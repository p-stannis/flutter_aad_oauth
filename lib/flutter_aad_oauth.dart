library flutter_aad_oauth;

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helper/auth_storage.dart';
import 'model/config.dart';
import 'model/token.dart';
import 'request_code.dart';
import 'request_token.dart';
import 'request_token_web.dart';

class FlutterAadOauth {
  static late Config _config;
  AuthStorage? _authStorage;
  Token? _token;
  late RequestCode _requestCode;
  late RequestTokenWeb _requestTokenWeb;
  late RequestToken _requestToken;
  late String tokenIdentifier;

  FlutterAadOauth(config, {this.tokenIdentifier = ''}) {
    FlutterAadOauth._config = config;
    _authStorage = _authStorage ?? AuthStorage(tokenIdentifier: tokenIdentifier);
    if (kIsWeb) {
      _requestTokenWeb = RequestTokenWeb(_config);
    } else {
      _requestCode = RequestCode(_config);
    }
    _requestToken = RequestToken(_config);
  }

  void setContext(BuildContext context) {
    _config.context = context;
    _requestToken.setContext(context);
    if (kIsWeb) {
      _requestTokenWeb.setContext(context);
    } else {
      _requestCode.setContext(context);
    }
  }

  Future<void> login() async {
    await _removeOldTokenOnFirstLogin();
    if (!Token.tokenIsValid(_token)) await _performAuthorization();
  }

  Future<String?> getAccessToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.accessToken;
  }

  Future<String?> getIdToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.idToken;
  }

  Future<String?> getRefreshToken() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.refreshToken;
  }

  Future<String?> getTokenType() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.tokenType;
  }

  Future<DateTime?> getIssueTimeStamp() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.issueTimeStamp;
  }

  Future<DateTime?> getExpireTimeStamp() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.expireTimeStamp;
  }

  Future<int?> getExpiresIn() async {
    if (!Token.tokenIsValid(_token)) await _performAuthorization();

    return _token?.expiresIn;
  }

  Future<bool> tokenIsValid({refreshIfNot = true}) async {
    _token ??= await _authStorage?.loadTokenToCache();
    if (Token.tokenIsValid(_token)) return true;
    if (refreshIfNot) {
      await _performRefreshAuthFlow();
      return Token.tokenIsValid(_token);
    } else {
      return false;
    }
  }

  Future<void> logout() async {
    await _authStorage?.clear();
    if (!kIsWeb) {
      await _requestCode.clearCookies();
    }
    _token = null;
    FlutterAadOauth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage?.loadTokenToCache();
    //still have refreh token / try to get new access token with refresh token
    if (_token?.refreshToken != null) {
      await _performRefreshAuthFlow();
    } else {
      try {
        await _performFullAuthFlow();
      } catch (e) {
        rethrow;
      }
    }

    //save token to cache
    await _authStorage!.saveTokenToCache(_token);
  }

  Future<void> _performFullAuthFlow() async {
    String? code;
    try {
      if (kIsWeb) {
        _token = await _requestTokenWeb.requestToken();
      } else {
        code = await _requestCode.requestCode();
        _token = await _requestToken.requestToken(code);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _performRefreshAuthFlow() async {
    if (_token?.refreshToken != null) {
      try {
        _token = await _requestToken.requestRefreshToken(_token!.refreshToken);
      } catch (e) {
        //do nothing (because later we try to do a full oauth code flow request)
      }
    } else {
      await _performFullAuthFlow();
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const _keyFreshInstall = 'freshInstall';
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      await logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
