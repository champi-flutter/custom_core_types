import 'dart:math';

import 'package:custom_core_types/custom_core_types.dart';
import 'package:flutter/foundation.dart';

/// 対象 List をその時点での状態で格納するクラス
abstract class ListSnapshot<E> {
  /// 対象 List をその時点での状態で格納するクラス
  ///
  ///  - [elementBuilder] : 要素の新しいオブジェクトを生成する Builder 関数
  ///  （Built-in の場合は、引数をそのまま返す関数でよい。)
  ListSnapshot(List<E> list, {required E Function(E element) elementBuilder})
    : _data = List.unmodifiable(list),
      _elementBuilder = elementBuilder;

  final List<E> _data;

  /// 要素の新しいオブジェクトを生成する Builder 関数
  ///
  /// Built-in の場合は、引数をそのまま返す関数でよい。
  final E Function(E element) _elementBuilder;

  E? operator [](int index) => _data[index];

  List<E> toMutable() =>
      _data.map<E>((E element) => _elementBuilder(element)).toList();
}

/// サンプルに当てはめるリストクラス（[FixedList] を継承）
class SampleFixedList<E> extends FixedList<E> {
  SampleFixedList(Iterable<E> iterable)
    : super.fromIterable(iterable.length, iterable);

  // 対象となるリストクラス（このクラス）の `FixedList.callDeepCopy` を
  // 継承するコンストラクタは、public にする
  SampleFixedList.callDeepCopy(super.entryList, {required super.copyBuilder})
    : super.callDeepCopy();

  @override
  SampleFixedList<E> deepCopy({required E Function(E value) copyBuilder}) =>
      SampleFixedList.callDeepCopy(toEntryList(), copyBuilder: copyBuilder);
}

/// サンプル
class SampleFixedListSnapshot<E>
    extends FixedListSnapshot<E, SampleFixedList<E>> {
  SampleFixedListSnapshot(super.fixedList, {required super.elementBuilder});

  // 対象の、 `FixedList.callDeepCopy` を継承したコンストラクタを返す
  // 内部に対象リストクラスを持つわけではないので、 `deepCopy` メソッドは使えない
  @override
  SampleFixedList<E> toOriginal() =>
      SampleFixedList.callDeepCopy(entryList, copyBuilder: elementBuilder);
}

class Hoge {
  void hoge() {
    final SampleFixedList<String> sample = SampleFixedList([
      "子ども",
      "大人",
      "その他",
    ]);
    final SampleFixedListSnapshot<String> snapshot = SampleFixedListSnapshot(
      sample,
      elementBuilder: (s) => s,
    );
    print(snapshot[1]!.value); // 大人
  }
}

/// [ListSnapshot] の固定長リスト版の基底クラス
///
/// [FixedList] の継承先に合わせて、このクラスを継承させる。
///
/// ```
///
/// /// サンプルに当てはめるリストクラス（[FixedList] を継承）
/// class SampleFixedList<E> extends FixedList<E> {
///   SampleFixedList(Iterable<E> iterable)
///       : super.fromIterable(iterable.length, iterable);
///
///   // 対象となるリストクラス（このクラス）の `FixedList.callDeepCopy` を
///   // 継承するコンストラクタは、public にする
///   SampleFixedList.callDeepCopy(super.entryList, {required super.copyBuilder})
///       : super.callDeepCopy();
///
///   @override
///   SampleFixedList<E> deepCopy({required E Function(E value) copyBuilder}) =>
///       SampleFixedList.callDeepCopy(toEntryList(), copyBuilder: copyBuilder);
/// }
///
/// /// サンプル
/// class SampleFixedListSnapshot<E>
///     extends FixedListSnapshot<E, SampleFixedList<E>> {
///   SampleFixedListSnapshot(super.fixedList, {required super.elementBuilder});
///
///   // 対象の、 `FixedList.callDeepCopy` を継承したコンストラクタを返す
///   // 内部に対象リストクラスを持つわけではないので、 `deepCopy` メソッドは使えない
///   @override
///   SampleFixedList<E> toOriginal() =>
///       SampleFixedList.callDeepCopy(entryList, copyBuilder: elementBuilder);
/// }
/// ```
///
/// ```
/// /// 使用例
/// void hoge() {
///   final SampleFixedList<String> sample = SampleFixedList([
///     "子ども",
///     "大人",
///     "その他",
///   ]);
///   final SampleFixedListSnapshot<String> snapshot = SampleFixedListSnapshot(
///     sample,
///     elementBuilder: (s) => s,
///   );
///   print(snapshot[1]!.value); // 大人
/// }
/// ```
abstract class FixedListSnapshot<E, R extends FixedList<E>> {
  FixedListSnapshot(
    R fixedList, {
    required E Function(E element) elementBuilder,
  }) : _data = fixedList.toEntryList(),
       elementBuilder = elementBuilder;

