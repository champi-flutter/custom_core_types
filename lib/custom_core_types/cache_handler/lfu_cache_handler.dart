
import 'package:flutter/foundation.dart';

class LfuCacheEntry<K, V> {
  final K key;
  V data;
  int freq;

  LfuCacheEntry({required this.key, required this.data}):
        freq = 1;

  void update(V newData){
    data = newData;
    freq++;
  }
}

extension OutputType<K, V> on Map<K, LfuCacheEntry<K, V>>{
  Map<K, V> outputType()=>map<K, V>((key, value)=>MapEntry(key, value.data));
}

// class LfuCacheMap<K, V>{
//   final Map<K, V> cacheMap = {};
//   final Map<K, int> keyFreqMap = {};
//
//   void update({required K key, required V data}){
//     cacheMap[key] = data;
//     keyFreqMap[key] = (keyFreqMap[key]??0)+1;
//   }
// }

abstract class LfuCacheHandler<K, V> {
  /// キャッシュの最大容量
  final int capacity;

  LfuCacheHandler({required this.capacity});

  final Map<K, LfuCacheEntry<K, V>> _cacheMap = {};
  // final Map<K, V> _cacheMap = {};
  // final Map<K, int> _keyFreqMap = {};

  /// 更新結果を出力する処理
  @protected
  void _output(Map<K, V> dataMap);

  @nonVirtual
  bool get _hasExceeded => _cacheMap.length >= capacity;

  @nonVirtual
  bool _existsDataAt(K key) => _cacheMap[key] != null;

  /// 新規データを加える
  @nonVirtual
  void _addNew(K key, V data) {
    assert(!_existsDataAt(key), "既存の key に対して _addNew が呼び出されました。");
    if (_hasExceeded) {
      _disposeLeastFrequentlyUsedData();
    }
    // 新たな枠にデータをキャッシュする
    _cacheMap[key] = LfuCacheEntry(key: key, data: data);
    // _cacheMap[key] = _LfuCacheEntry(data: data);
    //
    // // 新たな key と紐づく使用頻度を初期化する
    // _keyFreqMap[key] = 1;
  }

  /// キャッシュを更新して出力
  @nonVirtual
  void update(Map<K, V> dataMap) {
    // 取得したデータをキャッシュの Map に組み込む
    for (var entries in dataMap.entries) {
      final targetEntry = _cacheMap[entries.key];
      // すでに key と紐づくデータがある場合
      if (targetEntry != null) {
        targetEntry.update(entries.value);
      }
      // key と紐づくデータがない場合
      else {
        _addNew(entries.key, entries.value);
      }
    }
    // 更新結果を出力
    _output(_cacheMap.outputType());
  }

  @nonVirtual
  void _disposeAt(K key) {
    _cacheMap.remove(key);
  }

  @nonVirtual
  void _disposeLeastFrequentlyUsedData() {
    assert(
    _hasExceeded,
    "上限に達していないのに、キャッシュの破棄が呼び出されました。",
    );
    // todo
  }
}