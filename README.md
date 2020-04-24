# Azure Active Directory OAuth

Forked from [Earlybyte.aad_oauth](https://github.com/Earlybyte/aad_oauth).

A Flutter OAuth package for performing user authentication against Azure Active Directory OAuth2 v2.0 endpoint. Forked from [hitherejoe.FlutterOAuth](https://github.com/hitherejoe/FlutterOAuth).

Supported Flows:
 - [Authorization code flow (including refresh token flow)](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-auth-code-flow)

## Usage

For using this library you have to create an azure app at the [Azure App registration portal](https://apps.dev.microsoft.com/). Use native app as platform type (with callback URL: https://login.live.com/oauth20_desktop.srf).

Afterwards you have to initialize the library as follow:

```dart
final Config config = new Config(
  "YOUR TENANT ID",
  "YOUR CLIENT ID",
  "openid profile offline_access",
  "your redirect url available in azure portal");
final AadOAuth oauth = new AadOAuth(config);
```

This allows you to pass in an tenant ID, client ID, scope and redirect url.

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

