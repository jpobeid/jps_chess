import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';

const int nDiv = 8;
int rMax = nDiv - 1;

const List<String> listPieceName = [
  'king',
  'queen',
  'rook',
  'bishop',
  'knight',
  'pawn',
];

const Map<String, double> mapPieceSize = {
  'king': 1,
  'queen': 1,
  'rook': 1,
  'bishop': 1,
  'knight': 1,
  'pawn': 0.9,
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
  'rook': ["Stoner's tower", 'Tower turrets', "Stoner's castle"],
  'bishop': ['Lunar laser-guided ballistic missile'],
  'knight': ['Big-ass-horse', 'Big-ass-L ("Big AL")'],
  'pawn': ['I gotchu homie'],
};

const Map<String, List<bool>> mapAbilitySingleUse = {
  'king': [true, false, false],
  'queen': [true],
  'rook': [true, true, true],
  'bishop': [true, true],
  'knight': [true, true],
  'pawn': [true],
};

const IconData iconPieceAbilitySingleUse = FlutterIcons.play_mco;
const IconData iconPieceAbilityContinuous = FlutterIcons.infinity_mco;
const IconData iconPieceAbilityCancel = Icons.clear;