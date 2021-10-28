import 'package:flutter/material.dart';
import 'package:jps_chess/functions/draw_functions.dart';
import 'package:jps_chess/functions/general_game_functions.dart';
import 'package:jps_chess/widgets/board.dart';
import 'package:jps_chess/data/player_data.dart' as players;
import 'package:jps_chess/data/pieces_data.dart' as pieces;
import 'package:jps_chess/data/special_data.dart' as specials;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' as fnd;
import 'package:jps_chess/functions/motion_functions.dart';
import 'package:jps_chess/functions/piece_ability_functions.dart';
import 'package:jps_chess/functions/special_ability_functions.dart';
import 'package:flutter/services.dart';
import 'package:jps_chess/functions/settings_functions.dart';
import 'package:jps_chess/widgets/game_over_overlay.dart';
import 'package:jps_chess/functions/game_over_functions.dart';
import 'package:jps_chess/widgets/special_ability_sector.dart';
import 'package:jps_chess/functions/sector_functions.dart';
import 'package:jps_chess/widgets/piece_ability_sector.dart';

int nDiv = 8;
int rMax = nDiv - 1;
int j00 = 0;
int j01 = 1;
int j10 = nDiv - 1;
int j11 = nDiv - 2;

class GameLayoutOffline extends StatefulWidget {
  static const routeName = '/game-layout-offline';

  final List<String> listSpecialAbilityName;
  final List<int> listSpecialAbilityExtra;

  const GameLayoutOffline(
      {Key key, this.listSpecialAbilityName, this.listSpecialAbilityExtra})
      : super(key: key);

  static const double sizeDivider = 4;
  static const TextStyle styleSub =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 24);
  static const double sizeBorderRadius = 5;

  @override
  _GameLayoutOfflineState createState() => _GameLayoutOfflineState();
}

class _GameLayoutOfflineState extends State<GameLayoutOffline> {
  int _nTurn;
  int _indexActivePlayer;
  bool _toTransposeBoard = true;
  bool _isToPop = false;

  Map<String, List<List<int>>> _mapSelf = {
    'king': [
      [4, j00]
    ],
    'queen': [
      [3, j00]
    ],
    'rook': [
      [0, j00],
      [7, j00]
    ],
    'bishop': [
      [2, j00],
      [5, j00]
    ],
    'knight': [
      [1, j00],
      [6, j00]
    ],
    'pawn': [
      [0, j01],
      [1, j01],
      [2, j01],
      [3, j01],
      [4, j01],
      [5, j01],
      [6, j01],
      [7, j01]
    ],
  };
  Map<String, List<List<int>>> _mapRival = {
    'king': [
      [4, j10]
    ],
    'queen': [
      [3, j10]
    ],
    'rook': [
      [0, j10],
      [7, j10]
    ],
    'bishop': [
      [2, j10],
      [5, j10]
    ],
    'knight': [
      [1, j10],
      [6, j10]
    ],
    'pawn': [
      [0, j11],
      [1, j11],
      [2, j11],
      [3, j11],
      [4, j11],
      [5, j11],
      [6, j11],
      [7, j11]
    ],
  };
  Map<String, int> _mapGraveSelf = {
    'king': 0,
    'queen': 0,
    'rook': 0,
    'bishop': 0,
    'knight': 0,
    'pawn': 0,
  };
  Map<String, int> _mapGraveRival = {
    'king': 0,
    'queen': 0,
    'rook': 0,
    'bishop': 0,
    'knight': 0,
    'pawn': 0,
  };
  Map<String, List<List<int>>> _mapStatusSelf = {
    'fixed': [],
    'forced': [],
    'targeted': [],
    'traced': [],
    'cannotCheckmate': [],
    'timer': [],
    'mySpecial': [],
    'mySpecialLabel': [],
    'mySpecialSecret': [],
  };
  Map<String, List<List<int>>> _mapStatusRival = {
    'fixed': [],
    'forced': [],
    'targeted': [],
    'traced': [],
    'cannotCheckmate': [],
    'timer': [],
    'mySpecial': [],
    'mySpecialLabel': [],
    'mySpecialSecret': [],
  };
  List<Color> _listBoardColors;
  List<int> _listGameOverByKing = [0, 0];
  Map<int, String> _mapFutureBuilder = {};
  Map<int, List<dynamic>> _mapFutureBuilderArgs = {};
  List<bool> _listToggleAbility = [true, false];
  String _strPieceSelected;
  List<int> _listTap = [];
  List<List<int>> _listTupleDMotion = [];
  Map<String, int> _mapPieceAbilityActive = {};
  List<List<int>> _listTupleDPieceAbility = [];
  List<int> _listTimesSpecialAbilityMax;
  List<int> _listTimesSpecialAbilityUsed = [0, 0];
  List<bool> _listIsSpecialAbilityActive = [false, false];
  List<bool> _listIsSpecialAbilityAvailable = [true, true];
  List<int> _listSpecialAbilitySubtype = [null, null];
  List<List<int>> _listTupleAbsSpecialAbility = [];

  //region Draw functions
  Container makeBoard(double dimBoard, double dimBox,
      Map<String, List<List<int>>> map0, Map<String, List<List<int>>> map1) {
    List<Widget> listStack = [];
    listStack.add(Board(
      dimBoard: dimBoard,
      nDiv: nDiv,
      listBoardColor: _listBoardColors,
      listTap: _listTap,
      listTupleDMotion: _listTupleDMotion,
      isPieceAbilityActive: _mapPieceAbilityActive.isNotEmpty,
      listTupleDPieceAbility: _listTupleDPieceAbility,
      isSpecialAbilityActive: _listIsSpecialAbilityActive[_indexActivePlayer],
      listTupleAbsSpecialAbility: _listTupleAbsSpecialAbility,
      mapStatusSelf: _mapStatusSelf,
      mapStatusRival: _mapStatusRival,
      colorSelf: _listBoardColors[_indexActivePlayer],
      colorRival: _listBoardColors[1 - _indexActivePlayer],
      isRivalSpecialSecret: widget.listSpecialAbilityName
          .map((e) => specials.mapSpecialAttributes[e][4] == 1)
          .toList()[1 - _indexActivePlayer],
    ));
    Color color0 = _toTransposeBoard
        ? _listBoardColors[_indexActivePlayer]
        : _listBoardColors[0];
    Color color1 = _toTransposeBoard
        ? _listBoardColors[1 - _indexActivePlayer]
        : _listBoardColors[1];
    map0.forEach((key, value) {
      listStack.addAll(value.map((e) => makePiece(dimBox, key, color0, e)));
    });
    map1.forEach((key, value) {
      listStack.addAll(value.map((e) => makePiece(dimBox, key, color1, e)));
    });
    return Container(
      height: dimBoard,
      width: dimBoard,
      child: Stack(
        children: listStack,
      ),
    );
  }

