
import 'package:flutter/foundation.dart';

abstract interface class CacheHandlerBaseInterface<K, V> {

  /// キャッシュを更新し、出力処理を呼び出す統一フロー
  ///
  /// key（[dataMap.keys]）に対応する値を [dataMap.values] に更新する。
  ///
  /// 反映の完了まで待ちたい場合は、`await` をつけるとよい。
  Future<void> update(Map<K, V> dataMap);
}