import 'package:flutter/foundation.dart';

class CacheEntry<V> {
  V value;

  CacheEntry(this.value);
}

abstract interface class CacheEvent<K, V, E extends CacheEntry<V>> {
  /// キャッシュへのアクセスがあったときの処理
  void onAccess(K key, E entry);

  /// サブクラスで独自のエントリのインスタンスを生成できるようにするファクトリメソッド
  ///
  /// 独自のエントリのコンストラクタを返す。
  E createEntry(V value);
}

/// ベースとなるキャッシュクラス
abstract class BaseCache<K, V, E extends CacheEntry<V>> {
  BaseCache(this._event);

  final CacheEvent<K, V, E> _event;

  final Map<K, E> _storage = {};

  // todo [_storage] の情報へのアクセス
  @nonVirtual
  int get length => _storage.length;

  @nonVirtual
  bool get isEmpty => _storage.isEmpty;

  @nonVirtual
  bool get isNotEmpty => _storage.isNotEmpty;

  bool containsKey(K key) => _storage.containsKey(key);

  /// ストレージを探索するための、全エントリーの読み取りアクセス
  @protected
  Iterable<MapEntry<K, E>> get storageEntries => _storage.entries;

  /// [_storage] から指定項目を削除する
  @nonVirtual
  @protected
  void removeAt(K key) => _storage.remove(key);

  // 外側からの参照
  @nonVirtual
  V? operator [](K key) {
    final entry = _storage[key];
    if (entry == null) return null;

    // アクセス時のフック（サブクラスでログ記録や頻度更新に利用）
    _event.onAccess(key, entry);
    return entry.value;
  }

  // map[key] への代入
  @nonVirtual
  void operator []=(K key, V value) {
    final currentEntry = _storage[key];

    // 指定 key に対応する値すでに存在し、それを更新する場合
    if (currentEntry != null) {
      currentEntry.value = value;
      // アクセスを知らせる
      _event.onAccess(key, currentEntry);
    }
    // 新たな key と value を設置する場合
    else {
      // キャッシュの枠を追加するときのコールバックを呼び出す
      onAdd();
      // [E] に対応するエントリに変換
      final E entry = _event.createEntry(value);
      _storage[key] = entry;
      // アクセスを知らせる
      _event.onAccess(key, entry);
    }
  }

  /// 全データを純粋な `Map<K, V>` の形
  @nonVirtual
  Map<K, V> get base =>
      _storage.map((key, entry) => MapEntry(key, entry.value));

  // todo 継承先で override するメソッド
  /// キャッシュの枠を追加するときのコールバック
  @protected
  void onAdd() {}
}

/// キャッシュの更新および出力を扱うハンドラの抽象基底クラス
///
/// 継承先に対応するキャッシュクラス（[BaseCache] を継承）のコンストラクタを
/// イニシャライザで呼び出す。
/// ```
/// abstract class SuperCacheHandler<K, V>
///   extends BaseCacheHandler<K, V, SuperCache<K, V>> {
///   SuperCacheHandler()
///     : super(SuperCache<K, V>());
/// }
/// ```
///
abstract class BaseCacheHandler<
  K,
  V,
  C extends BaseCache<K, V, CacheEntry<V>>
> {
  /// 内部で利用するキャッシュデータ構造
  ///
  /// 継承先に対応するキャッシュクラス（[BaseCache] を継承）のコンストラクタを
  /// イニシャライザで呼び出す。
  ///
  /// ```
  /// abstract class SuperCacheHandler<K, V>
  ///   extends BaseCacheHandler<K, V, SuperCache<K, V>> {
  ///   SuperCacheHandler()
  ///     : super(SuperCache<K, V>());
  /// }
  /// ```
  final C _cache;

  BaseCacheHandler(this._cache);

  /// キャッシュを更新し、出力処理を呼び出す統一フロー（オーバーライド不可）
  @nonVirtual
  void update(Map<K, V> dataMap) {
    for (final entry in dataMap.entries) {
      _cache[entry.key] = entry.value;
    }
    output(_cache.base);
  }

  /// 更新後の状態を出力する抽象メソッド（継承先で実装）
  @protected
  void output(Map<K, V> dataMap);
}
