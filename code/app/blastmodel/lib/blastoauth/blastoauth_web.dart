import 'package:blastmodel/blastoauth/blastoauth.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'dart:html' as html;

html.WindowBase? _popupWin;

class BlastOAuthWeb extends BlastOAuth {
  @override
  void dispose() {
    
  }

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

    html.window.onMessage.listen((event) async {
      if (event.data.toString().startsWith(redirectUri.toString())) {
        responseUri = Uri.tryParse(event.data.toString());
      }

      if (_popupWin != null) {
        _popupWin!.close();
        _popupWin = null;
      }
    });

    //wait for authentication, max 30 seconds
    int counter = 0, timeout = 30;
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
}

BlastOAuth getBlastAuth() => BlastOAuthWeb();