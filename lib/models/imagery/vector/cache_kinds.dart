// This is for sorting cached files into kinds. The position in this
// list is more important than the access date. First is the most important,
// last is the least. Unknown types have the most priority.
// See [CachedFileKind] for enum names for each of the items.
final _fileKinds = <RegExp>[
  RegExp(r'^\d+_\d+_\d+_.+\.pbf$'), // downloaded vector tiles
  RegExp(r'.*-dem-\d.+\.png$'), // downloaded dem tiles
  RegExp(r'^\d+_\d+_\d+_.+\.(png|jpg|jpeg|webp)$'), // downloaded raster tiles
  RegExp(r'^icon-atlas-'), // sprites
  RegExp(r'^[a-zA-Z0-9.-]+-v[a-zA-Z0-9.-]+-\d+-\d+-\d+\.png'), // rendered raster
];

enum CachedFileKind implements Comparable<CachedFileKind> {
  unknown(-1),
  vector(0),
  dem(1),
  raster(2),
  sprite(3),
  rendered(4);

  final int _kind;

  const CachedFileKind(this._kind);

  factory CachedFileKind.match(String path) {
    final idx = _fileKinds.indexWhere((r) => r.hasMatch(path));
    return values.firstWhere((v) => v._kind == idx, orElse: () => unknown);
  }

  @override
  int compareTo(CachedFileKind other) => _kind.compareTo(other._kind);

  @override
  String toString() => _kind.toString();
}
