import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' as fnd;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jps_chess/data/database_data.dart' as datas;
import 'package:jps_chess/data/pieces_data.dart' as pieces;
import 'package:jps_chess/data/player_data.dart' as players;
import 'package:jps_chess/data/special_data.dart' as specials;
import 'package:jps_chess/functions/draw_functions.dart';
import 'package:jps_chess/functions/general_game_functions.dart';
import 'package:jps_chess/functions/motion_functions.dart';
import 'package:jps_chess/functions/piece_ability_functions.dart';
import 'package:jps_chess/functions/settings_functions.dart';
import 'package:jps_chess/functions/special_ability_functions.dart';
import 'package:jps_chess/widgets/board.dart';
import 'package:jps_chess/widgets/disconnect_overlay.dart';
import 'package:jps_chess/widgets/game_over_overlay.dart';
import 'package:jps_chess/functions/game_over_functions.dart';
import 'package:jps_chess/widgets/special_ability_sector.dart';
import 'package:jps_chess/widgets/piece_ability_sector.dart';
import 'package:jps_chess/functions/sector_functions.dart';

int nDiv = 8;
int rMax = nDiv - 1;
int j00 = 0;
int j01 = 1;
int j10 = nDiv - 1;
int j11 = nDiv - 2;

class GameLayoutOnline extends StatefulWidget {
  static const routeName = '/game-layout-online';

  final String strServerName;

  const GameLayoutOnline({Key key, this.strServerName}) : super(key: key);

  static const double sizeDivider = 4;
  static const TextStyle styleSub =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 24);
  static const double sizeBorderRadius = 5;

  @override
  _GameLayoutOnlineState createState() => _GameLayoutOnlineState();
}

class _GameLayoutOnlineState extends State<GameLayoutOnline> {
  //Proper global variables
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  StreamSubscription _subscription;
  User _userProper = FirebaseAuth.instance.currentUser;
  String _strSelfKeyProper;
  String _strRivalKeyProper;
  int _indexPlayerProper;
  List<bool> listToggleAbilityProper = [true, false];
  List<String> _listSpecialAbilityNameProper;
  List<int> _listSpecialAbilityExtraProper;
  List<int> _listTimesSpecialAbilityMaxProper = [];
  bool _isSpecialAbilityActiveProper = false;
  bool _isSpecialAbilityAvailableProper = true;
  int _nSpecialAbilitySubtypeProper;
  int _nTimesSpecialAbilityUsed = 0;
  bool _isToPop = false;

  int _nPlayers = 2;
  int _nTurn;
  int _indexActivePlayer;
  bool _toTransposeBoard = false;
  Map<int, String> _mapDeclaration;
  Map<dynamic, dynamic> _mapMapFutureMaker;

  Map<String, List<List<int>>> _mapSelf;
  Map<String, List<List<int>>> _mapRival;
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
  String _strPieceSelected;
  List<int> _listTap = [];
  List<List<int>> _listTupleDMotion = [];
  Map<String, int> _mapPieceAbilityActive = {};
  List<List<int>> _listTupleDPieceAbility = [];
  List<List<int>> _listTupleAbsSpecialAbility = [];

  //region Draw functions
  Container makeBoard(double dimBoard, double dimBox,
      Map<String, List<List<int>>> map0, Map<String, List<List<int>>> map1) {
    if (_listBoardColors != null) {
      List<Widget> listStack = [];
      listStack.add(Board(
        dimBoard: dimBoard,
        nDiv: nDiv,
        listBoardColor: _listBoardColors,
        listTap: _listTap,
        listTupleDMotion: _listTupleDMotion,
        isPieceAbilityActive: _mapPieceAbilityActive.isNotEmpty,
        listTupleDPieceAbility: _listTupleDPieceAbility,
        isSpecialAbilityActive: _isSpecialAbilityActiveProper,
        listTupleAbsSpecialAbility: _listTupleAbsSpecialAbility,
        mapStatusSelf: _mapStatusSelf,
        mapStatusRival: _mapStatusRival,
        colorSelf: _listBoardColors[_indexPlayerProper],
        colorRival: _listBoardColors[1 - _indexPlayerProper],
        isRivalSpecialSecret: _listSpecialAbilityNameProper
            .map((e) => specials.mapSpecialAttributes[e][4] == 1)
            .toList()[1 - _indexPlayerProper],
      ));
      Color color0 = _listBoardColors[_indexPlayerProper];
      Color color1 = _listBoardColors[1 - _indexPlayerProper];
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
    } else {
      return Container();
    }
  }

  void mapRemoveAdd(
    Map<String, List<List<int>>> map,
    Map<String, int> mapGrave,
    List<bool> listIsRemoveAdd,
    List<int> listCoordinateRemove,
    String strPieceNameAdd,
    List<int> listCoordinateAdd,
    bool toUploadData,
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
    if (toUploadData) {
      uploadGameData(_nTurn, _indexActivePlayer);
    }
  }

