
import 'package:custom_core_types/custom_core_types.dart';

/// スライド可能な有効期限付きキャッシュ
///
/// キャッシュに追加されたタイミングから有効期限がスタートする。
///
/// 大括弧でのアクセス時や、[BaseCache.notifyAccess] 起動時に、有効期限をスライドする。
class SlidingTtlCache<K, V> extends TtlCache<K, V>{
  SlidingTtlCache({required super.timeToLive});

  @override
  SlidingTtlCacheEntry<V> createEntry(V value) => SlidingTtlCacheEntry(value);
}