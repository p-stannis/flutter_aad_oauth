import 'package:flutter_aad_oauth/flutter_aad_oauth.dart';
import 'package:flutter_aad_oauth/model/config.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/external/platform_check/platform_check.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'AAD OAuth Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'AAD OAuth Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //TODO remover
  static const String TENANT_ID = "YOUR_TENANT_ID";
  static const String CLIENT_ID = "YOUR_CLIENT_ID";

  late Config config;
  late FlutterAadOauth oauth = FlutterAadOauth(config);

  @override
  initState() {
    var redirectUri;
    late String scope;
    late String responseType;

    if (PlatformCheck.isWeb) {
      scope = "openid profile email offline_access user.read";
      responseType = "id_token+token";
      final currentUri = Uri.base;
      redirectUri = Uri(
        host: currentUri.host,
        scheme: currentUri.scheme,
        port: currentUri.port,
        path: '/authRedirect.html',
      );
    } else {
      scope = "openid profile offline_access";
      responseType = "code";
      redirectUri = "https://login.live.com/oauth20_desktop.srf";
    }

    config = new Config(
        azureTennantId: TENANT_ID,
        clientId: CLIENT_ID,
        scope: scope,
        redirectUri: "$redirectUri",
        responseType: responseType);

    oauth = FlutterAadOauth(config);
    oauth.setContext(context);
    checkIsLogged();
    super.initState();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title!),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              "AzureAD OAuth",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          ListTile(
            leading: Icon(Icons.launch),
            title: Text('Login'),
            onTap: () {
              login();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Logout'),
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
    var alert = new AlertDialog(content: new Text(text), actions: <Widget>[
      new ElevatedButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          })
    ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  void checkIsLogged() async {
    if (await oauth.tokenIsValid()) {
      String? accessToken = await oauth.getAccessToken();
      showMessage("Access token: $accessToken");
    }
  }

  void login() async {
    try {
      await oauth.login();
      String? accessToken = await oauth.getAccessToken();
      showMessage("Logged in successfully, your access token: $accessToken");
    } catch (e) {
      showError(e);
    }
  }

  void logout() async {
    await oauth.logout();
    showMessage("Logged out");
  }
}
