import 'package:every_door/constants.dart';
import 'package:every_door/helpers/geometry.dart';
import 'package:every_door/helpers/good_tags.dart';
import 'package:every_door/models/note.dart';
import 'package:every_door/models/osm_element.dart';
import 'package:every_door/models/road_name.dart';
import 'package:logging/logging.dart';
import 'package:proximity_hash/geohash.dart';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;

const kOsmTypes = <String, OsmElementType>{
  'node': OsmElementType.node,
  'way': OsmElementType.way,
  'relation': OsmElementType.relation,
};

/// Information about a single uploaded element, as returned by OSM API.
/// Contains only an osm id and numeric values.
class UploadedElementRef {
  final OsmId oldId;
  final int? newId;
  final int? newVersion;

  bool get isDeleted => newId == null;

  const UploadedElementRef(this.oldId, this.newId, this.newVersion);

  static UploadedElementRef? fromXML(XmlNode node) {
    if (node is XmlElement && kOsmTypes.containsKey(node.name.local)) {
      final type = kOsmTypes[node.name.local]!;
      final String? oldId = node.getAttribute('old_id');
      if (oldId == null) {
        // This should not happen, but at least log something.
        Logger('UploadedElementRef').warning(
            'Wrong XML returned after the upload: ${node.toXmlString()}');
        return null;
      }
      return UploadedElementRef(
        OsmId(type, int.parse(oldId)),
        int.tryParse(node.getAttribute('new_id') ?? ''),
        int.tryParse(node.getAttribute('new_version') ?? ''),
      );
    }
    return null;
  }
}

/// Information about new id and version on an element.
/// Used when parsing an XML returned by changeset uploading method of OSM API.
class UploadedElement {
  final OsmElement oldElement;
  final int? newId;
  final int? newVersion;

  bool get isDeleted => newId == null;

  const UploadedElement(this.oldElement, {this.newId, this.newVersion});

  OsmElement get newElement =>
      oldElement.copyWith(id: newId, version: newVersion);

  static UploadedElement? fromXML(XmlNode node, Map<OsmId, OsmElement> idMap) {
    final ref = UploadedElementRef.fromXML(node);
    if (ref == null) return null;
    final element = idMap[ref.oldId];
    if (element == null) return null;
    return UploadedElement(element,
        newId: ref.newId, newVersion: ref.newVersion);
  }
}

/// Converts an XML stream from the `map` call of OSM API and returns
/// a list of raw `OsmElement` objects.
class XmlToOsmConverter extends Converter<List<XmlNode>, List<OsmElement>> {
  const XmlToOsmConverter();

  @override
  List<OsmElement> convert(List<XmlNode> input) {
    List<OsmElement> result = [];
    for (final node in input) {
      if (node is XmlElement && node.name.local == 'error') {
        throw FormatException('API returned error: ${node.innerText.trim()}');
      } else if (node is XmlElement && kOsmTypes.containsKey(node.name.local)) {
        final type = kOsmTypes[node.name.local]!;
        final tags = <String, String>{};
        for (final tag in node.findElements("tag")) {
          final k = tag.getAttribute("k");
          final v = tag.getAttribute("v");
          if (k != null && k.isNotEmpty && v != null && v.isNotEmpty)
            tags[k] = v;
        }
        LatLng? center;
        if (type == OsmElementType.node) {
          final lat = node.getAttribute("lat");
          final lon = node.getAttribute("lon");
          if (lat != null && lon != null)
            center = LatLng(double.parse(lat), double.parse(lon));
        }
        List<int>? nodes;
        if (type == OsmElementType.way) {
          nodes = [];
          for (final nd in node.findElements("nd")) {
            final ref = nd.getAttribute("ref");
            if (ref != null && ref.isNotEmpty) nodes.add(int.parse(ref));
          }
        }
        List<OsmMember>? members;
        if (type == OsmElementType.relation) {
          members = [];
          for (final member in node.findElements("member")) {
            final ref = member.getAttribute("ref");
            final typ = member.getAttribute("type");
            final role = member.getAttribute("role");
            if (ref != null &&
                ref.isNotEmpty &&
                typ != null &&
                kOsmTypes.containsKey(typ)) {
              members.add(OsmMember(
                OsmId(kOsmTypes[typ]!, int.parse(ref)),
                role,
              ));
            }
          }
        }
        result.add(OsmElement(
          id: OsmId(type, int.parse(node.getAttribute("id")!)),
          version: int.parse(node.getAttribute("version")!),
          timestamp: DateTime.parse(node.getAttribute("timestamp")!),
          downloaded: DateTime.now(),
          tags: tags,
          center: center,
          nodes: nodes,
          members: members,
        ));
      }
    }
    return result;
  }

