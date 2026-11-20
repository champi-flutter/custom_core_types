/// `Map` のその時点での状態を格納するクラス
abstract class _MapSnapshotBase<K, V> {
  _MapSnapshotBase(Map<K, V> data) : _data = Map<K, V>.unmodifiable(data);

  final Map<K, V> _data;

  Iterable<K> get keys => _data.keys;

  Iterable<V> get values => _data.values;

  Iterable<MapEntry<K, V>> get entries => _data.entries;

  int get length => _data.length;

  bool get isEmpty => _data.isEmpty;

  bool get isNotEmpty => _data.isNotEmpty;

  bool containsKey(Object? key) => _data.containsKey(key);

  bool containsValue(Object? value) => _data.containsValue(value);

  V? operator [](Object? key) => _data[key];

  Map<K, V> toMutable() => Map<K, V>.of(_data);
}

/// `Map<K, int>` のその時点での状態を格納するクラス
abstract class IntMapSnapshot<K> extends _MapSnapshotBase<K, int> {
  IntMapSnapshot(super.data);
}

/// `Map<K, double>` のその時点での状態を格納するクラス
abstract class DoubleMapSnapshot<K> extends _MapSnapshotBase<K, double> {
  DoubleMapSnapshot(super.data);
}

/// `Map<K, String>` のその時点での状態を格納するクラス
abstract class StringMapSnapshot<K> extends _MapSnapshotBase<K, String> {
  StringMapSnapshot(super.data);
}

/// `Map<K, bool>` のその時点での状態を格納するクラス
abstract class BoolMapSnapshot<K> extends _MapSnapshotBase<K, bool> {
  BoolMapSnapshot(super.data);
}

/// `Map<K, O>` のその時点での状態を格納するクラス
abstract class ObjectMapSnapshot<K, O> extends _MapSnapshotBase<K, O> {
  /// `Map<K, O>` のその時点での状態を格納するクラス
  ///
  /// 以下のように、[copyBuilder] を継承先で実装すること。
  /// ```
  /// class User {
  ///   String? name;
  ///
  ///   User(this.name);
  /// }
  ///
  /// class UserMapSnapshot extends ObjectMapSnapshot<int, User> {
  ///   UserMapSnapshot(Map<int, User> data) : super(data, (user) => User(user.name));
  /// }
  /// ```
  ObjectMapSnapshot(Map<K, O> data, O Function(O) copyBuilder)
    : _copyBuilder = copyBuilder,
      super({
        for (final entry in data.entries) entry.key: copyBuilder(entry.value),
      });

  /// 新しいオブジェクトを生成する関数
  final O Function(O) _copyBuilder;

  @override
  Map<K, O> toMutable() =>
      _data.map((K key, O object) => MapEntry<K, O>(key, _copyBuilder(object)));
}
