import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' as fnd;

class Board extends StatelessWidget {
  final double dimBoard;
  final int nDiv;
  final List<Color> listBoardColor;
  final List<int> listTap;
  final List<List<int>> listTupleDMotion;
  final bool isPieceAbilityActive;
  final List<List<int>> listTupleDPieceAbility;
  final bool isSpecialAbilityActive;
  final List<List<int>> listTupleAbsSpecialAbility;
  final Map<String, List<List<int>>> mapStatusSelf;
  final Map<String, List<List<int>>> mapStatusRival;
  final Color colorSelf;
  final Color colorRival;
  final bool isRivalSpecialSecret;

  const Board({
    Key key,
    this.dimBoard,
    this.nDiv,
    this.listBoardColor,
    this.listTap,
    this.listTupleDMotion,
    this.isPieceAbilityActive,
    this.listTupleDPieceAbility,
    this.isSpecialAbilityActive,
    this.listTupleAbsSpecialAbility,
    this.mapStatusSelf,
    this.mapStatusRival,
    this.colorSelf,
    this.colorRival,
    this.isRivalSpecialSecret,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: dimBoard,
      width: dimBoard,
      child: CustomPaint(
        painter: BoardPainter(
          nDiv: nDiv,
          listBoardColor: listBoardColor,
          listTap: listTap,
          listTupleDMotion: listTupleDMotion,
          isPieceAbilityActive: isPieceAbilityActive,
          listTupleDPieceAbility: listTupleDPieceAbility,
          isSpecialAbilityActive: isSpecialAbilityActive,
          listTupleAbsSpecialAbility: listTupleAbsSpecialAbility,
          mapStatusSelf: mapStatusSelf,
          mapStatusRival: mapStatusRival,
          colorSelf: colorSelf,
          colorRival: colorRival,
          isRivalSpecialSecret: isRivalSpecialSecret,
        ),
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final int nDiv;
  final List<Color> listBoardColor;
  final List<int> listTap;
  final List<List<int>> listTupleDMotion;
  final bool isPieceAbilityActive;
  final List<List<int>> listTupleDPieceAbility;
  final bool isSpecialAbilityActive;
  final List<List<int>> listTupleAbsSpecialAbility;
  final Map<String, List<List<int>>> mapStatusSelf;
  final Map<String, List<List<int>>> mapStatusRival;
  final Color colorSelf;
  final Color colorRival;
  final bool isRivalSpecialSecret;

  BoardPainter({
    this.nDiv,
    this.listBoardColor,
    this.listTap,
    this.listTupleDMotion,
    this.isPieceAbilityActive,
    this.listTupleDPieceAbility,
    this.isSpecialAbilityActive,
    this.listTupleAbsSpecialAbility,
    this.mapStatusSelf,
    this.mapStatusRival,
    this.colorSelf,
    this.colorRival,
    this.isRivalSpecialSecret,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBox0 = Paint();
    paintBox0.color = Colors.grey[300];

    Paint paintBox1 = Paint();
    paintBox1.color = Colors.grey[800];

    Paint paintBoxSelected = Paint();
    paintBoxSelected.color = listBoardColor[2];

    Paint paintBoxMotionPotential = Paint();
    paintBoxMotionPotential.color = Color.fromARGB(100, listBoardColor[2].red, listBoardColor[2].green, listBoardColor[2].blue);

    Paint paintBoxAbilityPotential = Paint();
    paintBoxAbilityPotential.color = listBoardColor[3];

    Paint paintBoxFixed = Paint();
    paintBoxFixed.color = listBoardColor[4];

    Paint paintBoxForced = Paint();
    paintBoxForced.color = listBoardColor[5];

    Paint paintBoxTargeted = Paint();
    paintBoxTargeted.color = listBoardColor[6];

    Paint paintBoxTraced = Paint();
    paintBoxTraced.color = listBoardColor[7];

    Paint paintBoxSelf = Paint();
    paintBoxSelf.color =
        Color.fromARGB(75, colorSelf.red, colorSelf.green, colorSelf.blue);

    Paint paintBoxRival = Paint();
    paintBoxRival.color = Color.fromARGB(isRivalSpecialSecret ? 0 : 75,
        colorRival.red, colorRival.green, colorRival.blue);

    List<Paint> listPaint = [
      paintBox0,
      paintBox1,
      paintBoxSelected,
      paintBoxMotionPotential,
      paintBoxAbilityPotential,
      paintBoxFixed,
      paintBoxForced,
      paintBoxTargeted,
      paintBoxSelf,
      paintBoxRival,
      paintBoxTraced,
    ];
    listPaint.forEach((element) {
      element.style = PaintingStyle.fill;
    });

    drawBoard(
        canvas,
        size,
        nDiv,
        listTap,
        listTupleDMotion,
        isPieceAbilityActive,
        listTupleDPieceAbility,
        isSpecialAbilityActive,
        listTupleAbsSpecialAbility,
        mapStatusSelf,
        mapStatusRival,
        listPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void drawBoard(
    Canvas canvas,
    Size size,
    int nDiv,
    List<int> listTap,
    List<List<int>> listTupleDMotion,
    bool isPieceAbilityActive,
    List<List<int>> listTupleDPieceAbility,
    bool isSpecialAbilityActive,
    List<List<int>> listTupleAbsSpecialAbility,
    Map<String, List<List<int>>> mapStatusSelf,
    Map<String, List<List<int>>> mapStatusRival,
    List<Paint> listPaint) {
  for (int j = 0; j < nDiv; j++) {
    for (int i = 0; i < nDiv; i++) {
      double x = (i + 1 / 2) * size.width / nDiv;
      double y = (j + 1 / 2) * size.height / nDiv;
      Paint boardPaint = (i + j) % 2 == 0 ? listPaint[0] : listPaint[1];
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(x, y),
              width: size.width / nDiv,
              height: size.height / nDiv),
          boardPaint);
      int jU = (nDiv - 1) - j;
      //Draw superimposed tags - First statuses then selections
      drawTagStatus(canvas, size, i, jU, x, y, nDiv, mapStatusSelf,
          mapStatusRival, listPaint);
      drawTagSelection(
          canvas,
          size,
          i,
          jU,
          x,
          y,
          nDiv,
          listTap,
          listTupleDMotion,
          isPieceAbilityActive,
          listTupleDPieceAbility,
          isSpecialAbilityActive,
          listTupleAbsSpecialAbility,
          listPaint);
    }
  }
}

void drawTagSelection(
    Canvas canvas,
    Size size,
    int i,
    int jU,
    double x,
    double y,
    int nDiv,
    List<int> listTap,
    List<List<int>> listTupleDMotion,
    bool isPieceAbilityActive,
    List<List<int>> listTupleDPieceAbility,
    bool isSpecialAbilityActive,
    List<List<int>> listTupleAbsSpecialAbility,
    List<Paint> listPaint) {
  //Generate the correct paint to label the box
  Paint tagPaint;
  //Selection based tags
  if (listTap.isNotEmpty && listTap[0] == i && listTap[1] == jU) {
    tagPaint = listPaint[2];
  } else if (!isPieceAbilityActive) {
    if (listTupleDMotion.isNotEmpty &&
        listTupleDMotion.any((element) =>
            (listTap[0] + element[0] == i && listTap[1] + element[1] == jU))) {
      tagPaint = listPaint[3];
    }
  } else if (isPieceAbilityActive) {
    if (listTupleDPieceAbility.any((element) =>
        (listTap[0] + element[0] == i && listTap[1] + element[1] == jU))) {
      tagPaint = listPaint[4];
    }
  }
  if (isSpecialAbilityActive) {
    if (listTupleAbsSpecialAbility
        .any((element) => fnd.listEquals(element, [i, jU]))) {
      tagPaint = listPaint[4];
    }
  }
  //Label that box with superimposed paint
  if (tagPaint != null) {
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(x, y),
            width: size.width / nDiv,
            height: size.height / nDiv),
        tagPaint);
  }
}

void drawTagStatus(
    Canvas canvas,
    Size size,
    int i,
    int jU,
    double x,
    double y,
    int nDiv,
    Map<String, List<List<int>>> mapStatusSelf,
    Map<String, List<List<int>>> mapStatusRival,
    List<Paint> listPaint) {
  //Generate the correct paint to label the box
  Paint tagPaint;
  //Status based tags
  if (checkStatus(mapStatusSelf, mapStatusRival, 'fixed', i, jU)) {
    tagPaint = listPaint[5];
  } else if (checkStatus(mapStatusSelf, mapStatusRival, 'forced', i, jU)) {
    tagPaint = listPaint[6];
  } else if (checkStatus(mapStatusSelf, mapStatusRival, 'targeted', i, jU)) {
    tagPaint = listPaint[7];
  } else if (checkStatus(mapStatusRival, mapStatusRival, 'traced', i, jU)) {
    tagPaint = listPaint[10];
  } else if (checkStatus(mapStatusSelf, mapStatusRival, 'mySpecial', i, jU)) {
    if (checkStatus(
            mapStatusSelf,
            {
              'mySpecial': [[]]
            },
            'mySpecial',
            i,
            jU) &&
        checkStatus({
          'mySpecial': [[]]
        }, mapStatusRival, 'mySpecial', i, jU)) {
      Paint paintMixed = Paint();
      Color paintMixedColor;
      if (listPaint[8].color.alpha == 0) {
        paintMixedColor = listPaint[9].color;
      } else if (listPaint[9].color.alpha == 0) {
        paintMixedColor = listPaint[8].color;
      } else {
        int nAlphaSum = listPaint[8].color.alpha + listPaint[9].color.alpha;
        paintMixedColor = Color.fromARGB(
            math.max(listPaint[8].color.alpha, listPaint[9].color.alpha),
            ((listPaint[8].color.red * listPaint[8].color.alpha +
                listPaint[9].color.red * listPaint[9].color.alpha) /
                (2 * nAlphaSum))
                .floor(),
            ((listPaint[8].color.green * listPaint[8].color.alpha +
                listPaint[9].color.green * listPaint[9].color.alpha) /
                (2 * nAlphaSum))
                .floor(),
            ((listPaint[8].color.blue * listPaint[8].color.alpha +
                listPaint[9].color.blue * listPaint[9].color.alpha) /
                (2 * nAlphaSum))
                .floor());
      }
      paintMixed.color = paintMixedColor;
      paintMixed.style = PaintingStyle.fill;
      tagPaint = paintMixed;
    } else if (checkStatus(
        mapStatusSelf,
        {
          'mySpecial': [[]]
        },
        'mySpecial',
        i,
        jU)) {
      tagPaint = listPaint[8];
    } else if (checkStatus({
      'mySpecial': [[]]
    }, mapStatusRival, 'mySpecial', i, jU)) {
      tagPaint = listPaint[9];
    }
  }
  //Label that box with superimposed paint
  if (tagPaint != null) {
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(x, y),
            width: size.width / nDiv,
            height: size.height / nDiv),
        tagPaint);
  }
}

bool checkStatus(
    Map<String, List<List<int>>> mapStatusSelf,
    Map<String, List<List<int>>> mapStatusRival,
    String strStatus,
    int i,
    int jU) {
  bool isStatus = false;
  if (mapStatusSelf[strStatus].isNotEmpty &&
      mapStatusSelf[strStatus]
          .any((element) => fnd.listEquals(element, [i, jU]))) {
    isStatus = true;
  }
  if (mapStatusRival[strStatus].isNotEmpty &&
      mapStatusRival[strStatus]
          .any((element) => fnd.listEquals(element, [i, jU]))) {
    isStatus = true;
  }
  return isStatus;
}
