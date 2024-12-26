import 'blastoauth.dart';
import 'package:blastmodel/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class BlastOAuthMobile extends BlastOAuth {
  @override
  void dispose() {}

  @override
  Future<oauth2.Client> createClient() async {
    if (cachedCredentials != null) {
      var credentials = oauth2.Credentials.fromJson(cachedCredentials!);
      return oauth2.Client(credentials, identifier: applicationId);
    }

    var grant = oauth2.AuthorizationCodeGrant(applicationId, authorizationEndpoint, tokenEndpoint);

    // A URL on the authorization server (authorizationEndpoint with some
    // additional query parameters). Scopes and state can optionally be passed
    // into this method.
    var authorizationUrl = grant.getAuthorizationUrl(redirectUri, scopes: scopes);

    // Redirect the resource owner to the authorization URL. Once the resource
    // owner has authorized, they'll be redirected to `redirectUrl` with an
    // authorization code. The `redirect` should cause the browser to redirect to
    // another URL which should also have a listener.
    //
    // `redirect` and `listen` are not shown implemented here.
    await _redirect(authorizationUrl);
    var responseUrl = await _listen(redirectUri);

    // Once the user is redirected to `redirectUrl`, pass the query parameters to
    // the AuthorizationCodeGrant. It will validate them and extract the
    // authorization code to create a new Client.
    var client = await grant.handleAuthorizationResponse(responseUrl.queryParameters);

    cachedCredentials = client.credentials.toJson();

    return client;
  }

  Future<void> _redirect(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<Uri> _listen(Uri url) async {
    Uri? responseUri;

    appLinks.uriLinkStream.listen((uri) async {
      if (uri.toString().startsWith(redirectUri.toString())) {
        responseUri = uri;
      }
    });

    //wait for authentication, max 15 seconds
    int counter = 0, timeout = 15;
    while (responseUri == null && counter++ < timeout) {
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("waiting.... $counter of $timeout");
      }
    }

    if (responseUri == null) {
      throw BlastAuthenticationFailedException();
    }

    return responseUri!;
  }
}

BlastOAuth getBlastAuth() => BlastOAuthMobile();
