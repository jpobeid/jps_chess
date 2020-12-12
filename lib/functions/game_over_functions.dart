int checkGameOverByKing(
    Map<String, int> mapGraveSelf,
    Map<String, int> mapGraveRival,
    bool isSelfCannotCheckmate,
    bool isRivalCannotCheckmate,) {
  // Return 0 to keep playing (no king game over), 1 to display defeat and 2 for victory
  bool isNotGameOverByKing =
      mapGraveSelf['king'] == 0 && mapGraveRival['king'] == 0;
  if (isNotGameOverByKing) {
    return 0;
  } else if (mapGraveSelf['king'] != 0) {
    return !isRivalCannotCheckmate ? 1 : 2;
  } else {
    return !isSelfCannotCheckmate ? 2 : 1;
  }
}

void addCannotCheckmateStatus(Function mapStatusTimerAdd, mapStatus) {
  const int nTurnsCannotCheckmate = 3;
  const List<List<int>> listListPlaceholder = [
    [-1, -1]
  ];
  mapStatusTimerAdd(
      mapStatus, 'cannotCheckmate', listListPlaceholder, nTurnsCannotCheckmate);
}

