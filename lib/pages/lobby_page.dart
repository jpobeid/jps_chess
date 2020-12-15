import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:jps_chess/data/database_data.dart' as datas;

class LobbyPage extends StatefulWidget {
  static const String routeName = '/lobby-page';

  final String strServerName;

  const LobbyPage({Key key, this.strServerName}) : super(key: key);

  static const int minPlayersRequired = 2;
  static const double sizeIndicator = 15;
  static const TextStyle styleHead1 = TextStyle(
      color: Colors.blue, fontSize: 24, fontWeight: FontWeight.normal);
  static const TextStyle styleHead2 = TextStyle(
      color: Colors.black, fontSize: 24, fontWeight: FontWeight.normal);

  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  final User _user = FirebaseAuth.instance.currentUser;
  StreamSubscription _subscribeDatabase;
  int _nLobby0;

  Future<int> getCurrentLobbyPopulation() async {
    DataSnapshot dataLobby = await _databaseReference
        .child(datas.strLobbyData)
        .child(widget.strServerName)
        .once();
    return dataLobby.value[datas.strKeyN];
  }

  Future<void> proceedOrSubscribe() async {
    _nLobby0 = await getCurrentLobbyPopulation();
    if (_nLobby0 != null && _nLobby0 >= LobbyPage.minPlayersRequired) {
      setState(() {
        proceedToGame();
      });
    } else {
      _subscribeDatabase = _databaseReference
          .child(datas.strLobbyData)
          .child(widget.strServerName)
          .onChildChanged
          .listen((event) {
        int nLobby = event.snapshot.value;
        if (nLobby >= LobbyPage.minPlayersRequired) {
          setState(() {
            proceedToGame();
          });
        }
      });
    }
  }

  void createUserDataProfiles(int indexPlayer) {
    String strVarUser =
        indexPlayer == 0 ? datas.strKey1VarUser0 : datas.strKey1VarUser1;
    Map<String, dynamic> mapUserProperty = {
      datas.strKey2Uid: _user.uid,
      datas.strKey2IndexPlayer: indexPlayer,
    };
    //Set indexActivePlayer to 0 && nPlayers to 2 && intGameOverByKing to 0
    _databaseReference
        .child(datas.strGameData)
        .child(widget.strServerName)
        .child(datas.strKey1VarGlobal)
        .update({datas.strKey2IndexActivePlayer: 0, datas.strKey2NPlayers: 2, datas.strKey2listGameOverByKing: [0, 0],});
    //Set user profile properties
    mapUserProperty.forEach((key, value) {
      _databaseReference
          .child(datas.strGameData)
          .child(widget.strServerName)
          .child(strVarUser)
          .update({key: value});
    });
  }

  void proceedToGame() {
    int indexPlayer = (_nLobby0 - 1);
    createUserDataProfiles(indexPlayer);
    Navigator.pushReplacementNamed(context, '/special-select-online',
        arguments: [widget.strServerName, indexPlayer]);
  }

  @override
  void initState() {
    proceedOrSubscribe();
    super.initState();
  }

  @override
  void dispose() {
    if (_subscribeDatabase != null) {
      _subscribeDatabase.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sizeProgressCircle = math.min(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) *
        0.5;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Game lobby'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: sizeProgressCircle,
                height: sizeProgressCircle,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]),
                  strokeWidth: LobbyPage.sizeIndicator,
                ),
              ),
              Text(
                'Waiting for both players...',
                style: LobbyPage.styleHead1,
                textAlign: TextAlign.center,
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Exit',
                  style: LobbyPage.styleHead2,
                ),
                onPressed: () {
                  if (_nLobby0 == 1) {
                    _databaseReference.child(datas.strLobbyData).child(widget.strServerName).remove();
                    _databaseReference.child(datas.strServerData).child(widget.strServerName).remove();
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
