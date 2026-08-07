
/// Map の value がリストの時の処理の簡略化
extension ListMapOptions<K, V> on Map<K, List<V>>{
  /// Map の value がリストの時の `.add` のプロセス
  void addNullable({required K key, required V value}){
    putIfAbsent(key, () => []).add(value);
  }
}