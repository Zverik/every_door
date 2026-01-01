// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:every_door/helpers/amenity_age.dart';
import 'package:flutter/material.dart';

class PoiTile extends StatelessWidget {
  final int? index;
  final TextSpan description;
  final double? width;
  final VoidCallback? onToggleCheck;
  final AmenityAgeData? amenityData;
  final Function() onTap;

  PoiTile({
    this.index,
    required this.description,
    required this.onTap,
    this.width,
    this.onToggleCheck,
    this.amenityData,
  });

  @override
  Widget build(BuildContext context) {
    final showWarning = amenityData?.showWarning ?? false;
    final prefix = (index == null ? '' : index.toString() + '. ') +
        (showWarning ? '⚠' : '');

    return Container(
      decoration: BoxDecoration(
        color: (amenityData?.isDisused ?? false)
            ? Colors.grey.shade200
            : Colors.white,
        border: showWarning
            ? Border.all(color: Colors.yellowAccent, width: 3.0)
            : null,
      ),
      width: width,
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onToggleCheck != null &&
                amenityData != null &&
                amenityData?.isOld != null)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: amenityData!.wasOld ? onToggleCheck : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        (amenityData!.isOld ?? false)
                            ? Icons.check
                            : Icons.check_circle,
                        color: (amenityData!.isOld ?? false)
                            ? Colors.black
                            : Colors.green,
                        size: 30.0,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: onTap,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: prefix),
                      description,
                    ]),
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
