
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache/lfu/lfu_cache.dart';


/// LFU のキャッシュハンドラ
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class LfuCacheHandler<K, V>
    extends BaseCacheHandler<K, V, LfuCache<K, V>> {

  LfuCacheHandler({required int capacity})
      : super(LfuCache<K, V>(capacity: capacity));
}