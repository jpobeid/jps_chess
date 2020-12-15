import 'package:flutter/material.dart';

SnackBar makeGlobalSnackBar(String strMessage) {
  const int nMilliDuration = 1500;
  const TextStyle styleHead =
  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24);
  return SnackBar(
    backgroundColor: Colors.redAccent,
    content: Text(
      strMessage,
      style: styleHead,
    ),
    duration: Duration(
      milliseconds: nMilliDuration,
    ),
  );
}