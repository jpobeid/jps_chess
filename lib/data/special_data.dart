import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

const List<String> listSpecialName = [
  'Sniper from Heaven',
  'Time Wizard',
  'Necromancer',
  'Puppet Master',
  'Invisible Hands',
  'Navy SEAL Special Operations Units',
  'Mesmer',
  'Mind Control Tower',
];

const Map<String, List<dynamic>> mapSpecialSubtitleIcon = {
  'Sniper from Heaven': [
    'Establish a deadly assassin zone',
    FlutterIcons.crosshairs_faw5s,
  ],
  'Time Wizard': [
    'Twist and repeat time',
    FlutterIcons.history_faw5s,
  ],
  'Necromancer': [
    'Resurrect or swap from the grave',
    FlutterIcons.hat_wizard_faw5s,
  ],
  'Puppet Master': [
    'Controller of the masses',
    FlutterIcons.theater_masks_faw5s,
  ],
  'Invisible Hands': [
    "Force your opponent's hands",
    FlutterIcons.hand_mco,
  ],
  'Navy SEAL Special Operations Units': [
    'Elite squadron of pawns',
    FlutterIcons.ammunition_mco,
  ],
  'Mesmer': [
    'Target and trap deception',
    FlutterIcons.eye_off_mco,
  ],
  'Mind Control Tower': [
    "Paralyzing (ultimate stoner's) tower",
    FlutterIcons.radio_tower_mco,
  ],
};

const Map<String, List<int>> mapSpecialAttributes = {
  //Value order is [(# turns for uses), (isExtra), (canReset), (isPreGameAction), (isSpecialTagSecret)]
  'Sniper from Heaven': [1, 1, 1, 1, 0],
  'Time Wizard': [1, 0, 1, 0, 0],
  'Necromancer': [1, 0, 1, 0, 0],
  'Puppet Master': [1, 0, 0, 0, 0],
  'Invisible Hands': [2, 0, 0, 0, 0],
  'Navy SEAL Special Operations Units': [0, 0, 0, 0, 0],
  'Mesmer': [0, 0, 0, 1, 1],
  'Mind Control Tower': [0, 0, 0, 1, 0],
};

const Map<String, List<String>> mapSpecialExtra = {
  'Sniper from Heaven': ['1-shot, 2-zones', '2-shots, 1-zone'],
};

const IconData iconSingleUse = FlutterIcons.play_mco;
const IconData iconContinuous = FlutterIcons.infinity_mco;
