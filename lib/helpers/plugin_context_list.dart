import 'dart:collection' show MapBase;

/// This is a list of elements that also keeps track of plugins that
/// added those. It is immutable, all methods return new instances.
class PluginContextList<T> with Iterable<T> {
  final List<(String?, T)> _elements;

  const PluginContextList(this._elements);

  PluginContextList.from(String? pluginId, Iterable<T>? initial)
      : _elements = initial?.map((e) => (pluginId, e)).toList() ?? [];

  PluginContextList<T> clear() => PluginContextList([]);

  PluginContextList<T> add(String? pluginId, T button) =>
      PluginContextList(_elements + [(pluginId, button)]);

  PluginContextList<T> removeFor(String pluginId) =>
      PluginContextList(_elements.where((e) => e.$1 != pluginId).toList());

  @override
  Iterator<T> get iterator => _elements.map((e) => e.$2).iterator;

  Iterable<T> get reversed => _elements.reversed.map((e) => e.$2);
}

/// A map that keeps track of which plugin added which key.
/// Unlike [PluginContextList] it is modified in-place.
/// See [PluginContextUMap] for an immutable version.
class PluginContextMap<K, V> with MapBase<K, V> {
  final Map<K, (String?, V)> _elements;

  const PluginContextMap(this._elements);

  PluginContextMap<K, V> set(String? pluginId, K key, V value) {
    _elements[key] = (pluginId, value);
    return this;
  }

  PluginContextMap<K, V> removeFor(String pluginId) {
    _elements.removeWhere((k, v) => v.$1 == pluginId);
    return this;
  }

  @override
  V? operator [](Object? key) {
    return _elements[key]?.$2;
  }

  @override
  Iterable<K> get keys => _elements.keys;

  @override
  Iterable<V> get values => _elements.values.map((e) => e.$2);

  @override
  void operator []=(K key, V value) {
    throw UnsupportedError(
        'Please use the set() method to modify PluginContextMap');
  }

  @override
  void clear() {
    _elements.clear();
  }

  @override
  V? remove(Object? key) => _elements.remove(key)?.$2;
}

/// Immutable map that tracks which plugin has added which key.
class PluginContextUMap<K, V> extends PluginContextMap<K, V> {
  const PluginContextUMap(super._elements);

  PluginContextUMap<K, V> empty() => PluginContextUMap({});

  @override
  PluginContextUMap<K, V> set(String? pluginId, K key, V value) {
    final e = Map.of(_elements);
    e[key] = (pluginId, value);
    return PluginContextUMap(e);
  }

  @override
  PluginContextUMap<K, V> removeFor(String pluginId) {
    final e = Map.of(_elements);
    e.removeWhere((k, v) => v.$1 == pluginId);
    return PluginContextUMap(e);
  }
}