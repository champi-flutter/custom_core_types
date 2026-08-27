import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';

/// 先入先出キャッシュのエントリ
class FifoCacheEntry<V> extends BaseCacheEntry<V> {
  int _sequence;

  int get sequence => _sequence;

  /// アクセス時に行う処理はない。
  @override
  bool onAccess() =>true;

  FifoCacheEntry(super.value, {required int sequence}): _sequence = sequence;
}