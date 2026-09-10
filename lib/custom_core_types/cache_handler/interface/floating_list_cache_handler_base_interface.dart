import 'package:custom_core_types/custom_core_types.dart';

abstract class FloatingListCacheHandlerBaseInterface<K, I, V>
    extends ListCacheHandlerBaseInterface<K, I, V> {
  /// ID で指定したエントリを、[key] に移動する
  ///
  /// fixme 計算量多め（最大 O(n^2） <= 数個の ID ならほぼ O(n)）
  void moveTo(K key, {required List<I> orderedId});
}