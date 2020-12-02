import 'package:flutter/foundation.dart' as fnd;

int nDiv = 8;

int iMin = 0;
int jMin = 0;
int rMax = nDiv - 1;

bool checkOccupied(
    Map<String, List<List<int>>> mapPlayer, List<int> listCoordinates) {
  return mapPlayer.values.any((element) =>
      element.any((element) => fnd.listEquals(element, listCoordinates)));
}

bool checkInBounds(List<int> listCoordinates) {
  return (listCoordinates[0] >= iMin &&
          listCoordinates[0] <= rMax &&
          listCoordinates[1] >= jMin &&
          listCoordinates[1] <= rMax)
      ? true
      : false;
}

bool checkFreeAndInBounds(
    Map<String, List<List<int>>> mapPlayer, List<int> listCoordinates) {
  return !checkOccupied(mapPlayer, listCoordinates) &&
      checkInBounds(listCoordinates);
}

String getPieceName(
    Map<String, List<List<int>>> mapPlayer, List<int> listCoordinates) {
  if (checkOccupied(mapPlayer, listCoordinates)) {
    List<bool> listMask = mapPlayer.values
        .map(
            (e) => e.any((element) => fnd.listEquals(element, listCoordinates)))
        .toList();
    if (listMask.any((element) => element)) {
      int index = listMask.indexOf(true);
      return mapPlayer.keys.toList()[index];
    } else {
      return null;
    }
  } else {
    return null;
  }
}

Map<String, Function> mapPieceMotionFunction = {
  'king': getMotionKing,
  'queen': getMotionQueen,
  'rook': getMotionRook,
  'bishop': getMotionBishop,
  'knight': getMotionKnight,
  'pawn': getMotionPawn,
};

List<List<int>> getMotionPawn(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  int jBoost = 1;
  if (isClassic) {
    //Classic pawn motions
    List<List<int>> listFinalSpots = [];
    if (checkInBounds([i + 0, j + 1]) &&
        !checkOccupied(mapSelf, [i + 0, j + 1]) &&
        !checkOccupied(mapRival, [i + 0, j + 1])) {
      listFinalSpots.add([0, 1]);
    }
    if (checkInBounds([i + 1, j + 1]) &&
        !checkOccupied(mapSelf, [i + 1, j + 1]) &&
        checkOccupied(mapRival, [i + 1, j + 1])) {
      listFinalSpots.add([1, 1]);
    }
    if (checkInBounds([i - 1, j + 1]) &&
        !checkOccupied(mapSelf, [i - 1, j + 1]) &&
        checkOccupied(mapRival, [i - 1, j + 1])) {
      listFinalSpots.add([-1, 1]);
    }
    if (j == jBoost &&
        listFinalSpots.any((element) => fnd.listEquals(element, [0, 1])) &&
        !checkOccupied(mapSelf, [i, j + 2]) &&
        !checkOccupied(mapRival, [i, j + 2])) {
      listFinalSpots.add([0, 2]);
    }
    return listFinalSpots;
  } else {
    //Navy seal augmented pawn motions (partially)
    List<List<int>> listFinalSpots = [];
    if (checkInBounds([i + 0, j + 1]) &&
        !checkOccupied(mapSelf, [i + 0, j + 1]) &&
        !checkOccupied(mapRival, [i + 0, j + 1])) {
      listFinalSpots.add([0, 1]);
    }
    if (checkInBounds([i + 0, j - 1]) &&
        !checkOccupied(mapSelf, [i + 0, j - 1]) &&
        !checkOccupied(mapRival, [i + 0, j - 1])) {
      listFinalSpots.add([0, -1]);
    }
    if (checkInBounds([i + 1, j + 1]) &&
        !checkOccupied(mapSelf, [i + 1, j + 1]) &&
        checkOccupied(mapRival, [i + 1, j + 1])) {
      listFinalSpots.add([1, 1]);
    }
    if (checkInBounds([i - 1, j + 1]) &&
        !checkOccupied(mapSelf, [i - 1, j + 1]) &&
        checkOccupied(mapRival, [i - 1, j + 1])) {
      listFinalSpots.add([-1, 1]);
    }
    if (listFinalSpots.any((element) => fnd.listEquals(element, [0, 1])) &&
        !checkOccupied(mapSelf, [i, j + 2]) &&
        !checkOccupied(mapRival, [i, j + 2])) {
      listFinalSpots.add([0, 2]);
    }
    return listFinalSpots;
  }
}

