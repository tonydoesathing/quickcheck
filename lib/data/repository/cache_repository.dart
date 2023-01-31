/// Provides a cache mechanism
abstract class CacheRepository {
  /// checks to see if cache contains the [key]; returns value if yes, null if no
  Future<Object?> getRecord(String key);

  /// puts an [object] at the specified [key]
  Future<void> putRecord(String key, Object? object);
}
