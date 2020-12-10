import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jps_chess/data/settings_data.dart' as settings;

Future<List<Color>> loadBoardColors() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, List<int>> mapPreferences;
  if (prefs.getKeys().isEmpty) {
    mapPreferences = {
      'Player 1 Color': [0, 0],
      'Player 2 Color': [1, 0],
      'Selection Color': [8, 0],
      'Action Color': [5, 2],
      'Fixed Color': [10, 1],
      'Forced Color': [12, 2],
      'Targeted Color': [4, 1],
    };
  } else {
    mapPreferences = {
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
    };
  }
  return mapPreferences.values.map((e) => Color.fromARGB(settings.listAlpha[e.last], settings.listColor[e.first].red, settings.listColor[e.first].green, settings.listColor[e.first].blue)).toList();
}
