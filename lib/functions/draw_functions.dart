import 'package:flutter/material.dart';
import 'package:jps_chess/data/pieces_data.dart' as pieces;

Positioned makePiece(double dimBox, String strPieceName, Color colorPiece,
    List<int> listCoordinate) {
  const double fractionBox = 0.8;
  double fractionPiece = fractionBox * pieces.mapPieceSize[strPieceName];
  return Positioned(
    left: dimBox * (listCoordinate[0] + (1 - fractionPiece) / 2),
    bottom: dimBox * (listCoordinate[1] + (1 - fractionPiece) / 2),
    child: ImageIcon(
      AssetImage('assets/$strPieceName-piece.png'),
      color: colorPiece,
      size: dimBox * fractionPiece,
    ),
  );
}