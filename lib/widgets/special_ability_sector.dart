import 'package:flutter/material.dart';
import 'package:jps_chess/data/special_data.dart' as specials;
import 'package:jps_chess/functions/snack_bar_functions.dart';

class SpecialAbilitySector extends StatefulWidget {
  final int indexPlayer;
  final String strSpecialAbilityName;
  final String strRivalSpecialAbilityName;
  final bool isSpecialAbilitySingleUse;
  final bool isSpecialAbilityActive;
  final bool isSpecialAbilityAvailable;
  final bool canSpecialAbilityReset;
  final Function specialAbilityOnPressed;

  const SpecialAbilitySector(
      {Key key,
      this.indexPlayer,
      this.strSpecialAbilityName,
      this.strRivalSpecialAbilityName,
      this.isSpecialAbilitySingleUse,
      this.isSpecialAbilityActive,
      this.isSpecialAbilityAvailable,
      this.canSpecialAbilityReset,
      this.specialAbilityOnPressed})
      : super(key: key);

  @override
  _SpecialAbilitySectorState createState() => _SpecialAbilitySectorState();
}

class _SpecialAbilitySectorState extends State<SpecialAbilitySector> {
  static const TextStyle styleHead1 =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30);
  static const TextStyle styleHead2 =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30);
  static const List<int> listSpecialFlex = [5, 1];
  static const double fractionWidthButton = 0.8;
  static const Color colorSingleUseAvailable = Colors.amber;
  static const Color colorSingleUseActive = Colors.red;
  static const Color colorSingleUseNotAvailable = Colors.grey;
  static const Color colorContinuous = Colors.red;

  List<dynamic> getDisplayData() {
    Color colorDisplay;
    String strDisplay;
    IconData iconDisplay;
    if (widget.isSpecialAbilitySingleUse) {
      if (widget.isSpecialAbilityActive) {
        colorDisplay = colorSingleUseActive;
        strDisplay = widget.canSpecialAbilityReset ? 'Reset' : 'End';
        iconDisplay = Icons.star;
      } else if (widget.isSpecialAbilityAvailable) {
        colorDisplay = colorSingleUseAvailable;
        strDisplay = 'Activate';
        iconDisplay = specials.iconSingleUse;
      } else {
        colorDisplay = colorSingleUseNotAvailable;
        strDisplay = 'Not Available';
        iconDisplay = Icons.cancel_outlined;
      }
    } else {
      colorDisplay = colorContinuous;
      strDisplay = 'Active';
      iconDisplay = specials.iconContinuous;
    }
    return [colorDisplay, strDisplay, iconDisplay];
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> listDisplayData = getDisplayData();
    Color colorDisplay = listDisplayData[0];
    String strDisplay = listDisplayData[1];
    IconData iconDisplay = listDisplayData[2];
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: listSpecialFlex[0],
                child: GestureDetector(
                  child: Text(
                    widget.strSpecialAbilityName,
                    style: styleHead1,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    String strRivalSpecialMessage = 'Opponent: ${widget.strRivalSpecialAbilityName}';
                    ScaffoldMessenger.of(context).showSnackBar(
                      makeGlobalSnackBar(strRivalSpecialMessage),
                    );
                  },
                ),
              ),
              Expanded(
                flex: listSpecialFlex[1],
                child: Icon(
                  specials.mapSpecialSubtitleIcon[widget.strSpecialAbilityName]
                      [1],
                  size: styleHead1.fontSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Builder(builder: (context) {
            return FractionallySizedBox(
              widthFactor: fractionWidthButton,
              child: Card(
                color: colorDisplay,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    title: Text(
                      strDisplay,
                      style: styleHead2,
                      textAlign: TextAlign.center,
                    ),
                    trailing: Icon(
                      iconDisplay,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: styleHead2.fontSize,
                    ),
                  ),
                  onPressed: () async {
                    await widget.specialAbilityOnPressed(
                        widget.strSpecialAbilityName,
                        widget.isSpecialAbilitySingleUse,
                        widget.isSpecialAbilityAvailable,
                        widget.isSpecialAbilityActive,
                        widget.canSpecialAbilityReset);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