  final List<ListEntry<E>> _data;

  @protected
  List<ListEntry<E>> get entryList => _data;

  // final int _length;

  @protected
  final E Function(E element) elementBuilder;

  /// [ListEntry.value] には setter がないので変更不可
  ListEntry<E>? operator [](int index) => _data[index];

  /// 元の（[FixedList] を継承した）固定長リストを返す
  ///
  /// 元の固定長リストクラスに、`List<ListEntry<E>>` を渡して作るコンストラクタを用意する
  /// こと。
  ///
  /// ```
  ///   // 対象の、 `FixedList.callDeepCopy` を継承したコンストラクタを返す
  ///   // 内部に対象リストクラスを持つわけではないので、 `deepCopy` メソッドは使えない
  ///   @override
  ///   SampleFixedList<E> toOriginal() =>
  ///       SampleFixedList.callDeepCopy(entryList, copyBuilder: elementBuilder);
  /// ```
  R toOriginal();
}

// class SampleList<E> extends FixedList<E> {
//   SampleList(super.length, super.iterable) : super.fromIterable();
//
//   @override
//   // TODO: implement deepCopy
//   FixedList<E> get deepCopy => throw UnimplementedError();
// }
//
// abstract class ListSnapshot<E> extends FixedList<E> {
//   ListSnapshot(Iterable<E> iterable)
//     : super.fromIterable(iterable.length, iterable);
//
//   /// [FixedList] を継承した固定長リストのスナップショット
//   ListSnapshot._fromFixedList(FixedList<E> fixedList)
//     : super.copy(fixedList.toEntryList());
//
//   ListType _unfreezeAs<ListType extends FixedList<E>>(
//     ListType Function(List<ListEntry<E>>) copy,
//   ) {
//     return copy(unfreezeValue());
//   }
//
//   List<E> unfreezeAll() => super.toValueList();
//
//   List<ListEntry<E>> unfreezeValue() => [...super.toEntryList()];
//
//   // region 要素変更アクセスの制限
//
//   Never _throwUnsupported() {
//     throw UnsupportedError("[ListSnapshot] 要素変更のアクセスがありました。");
//   }
//
//   @override
//   @protected
//   List<ListEntry<E>> toList({bool growable = false}) => _throwUnsupported();
//
//   @override
//   @protected
//   List<E> toValueList() => _throwUnsupported();
//
//   @override
//   @protected
//   List<ListEntry<E>> toEntryList() => _throwUnsupported();
//
//   /// 要素の置き換え
//   @override
//   void setAt(int index, E newElement) => _throwUnsupported();
//
//   /// Entry の置き換え
//   @override
//   void operator []=(int index, ListEntry<E> newEntry) => _throwUnsupported();
//
//   /// 先頭 Entry の置き換え
//   @override
//   set first(ListEntry<E> value) => _throwUnsupported();
//
//   /// 末尾 Entry の置き換え
//   @override
//   set last(ListEntry<E> value) => _throwUnsupported();
//
//   /// 複数 Entry の置き換え
//   @override
//   void setAll(int index, Iterable<ListEntry<E>> iterable) =>
//       _throwUnsupported();
//
//   /// 範囲内の Entry の置き換え
//   @override
//   void setRange(
//     int start,
//     int end,
//     Iterable<ListEntry<E>> iterable, [
//     int skipCount = 0,
//   ]) => _throwUnsupported();
//
//   /// 範囲内の Entry の埋め込み
//   @override
//   void fillRange(int start, [int? end, ListEntry<E>? fillValue]) =>
//       _throwUnsupported();
//
//   /// 並び替え
//   @override
//   void sort([int Function(ListEntry<E> a, ListEntry<E> b)? compare]) =>
//       _throwUnsupported();
//
//   /// シャッフル
//   @override
//   void shuffle([Random? _]) => _throwUnsupported();
//   // endregion
// }
//
// abstract class FixedListSnapshot<E, ListType extends FixedList<E>>
//     extends ListSnapshot<E> {
//   FixedListSnapshot(
//     ListType super.list, {
//     required ListType Function(List<ListEntry<E>>) copy,
//   }) : _copy = copy,
//        super._fromFixedList();
//
//   final ListType Function(List<ListEntry<E>>) _copy;
//
//   /// 元の固定長リストに戻す
//   ListType unfreeze() => _unfreezeAs<ListType>(_copy);
// }
//
// class SampleListSnapshot<E> extends ListSnapshot<E> {
//   SampleListSnapshot(List<E> super.list);
//
//   @override
//   // TODO: implement deepCopy
//   FixedList<E> get deepCopy => throw UnimplementedError();
// }
//
// void hoge() {
//   final list = <int>[0, 1, 2];
//   final SampleListSnapshot<int> listSnapshot = SampleListSnapshot(list);
// }
