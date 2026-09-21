
import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/expirable_cache/ttl/expiration_timer.dart';

/// TTL キャッシュのエントリ
class TtlCacheEntry<V> extends BaseCacheEntry<V> {
  TtlCacheEntry(super.value);

  @override
  bool onAccess() => true;

  ExpirationTimer? expirationTimer;
}
