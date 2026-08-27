
import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/base_list_cache/base_list_cache_entry.dart';
import 'package:flutter/foundation.dart';

/// ベースとなるキャッシュクラス
///
/// 対応するイベントハンドラ（[CacheEvent] かそれを継承したインターフェース）
/// を引数にとり、その具象クラスのコンストラクタを当てはめること。
abstract class BaseListCache<K, El, En extends BaseListCacheEntry<El>> {

  /// 識別子とキャッシュエントリのハッシュマップ
  final Map<K, En> _storage = {};

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
  Map<K, En> get storage => _storage;

  /// [_storage] から指定項目を削除する
  @nonVirtual
  @protected
  void removeAt(K key) => _storage.remove(key);

  // 外側からの参照
  @nonVirtual
  List<El>? operator [](K key) {
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
  void setList(K key, List<El> value) {
    final currentEntry = _storage[key];

    // 指定 key に対応する値すでに存在し、それを更新する場合
    if (currentEntry != null) {
      currentEntry.value = value;
      // 対象のアクセス時コールバックを呼び出す
      currentEntry.onAccess();
    }
    // 新たな key と value を設置する場合
    else {
      // [E] に対応するエントリに変換
      final En entry = createEntry(value);
      _storage[key] = entry;
      // キャッシュの枠を追加するときのコールバックを呼び出す
      onAddEntry(key);
    }
  }

  final Map<K, BiMap<int, int>> indexMap = {};

  /// 指定 [key] のリストの指定 [index] に [value] を代入する
  Future<void> setEl ({
    required K key,
    required Map<int, El> indexValueMap,
  })
  // 折りたたみ用
  async{
    final currentEntry = _storage[key];
      // 指定 key に対応するリストが存在し、指定 index の枠が存在する場合
    if (currentEntry != null) {
      // 対象のアクセス時コールバックを呼び出す
      final bool willAccess = currentEntry.onAccess();
      // 継承先で false になりうる実装もできる
      if(willAccess) {
        // 最終的に当てはめる値を保有するサブリストを生成する
        // （`currentEntry.value[index]` に直接代入しない）
        final List<El> resultList = [...currentEntry.value];
        for (final entry in indexValueMap.entries) {
          final index = entry.key;
          final value = entry.value;
          // index が有効かどうか
          if (index >= 0 && index < currentEntry.value.length) {
            // サブリストに当てはめる
            resultList[index] = value;
          }
          else {
            throw Exception(
                "[BaseListCache] index が指定のリストに対して不適当です。");
          }
        }
        // サブリストを当てはめる
        currentEntry.value = resultList;
      }
    }
    else {
      throw Exception("[BaseListCache] index が指定のリストに対して不適当です。");
    }
  }

  /// 全データを純粋な `Map<K, V>` の形
  @nonVirtual
  Map<K, List<El>> get base =>
      _storage.map((key, entry) => MapEntry(key, entry.value));

  // todo 継承先で override するメソッド
  /// キャッシュの枠を追加するときのコールバック
  @protected
  @visibleForOverriding
  void onAddEntry(K key);

  /// key に対応する独自のキャッシュエントリのインスタンスをつくるファクトリメソッド
  ///
  /// 独自のエントリのコンストラクタを返す。
  @protected
  @visibleForOverriding
  En createEntry(List<El> value);
}