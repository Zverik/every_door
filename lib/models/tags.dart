import 'dart:collection';

class Tags<T> extends MapBase<String, T> {
  Map<String, T> tags;

  Tags([Map<String, T>? baseTags]) : tags = baseTags == null ? {} : Map.of(baseTags);

  @override
  T? operator [](Object? key) => tags[key];

  @override
  void operator []=(String key, T value) {
    tags[key] = value;
  }

  @override
  void clear() {
    tags.clear();
  }

  @override
  Iterable<String> get keys => tags.keys;

  @override
  T? remove(Object? key) => tags.remove(key);
}