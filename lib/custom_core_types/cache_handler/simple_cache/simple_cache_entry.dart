import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';

class SimpleCacheEntry<V> extends BaseCacheEntry<V>{
  SimpleCacheEntry(super.value);

  @override
  bool onAccess() =>true;
}