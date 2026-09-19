
import 'package:custom_core_types/custom_core_types/cache_handler/base_cache/base_cache_handler.dart';
import 'package:custom_core_types/custom_core_types/cache_handler/expirable_cache/ttl/ttl_cache.dart';


/// TTL のキャッシュハンドラ
///
/// ジェネリクスに識別子とデータの型を指定する。
///
///  - `timeToLive`: キャッシュの有効期限（秒）
///
/// ```
/// /// 識別子の型が `int` 、データの型が `SampleData` の場合
/// abstract class SampleCacheHandler
///     extends TtlCacheHandler<int, List<SampleData>> {
///   /// `super.timeToLive` を親に渡すための内部的なコンストラクタ
///   /// （抽象クラスなので呼び出し不可）
///   SampleCacheHandler({required super.timeToLive});
/// }
/// ```
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class TtlCacheHandler<K, V>
    extends BaseCacheHandler<K, V, TtlCache<K, V>> {

  TtlCacheHandler({required int timeToLive})
      : super(TtlCache<K, V>(timeToLive: timeToLive));
}