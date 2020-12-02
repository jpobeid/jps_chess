import 'dart:async';

import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart' as csv;
import 'package:jps_chess/data/player_data.dart' as players;
import 'package:jps_chess/data/special_data.dart' as specials;
import 'package:jps_chess/data/database_data.dart' as datas;
import 'package:jps_chess/widgets/disconnect_overlay.dart';

List<bool> _listToggle = [true, false];
final List<String> listSpecialSubtitle = List<String>.from(
    specials.mapSpecialSubtitleIcon.values.map((e) => e[0]).toList());
final List<IconData> listSpecialIcon = List<IconData>.from(
    specials.mapSpecialSubtitleIcon.values.map((e) => e[1]).toList());
final List<int> listNumberSpecialUses =
    specials.mapSpecialAttributes.values.map((e) => e[0]).toList();
final List<int> listIsExtra =
    specials.mapSpecialAttributes.values.map((e) => e[1]).toList();

class SpecialSelectOnline extends StatefulWidget {
  static const routeName = '/special-select-online';

  final String strServerName;
  final int indexPlayer;

  const SpecialSelectOnline({Key key, this.strServerName, this.indexPlayer})
      : super(key: key);

  final List<String> listSpecialName = specials.listSpecialName;

  @override
  _SpecialSelectOnlineState createState() => _SpecialSelectOnlineState();
}

class _SpecialSelectOnlineState extends State<SpecialSelectOnline> {
  static const TextStyle styleTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle styleSubtitle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static const List<int> listFlexColumn = [8, 1];

  DatabaseReference _databaseReference;
  StreamSubscription _streamSubscription;

  List<List<dynamic>> dataAbilities;
  int _nPlayers = 2;
  int _indexActivePlayer = 0;
  List<String> _listPlayerSpecialAbility = [null, null];
  List<int> _listPlayerSpecialAbilityExtra = [null, null];
  bool _isNavigating = false;

  Future<void> loadCsv(String pathCsv) async {
    String strCsv = await rootBundle.loadString(pathCsv);
    setState(() {
      dataAbilities = csv.CsvToListConverter().convert(strCsv);
    });
  }

  void uploadGameData(String strNewSpecialName, int intNewExtra) {
    String strVarUserActive =
        _indexActivePlayer == 0 ? datas.strKey1VarUser0 : datas.strKey1VarUser1;
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(strVarUserActive)
        .update({datas.strKey2SpecialName: strNewSpecialName});
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(strVarUserActive)
        .update({datas.strKey2SpecialExtra: intNewExtra});
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(datas.strKey1VarGlobal)
        .update({datas.strKey2IndexActivePlayer: (1 - _indexActivePlayer)});
  }

  void listenToUpdatedGameData(Event event) {
    switch (event.snapshot.key) {
      case datas.strKey1VarGlobal:
        setState(() {
          _nPlayers = event.snapshot.value[datas.strKey2NPlayers];
          _indexActivePlayer =
              event.snapshot.value[datas.strKey2IndexActivePlayer];
        });
        break;
      case datas.strKey1VarUser0:
        _listPlayerSpecialAbility[0] =
            event.snapshot.value[datas.strKey2SpecialName];
        _listPlayerSpecialAbilityExtra[0] =
            event.snapshot.value[datas.strKey2SpecialExtra];
        break;
      case datas.strKey1VarUser1:
        _listPlayerSpecialAbility[1] =
            event.snapshot.value[datas.strKey2SpecialName];
        _listPlayerSpecialAbilityExtra[1] =
            event.snapshot.value[datas.strKey2SpecialExtra];
        break;
    }
    proceedToGame();
  }

