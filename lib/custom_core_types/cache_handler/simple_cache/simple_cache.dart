

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/simple_cache/simple_cache_entry.dart';

class SimpleCache<K, V> extends BaseCache<K, V, SimpleCacheEntry<V>> {
  @override
  SimpleCacheEntry<V> createEntry(V value) => SimpleCacheEntry(value);

  @override
  void onAddEntry(_) {}
}