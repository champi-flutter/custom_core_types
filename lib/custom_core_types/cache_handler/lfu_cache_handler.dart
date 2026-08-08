
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache.dart';

/// LFUキャッシュのエントリ
class LfuCacheEntry<V> extends CacheEntry<V> {
  int _frequency;

  int get frequency => _frequency;

  void onAccess()=>_frequency++;

  LfuCacheEntry(super.value): _frequency = 1;
}


/// LFU のルールを実装するクラス
///
/// このクラスのコンストラクタは、[CacheEviction] のインスタンスを作り、LFU のロジックを
/// 提供する。
class CacheEventImplLfu<K, V> implements CacheEviction<K, V, LfuCacheEntry<V>>{
  @override
  LfuCacheEntry<V> createEntry(V value) => LfuCacheEntry(value);

  // アクセスされるたびに参照頻度を加算
  @override
  void onAccess(K key, LfuCacheEntry<V> entry) => entry.onAccess();

  @override
  K specifyToEvict() {
    // TODO: implement specifyToEvict
    throw UnimplementedError();
  }

}

/// 使用頻度の低いキャッシュから削除していくキャッシュ
///  - [capacity]: キャッシュの最大容量
class LfuCache<K, V> extends EvictingCache<K, V, LfuCacheEntry<V>>{
  LfuCache({required super.capacity})
      : super(event: CacheEventImplLfu<K, V>());
}

/// LFU のキャッシュハンドラ
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class LfuCacheHandler<K, V>
    extends BaseCacheHandler<K, V, LfuCache<K, V>> {

  LfuCacheHandler({required int capacity})
      : super(LfuCache<K, V>(capacity: capacity));
}