  void proceedToGame() {
    bool isReadyForGame =
        !(_listPlayerSpecialAbility.any((element) => element == null));
    //Navigate to Game if lists are non-space strings
    if (isReadyForGame && !_isNavigating) {
      _isNavigating = true;
      Navigator.pushReplacementNamed(context, '/game-layout-online',
          arguments: [widget.strServerName]);
    }
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    loadCsv('assets/abilities.csv');
    _databaseReference = FirebaseDatabase.instance.reference();
    _streamSubscription = _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .onChildChanged
        .listen((event) {
      listenToUpdatedGameData(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    if (!_isNavigating) {
      reduceServerNPlayers(_databaseReference, _nPlayers, widget.strServerName);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color colorFade = Color.fromARGB(135, 50, 50, 50);

    bool toBuild = dataAbilities != null &&
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isProperPlayerActive = widget.indexPlayer == _indexActivePlayer;
    if (toBuild && isProperPlayerActive) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _indexActivePlayer == 0
                ? players.colorTeam0
                : players.colorTeam1,
            automaticallyImplyLeading: false,
            title: Text(
              '${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Special Ability Select',
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  makeSpecialSelectionList(),
                  (_listPlayerSpecialAbility[0] != null)
                      ? makeBottomSelectionBar()
                      : Container(),
                ],
              ),
              DisconnectionOverlay(
                nPlayers: _nPlayers,
              ),
            ],
          ),
        ),
      );
    } else if (toBuild) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _indexActivePlayer == 0
                ? players.colorTeam0
                : players.colorTeam1,
            automaticallyImplyLeading: false,
            title: Text(
                '${_indexActivePlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Special Ability Select'),
          ),
          body: IgnorePointer(
            child: Stack(
              children: [
                Column(
                  children: [
                    makeSpecialSelectionList(),
                    (_listPlayerSpecialAbility[0] != null)
                        ? makeBottomSelectionBar()
                        : Container(),
                  ],
                ),
                Container(
                  color: colorFade,
                ),
                Container(
                  color: Colors.black,
                  child: Text(
                    "Pending other player's selection",
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                makePendingSelectionIndicator(context),
                DisconnectionOverlay(
                  nPlayers: _nPlayers,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold();
    }
  }

  Expanded makeSpecialSelectionList() {
    return Expanded(
      flex: listFlexColumn[0],
      child: ListView.builder(
          itemCount: dataAbilities[0].length - 1,
          itemBuilder: (context, index) {
            String strSpecialName = dataAbilities[0][index + 1];
            int indexReference = widget.listSpecialName.indexOf(strSpecialName);
            return Card(
              child: ListTile(
                leading: Icon(
                  listSpecialIcon[indexReference],
                  size: 32,
                ),
                title: Text(
                  strSpecialName,
                  style: styleTitle,
                ),
                subtitle: Text(
                  listSpecialSubtitle[indexReference],
                  style: styleSubtitle,
                ),
                trailing: Icon(
                  listNumberSpecialUses[indexReference] != 0
                      ? specials.iconSingleUse
                      : specials.iconContinuous,
                  size: 30,
                ),
                onTap: () async {
                  bool result = await showDialog(
                    context: context,
                    child: ConfirmDialog(
                      strSpecialName: strSpecialName,
                      iconSpecial: listSpecialIcon[indexReference],
                      isExtra: listIsExtra[indexReference] == 1,
                    ),
                  );
                  onConfirmDialogResult(strSpecialName, result, indexReference);
                },
              ),
            );
          }),
    );
  }

  Expanded makeBottomSelectionBar() {
    return Expanded(
      flex: listFlexColumn[1],
      child: Container(
        color: players.colorTeam0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${players.strPlayer0}'s Selection:\n${_listPlayerSpecialAbility[0]}",
              style: styleTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void onConfirmDialogResult(
      String strSpecialName, bool result, int indexReference) {
    if (result != null && result) {
      setState(() {
        int intExtra;
        if (listIsExtra[indexReference] == 1) {
          intExtra = (_listToggle.indexOf(true) + 1);
        } else {
          intExtra = 0;
        }
        uploadGameData(strSpecialName, intExtra);
      });
    } else {
      _listToggle = [true, false];
    }
  }
}

Center makePendingSelectionIndicator(BuildContext context) {
  const double fractionSizeWaiter = 0.4;
  const double sizeWaiterStroke = 20;
  double sizeWaiter = math.min(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height) *
      fractionSizeWaiter;
  return Center(
    child: Container(
      width: sizeWaiter,
      height: sizeWaiter,
      child: CircularProgressIndicator(
        strokeWidth: sizeWaiterStroke,
      ),
    ),
  );
}

class ConfirmDialog extends StatefulWidget {
  final String strSpecialName;
  final IconData iconSpecial;
  final bool isExtra;

  const ConfirmDialog(
      {Key key, this.strSpecialName, this.iconSpecial, this.isExtra})
      : super(key: key);

  static const fractionWidth = 0.8;
  static const fractionHeight = 0.2;

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isExtra) {
      return AlertDialog(
        content: Container(
          width:
              MediaQuery.of(context).size.width * ConfirmDialog.fractionWidth,
          height:
              MediaQuery.of(context).size.height * ConfirmDialog.fractionHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Confirm the following selection?'),
              Text(
                widget.strSpecialName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Icon(
                widget.iconSpecial,
                size: 32,
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Yes'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('No'),
          ),
        ],
      );
    } else {
      const double sizeBorderRadius = 10;
      const double scaleHeight = 1.25;
      const double sizeDivider = 2;
      const double sizeTextPadding = 8;
      List<String> listStrExtra =
          specials.mapSpecialExtra[widget.strSpecialName];
      return AlertDialog(
        content: Container(
          width:
              MediaQuery.of(context).size.width * ConfirmDialog.fractionWidth,
          height: MediaQuery.of(context).size.height *
              ConfirmDialog.fractionHeight *
              scaleHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Confirm the following selection?'),
              Text(
                widget.strSpecialName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Icon(
                widget.iconSpecial,
                size: 32,
              ),
              Divider(
                thickness: sizeDivider,
              ),
              FittedBox(
                child: ToggleButtons(
                  children: listStrExtra.map((e) {
                    return Padding(
                      padding: EdgeInsets.all(sizeTextPadding),
                      child: Text(
                        e,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  isSelected: _listToggle,
                  onPressed: (index) {
                    setState(() {
                      _listToggle = _listToggle.map((e) => !e).toList();
                    });
                  },
                  borderRadius: BorderRadius.circular(sizeBorderRadius),
                ),
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Yes'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('No'),
          ),
        ],
      );
    }
  }
}
