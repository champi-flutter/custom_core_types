import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

/// 1つの [StreamSubscription] を扱うハンドラクラス
abstract class SingleStreamHandler<T> {
  @nonVirtual
  @protected
  StreamSubscription<T>? subscription;

  /// コントローラ
  final StreamController<T> _controller = BehaviorSubject<T>();

  /// ストリーム
  Stream<T> get stream => _controller.stream;

  /// ストリームを購読する
  Future<void> listen({
    required void Function(T data) onData,
    Function? onStreamingError,
    void Function()? onDone,
    bool cancelOnError = false,
  })
  // 折りたたみ用
  async {
    try {
      // 既存の購読があれば二重破棄を防ぐため一旦キャンセル
      await cancel();

      subscription = stream.listen(
        onData,
        onError: onStreamingError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } catch (e, st) {
      subscription = null;
      onInitializationError(e, st);
    }
  }

  /// データをストリームに流す
  @mustCallSuper
  void add(T data) {
    _controller.add(data);
  }

  /// 購読開始時のエラー発生時の処理
  ///
  /// 必要に応じて派生クラスでオーバーライド
  @protected
  void onInitializationError(Object error, [StackTrace? stackTrace]) {
    final st = stackTrace ?? StackTrace.current;
    _print("[$runtimeType] Error: $error\n$st");
  }

  /// 購読をキャンセルする
  Future<void> cancel() async {
    await subscription?.cancel();
    subscription = null;
  }

  /// 自身の破棄
  @mustCallSuper
  Future<void> dispose() async {
    await cancel();
    await _controller.close();
  }

  /// 購読を一時停止
  void pause() {
    if (subscription != null) {
      if (!subscription!.isPaused) {
        subscription!.pause();
      }
    }
  }

  /// 一時停止中の購読を再開
  void resume() {
    if (subscription != null) {
      if (subscription!.isPaused) {
        subscription!.resume();
      }
    }
  }
}

/// printメソッド [single_stream_handler.dart]
void _print(String s1, [String? s2, String? s3, String? s4, String? s5]) {
  if (kDebugMode) {
    print("");
    print("[single_stream_handler.dart]　" + s1);
    if (s2 != null) print("[single_stream_handler.dart]　" + s2);
    if (s3 != null) print("[single_stream_handler.dart]　" + s3);
    if (s4 != null) print("[single_stream_handler.dart]　" + s4);
    if (s5 != null) print("[single_stream_handler.dart]　" + s5);
    print("");
  }
}
