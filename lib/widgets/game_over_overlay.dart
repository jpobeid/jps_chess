import 'package:flutter/material.dart';

class GameOverOverlay extends StatelessWidget {
  final String strMessage;
  final Color colorMessage;

  const GameOverOverlay({Key key, this.strMessage, this.colorMessage})
      : super(key: key);

  static const Color colorBorder = Colors.amberAccent;
  static const double sizeBorder = 5;
  static const double sizeBorderRadius = 20;
  static const double fractionWidthMessage = 0.75;
  static const double fractionHeightMessage = 0.35;
  static const Color colorFade = Color.fromARGB(135, 50, 50, 50);
  static const TextStyle styleMessage =
      TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AbsorbPointer(
        child: Container(
          color: colorFade,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorMessage,
                    border: Border.all(color: colorBorder, width: sizeBorder),
                    borderRadius: BorderRadius.circular(sizeBorderRadius),
                  ),
                  width: constraints.maxWidth * fractionWidthMessage,
                  height: constraints.maxHeight * fractionHeightMessage,
                  child: Material(
                    color: colorMessage,
                    child: Text(
                      strMessage,
                      style: styleMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
