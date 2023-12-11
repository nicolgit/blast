
import 'package:blastmodel/blastattributetype.dart';

class BlastAttribute {
  BlastAttribute({BlastAttributeType type = BlastAttributeType.typeString}) {
    type = type;
  }

  String name = "";
  String value = "";
  late BlastAttributeType type;
}

