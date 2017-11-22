/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2014 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

"use strict";

function testAllMoves() {
  var ii = 0;
  var mm = 0;
  var start = (new Date()).getTime();
  resetAlert();
  for (var gg = 0; gg < numberOfGames; gg++) {
    Init(gg);
    for (var vv = 0; vv < numberOfVars; vv++) {
      for (var hh = StartPlyVar[vv]; hh <= StartPlyVar[vv] + PlyNumberVar[vv]; hh++) {
        GoToMove(hh, vv);
        mm++;
        if ((++ii % 100 === 0) && console) { console.log("i=" + ii + " g=" + gg + "/" + numberOfGames + " a=" + alertNumSinceReset); }
      }
    }
  }
  var tt = ((new Date()).getTime() - start) / 1000;
  if (console) { console.log("t=" + tt + "s mps=" + Math.floor(mm / tt) + " a=" + alertNumSinceReset); }
  return alertNumSinceReset;
}

function testRandomMoves(nn, pv, pg) {
  var start = (new Date()).getTime();
  resetAlert();
  if (typeof(nn) == "undefined") { nn = numberOfGames * 100; }
  if (typeof(pv) == "undefined") { pv = 0.5; }
  if (typeof(pg) == "undefined") { pg = 0.1; }
  var gg = 0;
  var vv = 0;
  var mm = 0;
  for (var ii = 1; ii <= nn; ii++) {
    if (Math.random() < pg) {
      gg = Math.floor(numberOfGames * Math.random());
      Init(gg);
      vv = 0;
    }
    if (Math.random() < pv) {
      vv = Math.floor(numberOfVars * Math.random());
    }
    var hh = StartPlyVar[vv] + Math.floor((PlyNumberVar[vv] + 1) * Math.random());
    GoToMove(hh, vv);
    mm++;
    if ((ii % 100 === 0) && console) { console.log("i=" + ii + "/" + nn + " a=" + alertNumSinceReset); }
  }
  var tt = ((new Date()).getTime() - start) / 1000;
  if (console) { console.log("t=" + tt + "s mps=" + Math.floor(mm / tt) + " a=" + alertNumSinceReset); }
  return alertNumSinceReset;
}

function customFunctionOnAlert(msg) {
  if (console) { console.log("  alert: g=" + currentGame + " v=" + CurrentVar + " p=" + CurrentPly + " m=" + msg); }
}

