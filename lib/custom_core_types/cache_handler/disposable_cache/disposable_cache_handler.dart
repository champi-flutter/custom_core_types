

import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/simple_cache/simple_cache.dart';

/// 使用元から破棄処理（[dispose]）を呼び出せるキャッシュハンドラ
abstract class DisposableCacheHandler<K, V>
    extends BaseCacheHandler<K, V, SimpleCache<K, V>> {
  DisposableCacheHandler(): super(SimpleCache<K, V>());

  /// キャッシュを破棄
  void dispose()=>cache.dispose();
}