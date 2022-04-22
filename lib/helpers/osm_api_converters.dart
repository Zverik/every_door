import 'package:every_door/models/osm_element.dart';
import 'dart:convert';
import 'package:xml/xml.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:flutter_map/flutter_map.dart' show LatLngBounds;

const kOsmTypes = <String, OsmElementType>{
  'node': OsmElementType.node,
  'way': OsmElementType.way,
  'relation': OsmElementType.relation,
};

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
        print('Wrong XML returned after the upload: ${node.toXmlString()}');
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

class XmlToOsmConverter extends Converter<List<XmlNode>, List<OsmElement>> {
  const XmlToOsmConverter();

  @override
  List<OsmElement> convert(List<XmlNode> input) {
    List<OsmElement> result = [];
    for (final node in input) {
      if (node is XmlElement && kOsmTypes.containsKey(node.name.local)) {
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

class XmlToOsmSink extends ChunkedConversionSink<List<XmlNode>> {
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
        // Skipping relation members, since the dependency is not geometric.
        // refs = element.members?.map((member) => member.id);
      }

      // Process references in this element
      if (refs != null) {
        for (final ref in refs) {
          final el = _stack[ref];
          if (el != null) {
            referenced.add(el.copyWith(isMember: true));
            _stack.remove(ref);
          } else {
            _refs.add(ref);
          }
        }
      }

      // Emit if already referenced, stash otherwise
      if (_refs.contains(element.id)) {
        referenced.add(element.copyWith(isMember: true));
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

class MarkReferencedSink extends ChunkedConversionSink<List<OsmElement>> {
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

class FlattenOsmGeometry extends Converter<List<OsmElement>, List<OsmElement>> {
  final bool clearMembers;
  final bool addNodeLocations;

  FlattenOsmGeometry(
      {this.clearMembers = false, this.addNodeLocations = false});

  final Map<int, LatLng> nodeLocations = {};
  final Map<OsmId, LatLngBounds> wayBounds = {};

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
          final bounds = LatLngBounds.fromPoints(el.nodes!
              .map((nodeId) => nodeLocations[nodeId])
              .whereType<LatLng>()
              .toList());
          if (bounds.isValid) {
            wayBounds[el.id] = bounds;
            final nodeLoc = el.nodes == null
                ? null
                : {
                    for (var n in el.nodes!)
                      if (nodeLocations.containsKey(n)) n: nodeLocations[n]
                  };
            result.add(el.copyWith(
                bounds: bounds, nodeLocations: nodeLoc?.cast<int, LatLng>()));
          }
        }
      } else if (el.type == OsmElementType.relation) {
        if (el.members != null) {
          var bounds = LatLngBounds();
          for (final m in el.members!) {
            if (m.type == OsmElementType.node &&
                nodeLocations.containsKey(m.id.ref)) {
              bounds.extend(nodeLocations[m.id.ref]);
            } else if (m.type == OsmElementType.way &&
                wayBounds.containsKey(m.id)) {
              bounds.extendBounds(wayBounds[m.id]!);
            }
          }
          if (bounds.isValid) result.add(el.copyWith(bounds: bounds));
        }
      }
    }
    return result;
  }

  @override
  Sink<List<OsmElement>> startChunkedConversion(Sink<List<OsmElement>> sink) {
    return FlattenOsmSink(sink, clearMembers);
  }
}

class FlattenOsmSink extends ChunkedConversionSink<List<OsmElement>> {
  final FlattenOsmGeometry _converter;
  final Sink<List<OsmElement>> _sink;

  FlattenOsmSink(this._sink, bool clearMembers)
      : _converter = FlattenOsmGeometry(clearMembers: clearMembers);

  @override
  void add(List<OsmElement> chunk) {
    _sink.add(_converter.convert(chunk));
  }

  @override
  void close() {
    _sink.close();
  }
}

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

class FilterAmenitiesSink extends ChunkedConversionSink<List<OsmElement>> {
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

class FilterSnapTargetsSink extends ChunkedConversionSink<List<OsmElement>> {
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

class ParseUploadedSink extends ChunkedConversionSink<List<XmlNode>> {
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
