// import 'dart:collection';
//
// import 'package:custom_core_types/custom_core_types.dart';
// import 'package:flutter/foundation.dart';
//
// // class El<I, V> {
// //   final I id;
// //   final V value;
// //
// //   El(this.id, this.value);
// //
// //   @override
// //   String toString() => 'El(id: $id, value: $value)';
// // }
//
// class Group<K, I, V> {
//   final Map<K, List<I>> _group = {};
//   final Map<I, V> _identifier = {};
//
//   List<V> operator [](K key) {
//     final List<I>? idList = _group[key];
//     if(idList == null){
//       return <V>[];
//     }
//     final sortedKeys = idList.toList()..sort();
//
//     final List<V> result = sortedKeys.map((key) => _identifier[key]!).toList();
//     return result;
//   }
//
//   void operator []=(K key, Map<I, V> valueMap){
//     final List<I>? idList = _group[key];
//     final List<I> removedIdList = idList??[];
//     for(final entry in valueMap.entries){
//       final I targetId = entry.key;
//       removedIdList.remove(targetId);
//       final V newValue = entry.value;
//       //
//       if(!(idList != null && idList.contains(targetId))){
//         // _group に targetKey を追加
//         _group.addNullable(key: key, value: targetId);
//       }
//       // key に依存しない Map データを更新
//       _identifier[targetId] = newValue;
//     }
//     // 指定されなかった ID を key の対象から外す
//     for(I removedId in removedIdList){
//       _group[key]?.remove(removedId);
//     }
//   }
//
//   void updateAt({required K key, required I id, required V value}){
//
//   }
//
//   void updateByList({required K key, required List<V> valueList}){
//     final List<I>? idList = _group[key];
//     if(idList != null) {
//       assert(valueList.length == idList.length,
//         "[Group.update] 要素数が異なります。",
//       );
//       int index = -1;
//       for (I id in idList) {
//         index++;
//         _identifier[id] = valueList[index];
//       }
//     }
//   }
//
//   @override
//   List<V>? remove(Object? key) {
//     final List<I>? removed = _group.remove(key);
//     final List<V> result = [];
//     if (removed != null) {
//       for (final removedId in removed) {
//         final V? v = _identifier.remove(removedId);
//         if(v!=null) {
//           result.add(v);
//         }
//       }
//     }
//     return result;
//   }
//
//   @override
//   void clear() {
//     _byK.clear();
//     _byI.clear();
//   }
//
//   @override
//   Iterable<K> get keys => _byK.keys;
//
//   // --- カスタム機能 ---
//
//   /// I (id) から V (value) を高速取得 (O(1))
//   V? getByI(I id) => _byI[id];
//
//   /// 単一要素を追加する便利なヘルパーメソッド
//   void addEl(K key, El<I, V> element) {
//     final list = _byK.putIfAbsent(key, () => []);
//     list.add(element);
//     _byI[element.id] = element.value;
//   }
// }