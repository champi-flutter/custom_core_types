import 'dart:async';

import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/custom_stream/stream_handler/single_stream_handler/implementation/single_stream_handler_base_implementation.dart';
import 'package:custom_core_types/custom_core_types/custom_stream/stream_handler/single_stream_handler/implementation/single_stream_handler_implementation_with_initial_loading.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_wrapper/riverpod_wrapper.dart';

/// 最初のデータの受信を待つ機能を実装する、[SingleStreamHandlerInterface] の具象クラス
///
/// **【使い方】**
///  1. アプリのコアの層に、[SingleStreamHandlerInterface] を継承した、
///  ストリームハンドラのインターフェースを設置する。
///  2. アプリのインフラ層に、このクラスを継承した、ストリームハンドラの具象クラスを設置する。
///
///
/// 最初のデータを受信するまでローディングを表示する。\
/// 以下のようにアプリの全画面を [LoadingWrapper] でラップすること。
///
/// ```
/// MaterialApp(
///   home: LoadingWrapper(child: Home()),
/// )
/// ```
abstract class SingleStreamHandlerImplementationWithInitialLoading<T>
    extends SingleStreamHandlerBaseImplementation<T>{
  @visibleForOverriding
  LoadingService get loadingService;

  /// ストリームを購読する
  @override
  Future<void> listen({
    required void Function(T data) onData,
    Function? onStreamingError,
    void Function()? onDone,
    bool cancelOnError = false,
  })
  // 折りたたみ用
  => loadingService.loadAsync(() async {
    try {
      // 既存の購読があれば二重破棄を防ぐため一旦キャンセル
      await cancel();
      // 受信を待つフラグ
      final Completer<void> completer = Completer<void>();
      subscription = stream.listen(
            (data) {
          // 最初のデータを受信したフラグを立てる
          if (!completer.isCompleted) {
            completer.complete();
          }
          onData(data);
        },
        onError: (Object error, StackTrace st) {
          if (!completer.isCompleted) {
            completer.completeError(error, st);
          }
          onStreamingError?.call(error, st);
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
          onDone?.call();
        },
        cancelOnError: cancelOnError,
      );
      // フラグが立つまでローディングを表示
      await completer.future;
    } catch (e, st) {
      subscription = null;
      onInitializationError(e, st);
    }
  });
}
