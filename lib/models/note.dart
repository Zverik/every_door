// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/constants.dart';
import 'package:every_door/helpers/draw_style.dart';
import 'package:every_door/helpers/geometry/geometry.dart';
import 'package:every_door/models/located.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:proximity_hash/geohash.dart';
import 'dart:convert' show json;

import 'package:uuid/uuid.dart';

@Bind()
class BaseNote extends Located {
  static const kNoteGeohashPrecision = 6;

  // TODO: this id is used raw from OSM and GeoScribble, potentially leading to conflicts.
  int? id;
  final int? type;
  final DateTime created;

  @override
  final String uniqueId;

  @override
  final LatLng location;

  @override
  bool isDeleted;

  BaseNote(
      {required this.location,
      this.id,
      required this.type,
      DateTime? created,
      this.isDeleted = false})
      : created = created ?? DateTime.now(),
        uniqueId = id?.toString() ?? Uuid().v1();

  @override
  bool get isModified => isNew || isDeleted;

  @override
  bool get isNew => (id ?? -1) < 0;

  /// Reverts changes if possible (except isNew) and returns true if successful.
  bool revert() {
    if (!isModified || isNew) return false;
    if (isDeleted) isDeleted = false;
    if (isModified)
      throw UnimplementedError('A note has a state that cannot be reverted.');
    return true;
  }

  static const kTableName = 'notes';
  static const kTableFields = [
    'id integer primary key',
    'type integer',
    'lat integer',
    'lon integer',
    'created integer',
    'is_changed integer',
    'is_deleting integer',
    'geohash text',
    'author text', // MapNote and MapDrawing
    'message text', // MapNote
    'comments text', // OsmNote
    'new_comment integer', // OsmNote
    'coords text', // MapDrawing
    'path_type text', // MapDrawing
  ];

  factory BaseNote.fromJson(Map<String, dynamic> data) {
    switch (data['type']) {
      case MapNote.dbType:
        return MapNote.fromJson(data);
      case OsmNote.dbType:
        return OsmNote.fromJson(data);
      case MapDrawing.dbType:
        return MapDrawing.fromJson(data);
    }
    throw ArgumentError('Unknown note type in the database: ${data["type"]}');
  }

  static LatLng _parseLocation(Map<String, dynamic> data) => LatLng(
      data['lat'] / kCoordinatePrecision, data['lon'] / kCoordinatePrecision);

  Map<String, dynamic> toJson() {
    assert(id != null, 'BaseNote id should not be null on saving');
    return {
      'id': id,
      'type': type,
      'lat': (location.latitude * kCoordinatePrecision).round(),
      'lon': (location.longitude * kCoordinatePrecision).round(),
      'created': created.millisecondsSinceEpoch,
      'is_changed': isModified ? 1 : 0,
      'is_deleting': isDeleted ? 1 : 0,
      'geohash': GeoHasher().encode(location.longitude, location.latitude,
          precision: kNoteGeohashPrecision),
    };
  }

  @override
  bool operator ==(other) {
    if (other is! BaseNote) return false;
    return id == other.id &&
        type == other.type &&
        location == other.location &&
        created == other.created;
  }

  @override
  int get hashCode => id.hashCode + type.hashCode + location.hashCode;

  @override
  String toString() => 'BaseNote(type $type, id $id)';
}

class MapNote extends BaseNote {
  static const kMaxLength = 40;
  static const dbType = 1;
  final String? author;
  String message;

  MapNote(
      {super.id,
      required super.location,
      this.author,
      required this.message,
      super.isDeleted,
      super.created})
      : super(type: dbType);

  factory MapNote.fromJson(Map<String, dynamic> data) {
    return MapNote(
      id: data['id'],
      location: BaseNote._parseLocation(data),
      author: data['author'],
      message: data['message'],
      created: DateTime.fromMillisecondsSinceEpoch(data['created']),
      isDeleted: data['is_deleting'] == 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'author': author,
      'message': message,
    };
  }

  @override
  String toString() => 'MapNote($id, $location, "$message" by $author)';
}

class OsmNoteComment {
  final String? author;
  String message;
  final DateTime date;
  final bool isNew;

  OsmNoteComment({
    this.author,
    required this.message,
    DateTime? date,
    this.isNew = false,
  }) : date = date ?? DateTime.now();

  factory OsmNoteComment.fromJson(Map<String, dynamic> data) {
    return OsmNoteComment(
      author: data['author'],
      message: data['message'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
      isNew: data['isNew'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (author != null) 'author': author,
      'message': message,
      'date': date.millisecondsSinceEpoch,
      'isNew': isNew,
    };
  }

  @override
  String toString() => 'Comment(${isNew ? "new " : ""}"$message" by $author)';
}

class OsmNote extends BaseNote {
  static const dbType = 2;
  final List<OsmNoteComment> comments;

  OsmNote({
    super.id,
    required super.location,
    this.comments = const [],
    super.created,
    super.isDeleted,
  }) : super(type: dbType);

  String? get author => comments.isEmpty ? null : comments.first.author;
  String? get message => comments.isEmpty ? null : comments.first.message;
  bool get hasNewComments => comments.any((c) => c.isNew);

  @override
  bool get isModified => super.isModified || hasNewComments;

  @override
  bool revert() {
    comments.removeWhere((c) => c.isNew);
    return super.revert();
  }

  String? getNoteTitle() {
    return (message?.length ?? 0) < 100 ? message : message?.substring(0, 100);
  }

  factory OsmNote.fromJson(Map<String, dynamic> data) {
    List<OsmNoteComment> comments = [];
    if (data['comments'] != null) {
      final parsed = json.decode(data['comments']);
      if (parsed is List) {
        comments.addAll(parsed.map((v) => OsmNoteComment.fromJson(v)));
      }
    }

    return OsmNote(
      id: data['id'],
      location: BaseNote._parseLocation(data),
      created: DateTime.fromMillisecondsSinceEpoch(data['created']),
      isDeleted: data['is_deleting'] == 1,
      comments: comments,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'comments': json.encode(comments.map((c) => c.toJson()).toList()),
      'new_comment': hasNewComments ? 1 : 0,
    };
  }

  @override
  String toString() =>
      'OsmNote(${isDeleted ? "closing " : (isModified ? "changed " : "")}$id, $location, $comments)';
}

class MapDrawing extends BaseNote {
  static const dbType = 3;
  final LineString path;
  final String? author;
  final DrawingStyle style;

  MapDrawing({
    super.id,
    required this.path,
    required this.style,
    this.author,
    super.created,
    super.isDeleted,
  }) : super(type: dbType, location: path.nodes[path.nodes.length >> 1]);

  factory MapDrawing.fromJson(Map<String, dynamic> data) {
    final coords = <LatLng>[];
    for (final part in (data['coords'] as String).split('|')) {
      final latlon =
          part.split(';').map((s) => double.parse(s.trim())).toList();
      if (latlon.length == 2) coords.add(LatLng(latlon[0], latlon[1]));
    }

    return MapDrawing(
      id: data['id'],
      style: styleByName(data['path_type']),
      author: data['author'],
      path: LineString(coords),
      created: DateTime.fromMillisecondsSinceEpoch(data['created']),
      isDeleted: data['is_deleting'] == 1,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'path_type': style.name,
      'author': author,
      'coords': path.nodes.map((c) => '${c.latitude};${c.longitude}').join('|'),
    };
  }

  @override
  String toString() => 'MapDrawing($id, "${style.name}", $location)';
}
