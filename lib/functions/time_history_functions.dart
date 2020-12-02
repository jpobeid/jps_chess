// This is the template in different portions for the Time Wizard rewind capability
// However, because it is so damn hard to clone things in dart and the history list keeps updating
// with the variables it is supposed to be recording, this will be defered...

// void selectWizardRewindOption() {
//   int indexResult2 = await showDialog(
//       context: (context),
//       builder: (context) {
//         return makeSpecialAbilityDialog(context, [
//           'Rewind 1 self-turn\n(2 total turns)',
//           'Rewind 2 self-turns\n(4 total turns)'
//         ]);
//       });
//   if (indexResult2 == null) {
//     resetSpecialAbility();
//   } else {
//     int nTurnsToRevert = 2 * (indexResult2 + 1);
//     setState(() {
//       completeSpecialAbility(true, false, true);
//     });
//   }
// }
//
// void recordListHistory() {
//   Map<String, int> mapTurnPlayer = {
//     'nTurn': _nTurn,
//     'nActivePlayer': _indexActivePlayer,
//   };
//   if (_listListMapHistory.isEmpty || (_listListMapHistory.isNotEmpty && _listListMapHistory.last[0]['nTurn'] != mapTurnPlayer['nTurn'])) {
//     Map<String, List<List<int>>> mapSelfCopy = {};
//     _mapSelf.forEach((key, value) {
//       mapSelfCopy.addAll({key: value});
//     });
//     List<Map<String, dynamic>> listRecordingData = [
//       mapTurnPlayer,
//       _mapSelf,
//       _mapRival,
//       _mapGraveSelf,
//       _mapGraveRival,
//       _mapStatusSelf,
//       _mapStatusRival
//     ];
//     setState(() {
//       _listListMapHistory.add(listRecordingData);
//     });
//   }
// }
//
// void deletePastHistory() {
//   const int maxDesiredTurnRevert = 4;
//   int maxLengthHistory = maxDesiredTurnRevert + 2;
//   while (_listListMapHistory.length > maxLengthHistory) {
//     _listListMapHistory.removeAt(0);
//   }
// }
//
// void revertHistory(int nTurnsToRevert) {
//   _listListMapHistory.forEach((element) {
//     print(element);
//     print('----------------');
//   });
//   int indexRecordToQuery = (_listListMapHistory.length - nTurnsToRevert - 2);
//   if (indexRecordToQuery == -1) {
//     print('1');
//     List<dynamic> listRevertedData = starting.listListMapHistory0;
//     setState(() {
//       print(listRevertedData);
//       _nTurn = listRevertedData[0]['nTurn'];
//       _indexActivePlayer = listRevertedData[0]['nActivePlayer'];
//       _mapSelf = listRevertedData[1];
//       _mapRival = listRevertedData[2];
//       _mapGraveSelf = listRevertedData[3];
//       _mapGraveRival = listRevertedData[4];
//       _mapStatusSelf = listRevertedData[5];
//       _mapStatusRival = listRevertedData[6];
//       endTurn();
//     });
//   } else if (indexRecordToQuery > -1 && indexRecordToQuery < _listListMapHistory.length) {
//     print('2');
//     List<Map<String, dynamic>> listRevertedData = _listListMapHistory[indexRecordToQuery];
//     setState(() {
//       print(listRevertedData);
//       _nTurn = listRevertedData[0]['nTurn'];
//       _indexActivePlayer = listRevertedData[0]['nActivePlayer'];
//       _mapSelf = listRevertedData[1];
//       _mapRival = listRevertedData[2];
//       _mapGraveSelf = listRevertedData[3];
//       _mapGraveRival = listRevertedData[4];
//       _mapStatusSelf = listRevertedData[5];
//       _mapStatusRival = listRevertedData[6];
//       endTurn();
//     });
//   }
// }
