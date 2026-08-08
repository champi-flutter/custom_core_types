

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache_handler.dart';
import 'package:flutter/foundation.dart';

/// ベースとなるキャッシュクラス
abstract class EvictingCache<K, V, E extends CacheEntry<V>> extends BaseCache<K, V, E>{
  /// キャッシュの最大容量
  final int capacity;

  final CacheEviction<K, V, E> _event;

  EvictingCache({required this.capacity,
    required CacheEviction<K, V, E> event,
  })
      : _event = event,
        super(event);

  @override
  @protected
  @nonVirtual
  void onAdd() {
    // 最大容量を超過時に削除を実行
    if (length >= capacity) {
      evict();
    }
  }

  /// キャッシュ溢れ発生時の削除処理
  @protected
  @nonVirtual
  void evict() {
    assert(
    isNotEmpty,
    "_storage.isEmpty: $runtimeType.evict",
    );

    // 継承先指定のロジックで、削除する項目を決定する
    final K keyToEvict = _event.specifyToEvict();

    assert(
    containsKey(keyToEvict),
    "存在しない key が指定されました。\n$runtimeType.evict",
    );

    removeAt(keyToEvict);
  }
}

abstract interface class CacheEviction<K, V, E extends CacheEntry<V>> implements CacheEvent<K, V, E>{

  /// 最大容量超過時にどの entry を削除するかを決めるロジック
  ///
  /// 対応する key を返す。
  K specifyToEvict();
}