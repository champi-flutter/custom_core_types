

import 'package:custom_core_types/custom_core_types.dart';

/// スライド式 TTL キャッシュのエントリ
class SlidingTtlCacheEntry<V> extends TtlCacheEntry<V> {
  SlidingTtlCacheEntry(super.value);

  /// アクセスされると、有効期限タイマーが最初からになる
  @override
  bool onAccess() {
    expirationTimer?.slide();
    return true;
  }
}