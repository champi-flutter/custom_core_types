
import 'package:custom_core_types/custom_core_types.dart';

class TtlCacheEntry<V> extends BaseCacheEntry<V>{
  TtlCacheEntry(super.value);

  @override
  bool onAccess() =>true;
}