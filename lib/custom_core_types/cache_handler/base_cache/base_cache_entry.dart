

abstract class BaseCacheEntry<V> {
  V value;

  BaseCacheEntry(this.value);

  void onAccess();
}