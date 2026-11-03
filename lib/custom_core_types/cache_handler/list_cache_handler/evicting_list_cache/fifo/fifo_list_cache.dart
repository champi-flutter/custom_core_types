import 'package:custom_core_types/custom_core_types.dart';

/// 先に入ったキャッシュから削除していくキャッシュ
///  - [capacity]: キャッシュの最大容量
class FifoListCache<K, I, V> extends EvictingListCache<K, I, V, FifoCacheEntry<V>, FifoCache<I, V>> {
  FifoListCache({required super.capacity}) : _last = 0, super(FifoCache(capacity: capacity));

  /// 削除対象決定ロジック
  ///
  ///  - 最大容量超過時にどの entry を削除するかを決める。
  ///  - 対応する key を返す。
  @override
  K specifyToEvict() {
    late K result;
    int minSequence = double.maxFinite.toInt();
    // 全キャッシュを探索
    for(final targetKey in group.keys){
      // targetKey に含まれるキャッシュのリストをエントリ型で参照する
      final List<FifoCacheEntry<V>> targetEntList = getEntries(targetKey);

      // グループ内で最も最近のキャッシュの sequence を決定する
      int? newestSequence;
      for (final ent in targetEntList) {
        newestSequence ??= ent.sequence;
        if (ent.sequence < minSequence) {
          minSequence = ent.sequence;
        }
      }
      if(newestSequence == null){
        continue;
      }
      // minSequence の初期値は無限なので必ず一回は回る
      if(newestSequence < minSequence){
        minSequence = newestSequence;
        result = targetKey;
      }
    }
    return result;
  }

  /// 順番の最後尾
  int _last;

  int get _next {
    _last++;
    return _last;
  }

  /// [FifoCacheEntry] を提供するファクトリメソッド
  @override
  FifoCacheEntry<V> createEntry(V value) =>
      FifoCacheEntry<V>(value, sequence: _next);
}
