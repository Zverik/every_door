class Counter<T> {
  final _data = <T, int>{};

  Counter([Iterable<T>? initial]) {
    if (initial != null) addAll(initial);
  }

  void add(T item, [int? count]) {
    _data[item] = (_data[item] ?? 0) + (count ?? 1);
  }

  void addAll(Iterable<T> items, [int? count]) {
    for (final item in items) add(item, count);
  }

  int? remove(T item) {
    return _data.remove(item);
  }

  int get length => _data.length;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  int operator [](T item) => _data[item] ?? 0;

  void operator []=(T item, int value) {
    _data[item] = value;
  }

  Iterable<CounterEntry<T>> mostOccurent([int? count]) {
    final entries = _data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    final result = entries.map((e) => CounterEntry(e.key, e.value));
    return count == null ? result : result.take(count);
  }

  Iterable<T> mostOccurentItems({int? count, int? cutoff}) {
    return mostOccurent(count)
        .where((e) => cutoff == null || e.count >= cutoff)
        .map((e) => e.item);
  }

  @override
  String toString() {
    final data = _data.entries.map((e) => '${e.key}:${e.value}').join(';');
    return 'Counter($data)';
  }
}

class CounterEntry<T> {
  final T item;
  final int count;

  const CounterEntry(this.item, this.count);

  @override
  String toString() => 'CounterEntry($item, $count)';
}
