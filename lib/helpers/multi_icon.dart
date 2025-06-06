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
  late ScalableImage? svg;
  final String? tooltip;

  MultiIcon({
    this.fontIcon,
    Uint8List? imageData,
    Uint8List? svgData,
    Uint8List? siData,
    String? imageUrl,
    String? asset,
    this.tooltip,
  }) {
    if (imageData != null) {
      image = MemoryImage(imageData);
    } else if (asset != null) {
      image = AssetImage(asset);
    } else if (imageUrl != null && !imageUrl.contains('.svg')) {
      image = NetworkImage(imageUrl);
    } else {
      image = null;
    }

    if (svgData != null) {
      svg = ScalableImage.fromSvgString(String.fromCharCodes(svgData));
    } else if (siData != null) {
      svg = ScalableImage.fromSIBytes(siData);
    } else if (imageUrl != null && imageUrl.contains('.svg')) {
      svg = null;
      _loadNetworkSvg(Uri.parse(imageUrl));
    } else {
      svg = null;
    }
  }

  MultiIcon._({this.fontIcon, this.image, this.svg, this.tooltip});

  MultiIcon withTooltip(String? tooltip) {
    return MultiIcon._(
        fontIcon: fontIcon, image: image, svg: svg, tooltip: tooltip);
  }

  void _loadNetworkSvg(Uri url) async {
    final loaded = await ScalableImage.fromSvgHttpUrl(url);
    await loaded.prepareImages();
    svg = loaded;
  }

  Widget getWidget({
    double? size,
    Color? color,
    String? semanticLabel,
    bool icon = true,
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
      return icon
          ? ImageIcon(
              image!,
              color: color,
              size: size,
              semanticLabel: semanticLabel,
            )
          : Image(
              image: image!,
              semanticLabel: semanticLabel,
              width: size,
              height: size,
            );
    }
    if (svg != null) {
      // TODO: document what the current color is.
      final modified = color == null ? svg! : svg!.modifyCurrentColor(color);
      return SizedBox(
          width: size, height: size, child: ScalableImageWidget(si: modified));
    }
    return SizedBox(width: size, height: size);
  }
}
