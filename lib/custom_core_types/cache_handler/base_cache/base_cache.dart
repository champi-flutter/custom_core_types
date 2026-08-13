
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// ベースとなるキャッシュクラス
///
/// 対応するイベントハンドラ（[CacheEvent] かそれを継承したインターフェース）
/// を引数にとり、その具象クラスのコンストラクタを当てはめること。
abstract class BaseCache<K, V, E extends BaseCacheEntry<V>> {
  // BaseCache(this._event);
  //
  // /// イベントの呼び出し口
  // // イベントをメソッドで持つと、継承先で override したときに @protected も継承先で
  // // 記述する必要があるため、イベントハンドラのインターフェースをプライベートで持つようにする。
  // final CacheEvent<K, V, E> _event;

  /// 識別子とキャッシュエントリのハッシュマップ
  final Map<K, E> _storage = {};

  // todo [_storage] の情報へのアクセス
  @nonVirtual
  int get length => _storage.length;

  @nonVirtual
  bool get isEmpty => _storage.isEmpty;

  @nonVirtual
  bool get isNotEmpty => _storage.isNotEmpty;

  bool containsKey(K key) => _storage.containsKey(key);

  /// ストレージの参照
  @nonVirtual
  @protected
  Map<K, E> get storage => _storage;

  /// [_storage] から指定項目を削除する
  @nonVirtual
  @protected
  void removeAt(K key) => _storage.remove(key);

  // 外側からの参照
  @nonVirtual
  V? operator [](K key) {
    final entry = _storage[key];
    if (entry == null) {
      return null;
    } else {
      // 対象のアクセス時コールバックを呼び出す
      entry.onAccess();
      return entry.value;
    }
  }

  // map[key] への代入
  @nonVirtual
  void operator []=(K key, V value) {
    final currentEntry = _storage[key];

    // 指定 key に対応する値すでに存在し、それを更新する場合
    if (currentEntry != null) {
      currentEntry.value = value;
      // 対象のアクセス時コールバックを呼び出す
      currentEntry.onAccess();
    }
    // 新たな key と value を設置する場合
    else {
      // キャッシュの枠を追加するときのコールバックを呼び出す
      onAddEntry();
      // [E] に対応するエントリに変換
      final E entry = createEntry(value);
      _storage[key] = entry;
      // // アクセスを知らせる
      // _event.onAccess(key, entry);
    }
  }

  /// 全データを純粋な `Map<K, V>` の形
  @nonVirtual
  Map<K, V> get base =>
      _storage.map((key, entry) => MapEntry(key, entry.value));

  // todo 継承先で override するメソッド
  /// キャッシュの枠を追加するときのコールバック
  @protected
  @visibleForOverriding
  void onAddEntry();

  /// key に対応する独自のキャッシュエントリのインスタンスをつくるファクトリメソッド
  ///
  /// 独自のエントリのコンストラクタを返す。
  @protected
  @visibleForOverriding
  E createEntry(V value);
}