  @override
  Sink<List<XmlNode>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return XmlToOsmSink(sink);
  }
}

class XmlToOsmSink implements ChunkedConversionSink<List<XmlNode>> {
  final XmlToOsmConverter _converter;
  final Sink<List<OsmElement>> _sink;

  XmlToOsmSink(this._sink) : _converter = const XmlToOsmConverter();

  @override
  void add(List<XmlNode> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Converts an XML stream from the `map` call of OSM API and returns
/// a list of raw `OsmElement` objects.
class XmlToNotesConverter extends Converter<List<XmlNode>, List<OsmNote>> {
  const XmlToNotesConverter();

  // Sample: "2022-07-24 16:30:22 UTC".
  static final kReDate =
      RegExp(r'^(2\d+)-([01]\d)-(\d\d)\s+(\d\d):(\d\d):(\d\d)\s+UTC$');

  static DateTime? _parseTimestamp(XmlElement node) {
    final value = node.innerText.trim();
    if (value.isEmpty) return null;
    final match = kReDate.matchAsPrefix(value);
    if (match == null) return DateTime.now();
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }

  static OsmNote? convertNode(XmlNode node) {
    if (node is XmlElement && node.name.local == 'error') {
      throw FormatException('API returned error: ${node.innerText.trim()}');
    } else if (node is XmlElement && node.name.local == 'note') {
      // Skip closed notes.
      final noteId = node.findElements('id');
      final status = node.findElements('status');
      if (noteId.isEmpty || status.isEmpty || status.first.innerText != 'open')
        return null;

      // Get location and creation date.
      final lat = node.getAttribute("lat");
      final lon = node.getAttribute("lon");
      if (lat == null || lon == null) return null;
      final location = LatLng(double.parse(lat), double.parse(lon));
      final created = node.findElements('date_created');

      // Parse comments.
      final comments = <OsmNoteComment>[];
      final commentsNodes = node.findElements('comments');
      if (commentsNodes.isNotEmpty) {
        for (final comment in commentsNodes.first.findElements('comment')) {
          final comDate = comment.findElements('date');
          final comUser = comment.findElements('user');
          final comText = comment.findElements('text');
          if (comDate.isNotEmpty && comText.isNotEmpty) {
            comments.add(OsmNoteComment(
              author: comUser.isEmpty ? null : comUser.first.innerText.trim(),
              message: comText.first.innerText.trim(),
              date: _parseTimestamp(comDate.first)!,
            ));
          }
        }
      }

      // Build the resulting object.
      return OsmNote(
        id: int.parse(noteId.first.innerText.trim()),
        location: location,
        created: created.isEmpty ? null : _parseTimestamp(created.first),
        comments: comments,
      );
    }
    return null;
  }

  @override
  List<OsmNote> convert(List<XmlNode> input) {
    List<OsmNote> result = [];
    for (final node in input) {
      if (node is XmlElement && node.name.local == 'error') {
        throw FormatException('API returned error: ${node.innerText.trim()}');
      } else if (node is XmlElement && node.name.local == 'note') {
        // Skip closed notes.
        final noteId = node.findElements('id');
        final status = node.findElements('status');
        if (noteId.isEmpty ||
            status.isEmpty ||
            status.first.innerText != 'open') continue;

        // Get location and creation date.
        final lat = node.getAttribute("lat");
        final lon = node.getAttribute("lon");
        if (lat == null || lon == null) continue;
        final location = LatLng(double.parse(lat), double.parse(lon));
        final created = node.findElements('date_created');

        // Parse comments.
        final comments = <OsmNoteComment>[];
        final commentsNodes = node.findElements('comments');
        if (commentsNodes.isNotEmpty) {
          for (final comment in commentsNodes.first.findElements('comment')) {
            final comDate = comment.findElements('date');
            final comUser = comment.findElements('user');
            final comText = comment.findElements('text');
            if (comDate.isNotEmpty && comText.isNotEmpty) {
              comments.add(OsmNoteComment(
                author: comUser.isEmpty ? null : comUser.first.innerText.trim(),
                message: comText.first.innerText.trim(),
                date: _parseTimestamp(comDate.first)!,
              ));
            }
          }
        }

        // Build the resulting object.
        result.add(OsmNote(
          id: int.parse(noteId.first.innerText.trim()),
          location: location,
          created: created.isEmpty ? null : _parseTimestamp(created.first),
          comments: comments,
        ));
      }
    }
    return result;
  }

  @override
  Sink<List<XmlNode>> startChunkedConversion(Sink<List<OsmNote>> sink) {
    return XmlToNotesSink(sink);
  }
}

class XmlToNotesSink implements ChunkedConversionSink<List<XmlNode>> {
  final XmlToNotesConverter _converter;
  final Sink<List<OsmNote>> _sink;

  XmlToNotesSink(this._sink) : _converter = const XmlToNotesConverter();

  @override
  void add(List<XmlNode> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Sets `isMember` property on objects that are referenced
/// by other objects in the stream.
class MarkReferenced extends Converter<List<OsmElement>, List<OsmElement>> {
  final Set<OsmId> _refs = {};
  final Map<OsmId, OsmElement> _stack = {};

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    List<OsmElement> referenced = [];
    for (final element in input) {
      // Build an iterable of references
      Iterable<OsmId>? refs;
      if (element.nodes != null) {
        refs =
            element.nodes?.map((nodeId) => OsmId(OsmElementType.node, nodeId));
      } else if (element.members != null) {
        // TODO: allow moving relation members, since the dependency is not geometric.
        refs = element.members?.map((member) => member.id);
      }

      // Process references in this element
      final isMember = element.id.type == OsmElementType.relation
          ? IsMember.relation
          : IsMember.way;

      if (refs != null) {
        for (final ref in refs) {
          final el = _stack[ref];
          if (el != null) {
            referenced.add(el.copyWith(isMember: isMember));
            _stack.remove(ref);
          } else {
            _refs.add(ref);
          }
        }
      }

      // Emit if already referenced, stash otherwise
      if (_refs.contains(element.id)) {
        referenced.add(element.copyWith(isMember: isMember));
        _refs.remove(element.id);
      } else {
        _stack[element.id] = element;
      }
    }
    return referenced;
  }

  /// Returns the remaining unreferenced elements.
  List<OsmElement> finish() {
    return _stack.values.toList();
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return MarkReferencedSink(sink);
  }
}

class MarkReferencedSink implements ChunkedConversionSink<List<OsmElement>> {
  final MarkReferenced _converter;
  final Sink<List<OsmElement>> _sink;

  MarkReferencedSink(this._sink) : _converter = MarkReferenced();

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.add(_converter.finish());
    _sink.close();
  }
}

/// Fills `center` and `bounds` properties on all way and relation objects.
/// It does that by caching node locations. Also fills the `nodeLocations`
/// map on ways. See `StripMembers` for clearing that map.
class CollectGeometry extends Converter<List<OsmElement>, List<OsmElement>> {
  CollectGeometry();

  final Map<int, LatLng> nodeLocations = {};
  final Map<OsmId, Geometry> wayGeometries = {};

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    final List<OsmElement> result = [];
    for (final el in input) {
      if (el.type == OsmElementType.node) {
        if (el.center != null) {
          nodeLocations[el.id.ref] = el.center!;
          result.add(el);
        }
      } else if (el.type == OsmElementType.way) {
        if (el.nodes != null && el.nodes!.isNotEmpty) {
          final points = el.nodes!
              .map((nodeId) => nodeLocations[nodeId])
              .whereType<LatLng>();
          if (points.isNotEmpty) {
            final bounds = LatLngBounds.fromPoints(points.toList());
            final nodeLoc = el.nodes == null
                ? null
                : {
                    for (var n in el.nodes!)
                      if (nodeLocations.containsKey(n)) n: nodeLocations[n]
                  };
            Geometry geometry;
            if (nodeLoc == null ||
                (el.nodes?.any((n) => !nodeLoc.containsKey(n)) ?? true)) {
              geometry = Envelope(bounds);
            } else {
              final nodes = el.nodes!.map((n) => nodeLoc[n]!);
              try {
                geometry = nodes.first == nodes.last
                    ? Polygon(nodes)
                    : LineString(nodes);
              } on GeometryException {
                geometry = Envelope(bounds);
              }
            }
            wayGeometries[el.id] = geometry;
            result.add(el.copyWith(
                geometry: geometry,
                nodeLocations: nodeLoc?.cast<int, LatLng>()));
          }
        }
      } else if (el.type == OsmElementType.relation) {
        if (el.members != null) {
          final points = <LatLng>[];
          for (final m in el.members!) {
            if (m.type == OsmElementType.node &&
                nodeLocations.containsKey(m.id.ref)) {
              points.add(nodeLocations[m.id.ref]!);
            } else if (m.type == OsmElementType.way &&
                wayGeometries.containsKey(m.id)) {
              points.addAll([
                wayGeometries[m.id]!.bounds.northEast,
                wayGeometries[m.id]!.bounds.southWest,
              ]);
            }
          }
          if (points.isNotEmpty)
            result.add(el.copyWith(
                geometry: Envelope(LatLngBounds.fromPoints(points))));
        }
      }
    }
    return result;
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return CollectGeometrySink(sink);
  }
}

class CollectGeometrySink implements ChunkedConversionSink<List<OsmElement>> {
  final CollectGeometry _converter;
  final Sink<List<OsmElement>> _sink;

