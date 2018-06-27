<?php

/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2017 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

error_reporting(E_ALL | E_STRICT);


$enableLogging = false;


$appName = 'Live Games';

$appUserGuide = 'http://pgn4web-project.casaschi.net/wiki/App_LiveGames/';

if (isset($_SERVER['REQUEST_URI']) && preg_match('/\?install(#|$)/', $_SERVER['REQUEST_URI'], $matches)) {
  $installTextColor = 'white';
  $installBackgroundColor = 'black';
  $ua = strtolower($_SERVER['HTTP_USER_AGENT']);
  if(strstr($ua, 'android')) {
    $platform = 'Android';
  } else if (strstr($ua, 'ipad') || strstr($ua, 'iphone') || strstr($ua, 'ipod')) {
    $platform = 'iOS';
  } else {
    $platform = 'other';
  }

  $html = <<<END
<!DOCTYPE HTML>
<html>
<head>
<link rel="icon" sizes="16x16" href="live-games-app-icon-16x16.ico">
<title>$appName</title>
<style type="text/css">
a { color: white; }
body { color: $installTextColor; background: $installBackgroundColor; font-family: sans-serif; padding: 2em; }
li { margin-bottom: 1em; }
.icon { float: right; margin-left: 2em; }
</style>
</head>
<body>
<a id="appIconLink" href="" target="_blank"><img id="appIcon" class="icon" src="live-games-app-icon-60x60.png" title="$appName app icon" /></a>
<h1>$appName</h1>
App installation:

END;

  if ($platform == 'Android') {
    $html .= "<ol>";
    if (!strstr($ua, 'chrome')) {
      $html .= "<li>google chrome is the reccomended browser for the installation on android devices</li>";
    }
    $html .= <<<END
<li>open the <a id="appLink" href="" target="_blank">app URL</a> on a new tab of the google chrome browser</li>
<li>tap on the action overflow button and select the "add to home screen" action</li>
<li>the app icon should appear on the home screen</li>
</ol>
END;
  } else if ($platform == 'iOS') {
    $html .= "<ol>";
    if (!strstr($ua, 'safari') || strstr($ua, 'crios')) {
      $html .= "<li>safari is the reccomended browser for the installation on iOS devices</li>";
    }
    $html .= <<<END
<li>open the <a id="appLink" href="" target="_blank">app URL</a> on a new page of the safari browser</li>
<li>tap on the action menu button</li>
<li>select the "add to home screen" action</li>
<li>the app icon should appear on the home screen</li>
</ol>
END;
  } else {
    $html .= <<<END
<ol id="openappOl" style="display: none;">
<li>start the <a href="javascript:void(0);" onclick="installOpenWebApp();">app installation script</a></li>
<li>the app icon should appear on the start menu, on the desktop or on the home screen</li>
</ol>
<ol id="otherOl" style="display: none;">
<li>open the <a id="appLink" href="" target="_blank">app URL</a> on a new page of the browser</li>
<li>bookmark the URL</li>
<li>open the newly created bookmark and start the app from the browser</a>
<li>optionally, if available from the browser, use a command like "add app, site or shortcut to apps, desktop, home, menu, shelf, start or taskbar" in order to add the app icon to your system</li>
</ol>
<script type="text/javascript">
"use strict";
document.getElementById((navigator && navigator.mozApps && navigator.mozApps.install) ? "openappOl" : "otherOl").style.display = "";
function installOpenWebApp() {
  try {
    var installOpenWebAppRequest = navigator.mozApps.install(location.href.replace(/\.php\?install.*/, ".webapp"));
    installOpenWebAppRequest.onerror = function() {
      if ((this.error.name == "MULTIPLE_APPS_PER_ORIGIN_FORBIDDEN") || (this.error.name == "REINSTALL_FORBIDDEN")) {
        alert("error: installation failed: app already installed for this domain");
      } else {
        alert("error: app installation failed");
      }
    };
  } catch(e) { alert("error: app installation not supported"); }
}
</script>

END;
  }

  $html .= <<<END
The <a href="$appUserGuide" target="_blank">app user guide</a> provides a detailed usage tutorial and further information: from the app, click/tap square F8 to open the <a href="$appUserGuide" target="_blank">app user guide</a>.
<script type="text/javascript">
"use strict";
window.onload = function() {
  document.getElementById("appIconLink").href = document.getElementById("appLink").href = location.href.replace(/\?install(#|$)/, "$1");
};
document.addEventListener("contextmenu", function(e){ e.preventDefault(); }, false);
</script>
</body>
</html>
END;

  print $html;
  exit;

}


$html = @file_get_contents("dynamic-frame.html");


function errorExit($errorNum, $errorInfo) {
  global $appName;
  $errorTextColor = 'white';
  $errorBackgroundColor = 'black';
  $errorInfo = htmlentities(substr($errorInfo, 0, 40));
  $html = <<<END
<!DOCTYPE HTML>
<html manifest="live-games-app.appcache">
<head>
<title>$appName</title>
</head>
<body style="color: $errorTextColor; background: $errorBackgroundColor; font-family: sans-serif;">
$appName app error: $errorNum: $errorInfo
</body>
</html>
END;
  print $html;
  exit;
}


$actionNum = 0;
if (!$html) { errorExit($actionNum, "source file not found"); }


$text = "('?l=t&' + window.location.hash + '&scf=t&hc=t&pf=a' + '&lch=FFCC99&dch=CC9966&hch=996633&bch=000000&fch=FFEEDD')";
$oldText = "window.location.search";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = '<html manifest="live-games-app.appcache">';
$oldText = "<html>";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = "<title>$appName</title>";
$oldText = "<title>chess games</title>";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = "liveStatusTickerString";
$oldText = "document.title";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
<link rel="manifest" href="live-games-app.json">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black">
<meta name="application-name" content="$appName">
END;
$oldText = "<!-- AppCheck: meta -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = '<link href="fonts/pgn4web-font-LiberationSans.css" type="text/css" rel="stylesheet" />';
$oldText = "<!-- AppCheck: fonts -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = "font-family: 'pgn4web Liberation Sans', sans-serif";
$oldText = "font-family: sans-serif";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
<!-- DeploymentCheck: icons -->
<link rel="icon" sizes="16x16" href="live-games-app-icon-16x16.ico">
<link rel="icon" sizes="128x128" href="live-games-app-icon-128x128.png">
<link rel="apple-touch-icon" href="live-games-app-icon-60x60.png" />
<!-- end DeploymentCheck -->
<script type="text/javascript">
"use strict";
window['defaultOpen'] = window.open;
window.open = function (winUrl, winTarget, winParam) {
  if ((winUrl) && (winUrl.match(/(^|\/)live-games-app-engine\.php/))) {
     window.location.href = winUrl;
     return null;
  } else if (!window.navigator.standalone) {
     return window.defaultOpen(winUrl, winTarget, winParam || "");
  } else if (winUrl) {
     var a = document.createElement("a");
     a.setAttribute("href", winUrl);
     a.setAttribute("target", winTarget ? winTarget : "_blank");
     var e = document.createEvent("HTMLEvents");
     e.initEvent("click", true, true);
     a.dispatchEvent(e);
     return null;
  }
  return null;
};
</script>
END;
$oldText = '<link rel="icon" sizes="16x16" href="pawn.ico" />';
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = 'pgnData_default = "live-games-app.pgn";';
$oldText = 'pgnData_default = "live/live.pgn";';
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = "gameListLineHeight = Math.floor(2.3 * gameListFontSize);";
$oldText = "gameListLineHeight = Math.floor(1.9 * gameListFontSize);";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = 'myInsertRule(sheet, ".gameListBody", "height: " + gameListBodyHeight + "px; width: " + (ww - 2 * framePadding) + "px; overflow-x: " + (window.navigator.standalone ? "auto" : "hidden") + "; overflow-y: auto; scrollbar-base-color: #" + backgroundColorHex + "; -webkit-overflow-scrolling: touch; overflow-scrolling: touch;");';
$oldText = 'myInsertRule(sheet, ".gameListBody", "height: " + gameListBodyHeight + "px; width: " + (ww - 2 * framePadding) + "px; overflow-x: hidden; overflow-y: auto; scrollbar-base-color: #" + backgroundColorHex + "; -webkit-overflow-scrolling: touch; overflow-scrolling: touch;");';
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = 'myInsertRule(sheet, ".gameListBodyItems", window.navigator.standalone ? "min-height: " + (gameListBodyHeight + 2) + "px; min-width: " + (ww - 2 * framePadding + 1) + "px;" : "");';
$oldText = 'myInsertRule(sheet, ".gameListBodyItems", "");';
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
  if (!appInitialized) {
    if (localStorage[lsId + "lastGameKey"]) {
      var lastGameKey = localStorage[lsId + "lastGameKey"];
      var lastGameVar = parseInt(localStorage[lsId + "lastGameVar"], 10) || 0;
      var lastGamePly = parseInt(localStorage[lsId + "lastGamePly"], 10);
      var lastGameAutoplay = localStorage[lsId + "lastGameAutoplay"] === "true";
      for (var gg = 0; gg < numberOfGames; gg++) {
        if (lastGameKey === gameKey(gameEvent[gg], gameSite[gg], gameDate[gg], gameRound[gg], gameWhite[gg], gameBlack[gg])) { break; }
      }
      if (gg < numberOfGames) {
        if (gg !== currentGame) { Init(gg); }
        if ((!isNaN(lastGamePly)) && ((lastGamePly !== CurrentPly) || (lastGameVar !== CurrentVar))) { GoToMove(lastGamePly, lastGameVar); }
        SetAutoPlay(lastGameAutoplay);
      }
    }
    appInitialized = true;
  }
END;
$oldText = "<!-- AppCheck: customFunctionOnPgnTextLoad -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
  if (appInitialized) { localStorage[lsId + "lastGameKey"] = gameKey(gameEvent[currentGame], gameSite[currentGame], gameDate[currentGame], gameRound[currentGame], gameWhite[currentGame], gameBlack[currentGame]); }
END;
$oldText = "<!-- AppCheck: customFunctionOnPgnGameLoad -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
  if (appInitialized) {
    localStorage[lsId + "lastGameVar"] = CurrentVar;
    localStorage[lsId + "lastGamePly"] = CurrentPly;
    localStorage[lsId + "lastGameAutoplay"] = ((isAutoPlayOn) || (CurrentPly === StartPly + PlyNumber));
  }
END;
$oldText = "<!-- AppCheck: customFunctionOnMove -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


$text = <<<END
var appInitialized = false;

var liveStatusTickerString = "";

var lsId = "pgn4web_live_games_app_";

var storageId = "4";
if ((localStorage[lsId + "storageId"] !== storageId) || (localStorage[lsId + "locationHref"] !== window.location.href)) {
  window.localStorage.clear();
  localStorage[lsId + "storageId"] = storageId;
  localStorage[lsId + "locationHref"] = window.location.href;
}

window['defaultSetAutoPlay'] = window['SetAutoPlay'];
window['SetAutoPlay'] = function(vv) {
  defaultSetAutoPlay(vv);
  if (appInitialized) {
    localStorage[lsId + "lastGameAutoplay"] = ((isAutoPlayOn) || (CurrentPly === StartPly + PlyNumber));
  }
};

window['defaultSetAutoplayDelay'] = window['SetAutoplayDelay'];
window['SetAutoplayDelay'] = function(vv) {
  defaultSetAutoplayDelay(vv);
  localStorage[lsId + "Delay"] = Delay;
};
if (typeof(localStorage[lsId + "Delay"]) == "string") {
  var newDelay = parseInt(localStorage[lsId + "Delay"], 10);
  if (!isNaN(newDelay)) { Delay = newDelay; }
}

window['defaultSetHighlightOption'] = window['SetHighlightOption'];
window['SetHighlightOption'] = function(on) {
  defaultSetHighlightOption(on);
  localStorage[lsId + "highlightOption"] = highlightOption;
};
if (typeof(localStorage[lsId + "highlightOption"]) == "string") {
  highlightOption = (localStorage[lsId + "highlightOption"] == "true");
}

window['defaultToggleShowEco'] = window['toggleShowEco'];
window['toggleShowEco'] = function() {
  defaultToggleShowEco();
  localStorage[lsId + "showEco"] = showEco;
};
if (typeof(localStorage[lsId + "showEco"]) == "string") {
  showEco = (localStorage[lsId + "showEco"] == "true");
}

window['defaultToggleColorFlag'] = window['toggleColorFlag'];
window['toggleColorFlag'] = function() {
  defaultToggleColorFlag();
  localStorage[lsId + "showColorFlag"] = showColorFlag;
};
if (typeof(localStorage[lsId + "showColorFlag"]) == "string") {
  showColorFlag = (localStorage[lsId + "showColorFlag"] == "true");
}

window['defaultPauseLiveBroadcast'] = window['pauseLiveBroadcast'];
window['pauseLiveBroadcast'] =  function() {
  defaultPauseLiveBroadcast();
  localStorage[lsId + "LiveBroadcastPaused"] = LiveBroadcastPaused;
  fixGameLiveStatusExtraInfo();
};
window['defaultRestartLiveBroadcast'] = window['restartLiveBroadcast'];
window['restartLiveBroadcast'] =  function() {
  defaultRestartLiveBroadcast();
  localStorage[lsId + "LiveBroadcastPaused"] = LiveBroadcastPaused;
};
if (typeof(localStorage[lsId + "LiveBroadcastPaused"]) == "string") {
  LiveBroadcastPaused = (localStorage[lsId + "LiveBroadcastPaused"] == "true");
}

var lastGameLiveStatusExtraInfoRes = LOAD_PGN_FAIL;
window['defaultCustomFunctionOnCheckLiveBroadcastStatus'] = window['customFunctionOnCheckLiveBroadcastStatus'];
window['customFunctionOnCheckLiveBroadcastStatus'] = function() {
  defaultCustomFunctionOnCheckLiveBroadcastStatus();
  fixGameLiveStatusExtraInfo();
};

function fixGameLiveStatusExtraInfo(res) {
  if (typeof(res) != "undefined") {
    lastGameLiveStatusExtraInfoRes = res;
  }
  var newExtraText = "";
  if (LiveBroadcastDelay && LiveBroadcastDemo) { newExtraText += "<span title='this is a broadcast simulation'>demo</span>"; }
  if (lastGameLiveStatusExtraInfoRes === LOAD_PGN_FAIL) {
    if ((!localStorage[lsId + "lastGamesValidationTime"]) || ((new Date()).getTime() - localStorage[lsId + "lastGamesValidationTime"]) > (LiveBroadcastDelay * 60000)) {
      // 1m = 60000ms = live broadcast delay unit
      newExtraText += "<span style='cursor:pointer; margin-left:" + (1.5 / fontSizeRatio) + "em;'";
      newExtraText += " onclick='refreshPgnSource(); this.blur();'";
      newExtraText += " title='games from app cache'>";
      newExtraText += ((!localStorage[lsId + "lastGamesValidationTime"]) || ((new Date()).getTime() - localStorage[lsId + "lastGamesValidationTime"]) > 21600000) ? "X" : "&times;";
      // 6h = 21600000ms ~ live event duration
      newExtraText += "</span>";
    }
  }
  var theObj = document.getElementById("GameLiveStatusExtraInfoRight");
  if (theObj) {
    theObj.style.visibility = newExtraText ? "visible" : "hidden";
    var otherObj = document.getElementById("GameLiveStatusExtraInfoLeft");
    if (otherObj) { otherObj.innerHTML = theObj.innerHTML = newExtraText; }
  }
}

window['defaultLoadPgnCheckingLiveStatus'] = window['loadPgnCheckingLiveStatus'];
window['loadPgnCheckingLiveStatus'] = function(res) {
  fixGameLiveStatusExtraInfo(res);
  if (res === LOAD_PGN_OK) {
    var text = "";
    for (var ii = 0; ii < numberOfGames; ++ii) { text += fullPgnGame(ii) + "\\n\\n"; }
    localStorage[lsId + "lastGamesPgnText"] = simpleHtmlentitiesDecode(text);
    localStorage[lsId + "lastGamesLastModifiedHeader"] = LiveBroadcastLastModifiedHeader;
    localStorage[lsId + "lastGamesLastReceivedLocal"] = LiveBroadcastLastReceivedLocal;
  }
  if ((res === LOAD_PGN_OK) || (res === LOAD_PGN_UNMODIFIED)) {
    localStorage[lsId + "lastGamesValidationTime"] = (new Date()).getTime();
  }
  defaultLoadPgnCheckingLiveStatus(res);
};

window['defaultLoadPgnFromPgnUrl'] = window['loadPgnFromPgnUrl'];
window['loadPgnFromPgnUrl'] = function(pgnUrl) {
  var rememberAppInitialized = appInitialized;
  if (!appInitialized) {
    var theObj = document.getElementById("GameLiveStatusExtraInfoRight");
    if (theObj) { theObj.style.visibility = "visible"; }
    var initialPgnGames = localStorage[lsId + "lastGamesPgnText"] || '[Event "$appName"]\\n[Result "*"]\\n';
    if (!pgnGameFromPgnText(initialPgnGames)) {
      myAlert("error: invalid games cache");
    } else {
      if (typeof(localStorage[lsId + "lastGamesLastModifiedHeader"]) == "string") {
        LiveBroadcastLastModifiedHeader = localStorage[lsId + "lastGamesLastModifiedHeader"];
        LiveBroadcastLastModified = new Date(LiveBroadcastLastModifiedHeader);
      }
      if (typeof(localStorage[lsId + "lastGamesLastReceivedLocal"]) == "string") {
        LiveBroadcastLastReceivedLocal = localStorage[lsId + "lastGamesLastReceivedLocal"];
      }
      firstStart = true;
      undoStackReset();
      Init();
      LiveBroadcastStarted = true;
      checkLiveBroadcastStatus();
      customFunctionOnPgnTextLoad();
    }
  }
  if (rememberAppInitialized || !LiveBroadcastPaused) { defaultLoadPgnFromPgnUrl(pgnUrl); }
  else { fixGameLiveStatusExtraInfo(); }
};

function detectEngineLocation() {
  return detectJavascriptLocation().replace(/(pgn4web|pgn4web-compacted)\\.js/, "live-games-app-engine.php");
}

engineWinParametersSeparator = "#?";

boardShortcut(debugShortcutSquare, "about", function(t,e){ if (e.shiftKey || confirm("$appName\\napp from the pgn4web project\\n\\nclick OK for debug info")) { displayDebugInfo(); } });

boardShortcut("F8", "app user guide", function(t,e){ window.open("$appUserGuide", "pgn4web_webAppUserGuide"); });

if (LiveBroadcastDelay > 0) {
  boardShortcut("G6", "search next live date", function(t,e){ searchPgnGame('\\\\[\\\\s*Date\\\\s*"[^"]*live[^"]*"\\\\s*\\\\]', e.shiftKey); }, true);
} else {
  boardShortcut("G6", "search next date", function(t,e){ searchPgnGame('\\\\[\\\\s*Date\\\\s*"(?!' + fixRegExp(gameDate[currentGame]) + '"\\\\s*\\\\])', e.shiftKey); }, true);
}

boardShortcut("H5", "app reset", function(t,e){ if (confirm("App reset?\\n\\nWarning: customized settings, games data and engine analysis data will be lost.")) { window.localStorage.clear(); window.location.reload(); } });

function gameKey(event, site, date, round, white, black) {
  var key = "";
  key += "[" + (typeof(event) == "string" ? event : "") + "]";
  key += "[" + (typeof(site) == "string" ? site : "") + "]";
  // key += "[" + (typeof(date) == "string" ? date : "") + "]"; // keep consistent with LiveBroadcastFoundOldGame in pgn4web.js
  key += "[" + (typeof(round) == "string" ? round : "") + "]";
  key += "[" + (typeof(white) == "string" ? white : "") + "]";
  key += "[" + (typeof(black) == "string" ? black : "") + "]";
  return key;
}


function GoToMove_forTouchEnd(thisPly) {
  GoToMove(thisPly);
}

function pgn4web_handleTouchEnd_HeaderContainer(e) {
  e.stopPropagation();
  var jj, deltaX, deltaY;
  for (var ii = 0; ii < e.changedTouches.length; ii++) {
    if ((jj = pgn4webOngoingTouchIndexById(e.changedTouches[ii].identifier)) != -1) {
      if (pgn4webOngoingTouches.length == 1) {
        deltaX = e.changedTouches[ii].clientX - pgn4webOngoingTouches[jj].clientX;
        deltaY = e.changedTouches[ii].clientY - pgn4webOngoingTouches[jj].clientY;
        if (Math.max(Math.abs(deltaX), Math.abs(deltaY)) >= 13) {
          if (Math.abs(deltaY) > 1.5 * Math.abs(deltaX)) {
            if (deltaY > 0) { // vertical down
              showEngineAnalysisBoard();
            } else { // vertical up
              showGameList();
            }
          } else if (Math.abs(deltaX) > 1.5 * Math.abs(deltaY)) { // horizontal left or right
            GoToMove_forTouchEnd(CurrentPly + sign(deltaX));
          }
        }
        pgn4webMaxTouches = 0;
      }
      pgn4webOngoingTouches.splice(jj, 1);
    }
  }
  clearSelectedText();
}

function pgn4web_handleTouchEnd_Header(e) {
  e.stopPropagation();
  var jj, deltaX, deltaY, theObj;
  for (var ii = 0; ii < e.changedTouches.length; ii++) {
    if ((jj = pgn4webOngoingTouchIndexById(e.changedTouches[ii].identifier)) != -1) {
      if (pgn4webOngoingTouches.length == 1) {
        deltaX = e.changedTouches[ii].clientX - pgn4webOngoingTouches[jj].clientX;
        deltaY = e.changedTouches[ii].clientY - pgn4webOngoingTouches[jj].clientY;
        if (Math.max(Math.abs(deltaX), Math.abs(deltaY)) >= 13) {
          if (Math.abs(deltaX) > 1.5 * Math.abs(deltaY)) {
            if (deltaX > 0) { // horizontal right
              toggleGameListHorizontalScroll();
            } else { // horizontal left
              selectGameList(-1);
            }
          }
        }
        pgn4webMaxTouches = 0;
      }
      pgn4webOngoingTouches.splice(jj, 1);
    }
  }
  clearSelectedText();
}

function pgn4web_handleTouchStart_scroll(e) {
  if (window.navigator.standalone) {
    if (this.scrollTop === 0) { this.scrollTop += 1; }
    if (this.scrollTop === this.scrollHeight - this.clientHeight) { this.scrollTop -= 1; }
  }
  this.allowUp = (this.scrollTop > 0);
  this.allowDown = (this.scrollTop < this.scrollHeight - this.clientHeight);
  this.lastY = e.pageY;
}

function pgn4web_handleTouchMove_scroll(e) {
  var up = (e.pageY > this.lastY);
  var down = (e.pageY < this.lastY);
  var flat = (e.pageY === this.lastY);
  this.lastY = e.pageY;
  if ((up && this.allowUp) || (down && this.allowDown) || (flat)) { e.stopPropagation(); }
  else { e.preventDefault(); }
}

if (touchEventEnabled) {
  if (theObj = document.getElementById("HeaderContainer")) {
    simpleAddEvent(theObj, "touchstart", pgn4web_handleTouchStart);
    simpleAddEvent(theObj, "touchmove", pgn4web_handleTouchMove);
    simpleAddEvent(theObj, "touchend", pgn4web_handleTouchEnd_HeaderContainer);
    simpleAddEvent(theObj, "touchleave", pgn4web_handleTouchEnd_HeaderContainer);
    simpleAddEvent(theObj, "touchcancel", pgn4web_handleTouchCancel);
  }

  if (theObj = document.getElementById("GameListHeader")) {
    simpleAddEvent(theObj, "touchstart", pgn4web_handleTouchStart);
    simpleAddEvent(theObj, "touchmove", pgn4web_handleTouchMove);
    simpleAddEvent(theObj, "touchend", pgn4web_handleTouchEnd_Header);
    simpleAddEvent(theObj, "touchleave", pgn4web_handleTouchEnd_Header);
    simpleAddEvent(theObj, "touchcancel", pgn4web_handleTouchCancel);
  }

  simpleAddEvent(document.body, "touchmove", function(e) { e.preventDefault(); });

  if (theObj = document.getElementById("GameListBody")) {
    simpleAddEvent(theObj, "touchstart", pgn4web_handleTouchStart_scroll);
    simpleAddEvent(theObj, "touchmove", pgn4web_handleTouchMove_scroll);
  }

  touchGestures_helpActions =  touchGestures_helpActions.concat([ "&nbsp;" ]);
  touchGestures_helpText = touchGestures_helpText.concat([ "" ]);
  if (!pgn4web_engineWindowDisableAnalysisBoard) {
    touchGestures_helpActions =  touchGestures_helpActions.concat([ "game info top-down swipe" ]);
    touchGestures_helpText = touchGestures_helpText.concat([ "open/update analysis board" ]);
  }
  touchGestures_helpActions =  touchGestures_helpActions.concat([ "game info bottom-up swipe", "game info left-right swipe", "game info right-left swipe", "&nbsp;", "games list swipe", "games list header left-right swipe", "games list header right-left swipe" ]);
  touchGestures_helpText = touchGestures_helpText.concat([ "show games list", "move forward", "move backward", "", "games list scroll", "games list horizontal scroll", "return to game"  ]);
}

simpleAddEvent(window.applicationCache, "updateready", function(e) {
  window.applicationCache.swapCache();
  window.location.reload();
});

simpleAddEvent(document, "contextmenu", function(e){ e.preventDefault(); });
END;
$oldText = "<!-- AppCheck: footer -->";
$actionNum += 1;
if (!strstr($html, $oldText)) { errorExit($actionNum, $oldText); }
$html = str_replace($oldText, $text, $html);


print $html;


if ($enableLogging && isset($_SERVER['REMOTE_ADDR']) && isset($_SERVER['HTTP_USER_AGENT'])) {
  $logentry = strftime("%Y-%m-%d %H:%M:%S") . sprintf("  %15s  ", $_SERVER['REMOTE_ADDR']) . $_SERVER['HTTP_USER_AGENT'] . "\n";
  $logfile = preg_replace("/\.php$/", ".log", __FILE__);
  $logfp = fopen($logfile, 'a');
  fwrite($logfp, $logentry);
  fclose($logfp);
}

?>
