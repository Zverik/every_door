import 'dart:convert';

import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/private.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/osm_api_converters.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final osmApiProvider = Provider((ref) => OsmApiHelper(ref));

class OsmApiError extends Error {
  final int code;
  final String message;

  OsmApiError(this.code, this.message);

  @override
  String toString() => 'OsmApiError($code $message)';
}

class OsmApiHelper {
  final Ref _ref;

  OsmApiHelper(this._ref);

  Future<List<OsmElement>> map(LatLngBounds bounds) async {
    final url = Uri.https(kOsmEndpoint, '/api/0.6/map', {
      'bbox': '${bounds.west},${bounds.south},${bounds.east},${bounds.north}',
    });
    var client = http.Client();
    var request = http.Request('GET', url);
    try {
      var response = await client.send(request);
      if (response.statusCode != 200) {
        throw Exception('Failed to query OSM API: ${response.statusCode} $url');
      }
      final elements = await response.stream
          .transform(utf8.decoder)
          .toXmlEvents()
          .selectSubtreeEvents(
              (event) => kOsmTypes.containsKey(event.localName))
          .toXmlNodes()
          .transform(XmlToOsmConverter())
          .transform(MarkReferenced())
          .transform(FlattenOsmGeometry(clearMembers: false))
          .transform(FilterAmenities())
          .flatten()
          .toList();
      print('Downloaded ${elements.length} elements');
      return elements;
    } finally {
      client.close();
    }
  }

