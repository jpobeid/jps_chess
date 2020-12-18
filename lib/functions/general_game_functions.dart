import 'package:flutter/foundation.dart' as fnd;
import 'motion_functions.dart';

const Map<int, String> _mapStatusNumber = {
  0: 'fixed',
  1: 'forced',
  2: 'targeted',
  3: 'traced',
  4: 'cannotCheckmate',
};

void _mapRemoveAdd(
    int nTurn,
    int indexActivePlayer,
    Map<String, List<List<int>>> map,
    Map<String, int> mapGrave,
    List<bool> listIsRemoveAdd,
    List<int> listCoordinateRemove,
    String strPieceNameAdd,
    List<int> listCoordinateAdd) {
  if (listIsRemoveAdd[0]) {
    String strPieceNameRemove = getPieceName(map, listCoordinateRemove);
    List<List<int>> listSubRemove = map[strPieceNameRemove];
    int index = listSubRemove
        .map((e) => fnd.listEquals(e, listCoordinateRemove))
        .toList()
        .indexOf(true);
    listSubRemove.removeAt(index);
    map.addAll({strPieceNameRemove: listSubRemove});
    int nPieceInGrave = mapGrave[strPieceNameRemove];
    mapGrave.addAll({strPieceNameRemove: nPieceInGrave + 1});
  }
  if (listIsRemoveAdd[1]) {
    List<List<int>> listSubAdd = map[strPieceNameAdd];
    listSubAdd.add(listCoordinateAdd);
    map.addAll({strPieceNameAdd: listSubAdd});
    int nPieceInGrave = mapGrave[strPieceNameAdd];
    mapGrave.addAll({strPieceNameAdd: nPieceInGrave - 1});
  }
}

Map<String, List<List<int>>> mapStatusTimerAdd(
    int nTurn,
    Map<String, List<List<int>>> mapStatus,
    String strStatus,
    List<List<int>> listListAdd,
    int nTurnsDuration) {
  List<List<int>> listSub = mapStatus[strStatus];
  List<List<int>> listSubTimer = mapStatus['timer'];
  listListAdd.forEach((eD0) {
    listSub.add(eD0);
    listSubTimer.add([
      eD0[0],
      eD0[1],
      mapStatus.keys.toList().indexOf(strStatus),
      nTurn + nTurnsDuration
    ]);
  });
  mapStatus.addAll({strStatus: listSub});
  mapStatus.addAll({'timer': listSubTimer});
  return mapStatus;
}
Map<String, List<List<int>>> mapStatusTimerRemove(
    Map<String, List<List<int>>> mapStatus,
    String strStatus,
    List<List<int>> listListRemove) {
  int indexStatus = _mapStatusNumber.values.toList().indexOf(strStatus);
  List<List<int>> listSub = mapStatus[strStatus];
  List<List<int>> listSubTimer = mapStatus['timer'];
  listListRemove.forEach((eR) {
    bool isPresent = (listSub.any((element) => fnd.listEquals(element, eR)));
    if (isPresent) {
      int index =
          listSub.map((e) => fnd.listEquals(e, eR)).toList().indexOf(true);
      listSub.removeAt(index);
      int indexTimer = listSubTimer
          .map((e) => fnd.listEquals([e[0], e[1], e[2]], [eR[0], eR[1], indexStatus]))
          .toList()
          .indexOf(true);
      listSubTimer.removeAt(indexTimer);
    }
  });
  mapStatus.addAll({strStatus: listSub});
  mapStatus.addAll({'timer': listSubTimer});
  return mapStatus;
}

Map<String, List<List<int>>> performStatusExpiration(
    int nTurn,
    int indexActivePlayer,
    Map<String, List<List<int>>> mapStatus,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    Map<String, int> mapGraveSelf,
    Map<String, int> mapGraveRival) {
  List<List<int>> listListSubTimer;
  int i;
  List<int> listI;
  //Perform expiration for Self
  listListSubTimer = mapStatus['timer'];
  i = 0;
  listI = [];
  if (listListSubTimer.isNotEmpty) {
    listListSubTimer.forEach((element) {
      if (element.last < nTurn) {
        listI.add(i);
        List<List<int>> listListSub = mapStatus[_mapStatusNumber[element[2]]];
        int index = listListSub
            .map((e) => fnd.listEquals(e, [element[0], element[1]]))
            .toList()
            .indexOf(true);
        listListSub.removeAt(index);
        mapStatus.addAll({_mapStatusNumber[element[2]]: listListSub});
        performStatusFunction(
            nTurn,
            indexActivePlayer,
            _mapStatusNumber[element[2]],
            [element[0], element[1]],
            mapSelf,
            mapRival,
            mapGraveSelf,
            mapGraveRival);
      }
      i++;
    });
    int j = 0;
    listI.forEach((element) {
      listListSubTimer.removeAt(element - j);
      j++;
    });
    mapStatus.addAll({'timer': listListSubTimer});
  }
  return mapStatus;
}

