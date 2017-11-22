<?php

/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2016 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

error_reporting(E_ALL | E_STRICT);

// add temporarily blocked sites here
$blockedReferrers = array();


$referrerHost = isset($_SERVER['HTTP_REFERER']) ? parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST) : "";
if ($referrerHost) {
  foreach ($blockedReferrers as $blockedReferrer) {
    if (strstr($referrerHost, $blockedReferrer)) {
      $thisPage = curPageURL();
      $thisPage .= ((strstr($thisPage, "?") ? "&" : "?") . "selfReferred=true");
      print <<<END
<!DOCTYPE HTML>
<html>
<head>
</head>
<body style="padding:10px; font-size:x-small; font-family:sans-serif;">
<p style="font-weight:bold;">pgn4web chess puzzler: warning</p><p>Your site generates a substantial load on the pgn4web chess puzzler server. Please install the pgn4web chess puzzler on your own server following these <a href="http://pgn4web-project.casaschi.net/wiki/ServiceAvailability/" target="_blank">instructions</a>. Sorry for any inconvenience, previous attempts contacting your site's administrators were unsuccessful.</p><p>Click <a href="$thisPage">here</a> to view the pgn4web chess puzzler.</p>
</body>
</html>
END;
      exit;
    }
  }
}

$debugInfo = "\n";

function get_param($param, $shortParam, $default) {
  if (isset($_REQUEST[$param])) { return $_REQUEST[$param]; }
  if (isset($_REQUEST[$shortParam])) { return $_REQUEST[$shortParam]; }
  return $default;
}


$pgnData = get_param("pgnData", "pd", "tactics.pgn");

function get_pgnText($pgnUrl) {
  if (strpos($pgnUrl, ":") || (strpos($pgnUrl, "%3A"))) { return "[Event \"error: invalid pgnData parameter\"]\n"; }
  $fileLimitBytes = 10000000; // 10Mb
  $pgnText = file_get_contents($pgnUrl, NULL, NULL, 0, $fileLimitBytes + 1);
  if (!$pgnText) { return "[Event \"error: failed to get pgnData content\"]\n"; }
  $pgnText = str_replace(array("&", "<", ">"), array("&amp;", "&lt;", "&gt;"), $pgnText);
  return $pgnText;
}

$pgnText = get_pgnText($pgnData);

// for simplicity, remove all comments from the game text
// to avoid spurious [ in comments breaking the regular expression
// splitting the PGN data into games
$pgnText = preg_replace("/{[^}]*}/", "", $pgnText);
$pgnText = preg_replace("/;[^\n$]*/", "", $pgnText);
$pgnText = preg_replace("/(\n|^)%[^\n$]*/", "", $pgnText);

$numGames = preg_match_all("/(\s*\[\s*(\w+)\s*\"([^\"]*)\"\s*\]\s*)+[^\[]*/", $pgnText, $games );


$gameNum = get_param("gameNum", "gn", "");

$expiresDate = "";
if ($gameNum == "random") { $gameNum = rand(1, $numGames); }
else if (!preg_match("/^\d+$/", $gameNum)) {
  $timeNow = time();
  $expiresDate = gmdate("D, d M Y H:i:s", (floor($timeNow / (60 * 60 * 24)) + 1) * (60 * 60 * 24)) . " GMT";
  if (!preg_match("/^[ +-]\d+$/", $gameNum)) { $gameNum = 0; } // space is needed since + is urldecoded as space
  $gameNum = floor(($gameNum + ($timeNow / (60 * 60 * 24))) % $numGames) + 1;
}
else if ($gameNum < 1) { $gameNum = 1; }
else if ($gameNum > $numGames) { $gameNum = $numGames; }
$debugInfo .= "#" . ($gameNum ^ $numGames) . "." . $numGames . "\n";
$gameNum -= 1;

$pgnGame = $games[0][$gameNum];


$lightColorHex = get_param("lightColorHex", "lch", "EFF4EC"); // FFCC99
$lightColorHexCss = "#" . $lightColorHex;
$darkColorHex = get_param("darkColorHex", "dch", "C6CEC3"); // CC9966
$darkColorHexCss = "#" . $darkColorHex;

$controlBackgroundColorHex = get_param("controlBackgroundColorHex", "cbch", "EFF4EC"); // FFCC99
$controlBackgroundColorHexCss = "#" . $controlBackgroundColorHex;
$controlTextColorHex = get_param("controlTextColorHex", "ctch", "888888"); // 663300
$controlTextColorHexCss = "#" . $controlTextColorHex;


