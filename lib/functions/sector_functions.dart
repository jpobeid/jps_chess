import 'package:flutter/material.dart';
import 'package:jps_chess/data/pieces_data.dart' as pieces;
import 'package:jps_chess/functions/motion_functions.dart';
import 'package:jps_chess/functions/snack_bar_functions.dart';

bool makeInvalidPieceAbilityMessage(
    BuildContext context,
    String strPieceSelected,
    int index,
    Map<String, List<List<int>>> mapSelf,
    List<int> listTap) {
  const String strQueenKingError = 'Need a king present...';
  const String strBishopLaunchError = 'Needs to be at launch edge!';
  const String strKnightRiderError = 'Needs a pawn rider behind!';
  const String strPawnEdgeError = 'Needs to be at opponent edge!';
  switch (strPieceSelected) {
    case 'queen':
      if (index ==
              pieces.mapAbilityName[strPieceSelected]
                  .indexOf('Summon big papi') &&
          mapSelf['king'].isEmpty) {
        showInvalidSnackBar(context, strQueenKingError);
        return true;
      } else {
        return false;
      }
      break;
    case 'bishop':
      if (index ==
              pieces.mapAbilityName[strPieceSelected]
                  .indexOf('Lunar laser-guided ballistic missile') &&
          !(listTap[0] == 0 || listTap[0] == pieces.rMax)) {
        showInvalidSnackBar(context, strBishopLaunchError);
        return true;
      } else {
        return false;
      }
      break;
    case 'knight':
      if (index ==
              pieces.mapAbilityName[strPieceSelected]
                  .indexOf('Big-ass-horse') &&
          !(checkInBounds([listTap[0], listTap[1] - 1]) &&
              getPieceName(mapSelf, [listTap[0], listTap[1] - 1]) == 'pawn')) {
        showInvalidSnackBar(context, strKnightRiderError);
        return true;
      } else {
        return false;
      }
      break;
    case 'pawn':
      if (index ==
              pieces.mapAbilityName[strPieceSelected]
                  .indexOf('I gotchu homie') &&
          !(listTap[1] == pieces.rMax)) {
        showInvalidSnackBar(context, strPawnEdgeError);
        return true;
      } else {
        return false;
      }
      break;
    default:
      return false;
      break;
  }
}

void showInvalidSnackBar(BuildContext context, String strMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    makeGlobalSnackBar(strMessage),
  );
}
