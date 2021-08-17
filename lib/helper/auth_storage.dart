import 'dart:async';
import 'package:flutter_aad_oauth/data/i_storage.dart';
import 'package:flutter_aad_oauth/data/implementations/mobile_storage.dart';
import 'package:flutter_aad_oauth/data/implementations/web_storage.dart';
import 'package:flutter_aad_oauth/model/token.dart';
import "dart:convert" as Convert;
import 'package:keyboard_actions/external/platform_check/platform_check.dart';

class AuthStorage {
  static AuthStorage shared = new AuthStorage();
  late IStorage _storage;
  late String _identifier = "Token";
  AuthStorage({String tokenIdentifier = ""}) {
    _identifier += tokenIdentifier;
    if (PlatformCheck.isWeb) {
      _storage = WebStorage();
    } else {
      _storage = MobileStorage();
    }
  }
  Future<void> saveTokenToCache(Token? token) async {
    var data = Token.toJsonMap(token);
    var json = Convert.jsonEncode(data);
    await _storage.write(key: _identifier, value: json);
  }

  Future<T?> loadTokenToCache<T extends Token>() async {
    var json = await _storage.read(key: _identifier);
    if (json == null) return null;
    try {
      var data = Convert.jsonDecode(json);
      return _getTokenFromMap<T>(data) as FutureOr<T?>;
    } catch (exception) {
      return null;
    }
  }

  Token _getTokenFromMap<T extends Token>(Map<String, dynamic>? data) =>
      Token.fromJson(data);

  Future clear() async {
    _storage.delete(key: _identifier);
  }
}
