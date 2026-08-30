
import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/floating_list_cache/base_floating_list_cache/base_floating_list_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/list_cache_handler/floating_list_cache/floating_evicting_cache/lfu/lfu_floating_list_cache.dart';

/// LFU のキャッシュハンドラ
///
/// ジェネリクスに識別子とデータの型を指定する。
///
/// ```
/// /// 識別子の型が `int` 、データの型が `SampleData` の場合
/// abstract class SampleListCacheHandler
///     extends LfuListCacheHandler<int, SampleData> {
///   /// `super.capacity` を親に渡すための内部的なコンストラクタ
///   /// （抽象クラスなので呼び出し不可）
///   SampleListCacheHandler({required super.capacity});
/// }
/// ```
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class LfuFloatingListCacheHandler<K, I, V>
    extends BaseFloatingListCacheHandler<K, I, V, LfuCacheEntry<V>, LfuCache<I, V>, LfuFloatingListCache<K, I, V>> {

  LfuFloatingListCacheHandler({required int capacity})
      : super(LfuFloatingListCache<K, I, V>(capacity: capacity));
}