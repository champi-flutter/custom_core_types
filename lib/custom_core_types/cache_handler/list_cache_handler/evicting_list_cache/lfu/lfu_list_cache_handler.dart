
import 'package:custom_core_types/custom_core_types.dart';

/// LFU のキャッシュハンドラ
///
/// ジェネリクスに識別子とデータの型を指定する。
///
/// ```
/// /// 識別子の型が `int` 、データの型が `SampleData` の場合
/// abstract class SampleListCacheHandler
///     extends LfuListCacheHandler<int, List<SampleData>> {
///   /// `super.capacity` を親に渡すための内部的なコンストラクタ
///   /// （抽象クラスなので呼び出し不可）
///   SampleListCacheHandler({required super.capacity});
/// }
/// ```
///
/// このクラスを継承して、[output] に、キャッシュ更新時の反映処理を記述する。
abstract class LfuListCacheHandler<K, El>
    extends BaseListCacheHandler<K, El, LfuListCache<K, El>> {

  LfuListCacheHandler({required int capacity})
      : super(LfuListCache<K, El>(capacity: capacity));
}