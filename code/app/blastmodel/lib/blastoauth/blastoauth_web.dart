import 'package:blastmodel/blastoauth/blastoauth.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

class BlastOAuthWeb extends BlastOAuth {
  @override
  void dispose() {
    
  }

  @override
  Future<oauth2.Client> createClient() {
    // TODO: implement createClient
    throw UnimplementedError();
  }
  
}

BlastOAuth getBlastAuth() => BlastOAuthWeb();