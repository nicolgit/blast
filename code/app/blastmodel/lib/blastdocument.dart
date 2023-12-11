import 'package:blastmodel/blastcard.dart';
import 'package:uuid/uuid.dart';

class BlastDocument {
  BlastDocument(); /* {
    Id = const Uuid().v4();
    Version = 10;
    Cards = List<BlastCard>.empty(growable: true);

    var card1 = BlastCard();
    card1.Title = "lorem ipsut dixit";

    var card2 = BlastCard();
    card2.Title = "consectetur adipiscing elit";

    Cards.add(card1);
    Cards.add(card2);
  }*/

  String id = const Uuid().v4();
  int Version = 1;
  List<BlastCard> Cards = List<BlastCard>.empty(growable: true);
}
