class CacheManager {
  final Map<String, CacheItem> _cache = {};

  void put(String key, dynamic data, {Duration? ttl}) {
    final expiry = ttl != null ? DateTime.now().add(ttl) : null;
    _cache[key] = CacheItem(data: data, expiry: expiry);
  }

  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (item.expiry != null && DateTime.now().isAfter(item.expiry!)) {
      _cache.remove(key);
      return null;
    }

    return item.data as T?;
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }

  bool containsKey(String key) {
    final item = _cache[key];
    if (item == null) return false;

    if (item.expiry != null && DateTime.now().isAfter(item.expiry!)) {
      _cache.remove(key);
      return false;
    }

    return true;
  }

  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere(
        (key, item) => item.expiry != null && now.isAfter(item.expiry!));
  }
}

class CacheItem {
  final dynamic data;
  final DateTime? expiry;

  CacheItem({required this.data, this.expiry});
}
