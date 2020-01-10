import 'package:flutter_aad_oauth/flutter_aad_oauth.dart';
import 'package:flutter_aad_oauth/model/config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds one to input values', () {
    final Config config = new Config("YOUR TENANT ID", "YOUR CLIENT ID",
        "openid profile offline_access", "redirectUri");
    final FlutterAadOauth oauth = new FlutterAadOauth(config);
    oauth.toString();
  });
}
