import 'dart:async';

import 'package:every_door/constants.dart';
import 'package:every_door/helpers/tags/element_kind.dart';
import 'package:every_door/helpers/geometry/equirectangular.dart';
import 'package:every_door/helpers/tags/poi_warnings.dart';
import 'package:every_door/models/amenity.dart';
import 'package:every_door/providers/editor_mode.dart';
import 'package:every_door/providers/osm_data.dart';
import 'package:every_door/screens/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DuplicateWarning extends ConsumerStatefulWidget {
  final OsmChange amenity;

  const DuplicateWarning({required this.amenity, super.key});

  @override
  ConsumerState<DuplicateWarning> createState() => _DuplicateWarningState();
}

class _DuplicateWarningState extends ConsumerState<DuplicateWarning> {
  static final _logger = Logger('DuplicateWarning');
  OsmChange? possibleDuplicate;
  Timer? duplicateTimer;
  String? warning;

  @override
  initState() {
    super.initState();
    widget.amenity.addListener(onAmenityChange);
    Future.delayed(Duration.zero, () {
      onAmenityChange();
    });
  }

  @override
  dispose() {
    widget.amenity.removeListener(onAmenityChange);
    super.dispose();
  }

  startDuplicateSearch() {
    final isAmenity = ElementKind.amenity.matchesChange(widget.amenity);
    if (!widget.amenity.isNew || !isAmenity) return;
    possibleDuplicate = null;
    if (duplicateTimer != null) {
      duplicateTimer?.cancel();
      duplicateTimer = null;
    }
    duplicateTimer = Timer(Duration(seconds: 2), () async {
      if (!mounted) return;
      final duplicate =
          await ref.read(osmDataProvider).findPossibleDuplicate(widget.amenity);
      _logger.info('Found duplicate: $duplicate');
      if (mounted) {
        setState(() {
          possibleDuplicate = duplicate;
        });
      }
    });
  }

  bool isWrongMode() {
    final isAmenity = ElementKind.amenity.matchesChange(widget.amenity);
    // This is a hack, and it might fail in some cases of redefined modes.
    final mode = ref.read(editorModeProvider);
    return (isAmenity && mode.name == "micro") ||
        (!isAmenity && mode.name == "amenity");
  }

  onAmenityChange() {
    startDuplicateSearch();
    final loc = AppLocalizations.of(context)!;
    String? newWarning = getWarningForAmenity(widget.amenity, loc);
    if (newWarning == null && isWrongMode()) newWarning = loc.warningWrongMode;

    if (mounted) {
      setState(() {
        warning = newWarning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const distance = DistanceEquirectangular();
    final int duplicateDistance = possibleDuplicate == null
        ? 0
        : distance(possibleDuplicate!.location, widget.amenity.location)
            .round();
    final loc = AppLocalizations.of(context)!;
    if (possibleDuplicate == null && warning == null) return Container();

    return GestureDetector(
      child: Container(
        color: Colors.yellow,
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 5.0),
            Flexible(
              child: Text(
                warning ?? loc.editorDuplicate(duplicateDistance),
                style: kFieldTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      onTap: possibleDuplicate == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PoiEditorPage(amenity: possibleDuplicate),
                  fullscreenDialog: true,
                ),
              );
            },
    );
  }
}
