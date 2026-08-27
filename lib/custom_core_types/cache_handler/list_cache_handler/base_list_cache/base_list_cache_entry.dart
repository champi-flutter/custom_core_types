

abstract class BaseListCacheEntry<El> {
  List<El> value;

  BaseListCacheEntry(this.value);

  void onAccess();
}