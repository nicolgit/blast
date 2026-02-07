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
    if (cachedCredentials != null && cachedCredentials!.isNotEmpty) {
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

  bool canceling = false;
  Future<Uri> _listen(Uri url) async {
    Uri? responseUri;
    canceling = false;

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
    int counter = 0;
    while (responseUri == null && counter++ < timeout && !canceling) {
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("WEB waiting.... $counter of $timeout secs.");
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
    final url = Uri.parse(logoutUrl.replaceAll('REDIRECT_URI', redirectUri.toString()));

    await _redirect(url);
    return true;
  }

  @override
  void cancelAuthorization() {
    canceling = true;
  }
}

BlastOAuth getBlastAuth() => BlastOAuthWeb();
