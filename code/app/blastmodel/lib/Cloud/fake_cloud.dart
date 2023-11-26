import 'package:blastmodel/Cloud/cloud.dart';

class FakeCloud extends Cloud {
  @override
  String get name => 'Fake Cloud - for testing purposes only';

  @override
  set test(String value) {}
  
  @override
  void testMethod() {
    // TODO: implement testMethod
  }
}