# Azure Active Directory OAuth

Forked from [Earlybyte.aad_oauth](https://github.com/Earlybyte/aad_oauth).

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:
 - [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Afterwards you have to initialize the library as follow:

```dart
final Config config = Config(
        azureTennantId: "$TENANT_ID",
        clientId: "$CLIENT_ID",
        scope: "$scope",
        redirectUri: "$redirectUri",
        responseType: "$responseType");
final AadOAuth oauth = AadOAuth(config);
```
This allows you to pass in an tenant ID, client ID, scope and redirect url.
### Two important things:
1. ResponseType for mobile is usually "code", and web is usually "id_token + token";
2. Redirect URI to Flutter Web is explained below.
3. `nonce` is an optional parm to Web flow


Then once you have an OAuth instance, you can call `login()` and afterwards `getAccessToken()` or `getIdToken()` or the `getRefreshToken()` to retrieve an access token or the id token or the refresh token:

```dart
await oauth.login();
String accessToken = await oauth.getAccessToken();
String idToken = await oauth.getIdToken();
String refreshToken = await oauth.getRefreshToken();
String tokenType = await oauth.getTokenType();
DateTime issueTimeStamp = await oauth.getIssueTimeStamp();
DateTime refreshToken = await oauth.getExpireTimeStamp();
int refreshToken = await oauth.getExpiresIn();
```

You can also call `getAccessToken()` directly. It will automatically login and retrieve an access token.
You can also call `getIdToken()` directly. It will automatically login and retrieve an id token.
You can also call `getRefreshToken()` directly. It will automatically login and retrieve a refresh token.
You can also call `getTokenType()` directly. It will retrieve the token type.
You can also call `getIssueTimeStamp()` directly. It retrieve the Issue Time Stamp.
You can also call `getExpireTimeStamp()` directly. It retrieve the Expire Time Stamp.
You can also call `getExpiresIn()` directly. It retrieve the value of when the token expires in.

Tokens are stored in Keychain for iOS or Keystore for Android. To destroy the tokens you can call `logout()`:

```dart
await oauth.logout();
```

## Flutter Web

There are a few steps to make the authentication flow in Flutter Web:
1.  Your project must have a web folder at the root of the directory (Flutter 2.0);
2.  Inside this folder it is necessary to create the file `authRedirect.html`, to be the redirect page, when requesting the token. This html file needs to have a script with the post method, like this:
```HTML
<script>
    window.opener.postMessage(window.location.href, '*');
</script>
```
3. The redirect URL must be previously registered in Azure, so the application must always run on the same port. To do this just use the `--web-port=3000` flag in `flutter run`, or add the `args` to the launch.json file (VsCode) as shown below
```json
"args": ["--web-port", "3000"],
```
4. In the repository of this package, there is an example folder, with a flutter project that uses this lib with mobile and web authentication.

### Example To Get Redirect URI 
```dart
final currentUri = Uri.base;
redirectUri = Uri(
  host: currentUri.host,
  scheme: currentUri.scheme,
  port: currentUri.port,
  path: '/authRedirect.html',
);
```

Flutter Web support was based on this [article](https://itnext.io/flutter-web-oauth-authentication-through-external-window-d890a7ff6463)
