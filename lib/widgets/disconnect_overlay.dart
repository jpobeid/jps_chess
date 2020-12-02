import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jps_chess/data/database_data.dart' as datas;

class DisconnectionOverlay extends StatelessWidget {
  final int nPlayers;

  const DisconnectionOverlay({Key key, this.nPlayers})
      : super(key: key);

  static const double sizeBorderRadius = 20;
  static const double fractionWidthMessage = 0.75;
  static const double fractionHeightMessage = 0.35;
  static const Color colorFade = Color.fromARGB(135, 50, 50, 50);

  @override
  Widget build(BuildContext context) {
    bool areBothPlayersPresent = nPlayers == 2;
    return areBothPlayersPresent
        ? Container()
        : Container(
          child: AbsorbPointer(
              child: Container(
                color: colorFade,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.circular(sizeBorderRadius),
                        ),
                        width: constraints.maxWidth * fractionWidthMessage,
                        height: constraints.maxHeight * fractionHeightMessage,
                        child: Material(
                          color: Colors.deepOrangeAccent,
                          child: Text(
                            'Game over:\n\nOther player disconnected...',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    );
                  },
                ),
              ),
            ),
        );
  }
}

void reduceServerNPlayers(DatabaseReference databaseReference, int nPlayers, String strServerName) {
  nPlayers--;
  databaseReference
      .child(datas.strGameData)
      .child(strServerName)
      .child(datas.strKey1VarGlobal)
      .update({datas.strKey2NPlayers: nPlayers});
}