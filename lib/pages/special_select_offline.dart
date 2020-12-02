import 'dart:async';

import 'package:csv/csv.dart' as csv;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jps_chess/data/player_data.dart' as players;
import 'package:jps_chess/data/special_data.dart' as specials;

List<bool> _listToggle = [true, false];
final List<String> listSpecialSubtitle = List<String>.from(
    specials.mapSpecialSubtitleIcon.values.map((e) => e[0]).toList());
final List<IconData> listSpecialIcon = List<IconData>.from(
    specials.mapSpecialSubtitleIcon.values.map((e) => e[1]).toList());
final List<int> listNumberSpecialUses =
    specials.mapSpecialAttributes.values.map((e) => e[0]).toList();
final List<int> listIsExtra =
    specials.mapSpecialAttributes.values.map((e) => e[1]).toList();

class SpecialSelectOffline extends StatefulWidget {
  static const routeName = '/special-select-offline';

  final List<String> listSpecialName = specials.listSpecialName;

  @override
  _SpecialSelectState createState() => _SpecialSelectState();
}

class _SpecialSelectState extends State<SpecialSelectOffline> {
  static const TextStyle styleTitle =
      TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle styleSubtitle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static const List<int> listFlexColumn = [8, 1];

  List<List<dynamic>> dataAbilities;
  int _indexPlayer = 0;
  List<String> _listPlayerSpecialAbility = [];
  List<int> _listPlayerSpecialAbilityExtra = [];

  Future<void> loadCsv(String pathCsv) async {
    String strCsv = await rootBundle.loadString(pathCsv);
    setState(() {
      dataAbilities = csv.CsvToListConverter().convert(strCsv);
    });
  }

  void proceedToGame(List<String> listPlayerSpecialAbility,
      List<int> listPlayerSpecialAbilityExtra) {
    //Navigate to Game if lists are full
    if (listPlayerSpecialAbility.length == 2) {
      Navigator.pushReplacementNamed(context, '/game-layout-offline',
          arguments: [
            listPlayerSpecialAbility,
            listPlayerSpecialAbilityExtra,
          ]);
    }
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    loadCsv('assets/abilities.csv');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool toBuild = dataAbilities != null &&
        MediaQuery.of(context).orientation == Orientation.portrait;
    if (toBuild) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor:
                _indexPlayer == 0 ? players.colorTeam0 : players.colorTeam1,
            automaticallyImplyLeading: false,
            title: Text(
                '${_indexPlayer == 0 ? players.strPlayer0 : players.strPlayer1} - Special Ability Select'),
          ),
          body: Column(
            children: [
              makeSpecialSelectionList(),
              _listPlayerSpecialAbility.isNotEmpty
                  ? makeBottomSelectionBar()
                  : Container(),
            ],
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
      flex: _listPlayerSpecialAbility.isNotEmpty ? listFlexColumn[1] : 0,
      child: _listPlayerSpecialAbility.isNotEmpty
          ? Container(
              color:
                  _indexPlayer == 1 ? players.colorTeam0 : players.colorTeam1,
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
            )
          : Container(),
    );
  }

  void onConfirmDialogResult(
      String strSpecialName, bool result, int indexReference) {
    if (result != null && result) {
      setState(() {
        if (listIsExtra[indexReference] == 1) {
          _listPlayerSpecialAbilityExtra.add(_listToggle.indexOf(true) + 1);
        } else {
          _listPlayerSpecialAbilityExtra.add(0);
        }
        _listPlayerSpecialAbility.add(strSpecialName);
        _indexPlayer++;
        proceedToGame(
            _listPlayerSpecialAbility, _listPlayerSpecialAbilityExtra);
      });
    } else {
      _listToggle = [true, false];
    }
  }
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
