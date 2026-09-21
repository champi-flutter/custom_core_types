import 'dart:async';

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/expirable_cache/ttl/expiration_timer.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/expirable_cache/ttl/ttl_cache_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// 有効期限付きキャッシュ
///
/// キャッシュに追加されたタイミングから有効期限がスタートする。
class TtlCache<K, V> extends BaseCache<K, V, TtlCacheEntry<V>> {
  TtlCache({required this.timeToLive});

  /// キャッシュの有効期限（秒）
  final int timeToLive;

  @override
  @protected
  @nonVirtual
  void onAddEntry(K key) {
    // キャッシュに追加されたタイミングから有効期限がスタートする
    storage[key]?.expirationTimer = ExpirationTimer(
      timeToLive,
      () => removeAt(key),
    );
  }

  /// キャッシュエントリを提供するファクトリメソッド
  @override
  @mustBeOverridden
  TtlCacheEntry<V> createEntry(V value) => TtlCacheEntry<V>(value);
}
