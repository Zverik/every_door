// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:every_door/helpers/tags/snap_tags.dart';
import 'package:fast_geohash/fast_geohash_str.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'dart:convert';

import 'package:xml/xml.dart';

/// An element type: node, way, or relation.
@Bind()
enum OsmElementType { node, way, relation }

/// Mapping from the enum value to strings.
const kOsmElementTypeName = <OsmElementType, String>{
  OsmElementType.node: 'node',
  OsmElementType.way: 'way',
  OsmElementType.relation: 'relation',
};

/// OSM identifier: a type and a number.
@Bind()
class OsmId {
  final OsmElementType type;
  final int ref;

  const OsmId(this.type, this.ref);

  /// Parses a string like "n123" into [OsmId] with the type from the letter
  /// (e.g. node for "n") and the number from the rest.
  factory OsmId.fromString(String s) {
    OsmElementType typ;
    final t = s.toLowerCase().substring(0, 1);
    if (t == 'n')
      typ = OsmElementType.node;
    else if (t == 'w')
      typ = OsmElementType.way;
    else
      typ = OsmElementType.relation;
    return OsmId(typ, int.parse(s.substring(1)));
  }

  /// Returns a representation like "node/123", to use in building
  /// website URLs.
  String get fullRef => '${kOsmElementTypeName[type]}/$ref';

  /// Returns a string like "n123" for a node with id=123. Can be
  /// parsed back into an [OsmId] with [OsmId.fromString].
  @override
  String toString() {
    String typ;
    if (type == OsmElementType.node)
      typ = 'n';
    else if (type == OsmElementType.way)
      typ = 'w';
    else
      typ = 'r';
    return '$typ$ref';
  }

  @override
  bool operator ==(Object other) =>
      other is OsmId && type == other.type && ref == other.ref;

  @override
  int get hashCode => type.hashCode + ref.hashCode;
}

/// An OSM relation member. Contains of an OSM id and an optional [role].
@Bind()
class OsmMember {
  final OsmId id;
  final String? role;

  const OsmMember(this.id, [this.role]);

  OsmElementType get type => id.type;

  factory OsmMember.fromString(String s) {
    final idx = s.indexOf(' ');
    if (idx < 0) return OsmMember(OsmId.fromString(s));
    return OsmMember(
        OsmId.fromString(s.substring(0, idx)), s.substring(idx + 1));
  }

  @override
  String toString() {
    if (role == null) return id.toString();
    return '$id $role';
  }
}

/// Whether this object is a member of a way or a relation. Way
/// membership takes precedence.
@Bind()
enum IsMember { no, way, relation }

/// An OSM element downloaded from the server.
@Bind()
class OsmElement {
  final String source;
  final OsmId id;
  final Map<String, String> tags;
  final int version;
  final DateTime timestamp;
  final DateTime? downloaded;
  final LatLng? center;
  final Geometry? geometry;
  final List<int>? nodes;
  final Map<int, LatLng>? nodeLocations; // not stored to the database
  final List<OsmMember>? members;
  final IsMember isMember;

  OsmElementType get type => id.type;

  OsmElement({
    required this.source,
    required this.id,
    required this.version,
    required this.timestamp,
    this.downloaded,
    required this.tags,
    LatLng? center,
    this.geometry,
    this.nodes,
    this.nodeLocations,
    this.members,
    this.isMember = IsMember.no,
  }) : center = center ??
            (geometry is Polygon
                ? geometry.findPointOnSurface()
                : geometry?.center);

  OsmElement copyWith(
      {Map<String, String>? tags,
      int? id,
      int? version,
      LatLng? center,
      Geometry? geometry,
      IsMember? isMember,
      List<int>? nodes,
      Map<int, LatLng>? nodeLocations,
      bool currentTimestamp = false,
      bool clearMembers = false}) {
    return OsmElement(
      source: source,
      id: id != null ? OsmId(this.id.type, id) : this.id,
      version: version ?? this.version,
      timestamp: currentTimestamp ? DateTime.now().toUtc() : timestamp,
      downloaded: downloaded,
      tags: tags ?? this.tags,
      center: center ?? this.center,
      geometry: geometry ?? this.geometry,
      nodes: clearMembers ? null : (nodes ?? this.nodes),
      nodeLocations: clearMembers || (nodeLocations?.isEmpty ?? false)
          ? null
          : (nodeLocations ?? this.nodeLocations),
      members: clearMembers ? null : members,
      isMember: isMember ?? this.isMember,
    );
  }

  /// Updates location and reference properties from `old`
  /// (When this element was downloaded fresh, but is missing some).
  OsmElement updateMeta(OsmElement? old) {
    if (old == null) return this;
    return OsmElement(
      source: source,
      id: id,
      version: version,
      timestamp: timestamp,
      downloaded: downloaded,
      tags: tags,
      center: center ?? old.center,
      geometry: geometry ?? old.geometry,
      nodes: nodes ?? old.nodes,
      nodeLocations: nodeLocations ?? old.nodeLocations,
      members: members ?? old.members,
      isMember: isMember,
    );
  }

