import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  static const routeName = '/about-page';

  final strVersion = '1.2';
  final TextStyle styleAboutHead =
      TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold);
  final TextStyle styleAboutSub = TextStyle(
      color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          makeAboutTextPortion('Conceived & designed by:', 'JP Obeid & Stephan Mouhanna\nCirca 2013'),
          makeAboutTextPortion('Coded in Dart/Flutter by:', 'JP Obeid\n2020'),
          makeAboutTextPortion('Version:', strVersion),
        ],
      ),
    );
  }
}

Row makeAboutTextPortion(String strHead, String strSub) {
  final TextStyle styleAboutHead =
      TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold);
  final TextStyle styleAboutSub = TextStyle(
      color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: strHead + '\n',
              style: styleAboutHead,
            ),
            TextSpan(
              text: strSub,
              style: styleAboutSub,
            )
          ],
        ),
      ),
    ],
  );
}
