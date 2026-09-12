import 'dart:collection';

/// 新しい key にアクセスした際に、取得処理を走らせる Map
class AccessibleMap<K, V> extends MapBase<K, V> {
  AccessibleMap({
    Map<K, V>? initialData,
    required this.onAccessWithNew,
    required this.placeholder,
  }) : _map = Map<K, V>.from(initialData ?? {});

  final Map<K, V> _map;

  final void Function(K key) onAccessWithNew;

  final V placeholder;

  @override
  V operator [](Object? key) {
    if (key is K) {
      final V? value = _map[key];
      if (value == null) {
        onAccessWithNew(key);
        return placeholder;
      } else {
        return value;
      }
    } else {
      throw Exception("key が不適当です");
    }
  }

  @override
  void operator []=(K key, V value) {
    _map[key] = value;
  }

  @override
  void clear() => _map.clear();

  @override
  Iterable<K> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);

  /// 自身を複製するメソッド
  AccessibleMap<K, V> copyWith(K key, V value) {
    final newMap = Map<K, V>.from(_map)..[key] = value;
    return AccessibleMap(
      initialData: newMap,
      onAccessWithNew: onAccessWithNew,
      placeholder: placeholder,
    );
  }
}
