import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jps_chess/data/settings_data.dart' as settings;
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings-page';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // The list of ints is the index of the color and the respective index of alpha used
  Map<String, List<int>> _mapPreferences;

  @override
  void initState() {
    loadPreferences();
    super.initState();
  }

  void setMapDefaults() {
    _mapPreferences = {
      'Player 1 Color': [0, 0],
      'Player 2 Color': [1, 0],
      'Selection Color': [8, 0],
      'Action Color': [5, 2],
      'Fixed Color': [10, 1],
      'Forced Color': [12, 2],
      'Targeted Color': [4, 1],
      'Traced Color': [14, 2],
    };
  }

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getKeys().isEmpty) {
        setMapDefaults();
      } else {
        _mapPreferences = {
          'Player 1 Color': [
            prefs.getInt('Player 1 Color-Color'),
            prefs.getInt('Player 1 Color-Alpha')
          ],
          'Player 2 Color': [
            prefs.getInt('Player 2 Color-Color'),
            prefs.getInt('Player 2 Color-Alpha')
          ],
          'Selection Color': [
            prefs.getInt('Selection Color-Color'),
            prefs.getInt('Selection Color-Alpha')
          ],
          'Action Color': [
            prefs.getInt('Action Color-Color'),
            prefs.getInt('Action Color-Alpha')
          ],
          'Fixed Color': [
            prefs.getInt('Fixed Color-Color'),
            prefs.getInt('Fixed Color-Alpha')
          ],
          'Forced Color': [
            prefs.getInt('Forced Color-Color'),
            prefs.getInt('Forced Color-Alpha')
          ],
          'Targeted Color': [
            prefs.getInt('Targeted Color-Color'),
            prefs.getInt('Targeted Color-Alpha')
          ],
          'Traced Color': [
            prefs.getInt('Traced Color-Color'),
            prefs.getInt('Traced Color-Alpha')
          ],
        };
      }
    });
  }

  Future<void> savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _mapPreferences.forEach((key, value) {
      prefs.setInt(key + '-Color', value.first);
      prefs.setInt(key + '-Alpha', value.last);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double fractionButtonHeight = 0.08;
    const double fractionDropHeight = 0.06;
    const double fractionDropWidth = 0.2;
    const Color colorBorder = Colors.amberAccent;
    const double sizeBorderWidth = 3;
    const double sizeBorderRadius = 10;
    const TextStyle styleSettings = TextStyle(
        color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal);

    bool isLoaded = _mapPreferences != null && _mapPreferences.isNotEmpty;
    if (isLoaded) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Settings / Info'),
            actions: [
              FlatButton(
                child: Text('Reset'),
                onPressed: () async {
                  setMapDefaults();
                  await savePreferences();
                  setState(() {});
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: _mapPreferences.length,
                  itemBuilder: (context, index) {
                    int intValue = _mapPreferences.values.toList()[index].first;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(
                          _mapPreferences.keys.toList()[index],
                          style: styleSettings,
                          textAlign: TextAlign.center,
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: settings.listColor[intValue],
                            border: Border.all(
                                color: colorBorder, width: sizeBorderWidth),
                            borderRadius:
                                BorderRadius.circular(sizeBorderRadius),
                          ),
                          width: MediaQuery.of(context).size.width *
                              fractionDropWidth,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: intValue,
                              items: settings.listColor
                                  .map((e) => DropdownMenuItem(
                                        value:
                                        settings.listColor.indexOf(e),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              fractionDropHeight,
                                          color: e,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) async {
                                _mapPreferences.values.toList()[index].first =
                                    value;
                                await savePreferences();
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Divider(
                thickness: sizeBorderWidth,
                color: Theme.of(context).primaryColor,
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _makeModeButton(context, fractionButtonHeight,
                        settings.listModeName, 0),
                    _makeModeButton(context, fractionButtonHeight,
                        settings.listModeName, 1),
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

Row _makeModeButton(BuildContext context, double fractionHeightMode,
    List<String> listModeName, int index) {
  const fractionWidthMode = 0.8;
  const TextStyle styleMode = TextStyle(
      color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal);

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
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
          onPressed: () async {
            switch (index) {
              case 0:
                if (await canLaunch(settings.strRulesUrl)) {
                  launch(settings.strRulesUrl);
                } else {
                  throw 'Could not launch ${settings.strRulesUrl}';
                }
                break;
              case 1:
                Navigator.pushNamed(context, '/about-page');
                break;
              default:
                break;
            }
          },
        ),
      ),
    ],
  );
}
