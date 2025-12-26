// Copyright 2022-2025 Ilya Zverev
// This file is a part of Every Door, distributed under GPL v3 or later version.
// Refer to LICENSE file and https://www.gnu.org/licenses/gpl-3.0.html for details.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eval_annotation/eval_annotation.dart';
import 'package:every_door/helpers/cached_svg_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';

/// This class encapsulates monochrome icons.
/// It replaces IconData class, allowing for raster
/// and vector images. An image should be rectangular,
/// recommended dimensions are 256×256.
@Bind()
class MultiIcon {
  static final _svgCache = ScalableImageCache(size: 1000);

  final IconData? _fontIcon;
  final String? _emoji;
  late final ImageProvider<Object>? _image;
  late final ScalableImage? _svg;
  late final ScalableImageSource? _svgSource;
  final String? tooltip;

  MultiIcon({
    IconData? fontIcon,
    String? emoji,
    Uint8List? imageData,
    Uint8List? svgData,
    Uint8List? siData,
    String? imageUrl,
    String? asset,
    this.tooltip,
  }) : _fontIcon = fontIcon, _emoji = emoji {
    if (imageData != null) {
      _image = MemoryImage(imageData);
    } else if (asset != null && !asset.contains('.svg')) {
      _image = AssetImage(asset);
    } else if (imageUrl != null && !imageUrl.contains('.svg')) {
      _image = CachedNetworkImageProvider(imageUrl);
    } else {
      _image = null;
    }

    if (svgData != null) {
      _svg = ScalableImage.fromSvgString(String.fromCharCodes(svgData));
      _svgSource = null;
    } else if (siData != null) {
      _svg = ScalableImage.fromSIBytes(siData);
      _svgSource = null;
    } else if (asset != null && asset.contains('.si')) {
      _svg = null;
      _svgSource = ScalableImageSource.fromSI(rootBundle, asset);
    } else if (asset != null && asset.contains('.svg')) {
      _svg = null;
      _svgSource = ScalableImageSource.fromSvg(rootBundle, asset);
    } else if (imageUrl != null && imageUrl.contains('.svg')) {
      _svg = null;
      _svgSource = CachedSvgSource(imageUrl);
    } else {
      _svg = null;
      _svgSource = null;
    }

    if ((_emoji?.runes.length ?? 0) > 1) {
      throw ArgumentError('MultiIcon allows only one rune for emoji: $_emoji');
    }
  }

  MultiIcon._({
    IconData? fontIcon,
    String? emoji,
    ImageProvider<Object>? image,
    ScalableImage? svg,
    ScalableImageSource? svgSource,
    this.tooltip,
  }) : _fontIcon = fontIcon, _emoji = emoji, _svgSource = svgSource, _svg = svg, _image = image;

  MultiIcon withTooltip(String? tooltip) {
    return MultiIcon._(
        fontIcon: _fontIcon,
        emoji: _emoji,
        image: _image,
        svg: _svg,
        svgSource: _svgSource,
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

    if (_fontIcon != null)
      return Icon(
        _fontIcon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    if (_image != null) {
      return icon
          ? ImageIcon(
              _image,
              color: color,
              size: size,
              semanticLabel: semanticLabel,
            )
          : Image(
              image: _image,
              semanticLabel: semanticLabel,
              width: size,
              height: size,
            );
    }
    if (_svg != null) {
      final modified =
          color == null || !icon ? _svg : _svg.modifyCurrentColor(color);
      final widget = ScalableImageWidget(si: modified, fit: BoxFit.contain);
      return size == null
          ? widget
          : SizedBox(width: size, height: size, child: widget);
    }
    if (_svgSource != null) {
      final widget = ScalableImageWidget.fromSISource(
        si: _svgSource,
        cache: _svgCache,
        currentColor: icon ? color : null,
      );
      return size == null
          ? widget
          : SizedBox(width: size, height: size, child: widget);
    }
    if (_emoji != null)
      return Text(
        _emoji,
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
    if (_fontIcon != null) return 'MultiIcon(fontIcon=$_fontIcon)';
    if (_image != null) return 'MultiIcon(image=$_image)';
    if (_svg != null) return 'MultiIcon(svg=$_svg)';
    if (_svgSource != null) return 'MultiIcon(svgSource=$_svgSource)';
    if (_emoji != null) return 'MultiIcon(emoji=$_emoji)';
    return 'MultiIcon(empty)';
  }
}