void performStatusFunction(
    int nTurn,
    int indexActivePlayer,
    String strStatus,
    List<int> listCoordinates,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    Map<String, int> mapGraveSelf,
    Map<String, int> mapGraveRival) {
  switch (strStatus) {
    case 'fixed':
      break;
    case 'forced':
      break;
    case 'traced':
      break;
    case 'targeted':
      if (checkOccupied(mapSelf, listCoordinates) &&
          getPieceName(mapSelf, listCoordinates) != 'king') {
        _mapRemoveAdd(nTurn, indexActivePlayer, mapSelf, mapGraveSelf,
            [true, false], listCoordinates, '', []);
      } else if (checkOccupied(mapRival, listCoordinates) &&
          getPieceName(mapRival, listCoordinates) != 'king') {
        _mapRemoveAdd(nTurn, indexActivePlayer, mapRival, mapGraveRival,
            [true, false], listCoordinates, '', []);
      }
      break;
    case 'cannotCheckmate':
      break;
    default:
      break;
  }
}

List<Map> performTurnTranspositions(
    int nTurn,
    int indexActivePlayer,
    Map<String, List<List<int>>> mapSelf,
    Map<String, List<List<int>>> mapRival,
    Map<String, List<List<int>>> mapStatusSelf,
    Map<String, List<List<int>>> mapStatusRival,
    Map<String, int> mapGraveSelf,
    Map<String, int> mapGraveRival,
    bool toTransposeBoard) {
  mapStatusSelf = performStatusExpiration(nTurn, indexActivePlayer,
      mapStatusSelf, mapSelf, mapRival, mapGraveSelf, mapGraveRival);
  mapStatusRival = performStatusExpiration(nTurn, indexActivePlayer,
      mapStatusRival, mapSelf, mapRival, mapGraveSelf, mapGraveRival);
  if (toTransposeBoard) {
    Map<String, List<List<int>>> mapTempSelf;
    Map<String, List<List<int>>> mapTempRival;
    mapTempSelf = mapSelf;
    mapTempRival = mapRival;
    mapRival = transposeMap(mapTempSelf, toTransposeBoard);
    mapSelf = transposeMap(mapTempRival, toTransposeBoard);
    mapTempSelf = mapStatusSelf;
    mapTempRival = mapStatusRival;
    mapStatusRival = transposeMap(mapTempSelf, toTransposeBoard);
    mapStatusSelf = transposeMap(mapTempRival, toTransposeBoard);
    Map<String, int> mapTempGraveSelf = mapGraveSelf;
    Map<String, int> mapTempGraveRival = mapGraveRival;
    mapGraveRival = mapTempGraveSelf;
    mapGraveSelf = mapTempGraveRival;
  }
  return [
    mapSelf,
    mapRival,
    mapStatusSelf,
    mapStatusRival,
    mapGraveSelf,
    mapGraveRival
  ];
}

Map<String, List<List<int>>> transposeMap(
    Map<String, List<List<int>>> map, bool toTransposeBoard) {
  Map<String, List<List<int>>> mapTransposed = {};
  if (toTransposeBoard) {
    //Transpose pieces
    map.keys.forEach((element) {
      List<List<int>> listSub = map[element];
      if (listSub.isNotEmpty && listSub.first.length == 2) {
        listSub = listSub.map((e) => [rMax - e[0], rMax - e[1]]).toList();
      } else if (listSub.isNotEmpty && listSub.first.length == 4) {
        listSub =
            listSub.map((e) => [rMax - e[0], rMax - e[1], e[2], e[3]]).toList();
      }
      mapTransposed.addAll({element: listSub});
    });
    return mapTransposed;
  } else {
    map.keys.forEach((element) {
      List<List<int>> listSub = map[element];
      if (listSub.isNotEmpty && listSub.first.length == 2) {
        listSub = listSub.map((e) => [rMax - e[0], rMax - e[1]]).toList();
      } else if (listSub.isNotEmpty && listSub.first.length == 4) {
        listSub =
            listSub.map((e) => [rMax - e[0], rMax - e[1], e[2], e[3]]).toList();
      }
      mapTransposed.addAll({element: listSub});
    });
    return mapTransposed;
  }
}
