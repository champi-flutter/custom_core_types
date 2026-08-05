import 'dart:async';

/// 識別子付き [StreamSubscription]
class IdentifiableStreamSubscription<T> {
  /// この [StreamSubscription] の識別子（int）
  final int key;

  final StreamSubscription<T> _subscription;

  IdentifiableStreamSubscription({
    required this.key,
    required StreamSubscription<T> subscription,
  })  : _subscription = subscription;

  /// 一時停止
  void pause() {
      if (!_subscription.isPaused) {
        _subscription.pause();
      }

  }

  /// 再開
  void resume() {
      if (!_subscription.isPaused) {
        _subscription.resume();

    }
  }

  /// 破棄
  Future<void> cancel() async {
    await _subscription.cancel();
  }

  /// 現在一時停止中かどうか
  bool get isPaused => _subscription.isPaused;
}