  void mapRemoveAdd(
    Map<String, List<List<int>>> map,
    Map<String, int> mapGrave,
    List<bool> listIsRemoveAdd,
    List<int> listCoordinateRemove,
    String strPieceNameAdd,
    List<int> listCoordinateAdd,
  ) {
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

  void attackIfRivalSpot(List<int> listNewTap) {
    if (checkOccupied(_mapRival, listNewTap)) {
      mapRemoveAdd(
          _mapRival, _mapGraveRival, [true, false], listNewTap, '', []);
      _mapStatusRival.keys.forEach((element) {
        if (_mapStatusRival[element].isNotEmpty &&
            (element == 'fixed' || element == 'forced')) {
          _mapStatusRival =
              mapStatusTimerRemove(_mapStatusRival, element, [listNewTap]);
        }
        //Break the rival Mind Control chain
        else if (widget.listSpecialAbilityName[1 - _indexActivePlayer] ==
                'Mind Control Tower' &&
            _mapStatusRival['mySpecial']
                .any((element) => fnd.listEquals(element, listNewTap))) {
          _mapStatusRival['mySpecial'].clear();
        }
        //Trigger the Mesmer power
        else if (widget.listSpecialAbilityName[1 - _indexActivePlayer] ==
                'Mesmer' &&
            _mapStatusRival['mySpecial']
                .any((element) => fnd.listEquals(element, listNewTap)) &&
            getPieceName(_mapSelf, _listTap) != 'king' &&
            getPieceName(_mapSelf, listNewTap) != 'king') {
          mapRemoveAdd(
              _mapSelf, _mapGraveSelf, [true, false], listNewTap, '', []);
          String strMesmerPieceName = pieces.mapPieceRank.keys.toList()[pieces
              .mapPieceRank.values
              .toList()
              .indexOf(_mapStatusRival['mySpecialLabel'].first[0])];
          mapRemoveAdd(_mapRival, _mapGraveRival, [false, true], [],
              strMesmerPieceName, listNewTap);
          _mapStatusRival['mySpecialLabel'].clear();
          _mapStatusRival['mySpecialLabel']
              .addAll(_mapStatusRival['mySpecial']);
          _mapStatusRival['mySpecial'].clear();
        }
      });
      int result = checkGameOverByKing(
        _mapGraveSelf,
        _mapGraveRival,
        _mapStatusSelf['cannotCheckmate'].isNotEmpty,
        _mapStatusRival['cannotCheckmate'].isNotEmpty,
      );
      if (result != 0) {
        setState(() {
          _listGameOverByKing = [result, _indexActivePlayer];
        });
      }
    }
  }

  //endregion Draw functions

  //region Piece Ability sector
  void pieceAbilityOnPressed(
      String strPieceName,
      int index,
      bool isAbilitySingleUse,
      bool isPieceAbilityActive,
      bool isSpecificPieceAbilityActive) {
    if (isAbilitySingleUse && !isPieceAbilityActive) {
      //Invalid usable management - Else proceed with ability box delineation
      bool isInvalidUsage = makeInvalidPieceAbilityMessage(
          context, _indexActivePlayer, strPieceName, index, _mapSelf, _listTap);
      if (!isInvalidUsage) {
        setState(() {
          _mapPieceAbilityActive = {
            strPieceName: index,
          };
          _listTupleDPieceAbility = mapPieceAbilityFunction[_strPieceSelected](
              index, _mapSelf, _mapRival, _listTap);
        });
      }
    } else if (isPieceAbilityActive && isSpecificPieceAbilityActive) {
      setState(() {
        resetPieceAbility();
      });
    }
  }

  //endregion Piece Ability sector

  //region Piece Ability functions
  void performPieceAbility(List<int> listNewTap) {
    switch (_strPieceSelected) {
      case 'king':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected].indexOf('Begone bitch')) {
          setState(() {
            attackIfRivalSpot(listNewTap);
            markTracedBoxes(_listTap, listNewTap, true);
            endTurn();
          });
        }
        break;
      case 'queen':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf('Summon big papi')) {
          if (_mapSelf['king'].isNotEmpty) {
            List<int> listCoordinatesKing = _mapSelf['king'].first;
            setState(() {
              mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true],
                  listCoordinatesKing, 'king', listNewTap);
              markTracedBoxes(listCoordinatesKing, listNewTap, false);
              endTurn();
            });
          }
        }
        break;
      case 'rook':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf("Stoner's tower")) {
          int nDuration = 2;
          setState(() {
            //Fix rival piece
            _mapStatusRival = mapStatusTimerAdd(
                _nTurn, _mapStatusRival, 'fixed', [listNewTap], nDuration);
            //Fix your own rook
            _mapStatusSelf = mapStatusTimerAdd(
                _nTurn,
                _mapStatusSelf,
                'fixed',
                [
                  [_listTap[0], _listTap[1]]
                ],
                nDuration);
          });
        } else if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected].indexOf('Tower turrets')) {
          setState(() {
            attackIfRivalSpot(listNewTap);
            markTracedBoxes(_listTap, listNewTap, true);
            endTurn();
          });
        } else if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf("Stoner's castle")) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'rook', listNewTap);
            List<int> tupleKing = _mapSelf['king'].first;
            int intDirectionKingCastle = listNewTap[0] > tupleKing[0] ? 1 : -1;
            List<int> tupleNewKing = [
              listNewTap[0] + intDirectionKingCastle,
              listNewTap[1]
            ];
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], tupleKing,
                'king', tupleNewKing);
            markTracedBoxes(tupleKing, tupleNewKing, false);
            endTurn();
          });
        }
        break;
      case 'bishop':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf('Lunar laser-guided ballistic missile')) {
          List<List<int>> listD0 = [
            [1, 0],
            [-1, 0],
            [0, 0],
            [0, 1],
            [0, -1],
          ];
          List<List<int>> listListTarget = listD0
              .map((e) => [listNewTap[0] + e[0], listNewTap[1] + e[1]])
              .toList();
          int nDuration = 5;
          setState(() {
            //Target the cross area
            _mapStatusSelf = mapStatusTimerAdd(
                _nTurn, _mapStatusSelf, 'targeted', listListTarget, nDuration);
            _mapStatusRival = mapStatusTimerAdd(
                _nTurn, _mapStatusRival, 'targeted', listListTarget, nDuration);
            //Destroy the missile piece
            mapRemoveAdd(
                _mapSelf, _mapGraveSelf, [true, false], _listTap, '', []);
            endTurn();
          });
        }
        break;
      case 'knight':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf('Big-ass-L ("Big AL")')) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'knight', listNewTap);
            attackIfRivalSpot(listNewTap);
            markTracedBoxes(_listTap, listNewTap, false);
            endTurn();
          });
        } else if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected].indexOf('Big-ass-horse')) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'knight', listNewTap);
            mapRemoveAdd(
                _mapSelf,
                _mapGraveSelf,
                [true, true],
                [_listTap[0], _listTap[1] - 1],
                'pawn',
                [listNewTap[0], listNewTap[1] - 1]);
            attackIfRivalSpot(listNewTap);
            markTracedBoxes(_listTap, listNewTap, false);
            endTurn();
          });
        }
        break;
      case 'pawn':
        if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf('I gotchu homie')) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'pawn', listNewTap);
            markTracedBoxes(_listTap, listNewTap, false);
            endTurn();
          });
        }
        break;
    }
    resetSelection();
    resetPieceAbility();
  }

  //endregion Piece Ability functions

  //region Special Ability sector
  Future<void> specialAbilityOnPressed(
      String strSpecialAbilityName,
      bool isSpecialAbilitySingleUse,
      bool isSpecialAbilityAvailable,
      bool isSpecialAbilityActive,
      bool canSpecialAbilityReset) async {
    if (isSpecialAbilitySingleUse && isSpecialAbilityAvailable) {
      resetSelection();
      switch (strSpecialAbilityName) {
        case 'Invisible Hands':
          int nThresholdPieces = 3;
          int nPawnsPresent = _mapRival['pawn'].length;
          int nNonPawnsPresent = _mapRival.values
                  .map((e) => e.length)
                  .reduce((value, element) => value + element) -
              nPawnsPresent;
          bool areAdequatePiecesPresent = (nPawnsPresent >= nThresholdPieces &&
              nNonPawnsPresent >= nThresholdPieces);
          if (areAdequatePiecesPresent && !isSpecialAbilityActive) {
            _listIsSpecialAbilityActive[_indexActivePlayer] = true;
            primeSpecialAbility(strSpecialAbilityName);
          } else if (isSpecialAbilityActive) {
            canSpecialAbilityReset
                ? resetSpecialAbility()
                : completeSpecialAbility(true, false, false);
          } else if (!areAdequatePiecesPresent) {
            showInvalidSnackBar(context, 'Inadequate opponent pieces...');
          }
          break;
        case 'Necromancer':
          bool areAllGravesEmpty =
              !(_mapGraveSelf.values.any((element) => element > 0) ||
                  _mapGraveRival.values.any((element) => element > 0));
          if (!areAllGravesEmpty && !isSpecialAbilityActive) {
            _listIsSpecialAbilityActive[_indexActivePlayer] = true;
            primeSpecialAbility(strSpecialAbilityName);
          } else if (isSpecialAbilityActive) {
            canSpecialAbilityReset
                ? resetSpecialAbility()
                : completeSpecialAbility(false, false, false);
          } else if (areAllGravesEmpty) {
            showInvalidSnackBar(context, 'Graves are empty...');
          }
          break;
        case 'Puppet Master':
          if (_mapSelf['pawn'].isNotEmpty && !isSpecialAbilityActive) {
            int indexConfirmation = await showDialog(
                context: (context),
                builder: (context) {
                  return makeSpecialAbilityDialog(
                      context, ['Confirm use', 'Do not use']);
                });
            if (indexConfirmation == 0) {
              _mapStatusSelf = addCannotCheckmateStatus(
                  _nTurn, mapStatusTimerAdd, _mapStatusSelf);
              _listIsSpecialAbilityActive[_indexActivePlayer] = true;
              primeSpecialAbility(strSpecialAbilityName);
            }
          } else if (isSpecialAbilityActive) {
            canSpecialAbilityReset
                ? resetSpecialAbility()
                : completeSpecialAbility(true, true, true);
          } else if (_mapSelf['pawn'].isEmpty) {
            showInvalidSnackBar(context, 'No pawns present...');
          }
          break;
        case 'Sniper from Heaven':
          bool isRivalInSniperZone = false;
          _mapRival.values.forEach((eR) {
            eR.forEach((eR2) {
              isRivalInSniperZone = (isRivalInSniperZone ||
                  _mapStatusSelf['mySpecial']
                      .any((element) => fnd.listEquals(element, eR2)));
            });
          });
          if (isRivalInSniperZone && !isSpecialAbilityActive) {
            _listIsSpecialAbilityActive[_indexActivePlayer] = true;
            primeSpecialAbility(strSpecialAbilityName);
          } else if (isSpecialAbilityActive) {
            canSpecialAbilityReset
                ? resetSpecialAbility()
                : completeSpecialAbility(false, false, false);
          } else if (!isRivalInSniperZone) {
            showInvalidSnackBar(context, 'No enemy in zone...');
          }
          break;
        case 'Time Wizard':
          int minPlayerTurns = 2;
          bool isStartOfGame = _nTurn < (2 * minPlayerTurns);
          if (!isStartOfGame && !isSpecialAbilityActive) {
            setState(() {
              _listIsSpecialAbilityActive[_indexActivePlayer] = true;
              primeSpecialAbility(strSpecialAbilityName);
            });
          } else if (isSpecialAbilityActive) {
            canSpecialAbilityReset
                ? resetSpecialAbility()
                : completeSpecialAbility(false, false, false);
          } else if (isStartOfGame) {
            String strMessageTooEarly = 'Chill your ass...';
            showInvalidSnackBar(context, strMessageTooEarly);
          }
          break;
      }
    } else if (isSpecialAbilitySingleUse && !isSpecialAbilityAvailable) {
      int nMax = _listTimesSpecialAbilityMax[_indexActivePlayer];
      int nUses = _listTimesSpecialAbilityUsed[_indexActivePlayer];
      if (nMax < 2 || nUses >= nMax) {
        showInvalidSnackBar(context, 'Ability already used!');
      } else if (nUses < nMax) {
        showInvalidSnackBar(context, 'Ability cooling down!');
      }
    } else {
      if (!(strSpecialAbilityName == 'Mind Control Tower' &&
          _mapStatusSelf['mySpecial'].isEmpty)) {
        showInvalidSnackBar(context, 'Ability continuously active!');
      } else {
        showInvalidSnackBar(context, 'Control chain broken...');
      }
    }
  }

  //endregion Special Ability sector

  //region Special Ability functions
  void primeSpecialAbility(String strSpecialAbilityName) async {
    switch (strSpecialAbilityName) {
      case 'Invisible Hands':
        _listSpecialAbilitySubtype[_indexActivePlayer] = await showDialog(
            context: (context),
            builder: (context) {
              return makeSpecialAbilityDialog(
                  context, ['Restrict Pawns', 'Restrict Non-Pawns']);
            });
        if (_listSpecialAbilitySubtype[_indexActivePlayer] == null) {
          resetSpecialAbility();
        } else {
          setState(() {
            int dTurnsEffect = 3;
            int dTurnsCoolDown = 6;
            _mapFutureBuilder
                .addAll({(_nTurn + dTurnsEffect): 'Invisible Hands'});
            _mapFutureBuilderArgs.addAll({
              (_nTurn + dTurnsEffect): [
                _listSpecialAbilitySubtype[_indexActivePlayer]
              ]
            });
            if (_listTimesSpecialAbilityUsed[_indexActivePlayer] <
                _listTimesSpecialAbilityMax[_indexActivePlayer] - 1) {
              _mapFutureBuilder
                  .addAll({(_nTurn + dTurnsCoolDown): 'Invisible Hands'});
              _mapFutureBuilderArgs.addAll({
                (_nTurn + dTurnsCoolDown): [2]
              });
            }
            completeSpecialAbility(true, false, true);
          });
        }
        break;
      case 'Mesmer':
        bool isPreGame = _nTurn < 0;
        bool isDirectAttacked = _mapStatusSelf['mySpecialLabel'].isNotEmpty &&
            _mapStatusSelf['mySpecial'].isEmpty;
        bool isIndirectlyDestroyed = _mapStatusSelf['mySpecial'].isNotEmpty &&
            !checkOccupied(_mapSelf, _mapStatusSelf['mySpecial'].first);
        if (isPreGame) {
          _listIsSpecialAbilityActive[_indexActivePlayer] = true;
          setState(() {
            _listTupleAbsSpecialAbility =
                mapSpecialAbilityFunction[strSpecialAbilityName](_mapSelf);
          });
        } else if (isDirectAttacked) {
          _listTupleAbsSpecialAbility =
              getInitialTerritory(true, _mapSelf, _mapRival, true);
        } else if (isIndirectlyDestroyed) {
          _mapSelf.forEach((key, value) {
            if (pieces.mapPieceRank[key] <=
                _mapStatusSelf['mySpecialLabel'].first[0]) {
              _listTupleAbsSpecialAbility.addAll(value);
            }
          });
        }
        break;
      case 'Mind Control Tower':
        bool isPreGame = _nTurn < 0;
        if (isPreGame) {
          _listIsSpecialAbilityActive[_indexActivePlayer] = true;
          setState(() {
            if (_mapStatusSelf['mySpecial'].isEmpty) {
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      0, _mapSelf, _mapRival);
            } else {
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      1, _mapSelf, _mapRival);
            }
          });
        }
        break;
      case 'Necromancer':
        _listSpecialAbilitySubtype[_indexActivePlayer] = await showDialog(
            context: (context),
            builder: (context) {
              return makeSpecialAbilityDialog(context, ['Revive', 'Sacrifice']);
            });
        if (_listSpecialAbilitySubtype[_indexActivePlayer] == null) {
          resetSpecialAbility();
        } else {
          setState(() {
            _listTupleAbsSpecialAbility =
                mapSpecialAbilityFunction[strSpecialAbilityName](
                    _listSpecialAbilitySubtype[_indexActivePlayer],
                    _mapSelf,
                    _mapRival);
          });
        }
        break;
      case 'Puppet Master':
        int nDuration = 0;
        setState(() {
          _mapStatusSelf = mapStatusTimerAdd(
              _nTurn, _mapStatusSelf, 'forced', _mapSelf['pawn'], nDuration);
        });
        break;
      case 'Sniper from Heaven':
        bool isPreGame = _nTurn < 0;
        if (isPreGame) {
          _listIsSpecialAbilityActive[_indexActivePlayer] = true;
          setState(() {
            if (widget.listSpecialAbilityExtra[_indexActivePlayer] == 1) {
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      _mapSelf, _mapRival, _mapStatusSelf, true);
            } else if (widget.listSpecialAbilityExtra[_indexActivePlayer] ==
                2) {
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      _mapSelf, _mapRival, _mapStatusSelf, true);
            }
          });
        } else {
          setState(() {
            _listTupleAbsSpecialAbility =
                mapSpecialAbilityFunction[strSpecialAbilityName](
                    _mapSelf, _mapRival, _mapStatusSelf, false);
          });
        }
        break;
    }
  }

  void primeSpecialAbilityFromBuild() {
    bool isPreGame = _nTurn < 0;
    bool isMesmerAndDirectAttacked =
        widget.listSpecialAbilityName[_indexActivePlayer] == 'Mesmer' &&
            _mapStatusSelf['mySpecialLabel'].isNotEmpty &&
            _mapStatusSelf['mySpecial'].isEmpty;
    bool isMesmerAndIndirectlyDestroyed =
        widget.listSpecialAbilityName[_indexActivePlayer] == 'Mesmer' &&
            _mapStatusSelf['mySpecial'].isNotEmpty &&
            !checkOccupied(_mapSelf, _mapStatusSelf['mySpecial'].first);
    if (isPreGame ||
        isMesmerAndDirectAttacked ||
        isMesmerAndIndirectlyDestroyed) {
      primeSpecialAbility(widget.listSpecialAbilityName[_indexActivePlayer]);
    }
  }

  SimpleDialog makeSpecialAbilityDialog(
      BuildContext context, List<String> listStringOptions) {
    const int indexToListView = 4;
    const Color colorDialog = Colors.grey;
    const double fractionHeightListView = 0.6;
    const double fractionWidthDialog = 0.75;
    const double fractionWidthButton = 0.8;
    const double sizePadding = 5;
    const double sizeBorderRadius = 10;
    const double sizeBorderWidth = 2;
    const TextStyle styleSub = TextStyle(
        color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold);
    Color colorActive =
        _indexActivePlayer == 0 ? players.colorTeam0 : players.colorTeam1;

    List<Padding> listChildren = listStringOptions
        .map((e) => Padding(
              padding: EdgeInsets.all(sizePadding),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    fractionWidthDialog *
                    fractionWidthButton,
                decoration: BoxDecoration(
                  color: colorActive,
                  borderRadius: BorderRadius.circular(sizeBorderRadius),
                  border:
                      Border.all(color: Colors.black, width: sizeBorderWidth),
                ),
                child: TextButton(
                  child: Text(
                    e,
                    style: styleSub,
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.pop(context, listStringOptions.indexOf(e));
                  },
                ),
              ),
            ))
        .toList();
    return SimpleDialog(
      backgroundColor: colorDialog,
      children: [
        Builder(builder: (context) {
          if (listChildren.length < indexToListView) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: listChildren,
            );
          } else {
            return Container(
                height:
                    MediaQuery.of(context).size.height * fractionHeightListView,
                width: MediaQuery.of(context).size.width * fractionWidthDialog,
                child: ListView.builder(
                    itemCount: listChildren.length,
                    itemBuilder: (context, index) {
                      return listChildren[index];
                    }));
          }
        }),
      ],
    );
  }

  void completeSpecialAbility(
      bool toIncrementTimesUsed, bool toEndTurn, bool toMakeNotAvailable) {
    setState(() {
      if (toIncrementTimesUsed) {
        _listTimesSpecialAbilityUsed[_indexActivePlayer]++;
      }
      _listIsSpecialAbilityActive[_indexActivePlayer] = false;
      _listIsSpecialAbilityAvailable[_indexActivePlayer] = !toMakeNotAvailable;
      _listTupleAbsSpecialAbility.clear();
      if (toEndTurn) {
        endTurn();
      }
    });
  }

  void resetSpecialAbility() {
    setState(() {
      _listIsSpecialAbilityActive[_indexActivePlayer] = false;
      _listIsSpecialAbilityAvailable[_indexActivePlayer] = true;
      _listTupleAbsSpecialAbility.clear();
    });
  }

  //endregion Special Ability functions

  //region Special-Gesture hybrid
  void performSpecialGestureRoutine(String strSpecialAbilityName,
      int nSpecialAbility, List<int> listNewTap) async {
    switch (strSpecialAbilityName) {
      case 'Mesmer':
        bool arePotentialSpots = _listTupleAbsSpecialAbility.isNotEmpty;
        bool isPreGame = _nTurn < 0;
        bool isDirectAttacked = _mapStatusSelf['mySpecialLabel'].isNotEmpty &&
            _mapStatusSelf['mySpecial'].isEmpty;
        bool isIndirectlyDestroyed = _mapStatusSelf['mySpecial'].isNotEmpty &&
            !checkOccupied(_mapSelf, _mapStatusSelf['mySpecial'].first);
        bool isPotentialZone = (arePotentialSpots &&
            _listTupleAbsSpecialAbility
                .any((element) => fnd.listEquals(element, listNewTap)));
        if (arePotentialSpots) {
          if (isPreGame && isPotentialZone) {
            _mapStatusSelf['mySpecial'].add(listNewTap);
            pieces.mapPieceRank.forEach((key, value) {
              if (key == getPieceName(_mapSelf, listNewTap)) {
                _mapStatusSelf['mySpecialLabel'].add([value]);
              }
            });
            completeSpecialAbility(false, true, false);
          } else if (!isPreGame && isDirectAttacked && isPotentialZone) {
            List<int> tupleMesmerPiece = _mapStatusSelf['mySpecialLabel'].first;
            setState(() {
              mapRemoveAdd(
                  _mapSelf,
                  _mapGraveSelf,
                  [true, true],
                  tupleMesmerPiece,
                  getPieceName(_mapSelf, tupleMesmerPiece),
                  listNewTap);
              _listTupleAbsSpecialAbility.clear();
              _mapStatusSelf['mySpecialLabel'].clear();
            });
          } else if (!isPreGame && isDirectAttacked && !isPotentialZone) {
            setState(() {
              _listTupleAbsSpecialAbility.clear();
              _mapStatusSelf['mySpecialLabel'].clear();
            });
            bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
            performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
          } else if (!isPreGame && isIndirectlyDestroyed && isPotentialZone) {
            setState(() {
              _mapStatusSelf['mySpecial'].clear();
              _mapStatusSelf['mySpecialLabel'].clear();
              _mapStatusSelf['mySpecial'].add(listNewTap);
              _mapStatusSelf['mySpecialLabel'].add(
                  [pieces.mapPieceRank[getPieceName(_mapSelf, listNewTap)]]);
              _listTupleAbsSpecialAbility.clear();
            });
          }
        } else {
          if (!isPreGame && (isDirectAttacked || isIndirectlyDestroyed)) {
            _mapStatusSelf['mySpecial'].clear();
            _mapStatusSelf['mySpecialLabel'].clear();
          }
          bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
          performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
        }
        break;
      case 'Mind Control Tower':
        bool isPreGame = _nTurn < 0;
        bool isPotentialZone = (_listTupleAbsSpecialAbility.isNotEmpty &&
            _listTupleAbsSpecialAbility
                .any((element) => fnd.listEquals(element, listNewTap)));
        if (isPreGame && isPotentialZone) {
          _mapStatusSelf['mySpecial'].add(listNewTap);
          if (_mapStatusSelf['mySpecial'].length <= 1) {
            completeSpecialAbility(false, false, false);
          } else {
            completeSpecialAbility(false, true, false);
          }
        } else if (!isPreGame) {
          bool isMotionPotentialZone = (_listTap.isNotEmpty &&
              _listTupleDMotion.isNotEmpty &&
              _listTupleDMotion.any((element) => fnd.listEquals(
                  [element[0] + _listTap[0], element[1] + _listTap[1]],
                  listNewTap)));
          bool isNewTapControlledPieceAttack = isMotionPotentialZone &&
              checkOccupied(_mapRival, listNewTap) &&
              _mapStatusSelf['mySpecial']
                  .any((element) => fnd.listEquals(element, listNewTap));
          if (_mapStatusSelf['mySpecial'].length == 2 &&
              isNewTapControlledPieceAttack) {
            setState(() {
              mapRemoveAdd(
                  _mapRival, _mapGraveRival, [true, false], listNewTap, '', []);
              mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                  getPieceName(_mapSelf, _listTap), listNewTap);
              resetSelection();
              _mapStatusSelf['mySpecial'].removeWhere(
                  (element) => fnd.listEquals(element, listNewTap));
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      1, _mapSelf, _mapRival);
            });
          } else if (_mapStatusSelf['mySpecial'].length == 1 &&
              isPotentialZone) {
            _mapStatusSelf['mySpecial'].add(listNewTap);
            completeSpecialAbility(false, true, false);
          } else if (_listTupleAbsSpecialAbility.isEmpty) {
            bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
            performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
          }
        }
        break;
      case 'Necromancer':
        bool isPotentialZone = (_listTupleAbsSpecialAbility.isNotEmpty &&
            _listTupleAbsSpecialAbility
                .any((element) => fnd.listEquals(element, listNewTap)));
        if (isPotentialZone) {
          switch (nSpecialAbility) {
            case 0:
              List<String> listStringGraveName = [];
              _mapGraveSelf.forEach((key, value) {
                if (value > 0) {
                  listStringGraveName.add('My $key');
                }
              });
              _mapGraveRival.forEach((key, value) {
                if (value > 0 && key != 'queen') {
                  listStringGraveName.add('Opp. $key');
                }
              });
              int indexPieceRevive = await showDialog(
                  context: (context),
                  builder: (context) {
                    return makeSpecialAbilityDialog(
                        context, listStringGraveName);
                  });
              if (indexPieceRevive != null) {
                String strPlayer =
                    listStringGraveName[indexPieceRevive].split(' ')[0];
                String strPieceName =
                    listStringGraveName[indexPieceRevive].split(' ')[1];
                mapRemoveAdd(
                    _mapSelf,
                    strPlayer == 'My' ? _mapGraveSelf : _mapGraveRival,
                    [false, true],
                    [],
                    strPieceName,
                    listNewTap);
                _mapStatusSelf = addCannotCheckmateStatus(
                    _nTurn, mapStatusTimerAdd, _mapStatusSelf);
                markTracedBoxes(listNewTap, listNewTap, true);
                completeSpecialAbility(true, true, true);
              }
              break;
            case 1:
              int rankPieceSelected =
                  pieces.mapPieceRank[getPieceName(_mapSelf, listNewTap)];
              List<String> listStringGraveName = [];
              _mapGraveSelf.forEach((key, value) {
                if (value > 0 && pieces.mapPieceRank[key] < rankPieceSelected) {
                  listStringGraveName.add('My $key');
                }
              });
              int indexPieceRevive = await showDialog(
                  context: (context),
                  builder: (context) {
                    return makeSpecialAbilityDialog(
                        context, listStringGraveName);
                  });
              if (indexPieceRevive != null) {
                String strPieceName =
                    listStringGraveName[indexPieceRevive].split(' ')[1];
                mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], listNewTap,
                    strPieceName, listNewTap);
                _mapStatusSelf = mapStatusTimerAdd(
                    _nTurn, _mapStatusSelf, 'fixed', [listNewTap], 0);
                completeSpecialAbility(false, false, false);
              }
              break;
          }
        }
        break;
      case 'Puppet Master':
        bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
        performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
        break;
      case 'Navy SEAL Special Operations Units':
        bool isNewTapPawnAttack = _listTap.isNotEmpty
            ? ((listNewTap[0] == _listTap[0] - 1 &&
                    listNewTap[1] == _listTap[1] + 1 &&
                    checkOccupied(_mapRival, listNewTap)) ||
                (listNewTap[0] == _listTap[0] + 1 &&
                    listNewTap[1] == _listTap[1] + 1 &&
                    checkOccupied(_mapRival, listNewTap)))
            : false;
        if (_listTap.isNotEmpty &&
            getPieceName(_mapSelf, _listTap) == 'pawn' &&
            isNewTapPawnAttack) {
          int indexAttackType = await showDialog(
              context: (context),
              builder: (context) {
                return makeSpecialAbilityDialog(
                    context, ['Move & Attack', 'Stay & Attack']);
              });
          if (indexAttackType != null) {
            setState(() {
              if (indexAttackType == 0) {
                mapRemoveAdd(_mapRival, _mapGraveRival, [true, false],
                    listNewTap, '', []);
                mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                    'pawn', listNewTap);
                markTracedBoxes(_listTap, listNewTap, false);
              } else if (indexAttackType == 1) {
                mapRemoveAdd(_mapRival, _mapGraveRival, [true, false],
                    listNewTap, '', []);
                markTracedBoxes(_listTap, listNewTap, true);
              }
              endTurn();
            });
          } else {
            setState(() {
              resetSelection();
            });
          }
        } else {
          bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
          performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
        }
        break;
      case 'Sniper from Heaven':
        bool isPreGame = _nTurn < 0;
        bool isPotentialZone = (_listTupleAbsSpecialAbility.isNotEmpty &&
            _listTupleAbsSpecialAbility
                .any((element) => fnd.listEquals(element, listNewTap)));
        if (isPreGame && isPotentialZone) {
          if (widget.listSpecialAbilityExtra[_indexActivePlayer] == 1) {
            _mapStatusSelf['mySpecial'].addAll(_listTupleAbsSpecialAbility
                .where((element) => element[1] == listNewTap[1]));
            if (_mapStatusSelf['mySpecial'].length <= nDiv) {
              completeSpecialAbility(false, false, false);
            } else {
              completeSpecialAbility(false, true, false);
            }
          } else if (widget.listSpecialAbilityExtra[_indexActivePlayer] == 2) {
            _mapStatusSelf['mySpecial'].addAll(_listTupleAbsSpecialAbility
                .where((element) => element[1] == listNewTap[1]));
            completeSpecialAbility(false, true, false);
          }
        } else if (!isPreGame && isPotentialZone) {
          mapRemoveAdd(
              _mapRival, _mapGraveRival, [true, false], listNewTap, '', []);
          _listTimesSpecialAbilityUsed[_indexActivePlayer]++;
          bool toMakeNotAvailable =
              (_listTimesSpecialAbilityUsed[_indexActivePlayer] >=
                  _listTimesSpecialAbilityMax[_indexActivePlayer]);
          if (toMakeNotAvailable) {
            _mapStatusSelf['mySpecial'].clear();
          }
          completeSpecialAbility(false, true, toMakeNotAvailable);
        }
        break;
      case 'Time Wizard':
        bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
        performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
        break;
      default:
        break;
    }
  }

  //endregion Special-Gesture hybrid

  //region Gesture functions
  void functionTap(double dimBoard, double dimBox, TapDownDetails details) {
    int iTap = (details.localPosition.dx / dimBox).floor();
    int jTap = ((dimBoard - details.localPosition.dy) / dimBox).floor();
    bool isPreGame = _nTurn < 0;
    bool isPieceAbilityActive = _mapPieceAbilityActive.isNotEmpty;
    bool isSingleUseSpecialActive =
        _listTimesSpecialAbilityMax[_indexActivePlayer] != 0 &&
            _listIsSpecialAbilityActive[_indexActivePlayer];
    //Region for pre-game selections
    if (isPreGame) {
      performSpecialGestureRoutine(
          widget.listSpecialAbilityName[_indexActivePlayer],
          _listSpecialAbilitySubtype[_indexActivePlayer],
          [iTap, jTap]);
    }
    //Region for regular motion based selections
    else if (!isPieceAbilityActive &&
        !isSingleUseSpecialActive &&
        _listTimesSpecialAbilityMax[_indexActivePlayer] != 0) {
      bool isSelfPieceZone = checkOccupied(_mapSelf, [iTap, jTap]);
      performMotionRoutine(isSelfPieceZone, iTap, jTap);
    }
    //region for piece ability based taps
    else if (isPieceAbilityActive) {
      bool isPotentialZone = (_listTupleDPieceAbility.isNotEmpty &&
          _listTupleDPieceAbility.any((element) => fnd.listEquals(
              [element[0] + _listTap[0], element[1] + _listTap[1]],
              [iTap, jTap])));
      if (isPotentialZone) {
        performPieceAbility([iTap, jTap]);
      }
    }
    //region for single use abilities based taps
    else if (isSingleUseSpecialActive) {
      performSpecialGestureRoutine(
          widget.listSpecialAbilityName[_indexActivePlayer],
          _listSpecialAbilitySubtype[_indexActivePlayer],
          [iTap, jTap]);
    }
    //region for continuous abilities - Not in PreGame
    else if (!isSingleUseSpecialActive &&
        _listTimesSpecialAbilityMax[_indexActivePlayer] == 0) {
      switch (widget.listSpecialAbilityName[_indexActivePlayer]) {
        case 'Navy SEAL Special Operations Units':
          performSpecialGestureRoutine(
              widget.listSpecialAbilityName[_indexActivePlayer],
              _listSpecialAbilitySubtype[_indexActivePlayer],
              [iTap, jTap]);
          break;
        case 'Mesmer':
          performSpecialGestureRoutine(
              widget.listSpecialAbilityName[_indexActivePlayer],
              0,
              [iTap, jTap]);
          break;
        case 'Mind Control Tower':
          performSpecialGestureRoutine(
              widget.listSpecialAbilityName[_indexActivePlayer],
              0,
              [iTap, jTap]);
          break;
      }
    }
  }

  void performMotionRoutine(bool isSelfPieceZone, int iTap, int jTap) {
    bool areForcedZonesPresent = _mapStatusSelf['forced'].isNotEmpty;
    bool isForcedSelfPieceZone = areForcedZonesPresent
        ? _mapStatusSelf['forced']
            .any((element) => fnd.listEquals(element, [iTap, jTap]))
        : false;
    bool isSelfFixedZone = isSelfPieceZone
        ? _mapStatusSelf['fixed']
            .any((element) => fnd.listEquals(element, [iTap, jTap]))
        : false;
    //Check if fixed from Mind Control (under mySpecial section)
    if ((widget.listSpecialAbilityName[0] == 'Mind Control Tower' &&
            (_nTurn % 2 == 0 ? _mapStatusSelf : _mapStatusRival)['mySpecial']
                .any((element) => fnd.listEquals(element, [iTap, jTap]))) ||
        (widget.listSpecialAbilityName[1] == 'Mind Control Tower' &&
            (_nTurn % 2 == 0 ? _mapStatusRival : _mapStatusSelf)['mySpecial']
                .any((element) => fnd.listEquals(element, [iTap, jTap])))) {
      isSelfFixedZone = true;
    }
    bool isFreeSelfPieceZone = isSelfPieceZone && !isSelfFixedZone;
    bool isPotentialZone = (_listTupleDMotion.isNotEmpty &&
        _listTupleDMotion.any((element) => fnd.listEquals(
            [element[0] + _listTap[0], element[1] + _listTap[1]],
            [iTap, jTap])));
    bool isResetZone =
        (_listTap.isNotEmpty && !isSelfPieceZone && !isPotentialZone);
    if ((areForcedZonesPresent && isForcedSelfPieceZone) ||
        (!areForcedZonesPresent && isFreeSelfPieceZone) ||
        isPotentialZone ||
        isResetZone) {
      setState(() {
        if (isSelfPieceZone) {
          _listTap = [iTap, jTap];
          _strPieceSelected = getPieceName(_mapSelf, _listTap);
          _listTupleDMotion = mapPieceMotionFunction[_strPieceSelected](
              _listTap,
              _mapSelf,
              _mapRival,
              (widget.listSpecialAbilityName[_indexActivePlayer] ==
                          'Navy SEAL Special Operations Units' &&
                      _strPieceSelected == 'pawn')
                  ? false
                  : true);
        } else if (isPotentialZone) {
          bool toMoveSpecialTagWithPiece =
              (widget.listSpecialAbilityName[_indexActivePlayer] == 'Mesmer' &&
                      _mapStatusSelf['mySpecial'].any((element) =>
                          fnd.listEquals(element, [_listTap[0], _listTap[1]])))
                  ? true
                  : false;
          mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
              _strPieceSelected, [iTap, jTap]);
          attackIfRivalSpot([iTap, jTap]);
          if (areForcedZonesPresent) {
            _mapStatusSelf =
                mapStatusTimerRemove(_mapStatusSelf, 'forced', [_listTap]);
          }
          if (toMoveSpecialTagWithPiece) {
            _mapStatusSelf['mySpecial']
                .removeWhere((element) => fnd.listEquals(element, _listTap));
            _mapStatusSelf['mySpecial'].add([iTap, jTap]);
          }
          markTracedBoxes(_listTap, [iTap, jTap], false);
          resetSelection();
          if (_mapStatusSelf['forced'].length == 0) {
            bool isSpecialAbilitySingleUse =
                _listTimesSpecialAbilityMax[_indexActivePlayer] != 0;
            bool toRepeatTurn =
                widget.listSpecialAbilityName[_indexActivePlayer] ==
                        'Time Wizard' &&
                    _listIsSpecialAbilityActive[_indexActivePlayer];
            if (isSpecialAbilitySingleUse &&
                _listIsSpecialAbilityActive[_indexActivePlayer] &&
                !toRepeatTurn) {
              completeSpecialAbility(true, true, true);
            } else if (toRepeatTurn) {
              _mapStatusSelf = addCannotCheckmateStatus(
                  _nTurn, mapStatusTimerAdd, _mapStatusSelf);
              resetSelection();
              completeSpecialAbility(true, false, true);
            } else {
              endTurn();
            }
          }
        } else {
          resetSelection();
        }
      });
    }
  }

  void markTracedBoxes(
      List<int> listTap, List<int> listNewTap, bool isOldBoxOnly) {
    _mapStatusSelf = mapStatusTimerAdd(
        _nTurn,
        _mapStatusSelf,
        'traced',
        [
          [listTap[0], listTap[1]]
        ],
        players.nDurationTraced);
    if (!isOldBoxOnly) {
      _mapStatusSelf = mapStatusTimerAdd(
          _nTurn,
          _mapStatusSelf,
          'traced',
          [
            [listNewTap[0], listNewTap[1]]
          ],
          players.nDurationTraced);
    }
  }

