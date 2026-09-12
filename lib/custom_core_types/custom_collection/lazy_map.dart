import 'dart:collection';

import 'package:flutter/foundation.dart';

/// 新しい key にアクセスした際に、取得処理を走らせる Map
class LazyMap<K, V> extends MapBase<K, V> {
  LazyMap({
    Map<K, V>? initialData,
    required this.onAccessWithNew,
    required this.placeholder,
  }) : _map = Map<K, V>.from(initialData ?? {});

  final Map<K, V> _map;

  /// まだ値の入っていない key にアクセスされたときのコールバック
  @protected
  final void Function(K key) onAccessWithNew;

  /// [onAccessWithNew] が呼ばれている間に入れる仮データ
  @protected
  final V Function(K key) placeholder;

  /// 現在、値が保持されている key の集合を取得する
  Set<K> get activeKeys => _map.keys.toSet();

  @override
  V operator [](Object? key) {
    if (key is K) {
      final V? value = _map[key];
      if (value == null) {
        onAccessWithNew(key);
        return placeholder(key);
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
  LazyMap<K, V> copyWith(K key, V value) {
    final newMap = Map<K, V>.from(_map)..[key] = value;
    return LazyMap(
      initialData: newMap,
      onAccessWithNew: onAccessWithNew,
      placeholder: placeholder,
    );
  }
}
