import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// キャッシュのイベントの呼び出し口
abstract interface class BaseCacheEvent<K, V, E extends BaseCacheEntry<V>> {
  // /// キャッシュへのアクセスがあったときの処理
  // void onAccess(K key, E entry);

  /// キャッシュの枠を追加するときのコールバック
  void onAddEntry();

  /// key に対応する独自のキャッシュエントリのインスタンスをつくるファクトリメソッド
  ///
  /// 独自のエントリのコンストラクタを返す。
  E createEntry(V value);
}