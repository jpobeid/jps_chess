import 'package:jps_chess/functions/motion_functions.dart';
import 'package:jps_chess/data/pieces_data.dart' as pieces;
import 'package:flutter/foundation.dart' as fnd;

Map<String, Function> mapPieceAbilityFunction = {
  'king': getKingAbilityEligibleSpots,
  'queen': getQueenAbilityEligibleSpots,
  'rook': getRookAbilityEligibleSpots,
  'bishop': getBishopAbilityEligibleSpots,
  'knight': getKnightAbilityEligibleSpots,
  'pawn': getPawnAbilityEligibleSpots,
};

//region Check usability functions
List<List<int>> getKingAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (nAbility == pieces.mapAbilityName['king'].indexOf('Begone bitch')) {
    List<List<int>> listD0 = [
      [1, 1],
      [1, 0],
      [1, -1],
      [0, 1],
      [0, -1],
      [-1, 1],
      [-1, 0],
      [-1, -1],
    ];
    listD0.forEach((element) {
      List<int> listTarget = [i + element[0], j + element[1]];
      if (checkInBounds(listTarget) &&
          checkOccupied(mapRival, listTarget) &&
          getPieceName(mapRival, listTarget) != 'king') {
        listFinalSpots.add(element);
      }
    });
  }
  return listFinalSpots;
}

List<List<int>> getQueenAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (nAbility == pieces.mapAbilityName['queen'].indexOf('Summon big papi')) {
    List<List<int>> listD0 = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    listD0.forEach((element) {
      if (checkFreeAndInBounds(mapSelf, [i + element[0], j + element[1]]) &&
          checkFreeAndInBounds(mapRival, [i + element[0], j + element[1]])) {
        listFinalSpots.add(element);
      }
    });
  }
  return listFinalSpots;
}

List<List<int>> getRookAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (nAbility == pieces.mapAbilityName['rook'].indexOf("Stoner's tower")) {
    List<List<int>> listD0 = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    listD0.forEach((element) {
      if (checkOccupied(mapRival, [i + element[0], j + element[1]]) &&
          getPieceName(mapRival, [i + element[0], j + element[1]]) != 'king') {
        listFinalSpots.add(element);
      }
    });
  } else if (nAbility ==
      pieces.mapAbilityName['rook'].indexOf('Tower turrets')) {
    List<List<int>> listD0 = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    listD0.forEach((element) {
      List<List<int>> listIterations =
          iterateSpots(mapSelf, mapRival, i, j, 1, 3, element, false, true);
      if (listIterations.isNotEmpty) {
        List<int> listTarget = listIterations.last;
        if (listTarget.isNotEmpty &&
            checkOccupied(mapRival, [i + listTarget[0], j + listTarget[1]]) &&
            getPieceName(mapRival, [i + listTarget[0], j + listTarget[1]]) ==
                'pawn') {
          listFinalSpots.add(listTarget);
        }
      }
    });
  } else if (nAbility ==
      pieces.mapAbilityName['rook'].indexOf("Stoner's castle")) {
    List<int> tupleKing = mapSelf['king'].first;
    int dBoxes = (i - tupleKing[0]).abs();
    List<List<int>> listD0;
    switch (i < tupleKing[0]) {
      case true:
        if (dBoxes == 3) {
          listD0 = [
            [1, 0],
            [2, 0],
          ];
        } else {
          listD0 = [
            [1, 0],
            [2, 0],
            [3, 0],
          ];
        }
        break;
      case false:
        if (dBoxes == 3) {
          listD0 = [
            [-1, 0],
            [-2, 0],
          ];
        } else {
          listD0 = [
            [-1, 0],
            [-2, 0],
            [-3, 0],
          ];
        }
        break;
      default:
        listD0 = [];
        break;
    }
    bool isRegionClear = !listD0.any((element) => (checkOccupied(mapSelf, [i + element[0], j + element[1]]) || checkOccupied(mapRival, [i + element[0], j + element[1]])));
    if (isRegionClear) {
      listFinalSpots.add(listD0.last);
    }
  }
  return listFinalSpots;
}

List<List<int>> getBishopAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (nAbility ==
      pieces.mapAbilityName['bishop']
          .indexOf('Lunar laser-guided ballistic missile')) {
    for (int i1 = 1; i1 < rMax; i1++) {
      for (int j1 = 1; j1 < rMax; j1++) {
        listFinalSpots.add([i1 - i, j1 - j]);
      }
    }
  }
  return listFinalSpots;
}

List<List<int>> getKnightAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (nAbility ==
      pieces.mapAbilityName['knight'].indexOf('Big-ass-L ("Big AL")')) {
    List<List<int>> listD0 = [
      [3, 2],
      [3, -2],
      [-3, 2],
      [-3, -2],
      [2, 3],
      [2, -3],
      [-2, 3],
      [-2, -3],
    ];
    List<List<int>> listDir = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    List<int> listAlt1 = [0, 1];
    List<int> listAlt2 = [0, 1];
    listAlt1.forEach((eAlt1) {
      listAlt2.forEach((eAlt2) {
        listDir.forEach((eDir) {
          List<List<int>> listStep1 = iterateSpots(
              mapSelf,
              mapRival,
              i,
              j,
              1,
              eAlt1 == 0 ? 3 : 2,
              [eAlt2 * eDir[0], (1 - eAlt2) * eDir[1]],
              true,
              true);
          if (listStep1.isNotEmpty) {
            List<List<int>> listStep2 = iterateSpots(
                mapSelf,
                mapRival,
                i + listStep1.last[0],
                j + listStep1.last[1],
                1,
                eAlt1 == 0 ? 2 : 3,
                [(1 - eAlt2) * eDir[0], eAlt2 * eDir[1]],
                false,
                true);
            if (listStep2.isNotEmpty) {
              List<int> listTarget = [
                listStep1.last[0] + listStep2.last[0],
                listStep1.last[1] + listStep2.last[1]
              ];
              if (listD0
                  .any((element) => fnd.listEquals(element, listTarget))) {
                listFinalSpots.add(listTarget);
              }
            }
          }
        });
      });
    });
  } else if (nAbility ==
      pieces.mapAbilityName['knight'].indexOf('Big-ass-horse')) {
    List<int> listRider = [i, j - 1];
    if (checkInBounds(listRider) &&
        getPieceName(mapSelf, listRider) == 'pawn') {
      List<List<int>> listDKnight =
          getMotionKnight(listCoordinates, mapSelf, mapRival, true);
      List<List<int>> listDRider =
          getMotionKnight(listRider, mapSelf, mapRival, false);
      if (listDKnight.isNotEmpty && listDRider.isNotEmpty) {
        listDKnight.forEach((eKnight) {
          listDRider.forEach((eRider) {
            if (fnd.listEquals(eKnight, eRider)) {
              listFinalSpots.add(eKnight);
            }
          });
        });
      }
    }
  }
  return listFinalSpots;
}

List<List<int>> getPawnAbilityEligibleSpots(
    int nAbility,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    List<int> listCoordinates) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = getWholeBoard();
  listFinalSpots.removeWhere((element) => (checkOccupied(mapSelf, element) || checkOccupied(mapRival, element)));
  listFinalSpots = listFinalSpots.map((e) => [e[0] - i, e[1] - j]).toList();
  return listFinalSpots;
}

List<List<int>> getWholeBoard() {
  List<List<int>> listOutput = [];
  for (int i = 0; i <= rMax; i++) {
    for (int j = 0; j <= rMax; j++) {
      listOutput.add([i, j]);
    }
  }
  return listOutput;
}

//endregion Check usability functions
