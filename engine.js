/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2015 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

"use strict";

if (typeof(pgn4web_engineWindowDisableAnalysisBoard) == "undefined") { var pgn4web_engineWindowDisableAnalysisBoard = false; }

var pgn4web_engineWindowTarget = "pgn4webEngineAnalysisBoard";
var pgn4web_engineWindowUrlParameters = "";
var pgn4web_engineWindowHeight = 30 * 12; // window height/width corresponding to default squareSize = 30
var pgn4web_engineWindowWidth = 30 * 10;

// notes:
// - all pages on the same site will use the same analysis board popup; if the analysis board is embedded as iframe within a page (see the live-results.html example) the pgn4web_engineWindowTarget variable should be customized in order to prevent conflicts
// - if pgn4web_engineWindowUrlParameters is customized using the corresponding URL parameter of the main page, the value must be encoded with encodeURIComponent()

if (typeof(thisRegExp) == "undefined") { var thisRegExp; }
thisRegExp = /(&|\?)(engineWindowDisableAnalysisBoard|ewdab)=(true|t)(&|$)/i;
if (window.location.search.match(thisRegExp) !== null) {
  pgn4web_engineWindowDisableAnalysisBoard = true;
}
thisRegExp = /(&|\?)(engineWindowTarget|ewt)=([^&]+)(&|$)/i;
if (window.location.search.match(thisRegExp) !== null) {
  pgn4web_engineWindowTarget = unescape(window.location.search.match(thisRegExp)[3]);
}
thisRegExp = /(&|\?)(engineWindowUrlParameters|ewup)=([^&]+)(&|$)/i;
if (window.location.search.match(thisRegExp) !== null) {
  pgn4web_engineWindowUrlParameters = unescape(window.location.search.match(thisRegExp)[3]);
}
thisRegExp = /(&|\?)(engineWindowHeight|ewh)=([1-9][0-9]*)(&|$)/i;
if (window.location.search.match(thisRegExp) !== null) {
  pgn4web_engineWindowHeight = parseInt(unescape(window.location.search.match(thisRegExp)[3]), 10);
}
thisRegExp = /(&|\?)(engineWindowWidth|eww)=([1-9][0-9]*)(&|$)/i;
if (window.location.search.match(thisRegExp) !== null) {
  pgn4web_engineWindowWidth = parseInt(unescape(window.location.search.match(thisRegExp)[3]), 10);
}


if (!pgn4web_engineWindowDisableAnalysisBoard) {
  boardShortcut("A8", "pgn4web v" + pgn4web_version + " debug info", function(t,e){ if (e.shiftKey) { if (engineWinCheck()) { engineWin.displayDebugInfo(); } } else { displayDebugInfo(); } }, true);
  boardShortcut("E8", "open/update analysis board", function(t,e){ showEngineAnalysisBoard(e.shiftKey); });
  boardShortcut("F8", "close/pause analysis board", function(t,e){ if (engineWinCheck()) { if (e.shiftKey) { if ((engineWin.top === engineWin.self) && (engineWin.focus)) { engineWin.focus(); } } else { engineWin.StopBackgroundEngine(); if ((engineWin.top === engineWin.self) && (engineWin.close)) { engineWin.close(); } } } });
}

function customShortcutKey_Shift_8() { showEngineAnalysisBoard(true); }
function customShortcutKey_Shift_9() { showEngineAnalysisBoard(false); }
function customShortcutKey_Shift_0() { showEngineAnalysisBoard(); }


var pgn4web_engineWinSignature = Math.ceil(1073741822 * Math.random()); // from 1 to (2^30 -1) = 1073741823

var engineWinParametersSeparator = "?";
function detectEngineLocation() {
  return detectJavascriptLocation().replace(/(pgn4web|pgn4web-compacted)\.js/, "engine.html");
}

var engineWin;

var engineWinLastFen = "";

var warnedAboutUnsupportedVariation = "";

function showEngineAnalysisBoard(engineDisabled, startFen) {
  if (pgn4web_engineWindowDisableAnalysisBoard) { return null; }
  if ((typeof(gameVariant[currentGame]) == "undefined") || (gameVariant[currentGame].match(/^\s*(|chess|normal|standard)\s*$/i) !== null) || (startFen)) {
    warnedAboutUnsupportedVariation = "";
    engineWinLastFen = startFen ? FenStringStart : CurrentFEN();
    var doneAccessingDOM = false;
    try {
      if (engineWinCheck()) {
        if (typeof(engineDisabled) != "undefined") {
          engineWin.setDisableEngine(engineDisabled);
        }
        engineWin.updateFEN(engineWinLastFen);
        doneAccessingDOM = true;
      }
    } catch(e) {}
    if (!doneAccessingDOM) {
      var parameters = "fs=" + encodeURIComponent(engineWinLastFen) + "&es=" + pgn4web_engineWinSignature;
      if (engineDisabled) { parameters += "&de=t"; }
      if (pgn4web_engineWindowUrlParameters) { parameters += "&" + pgn4web_engineWindowUrlParameters; }
      var options = "resizable=no,scrollbars=no,toolbar=no,location=no,menubar=no,status=no";
      if (pgn4web_engineWindowHeight) { options = "height=" + pgn4web_engineWindowHeight + "," + options; }
      if (pgn4web_engineWindowWidth) { options = "width=" + pgn4web_engineWindowWidth + "," + options; }
      engineWin = window.open(detectEngineLocation() + engineWinParametersSeparator + parameters, pgn4web_engineWindowTarget, options);

      // bugfix: IE and Opera fail to set window.opener at this point, resulting in no autoUpdate possible and no update from the engine window possible; no fix available
    }
    if ((engineWinCheck(true)) && (engineWin.top === engineWin.self) && (window.focus)) { engineWin.focus(); }
    return engineWin;
  } else if (warnedAboutUnsupportedVariation != gameVariant[currentGame]) {
    warnedAboutUnsupportedVariation = gameVariant[currentGame];
    myAlert("warning: analysis board unavailable for the " + gameVariant[currentGame] + " variant", true);
  }
  return null;
}

function engineWinCheck(skipSignature) {
   return ((!pgn4web_engineWindowDisableAnalysisBoard) && (typeof(engineWin) == "object") && (engineWin !== null) && (!engineWin.closed) && (typeof(engineWin.engineSignature) != "undefined") && ((pgn4web_engineWinSignature === engineWin.engineSignature) || (skipSignature)));
}

function engineWinOnMove() {
   if (engineWinCheck()) {
      if ((engineWin.autoUpdate === true) && (CurrentFEN() != engineWinLastFen) && (engineWin.CurrentFEN() == engineWinLastFen)) {
         showEngineAnalysisBoard();
      }
      engineWin.updateGameAnalysisFlag();
   } else {
      engineWinLastFen = "";
   }
}

