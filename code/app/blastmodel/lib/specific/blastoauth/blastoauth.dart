import 'package:app_links/app_links.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

abstract class BlastOAuth {
  final appLinks = AppLinks();

  String? cachedCredentials;

  late String applicationId;
  late Uri authorizationEndpoint;
  late Uri tokenEndpoint;
  late Uri redirectUri;
  late Iterable<String> scopes;

  BlastOAuth initialize(
      {required String applicationId,
      required Uri authorizationEndpoint,
      required Uri tokenEndpoint,
      required Uri redirectUri,
      required Iterable<String> scopes}) {
    this.applicationId = applicationId;
    this.authorizationEndpoint = authorizationEndpoint;
    this.tokenEndpoint = tokenEndpoint;
    this.redirectUri = redirectUri;
    this.scopes = scopes;

    return this;
  }

  Future<oauth2.Client> createClient();

  Future<bool> logout();
  void dispose();
}
