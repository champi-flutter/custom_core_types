
class FifoSequenceCounter {

  FifoSequenceCounter(): _last = 0;

  /// 順番の最後尾
  int _last;

  /// 順番の最後尾
  int get last => _last;

  int get next => _last +1;

  void add(){
    _last ++;
  }
}