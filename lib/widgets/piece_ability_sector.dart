import 'package:flutter/material.dart';
import 'package:jps_chess/data/pieces_data.dart' as pieces;

class PieceAbilitySector extends StatelessWidget {
  final String strPieceName;
  final Map<String, int> mapPieceAbilityActive;
  final Function pieceAbilityOnPressed;

  const PieceAbilitySector(
      {Key key,
      this.strPieceName,
      this.mapPieceAbilityActive,
      this.pieceAbilityOnPressed})
      : super(key: key);

  static const List<int> listFlexRow = [3, 5];
  static const List<int> listFlexColumn1 = [1, 4];
  static const TextStyle styleSub1 = TextStyle(
      color: Colors.white, fontWeight: FontWeight.normal, fontSize: 24);
  static const TextStyle styleSub2 = TextStyle(
      color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20);
  static const Color colorSingleUse = Colors.amber;
  static const Color colorContinuous = Colors.grey;
  static const Color colorActive = Colors.red;

  @override
  Widget build(BuildContext context) {
    if (strPieceName != null) {
      return Container(
        child: Row(
          children: [
            Expanded(
              flex: listFlexRow[0],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: listFlexColumn1[1],
                    child: ClipOval(
                      child: Image(
                        image: AssetImage(
                          'assets/$strPieceName.png',
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: listFlexColumn1[0],
                    child: Text(
                      pieces.mapName[strPieceName],
                      style: styleSub1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: listFlexRow[1],
              child: ListView.builder(
                  itemCount: pieces.mapAbilityName[strPieceName].length,
                  itemBuilder: (context, index) {
                    bool isPieceAbilityActive =
                        mapPieceAbilityActive.isNotEmpty;
                    bool isSpecificPieceAbilityActive = isPieceAbilityActive &&
                        strPieceName == mapPieceAbilityActive.keys.first &&
                        index == mapPieceAbilityActive.values.first;
                    bool isAbilitySingleUse =
                        pieces.mapAbilitySingleUse[strPieceName][index];
                    return Card(
                      color: isAbilitySingleUse
                          ? (isSpecificPieceAbilityActive
                              ? colorActive
                              : colorSingleUse)
                          : colorContinuous,
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(
                            pieces.mapAbilityName[strPieceName][index],
                            style: styleSub2,
                            textAlign: TextAlign.center,
                          ),
                          trailing: Icon(
                            isAbilitySingleUse
                                ? (isSpecificPieceAbilityActive
                                    ? pieces.iconPieceAbilityCancel
                                    : pieces.iconPieceAbilitySingleUse)
                                : pieces.iconPieceAbilityContinuous,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        onPressed: () {
                          pieceAbilityOnPressed(
                              strPieceName,
                              index,
                              isAbilitySingleUse,
                              isPieceAbilityActive,
                              isSpecificPieceAbilityActive);
                        },
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
