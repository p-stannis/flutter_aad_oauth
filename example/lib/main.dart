// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_aad_oauth/flutter_aad_oauth.dart';
import 'package:flutter_aad_oauth/model/config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AAD OAuth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'AAD OAuth Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String TENANT_ID = 'YOUR_TENANT_ID';
  static const String CLIENT_ID = 'YOUR_CLIENT_ID';

  late Config config;
  late FlutterAadOauth oauth = FlutterAadOauth(config);

  @override
  initState() {
    Object redirectUri;
    late String scope;
    late String responseType;

    if (kIsWeb) {
      scope = 'openid profile email offline_access user.read';
      responseType = 'id_token+token';
      final currentUri = Uri.base;
      redirectUri = Uri(
        host: currentUri.host,
        scheme: currentUri.scheme,
        port: currentUri.port,
        path: '/authRedirect.html',
      );
    } else {
      scope = 'openid profile offline_access';
      responseType = 'code';
      redirectUri = 'https://login.live.com/oauth20_desktop.srf';
    }

    config = Config(
        azureTenantId: TENANT_ID,
        clientId: CLIENT_ID,
        scope: scope,
        redirectUri: '$redirectUri',
        responseType: responseType);

    oauth = FlutterAadOauth(config);
    oauth.setContext(context);
    checkIsLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'AzureAD OAuth',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.launch),
            title: const Text('Login'),
            onTap: () {
              login();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Logout'),
            onTap: () {
              logout();
            },
          ),
        ],
      ),
    );
  }

  void showError(dynamic ex) {
    showMessage(ex.toString());
  }

  void showMessage(String text) {
    var alert = AlertDialog(content: Text(text), actions: <Widget>[
      ElevatedButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void checkIsLogged() async {
    if (await oauth.tokenIsValid()) {
      String? accessToken = await oauth.getAccessToken();
      showMessage('Access token: $accessToken');
    }
  }

  void login() async {
    try {
      await oauth.login();
      String? accessToken = await oauth.getAccessToken();
      showMessage('Logged in successfully, your access token: $accessToken');
    } catch (e) {
      showError(e);
    }
  }

  void logout() async {
    await oauth.logout();
    showMessage('Logged out');
  }
}
