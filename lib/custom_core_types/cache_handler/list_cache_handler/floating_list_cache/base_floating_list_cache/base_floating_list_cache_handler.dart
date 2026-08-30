import 'dart:js_interop';

import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache_entry.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/floating_list_cache/base_floating_list_cache/base_floating_list_cache.dart';
import 'package:flutter/foundation.dart';

/// [BaseListCacheHandler] に [BaseFloatingListCache] の機能を付与したハンドラの
/// 基底クラス
abstract class BaseFloatingListCacheHandler<
  K,
  I,
  V,
  Ent extends BaseCacheEntry<V>,
  C extends BaseCache<I, V, Ent>,
  M extends BaseFloatingListCache<K, I, V, Ent, C>
> extends BaseListCacheHandler<K, I, V, Ent, C, M>{
  BaseFloatingListCacheHandler(super.cacheMap);

  /// ID で指定したエントリを、[key] に移動する
  ///
  /// fixme 計算量多め（最大 O(n^2） <= 数個の ID ならほぼ O(n)）
  void moveTo(K key, {required List<I> orderedId})=> cacheMap.moveTo;
}
