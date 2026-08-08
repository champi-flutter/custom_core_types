

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache_handler.dart';
import 'package:flutter/foundation.dart';

/// ベースとなるキャッシュクラス
abstract class EvictingCache<K, V, E extends CacheEntry<V>> extends BaseCache<K, V, E>{
  /// キャッシュの最大容量
  final int capacity;

  EvictingCache({required this.capacity});

  @override
  @protected
  @nonVirtual
  void onAdd() {
    // 最大容量を超過時に削除を実行
    if (length >= capacity) {
      evict();
    }
  }

  /// キャッシュへのアクセスがあったときの処理
  ///
  /// キャッシュ破棄ファクターを更新する。
  @override
  @protected
  void onAccess(K key, E entry);

  /// 最大容量超過時にどの entry を削除するかを決めるロジック
  ///
  /// 対応する key を返す。
  @protected
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