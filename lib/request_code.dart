import 'dart:async';
import 'package:flutter/material.dart'
    show MaterialPageRoute, Navigator, SafeArea, Scaffold;
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'model/config.dart';
import 'request/authorization_request.dart';

class RequestCode {
  final StreamController<String?> _onCodeListener = new StreamController();
  final Config _config;
  late AuthorizationRequest _authorizationRequest;

  var _onCodeStream;

  RequestCode(Config config) : _config = config {
    _authorizationRequest = AuthorizationRequest(config);
  }

  Future<String?> requestCode() async {
    var code;
    final String urlParams = _constructUrlParams();
    if (_config.context != null) {
      String initialURL =
          ("${_authorizationRequest.url}?$urlParams").replaceAll(" ", "%20");

      await _mobileAuth(initialURL);
    } else {
      throw Exception("Context is null. Please call setContext(context).");
    }

    code = await _onCode.first;
    return code;
  }

  _mobileAuth(String initialURL) async {
    var webView = WebView(
      initialUrl: initialURL,
      javascriptMode: JavascriptMode.unrestricted,
      onPageFinished: (url) => _geturlData(url),
    );

    await Navigator.of(_config.context!).push(MaterialPageRoute(
        builder: (context) => Scaffold(body: SafeArea(child: webView))));
  }

  _geturlData(String _url) {
    var url = _url.replaceFirst('#', "?");
    Uri uri = Uri.parse(url);

    if (uri.queryParameters["error"] != null) {
      Navigator.of(_config.context!).pop();
      _onCodeListener
          .addError(new Exception("Access denied or authentation canceled."));
    }

    var token = uri.queryParameters["code"];
    if (token != null) {
      _onCodeListener.add(token);
      Navigator.of(_config.context!).pop();
    }
  }

  Future<void> clearCookies() async {
    CookieManager().clearCookies();
  }

  Stream<String?> get _onCode =>
      _onCodeStream ??= _onCodeListener.stream.asBroadcastStream();

  String _constructUrlParams() =>
      _mapToQueryParams(_authorizationRequest.parameters);

  String _mapToQueryParams(Map<String, String> params) {
    final queryParams = <String>[];
    params
        .forEach((String key, String value) => queryParams.add("$key=$value"));
    return queryParams.join("&");
  }

  void setContext(BuildContext context) {
    _config.context = context;
  }
}
