import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jps_chess/data/database_data.dart' as datas;
import 'package:jps_chess/widgets/game_over_overlay.dart';

class DisconnectionOverlay extends StatelessWidget {
  final int nPlayers;

  const DisconnectionOverlay({Key key, this.nPlayers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool areBothPlayersPresent = nPlayers == 2;
    return areBothPlayersPresent
        ? Container()
        : GameOverOverlay(
            strMessage: 'Game over:\n\nOther player disconnected...',
            colorMessage: Colors.deepOrangeAccent,
          );
  }
}

void reduceServerNPlayers(
    DatabaseReference databaseReference, int nPlayers, String strServerName) {
  nPlayers--;
  databaseReference
      .child(datas.strGameData)
      .child(strServerName)
      .child(datas.strKey1VarGlobal)
      .update({datas.strKey2NPlayers: nPlayers});
}
