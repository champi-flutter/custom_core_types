import 'package:custom_core_types/custom_core_types.dart';
import 'package:flutter/foundation.dart';

/// いくつかのリストとして値を管理するキャッシュ
///
/// key （[K]）でリストを識別し、その index （0, 1, 2, ...）にエントリ（[Ent]）の
/// ID （[I]）が配置される。
abstract class BaseListCache<
K,
I,
V,
Ent extends BaseCacheEntry<V>,
C extends BaseCache<I, V, Ent>
> {
  BaseListCache(this._cache);

  /// key でグループ化されたキャッシュエントリを示す識別子のハッシュマップ
  final Map<K, List<I>> _group = {};

  List<I> _currentIdListAt(K key) => _group.nonNull(key);

  /// 個別のデータのハッシュマップ
  final C _cache;

  /// [_cache] へのアクセス
  ///
  /// このクラスと継承先のみアクセス可能。
  @protected
  C get cache => _cache;

  // Ent _entryAt(I id) => _identifier.nonNull(id);

  // /// 指定 [key] の値にアクセスした際のコールバック
  // Future<bool> _onGroupAccess(K key) => _currentIdListAt(
  //   key,
  // ).map<Ent>((I id) => _entryAt(id)).toList().onAnyAccess();

  /// 指定識別子に対応する value の値をセットするプライベートメソッド
  @protected
  void _setValue({required I id, required V value}) => _cache[id] = value;

  // todo [_group] の情報へのアクセス
  @nonVirtual
  int get length => _group.length;

  @nonVirtual
  bool get isEmpty => _group.isEmpty;

  @nonVirtual
  bool get isNotEmpty => _group.isNotEmpty;

  bool containsKey(K key) => _group.containsKey(key);

  /// ストレージの参照
  @nonVirtual
  @protected
  Map<K, List<I>> get group => _group;

  // /// [_group] から指定項目を削除する
  // @nonVirtual
  // @protected
  // void removeAt(K key) => _group.remove(key);

  /// key を指定して、対応する値のリストを返す
  @nonVirtual
  List<V> getValuesOf(K key) => _currentIdListAt(key).map((I id) {
    final V? value = _cache[id];
    if (value == null) {
      throw Exception("[BaseListCacheHandler] groupに存在するIDに対応するキャッシュが存在しません。");
    }
    return value;
  }).toList();

  /// 指定 [key] に対応する値のグループを、`List<Ent>` で参照する
  List<Ent> getEntries(K key) {
    final List<V> valueList = getValuesOf(key);
    return valueList.map((V value) => createEntry(value)).toList();
  }

  // region updateByList
  // /// 指定 [key] に対応する値を全て更新する
  // @nonVirtual
  // void updateByList({required K key, required List<V> valueList}) {
  //   final currentIdList = _currentIdListAt(key);
  //   assert(
  //   valueList.length == currentIdList.length,
  //   "[BaseListCache.updateByByList] 要素数が異なります。",
  //   );
  //   int index = -1;
  //   for (I id in currentIdList) {
  //     index++;
  //     _setValue(id: id, value: valueList[index]);
  //   }
  // }
  // endregion

  /// key を指定して、そのリストの index に対応する値をセットする
  ///
  /// [order] で ID の順番を指定する。
  ///
  /// [onAddEntry] が呼ばれる。
  @nonVirtual
  void _add({
    required K key,
    required Map<I, V> valueMap,
    required List<I>? order,
  })
  // 折りたたみ用
  {
    // fixme すでに ID が存在するエントリに対しては無効
    final bool isInvalid = valueMap.keys.any((I i) => _cache.containsKey(i));
    assert(!isInvalid, "[BaseListCacheHandler.add] すでに ID が存在するエントリに対しては無効です。");

    // キャッシュにデータを加える
    for (final entry in valueMap.entries) {
      _setValue(id: entry.key, value: entry.value);
    }

    // グルーピング
    // 順番が指定されている場合
    if (order != null) {
      final bool isOrderValid =
          order.every((I ordered) => valueMap.keys.contains(ordered)) &&
              order.length == (_currentIdListAt(key).length + valueMap.keys.length);
      if (isOrderValid) {
        _group[key] = order;
        return;
      } else {
        _group.addAllNullable(key: key, valueList: valueMap.keys);
        throw Exception("[BaseListCache.add] order が無効です。");
      }
    }
    // 順番が指定されていないが、識別子が整数の場合は昇順にする
    else if (I is int) {
      final valueList = [...valueMap.keys]..sort();
      _group.addAllNullable(key: key, valueList: valueList);
      _group[key]!.sort();
    }
    // その他
    else {
      _group.addAllNullable(key: key, valueList: valueMap.keys);
    }
  }

  /// 指定 key のキャッシュを削除する
  List<I> remove(K key) {
    final List<I>? removedIds = _group.remove(key);
    final List<I> result = [];
    if (removedIds != null) {
      for (final removedId in removedIds) {
        _cache.removeAt(removedId);
        result.add(removedId);
      }
    }
    return result;
  }

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
  })
  // 折りたたみ用
  async {
    final List<I> currentIdList = _currentIdListAt(key);
    // 指定された入力値の組み合わせだけ繰り返す
    for (final MapEntry<int, DataEntry<I, V>> valueMapEntry in valueMap.entries) {
      final int index = valueMapEntry.key;
      // index が指定された場合
      if (index >= 0) {
        final DataEntry<I, V> dataEntry = valueMapEntry.value;
        // 識別子
        final I id = dataEntry.id;
        // 入力値
        final V value = dataEntry.value;
        // 指定 index が現段階での index の最後尾を超えている時
        if (index >= currentIdList.length) {
          _add(key: key, valueMap: {id: value}, order: order);
        }
        // 指定した場所のデータの ID が一致した場合は、その場所の値を更新する
        else if (currentIdList[index] == id) {
          _setValue(id: id, value: value);
        }
        // 存在しない ID の場合は、新たなデータをキャッシュに追加する
        else if (!_cache.containsKey(id)) {
          _add(key: key, valueMap: {id: value}, order: order);
        }
        // 指定した場所のデータの ID が一致しないが、指定した ID が存在する場合
        // 　=> index と ID が同期していない（文法エラー）
        else {
          throw Exception("[BaseListCache] 指定 ID のデータが他の Key に存在します。");
        }
      }
      // index が指定されなかった（負で指定された場合）場合
      else {
        final DataEntry<I, V> dataEntry = valueMapEntry.value;
        // 識別子
        final I id = dataEntry.id;
        // 入力値
        final V value = dataEntry.value;
        // key で指定したグループに対象の ID が含まれている場合は、そのIDに対応する値を
        // 更新する
        if (currentIdList.contains(id)) {
          _setValue(id: id, value: value);
        }
        // 存在しない ID の場合は、新たなデータをキャッシュに追加する
        else if (!_cache.containsKey(id)) {
          _add(key: key, valueMap: {id: value}, order: order);
        }
        // 指定した場所のデータの ID が一致しないが、指定した ID が存在する場合
        // 　=> index と ID が同期していない（文法エラー）
        else {
          throw Exception("[BaseListCache] 指定 ID のデータが他の Key に存在します。");
        }
      }
    }
  }

  /// 全データを純粋な `Map<K, List<V>>` の形
  ///
  /// fixme O(n^2)
  @nonVirtual
  Map<K, List<V>> get base => _group.map<K, List<V>>((K key, _) {
    final List<V> resultList = getValuesOf(key);
    return MapEntry(key, resultList);
  });

//
  // todo 継承先で override するメソッド
  /// キャッシュの枠を追加するときのコールバック
  @protected
  @visibleForOverriding
  void onAddEntry(K key);

  /// key に対応する独自のキャッシュエントリのインスタンスをつくるファクトリメソッド
  ///
  /// 独自のエントリのコンストラクタを返す。
  @protected
  @visibleForOverriding
  Ent createEntry(V value);
}

// /// [BaseCacheEntry] をリストで扱うための拡張メソッド
// extension AccessEntryList<V, Ent extends BaseCacheEntry<V>> on Iterable<Ent> {
//   Future<bool> onAnyAccess() async {
//     bool result = true;
//     forEach((Ent ent) => result = ent.onAccess());
//     return result;
//   }
// }