  void attackIfRivalSpot(List<int> listNewTap, bool toUploadData) {
    if (checkOccupied(_mapRival, listNewTap)) {
      mapRemoveAdd(_mapRival, _mapGraveRival, [true, false], listNewTap, '', [],
          toUploadData);
      _mapStatusRival.keys.forEach((element) {
        if (_mapStatusRival[element].isNotEmpty &&
            (element == 'fixed' || element == 'forced')) {
          _mapStatusRival =
              mapStatusTimerRemove(_mapStatusRival, element, [listNewTap]);
        }
        //Break the rival Mind Control chain
        else if (_listSpecialAbilityNameProper[1 - _indexActivePlayer] ==
                'Mind Control Tower' &&
            _mapStatusRival['mySpecial']
                .any((element) => fnd.listEquals(element, listNewTap))) {
          _mapStatusRival['mySpecial'].clear();
        }
        //Trigger the Mesmer power
        else if (_listSpecialAbilityNameProper[1 - _indexActivePlayer] ==
                'Mesmer' &&
            _mapStatusRival['mySpecial']
                .any((element) => fnd.listEquals(element, listNewTap)) &&
            getPieceName(_mapSelf, _listTap) != 'king' &&
            getPieceName(_mapSelf, listNewTap) != 'king') {
          mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, false], listNewTap, '',
              [], toUploadData);
          String strMesmerPieceName = pieces.mapPieceRank.keys.toList()[pieces
              .mapPieceRank.values
              .toList()
              .indexOf(_mapStatusRival['mySpecialLabel'].first[0])];
          mapRemoveAdd(_mapRival, _mapGraveRival, [false, true], [],
              strMesmerPieceName, listNewTap, toUploadData);
          _mapStatusRival['mySpecialLabel'].clear();
          _mapStatusRival['mySpecialLabel']
              .addAll(_mapStatusRival['mySpecial']);
          _mapStatusRival['mySpecial'].clear();
          uploadDeclaration(
              _indexPlayerProper, 'You just attacked the mesmer...');
        }
      });
      int result = checkGameOverByKing(
        _mapGraveSelf,
        _mapGraveRival,
        (_mapStatusSelf['cannotCheckmate'] != null &&
            _mapStatusSelf['cannotCheckmate'].isNotEmpty),
        (_mapStatusRival['cannotCheckmate'] != null &&
            _mapStatusRival['cannotCheckmate'].isNotEmpty),
      );
      if (result != 0) {
        _listGameOverByKing = [result, _indexPlayerProper];
        uploadGameData(_nTurn, _indexActivePlayer);
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
          context, _indexPlayerProper, strPieceName, index, _mapSelf, _listTap);
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
            attackIfRivalSpot(listNewTap, false);
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
                  listCoordinatesKing, 'king', listNewTap, false);
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
            attackIfRivalSpot(listNewTap, false);
            markTracedBoxes(_listTap, listNewTap, true);
            endTurn();
          });
        } else if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected]
                .indexOf("Stoner's castle")) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'rook', listNewTap, false);
            List<int> tupleKing = _mapSelf['king'].first;
            int intDirectionKingCastle = listNewTap[0] > tupleKing[0] ? 1 : -1;
            List<int> tupleNewKing = [
              listNewTap[0] + intDirectionKingCastle,
              listNewTap[1]
            ];
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], tupleKing,
                'king', tupleNewKing, false);
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
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, false], _listTap, '',
                [], false);
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
                'knight', listNewTap, false);
            attackIfRivalSpot(listNewTap, false);
            markTracedBoxes(_listTap, listNewTap, false);
            endTurn();
          });
        } else if (_mapPieceAbilityActive.values.first ==
            pieces.mapAbilityName[_strPieceSelected].indexOf('Big-ass-horse')) {
          setState(() {
            mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                'knight', listNewTap, false);
            mapRemoveAdd(
              _mapSelf,
              _mapGraveSelf,
              [true, true],
              [_listTap[0], _listTap[1] - 1],
              'pawn',
              [listNewTap[0], listNewTap[1] - 1],
              false,
            );
            attackIfRivalSpot(listNewTap, false);
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
                'pawn', listNewTap, false);
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
            _isSpecialAbilityActiveProper = true;
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
            _isSpecialAbilityActiveProper = true;
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
              _isSpecialAbilityActiveProper = true;
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
            _isSpecialAbilityActiveProper = true;
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
              _isSpecialAbilityActiveProper = true;
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
      int nMax = _listTimesSpecialAbilityMaxProper[_indexPlayerProper];
      int nUses = _nTimesSpecialAbilityUsed;
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
        _nSpecialAbilitySubtypeProper = await showDialog(
            context: (context),
            builder: (context) {
              return makeSpecialAbilityDialog(
                  context, ['Restrict Pawns', 'Restrict Non-Pawns']);
            });
        if (_nSpecialAbilitySubtypeProper == null) {
          resetSpecialAbility();
        } else {
          //Both must be odd
          int dTurnsEffect = (1 * 2 + 1);
          int dTurnsCoolDown = (2 * 2 + 1);
          bool canCoolDown = (_nTimesSpecialAbilityUsed <
              _listTimesSpecialAbilityMaxProper[_indexPlayerProper] - 1);
          _databaseReference
              .child(datas.strGameData)
              .child(widget.strServerName)
              .child(datas.strKey1VarGlobal)
              .child(datas.strKey2FutureMaker)
              .child(_nTurn.toString())
              .update({
            datas.strKey3FutureName: strSpecialAbilityName,
            datas.strKey3FutureIndexInvoker: _indexPlayerProper,
            datas.strKey3FutureTurnAct: (_nTurn + dTurnsEffect),
            datas.strKey3FutureType: _nSpecialAbilitySubtypeProper,
            datas.strKey3FutureTurnReset:
                canCoolDown ? (_nTurn + dTurnsCoolDown) : 0,
          });
          uploadDeclaration((1 - _indexPlayerProper),
              'Opponent declared restriction of ${_nSpecialAbilitySubtypeProper == 0 ? 'Pawn' : 'Non-Pawn'} pieces on your following turn');
          completeSpecialAbility(true, false, true);
          uploadGameData(_nTurn, _indexActivePlayer);
        }
        break;
      case 'Mesmer':
        bool isPreGame = _nTurn < 0;
        bool isDirectAttacked = _mapStatusSelf['mySpecialLabel'].isNotEmpty &&
            _mapStatusSelf['mySpecial'].isEmpty;
        bool isIndirectlyDestroyed = _mapStatusSelf['mySpecial'].isNotEmpty &&
            !checkOccupied(_mapSelf, _mapStatusSelf['mySpecial'].first);
        if (isPreGame) {
          _isSpecialAbilityActiveProper = true;
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
          _isSpecialAbilityActiveProper = true;
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
        _nSpecialAbilitySubtypeProper = await showDialog(
            context: (context),
            builder: (context) {
              return makeSpecialAbilityDialog(context, ['Revive', 'Sacrifice']);
            });
        if (_nSpecialAbilitySubtypeProper == null) {
          resetSpecialAbility();
        } else {
          setState(() {
            _listTupleAbsSpecialAbility =
                mapSpecialAbilityFunction[strSpecialAbilityName](
                    _nSpecialAbilitySubtypeProper, _mapSelf, _mapRival);
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
          _isSpecialAbilityActiveProper = true;
          setState(() {
            if (_listSpecialAbilityExtraProper[_indexPlayerProper] == 1) {
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      _mapSelf, _mapRival, _mapStatusSelf, true);
            } else if (_listSpecialAbilityExtraProper[_indexPlayerProper] ==
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
    bool isProperActive = _indexPlayerProper == _indexActivePlayer;
    if (isProperActive && _nTimesSpecialAbilityUsed == 0) {
      bool isPreGame = _nTurn < 0;
      bool isMesmerAndDirectAttacked =
          _listSpecialAbilityNameProper[_indexPlayerProper] == 'Mesmer' &&
              _mapStatusSelf['mySpecialLabel'].isNotEmpty &&
              _mapStatusSelf['mySpecial'].isEmpty;
      bool isMesmerAndIndirectlyDestroyed =
          _listSpecialAbilityNameProper[_indexPlayerProper] == 'Mesmer' &&
              _mapStatusSelf['mySpecial'].isNotEmpty &&
              !checkOccupied(_mapSelf, _mapStatusSelf['mySpecial'].first);
      if (isPreGame ||
          isMesmerAndDirectAttacked ||
          isMesmerAndIndirectlyDestroyed) {
        primeSpecialAbility(_listSpecialAbilityNameProper[_indexActivePlayer]);
      }
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
        _nTimesSpecialAbilityUsed++;
      }
      _isSpecialAbilityActiveProper = false;
      _isSpecialAbilityAvailableProper = !toMakeNotAvailable;
      _listTupleAbsSpecialAbility.clear();
      if (toEndTurn) {
        endTurn();
      }
    });
  }

  void resetSpecialAbility() {
    setState(() {
      _isSpecialAbilityActiveProper = false;
      _isSpecialAbilityAvailableProper = true;
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
            mapRemoveAdd(
                _mapSelf,
                _mapGraveSelf,
                [true, true],
                tupleMesmerPiece,
                getPieceName(_mapSelf, tupleMesmerPiece),
                listNewTap,
                true);
            _listTupleAbsSpecialAbility.clear();
            _mapStatusSelf['mySpecialLabel'].clear();
            completeSpecialAbility(true, false, true);
          } else if (!isPreGame && isDirectAttacked && !isPotentialZone) {
            _listTupleAbsSpecialAbility.clear();
            _mapStatusSelf['mySpecialLabel'].clear();
            completeSpecialAbility(true, false, true);
            bool isSelfPieceZone = checkOccupied(_mapSelf, listNewTap);
            performMotionRoutine(isSelfPieceZone, listNewTap[0], listNewTap[1]);
          } else if (!isPreGame && isIndirectlyDestroyed && isPotentialZone) {
            setState(() {
              _mapStatusSelf['mySpecial'].clear();
              _mapStatusSelf['mySpecialLabel'].clear();
              _mapStatusSelf['mySpecial'].add(listNewTap);
              _mapStatusSelf['mySpecialLabel'].add(
                  [pieces.mapPieceRank[getPieceName(_mapSelf, listNewTap)]]);
              uploadGameData(_nTurn, _indexActivePlayer);
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
        bool isAbilityPotentialZone = (_listTupleAbsSpecialAbility.isNotEmpty &&
            _listTupleAbsSpecialAbility
                .any((element) => fnd.listEquals(element, listNewTap)));
        if (isPreGame && isAbilityPotentialZone) {
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
              mapRemoveAdd(_mapRival, _mapGraveRival, [true, false], listNewTap,
                  '', [], false);
              mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                  getPieceName(_mapSelf, _listTap), listNewTap, true);
              resetSelection();
              _mapStatusSelf['mySpecial'].removeWhere(
                  (element) => fnd.listEquals(element, listNewTap));
              _listTupleAbsSpecialAbility =
                  mapSpecialAbilityFunction[strSpecialAbilityName](
                      1, _mapSelf, _mapRival);
              uploadGameData(_nTurn, _indexActivePlayer);
            });
          } else if (_mapStatusSelf['mySpecial'].length == 1 &&
              isAbilityPotentialZone) {
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
                  listNewTap,
                  false,
                );
                _mapStatusSelf = addCannotCheckmateStatus(
                    _nTurn, mapStatusTimerAdd, _mapStatusSelf);
                uploadDeclaration((1 - _indexPlayerProper),
                    'Opponent performed a Necromancer revival of ${strPlayer == 'My' ? 'their' : 'your'} $strPieceName');
                markTracedBoxes(listNewTap, listNewTap, true);
                completeSpecialAbility(true, true, true);
              }
              break;
            case 1:
              String strPieceSelected = getPieceName(_mapSelf, listNewTap);
              int rankPieceSelected = pieces.mapPieceRank[strPieceSelected];
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
                    strPieceName, listNewTap, true);
                _mapStatusSelf = mapStatusTimerAdd(
                    _nTurn, _mapStatusSelf, 'fixed', [listNewTap], 0);
                uploadDeclaration((1 - _indexPlayerProper),
                    'Opponent performed a Necromancer sacrifice of a $strPieceSelected for a $strPieceName');
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
                    listNewTap, '', [], false);
                mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
                    'pawn', listNewTap, false);
                markTracedBoxes(_listTap, listNewTap, false);
              } else if (indexAttackType == 1) {
                mapRemoveAdd(_mapRival, _mapGraveRival, [true, false],
                    listNewTap, '', [], false);
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
          if (_listSpecialAbilityExtraProper[_indexPlayerProper] == 1) {
            _mapStatusSelf['mySpecial'].addAll(_listTupleAbsSpecialAbility
                .where((element) => element[1] == listNewTap[1]));
            if (_mapStatusSelf['mySpecial'].length <= nDiv) {
              completeSpecialAbility(false, false, false);
            } else {
              completeSpecialAbility(false, true, false);
            }
          } else if (_listSpecialAbilityExtraProper[_indexPlayerProper] == 2) {
            _mapStatusSelf['mySpecial'].addAll(_listTupleAbsSpecialAbility
                .where((element) => element[1] == listNewTap[1]));
            completeSpecialAbility(false, true, false);
          }
        } else if (!isPreGame && isPotentialZone) {
          mapRemoveAdd(_mapRival, _mapGraveRival, [true, false], listNewTap, '',
              [], false);
          _nTimesSpecialAbilityUsed++;
          bool toMakeNotAvailable = (_nTimesSpecialAbilityUsed >=
              _listTimesSpecialAbilityMaxProper[_indexPlayerProper]);
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
        _listTimesSpecialAbilityMaxProper[_indexPlayerProper] != 0 &&
            _isSpecialAbilityActiveProper;
    //Region for pre-game selections
    if (isPreGame) {
      performSpecialGestureRoutine(
          _listSpecialAbilityNameProper[_indexPlayerProper],
          _nSpecialAbilitySubtypeProper,
          [iTap, jTap]);
    }
    //Region for regular motion based selections
    else if (!isPieceAbilityActive &&
        !isSingleUseSpecialActive &&
        _listTimesSpecialAbilityMaxProper[_indexPlayerProper] != 0) {
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
          _listSpecialAbilityNameProper[_indexPlayerProper],
          _nSpecialAbilitySubtypeProper,
          [iTap, jTap]);
    }
    //region for continuous abilities - Not in PreGame
    else if (!isSingleUseSpecialActive &&
        _listTimesSpecialAbilityMaxProper[_indexPlayerProper] == 0) {
      switch (_listSpecialAbilityNameProper[_indexPlayerProper]) {
        case 'Navy SEAL Special Operations Units':
          performSpecialGestureRoutine(
              _listSpecialAbilityNameProper[_indexPlayerProper],
              _nSpecialAbilitySubtypeProper,
              [iTap, jTap]);
          break;
        case 'Mesmer':
          performSpecialGestureRoutine(
              _listSpecialAbilityNameProper[_indexPlayerProper],
              0,
              [iTap, jTap]);
          break;
        case 'Mind Control Tower':
          performSpecialGestureRoutine(
              _listSpecialAbilityNameProper[_indexPlayerProper],
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
    //Check if fixed (self OR rival) from Mind Control (under mySpecial section)
    if ((_listSpecialAbilityNameProper[_indexPlayerProper] ==
                'Mind Control Tower' &&
            _mapStatusSelf['mySpecial']
                .any((element) => fnd.listEquals(element, [iTap, jTap]))) ||
        (_listSpecialAbilityNameProper[1 - _indexPlayerProper] ==
                'Mind Control Tower' &&
            _mapStatusRival['mySpecial']
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
              (_listSpecialAbilityNameProper[_indexPlayerProper] ==
                          'Navy SEAL Special Operations Units' &&
                      _strPieceSelected == 'pawn')
                  ? false
                  : true);
        } else if (isPotentialZone) {
          bool toMoveSpecialTagWithPiece =
              (_listSpecialAbilityNameProper[_indexPlayerProper] == 'Mesmer' &&
                      _mapStatusSelf['mySpecial'].any((element) =>
                          fnd.listEquals(element, [_listTap[0], _listTap[1]])))
                  ? true
                  : false;
          mapRemoveAdd(_mapSelf, _mapGraveSelf, [true, true], _listTap,
              _strPieceSelected, [iTap, jTap], false);
          attackIfRivalSpot([iTap, jTap], false);
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
          uploadGameData(_nTurn, _indexActivePlayer);
          if (_mapStatusSelf['forced'].length == 0) {
            bool isSpecialAbilitySingleUse =
                _listTimesSpecialAbilityMaxProper[_indexPlayerProper] != 0;
            bool toRepeatTurn =
                _listSpecialAbilityNameProper[_indexPlayerProper] ==
                        'Time Wizard' &&
                    _isSpecialAbilityActiveProper;
            if (isSpecialAbilitySingleUse &&
                _isSpecialAbilityActiveProper &&
                !toRepeatTurn) {
              completeSpecialAbility(true, true, true);
            } else if (toRepeatTurn) {
              _mapStatusSelf = addCannotCheckmateStatus(
                  _nTurn, mapStatusTimerAdd, _mapStatusSelf);
              uploadGameData(_nTurn, _indexActivePlayer);
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
    int nTurn = _nTurn;
    int indexActivePlayer = _indexActivePlayer;
    resetSelection();
    nTurn++;
    bool isSamePlayer = indexActivePlayer == nTurn % 2;
    if (!isSamePlayer) {
      indexActivePlayer = nTurn % 2;
      performFutureFunction(nTurn, indexActivePlayer);
      performTurnTranspositionsLocal(nTurn, indexActivePlayer);
    }
    uploadGameData(nTurn, indexActivePlayer);
  }

  void performTurnTranspositionsLocal(int nTurn, int indexActivePlayer) {
    List<Map> listMapTransposed = performTurnTranspositions(
        nTurn,
        indexActivePlayer,
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

  void performFutureFunction(int nTurn, int indexActivePlayer) {
    if (_mapMapFutureMaker != null) {
      _mapMapFutureMaker.values.forEach((element) {
        if (nTurn == element[datas.strKey3FutureTurnAct] ||
            nTurn == element[datas.strKey3FutureTurnReset]) {
          switch (element[datas.strKey3FutureName]) {
            case 'Invisible Hands':
              if (nTurn == element[datas.strKey3FutureTurnAct]) {
                bool toTargetSelf = indexActivePlayer == _indexPlayerProper;
                Map<String, List<List<int>>> mapPositionToTarget =
                    toTargetSelf ? _mapSelf : _mapRival;
                Map<String, List<List<int>>> mapStatusToTarget =
                    toTargetSelf ? _mapStatusSelf : _mapStatusRival;
                int nDuration = 1;
                List<List<int>> listTupleRestrict = [];
                switch (element[datas.strKey3FutureType]) {
                  case 0:
                    listTupleRestrict.addAll(mapPositionToTarget['pawn']);
                    mapStatusToTarget = mapStatusTimerAdd(
                        _nTurn,
                        mapStatusToTarget,
                        'fixed',
                        listTupleRestrict,
                        nDuration);
                    break;
                  case 1:
                    listTupleRestrict.addAll(mapPositionToTarget['queen']);
                    listTupleRestrict.addAll(mapPositionToTarget['rook']);
                    listTupleRestrict.addAll(mapPositionToTarget['bishop']);
                    listTupleRestrict.addAll(mapPositionToTarget['knight']);
                    mapStatusToTarget = mapStatusTimerAdd(
                        _nTurn,
                        mapStatusToTarget,
                        'fixed',
                        listTupleRestrict,
                        nDuration);
                    break;
                }
              } else if (nTurn == element[datas.strKey3FutureTurnReset]) {
                resetSpecialAbility();
              }
          }
        }
      });
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

  //region Data functions

  makeProperMapsFromData(Map snapshotUser, bool isSelfData) {
    Map<String, List<dynamic>> mapPre;
    String strKey;
    strKey = datas.strKey2MapPosition;
    if (snapshotUser.containsKey(strKey)) {
      Map<String, List<List<int>>> mapPost = {};
      mapPre = Map<String, List<dynamic>>.from(snapshotUser[strKey]);
      pieces.listPieceName.forEach((element) {
        if (!mapPre.containsKey(element)) {
          mapPost.addAll({element: []});
        } else {
          List<List<int>> listListSub = [];
          mapPre[element].forEach((element) {
            listListSub.add([element[0], element[1]]);
          });
          mapPost.addAll({element: listListSub});
        }
      });
      if (isSelfData) {
        _mapSelf = mapPost;
      } else {
        _mapRival = transposeMap(mapPost, _toTransposeBoard);
      }
    } else {
      if (isSelfData) {
        _mapSelf =
            Map.fromIterables(pieces.listPieceName, [[], [], [], [], [], []]);
      } else {
        _mapRival =
            Map.fromIterables(pieces.listPieceName, [[], [], [], [], [], []]);
      }
    }
    strKey = datas.strKey2MapStatus;
    if (snapshotUser.containsKey(strKey)) {
      Map<String, List<List<int>>> mapPost = {};
      mapPre = Map<String, List<dynamic>>.from(snapshotUser[strKey]);
      players.mapStartStatus.keys.forEach((element) {
        if (!mapPre.containsKey(element)) {
          mapPost.addAll({element: []});
        } else {
          List<List<int>> listListSub = [];
          mapPre[element].forEach((e2) {
            List<int> listSub = [];
            e2.forEach((e3) {
              listSub.add(e3);
            });
            listListSub.add(listSub);
          });
          mapPost.addAll({element: listListSub});
        }
      });
      if (isSelfData) {
        _mapStatusSelf = mapPost;
      } else {
        _mapStatusRival = transposeMap(mapPost, _toTransposeBoard);
      }
    } else {
      if (isSelfData) {
        _mapStatusSelf = makeEmptyMapStatus();
      } else {
        _mapStatusRival = makeEmptyMapStatus();
      }
    }
    strKey = datas.strKey2MapGrave;
    if (snapshotUser.containsKey(strKey)) {
      if (isSelfData) {
        _mapGraveSelf = Map<String, int>.from(snapshotUser[strKey]);
      } else {
        _mapGraveRival = Map<String, int>.from(snapshotUser[strKey]);
      }
    }
  }

  Map<String, List<List<int>>> makeEmptyMapStatus() {
    return {
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
  }

  //endregion Data functions

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    initProperGameData();
    super.initState();
  }

  Future<void> initProperGameData() async {
    _listBoardColors = await loadBoardColors();
    DataSnapshot snapshot =
        await _databaseReference.child(datas.strGameData).once();
    Map mapSnapshotGame = snapshot.value[widget.strServerName];
    bool isUser0 =
        mapSnapshotGame[datas.strKey1VarUser0]['uid'] == _userProper.uid;
    _strSelfKeyProper = isUser0 ? datas.strKey1VarUser0 : datas.strKey1VarUser1;
    _strRivalKeyProper =
        isUser0 ? datas.strKey1VarUser1 : datas.strKey1VarUser0;
    _indexPlayerProper =
        mapSnapshotGame[_strSelfKeyProper][datas.strKey2IndexPlayer];
    _listSpecialAbilityNameProper = [
      mapSnapshotGame[datas.strKey1VarUser0][datas.strKey2SpecialName],
      mapSnapshotGame[datas.strKey1VarUser1][datas.strKey2SpecialName]
    ];
    _listSpecialAbilityExtraProper = [
      mapSnapshotGame[datas.strKey1VarUser0][datas.strKey2SpecialExtra],
      mapSnapshotGame[datas.strKey1VarUser1][datas.strKey2SpecialExtra]
    ];
    uploadInitialSelfGameData();
    initTimesSpecialAbilityMax();
    initPreGame();
    initSpecialAbility();
    _subscription = _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .onChildChanged
        .listen((event) {
      setState(() {
        updateProperGameData(event);
      });
    });
  }

  void uploadInitialSelfGameData() {
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(_strSelfKeyProper)
        .update({
      datas.strKey2MapPosition: players.mapMapStartPosition[_indexPlayerProper],
      datas.strKey2MapGrave: players.mapStartGrave,
      datas.strKey2MapStatus: players.mapStartStatus,
    });
    setState(() {
      Map<String, List<List<int>>> mapPreSelf = {};
      players.mapMapStartPosition[_indexPlayerProper].keys.forEach((element) {
        mapPreSelf.addAll({
          element: players.mapMapStartPosition[_indexPlayerProper][element]
              .map((e) => [e[0], e[1]])
              .toList()
        });
      });
      _mapSelf = mapPreSelf;
      //Want to create a mirror reflexion about x-axis
      Map<String, List<List<int>>> mapPreRival = {};
      mapPreSelf.keys.forEach((element) {
        mapPreRival.addAll({
          element: mapPreSelf[element].map((e) => [e[0], rMax - e[1]]).toList()
        });
      });
      _mapRival = mapPreRival;
    });
  }

  void initTimesSpecialAbilityMax() {
    int i = 0;
    _listSpecialAbilityNameProper.forEach((element) {
      int nMax;
      String strUser = i == 0 ? datas.strKey1VarUser0 : datas.strKey1VarUser1;
      if (_listSpecialAbilityExtraProper[i] == 0) {
        nMax = specials.mapSpecialAttributes[element][0];
      } else if (element == 'Sniper from Heaven') {
        nMax = _listSpecialAbilityExtraProper[i];
      }
      _listTimesSpecialAbilityMaxProper.add(nMax);
      _databaseReference
          .child(datas.strGameData)
          .child(widget.strServerName)
          .child(strUser)
          .update({datas.strKey2TimesSpecialAbilityMax: nMax});
      i++;
    });
  }

  void initPreGame() {
    int nTurn;
    int indexActivePlayer;
    int nPreGameSpecials = _listSpecialAbilityNameProper
        .map((e) => specials.mapSpecialAttributes[e][3])
        .reduce((value, element) => value + element);
    if (specials.mapSpecialAttributes[_listSpecialAbilityNameProper[0]][3] ==
        1) {
      nTurn = -nPreGameSpecials;
      indexActivePlayer = 0;
    } else if (specials.mapSpecialAttributes[_listSpecialAbilityNameProper[1]]
            [3] ==
        1) {
      nTurn = -nPreGameSpecials;
      indexActivePlayer = 1;
      performTurnTranspositionsLocal(nTurn, indexActivePlayer);
    } else {
      nTurn = 0;
      indexActivePlayer = nTurn % 2;
    }
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(datas.strKey1VarGlobal)
        .update({
      datas.strKey2NTurn: nTurn,
      datas.strKey2IndexActivePlayer: indexActivePlayer
    });
    setState(() {
      _nTurn = nTurn;
      _indexActivePlayer = indexActivePlayer;
    });
  }

  void initSpecialAbility() {
    if (!_isSpecialAbilityActiveProper &&
        !(_listTimesSpecialAbilityMaxProper[_indexPlayerProper] != 0)) {
      _isSpecialAbilityActiveProper = true;
    }
  }

  void updateProperGameData(Event event) {
    switch (event.snapshot.key) {
      case datas.strKey1VarGlobal:
        setState(() {
          _nPlayers = event.snapshot.value[datas.strKey2NPlayers];
          _mapDeclaration =
              event.snapshot.value[datas.strKey2DeclarationMaker] != null
                  ? {
                      event.snapshot.value[datas.strKey2DeclarationMaker]
                              [datas.strKey3DeclarationIndexTargetPlayer]:
                          event.snapshot.value[datas.strKey2DeclarationMaker]
                              [datas.strKey3DeclarationMessage]
                    }
                  : _mapDeclaration;
          _listGameOverByKing = List<int>.from(
              event.snapshot.value[datas.strKey2listGameOverByKing]);
        });
        _nTurn = event.snapshot.value[datas.strKey2NTurn];
        _indexActivePlayer =
            event.snapshot.value[datas.strKey2IndexActivePlayer];
        _mapMapFutureMaker =
            event.snapshot.value[datas.strKey2FutureMaker] != null
                ? event.snapshot.value[datas.strKey2FutureMaker]
                : null;
        break;
      case datas.strKey1VarUser0:
        if (_indexPlayerProper == 0) {
          makeProperMapsFromData(event.snapshot.value, true);
        } else {
          makeProperMapsFromData(event.snapshot.value, false);
        }
        break;
      case datas.strKey1VarUser1:
        if (_indexPlayerProper == 1) {
          makeProperMapsFromData(event.snapshot.value, true);
        } else {
          makeProperMapsFromData(event.snapshot.value, false);
        }
        break;
    }
  }

  void uploadGameData(int nTurn, int indexActivePlayer) {
    //Upload global data
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(datas.strKey1VarGlobal)
        .update({
      datas.strKey2NTurn: nTurn,
      datas.strKey2IndexActivePlayer: indexActivePlayer,
      datas.strKey2listGameOverByKing: _listGameOverByKing,
    });
    //Upload Self data
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(_strSelfKeyProper)
        .update({
      datas.strKey2MapPosition: _mapSelf,
      datas.strKey2MapGrave: _mapGraveSelf,
      datas.strKey2MapStatus: _mapStatusSelf,
    });
    //Upload Rival data
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(_strRivalKeyProper)
        .update({
      datas.strKey2MapPosition: transposeMap(_mapRival, _toTransposeBoard),
      datas.strKey2MapGrave: _mapGraveRival,
      datas.strKey2MapStatus: transposeMap(_mapStatusRival, _toTransposeBoard),
    });
  }

  void uploadDeclaration(int indexTargetPlayer, String strMessage) {
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(datas.strKey1VarGlobal)
        .update({
      datas.strKey2DeclarationMaker: {
        datas.strKey3DeclarationIndexTargetPlayer: indexTargetPlayer,
        datas.strKey3DeclarationMessage: strMessage,
      }
    });
  }

  Map<dynamic, dynamic> convertKeyToStringOrInt(
      Map<dynamic, dynamic> map, bool toString) {
    if (map != null) {
      Map<dynamic, dynamic> mapOut = {};
      if (toString) {
        map.keys.forEach((element) {
          mapOut.addAll({element.toString(): map[element]});
        });
      } else {
        map.keys.forEach((element) {
          mapOut.addAll({int.parse(element): map[element]});
        });
      }
      return mapOut;
    } else {
      return null;
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
    _subscription.cancel();
    reduceServerNPlayers(_databaseReference, _nPlayers, widget.strServerName);
    super.dispose();
  }

  //region Build functions
  SafeArea makeMainScaffold(
      bool isPreGame, double dimBoard, double dimBox, String strAppBarText) {
    const styleTextPass =
        TextStyle(fontSize: 18, fontWeight: FontWeight.normal);
    return SafeArea(
      child: Scaffold(
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
                    _isSpecialAbilityActiveProper &&
                        specials.mapSpecialAttributes[
                                _listSpecialAbilityNameProper[
                                    _indexActivePlayer]][0] !=
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
          backgroundColor: (_indexActivePlayer == 0
              ? players.colorTeam0
              : players.colorTeam1),
        ),
        body: WillPopScope(
          child: Column(
            children: [
              Divider(
                height: GameLayoutOnline.sizeDivider,
                thickness: GameLayoutOnline.sizeDivider,
                color: Colors.amberAccent,
              ),
              GestureDetector(
                child: makeBoard(dimBoard, dimBox, _mapSelf, _mapRival),
                onTapDown: (details) => functionTap(dimBoard, dimBox, details),
              ),
              Divider(
                height: GameLayoutOnline.sizeDivider,
                thickness: GameLayoutOnline.sizeDivider,
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
                              style: GameLayoutOnline.styleSub,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            child: Text(
                              'Piece Ability',
                              style: GameLayoutOnline.styleSub,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            GameLayoutOnline.sizeBorderRadius),
                        isSelected: listToggleAbilityProper,
                        color: Colors.white,
                        borderColor: Theme.of(context).scaffoldBackgroundColor,
                        fillColor: Colors.white,
                        selectedColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        onPressed: (index) {
                          bool isPieceAbilityActive =
                              _mapPieceAbilityActive.isNotEmpty;
                          bool isSingleUseSpecialActive =
                              _listTimesSpecialAbilityMaxProper[
                                          _indexPlayerProper] !=
                                      0 &&
                                  _isSpecialAbilityActiveProper;
                          if (!isPieceAbilityActive &&
                              !isSingleUseSpecialActive) {
                            setState(() {
                              listToggleAbilityProper = listToggleAbilityProper
                                  .map((e) => !e)
                                  .toList();
                            });
                          }
                        },
                      ),
                    )
                  : Container(),
              !isPreGame
                  ? Expanded(
                      child: listToggleAbilityProper[0]
                          ? SpecialAbilitySector(
                              indexPlayer: _indexPlayerProper,
                              strSpecialAbilityName:
                                  _listSpecialAbilityNameProper[
                                      _indexPlayerProper],
                              strRivalSpecialAbilityName:
                                  _listSpecialAbilityNameProper[
                                      1 - _indexPlayerProper],
                              isSpecialAbilitySingleUse:
                                  _listTimesSpecialAbilityMaxProper[
                                          _indexPlayerProper] !=
                                      0,
                              isSpecialAbilityActive:
                                  _isSpecialAbilityActiveProper,
                              isSpecialAbilityAvailable:
                                  _isSpecialAbilityAvailableProper,
                              canSpecialAbilityReset:
                                  specials.mapSpecialAttributes[
                                          _listSpecialAbilityNameProper[
                                              _indexPlayerProper]][2] ==
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
      ),
    );
  }

  GameOverOverlay makeGameOverOverlay() {
    const String strMessageLose = 'Game over\n\nYou lose...';
    const String strMessageWin = 'Game over\n\nYou win!!!';
    bool isWinner = (_listGameOverByKing.first == 2 &&
            _indexActivePlayer == 1 - _indexPlayerProper) ||
        (_listGameOverByKing.first == 1 &&
            _indexActivePlayer == _indexPlayerProper);
    String strMessageDisplayed = isWinner ? strMessageWin : strMessageLose;
    return GameOverOverlay(
      strMessage: strMessageDisplayed,
      colorMessage:
          _indexPlayerProper == 0 ? players.colorTeam0 : players.colorTeam1,
    );
  }

  //endregion Build functions

  @override
  Widget build(BuildContext context) {
    bool anyCriticalNulls = (_nTurn == null ||
        _indexActivePlayer == null ||
        _mapSelf == null ||
        _mapRival == null);
    bool isBuildReady =
        MediaQuery.of(context).orientation == Orientation.portrait &&
            _listBoardColors != null;
    if (isBuildReady && !anyCriticalNulls) {
      bool isPreGame;
      double dimBoard;
      double dimBox;
      String strAppBarText;
      primeSpecialAbilityFromBuild();
      isPreGame = _nTurn < 0;
      dimBoard = math.min(MediaQuery.of(context).size.height,
          MediaQuery.of(context).size.width);
      dimBox = dimBoard / nDiv;
      strAppBarText = isPreGame
          ? "${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Pre-Game Select"
          : "${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Turn ${_nTurn + 1}";
      bool toDisplayDeclaration = _mapDeclaration != null &&
          _mapDeclaration.keys.first == _indexPlayerProper;
      if (toDisplayDeclaration) {
        _databaseReference
            .child(datas.strGameData)
            .child(widget.strServerName)
            .child(datas.strKey1VarGlobal)
            .child(datas.strKey2DeclarationMaker)
            .remove();
        Future.delayed(Duration.zero, () {
          String strMessage = _mapDeclaration.values.first;
          _mapDeclaration = null;
          return showDialog(
              barrierDismissible: true,
              context: context,
              // ignore: deprecated_member_use
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    strMessage,
                    textAlign: TextAlign.center,
                  ),
                );
              });
        });
        if (_indexPlayerProper == _indexActivePlayer) {
          return Stack(
            children: [
              makeMainScaffold(isPreGame, dimBoard, dimBox, strAppBarText),
              DisconnectionOverlay(
                nPlayers: _nPlayers,
              ),
              _listGameOverByKing.first != 0
                  ? makeGameOverOverlay()
                  : Container(),
            ],
          );
        } else {
          return Stack(
            children: [
              IgnorePointer(
                child: makeMainScaffold(
                    isPreGame, dimBoard, dimBox, strAppBarText),
              ),
              DisconnectionOverlay(
                nPlayers: _nPlayers,
              ),
              _listGameOverByKing.first != 0
                  ? makeGameOverOverlay()
                  : Container(),
            ],
          );
        }
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }
}
