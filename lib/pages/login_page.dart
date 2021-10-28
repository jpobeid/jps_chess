import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jps_chess/data/database_data.dart' as datas;
import 'package:jps_chess/services/auth.dart';
import 'package:jps_chess/functions/snack_bar_functions.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login-page';

  static const List<int> listFlexColumn = [1, 1, 1, 6];
  static const double sizeBorderRadius = 20;
  static const double fractionToggleButton = 0.9;
  static const TextStyle styleHead =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24);
  static const TextStyle styleHead2 =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28);
  static const int maxInputLength = 7;
  static const List<String> listInputs = [
    'Server Name:',
    'Server Pass:',
  ];
  static const int expirationDurationHours = 12;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  User _userActive;
  List<bool> _listToggleSelected = [true, false];
  List<TextEditingController> _listController = [
    TextEditingController(text: ''),
    TextEditingController(text: ''),
    TextEditingController(text: ''),
  ];

  Future<void> initSignIn() async {
    User getActiveUser = await _authService.signInAnon();
    setState(() {
      _userActive = getActiveUser;
    });
  }

  Future<Map<dynamic, dynamic>> getServerMaps() async {
    DataSnapshot snapshot =
        await _databaseReference.child(datas.strServerData).once();
    if (snapshot.value != null) {
      return Map<dynamic, dynamic>.from(snapshot.value);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    initSignIn();
  }

  @override
  void dispose() {
    _listController.forEach((element) {
      element.dispose();
    });
    _authService.signOut();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoadingUser = _userActive == null;
    if (!isLoadingUser) {
      return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Multiple devices'),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  _authService.signOut();
                  Navigator.pushReplacementNamed(context, '/title-page');
                },
                icon: Icon(Icons.people_alt),
                label: Text('Logout'),
              )
            ],
          ),
          body: Column(
            children: [
              Spacer(
                flex: LoginPage.listFlexColumn[0],
              ),
              Expanded(
                flex: LoginPage.listFlexColumn[1],
                child: ToggleButtons(
                  fillColor: Colors.red,
                  borderRadius:
                      BorderRadius.circular(LoginPage.sizeBorderRadius),
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          LoginPage.fractionToggleButton /
                          2,
                      child: Text(
                        'Create Server',
                        style: LoginPage.styleHead,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width *
                          LoginPage.fractionToggleButton /
                          2,
                      child: Text(
                        'Join Server',
                        style: LoginPage.styleHead,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  isSelected: _listToggleSelected,
                  onPressed: (index) {
                    setState(() {
                      _listToggleSelected =
                          _listToggleSelected.map((e) => !e).toList();
                      _listController.forEach((element) {
                        element.clear();
                      });
                    });
                  },
                ),
              ),
              Spacer(
                flex: LoginPage.listFlexColumn[2],
              ),
              Expanded(
                flex: LoginPage.listFlexColumn[3],
                child: ListView.builder(
                    itemCount: LoginPage.listInputs.length + 1,
                    itemBuilder: (context, index) {
                      const double fractionHeight = 0.08;
                      const double fractionButtonWidth = 0.5;
                      if (index <= LoginPage.listInputs.length - 1) {
                        return Container(
                          height: MediaQuery.of(context).size.height *
                              fractionHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  LoginPage.listInputs[index],
                                  style: LoginPage.styleHead2,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(0),
                                  ),
                                  style: LoginPage.styleHead2,
                                  textAlign: TextAlign.center,
                                  controller: _listController[index],
                                  maxLength: LoginPage.maxInputLength,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height *
                              2 *
                              fractionHeight,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height *
                                fractionHeight,
                            width: MediaQuery.of(context).size.width *
                                fractionButtonWidth,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(
                                  LoginPage.sizeBorderRadius),
                            ),
                            child: TextButton(
                              child: Text(
                                _listToggleSelected[0] ? 'Create' : 'Join',
                                style: LoginPage.styleHead,
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () async {
                                Map<dynamic, dynamic> mapServerData =
                                    await getServerMaps();
                                String strServerName = _listController[0].text;
                                String strServerPass = _listController[1].text;
                                bool isServerNameValid =
                                    strServerName.length > 0;
                                bool isServerPassValid =
                                    strServerPass.length > 0;
                                bool isServerNameTaken = mapServerData == null
                                    ? false
                                    : mapServerData.containsKey(strServerName);
                                if (isServerNameValid && isServerPassValid) {
                                  if (_listToggleSelected[0]) {
                                    if (!isServerNameTaken) {
                                      //Successful CREATE connection!
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(makeGlobalSnackBar(
                                              'Successful connection!'));
                                      //Generate the server data
                                      _databaseReference
                                          .child(datas.strServerData)
                                          .update({
                                        strServerName: {
                                          datas.strKey1Pass: strServerPass,
                                          datas.strKey1ActiveUsers: {
                                            _userActive.uid: 1,
                                          },
                                          datas.strKey1ExpireDatetime: DateTime
                                                  .now()
                                              .toUtc()
                                              .add(Duration(
                                                  hours: LoginPage
                                                      .expirationDurationHours))
                                              .millisecondsSinceEpoch,
                                        }
                                      });
                                      //Clean up expired server data
                                      removeExpiredServers(
                                          _databaseReference, mapServerData);
                                      //Generate the lobby data and enter the lobby
                                      _databaseReference
                                          .child(datas.strLobbyData)
                                          .update({
                                        strServerName: {'n': 1}
                                      });
                                      Navigator.pushNamed(
                                          context, '/lobby-page',
                                          arguments: [strServerName]);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(makeGlobalSnackBar(
                                              'Server name taken...'));
                                    }
                                  } else if (_listToggleSelected[1]) {
                                    if (isServerNameTaken) {
                                      bool isPassCorrect =
                                          mapServerData[strServerName]
                                                      [datas.strKey1Pass]
                                                  .toString() ==
                                              _listController[1].text;
                                      bool isServerNotFull =
                                          mapServerData[strServerName]
                                                      [datas.strKey1ActiveUsers]
                                                  .length <
                                              datas.nServerMaxPlayers;
                                      if (isPassCorrect && isServerNotFull) {
                                        //Successful JOIN connection!
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(makeGlobalSnackBar(
                                                'Successful connection!'));
                                        _databaseReference
                                            .child(datas.strServerData)
                                            .child(strServerName)
                                            .child(datas.strKey1ActiveUsers)
                                            .update({_userActive.uid: 1});
                                        //Get that lobby's current population number
                                        DataSnapshot snapshot =
                                            await _databaseReference
                                                .child(datas.strLobbyData)
                                                .once();
                                        int nPopulation =
                                            snapshot.value[strServerName]
                                                [datas.strKeyN];
                                        //Go to lobby and add +1 to the number in it
                                        _databaseReference
                                            .child(datas.strLobbyData)
                                            .update({
                                          strServerName: {
                                            datas.strKeyN: (nPopulation + 1)
                                          }
                                        });
                                        Navigator.pushNamed(
                                            context, '/lobby-page',
                                            arguments: [strServerName]);
                                      } else if (!isPassCorrect) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(makeGlobalSnackBar(
                                                'Incorrect password...'));
                                      } else if (!isServerNotFull) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(makeGlobalSnackBar(
                                                'Server is full...'));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(makeGlobalSnackBar(
                                              'Server not found...'));
                                    }
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      makeGlobalSnackBar(
                                          'Empty inputs present...'));
                                }
                              },
                            ),
                          ),
                        );
                      }
                    }),
              )
            ],
          ),
        ),
      );
    } else {
      return makeProgressIndicator(context);
    }
  }
}

Center makeProgressIndicator(BuildContext context) {
  const double fractionSize = 0.2;
  double sizeContainer = math.min(MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height) *
      fractionSize;
  return Center(
    child: Container(
      width: sizeContainer,
      height: sizeContainer,
      child: CircularProgressIndicator(),
    ),
  );
}

void removeExpiredServers(
    DatabaseReference reference, Map<dynamic, dynamic> mapServerData) {
  int nNow = DateTime.now().millisecondsSinceEpoch;
  if (mapServerData != null && mapServerData.isNotEmpty) {
    mapServerData.forEach((key, value) {
      if (value[datas.strKey1ExpireDatetime] < nNow) {
        reference.child(datas.strServerData).child(key).remove();
        reference.child(datas.strLobbyData).child(key).remove();
        reference.child(datas.strGameData).child(key).remove();
      }
    });
  }
}
