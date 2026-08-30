
import 'package:custom_core_types/custom_core_types.dart';

abstract class BaseFloatingListCache <
 K,
 I,
 V,
 Ent extends BaseCacheEntry<V>,
 C extends BaseCache<I, V, Ent>
 > extends BaseListCache<K, I, V, Ent, C>{
  // 継承のための内部的なコンストラクタ
  BaseFloatingListCache(super.cache);


  /// ID で指定したエントリを、[key] に移動する
  ///
  /// fixme 計算量多め（最大 O(n^2） <= 数個の ID ならほぼ O(n)）
  void moveTo(K key, {required List<I> orderedId}) {
    // 古い key が見つからない場合
    final List<I> notFound = [];
    for (I targetId in orderedId) {
      // 古い key を探索する（O(n)）
      final K? oldKey = _searchForKeyToMove(targetId);
      if (oldKey != null) {
        // 対象グループの参照をコピーする
        final List<I>? idList = group[oldKey];
        if(idList != null) {
          idList.remove(targetId);
          group.addNullable(key: key, value: targetId);
        } else {
          notFound.add(targetId);
        }
      } else {
        notFound.add(targetId);
      }
    }
    if(notFound.isNotEmpty){
      throw Exception("[BaseListCache.moveTo] ID が見つかりませんでした。\n - ${notFound.join("\n - ")}");
    }
  }

  /// region [moveTo] で古い key を探索するプロセス
  K? _searchForKeyToMove(I targetId) {
    for (final groupEntry in group.entries) {
      if (groupEntry.value == targetId) {
        return groupEntry.key;
      }
    }
    return null;
  }
  // endregion

// region fixme replace
// /// 指定 [key] に含まれるキャッシュを丸ごと更新する
// void replace(K key, Map<I, V> valueMap) {
//   // fixme すでに ID が存在するエントリに対しては無効
//   final bool isInvalid = valueMap.keys.any(
//         (I i) => _identifier.containsKey(i),
//   );
//   assert(!isInvalid, "[BaseListCache.replace] すでに ID が存在するエントリに対しては無効です。");
//   final List<I> currentIdList = _currentIdListAt(key);
//   final List<I> removedIdList = currentIdList;
//   for (final entry in valueMap.entries) {
//     final I targetId = entry.key;
//     removedIdList.remove(targetId);
//     final V newValue = entry.value;
//
//     //
//     if (!(currentIdList.contains(targetId))) {
//       // _group に targetKey を追加
//       _group.addNullable(key: key, value: targetId);
//     }
//     // key に依存しないエントリの値を更新
//     _setValue(id: targetId, value: newValue);
//   }
//   // 指定されなかった ID を key の対象から外す
//   for (I removedId in removedIdList) {
//     _group[key]?.remove(removedId);
//   }
// }
// endregion
}