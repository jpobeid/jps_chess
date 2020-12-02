import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';

const nDiv = 8;

const List<String> listPieceName = [
  'king',
  'queen',
  'rook',
  'bishop',
  'knight',
  'pawn',
];

const Map<String, IconData> mapPiece = {
  'king': FlutterIcons.chess_king_mco,
  'queen': FlutterIcons.chess_queen_mco,
  'rook': FlutterIcons.chess_rook_mco,
  'bishop': FlutterIcons.chess_bishop_mco,
  'knight': FlutterIcons.chess_knight_mco,
  'pawn': FlutterIcons.chess_pawn_mco,
};

const Map<String, String> mapName = {
  'king': 'King',
  'queen': 'Queen',
  'rook': 'Rook',
  'bishop': 'B1sh0p',
  'knight': 'Knight',
  'pawn': 'Pawn',
};

const Map<String, int> mapPieceRank = {
  'king': 5,
  'queen': 4,
  'rook': 3,
  'bishop': 2,
  'knight': 1,
  'pawn': 0,
};

const Map<String, List<String>> mapAbilityName = {
  'king': ['Begone bitch', 'Force field', 'I workout'],
  'queen': ['Summon big papi'],
  'rook': ["Stoner's tower", 'Tower turrets'],
  'bishop': ['Lunar laser-guided ballistic missile'],
  'knight': ['Big-ass-horse', 'Big-ass-L ("Big AL")'],
  'pawn': ['I gotchu homie'],
};

const Map<String, List<bool>> mapAbilitySingleUse = {
  'king': [true, false, false],
  'queen': [true],
  'rook': [true, true],
  'bishop': [true, true],
  'knight': [true, true],
  'pawn': [true],
};

const IconData iconPieceAbilitySingleUse = FlutterIcons.play_mco;
const IconData iconPieceAbilityContinuous = FlutterIcons.infinity_mco;
const IconData iconPieceAbilityCancel = Icons.clear;