import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';

/// LFUキャッシュのエントリ
class LfuCacheEntry<V> extends BaseCacheEntry<V> {
  int _frequency;

  int get frequency => _frequency;

  /// アクセス時に [_frequency] を 1 増やす。
  @override
  bool onAccess() {
    _frequency++;
    return true;
  }

  LfuCacheEntry(super.value): _frequency = 1;
}