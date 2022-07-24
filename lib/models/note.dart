import 'package:every_door/constants.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:proximity_hash/geohash.dart';
import 'dart:convert' show json;

class BaseNote {
  final int? id;
  final int? type;
  final LatLng location;
  final DateTime created;

  BaseNote(
      {required this.location, this.id, required this.type, DateTime? created})
      : created = created ?? DateTime.now();

  static const kTableName = 'notes';
  static const kTableFields = [
    'id integer',
    'type integer',
    'lat integer',
    'lon integer',
    'created integer',
    'geohash text',
    'author text', // MapNote and MapDrawing
    'message text', // MapNote
    'is_open integer', // OsmNote
    'comments text', // OsmNote
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

  Map<String, dynamic> baseJson() {
    return {
      'id': id,
      'lat': (location.latitude * kCoordinatePrecision).round(),
      'lon': (location.longitude * kCoordinatePrecision).round(),
      'created': created.millisecondsSinceEpoch,
      'geohash': GeoHasher().encode(location.longitude, location.latitude,
          precision: kGeohashPrecision),
    };
  }
}

class MapNote extends BaseNote {
  static const dbType = 1;
  final String author;
  final String message;

  MapNote(
      {super.id,
      required super.location,
      required this.author,
      required this.message,
      super.created})
      : super(type: dbType);

  factory MapNote.fromJson(Map<String, dynamic> data) {
    return MapNote(
      id: data['id'],
      location: BaseNote._parseLocation(data),
      author: data['author'],
      message: data['message'],
      created: DateTime.fromMillisecondsSinceEpoch(data['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...baseJson(),
      'author': author,
      'message': message,
    };
  }
}

class OsmNoteComment {
  final String? author;
  final String message;
  final DateTime date;

  const OsmNoteComment(
      {required this.author, required this.message, required this.date});

  factory OsmNoteComment.fromJson(Map<String, dynamic> data) {
    return OsmNoteComment(
      author: data['author'],
      message: data['message'],
      date: data['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (author != null) 'author': author,
      'message': message,
      'date': date.millisecondsSinceEpoch,
    };
  }
}

class OsmNote extends BaseNote {
  static const dbType = 2;
  final List<OsmNoteComment> comments;
  final bool isOpen;

  OsmNote({
    required super.id,
    required super.location,
    this.comments = const [],
    super.created,
    this.isOpen = true,
  }) : super(type: dbType);

  String? get author => comments.isEmpty ? null : comments.first.author;
  String? get message => comments.isEmpty ? null : comments.first.message;

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
      isOpen: data['is_open'] == 1,
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...baseJson(),
      'is_open': isOpen ? 1 : 0,
      'comments': json.encode(comments.map((c) => c.toJson()).toList()),
    };
  }
}

class MapDrawing extends BaseNote {
  static const dbType = 3;
  final List<LatLng> coordinates;
  final String author;
  final String pathType;

  MapDrawing(
      {super.id,
      required this.coordinates,
      required this.pathType,
      required this.author})
      : super(type: dbType, location: coordinates[coordinates.length >> 1]);

  factory MapDrawing.fromJson(Map<String, dynamic> data) {
    final coords = <LatLng>[];
    for (final part in (data['coords'] as String).split('|')) {
      final latlon =
          part.split(';').map((s) => double.parse(s.trim())).toList();
      if (latlon.length == 2) coords.add(LatLng(latlon[0], latlon[1]));
    }
    return MapDrawing(
      id: data['id'],
      pathType: data['path_type'],
      author: data['author'],
      coordinates: coords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...baseJson(),
      'path_type': type,
      'author': author,
      'coords':
          coordinates.map((c) => '${c.latitude};${c.longitude}').join('|'),
    };
  }
}
