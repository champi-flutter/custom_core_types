

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache_handler.dart';

class SimpleCacheEvent<K, V> implements CacheEvent<K, V, CacheEntry<V>> {
  @override
  CacheEntry<V> createEntry(V value) => CacheEntry<V>(value);

  @override
  void onAccess(K _, CacheEntry<V> __) {}
}

class SimpleCache<K, V> extends BaseCache<K, V, CacheEntry<V>> {
  SimpleCache() : super(SimpleCacheEvent<K, V>());
}

abstract class SimpleCacheHandler<K, V>
    extends BaseCacheHandler<K, V, SimpleCache<K, V>> {
  SimpleCacheHandler() : super(SimpleCache<K, V>());
}