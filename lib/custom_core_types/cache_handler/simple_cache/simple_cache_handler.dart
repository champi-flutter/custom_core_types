

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/simple_cache/simple_cache.dart';


abstract class SimpleCacheHandler<K, V>
    extends BaseCacheHandler<K, V, SimpleCache<K, V>> {
  SimpleCacheHandler(): super(SimpleCache<K, V>());
}