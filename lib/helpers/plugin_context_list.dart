/// This is a list of elements that also keeps track of plugins that
/// added those. It is immutable, all methods return new instances.
class PluginContextList<T> with Iterable<T> {
  final List<MapEntry<String?, T>> _elements;

  const PluginContextList(this._elements);

  PluginContextList.from(String? pluginId, Iterable<T>? initial)
      : _elements = initial?.map((e) => MapEntry(pluginId, e)).toList() ?? [];

  PluginContextList<T> clear() => PluginContextList([]);

  PluginContextList<T> add(String? pluginId, T button) =>
      PluginContextList(_elements + [MapEntry(pluginId, button)]);

  PluginContextList<T> removeFor(String pluginId) =>
      PluginContextList(_elements.where((e) => e.key != pluginId).toList());

  @override
  Iterator<T> get iterator => _elements.map((e) => e.value).iterator;

  Iterable<T> get reversed => _elements.reversed.map((e) => e.value);
}
