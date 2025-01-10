import 'blastoauth.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:universal_html/html.dart' as html;

html.WindowBase? _popupWin;

class BlastOAuthWeb extends BlastOAuth {
  @override
  void dispose() {}

  @override
  Future<oauth2.Client> createClient() async {
    if (cachedCredentials != null) {
      var credentials = oauth2.Credentials.fromJson(cachedCredentials!);
      return oauth2.Client(credentials, identifier: applicationId);
    }

    var grant = oauth2.AuthorizationCodeGrant(applicationId, authorizationEndpoint, tokenEndpoint);
    var authorizationUrl = grant.getAuthorizationUrl(redirectUri, scopes: scopes);

    await _redirect(authorizationUrl);
    var responseUrl = await _listen(redirectUri);
    var client = await grant.handleAuthorizationResponse(responseUrl.queryParameters);
    cachedCredentials = client.credentials.toJson();
    return client;
  }

  Future<void> _redirect(Uri url) async {
    _popupWin = html.window.open(url.toString(), "blast Auth", "width=800, height=900, scrollbars=yes");
  }

  Future<Uri> _listen(Uri url) async {
    Uri? responseUri;

    //print("_listen URI: $url");
    html.window.onMessage.listen((event) async {
      //print("received EVENT: data:${event.data}");

      if (event.data.toString().startsWith(redirectUri.toString())) {
        responseUri = Uri.tryParse(event.data.toString());

        if (_popupWin != null) {
          _popupWin!.close();
          _popupWin = null;
        }
      }
    });

    //wait for authentication, max 20 seconds
    int counter = 0, timeout = 20;
    while (responseUri == null && counter++ < timeout) {
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("WEB waiting.... $counter of $timeout");
      }
    }

    if (responseUri == null) {
      throw BlastAuthenticationFailedException();
    }

    return responseUri!;
  }

  @override
  Future<bool> logout() async {
    cachedCredentials = null;
    final logoffUrl = Uri.parse(
        'https://login.microsoftonline.com/common/oauth2/v2.0/logout?post_logout_redirect_uri=${redirectUri.toString()}');

    await _redirect(logoffUrl);
    //var responseUrl = await _listen(redirectUri);

    return true;
  }
}

BlastOAuth getBlastAuth() => BlastOAuthWeb();
