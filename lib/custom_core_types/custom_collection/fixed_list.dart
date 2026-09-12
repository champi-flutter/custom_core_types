import 'dart:collection';

/// 要素数が固定で、各要素が index を保持するリストの基底クラス
///
/// 継承先で [length] を指定し、`.fill` と `.fromIterable` の両方のコンストラクタを
/// 設置すること。
/// ```
/// const int sampleListLength = 3;
///
/// class SampleFixedList<E> extends FixedList<E> {
///   SampleFixedList.fill(E Function(int index) fill)
///       : super.fill(sampleListLength, fill);
///
///   SampleFixedList.fromIterable(Iterable<E> iterable)
///       : assert(
///     iterable.length == sampleListLength,
///     "[SampleFixedList.fromIterable] 要素数が不適当です",
///   ),
///         super.fromIterable(sampleListLength, iterable);
/// }
/// ```
abstract class FixedList<E> extends ListBase<ListEntry<E>> {
  final List<ListEntry<E>> _list;

  /// インデックスに対する要素の生成関数を指定するコンストラクタ
  FixedList.fill(int length, E Function(int index) fill)
    : _list = List.generate(
        length,
        (i) => ListEntry._(i, fill(i)),
        growable: false, // 固定長化
      );

  /// [Iterable] から [FixedList] を生成するコンストラクタ
  FixedList.fromIterable(int length, Iterable<E> iterable)
    : _list = _buildFromIterable(length, iterable);

  static List<ListEntry<T>> _buildFromIterable<T>(
    int length,
    Iterable<T> iterable,
  )
  // 折りたたみ用
  {
    final List<T> list = iterable is List<T>
        ? iterable
        : iterable.toList(growable: false);
    return List.generate(
      length,
      (i) => ListEntry._(i, list[i]),
      growable: false,
    );
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
  void setAt(int index, E newElement) {
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

extension ToFixedList<E> on Iterable<E> {
  /// [Iterable] を [FixedList] の継承先リストに変換する
  ///
  /// [FixedList] の継承先リストの、[] を引数に取るコンストラクタを当てはめる。
  R to<R extends FixedList>(R Function(Iterable<E>) constructor) =>
      constructor(this);
}

const int sampleListLength = 3;

class SampleFixedList<E> extends FixedList<E> {
  SampleFixedList.fill(E Function(int index) fill)
    : super.fill(sampleListLength, fill);

  SampleFixedList.fromIterable(Iterable<E> iterable)
    : assert(
        iterable.length == sampleListLength,
        "[SampleFixedList.fromIterable] 要素数が不適当です",
      ),
      super.fromIterable(sampleListLength, iterable);
}