  CollectGeometrySink(this._sink) : _converter = CollectGeometry();

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// A pass-through converter that builds a list of road names and
/// their locations. Uses all node locations for highway ways if present.
class ExtractRoadNames extends Converter<List<OsmElement>, List<OsmElement>> {
  final Set<RoadNameRecord>? _names;

  const ExtractRoadNames(this._names);

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    if (_names == null) return input;
    for (final element in input) {
      if (element.type == OsmElementType.way &&
          element.center != null &&
          element.tags['name'] != null &&
          kHighwayRoadValues.contains(element.tags['highway'])) {
        // This is a named road, add it to the list.
        List<LatLng> coords;
        if ((element.nodeLocations ?? const {}).isNotEmpty)
          coords = element.nodeLocations!.values.toList();
        else
          coords = [element.center!];

        // Convert to hashes and store.
        final hashes = <String>{
          for (final c in coords)
            GeoHasher().encode(c.longitude, c.latitude,
                precision: kRoadNameGeohashPrecision)
        };
        _names!.addAll(
            hashes.map((h) => RoadNameRecord(element.tags['name']!, h)));
      }
    }
    return input;
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return ExtractRoadNamesSink(sink, _names);
  }
}

class ExtractRoadNamesSink implements ChunkedConversionSink<List<OsmElement>> {
  final ExtractRoadNames _converter;
  final Sink<List<OsmElement>> _sink;

