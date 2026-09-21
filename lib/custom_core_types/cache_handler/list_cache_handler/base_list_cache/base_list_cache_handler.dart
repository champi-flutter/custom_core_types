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
>
    implements ListCacheHandlerBaseInterface<K, I, V> {
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

  /// 複数の [update] を `Map` で指定して呼び出す
  @override
  Future<void> updateByMap({
    required Map<K, Map<int, DataEntry<I, V>>> updateInfo,
    Map<K, List<I>?>? orderMap,
  }) async {
    // 繰り返し処理を待ってから output する
    await _asyncUpdateByMap(updateInfo, orderMap);

    await output(_cacheMap.base);
  }

  /// [updateByMap] の繰り返し処理のまとまりを非同期で進める
  Future<void> _asyncUpdateByMap(
    Map<K, Map<int, DataEntry<I, V>>> updateInfo,
    Map<K, List<I>?>? orderMap,
  )
  // 折りたたみ用
  async {
    for (final entry in updateInfo.entries) {
      final K key = entry.key;
      final Map<int, DataEntry<I, V>> valueMap = entry.value;
      _cacheMap.update(key: key, valueMap: valueMap, order: orderMap?[key]);
    }
  }

  /// 指定 [key] のデータにアクセスされたことを伝える
  @override
  void notifyAccess({required K key})=> _cacheMap.notifyAccess(key: key);

  /// 指定 [key] のデータがキャッシュされているかどうか
  @override
  bool containsKey(K key) => _cacheMap.containsKey(key);

  /// 指定 [id] のデータがキャッシュされているかどうか
  @override
  bool containsId(I id)=> _cacheMap.containsId(id);

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  @visibleForOverriding
  Future<void> output(Map<K, List<V>> dataMap);
}
