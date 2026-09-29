import 'dart:collection';

import 'package:flutter/foundation.dart';

/// 新しい key にアクセスした際に、取得処理（[onNewAccess]）を走らせる Map
class LazyMap<K, V> extends MapBase<K, V> {
  LazyMap({
    Map<K, V>? initialData,
    required this.onAnyAccess,
    required this.onNewAccess,
    required this.placeholder,
  }) : _source = Map<K, V>.of(initialData ?? {});

  /// 本体
  final Map<K, V> _source;

  /// 本体の参照
  ///
  /// 継承した場合に、継承先の中でのみ参照可能
  @protected
  @nonVirtual
  Map<K, V> get source => _source;

  /// まだ値の入っていない key にアクセスされたときのコールバック
  @protected
  final void Function(K key) onNewAccess;

  /// 各 key にアクセスされたときの毎回のコールバック
  @protected
  final void Function(K key)? onAnyAccess;

  /// [onAccessWithNew] が呼ばれている間に入れる仮データ
  @protected
  final V Function(K key) placeholder;

  /// 現在、値が保持されている key の集合を取得する
  Set<K> get activeKeys => _source.keys.toSet();

  @override
  V operator [](Object? key) {
    if (key is K) {
      if(onAnyAccess != null) {
        onAnyAccess!(key);
      }
      final V? value = _source[key];
      // まだ登録されていない key にアクセスされた場合
      if (value == null) {
        onNewAccess(key);
        return placeholder(key);
      }
      // すでに値がある場合はそれを返す
      else {
        return value;
      }
    } else {
      throw Exception("key が不適当です");
    }
  }

  @override
  void operator []=(K key, V value) {
    _source[key] = value;
  }

  @override
  void clear() => _source.clear();

  @override
  Iterable<K> get keys => _source.keys;

  @override
  V? remove(Object? key) => _source.remove(key);

  /// 自身の一部を更新して、複製した [LazyMap] の新しい枠を返すメソッド
  LazyMap<K, V> copyWith(K key, V value) {
    final newMap = Map<K, V>.of(_source)..[key] = value;
    return LazyMap(
      initialData: newMap,
      onAnyAccess: onAnyAccess,
      onNewAccess: onNewAccess,
      placeholder: placeholder,
    );
  }

  /// 自身を更新して、複製した [LazyMap] の新しい枠を返すメソッド
  LazyMap<K, V> copyAs(Map<K, V> newMap) => LazyMap(
    initialData: newMap,
    onAnyAccess: onAnyAccess,
    onNewAccess: onNewAccess,
    placeholder: placeholder,
  );
}
