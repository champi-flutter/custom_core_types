import 'package:custom_core_types/custom_core_types.dart';

/// 使用頻度の低いキャッシュから削除していくキャッシュ
///  - [capacity]: キャッシュの最大容量
class FifoListCache<K, El> extends EvictingListCache<K, El, FifoListCacheEntry<El>> {
  FifoListCache({required super.capacity}) : _last = 0;

  /// 削除対象決定ロジック
  ///
  ///  - 最大容量超過時にどの entry を削除するかを決める。
  ///  - 対応する key を返す。
  @override
  K specifyToEvict() {
    late K result;
    int minSequence = double.maxFinite.toInt();

    for (final entry in storage.entries) {
      if (entry.value.sequence < minSequence) {
        minSequence = entry.value.sequence;
        result = entry.key;
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

  /// [FifoListCacheEntry] を提供するファクトリメソッド
  @override
  FifoListCacheEntry<El> createEntry(List<El> value) =>
      FifoListCacheEntry<El>(value, sequence: _next);
}
