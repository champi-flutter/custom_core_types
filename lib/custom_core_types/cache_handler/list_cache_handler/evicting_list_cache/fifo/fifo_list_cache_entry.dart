
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache_entry.dart';

/// 先入先出キャッシュのエントリ
class FifoListCacheEntry<El> extends BaseListCacheEntry<El> {
  int _sequence;

  int get sequence => _sequence;

  /// アクセス時に行う処理はない。
  @override
  bool onAccess() =>true;

  FifoListCacheEntry(super.value, {required int sequence}): _sequence = sequence;
}