import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';

class TitlePage extends StatefulWidget {
  static const routeName = '/title-page';

  static const Icon iconSettings = Icon(Icons.settings, color: Color.fromARGB(255, 220, 220, 220), size: 36);
  static const TextStyle styleTitle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  static const double fractionWidthTitle = 0.8;
  static const double fractionHeightMode = 0.1;
  static const double scaleHeightMode = 3.5;
  static const int flexSpacer = 2;
  static const List<int> listFlexColumn = [1, 2, 5];
  static const List<String> listModeName = [
    'Single Device - Alternating Orientation',
    'Multiple Devices',
  ];

  @override
  _TitlePageState createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  Artboard _riveArtBoard;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
    rootBundle.load('assets/chess_board_animation.riv').then((data) async {
      var file = RiveFile();
      bool success = file.import(data);
      if (success) {
        var artBoard = file.mainArtboard;
        artBoard.addController(
          SimpleAnimation('Idle'),
        );
        setState(() {
          _riveArtBoard = artBoard;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actions: [
              FlatButton.icon(
                icon: TitlePage.iconSettings,
                label: Text(''),
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings-page');
                },
              )
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: TitlePage.listFlexColumn[1],
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: FractionallySizedBox(
                    widthFactor: TitlePage.fractionWidthTitle,
                    child: FittedBox(
                      child: Text(
                        "JP's Chess",
                        style: TitlePage.styleTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: TitlePage.listFlexColumn[2],
                child: Container(
                  child: _riveArtBoard == null
                      ? Container()
                      : Rive(
                          artboard: _riveArtBoard,
                        ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height *
                    TitlePage.scaleHeightMode *
                    TitlePage.fractionHeightMode,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _makeModeButton(context, TitlePage.fractionHeightMode,
                        TitlePage.listModeName, 0),
                    _makeModeButton(context, TitlePage.fractionHeightMode,
                        TitlePage.listModeName, 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold();
    }
  }
}

Container _makeModeButton(BuildContext context, double fractionHeightMode,
    List<String> listModeName, int index) {
  const fractionWidthMode = 0.8;
  const TextStyle styleMode = TextStyle(
      color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal);

  return Container(
    width: MediaQuery.of(context).size.width * fractionWidthMode,
    height: MediaQuery.of(context).size.height * fractionHeightMode,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white, width: 2),
      borderRadius: BorderRadius.circular(10),
    ),
    child: FlatButton(
      child: Text(
        listModeName[index],
        style: styleMode,
        textAlign: TextAlign.center,
      ),
      onPressed: () {
        switch (index) {
          case 0:
            Navigator.of(context)
                .pushReplacementNamed('/special-select-offline', arguments: [false, 0]);
            break;
          case 1:
            Navigator.of(context).pushReplacementNamed('/login-page');
            break;
          default:
            break;
        }
      },
    ),
  );
}
