import 'package:custom_core_types/custom_core_types.dart';
import 'package:flutter/foundation.dart';

/// いくつかのリストとして値を管理するキャッシュ
///
/// key （[K]）でリストを識別し、その index （0, 1, 2, ...）にエントリ（[Ent]）の
/// ID （[I]）が配置される。
// abstract class BaseListCache<K, I, V, Ent extends BaseCacheEntry<V>> {
//   /// key でグループ化されたキャッシュエントリを示す識別子のハッシュマップ
//   final Map<K, List<I>> _group = {};
//
//   List<I> _currentIdListAt(K key) => _group.nonNull(key);
//
//   ///
//   final Map<I, Ent> _identifier = {};
//
//   Ent _entryAt(I id) => _identifier.nonNull(id);
//
//   // /// 指定 [key] の値にアクセスした際のコールバック
//   // Future<bool> _onGroupAccess(K key) => _currentIdListAt(
//   //   key,
//   // ).map<Ent>((I id) => _entryAt(id)).toList().onAnyAccess();
//
//   /// 指定識別子に対応する value の値をセットするプライベートメソッド
//   @protected
//   void _setValue({required I id, required V value}) {
//     _entryAt(id).onAccess();
//     _entryAt(id).value = value;
//   }
//
//   // todo [_group] の情報へのアクセス
//   @nonVirtual
//   int get length => _group.length;
//
//   @nonVirtual
//   bool get isEmpty => _group.isEmpty;
//
//   @nonVirtual
//   bool get isNotEmpty => _group.isNotEmpty;
//
//   bool containsKey(K key) => _group.containsKey(key);
//
//   /// ストレージの参照
//   @nonVirtual
//   @protected
//   Map<K, List<I>> get group => _group;
//
//   // /// [_group] から指定項目を削除する
//   // @nonVirtual
//   // @protected
//   // void removeAt(K key) => _group.remove(key);
//
//   // cache[key] による参照
//   @nonVirtual
//   List<V>? operator [](K key) {
//     final List<I>? idList = _group[key];
//     if (idList == null) {
//       return null;
//     } else {
//       final List<V> result = [];
//       // 対象のアクセス時コールバックを呼び出す
//       for (I id in idList) {
//         final entry = _entryAt(id);
//         final bool willAccess = entry.onAccess();
//         if (willAccess) {
//           result.add(entry.value);
//         }
//       }
//       return result;
//     }
//   }
//
//   /// 指定 [key] に対応する値のグループを、`List<Ent>` で参照する
//   List<Ent> getEntries(K key) {
//     final List<V>? valueList = this[key];
//     if (valueList == null) {
//       return <Ent>[];
//     }
//     return valueList.map((V value) => createEntry(value)).toList();
//   }
//
//   /// 指定 [key] に対応する値を全て更新する
//   @nonVirtual
//   void updateByList({required K key, required List<V> valueList}) {
//     final currentIdList = _currentIdListAt(key);
//     assert(
//     valueList.length == currentIdList.length,
//     "[BaseListCache.updateByByList] 要素数が異なります。",
//     );
//     int index = -1;
//     for (I id in currentIdList) {
//       index++;
//       _setValue(id: id, value: valueList[index]);
//     }
//   }
//
//   /// key を指定して、そのリストの index に対応する値をセットする
//   ///
//   /// [order] で ID の順番を指定する。
//   ///
//   /// [onAddEntry] が呼ばれる。
//   @nonVirtual
//   void add({
//     required K key,
//     required Map<I, V> valueMap,
//     required List<I>? order,
//   })
//   // 折りたたみ用
//   {
//     // fixme すでに ID が存在するエントリに対しては無効
//     final bool isInvalid = valueMap.keys.any(
//       (I i) => _identifier.containsKey(i),
//     );
//     assert(!isInvalid, "[BaseListCache.add] すでに ID が存在するエントリに対しては無効です。");
//
//     // 順番が指定されている場合
//     if (order != null) {
//       final bool isOrderValid =
//           order.every((I ordered) => valueMap.keys.contains(ordered)) &&
//           order.length == valueMap.keys.length;
//       assert(isOrderValid, "[BaseListCache.add] order が無効です。");
//       _group.addAllNullable(key: key, valueList: order);
//     }
//     // 順番が指定されていないが、識別子が整数の場合は昇順にする
//     else if (I is int) {
//       final valueList = [...valueMap.keys]..sort();
//       _group.addAllNullable(key: key, valueList: valueList);
//     }
//     // その他
//     else {
//       _group.addAllNullable(key: key, valueList: valueMap.keys);
//     }
//
//     // エントリ型に変換して、_identifier に加える
//     final Map<I, Ent> entMap = valueMap.map((key, value) {
//       return MapEntry(key, createEntry(value));
//     });
//     _identifier.addAll(entMap);
//     onAddEntry(key);
//   }
//
//   /// ID で指定したエントリを、[key] に移動する
//   ///
//   /// fixme 計算量多め（最大 O(n^2））
//   void moveTo(K key, {required List<I> orderedId}) {
//     // 古い key が見つからない場合
//     final List<I> notFound = [];
//     for (I targetId in orderedId) {
//       final K? oldKey = _searchForKeyToMove(targetId);
//       if (oldKey != null) {
//         final targetValue = _group[oldKey]!;
//         _group[key] = targetValue;
//         _group.remove(oldKey);
//         _entryAt(targetId).onAccess();
//       } else {
//         notFound.add(targetId);
//       }
//     }
//   }
//
//   /// region [moveTo] で古い key を探索するプロセス
//   K? _searchForKeyToMove(I targetId) {
//     for (final groupEntry in _group.entries) {
//       if (groupEntry.value == targetId) {
//         return groupEntry.key;
//       }
//     }
//     return null;
//   }
//
//   // endregion
//
//   /// 指定 [key] に含まれるキャッシュを丸ごと更新する
//   void replace(K key, Map<I, V> valueMap) {
//     // fixme すでに ID が存在するエントリに対しては無効
//     final bool isInvalid = valueMap.keys.any(
//       (I i) => _identifier.containsKey(i),
//     );
//     assert(!isInvalid, "[BaseListCache.replace] すでに ID が存在するエントリに対しては無効です。");
//     final List<I> currentIdList = _currentIdListAt(key);
//     final List<I> removedIdList = currentIdList;
//     for (final entry in valueMap.entries) {
//       final I targetId = entry.key;
//       removedIdList.remove(targetId);
//       final V newValue = entry.value;
//
//       //
//       if (!(currentIdList.contains(targetId))) {
//         // _group に targetKey を追加
//         _group.addNullable(key: key, value: targetId);
//       }
//       // key に依存しないエントリの値を更新
//       _setValue(id: targetId, value: newValue);
//     }
//     // 指定されなかった ID を key の対象から外す
//     for (I removedId in removedIdList) {
//       _group[key]?.remove(removedId);
//     }
//   }
//
//   /// 指定 key のキャッシュを削除する
//   List<I> remove(K key) {
//     final List<I>? removedIds = _group.remove(key);
//     final List<I> result = [];
//     if (removedIds != null) {
//       for (final removedId in removedIds) {
//         _identifier.remove(removedId);
//         result.add(removedId);
//       }
//     }
//     return result;
//   }
//
//   /// 指定識別子に対応する value の値をセットする
//   void setAt({required I id, required V value}) => _setValue;
//
//   final Map<K, BiMap<int, int>> indexMap = {};
//
//   /// 指定 [key] のリストの指定 [index] に [value] を代入する
//   Future<void> updateElement({
//     required K key,
//     required Map<int, V> indexValueMap,
//   })
//   // 折りたたみ用
//   async {
//     final List<I> currentIdList = _currentIdListAt(key);
//     // 指定された入力値の組み合わせだけ繰り返す
//     for (final entry in indexValueMap.entries) {
//       // 入力欄のある index
//       final index = entry.key;
//       // 入力値
//       final value = entry.value;
//       // index が有効かどうか
//       if (index >= 0 && index < currentIdList.length) {
//         // 入力値を対応する入力欄に格納する
//         _setValue(id: currentIdList[index], value: value);
//       } else {
//         throw Exception("[BaseListCache] index が指定のリストに対して不適当です。");
//       }
//     }
//   }
//
//   /// 全データを純粋な `Map<K, List<V>>` の形
//   ///
//   /// fixme O(n^2)
//   @nonVirtual
//   Map<K, List<V>> get base =>
//       _group.map<K, List<V>>((K key, List<I> idList) {
//         final List<V> resultList = idList.map<V>((I id)=> _entryAt(id).value).toList();
//         return MapEntry(key,resultList);
//       });
//
//   // todo 継承先で override するメソッド
//   /// キャッシュの枠を追加するときのコールバック
//   @protected
//   @visibleForOverriding
//   void onAddEntry(K key);
//
//   /// key に対応する独自のキャッシュエントリのインスタンスをつくるファクトリメソッド
//   ///
//   /// 独自のエントリのコンストラクタを返す。
//   @protected
//   @visibleForOverriding
//   Ent createEntry(V value);
// }

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
