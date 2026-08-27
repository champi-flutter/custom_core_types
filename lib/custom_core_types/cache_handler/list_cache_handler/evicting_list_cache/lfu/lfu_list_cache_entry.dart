import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache_entry.dart';

/// LFUキャッシュのエントリ
class LfuListCacheEntry<El> extends BaseListCacheEntry<El> {
  int _frequency;

  int get frequency => _frequency;

  /// アクセス時に [_frequency] を 1 増やす。
  @override
  void onAccess()=>_frequency++;

  LfuListCacheEntry(super.value): _frequency = 1;
}