import 'package:flutter/material.dart';

const nDiv = 8;

//Player 0
const String strPlayer0 = 'Player 1';
const Color colorTeam0 = Color.fromARGB(255, 33, 150, 243);

//Player 1
const String strPlayer1 = 'Player 2';
const Color colorTeam1 = Color.fromARGB(255, 244, 67, 54);

//Starting relative positions
//This VERY much depends on the actual player # since player0 will have a king at pos 4 and player1 at pos 3
const int j00 = 0;
const int j01 = 1;
const Map<int, Map<String, List<List<int>>>> mapMapStartPosition = {
  0: {
    'king': [
      [4, j00]
    ],
    'queen': [
      [3, j00]
    ],
    'rook': [
      [0, j00],
      [7, j00]
    ],
    'bishop': [
      [2, j00],
      [5, j00]
    ],
    'knight': [
      [1, j00],
      [6, j00]
    ],
    'pawn': [
      [0, j01],
      [1, j01],
      [2, j01],
      [3, j01],
      [4, j01],
      [5, j01],
      [6, j01],
      [7, j01]
    ],
  },
  1: {
    'king': [
      [3, j00]
    ],
    'queen': [
      [4, j00]
    ],
    'rook': [
      [0, j00],
      [7, j00]
    ],
    'bishop': [
      [2, j00],
      [5, j00]
    ],
    'knight': [
      [1, j00],
      [6, j00]
    ],
    'pawn': [
      [0, j01],
      [1, j01],
      [2, j01],
      [3, j01],
      [4, j01],
      [5, j01],
      [6, j01],
      [7, j01]
    ],
  },
};

const Map<String, int> mapStartGrave = {
  'king': 0,
  'queen': 0,
  'rook': 0,
  'bishop': 0,
  'knight': 0,
  'pawn': 0,
};

const Map<String, List<List<int>>> mapStartStatus = {
  'fixed': [],
  'forced': [],
  'targeted': [],
  'cannotCheckmate': [],
  'timer': [],
  'mySpecial': [],
  'mySpecialLabel': [],
  'mySpecialSecret': [],
};