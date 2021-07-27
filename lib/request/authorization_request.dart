import 'package:flutter_aad_oauth/model/config.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';

class AuthorizationRequest {
  String? url;
  String? redirectUrl;
  late Map<String, String> parameters;
  Map<String, String>? headers;
  bool? fullScreen;
  bool? clearCookies;

  AuthorizationRequest(Config config,
      {bool fullScreen: true, bool clearCookies: false}) {
    this.url = config.authorizationUrl;
    this.redirectUrl = config.redirectUri;
    this.parameters = {
      "client_id": config.clientId,
      "response_type": config.responseType,
      "redirect_uri": config.redirectUri,
      "scope": config.scope
    };
    if (PlatformCheck.isWeb) {
      this.parameters.addAll({"nonce": config.nonce});
    }
    this.fullScreen = fullScreen;
    this.clearCookies = clearCookies;
  }
}
