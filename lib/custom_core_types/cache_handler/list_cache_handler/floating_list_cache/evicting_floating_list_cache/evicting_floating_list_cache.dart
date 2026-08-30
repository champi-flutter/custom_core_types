import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/floating_list_cache/base_floating_list_cache/base_floating_list_cache.dart';
import 'package:flutter/foundation.dart';

/// 容量超過時の削除機能を搭載するキャッシュの基底クラス
///
/// 対応するイベントハンドラ（[CacheEviction]）を引数にとり、
/// その具象クラスのコンストラクタを当てはめること。
///
/// evict はグループ単位で行う。
abstract class EvictingFloatingListCache<K, I, V, Ent extends BaseCacheEntry<V>, C extends BaseCache<I, V, Ent>>
    extends BaseFloatingListCache<K, I, V, Ent, C> {
  /// キャッシュの最大容量
  final int capacity;

  EvictingFloatingListCache(super._cache, {required this.capacity});

  @override
  @protected
  @nonVirtual
  void onAddEntry(K key) {
    // 最大容量を超過時に削除を実行
    if (length >= capacity) {
      evict();
    }
  }

  /// 削除対象決定ロジック
  ///
  ///  - 最大容量超過時にどの entry を削除するかを決める。
  ///  - 対応する key を返す。
  @protected
  @visibleForOverriding
  K specifyToEvict();

  /// キャッシュ溢れ発生時の削除処理
  @protected
  @nonVirtual
  void evict() {
    assert(isNotEmpty, "_storage.isEmpty: $runtimeType.evict");

    // 継承先指定のロジックで、削除する項目を決定する
    final K keyToEvict = specifyToEvict();

    assert(containsKey(keyToEvict), "存在しない key が指定されました。\n$runtimeType.evict");

    remove(keyToEvict);
  }
}
