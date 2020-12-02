import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jps_chess/functions/route_generator.dart';
import 'package:jps_chess/pages/title_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.red,
      scaffoldBackgroundColor: Colors.black,
    ),
    home: TitlePage(),
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}