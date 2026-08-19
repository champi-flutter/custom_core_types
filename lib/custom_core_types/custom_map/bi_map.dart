import 'dart:collection';

class BiMap<K, V> extends MapBase<K, V> {
  final Map<K, V> _forward = {};
  final Map<V, K> _backward = {};

  /// key の全集合
  @override
  Iterable<K> get keys => _forward.keys;

  // key から value を取得
  @override
  V? operator [](Object? key) => _forward[key];

  // 要素の追加・更新（Valueの一意性を保証する）
  @override
  void operator []=(K key, V value) {
    // すでに同じKey-Valueの組み合わせが存在する場合は何もしない
    if (_forward[key] == value) return;

    // 追加しようとするValueが別のKeyで既に使われている場合はエラー（または上書き）
    if (_backward.containsKey(value)) {
      throw ArgumentError('Value "$value" は既に別のキーで存在しています。一意である必要があります。');
    }

    // 古い key のペアを削除して同期を保つ
    if (_forward.containsKey(key)) {
      final oldValue = _forward[key];
      _backward.remove(oldValue);
    }

    _forward[key] = value;
    _backward[value] = key;
  }

  /// 要素の削除
  @override
  V? remove(Object? key) {
    if (!_forward.containsKey(key)) return null;
    final value = _forward.remove(key);
    _backward.remove(value);
    return value;
  }

  /// すべてクリア
  @override
  void clear() {
    _forward.clear();
    _backward.clear();
  }

  /// value から key を O(1) で逆引きする
  K? getKey(V value) => _backward[value];
}
