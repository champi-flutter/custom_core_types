
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache/evicting_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache/lfu/lfu_cache_entry.dart';

/// 使用頻度の低いキャッシュから削除していくキャッシュ
///  - [capacity]: キャッシュの最大容量
class LfuCache<K, V> extends EvictingCache<K, V, LfuCacheEntry<V>>{
  LfuCache({required super.capacity});

  /// 削除対象決定ロジック
  ///
  ///  - 最大容量超過時にどの entry を削除するかを決める。
  ///  - 対応する key を返す。
  @override
  K specifyToEvict() {
    late K result;
    int currentMinFreq = double.maxFinite.toInt(); // ♾️
    for(final storageEntry in storage.entries){
      final int freq = storageEntry.value.frequency;
      // currentMinFreq == 無限 なので必ず一回は回る
      if(freq < currentMinFreq){
        currentMinFreq = freq;
        result = storageEntry.key;
      }
    }
    return result;
  }

  /// [LfuCacheEntry] を提供するファクトリメソッド
  @override
  LfuCacheEntry<V> createEntry(V value) => LfuCacheEntry(value);
}