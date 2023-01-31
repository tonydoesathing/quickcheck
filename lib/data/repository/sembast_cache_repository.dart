import 'package:quickcheck/data/provider/sembast_provider.dart';
import 'package:quickcheck/data/repository/cache_repository.dart';
import 'package:sembast/sembast.dart';

class SembastCacheRepository implements CacheRepository {
  final _cacheStore = stringMapStoreFactory.store("cache");

  @override
  Future<Object?> getRecord(String key) async {
    final record =
        await _cacheStore.record(key).get(await SembastProvider().database);
    return record?[key];
  }

  @override
  Future<void> putRecord(String key, Object? object) async {
    final Map<String, Object?> record = {key: object};
    await _cacheStore.record(key).put(await SembastProvider().database, record);
  }
}
