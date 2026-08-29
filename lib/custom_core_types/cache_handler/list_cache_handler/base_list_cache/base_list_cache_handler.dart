import 'dart:js_interop';

import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// キャッシュの更新および出力を扱うハンドラの抽象基底クラス
///
/// 継承先に対応するキャッシュクラス（[BaseListCache] を継承）のコンストラクタを
/// イニシャライザで呼び出す。
/// ```
/// abstract class SuperListCacheHandler<K, V>
///   extends BaseListCacheHandler<K, V, SuperListCache<K, V>> {
///   SuperListCacheHandler()
///     : super(SuperListCache<K, V>());
/// }
/// ```
///
// abstract class BaseListCacheHandler<
//   K,
//   I,
//   V,
//   C extends BaseListCache<K, I, V, BaseCacheEntry<V>>
// > {
//   /// 内部で利用するキャッシュデータ構造
//   ///
//   /// 継承先に対応するキャッシュクラス（[BaseListCache] を継承）のコンストラクタを
//   /// イニシャライザで呼び出す。
//   ///
//   /// ```
//   /// abstract class SuperListCacheHandler<K, V>
//   ///   extends BaseListCacheHandler<K, V, SuperListCache<K, V>> {
//   ///   SuperListCacheHandler()
//   ///     : super(SuperListCache<K, V>());
//   /// }
//   /// ```
//   final C _cache;
//
//   /// [_cache] へのアクセス
//   ///
//   /// このクラスと継承先のみアクセス可能。
//   @protected
//   C get cache => _cache;
//
//   BaseListCacheHandler(this._cache);
//
//   /// 対象リストを枠ごと更新し、出力するプロセス
//   ///
//   /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
//   @nonVirtual
//   Future<void> replace({required K key, required List<El> value}) async {
//     _cache.setList(key, value);
//     await output(_cache.base);
//   }
//
//   /// 対象リストの指定 index の値（[value]）を更新し、出力するプロセス
//   ///
//   /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
//   @nonVirtual
//   Future<void> updateElement({
//     required K key,
//     required Map<int, V> indexValueMap,
//   })
//   // 折りたたみ用
//   async {
//     await _cache.updateElement(key: key, indexValueMap: indexValueMap);
//     await output(_cache.base);
//   }
//
//   /// 対象リストに値を追加し、出力するプロセス
//   ///
//   /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
//   @nonVirtual
//   Future<void> addEl({required K key, required El value}) async {
//     final List<El>? currentCache = _cache[key];
//     if (currentCache != null) {
//       _cache.setList(key, [...currentCache, value]);
//     } else {
//       _cache.setList(key, [value]);
//     }
//     await output(_cache.base);
//   }
//
//   /// Map で指定してキャッシュを更新し、出力するプロセス
//   ///
//   /// key（[dataMap.keys]）に対応する値を [dataMap.values] に更新する。
//   ///
//   /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
//   Future<void> replaceByMap(Map<K, List<El>> dataMap) async {
//     for (final entry in dataMap.entries) {
//       _cache.setList(entry.key, entry.value);
//     }
//     await output(_cache.base);
//   }
//
//   /// 更新後の状態を出力する抽象メソッド（継承先で実装）
//   @protected
//   @visibleForOverriding
//   Future<void> output(Map<K, List<V>> dataMap);
// }

abstract class BaseListCacheHandler<
  K,
  I,
  V,
  Ent extends BaseCacheEntry<V>,
  C extends BaseCache<I, V, Ent>,
  M extends BaseListCache<K, I, V, Ent, C>
> {
  BaseListCacheHandler(this._cacheMap);

  final M _cacheMap;

  /// [_cache] へのアクセス
  ///
  /// このクラスと継承先のみアクセス可能。
  @protected
  M get cacheMap => _cacheMap;

  /// 指定 [key] のリストの指定 [index] に [value] を代入する
  ///
  /// ```
  /// _handler.update(
  ///   key: key,// 所属
  ///   valueMap: { // 場所とデータ（識別子と値の組み合わせ）の Map
  ///     0: (id: "識別子0", value: "値0"),
  ///     1: (id: "識別子1", value: "値1"),
  ///     2: (id: "識別子2", value: "値2"),
  ///   }
  /// );
  /// ```
  ///
  Future<void> update({
    required K key,
    required Map<int, DataEntry<I, V>> valueMap,
    List<I>? order,
  })
  // 折りたたみ用
  async {
    // 指定された入力値の組み合わせだけ繰り返す
    await _cacheMap.update(key: key, valueMap: valueMap, order: order);

    await output(_cacheMap.base);
  }

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  @visibleForOverriding
  Future<void> output(Map<K, List<V>> dataMap);
}

typedef DataEntry<I, V> = ({I id, V value});