$squareSize = get_param("squareSize", "ss", "30");
$squareSizeCss = $squareSize . "px";
if ($squareSize < 20) { $squareSize = 20; }
if ($squareSize < 30) {
  $borderStyleCss = "none";
  $highlightBorderStyleCss = "none";
  $borderSize = 0;
  $borderSizeCss = $borderSize;
} else {
  $borderStyleCss = "solid";
  $highlightBorderStyleCss = "inset";
  $borderSize = ceil($squareSize / 50);
  $borderSizeCss = $borderSize . "px";
}
$bareSquareSize = $squareSize - 2 * $borderSize;
$bareSquareSizeCss = $bareSquareSize . "px";

function defaultPieceSize($ss) {
  $pieceSizeOptions = array(20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 52, 56, 60, 64, 72, 80, 88, 96, 112, 128, 144, 300);
  $targetPieceSize = floor(0.8 * $ss);
  for ($ii=count($pieceSizeOptions)-1; $ii>=0; $ii--) {
    if ($pieceSizeOptions[$ii] <= $targetPieceSize) { return $pieceSizeOptions[$ii]; }
  }
  return $pieceSizeOptions[0];
}
$pieceSize = defaultPieceSize($squareSize - 2 * $borderSize);
$pieceSizeCss = $pieceSize . "px";


$pieceFont = get_param("pieceFont", "pf", "default");
if ($pieceFont == "a") { $pieceFont = "alpha"; }
if ($pieceFont == "m") { $pieceFont = "merida"; }
if ($pieceFont == "u") { $pieceFont = "uscf"; }
if (($pieceFont == "random") || ($pieceFont == "r")) {
  $randomPiece = rand(0, 2);
  switch ($randomPiece) {
    case 1: $pieceFont = "alpha"; break;
    case 2: $pieceFont = "merida"; break;
    default: $pieceFont = "uscf"; break;
  }
}
if (($pieceFont == "hash") || ($pieceFont == "h")) {
//  $hashPiece = strlen($pgnGame) % 3;
  $hashPiece = $gameNum % 3;
  switch ($hashPiece) {
    case 1: $pieceFont = "alpha"; break;
    case 2: $pieceFont = "merida"; break;
    default: $pieceFont = "uscf"; break;
  }
}
if (($pieceFont == "default") || ($pieceFont == "d")) {
  if ($pieceSize < 28) { $pieceFont = "uscf"; }
  else {
    if ($pieceSize > 39) { $pieceFont = "merida"; }
    else { $pieceFont = "alpha"; }
  }
}


$boardSize = $squareSize * 8;
$boardSizeCss = $boardSize . "px";


$buttonHeight = $squareSize;
$buttonHeightCss = $buttonHeight . "px";
$buttonWidth = $squareSize * 4;
$buttonWidthCss = $buttonWidth . "px";
$buttonFontSize = floor($squareSize / 2.5);
if ($buttonFontSize < 10) { $buttonFontSize = 10; }
$buttonFontSizeCss = $buttonFontSize . "px";
$buttonPadding = floor($squareSize / 10);


$sidetomoveBorder = floor($buttonFontSize / 18) + 1;
$sidetomoveBorderCss = $sidetomoveBorder . "px";
$sidetomoveHeight = floor(0.8 * $buttonFontSize - 2 * $sidetomoveBorder);
$sidetomoveHeightCss = $sidetomoveHeight . "px";
$sidetomoveWidth = $sidetomoveHeight;
$sidetomoveWidthCss = $sidetomoveWidth . "px";


$frameBorderColorHex = get_param("frameBorderColorHex", "fbch", "C6CEC3");
if ($frameBorderColorHex == "none") {
  $frameBorderStyleCss = "none";
  $frameBorderWidth = 0;
  $frameBorderWidthCss = "0";
  $frameBorderColorHex = "000000";
} else {
  $frameBorderStyleCss = "outset";
  $frameBorderWidth = ceil($squareSize / 50);
  $frameBorderWidthCss = $frameBorderWidth . "px";
}
$frameBorderColorHexCss = "#" . $frameBorderColorHex;

$frameWidth = $boardSize;
$frameWidthCss = $frameWidth . "px";
$frameHeight = $boardSize + $buttonHeight;
$frameHeightCss = $frameHeight . "px";


// undocumented features

$backgroundColorHex = get_param("backgroundColorHex", "bch", "transparent");
if (preg_match("/^[0123456789ABCDEF]{6}$/i", $backgroundColorHex)) {
  $backgroundColorHexCss = "#" . $backgroundColorHex;
} else {
  $backgroundColorHexCss = $backgroundColorHex;
}

