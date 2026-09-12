
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

  FixedList(int length, E Function(int index) fill)
      : _list = List.generate(
    length,
        (i) => ListEntry._(i, fill(i)),
    growable: false, // 固定長化
  );

  /// Iterable から FixedList を生成するファクトリコンストラクタ
  factory FixedList._fromIterable(Iterable<E> iterable) {
    final list = iterable.toList(growable: false);
    return _FixedListFromList._(list);
  }

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

  /// 各要素を [convert] に従って変換し、その戻り値の型の [Iterable] を返す
  Iterable<R> mapValues<R>(R Function(E value) convert) {
    return _list.map((entry) => convert(entry.value));
  }
}

/// [FixedList] のインデックスと要素の組み合わせ
class ListEntry<E> {
  final int index;
  E value;

  ListEntry._(this.index, this.value);
}

/// 変換メソッドのためのプライベートクラス
class _FixedListFromList<E> extends FixedList<E> {
  _FixedListFromList._(List<E> list)
      : super(list.length, (i) => list[i]);
}

extension ToFixedList<E> on Iterable<E> {
  /// [Iterable] を [FixedList] に変換する
  FixedList<E> toFixedList() => FixedList._fromIterable(this);
}