  String buildOsmChange(Iterable<OsmChange> changes, String? changeset, [Map<OsmId, OsmElement>? idMap]) {
    // TODO: Test that changing ways and relations works: that they have their members.
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osmChange', nest: () {
      builder.attribute('version', '0.6');
      builder.attribute('generator', '$kAppTitle $kAppVersion');
      int nodeId = -1;
      for (final change in changes) {
        if (!change.isModified) return;
        final action = change.deleted
            ? 'delete'
            : change.isNew
                ? 'create'
                : 'modify';
        final OsmElement el = change.toElement(
          change.element?.id.id ?? nodeId--,
          change.element?.version ?? 1,
        );
        if (idMap != null) idMap[el.id] = el;
        builder.element(action, nest: () {
          el.toXML(builder, changeset: changeset, visible: !change.deleted);
        });
      }
    });
    return builder.buildDocument().toXmlString();
  }

  String _buildChangeset() {
    final tags = _ref.read(changesetTagsProvider);
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', nest: () {
      builder.element('changeset', nest: () {
        tags.forEach((key, value) {
          builder.element('tag', nest: () {
            builder.attribute('k', key);
            builder.attribute('v', value);
          });
        });
      });
    });
    return builder.buildDocument().toXmlString();
  }

  Future _updateElementsAfterUpload(List<UploadedElement> elements) async {
    final changes = _ref.read(changesProvider);
    changes.clearChanges(); // Note that it keeps changes with non-empty errors

    final data = _ref.read(osmDataProvider);
    for (final el in elements) {
      if (el.isDeleted) {
        await data.deleteElement(el.oldElement);
      } else {
        await data.updateElement(el.newElement);
      }
    }
  }

  List<UploadedElement> _parseUploadResponse(
      String response, Map<OsmId, OsmElement> idMap) {
    final doc = XmlDocument.parse(response);
    final diff =
        doc.children.firstWhere((node) => node is XmlElement) as XmlElement;
    return diff.children
        .map((node) => UploadedElement.fromXML(node, idMap))
        .whereType<UploadedElement>()
        .toList();
  }

  Future<List<UploadedElement>> _uploadEverything(
      Iterable<OsmChange> changes, String changeset, Map<String, String> headers) async {
    final idMap = <OsmId, OsmElement>{};
    final resp = await http.post(
      Uri.https(kOsmEndpoint, '/api/0.6/changeset/$changeset/upload'),
      headers: headers,
      body: buildOsmChange(changes, changeset, idMap),
    );
    if (resp.statusCode != 200) {
      throw OsmApiError(resp.statusCode, 'Failed to upload data: ${resp.body}');
    }
    return _parseUploadResponse(resp.body, idMap);
  }

  String _buildSingleChange(OsmChange change, String changeset) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', nest: () {
      final OsmElement el = change.toElement(
        change.element?.id.id ?? 0,
        change.element?.version ?? 1,
      );
      el.toXML(builder, changeset: changeset, visible: !change.deleted);
    });
    return builder.buildDocument().toXmlString();
  }

  Future<List<UploadedElement>> _uploadOneByOne(
      Iterable<OsmChange> allChanges, String changeset, Map<String, String> headers) async {
    final changes = _ref.read(changesProvider);
    List<UploadedElement> updates = [];
    for (final change in allChanges) {
      if (change.isNew) {
        final resp = await http.put(
          Uri.https(kOsmEndpoint, '/api/0.6/node/create'),
          headers: headers,
          body: _buildSingleChange(change, changeset),
        );
        if (resp.statusCode != 200) {
          if (resp.statusCode > 400 && resp.statusCode < 500) {
            await changes.setError(change, resp.body);
            print('Failed to create a node: ${resp.body}');
          } else {
            throw OsmApiError(resp.statusCode, 'Failed to create a node: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          updates.add(UploadedElement(
            change.toElement(0, 1), // Id and version do not matter.
            newId: int.parse(resp.body.trim()),
            newVersion: 1,
          ));
        }
      } else if (change.deleted) {
        String objRef =
            '${kOsmElementTypeName[change.id.type]}/${change.id.id}';
        final resp = await http.delete(
          Uri.https(kOsmEndpoint, '/api/0.6/$objRef'),
          headers: headers,
          body: _buildSingleChange(change, changeset),
        );
        print('Delete $objRef: status ${resp.statusCode}');
        if (resp.statusCode != 200 && resp.statusCode != 410) {
          // 404 is for "already deleted", fine by us.
          if (resp.statusCode > 400 && resp.statusCode < 500) {
            await changes.setError(change, resp.body);
            print('Failed to delete $objRef: ${resp.body}');
          } else {
            throw OsmApiError(resp.statusCode, 'Failed to delete $objRef: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          updates.add(UploadedElement(change.element!));
        }
      } else if (change.isModified) {
        String objRef =
            '${kOsmElementTypeName[change.id.type]}/${change.id.id}';
        final resp = await http.put(
          Uri.https(kOsmEndpoint, '/api/0.6/$objRef'),
          headers: headers,
          body: _buildSingleChange(change, changeset),
        );
        if (resp.statusCode != 200) {
          if (resp.statusCode > 400 && resp.statusCode < 500) {
            await changes.setError(change, resp.body);
            print('Failed to update $objRef: ${resp.body}');
          } else {
            throw OsmApiError(resp.statusCode, 'Failed to update $objRef: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          updates.add(UploadedElement(
            change.element!,
            newId: change.id.id, // So it doesn't register as deleted
            newVersion: int.parse(resp.body.trim()),
          ));
        }
      }
    }
    return updates;
  }

  Future<int> uploadChanges([bool includeErrored = false]) async {
    final changes = _ref.read(changesProvider).all(includeErrored);
    if (changes.isEmpty) return 0;

    final auth = _ref.read(authProvider.notifier);
    if (!auth.authorized)
      throw StateError('Log in first.');

    final headers = await auth.getAuthHeaders();
    final resp = await http.put(
      Uri.https(kOsmEndpoint, '/api/0.6/changeset/create'),
      headers: headers,
      body: _buildChangeset(),
    );
    if (resp.statusCode != 200) {
      throw OsmApiError(resp.statusCode, 'Failed to create changeset: ${resp.body}');
    }
    final changeset = resp.body.trim();

    try {
      List<UploadedElement> updates;
      try {
        updates = await _uploadEverything(changes, changeset, headers);
      } on OsmApiError catch (e) {
        if (e.code == 409 || e.code == 404 || e.code == 412 || e.code == 410) {
          // Try one-by-one only on conflict.
          updates = await _uploadOneByOne(changes, changeset, headers);
          // TODO: Update changeset comment for changes actually uploaded.
        } else {
          rethrow;
        }
      }
      // This keeps elements with errors, so "includeErrored" doesn't apply.
      _updateElementsAfterUpload(updates);
      return updates.length;
    } finally {
      await http.put(
        Uri.https(kOsmEndpoint, '/api/0.6/changeset/$changeset/close'),
        headers: headers,
      );
    }
  }
}
