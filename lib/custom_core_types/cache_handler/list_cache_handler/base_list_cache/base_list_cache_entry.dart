

abstract class BaseListCacheEntry<El> {
  List<El> value;

  // List<int> indexIdMap;

  BaseListCacheEntry(this.value);

  bool onAccess();
}

class Identified<El>{
  final int id;
  El element;

  Identified(this.element, {required this.id});
}