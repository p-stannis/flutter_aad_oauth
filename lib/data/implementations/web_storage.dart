import 'package:universal_html/html.dart';

import '../i_storage.dart';

class WebStorage extends IStorage {
  @override
  Future<void> delete({required String key}) async {
    window.localStorage.remove(key);
  }

  @override
  Future<String?> read({required String key}) async {
    return window.localStorage[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    window.localStorage[key] = value;
  }
}
