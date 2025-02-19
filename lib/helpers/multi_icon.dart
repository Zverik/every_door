import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// This class encapsulates monochrome icons.
/// It replaces IconData class, allowing for raster
/// and vector images. An image should be rectangular,
/// recommended dimensions are 256×256.
class MultiIcon {
  final IconData? fontIcon;
  late final ImageProvider<Object>? image;
  late final ScalableImage? svg;
  final String? tooltip;

  MultiIcon({
    this.fontIcon,
    Uint8List? imageData,
    Uint8List? svgData,
    String? asset,
    this.tooltip,
  }) {
    if (imageData != null) {
      image = MemoryImage(imageData);
    }
    if (svgData != null) {
      svg = ScalableImage.fromSIBytes(svgData);
    }
    if (asset != null) {
      image = AssetImage(asset);
    }
  }

  Widget getWidget({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    if (fontIcon != null)
      return Icon(
        fontIcon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    if (image != null) {
      // TODO: learn how it recolours and document.
      return ImageIcon(
        image!,
        color: color,
        size: size,
        semanticLabel: semanticLabel,
      );
    }
    if (svg != null) {
      // TODO: document what the current color is.
      final modified = color == null ? svg! : svg!.modifyCurrentColor(color);
      return SizedBox(
          width: size, height: size, child: ScalableImageWidget(si: modified));
    }
    return Container();
  }
}
