import 'package:flutter/material.dart';
import 'package:jps_chess/pages/about_page.dart';
import 'package:jps_chess/pages/game_layout_offline.dart';
import 'package:jps_chess/pages/game_layout_online.dart';
import 'package:jps_chess/pages/lobby_page.dart';
import 'package:jps_chess/pages/login_page.dart';
import 'package:jps_chess/pages/settings_page.dart';
import 'package:jps_chess/pages/special_select_offline.dart';
import 'package:jps_chess/pages/special_select_online.dart';
import 'package:jps_chess/pages/title_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final List<dynamic> args = settings.arguments;
    switch (settings.name) {
      case (TitlePage.routeName):
        return MaterialPageRoute(builder: (context) => TitlePage());
        break;
      case (SettingsPage.routeName):
        return MaterialPageRoute(builder: (context) => SettingsPage());
        break;
      case (AboutPage.routeName):
        return MaterialPageRoute(builder: (context) => AboutPage());
        break;
      case (LoginPage.routeName):
        return MaterialPageRoute(builder: (context) => LoginPage());
        break;
      case (LobbyPage.routeName):
        if (args == null) {
          return MaterialPageRoute(builder: (context) => LobbyPage());
        } else {
          return MaterialPageRoute(
              builder: (context) => LobbyPage(
                    strServerName: args[0],
                  ));
        }
        break;
      case (SpecialSelectOffline.routeName):
        return MaterialPageRoute(builder: (context) => SpecialSelectOffline());
        break;
      case (SpecialSelectOnline.routeName):
        if (args == null) {
          return MaterialPageRoute(builder: (context) => SpecialSelectOnline());
        }
        return MaterialPageRoute(
            builder: (context) => SpecialSelectOnline(
                  strServerName: args[0],
                  indexPlayer: args[1],
                ));
        break;
      case (GameLayoutOffline.routeName):
        if (args == null) {
          return MaterialPageRoute(builder: (context) => GameLayoutOffline());
        } else {
          return MaterialPageRoute(
              builder: (context) => GameLayoutOffline(
                    listSpecialAbilityName: args[0],
                    listSpecialAbilityExtra: args[1],
                  ));
        }
        break;
      case (GameLayoutOnline.routeName):
        if (args == null) {
          return MaterialPageRoute(builder: (context) => GameLayoutOnline());
        } else {
          return MaterialPageRoute(
              builder: (context) => GameLayoutOnline(
                    strServerName: args[0],
                  ));
        }
        break;
      default:
        return MaterialPageRoute(builder: (context) => ErrorApp());
    }
  }
}

class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error!'),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Text(
          'Routing Error!',
        ),
      ),
    );
  }
}
