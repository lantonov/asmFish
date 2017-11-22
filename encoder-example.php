<?php

/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2014 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

error_reporting(E_ALL | E_STRICT);

include "pgn-encoder.php";

function get_param($param, $shortParam, $default) {
  if (isset($_REQUEST[$param])) { return $_REQUEST[$param]; }
  if (isset($_REQUEST[$shortParam])) { return $_REQUEST[$shortParam]; }
  return $default;
}

$pgnText = get_param("pgnText", "pt", "");

if ($pgnText) {
  $pgnText = str_replace(array("&", "<", ">"), array("&amp;", "&lt;", "&gt;"), $pgnText);
  $pgnTextBox = $pgnText;

  $pgnText = str_replace("\\\"", "\"", $pgnText);

  $pgnText = preg_replace("/\[/", "\n\n[", $pgnText);
  $pgnText = preg_replace("/\]/", "]\n\n", $pgnText);
  $pgnText = preg_replace("/([012\*])(\s*)(\[)/", "$1\n\n$3", $pgnText);
  $pgnText = preg_replace("/\]\s*\[/", "]\n[", $pgnText);
  $pgnText = preg_replace("/^\s*\[/", "[", $pgnText);
  $pgnText = preg_replace("/\n[\s*\n]+/", "\n\n", $pgnText);
} else {
  $pgnText = <<<END


 [White ""]
 [Black ""]
 [Result ""]
 [Date ""]
 [Event ""]
 [Site ""]
 [Round ""]

 {please enter your PGN games in the textbox and then click the button}

END;

  $pgnTextBox = $pgnText;
}

$pgnLength = strlen($pgnTextBox);

$pgnEncoded = EncodePGN($pgnText);

$pgnEncodedLength = strlen($pgnEncoded);

$compressionRatio = round(100 * $pgnEncodedLength / $pgnLength) . "%";

$frameUrl = "board.html?am=l&d=1000&ss=26&ps=d&pf=d&lcs=YeiP&dcs=Qcij&bbcs=D91v&hm=n&hcs=Udiz&bd=s&cbcs=YeiP&ctcs=\$\$\$\$&hd=j&md=f&tm=13&fhcs=\$\$\$\$&fhs=13&fmcs=\$\$\$\$&fccs=v71\$&hmcs=Qcij&fms=13&fcs=m&cd=i&bcs=____&fp=13&hl=t&fh=b&fw=p&pe=" . $pgnEncoded;

$frameUrlLength = strlen($frameUrl);

$thisScript = $_SERVER['SCRIPT_NAME'];

print <<<END
<!DOCTYPE HTML>
<html>

<head>

<meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">

<title>pgn4web PGN encoder/decoder php example</title>

<link rel="icon" sizes="16x16" href="pawn.ico" />

</head>

<body style="font-family: sans-serif; margin:20px; padding:0px;">

<h1 style="margin-top:0px; padding-top:0px;">pgn4web PGN encoder/decoder php example</h1>

<center>

<iframe src="$frameUrl"
 height="312" width="900" frameborder="0" scrolling="no" marginheight="0" marginwidth="0">
your web browser and/or your host do not support iframes as required to display the chessboard
</iframe>

<form action="$thisScript" method="POST">
<input type="submit" style="width:900px;" value="pgn4web PGN encoder/decoder php example">
<textarea id="pgnText" name="pgnText" style="height:300px; width:900px; margin:13px;">$pgnTextBox</textarea>
</form>

<div style="width:900px; text-align:left; font-size:66%;">PGN:$pgnLength &nbsp; &nbsp; encoded:$pgnEncodedLength &nbsp; &nbsp; ratio:$compressionRatio &nbsp; &nbsp; url:$frameUrlLength</div>

</center>

</body>

</html>

END;

?>