  ExtractRoadNamesSink(this._sink, names)
      : _converter = ExtractRoadNames(names);

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Removes `nodeLocations` map from ways. Also removes nodes and members,
/// if `clearMembers` is set.
class StripMembers extends Converter<List<OsmElement>, List<OsmElement>> {
  final bool clearMembers;

  const StripMembers({this.clearMembers = false});

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    return input
        .map((el) => el.isPoint
            ? el
            : el.copyWith(clearMembers: clearMembers, nodeLocations: const {}))
        .toList();
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return StripMembersSink(sink, clearMembers);
  }
}

class StripMembersSink implements ChunkedConversionSink<List<OsmElement>> {
  final StripMembers _converter;
  final Sink<List<OsmElement>> _sink;

  StripMembersSink(this._sink, bool clearMembers)
      : _converter = StripMembers(clearMembers: clearMembers);

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Keeps only points and areas with "good" tags in the stream.
class FilterAmenities extends Converter<List<OsmElement>, List<OsmElement>> {
  const FilterAmenities();

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    return input.where((el) => (el.isPoint || el.isArea) && el.isGood).toList();
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return FilterAmenitiesSink(sink);
  }
}

class FilterAmenitiesSink implements ChunkedConversionSink<List<OsmElement>> {
  final FilterAmenities _converter;
  final Sink<List<OsmElement>> _sink;

  FilterAmenitiesSink(this._sink) : _converter = const FilterAmenities();

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Keeps only snap targets in the stream, for all kinds of snapping.
class FilterSnapTargets extends Converter<List<OsmElement>, List<OsmElement>> {
  const FilterSnapTargets();

  @override
  List<OsmElement> convert(List<OsmElement> input) {
    return input.where((el) => el.isSnapTarget && el.isGeometryValid).toList();
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return FilterSnapTargetsSink(sink);
  }
}

class FilterSnapTargetsSink implements ChunkedConversionSink<List<OsmElement>> {
  final FilterSnapTargets _converter;
  final Sink<List<OsmElement>> _sink;

  FilterSnapTargetsSink(this._sink) : _converter = const FilterSnapTargets();

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Parses an XML stream returned by a changeset upload OSM API method.
/// Returns a stream of `UploadedElementRef`, from which `UploadedElement`s
/// can be built.
class ParseUploaded extends Converter<List<XmlNode>, List<UploadedElementRef>> {
  const ParseUploaded();

  @override
  List<UploadedElementRef> convert(List<XmlNode> input) {
    List<UploadedElementRef> result = [];
    for (final node in input) {
      final el = UploadedElementRef.fromXML(node);
      if (el != null) result.add(el);
    }
    return result;
  }

  @override
  Sink<List<XmlNode>> startChunkedConversion(
      Sink<List<UploadedElementRef>> sink) {
    return ParseUploadedSink(sink);
  }
}

class ParseUploadedSink implements ChunkedConversionSink<List<XmlNode>> {
  final ParseUploaded _converter;
  final Sink<List<UploadedElementRef>> _sink;

  ParseUploadedSink(this._sink) : _converter = const ParseUploaded();

  @override
  void add(List<XmlNode> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}
