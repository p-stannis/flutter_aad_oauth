import 'dart:async';

import 'package:flutter/material.dart'
    show MaterialPageRoute, Navigator, SafeArea;
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final StreamController<String?> _onCodeListener = StreamController();
  final Config _config;
  late AuthorizationRequest _authorizationRequest;

  Stream<String?>? _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = AuthorizationRequest(config);
  }

  Future<String?> requestCode() async {
    String? code;
    final String urlParams = _constructUrlParams();
    if (_config.context != null) {
      String initialURL =
          ('${_authorizationRequest.url}?$urlParams').replaceAll(' ', '%20');

      await _mobileAuth(initialURL);
    } else {
      throw Exception('Context is null. Please call setContext(context).');
    }

    code = await _onCode.first;
    return code;
  }

  _mobileAuth(String initialURL) async {
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView(); // webview_flutter: ^3.0.0 BREAKING CHANGE Not necessary

    var webView = WebView(
      initialUrl: initialURL,
      javascriptMode: JavascriptMode.unrestricted,
      onPageStarted: (url) => _handlePageStartData(url),
      onPageFinished: (url) => _getUrlData(url),
    );

    await Navigator.of(_config.context!).push(
      MaterialPageRoute(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            _onCodeListener.add('');
            return true;
          },
          child: SafeArea(child: webView),
        ),
      ),
    );
  }

  _getUrlData(String _url) {
    var url = _url.replaceFirst('#', '?');
    Uri uri = Uri.parse(url);

    if (uri.queryParameters['error'] != null) {
      if (Navigator.of(_config.context!).canPop()) {
        Navigator.of(_config.context!).pop();
      }
      _onCodeListener
          .addError(Exception('Access denied or authentication canceled.'));
    }

    var token = uri.queryParameters['code'];
    if (token != null) {
      _onCodeListener.add(token);
      if (Navigator.of(_config.context!).canPop()) {
        Navigator.of(_config.context!).pop();
      }
    }
  }

  Future<void> clearCookies() async {
    await CookieManager().clearCookies();
  }

  Stream<String?> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add('$key=$value'));
    return queryParams.join('&');
  }

  void setContext(BuildContext context) {
    _config.context = context;
  }

  _handlePageStartData(String url) {
    // early redirect to fetch the code from the url without
    // waiting for the the full page load
    if(url.contains(_config.redirectUri)) {
      _getUrlData(url);
    }
  }
}
