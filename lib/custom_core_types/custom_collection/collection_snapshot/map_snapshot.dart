
/// Map をその時の状態のまま不変の Map として定義するクラス
class MapSnapshot<K, V> {
  MapSnapshot(Map<K, V> data) : _data = Map<K, V>.unmodifiable(data);

  final Map<K, V> _data;

  Iterable<K> get keys => _data.keys;

  Iterable<V> get values => _data.values;

  Iterable<MapEntry<K, V>> get entries => _data.entries;

  int get length => _data.length;

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  bool containsKey(Object? key) => _data.containsKey(key);

  bool containsValue(Object? value) => _data.containsValue(value);

  V? operator [](Object? key) => _data[key];

  Map<K, V> toMutable() =>
      _data.map((K key, V value) => MapEntry<K, V>(key, value));
}