//endregion Gesture functions

//region Turn functions
  void endTurn() {
    resetSelection();
    _nTurn++;
    bool isSamePlayer = _indexActivePlayer == _nTurn % 2;
    if (!isSamePlayer) {
      _indexActivePlayer = _nTurn % 2;
      performFutureFunction();
      performTurnTranspositionsLocal();
    }
  }

  void performTurnTranspositionsLocal() {
    List<Map> listMapTransposed = performTurnTranspositions(
        _nTurn,
        _indexActivePlayer,
        _mapSelf,
        _mapRival,
        _mapStatusSelf,
        _mapStatusRival,
        _mapGraveSelf,
        _mapGraveRival,
        _toTransposeBoard);
    _mapSelf = listMapTransposed[0];
    _mapRival = listMapTransposed[1];
    _mapStatusSelf = listMapTransposed[2];
    _mapStatusRival = listMapTransposed[3];
    _mapGraveSelf = listMapTransposed[4];
    _mapGraveRival = listMapTransposed[5];
  }

  void performFutureFunction() {
    if (_mapFutureBuilder.isNotEmpty &&
        _mapFutureBuilder.keys.contains(_nTurn)) {
      switch (_mapFutureBuilder[_nTurn]) {
        case 'Invisible Hands':
          int nDuration = 0;
          List<List<int>> listTupleRestrict = [];
          switch (_mapFutureBuilderArgs[_nTurn][0]) {
            case 0:
              listTupleRestrict.addAll(_mapRival['pawn']);
              _mapStatusRival = mapStatusTimerAdd(_nTurn, _mapStatusRival,
                  'fixed', listTupleRestrict, nDuration);
              break;
            case 1:
              listTupleRestrict.addAll(_mapRival['queen']);
              listTupleRestrict.addAll(_mapRival['rook']);
              listTupleRestrict.addAll(_mapRival['bishop']);
              listTupleRestrict.addAll(_mapRival['knight']);
              _mapStatusRival = mapStatusTimerAdd(_nTurn, _mapStatusRival,
                  'fixed', listTupleRestrict, nDuration);
              break;
            case 2:
              resetSpecialAbility();
              break;
          }
      }
    }
  }

