import 'dart:async';

import 'package:flutter/material.dart'
    show MaterialPageRoute, Navigator, SafeArea, Scaffold;
import 'package:webview_flutter/webview_flutter.dart';

import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final StreamController<String?> _onCodeListener = new StreamController();
  final Config _config;
  late AuthorizationRequest _authorizationRequest;

  var _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = new AuthorizationRequest(config);
  }

  Future<String> requestCode() async {
    var code;
    final String urlParams = _constructUrlParams();

    if (_config.context != null) {
      var web = WebView(
        initialUrl: "${_authorizationRequest.url}?$urlParams",
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          Uri uri = Uri.parse(url);

          if (uri.queryParameters["error"] != null) {
            Navigator.of(_config.context!).pop();
            throw new Exception("Access denied or authentation canceled.");
          }

          if (uri.queryParameters["code"] != null) {
            Navigator.of(_config.context!).pop();
            _onCodeListener.add(uri.queryParameters["code"]);
          }
        },
      );

      await Navigator.of(_config.context!).push(MaterialPageRoute(
          builder: (context) => Scaffold(body: SafeArea(child: web))));
    } else {
      throw Exception("Context is null. Please call setContext(context).");
    }

    code = await _onCode.first;
    return code;
  }

  Future<void> clearCookies() async {
    CookieManager().clearCookies();
  }

  Stream<String> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }
}
