import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// This class encapsulates monochrome icons.
/// It replaces IconData class, allowing for raster
/// and vector images. An image should be rectangular,
/// recommended dimensions are 256×256.
class MultiIcon {
  static final _svgCache = ScalableImageCache(size: 200);

  final IconData? fontIcon;
  final String? emoji;
  late final ImageProvider<Object>? image;
  late final ScalableImage? svg;
  late final ScalableImageSource? svgSource;
  final String? tooltip;

  MultiIcon({
    this.fontIcon,
    this.emoji,
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
      svgSource = null;
    } else if (siData != null) {
      svg = ScalableImage.fromSIBytes(siData);
      svgSource = null;
    } else if (imageUrl != null && imageUrl.contains('.svg')) {
      svg = null;
      svgSource = ScalableImageSource.fromSvgHttpUrl(Uri.parse(imageUrl));
    } else {
      svg = null;
      svgSource = null;
    }

    if ((emoji?.runes.length ?? 0) > 1) {
      throw ArgumentError('MultiIcon allows only one rune for emoji: $emoji');
    }
  }

  MultiIcon._({
    this.fontIcon,
    this.emoji,
    this.image,
    this.svg,
    this.svgSource,
    this.tooltip,
  });

  MultiIcon withTooltip(String? tooltip) {
    return MultiIcon._(
        fontIcon: fontIcon,
        emoji: emoji,
        image: image,
        svg: svg,
        svgSource: svgSource,
        tooltip: tooltip);
  }

  Widget getWidget({
    BuildContext? context,
    double? size,
    Color? color,
    String? semanticLabel,
    bool icon = true,
    bool fixedSize = true,
  }) {
    if (size == null && fixedSize) {
      // In most use cases, having the size to match the image size is not what
      // is expected. So we're initializing the size the same way [Icon] does
      // that.
      if (context != null) {
        final IconThemeData iconTheme = IconTheme.of(context);
        final bool applyTextScaling = iconTheme.applyTextScaling ?? false;
        final double tentativeIconSize = iconTheme.size ?? kDefaultFontSize;
        size = applyTextScaling
            ? MediaQuery.textScalerOf(context).scale(tentativeIconSize)
            : tentativeIconSize;
      } else {
        size = 24.0;
      }
    }

    if (fontIcon != null)
      return Icon(
        fontIcon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    if (image != null) {
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
      final modified =
          color == null || !icon ? svg! : svg!.modifyCurrentColor(color);
      final widget = ScalableImageWidget(si: modified, fit: BoxFit.contain);
      return size == null
          ? widget
          : SizedBox(width: size, height: size, child: widget);
    }
    if (svgSource != null) {
      final widget = ScalableImageWidget.fromSISource(
        si: svgSource!,
        cache: _svgCache,
        currentColor: icon ? color : null,
      );
      return size == null
          ? widget
          : SizedBox(width: size, height: size, child: widget);
    }
    if (emoji != null)
      return Text(
        emoji!,
        overflow: TextOverflow.visible,
        style: TextStyle(
          color: color,
          fontSize: size,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
          inherit: false,
        ),
      );
    return SizedBox(width: size, height: size);
  }

  @override
  String toString() {
    if (fontIcon != null) return 'MultiIcon(fontIcon=$fontIcon)';
    if (image != null) return 'MultiIcon(image=$image)';
    if (svg != null) return 'MultiIcon(svg=$svg)';
    if (svgSource != null) return 'MultiIcon(svgSource=$svgSource)';
    if (emoji != null) return 'MultiIcon(emoji=$emoji)';
    return 'MultiIcon(empty)';
  }
}