//endregion Turn functions

//region Reset functions
  void resetSelection() {
    _strPieceSelected = null;
    _listTap.clear();
    _listTupleDMotion.clear();
    _mapPieceAbilityActive.clear();
  }

  void resetPieceAbility() {
    _mapPieceAbilityActive.clear();
    _listTupleDPieceAbility.clear();
  }

//endregion Reset functions

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    initTimesSpecialAbilityMax();
    initPreGame();
    initBoardColors();
    initSpecialAbility();
    super.initState();
  }

  void initTimesSpecialAbilityMax() {
    _listTimesSpecialAbilityMax = [];
    int i = 0;
    widget.listSpecialAbilityName.forEach((element) {
      if (widget.listSpecialAbilityExtra[i] == 0) {
        int nMax = specials.mapSpecialAttributes[element][0];
        _listTimesSpecialAbilityMax.add(nMax);
      } else {
        switch (element) {
          case 'Sniper from Heaven':
            _listTimesSpecialAbilityMax.add(widget.listSpecialAbilityExtra[i]);
            break;
        }
      }
      i++;
    });
  }

  void initPreGame() {
    int nPreGameSpecials = widget.listSpecialAbilityName
        .map((e) => specials.mapSpecialAttributes[e][3])
        .reduce((value, element) => value + element);
    if (specials.mapSpecialAttributes[widget.listSpecialAbilityName[0]][3] ==
        1) {
      _nTurn = -nPreGameSpecials;
      _indexActivePlayer = 0;
    } else if (specials.mapSpecialAttributes[widget.listSpecialAbilityName[1]]
            [3] ==
        1) {
      _nTurn = -nPreGameSpecials;
      _indexActivePlayer = 1;
      performTurnTranspositionsLocal();
    } else {
      _nTurn = 0;
      _indexActivePlayer = _nTurn % 2;
    }
  }

  Future<void> initBoardColors() async {
    _listBoardColors = await loadBoardColors();
    setState(() {});
  }

  void initSpecialAbility() {
    if (!_listIsSpecialAbilityActive[_indexActivePlayer] &&
        !(_listTimesSpecialAbilityMax[_indexActivePlayer] != 0)) {
      _listIsSpecialAbilityActive[_indexActivePlayer] = true;
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  //region Build functions
  Scaffold makeMainScaffold() {
    const styleTextPass =
        TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
    bool isPreGame = _nTurn < 0;
    double dimBoard = math.min(
        MediaQuery.of(context).size.height, MediaQuery.of(context).size.width);
    double dimBox = dimBoard / nDiv;
    String strAppBarText = isPreGame
        ? "${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Pre-Game Select"
        : "${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Turn ${_nTurn + 1}";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            icon: Icon(Icons.arrow_forward_ios),
            label: Text(
              'Pass',
              style: styleTextPass,
            ),
            onPressed: () {
              bool isSingleUseSpecialAbilityActive =
                  _listIsSpecialAbilityActive[_indexActivePlayer] &&
                      specials.mapSpecialAttributes[widget
                              .listSpecialAbilityName[_indexActivePlayer]][0] !=
                          0;
              bool isPieceAbilityActive = _mapPieceAbilityActive.isNotEmpty;
              if (!isPreGame &&
                  !isSingleUseSpecialAbilityActive &&
                  !isPieceAbilityActive) {
                setState(() {
                  endTurn();
                });
              }
            },
          ),
        ],
        title: Text(
          strAppBarText,
        ),
        backgroundColor:
            (_indexActivePlayer == 0 ? players.colorTeam0 : players.colorTeam1),
      ),
      body: WillPopScope(
        child: Column(
          children: [
            Divider(
              height: GameLayoutOffline.sizeDivider,
              thickness: GameLayoutOffline.sizeDivider,
              color: Colors.amberAccent,
            ),
            GestureDetector(
              child: makeBoard(dimBoard, dimBox, _mapSelf, _mapRival),
              onTapDown: (details) => functionTap(dimBoard, dimBox, details),
            ),
            Divider(
              height: GameLayoutOffline.sizeDivider,
              thickness: GameLayoutOffline.sizeDivider,
              color: Colors.amberAccent,
            ),
            !isPreGame
                ? FittedBox(
                    child: ToggleButtons(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            'Special Ability',
                            style: GameLayoutOffline.styleSub,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            'Piece Ability',
                            style: GameLayoutOffline.styleSub,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(
                          GameLayoutOffline.sizeBorderRadius),
                      isSelected: _listToggleAbility,
                      color: Colors.white,
                      borderColor: Theme.of(context).scaffoldBackgroundColor,
                      fillColor: Colors.white,
                      selectedColor: Theme.of(context).scaffoldBackgroundColor,
                      onPressed: (index) {
                        bool isPieceAbilityActive =
                            _mapPieceAbilityActive.isNotEmpty;
                        bool isSingleUseSpecialActive =
                            _listTimesSpecialAbilityMax[_indexActivePlayer] !=
                                    0 &&
                                _listIsSpecialAbilityActive[_indexActivePlayer];
                        if (!isPieceAbilityActive &&
                            !isSingleUseSpecialActive) {
                          setState(() {
                            _listToggleAbility =
                                _listToggleAbility.map((e) => !e).toList();
                          });
                        }
                      },
                    ),
                  )
                : Container(),
            !isPreGame
                ? Expanded(
                    child: _listToggleAbility[0]
                        ? SpecialAbilitySector(
                            indexPlayer: _indexActivePlayer,
                            strSpecialAbilityName: widget
                                .listSpecialAbilityName[_indexActivePlayer],
                            strRivalSpecialAbilityName: widget
                                .listSpecialAbilityName[1 - _indexActivePlayer],
                            isSpecialAbilitySingleUse:
                                _listTimesSpecialAbilityMax[
                                        _indexActivePlayer] !=
                                    0,
                            isSpecialAbilityActive:
                                _listIsSpecialAbilityActive[_indexActivePlayer],
                            isSpecialAbilityAvailable:
                                _listIsSpecialAbilityAvailable[
                                    _indexActivePlayer],
                            canSpecialAbilityReset:
                                specials.mapSpecialAttributes[
                                        widget.listSpecialAbilityName[
                                            _indexActivePlayer]][2] ==
                                    1,
                            specialAbilityOnPressed: specialAbilityOnPressed,
                          )
                        : PieceAbilitySector(
                            strPieceName: _strPieceSelected,
                            mapPieceAbilityActive: _mapPieceAbilityActive,
                            pieceAbilityOnPressed: pieceAbilityOnPressed,
                          ),
                  )
                : Container(),
          ],
        ),
        onWillPop: () async {
          if (!_isToPop) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text('Tap back again to exit'),
                  );
                });
            _isToPop = !_isToPop;
            return false;
          } else {
            return _isToPop;
          }
        },
      ),
    );
  }

  GameOverOverlay makeGameOverOverlay() {
    const String strMessageLose = 'Game over\n\nYou lose...';
    const String strMessageWin = 'Game over\n\nYou win!!!';
    return GameOverOverlay(
      strMessage:
          _listGameOverByKing.first == 1 ? strMessageLose : strMessageWin,
      colorMessage: _listGameOverByKing.last == 0
          ? players.colorTeam0
          : players.colorTeam1,
    );
  }

  //endregion Build functions

  @override
  Widget build(BuildContext context) {
    primeSpecialAbilityFromBuild();
    bool isBuildReady =
        MediaQuery.of(context).orientation == Orientation.portrait &&
            _listBoardColors != null;
    if (isBuildReady) {
      return SafeArea(
        child: _listGameOverByKing.first != 0
            ? Stack(
                children: [
                  makeMainScaffold(),
                  makeGameOverOverlay(),
                ],
              )
            : makeMainScaffold(),
      );
    } else {
      return Scaffold();
    }
  }
}
