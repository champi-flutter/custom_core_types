

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:flutter/foundation.dart';

/// 容量超過時の削除機能を搭載するキャッシュの基底クラス
///
/// 対応するイベントハンドラ（[CacheEviction]）を引数にとり、
/// その具象クラスのコンストラクタを当てはめること。
abstract class EvictingCache<K, V, E extends BaseCacheEntry<V>> extends BaseCache<K, V, E>{
  /// キャッシュの最大容量
  final int capacity;

  // /// イベントの呼び出し口
  // ///
  // /// イベントのロジックは、[CacheEviction] を実装したクラスで記述すること。
  // final CacheEviction<K, V, E> _event;

  EvictingCache({required this.capacity,
    // required CacheEviction<K, V, E> event,
  });
      // : _event = event;

  @override
  @protected
  @nonVirtual
  void onAddEntry() {
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
    assert(
    isNotEmpty,
    "_storage.isEmpty: $runtimeType.evict",
    );

    // 継承先指定のロジックで、削除する項目を決定する
    final K keyToEvict = specifyToEvict();

    assert(
    containsKey(keyToEvict),
    "存在しない key が指定されました。\n$runtimeType.evict",
    );

    removeAt(keyToEvict);
  }
}

// /// [CacheEvent] に削除対象決定ロジックを追加したインターフェース
// ///
// /// [CacheEvent] が元々持つ、[onAccess] 、 [createEntry] とこのクラスが持つ
// /// [specifyToEvict] を実装したクラスのコンストラクタでインスタンスを生成する。
// // インターフェースの継承（機能の追加）は、abstract interface + implements ...
// abstract class CacheEviction<K, V, E extends CacheEntry<V>> implements CacheEvent<K, V, E>{
//   //
//   /// 削除対象決定ロジック
//   ///
//   ///  - 最大容量超過時にどの entry を削除するかを決める。
//   ///  - 対応する key を返す。
//   K specifyToEvict(Map<K, E> storageMap);
//
//   // void onAdd()=>
//
//   // void callEviction({required int currentLength, required int capacity});
// }