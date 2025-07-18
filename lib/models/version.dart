class PluginVersion {
  late final int? _major;
  late final int _minor;

  static final zero = PluginVersion('0');

  /// Constructs a version instance. Possible types for the [version] are:
  ///
  /// * [int] - depending on [flatNumbering], parsed as "version" or "version.0"
  /// * [double] or [String] - if there's a point, parsed as "major.minor",
  ///   otherwise depends on [flatNumbering] (see [int]).
  /// * [null] - flat version 0.
  PluginVersion(dynamic version, [bool flatNumbering = true]) {
    if (version == null) {
      // Null version is considered "0", equal to [zero].
      _major = null;
      _minor = 0;
    } else if (version is int) {
      _major = flatNumbering ? null : version;
      _minor = flatNumbering ? version : 0;
    } else if (version is String || version is double) {
      final vs = version.toString();
      final p = vs.indexOf('.');
      if (p < 0) {
        final v = int.parse(vs);
        _major = flatNumbering ? null : v;
        _minor = flatNumbering ? v : 0;
      } else {
        _major = int.parse(vs.substring(0, p));
        _minor = int.parse(vs.substring(p + 1));
      }
    } else {
      throw ArgumentError('Plugin version should be a number or a string');
    }
  }

  PluginVersion.exact(this._major, this._minor);

  @override
  String toString() => _major == null ? _minor.toString() : '$_major.$_minor';

  @override
  bool operator ==(Object other) =>
      other is PluginVersion &&
      other._major == _major &&
      other._minor == _minor;

  bool operator <(PluginVersion other) {
    if (_major == null) return other._major != null || other._minor > _minor;
    if (other._major == null || other._major < _major) return false;
    return other._major > _major || other._minor > _minor;
  }

  bool operator >(PluginVersion other) {
    if (_major != null)
      return other._major == null ||
          other._major < _major ||
          (other._major == _major && other._minor < _minor);
    return other._major == null && other._minor < _minor;
  }

  bool operator <=(PluginVersion other) => other == this || this < other;

  bool fresherThan(PluginVersion? version) => version == null || this > version;

  PluginVersion nextMajor() => PluginVersion.exact((_major ?? 0) + 1, 0);

  @override
  int get hashCode => Object.hash(_major, _minor);
}

class PluginVersionRange {
  late final PluginVersion min;
  late final PluginVersion max;

  PluginVersionRange(dynamic data) {
    if (data is String || data is num) {
      min = PluginVersion(data, false);
      max = min.nextMajor();
    } else if (data is Iterable && data.length == 2) {
      final List versions = data.toList();
      min = PluginVersion(versions[0], false);
      max = PluginVersion(versions[1], false);
    }
  }

  bool matches(PluginVersion version) => min <= version && version < max;

  @override
  String toString() => '[$min, $max)';
}
