import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// キャッシュの更新および出力を扱うハンドラの抽象基底クラス
///
/// 継承先に対応するキャッシュクラス（[BaseCache] を継承）のコンストラクタを
/// イニシャライザで呼び出す。
/// ```
/// abstract class SuperCacheHandler<K, V>
///   extends BaseCacheHandler<K, V, SuperCache<K, V>> {
///   SuperCacheHandler()
///     : super(SuperCache<K, V>());
/// }
/// ```
///
abstract class BaseCacheHandler<
  K,
  V,
  C extends BaseCache<K, V, BaseCacheEntry<V>>
> {
  /// 内部で利用するキャッシュデータ構造
  ///
  /// 継承先に対応するキャッシュクラス（[BaseCache] を継承）のコンストラクタを
  /// イニシャライザで呼び出す。
  ///
  /// ```
  /// abstract class SuperCacheHandler<K, V>
  ///   extends BaseCacheHandler<K, V, SuperCache<K, V>> {
  ///   SuperCacheHandler()
  ///     : super(SuperCache<K, V>());
  /// }
  /// ```
  final C _cache;

  BaseCacheHandler(this._cache);

  /// キャッシュを更新し、出力処理を呼び出す統一フロー（オーバーライド不可）
  @nonVirtual
  void update(Map<K, V> dataMap) {
    for (final entry in dataMap.entries) {
      _cache[entry.key] = entry.value;
    }
    output(_cache.base);
  }

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  @visibleForOverriding
  void output(Map<K, V> dataMap);
}
