import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera_camera/camera_camera.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

class PhotoAiPage extends StatefulWidget {
  const PhotoAiPage({super.key});

  @override
  State<PhotoAiPage> createState() => _PhotoAiPageState();
}

class _PhotoAiPageState extends State<PhotoAiPage> {
  static final _logger = Logger('PhotoAiPage');

  processPhoto(file) async {
    final nav = Navigator.of(context);
    final content = await file.readAsBytes();

    final header = content
        .sublist(0, 4)
        .map((x) => x.toRadixString(16).padLeft(2, '0'))
        .join(' ');
    if (header.substring(0, 10) != 'ff d8 ff e') {
      _logger.warning('Camera returned not a JPEG. First bytes: $header');
      if (mounted) {
        await showOkAlertDialog(
          context: context,
          title: 'Camera error',
          message: 'Camera returned not a JPEG. First bytes: $header',
        );
        nav.pop();
      }
    }

    final uri = Uri.https('image-to-osm.vercel.app', '/upload');
    final body = {'image': 'data:image/jpeg;base64,${base64Encode(content)}'};
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      _logger.warning(
          'Failed to query image-to-osm: ${response.statusCode} ${response.body}');
      if (mounted) {
        await showOkAlertDialog(
          context: context,
          title: 'Server error',
          message: 'Failed to query image-to-osm: ${response.statusCode}',
        );
        nav.pop();
      }
    } else {
      try {
        final data = json.decode(response.body);
        _logger.info('Server returned: $data');
        if (data['status'] == 'ok') {
          final tags = data['tags'] as Map<String, dynamic>;
          nav.pop(tags.map((k, v) => MapEntry(k, v.toString())));
        } else if (data['status'] == 'not_found') {
          _logger.warning('Nothing good found');
          if (mounted) {
            await showOkAlertDialog(
                context: context,
                title: 'Nothing found',
                message: 'Nothing tag-worthy found in the image.');
          }
        } else if (data['error'] != null) {
          _logger.warning('Error: ${data["error"]}');
          if (mounted) {
            await showOkAlertDialog(
                context: context, title: 'Error', message: '${data["error"]}');
          }
        }
      } on FormatException {
        _logger
            .warning('Malformed response from image-to-osm: ${response.body}');
        if (mounted) {
          await showOkAlertDialog(
              context: context,
              title: 'Server error',
              message: 'Malformed response from image-to-osm.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraCamera(
        enableAudio: false,
        resolutionPreset: ResolutionPreset.veryHigh,
        onFile: (file) {
          processPhoto(file);
        },
      ),
    );
  }
}
