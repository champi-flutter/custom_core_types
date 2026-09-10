import 'package:custom_core_types/custom_core_types.dart';

abstract class ListCacheHandlerBaseInterface<K, I, V> {
  /// 指定 [key] のリストの指定 [index] に [value] を代入する
  ///
  /// ```
  /// _handler.update(
  ///   key: key,// 所属
  ///   valueMap: { // 場所とデータ（識別子と値の組み合わせ）の Map
  ///     0: (id: "識別子0", value: "値0"),
  ///     1: (id: "識別子1", value: "値1"),
  ///     2: (id: "識別子2", value: "値2"),
  ///   }
  /// );
  /// ```
  ///
  Future<void> update({
    required K key,
    required Map<int, DataEntry<I, V>> valueMap,
    List<I>? order,
  });
}