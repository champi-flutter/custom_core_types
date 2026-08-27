import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
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
abstract class BaseListCacheHandler<
  K,
  El,
  C extends BaseListCache<K, El, BaseListCacheEntry<El>>
> {
  /// 内部で利用するキャッシュデータ構造
  ///
  /// 継承先に対応するキャッシュクラス（[BaseListCache] を継承）のコンストラクタを
  /// イニシャライザで呼び出す。
  ///
  /// ```
  /// abstract class SuperListCacheHandler<K, V>
  ///   extends BaseListCacheHandler<K, V, SuperListCache<K, V>> {
  ///   SuperListCacheHandler()
  ///     : super(SuperListCache<K, V>());
  /// }
  /// ```
  final C _cache;

  /// [_cache] へのアクセス
  ///
  /// このクラスと継承先のみアクセス可能。
  @protected
  C get cache => _cache;

  BaseListCacheHandler(this._cache);

  /// 対象リストを枠ごと更新し、出力するプロセス
  ///
  /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
  @nonVirtual
  Future<void> replace({required K key, required List<El> value}) async {
    _cache.setList(key, value);
    await output(_cache.base);
  }

  /// 対象リストの指定 index の値（[value]）を更新し、出力するプロセス
  ///
  /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
  @nonVirtual
  Future<void> update({
    required K key,
    required Map<int, El> indexValueMap,
  })
  // 折りたたみ用
  async {
    await _cache.setEl(key: key, indexValueMap: indexValueMap);
    await output(_cache.base);
  }

  /// 対象リストに値を追加し、出力するプロセス
  ///
  /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
  @nonVirtual
  Future<void> addEl({required K key, required El value})async{
    final List<El>? currentCache = _cache[key];
    if(currentCache != null) {
      _cache.setList(key, [...currentCache, value]);
    } else {
      _cache.setList(key, [value]);
    }
    await output(_cache.base);
  }

  /// Map で指定してキャッシュを更新し、出力するプロセス
  ///
  /// key（[dataMap.keys]）に対応する値を [dataMap.values] に更新する。
  ///
  /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
  Future<void> replaceByMap(Map<K, List<El>> dataMap) async {
    for (final entry in dataMap.entries) {
      _cache.setList(entry.key, entry.value);
    }
    await output(_cache.base);
  }

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  @visibleForOverriding
  Future<void> output(Map<K, List<El>> dataMap);
}
