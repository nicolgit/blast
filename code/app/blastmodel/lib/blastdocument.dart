import 'package:blastmodel/blastcard.dart';
import 'package:uuid/uuid.dart';

class BlastDocument {
  BlastDocument(); 

  String id = const Uuid().v4();
  int version = 1;

  List<BlastCard> cards = List<BlastCard>.empty(growable: true);
}