List<List<int>> getMotionKing(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (isClassic) {
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
      List<int> listNewCoordinates = [i + element[0], j + element[1]];
      bool isSpotClear = !checkOccupied(mapSelf, listNewCoordinates) &&
          checkInBounds(listNewCoordinates);
      if (isSpotClear) {
        listFinalSpots.add(element);
      }
    });
  }
  return listFinalSpots;
}

List<List<int>> getMotionRook(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (isClassic) {
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, 0], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, 0], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [0, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [0, -1], false, true));
  }
  return listFinalSpots;
}

List<List<int>> getMotionBishop(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (isClassic) {
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, -1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, -1], false, true));
  }
  return listFinalSpots;
}

List<List<int>> getMotionQueen(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (isClassic) {
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, -1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, -1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [1, 0], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [-1, 0], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [0, 1], false, true));
    listFinalSpots.addAll(
        iterateSpots(mapSelf, mapRival, i, j, 1, rMax, [0, -1], false, true));
  }
  return listFinalSpots;
}

List<List<int>> getMotionKnight(
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    bool isClassic) {
  int i = listCoordinates[0];
  int j = listCoordinates[1];
  List<List<int>> listFinalSpots = [];
  if (isClassic) {
    List<List<int>> listD0 = [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2],
    ];
    listD0.forEach((element) {
      List<int> listNewCoordinates = [i + element[0], j + element[1]];
      bool isSpotClear = !checkOccupied(mapSelf, listNewCoordinates) &&
          checkInBounds(listNewCoordinates);
      if (isSpotClear) {
        listFinalSpots.add(element);
      }
    });
  } else {
    List<List<int>> listD0 = [
      [2, 1],
      [2, -1],
      [-2, 1],
      [-2, -1],
      [1, 2],
      [1, -2],
      [-1, 2],
      [-1, -2],
    ];
    listD0.forEach((element) {
      List<int> listNewCoordinates = [i + element[0], j + element[1]];
      bool isSpotClear = !checkOccupied(mapSelf, listNewCoordinates) &&
          !checkOccupied(mapRival, listNewCoordinates) &&
          checkInBounds(listNewCoordinates);
      if (isSpotClear) {
        listFinalSpots.add(element);
      }
    });
  }
  return listFinalSpots;
}

//region accessory functions
List<List<int>> iterateSpots(
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    int i,
    int j,
    int dr,
    int drMax,
    List<int> listDirection,
    bool breakBeforeRival,
    bool breakAtRival) {
  List<List<int>> listFinalSpots = [];
  bool isRivalBreak = false;
  List<int> listNewCoordinates = [
    i + listDirection[0] * dr,
    j + listDirection[1] * dr
  ];
  while (!checkOccupied(mapSelf, listNewCoordinates) &&
      !isRivalBreak &&
      checkInBounds(listNewCoordinates) &&
      dr <= drMax) {
    if (checkOccupied(mapRival, listNewCoordinates)) {
      if (breakBeforeRival) {
        isRivalBreak = true;
      } else if (breakAtRival) {
        listFinalSpots.add([listDirection[0] * dr, listDirection[1] * dr]);
        isRivalBreak = true;
      } else {
        listFinalSpots.add([listDirection[0] * dr, listDirection[1] * dr]);
      }
    } else {
      listFinalSpots.add([listDirection[0] * dr, listDirection[1] * dr]);
    }
    dr++;
    listNewCoordinates = [i + listDirection[0] * dr, j + listDirection[1] * dr];
  }
  return listFinalSpots;
}
//endregion accessory functions