$framePadding = get_param("framePadding", "fp", 0);
if ($framePadding != 0) {
  $framePaddingCss = $framePadding . "px";
} else {
  $framePaddingCss = $framePadding;
}

$rawGame = "";

$fenString = get_param("fenString", "fs", "");
if (($fenString == "true") || ($fenString == "t")) {
  if (preg_match('/\[\s*FEN\s*"([^"]*)"\s*\]/', $pgnGame, $matches)) { $rawGame = $matches[1]; }
}

$pgnOnly = get_param("pgnOnly", "po", "");
if (($pgnOnly == "true") || ($pgnOnly == "t")) {
  $rawGame = $pgnGame;
}

$pgnOnlyMini = get_param("pgnOnlyMini", "pom", "");
if (($pgnOnlyMini == "true") || ($pgnOnlyMini == "t")) {
  if (preg_match('/\[\s*FEN\s*"[^"]*"\s*\]/', $pgnGame, $matches)) { $rawGame = "[SetUp \"1\"]\n" . $matches[0] . "\n\n"; }
  $rawGame = $rawGame . preg_replace('/\[\s*\w+\s*"[^"]*"\s*\]\s*/', "", $pgnGame);
}

// end of undocumented features


$outerFrameWidth = $frameWidth + 2 * $frameBorderWidth + 2 * $framePadding;
$outerFrameHeight = $frameHeight + 2 * $frameBorderWidth + 2 * $framePadding;


function curPageURL() {
  if ((isset($_SERVER["SERVER_NAME"])) && (isset($_SERVER["REQUEST_URI"]))) {
    $pageURL = 'http';
    if ((isset($_SERVER["HTTPS"])) && ($_SERVER["HTTPS"] == "on")) { $pageURL .= "s"; }
    $pageURL .= "://";
    if ((isset($_SERVER["SERVER_PORT"])) && ($_SERVER["SERVER_PORT"] != "80")) {
      $pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
    } else {
      $pageURL .= $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"];
    }
  } else {
    $pageURL = "";
  }
  return $pageURL;
}
$thisPage = curPageURL();


$expiresMeta = "";
if ($expiresDate) {
  header("expires: " . $expiresDate);
  $expiresMeta = "<meta http-equiv=\"expires\" content=\"" . $expiresDate . "\">";
}

if ($rawGame) {
  header("content-type: application/x-chess-pgn; charset=utf-8");
  header("content-disposition: inline; filename=puzzler.pgn");
  print $rawGame;
  exit;
}

header("content-type: text/html; charset=utf-8");

print <<<END
<!DOCTYPE HTML>
<html>

<head>

<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
$expiresMeta

<title>chess puzzler</title>

<!-- debug info
$debugInfo
end of debug info -->

<style type="text/css">

html,
body {
  margin: 0px;
  padding: 0px;
}

body {
  padding: $framePaddingCss;
  background: $backgroundColorHexCss;
}

.container {
  width: $frameWidthCss;
  height: $frameHeightCss;
  border-style: $frameBorderStyleCss;
  border-width: $frameBorderWidthCss;
  border-color: $frameBorderColorHexCss;
}

.boardTable {
  width: $boardSizeCss;
  height: $boardSizeCss;
  border-width: 0px;
}

.pieceImage {
  width: $pieceSizeCss;
  height: $pieceSizeCss;
}

.whiteSquare,
.blackSquare,
.highlightWhiteSquare,
.highlightBlackSquare {
  width: $bareSquareSizeCss;
  height: $bareSquareSizeCss;
  border-style: $borderStyleCss;
  border-width: $borderSizeCss;
}

.whiteSquare,
.highlightWhiteSquare {
  border-color: $lightColorHexCss;
  background: $lightColorHexCss;
}

.blackSquare,
.highlightBlackSquare {
  border-color: $darkColorHexCss;
  background: $darkColorHexCss;
}

.highlightWhiteSquare,
.highlightBlackSquare {
  border-style: $highlightBorderStyleCss;
}

.buttonTable {
  width: $boardSizeCss;
  height: $buttonHeightCss;
  background-color: $controlBackgroundColorHexCss;
}

.buttonCell {
  width: $buttonWidthCss;
  height: $buttonHeightCss;
  white-space: nowrap;
  overflow: hidden;
}

.buttonCellLink {
  font-family: sans-serif;
  font-size: $buttonFontSizeCss;
  font-weight: 900;
  color: $controlTextColorHexCss;
  text-decoration: none;
}

.sidetomoveBox {
  display: inline-block;
  width: $sidetomoveWidthCss;
  height: $sidetomoveHeightCss;
  border-style: solid;
  border-width: $sidetomoveBorderCss;
  border-color: $controlTextColorHexCss;
}

