import 'package:jps_chess/functions/motion_functions.dart';
import 'package:flutter/foundation.dart' as fnd;

Map<String, Function> mapSpecialAbilityFunction = {
  'Mesmer': getMesmerEligibleSpots,
  'Mind Control Tower': getMindControlTowerEligibleSpots,
  'Necromancer': getNecromancerEligibleSpots,
  'Sniper from Heaven': getSniperFromHeavenEligibleSpots,
};

List<List<int>> getWholeBoard() {
  List<List<int>> listOutput = [];
  for (int i = 0; i <= rMax; i++) {
    for (int j = 0; j <= rMax; j++) {
      listOutput.add([i, j]);
    }
  }
  return listOutput;
}

List<List<int>> getInitialTerritory(
    bool isForSelf,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isVacant) {
  List<List<int>> listInitialTerritory = [];
  int i0 = 0;
  int iMax = rMax;
  int j0;
  int jMax;
  if (isForSelf) {
    j0 = 0;
    jMax = 1;
  } else {
    j0 = rMax - 1;
    jMax = rMax;
  }
  for (int i = i0; i <= iMax; i++) {
    for (int j = j0; j <= jMax; j++) {
      if (!isVacant ||
          (isVacant &&
              !checkOccupied(mapSelf, [i, j]) &&
              !checkOccupied(mapRival, [i, j]))) {
        listInitialTerritory.add([i, j]);
      }
    }
  }
  return listInitialTerritory;
}

//region check usability functions
List<List<int>> getMindControlTowerEligibleSpots(
  int nAbility,
  Map<String, List<List<int>>> mapSelf,
  Map<String, List<List<int>>> mapRival,
) {
  List<List<int>> listFinalSpots = [];
  //PreGame select self rook to control
  if (nAbility == 0) {
    mapSelf.forEach((key, value) {
      if (key == 'rook') {
        listFinalSpots.addAll(value);
      }
    });
  }
  //PreGame select rival piece to control
  else if (nAbility == 1) {
    mapRival.forEach((key, value) {
      if (key != 'king') {
        listFinalSpots.addAll(value);
      }
    });
  }
  return listFinalSpots;
}

List<List<int>> getMesmerEligibleSpots(
  Map<String, List<List<int>>> mapSelf,
) {
  List<List<int>> listFinalSpots = [];
  //PreGame select piece to trap
  mapSelf.forEach((key, value) {
    if (key != 'king' && key != 'queen') {
      listFinalSpots.addAll(value);
    }
  });
  return listFinalSpots;
}

List<List<int>> getNecromancerEligibleSpots(
  int nAbility,
  Map<String, List<List<int>>> mapSelf,
  Map<String, List<List<int>>> mapRival,
) {
  List<List<int>> listFinalSpots = [];
  if (nAbility == 0) {
    //Revive new piece ability
    listFinalSpots.addAll(getInitialTerritory(true, mapSelf, mapRival, true));
  } else if (nAbility == 1) {
    //Swap current piece ability
    mapSelf.keys.forEach((element) {
      if (element != 'king' && element != 'pawn') {
        listFinalSpots.addAll(mapSelf[element]);
      }
    });
  }
  return listFinalSpots;
}

List<List<int>> getSniperFromHeavenEligibleSpots(
  Map<String, List<List<int>>> mapSelf,
  Map<String, List<List<int>>> mapRival,
  Map<String, List<List<int>>> mapStatusSelf,
  bool isPreGame,
) {
  List<List<int>> listFinalSpots = [];
  if (isPreGame) {
    listFinalSpots.addAll(getWholeBoard());
    List<List<int>> listTupleEnemyTerritory =
        getInitialTerritory(false, mapSelf, mapRival, false);
    listFinalSpots.removeWhere((eF) =>
        listTupleEnemyTerritory.any((element) => fnd.listEquals(element, eF)));
    listFinalSpots.removeWhere((eF) => mapStatusSelf['mySpecial']
        .any((element) => fnd.listEquals(element, eF)));
  } else {
    List<List<int>> listTupleRivalNonKing = [];
    mapRival.forEach((key, value) {
      if (key != 'king') {
        listTupleRivalNonKing.addAll(value);
      }
    });
    listTupleRivalNonKing.forEach((eR) {
      if (mapStatusSelf['mySpecial']
          .any((element) => fnd.listEquals(element, eR))) {
        listFinalSpots.add(eR);
      }
    });
  }
  return listFinalSpots;
}

//endregion check usability functions
