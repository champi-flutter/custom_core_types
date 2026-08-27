
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache/fifo/fifo_cache.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/evicting_cache/lfu/lfu_cache.dart';


/// FIFO のキャッシュハンドラ
///
/// ジェネリクスに識別子とデータの型を指定する。
///
/// ```
/// /// 識別子の型が `int` 、データの型が `SampleData` の場合
/// abstract class SampleCacheHandler
///     extends FifoCacheHandler<int, List<SampleData>> {
///   /// `super.capacity` を親に渡すための内部的なコンストラクタ
///   /// （抽象クラスなので呼び出し不可）
///   SampleCacheHandler({required super.capacity});
/// }
/// ```
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class FifoCacheHandler<K, V>
    extends BaseCacheHandler<K, V, FifoCache<K, V>> {

  FifoCacheHandler({required int capacity})
      : super(FifoCache<K, V>(capacity: capacity));
}