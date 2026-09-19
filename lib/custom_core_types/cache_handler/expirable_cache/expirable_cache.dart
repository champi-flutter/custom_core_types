import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// 有効期限付きキャッシュの規定クラス
abstract class ExpirableCache<K, V, E extends BaseCacheEntry<V>>
    extends BaseCache<K, V, E> {
  // @override
  // @protected
  // @nonVirtual
  // void onAddEntry(K key) {}

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

    removeAt(keyToEvict);
  }
}
