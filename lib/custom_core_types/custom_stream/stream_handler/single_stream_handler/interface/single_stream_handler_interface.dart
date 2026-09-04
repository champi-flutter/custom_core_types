import 'dart:async';

import 'package:flutter/foundation.dart';

/// 1つの [StreamSubscription] を扱うハンドラクラスのインターフェース
///
/// **【使い方】**
///  1. アプリのコアの層に、このクラスを継承した、ストリームハンドラのインターフェースを設置
///  する。
///  2. アプリのインフラ層に、ストリームハンドラの具象クラスを設置する
///  （以下を継承（このクラスと同じジェネリクスを指定すること））。
///     - `SingleStreamHandlerBaseImplementation`
///     - `SingleStreamHandlerImplementationWithInitialLoading`
///
abstract class SingleStreamHandlerInterface<T> {

  /// ストリームを購読する
  Future<void> listen({
    required FutureOr<void> Function(T data) onData,
    Function? onStreamingError,
    void Function()? onDone,
    bool cancelOnError = false,
  });

  /// データをストリームに流す
  @mustCallSuper
  void add(T data);

  /// 購読開始時のエラー発生時の処理
  ///
  /// 必要に応じて派生クラスでオーバーライド
  @protected
  void onInitializationError(Object error, [StackTrace? stackTrace]);

  /// 購読をキャンセルする
  Future<void> cancel();

  /// 自身の破棄
  @mustCallSuper
  Future<void> dispose();

  /// 購読を一時停止
  void pause();

  /// 一時停止中の購読を再開
  void resume();
}

/// printメソッド [single_stream_handler_interface.dart]
void _print(String s1, [String? s2, String? s3, String? s4, String? s5]) {
  if (kDebugMode) {
    print("");
    print("[single_stream_handler_interface.dart]　" + s1);
    if (s2 != null) print("[single_stream_handler_interface.dart]　" + s2);
    if (s3 != null) print("[single_stream_handler_interface.dart]　" + s3);
    if (s4 != null) print("[single_stream_handler_interface.dart]　" + s4);
    if (s5 != null) print("[single_stream_handler_interface.dart]　" + s5);
    print("");
  }
}
