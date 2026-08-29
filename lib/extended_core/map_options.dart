
/// Map の value がリストの時の処理の簡略化
extension ListMapOptions<K, V> on Map<K, List<V>>{
  /// Map の value がリストの時の `.add` のプロセス
  void addNullable({required K key, required V value}){
    putIfAbsent(key, () => []).add(value);
  }

  /// Map の value がリストの時の `.addAll` のプロセス
  void addAllNullable({required K key, required Iterable<V> valueList}){
    putIfAbsent(key, () => []).addAll(valueList);
  }
}

/// 二重の Map の処理
extension TwoDMapOptions<K, SubK, V> on Map<K, Map<SubK, V>>{
  /// Map の value が Map の時の代入プロセス
  ///
  /// [key] は所属、[subKey] は場所
  void addNullable({required K key, required SubK subKey, required V value}){
    putIfAbsent(key, () => <SubK, V>{})[subKey] = value;
  }
}

extension NonNullMapOperator<K, V> on Map<K, V>{
  V nonNull(K key){
    final result = this[key];
    if(result == null){
      throw Exception("[NonNullMapOperator] key: $key に対応する値が存在しません。");
    }
    return result;
  }
}