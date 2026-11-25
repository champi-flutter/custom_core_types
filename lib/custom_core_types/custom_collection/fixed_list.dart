import 'dart:collection';

import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

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
    this[index]._setValue(newElement);
  }

  // 使用を制限（ListEntry のコンストラクタがプライベートなので代入不可）
  @protected
  @override
  void operator []=(int index, ListEntry<E> newEntry) {
    _list[index] = newEntry;
  }

  /// 各要素を [convert] に従って変換し、その戻り値の型の [Iterable] を返す
  Iterable<R> mapValues<R>(R Function(E value) convert) {
    return _list.map((entry) => convert(entry.value));
  }

  /// [ListBase] が持つ、元の [toList]
  ///
  /// 外部からの呼び出しを制限している。
  @override
  @protected
  @Deprecated("代わりに toEntryList を使ってください")
  List<ListEntry<E>> toList({bool growable = false}) => _list;

  /// エントリのリストを取得する
  List<ListEntry<E>> toEntryList() => _list;

  /// 要素のリストを取得する
  ///
  /// [growable] を必ず指定すること 。
  List<E> toValueList({required bool growable}) =>
      _list.map((entry) => entry.value).toList(growable: growable);

  /// 同じ情報を持つ別の新しいインスタンスを生成する。
  ///
  /// 継承先では、以下の2つを実装すること。
  ///
  /// 1. `super.deepCopy` をイニシャライザリストで呼び出す
  ///    複製用コンストラクタを設ける。
  /// 2. 本メソッドを override し、上記の複製用コンストラクタで
  ///    生成したインスタンスを返す。
  ///
  /// 例:
  /// ```dart
  /// class SampleList<E> extends FixedList<E> {
  ///
  ///   // (1) 複製用コンストラクタ
  ///   SampleList._callDeepCopy(super.entryList, super.copyBuilder)
  ///       : super.callDeepCopy();
  ///
  ///   // (2) deepCopy の override
  ///   @override
  ///   SampleList<E> deepCopy({
  ///     required E Function(E value) copyBuilder,
  ///   }) =>
  ///       SampleList<E>._callDeepCopy(
  ///           toEntryList(),
  ///           copyBuilder,
  ///         );
  /// }
  /// ```
  FixedList<E> deepCopy({required E Function(E value) copyBuilder});

  /// `List<ListEntry<E>>` から作るコンストラクタ。継承先の内部でのみ呼び出し可能。
  ///
  /// [copyBuilder] : ListEntry の value を作る処理
  /// （Built-in の場合は引数をそのまま返す関数）
  @protected
  FixedList.callDeepCopy(
    List<ListEntry<E>> entryList,
    E Function(E value) copyBuilder,
  ) : _list = List.generate(
        entryList.length,
        (i) => entryList[i].copy(valueBuilder: copyBuilder),
        growable: false, // 固定長化
      );

  /// `List<ListEntry<E>>` から作るコンストラクタ。
  FixedList.fromListEntry(List<ListEntry<E>> list)
    : _list = List.of(list, growable: false);

  // 2026/11/13 追加:
  // region リスト長変更アクセスの制限
  /// Unsupported を明示
  Never _throwUnsupported() =>
      throw UnsupportedError("[FixedList] リスト長変更のアクセスがありました。");

  @override
  @protected
  void add(ListEntry<E> element) => _throwUnsupported();

  @override
  @protected
  void addAll(Iterable<ListEntry<E>> iterable) => _throwUnsupported();

  @override
  @protected
  bool remove(Object? element) => _throwUnsupported();

  @override
  @protected
  ListEntry<E> removeAt(int index) => _throwUnsupported();

  @override
  @protected
  ListEntry<E> removeLast() => _throwUnsupported();

  @override
  @protected
  void removeRange(int start, int end) => _throwUnsupported();

  @override
  @protected
  void removeWhere(bool Function(ListEntry<E> element) _) =>
      _throwUnsupported();

  @override
  @protected
  void retainWhere(bool Function(ListEntry<E> element) _) =>
      _throwUnsupported();

  @override
  @protected
  void replaceRange(int start, int end, Iterable<ListEntry<E>> _) =>
      _throwUnsupported();

  @override
  @protected
  void clear() => _throwUnsupported();

  @override
  @protected
  void insert(int index, ListEntry<E> _) => _throwUnsupported();

  @override
  @protected
  void insertAll(int index, Iterable<ListEntry<E>> _) => _throwUnsupported();
  // endregion
}

/// [FixedList] のインデックスと要素の組み合わせ
class ListEntry<E> {
  final int index;
  E _value;

  E get value => _value;

  void _setValue(E newValue) => _value = newValue;

  ListEntry._(this.index, this._value);

  // /// 独立した ListEntry を生成する
  // ListEntry<E> copy() => ListEntry._(index, value);

  /// 同じ値を持つ新しい ListEntry を生成する
  ///
  /// [valueBuilder] : [value] を作る処理（Built-in の場合は引数をそのまま返す関数）
  ListEntry<E> copy({required E Function(E value) valueBuilder}) {
    return ListEntry._(index, valueBuilder(value));
  }

  // @protected
  // factory ListEntry.immutable(int index, E value) => ListEntry._(index, value);
}

extension ToFixedList<E> on Iterable<E> {
  /// [Iterable] を [FixedList] の継承先リストに変換する
  ///
  /// [FixedList] の継承先リストの、[] を引数に取るコンストラクタを当てはめる。
  R toListAs<R extends FixedList>(R Function(Iterable<E>) constructor) =>
      constructor(this);
}

extension UnorderedIterableEqualityExtension<T> on Iterable<T> {
  /// 順不同で Iterable の中身が等しいか判定する
  bool isUnorderedEqualTo(Iterable<T> other) {
    final equality = UnorderedIterableEquality<T>();
    return equality.equals(this, other);
  }
}

extension FixedListUnorderedEqualityExtension<E> on FixedList<E> {
  /// [FixedList] の内部の値を、他の List や FixedList と順不同で比較する
  bool isUnorderedEqualTo(Object other) {
    final Iterable<E> otherIterable;

    if (other is FixedList<E>) {
      otherIterable = other.mapValues((e) => e);
    } else if (other is Iterable<E>) {
      otherIterable = other;
    } else {
      return false;
    }

    // FixedList 内の ListEntry.value (E) を抽出して比較する
    return mapValues((e) => e).isUnorderedEqualTo(otherIterable);
  }
}
