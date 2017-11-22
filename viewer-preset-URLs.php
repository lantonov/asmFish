<?php

/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2012 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

/*
 *  add preset URLs for the viewer.php form using the following template
 *  the javascript code string should be the body of a function returning the preset PGN URL string
 *
 *  addPresetURL($label, $javascriptCode);
 *  addPresetURL('games of the month', 'var nowDate = new Date(); var nowMonth = nowDate.getMonth() + 1; if (nowMonth < 10) { nowMonth = "0" + nowMonth; } return "http://example.com/folder/gotm" + nowDate.getFullYear() + nowMonth + ".pgn";');
 *
 */


// Deployment check: preset URLs

// end DeploymentCheck


?>
