
import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/floating_list_cache/floating_evicting_cache/evicting_floating_list_cache.dart';

/// 使用頻度の低いキャッシュから削除していくキャッシュ
///  - [capacity]: キャッシュの最大容量
class LfuFloatingListCache<K, I, V> extends EvictingFloatingListCache<K, I, V, LfuCacheEntry<V>, LfuCache<I, V>>{
  LfuFloatingListCache({required super.capacity}): super(LfuCache(capacity: capacity));

  /// 削除対象決定ロジック
  ///
  /// key に対応するグループごとが対象。
  ///
  ///  - 最大容量超過時にどのグループを削除するかを決める。
  ///  - 対応する key を返す。
  @override
  K specifyToEvict() {
    late K result;
    int currentMinFreq = double.maxFinite.toInt(); // ♾️
    // 全キャッシュを探索
    for(final targetKey in group.keys){
      // targetKey に含まれるキャッシュのリストをエントリ型で参照する
      final List<LfuCacheEntry<V>> targetEntList = getEntries(targetKey);
      // そのリスト全体の frequency を取得する
      final int freq = targetEntList.freqOfList;
      // currentMinFreq の初期値は無限なので必ず一回は回る
      if(freq < currentMinFreq){
        currentMinFreq = freq;
        result = targetKey;
      }
    }
    return result;
  }

  /// [LfuCacheEntry] を提供するファクトリメソッド
  @override
  LfuCacheEntry<V> createEntry(V value) => LfuCacheEntry(value);
}