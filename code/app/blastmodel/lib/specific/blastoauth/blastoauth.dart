import 'package:app_links/app_links.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

abstract class BlastOAuth {
  final timeout = 30; // timeout in seconds for listening authentication response

  final appLinks = AppLinks();

  String? cachedCredentials;

  late String applicationId;
  late Uri authorizationEndpoint;
  late Uri tokenEndpoint;
  late Uri redirectUri;
  late Iterable<String> scopes;
  late String logoutUrl;

  BlastOAuth initialize(
      {required String applicationId,
      required Uri authorizationEndpoint,
      required Uri tokenEndpoint,
      required Uri redirectUri,
      required Iterable<String> scopes,
      required String logoutUrl}) {
    this.applicationId = applicationId;
    this.authorizationEndpoint = authorizationEndpoint;
    this.tokenEndpoint = tokenEndpoint;
    this.redirectUri = redirectUri;
    this.scopes = scopes;
    this.logoutUrl = logoutUrl;

    return this;
  }

  Future<oauth2.Client> createClient();

  void cancelAuthorization();

  Future<bool> logout();
  void dispose();
}
