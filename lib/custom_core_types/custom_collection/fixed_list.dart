
import 'dart:collection';

/// 要素数が固定で、各要素が index を保持するリストの基底クラス
///
/// 以下のように、継承先で [length] を指定する 。
/// ```
/// class SampleFixedList<E> extends FixedList<E> {
///   SampleFixedList(List<E> list)
///       : super(list.length, (i) => list[i]);
/// }
/// ```
abstract class FixedList<E> extends ListBase<ListEntry<E>> {
  final List<ListEntry<E>> _list;

  /// サブクラスから「要素数(length)」と「初期値生成処理(fill)」を受け取る
  FixedList(int length, E Function(int index) fill)
      : _list = List.generate(
    length,
        (i) => ListEntry._(i, fill(i)),
    growable: false, // 固定長化
  );

  @override
  int get length => _list.length;

  /// 要素数の変更を禁止（ListBaseの仕様上、例外を投げる）
  @override
  set length(int newLength) {
    throw UnsupportedError('FixedList の要素数は変更できません。');
  }

  @override
  ListEntry<E> operator [](int index) => _list[index];

  /// 指定 [index] に値を代入する
  void setAt(int index, E newElement){
    this[index].value = newElement;
  }

  // 使用を制限（ListEntry のコンストラクタがプライベートなので代入不可）
  @override
  void operator []=(int index, ListEntry<E> newEntry) {
    _list[index] = newEntry;
  }
}

class ListEntry<E> {
  final int index;
  E value;

  ListEntry._(this.index, this.value);
}