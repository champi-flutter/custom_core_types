import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/interface/list_cache_handler_base_interface.dart';
import 'package:flutter/foundation.dart';

/// キャッシュの更新および出力を扱うハンドラの抽象基底クラス
///
/// 継承先に対応するキャッシュクラス（[BaseListCache] を継承）のコンストラクタを
/// イニシャライザで呼び出す。
/// ```
/// abstract class SuperListCacheHandler<K, V>
///   extends BaseListCacheHandler<K, V, SuperListCache<K, V>> {
///   SuperListCacheHandler()
///     : super(SuperListCache<K, V>());
/// }
/// ```
///
abstract class BaseListCacheHandler<
  K,
  I,
  V,
  Ent extends BaseCacheEntry<V>,
  C extends BaseCache<I, V, Ent>,
  M extends BaseListCache<K, I, V, Ent, C>
> implements ListCacheHandlerBaseInterface<K, I, V>{
  BaseListCacheHandler(this._cacheMap);

  final M _cacheMap;

  /// [_cache] へのアクセス
  ///
  /// このクラスと継承先のみアクセス可能。
  @protected
  M get cacheMap => _cacheMap;

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
  @override
  Future<void> update({
    required K key,
    required Map<int, DataEntry<I, V>> valueMap,
    List<I>? order,
  })
  // 折りたたみ用
  async {
    // 指定された入力値の組み合わせだけ繰り返す
    await _cacheMap.update(key: key, valueMap: valueMap, order: order);

    await output(_cacheMap.base);
  }

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  @visibleForOverriding
  Future<void> output(Map<K, List<V>> dataMap);
}
