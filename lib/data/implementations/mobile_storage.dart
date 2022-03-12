import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../i_storage.dart';

class MobileStorage extends IStorage {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<String?> read({required String key}) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }
}