  static const kTableName = 'osm_data';
  static const kTableFields = <String>[
    'osmid text primary key',
    'version integer',
    'lat integer',
    'lon integer',
    'geohash text',
    'tags text',
    'timestamp integer',
    'downloaded integer',
    'nodes text',
    'members text',
    'is_member integer',
    'source text',
  ];

  factory OsmElement.fromJson(Map<String, dynamic> data) {
    List<dynamic>? members = json.decode(data['members']);
    String? nodes = data['nodes'];
    final int m = data['is_member'];
    return OsmElement(
      source: data['source'] ?? 'osm',
      id: OsmId.fromString(data['osmid']),
      version: data['version'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      downloaded: data['downloaded'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(data['downloaded']),
      tags: json.decode(data['tags']).map<String, String>(
          (key, value) => MapEntry(key.toString(), value.toString())),
      center: data['lat'] == null
          ? null
          : LatLng(data['lat'] / kCoordinatePrecision,
              data['lon'] / kCoordinatePrecision),
      nodes: nodes?.split(',').map((e) => int.parse(e)).toList(),
      members: members
          ?.whereType<String>()
          .map((e) => OsmMember.fromString(e))
          .toList(),
      isMember: m == 1
          ? IsMember.way
          : m == 2
              ? IsMember.relation
              : IsMember.no,
    );
  }

  Map<String, dynamic> toJson() {
    final center = this.center;
    return {
      'osmid': id.toString(),
      'source': source,
      'version': version,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'downloaded': downloaded?.millisecondsSinceEpoch,
      'lat': center == null
          ? null
          : (center.latitude * kCoordinatePrecision).round(),
      'lon': center == null
          ? null
          : (center.longitude * kCoordinatePrecision).round(),
      'geohash': center == null
          ? null
          : geohash.encode(
              center.latitude, center.longitude, kGeohashPrecision),
      // Not serializing bounds
      'tags': json.encode(tags),
      'nodes': nodes?.join(','),
      'members': json.encode(members?.map((e) => e.toString()).toList()),
      'is_member': isMember == IsMember.relation
          ? 2
          : isMember == IsMember.way
              ? 1
              : 0,
    };
  }

  void toXML(XmlBuilder builder, {String? changeset, bool visible = true}) {
    builder.element(kOsmElementTypeName[id.type]!, nest: () {
      builder.attribute('id', id.ref);
      builder.attribute('version', version);
      builder.attribute('visible', visible ? 'true' : 'false');
      if (changeset != null) builder.attribute('changeset', changeset);

      if (id.type == OsmElementType.node) {
        builder.attribute('lon', center!.longitude);
        builder.attribute('lat', center!.latitude);
      }

      if (visible) {
        tags.forEach((key, value) {
          builder.element('tag', nest: () {
            builder.attribute('k', key);
            builder.attribute('v', value);
          });
        });
        nodes?.forEach((ref) {
          builder.element('nd', nest: () {
            builder.attribute('ref', ref);
          });
        });
        members?.forEach((m) {
          builder.element('member', nest: () {
            builder.attribute('type', kOsmElementTypeName[m.id.type]!);
            builder.attribute('ref', m.id.ref);
            builder.attribute('role', m.role ?? '');
          });
        });
      }
    });
  }

  bool get isPoint => id.type == OsmElementType.node;
  bool get isGood => ElementKind.everything.matchesTags(tags);
  bool get isSnapTarget =>
      id.type == OsmElementType.way && isSnapTargetTags(tags);
  bool get isGeometryValid =>
      nodes != null &&
      nodes!.length >= 2 &&
      nodes!.every((element) => nodeLocations?.containsKey(element) ?? false);

  bool get isArea {
    if (id.type == OsmElementType.way)
      return nodes == null ||
          (nodes!.length >= 2 && nodes!.first == nodes!.last);
    if (id.type == OsmElementType.relation)
      return tags['type'] == 'multipolygon';
    return false;
  }

  static String tagsToString(Map<String, String?> tags) {
    return '{' +
        tags.entries
            .map((e) => '${e.key}${e.value != null ? "=${e.value}" : " del"}')
            .join('|') +
        '}';
  }

  String get idVersion => '${id}v$version';

  @override
  String toString() {
    return 'OsmElement($id v$version, $center, ${nodes?.length ?? members?.length} members, ${tagsToString(tags)})';
  }

  @override
  bool operator ==(Object other) =>
      other is OsmElement && id == other.id && version == other.version;

  @override
  int get hashCode => id.hashCode + version.hashCode;
}
