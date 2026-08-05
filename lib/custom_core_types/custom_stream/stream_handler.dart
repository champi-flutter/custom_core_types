import 'dart:async';

import 'package:flutter/foundation.dart';

/// 1つの [StreamSubscription] を扱うハンドラクラス
abstract class SingleStreamHandler<T> {
  StreamSubscription<T>? _subscription;

  /// ストリームを購読
  Future<void> listenTo(
    Stream<T> stream, {
    bool cancelOnError = false,
  })
  // 折りたたみ用
  async {
    try {
      // 既存の購読があれば二重破棄を防ぐため一旦キャンセル
      await cancel();

      _subscription = stream.listen(
        onData,
        onError: onStreamingError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } catch (e, st) {
      _subscription = null;
      onInitializationError(e, st);
    }
  }

  /// データ受信時の処理（派生クラスで必ず実装する）
  @protected
  void onData(T data);

  /// 購読中のエラー発生時の処理
  ///
  /// 必要に応じて派生クラスでオーバーライド）
  @protected
  void onStreamingError(Object error, [StackTrace? stackTrace]) {
    final st = stackTrace ?? StackTrace.current;
    _print("[$runtimeType] Error: $error\n$st");
  }

  /// 購読開始時のエラー発生時の処理
  ///
  /// 必要に応じて派生クラスでオーバーライド）
  @protected
  void onInitializationError(Object error, [StackTrace? stackTrace]) {
    final st = stackTrace ?? StackTrace.current;
    _print("[$runtimeType] Error: $error\n$st");
  }

  /// Stream 終了時の処理
  ///
  /// 必要に応じて派生クラスでオーバーライド
  @protected
  void onDone() {}

  /// 購読をキャンセルする
  Future<void> cancel() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// 自身の破棄
  @mustCallSuper
  Future<void> dispose() async {
    await cancel();
  }

  /// 購読を一時停止
  void pause() {
    if (_subscription != null) {
      if (!_subscription!.isPaused) {
        _subscription!.pause();
      }
    }
  }

  /// 一時停止中の購読を再開
  void resume() {
    if (_subscription != null) {
      if (_subscription!.isPaused) {
        _subscription!.resume();
      }
    }
  }
}

/// printメソッド [stream_handler.dart]
void _print(String s1, [String? s2, String? s3, String? s4, String? s5]) {
  if (kDebugMode) {
    print("");
    print("[stream_handler.dart]　" + s1);
    if (s2 != null) print("[stream_handler.dart]　" + s2);
    if (s3 != null) print("[stream_handler.dart]　" + s3);
    if (s4 != null) print("[stream_handler.dart]　" + s4);
    if (s5 != null) print("[stream_handler.dart]　" + s5);
    print("");
  }
}