</style>

<link rel="icon" sizes="16x16" href="pawn.ico" />

<script src="pgn4web.js" type="text/javascript"></script>

<script type="text/javascript">
"use strict";

SetImagePath("images/$pieceFont/$pieceSize");
SetShortcutKeysEnabled(false);

function displayPuzzlerHelp() {
  var puzzlerHelp = "pgn4web chess puzzler" + "\\n\\n";
  puzzlerHelp += "- the white or black small square below the chessboard's left side indicates the side to move" + "\\n\\n";
  puzzlerHelp += "- show the puzzler's solution step by step on the chessboard by clicking the > button below the chessboard's right side" + "\\n\\n";
  puzzlerHelp += "- step backwards one move by clicking the < button below the chessboard's left side" + "\\n\\n";
  puzzlerHelp += "click OK for more information, including how to add the chess puzzler to a website or blog";
  if (confirm(puzzlerHelp)) { window.open("http://pgn4web-project.casaschi.net/wiki/Example_Puzzler/", "_blank"); }
}

boardShortcut("F8", "chess puzzler help", function(t,e){ displayPuzzlerHelp(); });
clearShortcutSquares("E", "8");
clearShortcutSquares("BCDEFGH", "7");
clearShortcutSquares("ABCDEFGH", "23456");
clearShortcutSquares("BCFG", "1");

function solutionSoFar() {
  var sol = "";
  for (var thisPly = StartPly; thisPly < CurrentPly; thisPly++) {
    var moveCount = Math.floor(thisPly/2)+1;
    if ((thisPly % 2 === 0) || (thisPly === StartPly)) {
      sol += (Math.floor(thisPly/2)+1) + ".";
      if (thisPly % 2) { sol += ".."; }
      sol += " ";
    }
    sol += Moves[thisPly] + " ";
  }
  return sol;
}

function customFunctionOnMove() {
  var res, outcome;

  if (CurrentPly == StartPly) {
    document.getElementById("leftButtonLink").innerHTML = "<span class='sidetomoveBox' style='background-color:" + (CurrentPly % 2 ? "black" : "white" ) + ";'></span>";
    document.getElementById("leftButton").title = ((CurrentPly % 2) ? "Black" : "White") + " to play: find the best move";
  } else {
    document.getElementById("leftButtonLink").innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&lt;&nbsp;&nbsp;&nbsp;&nbsp;";
    document.getElementById("leftButton").title = "click < to step backwards one move";
  }

  if (CurrentPly == StartPly+PlyNumber) {
    switch (res = gameResult[currentGame]) {
      case "1-0": outcome = "white wins"; break;
      case "0-1": outcome = "black wins"; break;
      case "1/2-1/2": outcome = "draw"; break;
      default: outcome = "end"; res = "*"; break;
    }
    document.getElementById("rightButtonLink").innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;" + res + "&nbsp;&nbsp;&nbsp;&nbsp;";
    document.getElementById("rightButton").title = solutionSoFar() + " ..." + outcome;
  } else {
    document.getElementById("rightButtonLink").innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&gt;&nbsp;&nbsp;&nbsp;&nbsp;";
    if (CurrentPly == StartPly) {
      document.getElementById("rightButton").title = "click > to show the puzzler's solution step by step on the chessboard";
    } else {
      document.getElementById("rightButton").title = solutionSoFar() + " ...click > to continue showing the puzzler's solution step by step on the chessboard";
    }
  }

}

</script>


<!-- DeploymentCheck: google analytics code -->

<!-- end DeploymentCheck -->


</head>

<body>

<!-- paste your PGN below and make sure you dont specify an external source with SetPgnUrl() -->
<form style="display: none;"><textarea style="display: none;" id="pgnText">

$pgnGame

</textarea></form>
<!-- paste your PGN above and make sure you dont specify an external source with SetPgnUrl() -->

<center>
<div class="container">
<div id="GameBoard"></div>
<table class="buttonTable" border="0" cellspacing="0" cellpadding="0">
<tr>
<td id="leftButton" title="" class="buttonCell" onClick="javascript:GoToMove(CurrentPly - 1);" align="center" valign="middle">
<a id="leftButtonLink" class="buttonCellLink" href="javascript:void(0);" onfocus="blur();"></a>
</td>
<td id="rightButton" title="" class="buttonCell" onClick="javascript:GoToMove(CurrentPly + 1);" align="center" valign="middle">
<a id="rightButtonLink" class="buttonCellLink" href="javascript:void(0);" onfocus="blur();"></a>
</td>
</tr>
</table>
</div>
</center>

</body>

</html>
END;
?>
