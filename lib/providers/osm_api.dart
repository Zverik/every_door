import 'dart:convert';

import 'package:every_door/helpers/geometry/snap_nodes.dart';
import 'package:every_door/helpers/tags/snap_tags.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:every_door/providers/api_status.dart';
import 'package:every_door/providers/changes.dart';
import 'package:every_door/providers/changeset_tags.dart';
import 'package:every_door/providers/osm_auth.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;
import 'package:http/http.dart' as http;
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/osm_api_converters.dart';
import 'package:logging/logging.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final osmApiProvider = Provider((ref) => OsmApiHelper(ref));

class OsmApiError implements Exception {
  final int code;
  final String message;

  OsmApiError(this.code, this.message);

  @override
  String toString() => 'OsmApiError($code $message)';
}

class OsmApiHelper {
  final Ref _ref;
  static final _logger = Logger('OsmApiHelper');

  OsmApiHelper(this._ref);

  Future<List<OsmElement>> map(LatLngBounds bounds,
      {Set<RoadNameRecord>? roadNames}) async {
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
          .transform(CollectGeometry())
          .transform(ExtractRoadNames(roadNames))
          .transform(StripMembers(clearMembers: false))
          .transform(FilterAmenities())
          .flatten()
          .toList();
      // TODO: what to do with road names?
      return elements;
    } finally {
      client.close();
    }
  }

  Future<List<OsmElement>> elements(Iterable<OsmId> ids) async {
    const kBatchSize = 500; // elements in a single request
    var client = http.Client();
    try {
      final List<OsmElement> elements = [];
      for (final typ in OsmElementType.values) {
        final typeIds = ids.where((id) => id.type == typ);
        for (int i = 0; i < (typeIds.length / kBatchSize).ceil(); i++) {
          final typesName = kOsmElementTypeName[typ]! + 's';
          final url = Uri.https(kOsmEndpoint, '/api/0.6/$typesName', {
            typesName: typeIds
                .skip(kBatchSize * i)
                .take(kBatchSize)
                .map((e) => e.ref)
                .join(','),
          });
          var request = http.Request('GET', url);
          var response = await client.send(request);
          if (response.statusCode != 200) {
            throw Exception(
                'Failed to query OSM API: ${response.statusCode} $url');
          }
          final els = await response.stream
              .transform(utf8.decoder)
              .toXmlEvents()
              .selectSubtreeEvents(
                  (event) => kOsmTypes.containsKey(event.localName))
              .toXmlNodes()
              .transform(XmlToOsmConverter())
              .flatten()
              .toList();
          elements.addAll(els);
        }
      }
      return elements;
    } finally {
      client.close();
    }
  }

  Future<List<OsmElement>> snapWays(LatLngBounds bounds) async {
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
          .transform(CollectGeometry())
          .transform(FilterSnapTargets())
          .flatten()
          .toList();
      return elements;
    } finally {
      client.close();
    }
  }

  String buildOsmChange(Iterable<OsmChange> changes, String? changeset,
      [Map<OsmId, OsmElement>? idMap]) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osmChange', nest: () {
      builder.attribute('version', '0.6');
      builder.attribute('generator', '$kAppTitle $kAppVersion');
      int spareId = -1000;
      for (final change in changes) {
        if (!change.isModified) return;
        final action = change.hardDeleted
            ? 'delete'
            : change.isNew
                ? 'create'
                : 'modify';
        if (change.isNew && change.newId == null) change.newId = spareId--;
        final OsmElement el = change.toElement(
          newId: change.element?.id.ref,
          newVersion: change.element?.version,
        );
        if (idMap != null) idMap[el.id] = el;
        builder.element(action, nest: () {
          el.toXML(builder, changeset: changeset, visible: !change.hardDeleted);
        });
      }
    });
    return builder.buildDocument().toXmlString();
  }

  String _buildChangeset(Iterable<OsmChange> changes) {
    final tags =
        _ref.read(changesetTagsProvider).generateChangesetTags(changes);
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
    final data = _ref.read(osmDataProvider);
    for (final el in elements) {
      if (el.isDeleted) {
        await data.deleteElement(el.oldElement);
      } else {
        final newElement = el.newElement;
        if (newElement.nodes != null) {
          // Update node ids from placeholders
          for (int i = 0; i < newElement.nodes!.length; i++) {
            final oldNodeId = newElement.nodes![i];
            if (oldNodeId < 0) {
              bool foundNew = false;
              for (final nodeEl in elements) {
                if (nodeEl.oldElement.isPoint &&
                    nodeEl.oldElement.id.ref == oldNodeId) {
                  newElement.nodes![i] =
                      nodeEl.newId ?? nodeEl.oldElement.id.ref;
                  _logger.info(
                      'Replaced placeholder $oldNodeId with ${nodeEl.newElement.id} in ${newElement.id}.');
                  foundNew = true;
                  break;
                }
              }
              if (!foundNew) {
                _logger.warning(
                    'Could not find new node id for placeholder $oldNodeId in ${el.newElement.id}.');
              }
            }
          }
        }
        await data.updateElement(newElement);
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

  Future<List<UploadedElement>> _uploadEverything(Iterable<OsmChange> changes,
      String changeset, Map<String, String> headers) async {
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
        newId: change.element?.id.ref,
        newVersion: change.element?.version,
      );
      el.toXML(builder, changeset: changeset, visible: !change.hardDeleted);
    });
    return builder.buildDocument().toXmlString();
  }

  Future<List<UploadedElement>> _uploadOneByOne(Iterable<OsmChange> allChanges,
      String changeset, Map<String, String> headers) async {
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
          _logger.warning('Failed to create a node: ${resp.body}');
          if ((resp.statusCode > 400 && resp.statusCode < 500) ||
              updates.isNotEmpty) {
            if (resp.statusCode < 400 || resp.statusCode > 500) return updates;
            await changes.setError(change, resp.body);
          } else {
            throw OsmApiError(
                resp.statusCode, 'Failed to create a node: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          final newId = int.parse(resp.body.trim());
          updates.add(UploadedElement(
            change.toElement(newId: newId), // Id and version do not matter.
            newId: newId,
            newVersion: 1,
          ));
        }
      } else if (change.hardDeleted) {
        String objRef = change.id.fullRef;
        final resp = await http.delete(
          Uri.https(kOsmEndpoint, '/api/0.6/$objRef'),
          headers: headers,
          body: _buildSingleChange(change, changeset),
        );
        if (resp.statusCode != 200 && resp.statusCode != 410) {
          // 410 is for "already deleted", fine by us.
          _logger.warning('Failed to delete $objRef: ${resp.body}');
          if ((resp.statusCode > 400 && resp.statusCode < 500) ||
              updates.isNotEmpty) {
            if (resp.statusCode < 400 || resp.statusCode > 500) return updates;
            await changes.setError(change, resp.body);
          } else {
            throw OsmApiError(
                resp.statusCode, 'Failed to delete $objRef: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          updates.add(UploadedElement(change.element!));
        }
      } else if (change.isModified) {
        String objRef = change.id.fullRef;
        final resp = await http.put(
          Uri.https(kOsmEndpoint, '/api/0.6/$objRef'),
          headers: headers,
          body: _buildSingleChange(change, changeset),
        );
        if (resp.statusCode != 200) {
          _logger.warning('Failed to update $objRef: ${resp.body}');
          if ((resp.statusCode > 400 && resp.statusCode < 500) ||
              updates.isNotEmpty) {
            if (resp.statusCode < 400 || resp.statusCode > 500) return updates;
            await changes.setError(change, resp.body);
          } else {
            throw OsmApiError(
                resp.statusCode, 'Failed to update $objRef: ${resp.body}');
          }
        } else {
          await changes.setError(change, null);
          updates.add(UploadedElement(
            change.toElement(newId: change.id.ref),
            newId: change.id.ref, // So it doesn't register as deleted
            newVersion: int.parse(resp.body.trim()),
          ));
        }
      }
    }
    return updates;
  }

  /// For changes that require snapping, downloads relevant ways, snaps
  /// the changes (altering their locations), and returns OsmChanges for ways.
  Future<List<OsmChange>> _downloadWaysToSnap(List<OsmChange> changes) async {
    final toSnap = changes.where((e) => e.isNew);
    final snapKinds = {for (final e in toSnap) e: detectSnap(e.getFullTags())};
    snapKinds.removeWhere((_, value) => value == SnapTo.nothing);
    if (snapKinds.isEmpty) return const [];

    final snapper = Snapper();

    // 1. Download all ways to snap to.
    final bounds =
        snapper.groupIntoSmallBounds(snapKinds.keys.map((e) => e.location));
    final snapTargets = <OsmId, OsmElement>{};
    for (final b in bounds) {
      final elements = await snapWays(b);
      for (final e in elements) snapTargets[e.id] = e;
    }
    if (snapTargets.isEmpty) return const [];

    // 2. For each change, snap it and store the results.
    final modifiedWays = <OsmId>{};
    for (final e in snapKinds.entries) {
      final snapped = snapper.snapToClosest(
        nodeId: e.key.newId!,
        location: e.key.location,
        ways: snapTargets.values
            .where((element) => isSnapTargetTags(element.tags, e.value)),
      );
      if (snapped != null) {
        e.key.newLocation = snapped.newLocation;
        snapTargets[snapped.newElement.id] = snapped.newElement;
        modifiedWays.add(snapped.newElement.id);
      } else {
        if (e.key['fixme'] == null)
          e.key['fixme'] = 'Please merge me into a nearby ${e.value.name}';
      }
    }

    // 3. Prepare OsmChanges from the modified ways
    // Setting newNodes to trigger isModified.
    return modifiedWays
        .map((e) => OsmChange(snapTargets[e]!, newNodes: snapTargets[e]!.nodes))
        .toList();
  }

  List<OsmChange> _mergeUpdatedElements(
      List<OsmChange> changes, List<OsmChange> newChanges) {
    final changeMap = {for (final c in changes) c.databaseId: c};
    for (final c in newChanges) {
      changeMap[c.databaseId] =
          changeMap[c.databaseId]?.mergeNewElement(c.element!) ?? c;
    }
    return changeMap.values.toList();
  }

  Future<List<OsmChange>> _updateUnderlyingElements(
      List<OsmChange> changes) async {
    final changesProv = _ref.read(changesProvider);
    final elementsToUpdate = Map.fromEntries(changes
        .where((e) => !e.isNew)
        .map((e) => MapEntry(e.element!.id, e.element!)));

    // Query for recent version of the elements to update.
    final updated = await elements(elementsToUpdate.keys);

    // Update their missing metadata from the old elements.
    final Iterable<OsmElement> updatedElements =
        updated.map((e) => e.updateMeta(elementsToUpdate[e.id]));

    // Save them to the database.
    await _ref.read(osmDataProvider).storeElements(updatedElements, null);

    // Wrap the new elements with OsmChange, updating the latter from the new tags.
    final List<OsmChange> updatedChanges =
        updatedElements.map((e) => changesProv.changeFor(e)).toList();

    // Build the new `changes` list.
    final updatedIds = Set.of(updatedChanges.map((e) => e.id));
    updatedChanges
        .addAll(changes.where((e) => e.isNew || !updatedIds.contains(e.id)));
    changes = updatedChanges.where((e) => e.isModified).toList();

    return changes;
  }

  Future<String> _openChangeset(
      List<OsmChange> changes, Map<String, String> headers) async {
    final resp = await http.put(
      Uri.https(kOsmEndpoint, '/api/0.6/changeset/create'),
      headers: headers,
      body: _buildChangeset(changes),
    );
    if (resp.statusCode != 200) {
      throw OsmApiError(
          resp.statusCode, 'Failed to create changeset: ${resp.body}');
    }
    return resp.body.trim();
  }

  Future<int> _uploadChangesPack(List<OsmChange> changes) async {
    // Download elements to update the data and avoid version errors.
    changes = await _updateUnderlyingElements(changes);
    if (changes.isEmpty) return 0;

    // Keep the identifiers for clearing the changes later.
    final changeIds = changes.map((c) => c.databaseId).toList();

    // Enumerate new elements.
    int nodeId = -1;
    for (final c in changes) if (c.isNew) c.newId = nodeId--;

    // Snap elements to ways.
    final updatedWays = await _downloadWaysToSnap(changes);
    bool haveDependentWays = updatedWays.isNotEmpty;
    // Some of these ways can be present in the changes.
    changes = _mergeUpdatedElements(changes, updatedWays);
    changes.sort();

    // Prepare authentication headers.
    final auth = _ref.read(authProvider.notifier);
    final headers = await auth.getAuthHeaders();

    // Open a changeset and get its id.
    final changeset = await _openChangeset(changes, headers);

    // Upload changes.
    try {
      bool clearErrored;
      List<UploadedElement> updates;
      try {
        updates = await _uploadEverything(changes, changeset, headers);
        clearErrored = true;
      } on OsmApiError catch (e) {
        // TODO: some element could be uploaded, with no indication from API.
        // Not trying one by one when we have way geometry changes.
        if (!haveDependentWays && {409, 404, 412, 410}.contains(e.code)) {
          // Try one-by-one only on conflict.
          updates = await _uploadOneByOne(changes, changeset, headers);
          clearErrored = false;
          // Update changeset comment for changes actually uploaded.
          await http.put(
            Uri.https(kOsmEndpoint, '/api/0.6/changeset/$changeset'),
            headers: headers,
            body: _buildChangeset(changes.where((c) => c.error == null)),
          );
          // TODO: filter changeIds by changes actually uploaded.
        } else {
          rethrow;
        }
      }
      final chProv = _ref.read(changesProvider);
      await chProv.clearChanges(includeErrored: clearErrored, ids: changeIds);
      await _updateElementsAfterUpload(updates);
      return updates.length;
    } finally {
      // Close the changeset.
      await http.put(
        Uri.https(kOsmEndpoint, '/api/0.6/changeset/$changeset/close'),
        headers: headers,
      );
    }
  }

  Future<int> uploadChanges([bool includeErrored = false]) async {
    List<OsmChange> changes = _ref.read(changesProvider).all(includeErrored);
    if (changes.isEmpty) return 0;

    // Check whether we've authorized.
    final auth = _ref.read(authProvider.notifier);
    if (!auth.authorized) throw StateError('Log in first.');

    // Set the mutex.
    if (_ref.read(apiStatusProvider) != ApiStatus.idle)
      throw StateError('API is busy');
    _ref.read(apiStatusProvider.notifier).state = ApiStatus.uploading;

    try {
      int count = 0;
      for (final part
          in Snapper().splitChanges(changes, minGap: kChangesetSplitGap)) {
        count += await _uploadChangesPack(part);
      }
      return count;
    } finally {
      _ref.read(apiStatusProvider.notifier).state = ApiStatus.idle;
    }
  }
}
