

import 'dart:async';

/// TTL キャッシュの有効期限のタイマー
class ExpirationTimer {
  /// 有効期限
  final int timeToLive;

  /// 有効期限切れ時のコールバック
  final void Function() onExpired;

  Timer? _timer;

  // todo コンストラクタ
  ExpirationTimer(this.timeToLive, this.onExpired){
    _start();
  }

  /// 有効期限タイマーを開始する
  void _start() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: timeToLive), onExpired);
  }

  /// 有効期限をスライドする
  void slide() {
    _start();
  }

  /// 完全に停止する
  void cancel() {
    _timer?.cancel();
  }

  /// 現在タイマーが動いているかどうか
  bool get isActive => _timer?.isActive ?? false;
}