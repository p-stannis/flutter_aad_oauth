import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'model/config.dart';
import 'model/token.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';

class RequestToken {
  late final Config _config;
  late TokenRequestDetails _tokenRequest;
  late TokenRefreshRequestDetails _tokenRefreshRequest;

  RequestToken(this._config);

  Future<Token> requestToken(String? code) async {
    _generateTokenRequest(code);
    return await _sendTokenRequest(_tokenRequest.url!, _tokenRequest.params, _tokenRequest.headers);
  }

  Future<Token> requestRefreshToken(String? refreshToken) async {
    _generateTokenRefreshRequest(refreshToken);
    return await _sendTokenRequest(
        _tokenRefreshRequest.url!, _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
  }

  Future<Token> _sendTokenRequest(String url, Map<String, String?>? params, Map<String, String>? headers) async {
    Response response = await post(Uri.parse(url), body: params, headers: headers);
    Map<String, dynamic>? tokenJson = json.decode(response.body);
    Token token = Token.fromJson(tokenJson);
    return token;
  }

  void _generateTokenRequest(String? code) {
    _tokenRequest = TokenRequestDetails(_config, code);
  }

  void _generateTokenRefreshRequest(String? refreshToken) {
    _tokenRefreshRequest = TokenRefreshRequestDetails(_config, refreshToken);
  }

  void setContext(BuildContext context) {
    _config.context = context;
  }
}
