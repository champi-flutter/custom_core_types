

abstract class BaseCacheEntry<V> {
  V value;

  BaseCacheEntry(this.value);

  bool onAccess();
}