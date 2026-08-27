
/// Map の value がリストの時の処理の簡略化
extension ListMapOptions<K, V> on Map<K, List<V>>{
  /// Map の value がリストの時の `.add` のプロセス
  void addNullable({required K key, required V value}){
    putIfAbsent(key, () => []).add(value);
  }
}

/// 二重の Map の処理
extension TwoDMapOptions<K, SubK, V> on Map<K, Map<SubK, V>>{
  /// Map の value が Map の時の代入プロセス
  void addNullable({required K key, required SubK subKey, required V value}){
    putIfAbsent(key, () => <SubK, V>{})[subKey] = value;
  }
}