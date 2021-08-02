library flutter_aad_oauth;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_aad_oauth/helper/auth_storage.dart';
import 'package:flutter_aad_oauth/model/config.dart';
import 'package:flutter_aad_oauth/model/token.dart';
import 'package:flutter_aad_oauth/request_code.dart';
import 'package:flutter_aad_oauth/request_token.dart';
import 'package:flutter_aad_oauth/request_token_web.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterAadOauth {
  static Config? _config;
  AuthStorage? _authStorage;
  Token? _token;
  late RequestCode _requestCode;
  late RequestTokenWeb _requestTokenWeb;
  late RequestToken _requestToken;

  factory FlutterAadOauth(config) {
    if (FlutterAadOauth._instance == null)
      FlutterAadOauth._instance = new FlutterAadOauth._internal(config);
    return _instance!;
  }

  static FlutterAadOauth? _instance;

  FlutterAadOauth._internal(config) {
    FlutterAadOauth._config = config;
    _authStorage = _authStorage ?? new AuthStorage();
    if (PlatformCheck.isWeb) {
      _requestTokenWeb = RequestTokenWeb(_config!);
    } else {
      _requestCode = new RequestCode(_config!);
    }
    _requestToken = new RequestToken(_config);
  }

  void setContext(BuildContext context) {
    _config!.context = context;
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
    if (_token == null) _token = await _authStorage?.loadTokenToCache();
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
    if (!PlatformCheck.isWeb) {
      await _requestCode.clearCookies();
    }
    _token = null;
    FlutterAadOauth(_config);
  }

  Future<void> _performAuthorization() async {
    // load token from cache
    _token = await _authStorage?.loadTokenToCache();
    //still have refreh token / try to get new access token with refresh token
    if (_token?.refreshToken != null)
      await _performRefreshAuthFlow();

    // if we have no refresh token try to perform full request code oauth flow
    else {
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
      if (PlatformCheck.isWeb) {
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
    }
  }

  Future<void> _removeOldTokenOnFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _keyFreshInstall = "freshInstall";
    if (!prefs.getKeys().contains(_keyFreshInstall)) {
      logout();
      await prefs.setBool(_keyFreshInstall, false);
    }
  }
}
