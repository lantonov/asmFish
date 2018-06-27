#
#  pgn4web javascript chessboard
#  copyright (C) 2009-2017 Paolo Casaschi
#  see README file and http://pgn4web.casaschi.net
#  for credits, license and more details
#


PGN4WEB: javascript chess games viewer for websites, blogs and live broadcasts.


ABOUT

pgn4web is a software package providing a chess games viewer for websites and
blogs, including live games broadcast support; pgn4web also provides a variety
of online web services, including a chess viewer and a board generator tool for
adding chess games to websites and blogs without any coding; pgn4web integrates
with several popular web platforms and services.

***
*** THIS README FILE IS A SUMMARY OF THE PGN4WEB DOCUMENTATION
*** MORE EXTENSIVE AND UPDATED DOCUMENTATION IS AVAILABLE
*** FROM THE PGN4WEB SUPPORT WIKI REACHABLE FROM http://pgn4web.casaschi.net
*** PLEASE RELY ON THE SUPPORT WIKI RATHER THAN THIS README ONLY
***

Project homepage: http://pgn4web.casaschi.net (including downloads and wiki)
Contact email: pgn4web@casaschi.net

Features:
- display chess games form PGN files on websites and blogs
- supports live broadcasts of chess games with automatic refresh of remote PGNs
- interactive browsing of game variations and comments
- shortcut keys for navigating through the game, for selecting games and much
  more; uses chessboard squares as input buttons; on supported touchscreen
  devices uses touch gestures across the chessboard
- fully customizable display: each item (board, button bar, game selection
  menu, PGN header info, game text, game comment and more) can be displayed
  (or hidden) at pleasure in your html file
- supports different bitmaps for chess pieces (even custom bitmaps) and
  different chessboard sizes
- uses figurine fonts for chess moves and chess informant style symbols for
  comments and annotations
- provides a chess viewer web service, see http://pgn4web-viewer.casaschi.net
- provides a board generator web service for adding chess games to websites and
  blogs without any coding, see http://pgn4web-board-generator.casaschi.net
- integrates with popular web platforms and services such as blogger, drupal,
  joomla, mediawiki, phpBB, wordpress.org and many others.
- supports puzzles presentation modes
- integrates with HTML5 video
- supports Chess960 (a.k.a. Fischer random chess) games

Limitations:
- only one chessboard for html file (use frames if you need to display
  more in the same view)

Bugs:
- no major issue at the moment of writing, please check the project
  issues tracker at http://pgn4web-project.casaschi.net/tickets/

User feedback:
Please email the pgn4web project (pgn4web@casaschi.net) your feedback,
suggestions and bug reports. Please send for review any PGN file that
pgn4web fails parsing correctly.

Enjoy!


DEBUGGING

Errors alert messages are logged by pgn4web, such as failure to load PGN
data, incorrect PGN games or incorrect FEN strings.
When an error is encountered, the top left chessboard square will flash
to signal the exception.
The error alert log can be reviewed clicking on the same top left
chessboard square.


HOW TO USE pgn4we.js

To enable pgn4web, add a SCRIPT instance at the top of your HTML file:

  <script src="pgn4web.js" type="text/javascript"></script>

The PGN input can be specified either as URL within another SCRIPT instance
with at least the call to

  SetPgnUrl("http://yoursite/yourpath/yourfile.pgn")

and optionally any of the other calls listed below.

Or the PGN file can be pasted in the body of the HTML file
within a hidden FORM/TEXTAREA statement with the ID pgnText:

  <!-- paste your PGN below and make sure you dont specify an external source with SetPgnUrl() -->
  <form style="display: none;"><textarea style="display: none;" id="pgnText">

  ... your PGN text ...

  </textarea></form>
  <!-- paste your PGN above and make sure you dont specify an external source with SetPgnUrl() -->

Example:

  <script type="text/javascript">
    "use strict";

    SetPgnUrl("yourpath/yourfile.pgn"); // if set, this has precedence over the inline PGN in the HTML file
    SetImagePath("images");
    SetImageType("png");
    SetHighlightOption(true); // true or false
    SetGameSelectorOptions(null, false, 0, 0, 0, 15, 15, 0, 10); // (head, num, chEvent, chSite, chRound, chWhite, chBlack, chResult, chDate);
    SetCommentsIntoMoveText(false);
    SetCommentsOnSeparateLines(false);
    SetAutoplayDelay(1000); // milliseconds
    SetAutostartAutoplay(false);
    SetAutoplayNextGame(false); // if set, move to the next game at the end of the current game during autoplay
    SetInitialGame(1); // number of game to be shown at load, from 1 (default); values (keep the quotes) of "first", "last", "random" are accepted; other string values assumed as PGN search string
    SetInitialVariation(0); // number for the variation to be shown at load, 0 (default) for main variation
    SetInitialHalfmove(0,false); // halfmove number to be shown at load, 0 (default) for start position; values (keep the quotes) of "start", "end", "random", "comment" (go to first comment or variation), "variation" (go to the first variation) are also accepted. Second parameter if true applies the setting to every selected game instead of startup only
    SetShortcutKeysEnabled(false);

    SetLiveBroadcast(1, false, false, false, false); // set live broadcast; parameters are delay (refresh delay in minutes, 0 means no broadcast, default 0) alertFlag (if true, displays debug error messages, default false) demoFlag (if true starts broadcast demo mode, default false) stepFlag (if true, autoplays updates in steps, default false) endlessFlag (if true, keeps polling for new moves even after all games are finished)

  </script>

Then the script will automagically add content into your HTML file
to any <div> or <span> containers with the following IDs:

  <div id="GameSelector"></div>
  <div id="GameSearch"></div>
  <div id="GameLastMove"></div>
  <div id="GameLastVariations"></div>
  <div id="GameNextMove"></div>
  <div id="GameNextVariations"></div>
  <div id="GameSideToMove"></div>
  <div id="GameLastComment"></div>
  <div id="GameBoard"></div>
  <div id="GameButtons"></div>
  <div id="GameEvent"></div>
  <div id="GameRound"></div>
  <div id="GameSite"></div>
  <div id="GameDate"></div>
  <div id="GameWhite"></div>
  <div id="GameBlack"></div>
  <div id="GameResult"></div>
  <div id="GameText"></div>

  <div id="GameWhiteClock"></div>
  <div id="GameBlackClock"></div>
  <div id="GameLiveStatus"></div>
  <div id="GameLiveLastModified"></div>

The file template.css shows a list of customization style options.
For better chessboard display, it is recommended to explicitly enforce
chessboard and square size using the ".boardTable", ".whiteSquare" and
".blackSquare" CSS classes, such as:
   /* account for chessboard and squares border here, if any */
  .boardTable { width:326px; height:326px; border-width:3px; }
  .whiteSquare, .blackSquare { width:40px; height:40px; }

See template.html file for an example.
See *mini.html* for an example of embedding the PGN content into the HTML file.
See http://pgn4web.casaschi.net/demo/ usage example, including a live broadcast
demo.
See http://pgn4web-blog.casaschi for a usage example within a blog using the
iframe html tag.

The pgn4web scripts and pages are optimized for the HTML5 doctype declaration:
<!DOCTYPE HTML>


CHESS FIGURINE DISPLAY OF MOVES

pgn4web allows displaying chess moves text using the supplied figurine fonts:
'pgn4web ChessSansAlpha', 'pgn4web ChessSansMerida', 'pgn4web ChessSansPiratf',
'pgn4web ChessSansUscf' and 'pgn4web ChessSansUsual'. These fonts are based on
the Liberation Sans font, see credits section for more details, that is provided
as well for overall consistent display of moves, text and headers.

To enable figurine display of chess moves text, make sure you include the
corresponding fonts/pgn4web-font-ChessSansPiratf.css file toghether with the
font/pgn4web-font-LiberationSans.css file into your HTML file:

  <link href="fonts/pgn4web-font-LiberationSans.css" type="text/css" rel="stylesheet" />
  <link href="fonts/pgn4web-font-ChessSansPiratf.css" type="text/css" rel="stylesheet" />

or into your CSS file:

  @import url("fonts/pgn4web-font-LiberationSans.css");
  @import url("fonts/pgn4web-font-ChessSansPiratf.css");

Then set the font-family for the .move, .variation and .commentMove classes to
the chess font of your choice and the rest of the page to the Liberation Sans
font. For example in your CSS file:

  body {
    font-family: 'pgn4web Liberation Sans', sans-serif;
  }
  .move, .variation, .commentMove {
    font-family: 'pgn4web ChessSansPiratf', 'pgn4web Liberation Sans', sans-serif;
  }

When using chess figurine fonts it's strongly recommended to activate the
"smooth fonts display" feature of the client operating system (active by
default on most current systems).

See the template.html and template.css files for an example.


CHESS INFORMANT SYMBOLS

pgn4web allows for showing chess informant style symbols when the corresponding
PGN NAGs (Numeric Annotation Glyphs) are found in the PGN comments. This feature
is disabled by default; in order to enable it in your HTML page, please include
the script below immediately after the main pgn4web script:

  <script src="pgn4web.js" type="text/javascript"></script>
  <script src="fonts/chess-informant-NAG-symbols.js" type="text/javascript"></script>

Please note, differently than when using the figurine fonts, if the user's web
browser does not support web fonts, there's not elegant textual fallback.

See the chess-informant-template.html and the collection-example.thml (chess
informant sample) files for an example.


THE BOARD GENERATOR WEB TOOL

The board widget allows showing games and positions in web pages and blogs,
without any html coding for each game, where the chessboard widget is created
using a given HTML code within the web page or blog.

Just go to the board widget generator site on
  http://pgn4web-board-generator.casaschi.net
the enter your PGN games and configure the options. The tool will
automatically generate some HTML code that you can cut and paste in your web
page or your blog.


THE LIVE BROADCAST OF GAMES

By setting SetLiveBroadcast(delay, alertFlag, demoFlag, stepFlag, endlessFlag)
in the HTML file, pgn4web will periodically refresh the PGN file, showing the
live progress of the games. PGN files produced by the DGT chessboards are
supported.

SetLiveBroadcast(delay, alertFlag, demoFlag, stepFlag, endlessFlag) parameters:
 - delay = refresh interval in minutes, decimals allowed (default 1)
 - alertFlag = if set true, shows alert debug messages (default false)
 - demoFlag = if set true, sets live demo mode (default false)
 - stepFlag = if set true, autoplays updates in steps (default false)
 - endlessFlag = if set true, keeps polling for new moves even atfer all games
   are finished (default false)

If you set stepFlag, please note that the autoplay delay is set by
SetAutoplayDelay(delay), where no more than 2000ms should be used for live
broadcasts.

By default, polling for new moves stops once all games are finished; a game is
deemed finished when the Result header tag is different from "*"); when
endlessFlag is set, the polling for new moves continues endlessly.

The bash shell script live-grab.sh, executed on your server allows for grabbing
the updated game source from anywhere on the Internet to your server.

Clock information as provided by the DGT chessboards in PGN move comments, such
as {[%clk 1:59:59]}, and in the PGN header, such as [WhiteClock "2:00:00"],
[BlackClock "2:00:00"] and [Clock "W/1:59:59"] is displayed in the following
sections:

  <div id="GameWhiteClock"></div>
  <div id="GameBlackClock"></div>

The status of the live broadcast is displayed in the following sections:

  <div id="GameLiveStatus"></div>
  <div id="GameLiveLastRefreshed"></div>
  <div id="GameLiveLastReceived"></div>
  <div id="GameLiveLastModifiedServer"></div>

Clicking on the H6 square will force a games refresh.
Clicking on the A6/B6 squares will pause/restart the automatic games refresh.

The file live-template.html shows a very basic example.

A demo facility is available to test the live broadcast functionality.
If the demo flag is set in SetLiveBroadcast() and a set of full games is
provided, the tool will simulate a slow progress of the game. Set the
proper flag in live-template.html for an example. Please note, even during
a demo, the PGN file is actually refreshed from the server for a more
accurate testing.
Alternatively, for a more realistic simulation, the bash shell script
live-simulation.sh slowly updates the live.pgn file, simulating a real event.

To setup a live broadcast please use any of the live*.html files.
The live*.html files typically accept these parameters:
 - pgnData = PGN file to load (default live.pgn)
 - refreshMinutes = refresh interval in minutes, decimals allowed (default 1)
 - refreshDemo = if set true, sets live demo mode
 - help = if set true, shows additional help information

For instance, make sure that the file myGames.pgn on your server is periodically
refreshed with the live games, then add the following iframe to your page:
<iframe frameborder=0 width=480 height=360
        src=live-compact.html?pgnData=myGames.pgn>
</iframe>

Each live*.html file is customized to a different purpose and provides
specific configuration parameters.

http://pgn4web-live.casaschi.net will occasionally broadcast live major chess
events.


CUSTOMIZATION FUNCTIONS

The following functions, if defined in the HTML file after loading pgn4web.js,
allow for execution of custom commands at given points:
- customFunctionOnPgnTextLoad(): when loading a new PGN file
- customFunctionOnPgnGameLoad(): when loading a new game
- customFunctionOnMove(): when a move is made
- customFunctionOnAlert(message_string): when an error alert is raised
- customFunctionOnCheckLiveBroadcastStatus(): when a live broadcast is checked
Please note the order these functions are executed; for example, when loading
a new PGN file at the end of the first game, first customFunctionOnMove() is
executed, then (when the game has been loaded and the move positioning
completed) customFunctionOnPgnGameLoad() is executed and finally (when the
selected game is fully loaded) customFunctionOnPgnTextLoad() is executed.

The function customPgnHeaderTag(customTagString, htmlElementIdString, gameNumber)
is available for use in customFunctionOnPgnGameLoad() to parse custom PGN header
tags and automatically assign their value to the given HTML elements. The function
returns the custom tag value and the `gameNumber` parameter, if unassigned,
defaults to the current game.
The function customPgnCommentTag(customTagString, htmlElementIdString, plyNumber)
is available for use in customFunctionOnMove() to parse custom PGN comment tags
like { [%pgn4web info] } and automatically assign their value to the given HTML
elements. The function returns the custom tag value and the `plyNumber` parameter,
if unassigned, defaults to the current ply.

See twic944.html or live.html for examples.

The following functions, if defined in the HTML file after loading pgn4web.js,
allow for execution of custom commands when shift + a number key is pressed:
- customShortcutKey_Shift_0()
- customShortcutKey_Shift_1()
...
- customShortcutKey_Shift_9()


SHORTCUT KEYS AND TEXT FORMS

When the HTML page contains the following script command

  SetShortcutKeysEnabled(true);

then all keystrokes for that active page are captured and processed by pgn4web;
this allows for instance to browse the game using the arrow keys. If no other
precautions are taken, this has also the undesirable side effect of capturing
keystrokes intended by the user for typing in text forms when present in the
same page: this makes the text forms unusable.

In order to have fully functional text forms in pgn4web pages, the following
"onFocus" and "onBlur" actions should be added to the textarea forms:

  <textarea onFocus="disableShortcutKeysAndStoreStatus();"
  onBlur="restoreShortcutKeysStatus();"></textarea>

See the inputform.html HTML file for an example.


TECHNICAL NOTES ABOUT WEB BROWSERS

pgn4web is developed and tested with recent versions of a variety of
browsers (Arora, Blackberry browser, Chrome, Epiphany, Firefox, Internet
Explorer, Opera, Safari) on a variety of personal computer platforms
(Linux/Debian, MacOS, Windows) and some smartphone/pda platform (Android,
Blackberry, Apple iOS for iPhone/iPad/iPod).
Not every browser version (please upgrade to a recent release) has been
tested and not every combination of browser/platform has been validated.
If you have any issue with using pgn4web on your platform, please email
pgn4web@casaschi.net

Note about Google Chrome: you might experience problems when testing HTML
pages from your local computer while developing your site. This is a
security limitation of the browser with respect to loading local files.
The limitation can be bypassed by starting Google Chrome with the command
line switch '--allow-file-access-from-files'. Browsing pgn4web websites
with Google Chrome should work properly.

Note about Internet Explorer v7 and above: under some circumstances you might
experience problems when testing HTML pages from your local computer while
developing your site. If this happens to you, read notes at
http://pgn4web-project.casaschi.net/tickets/23/


PGN STANDARD SUPPORT

pgn4web mostly supports the PGN standard for chess games notation (see
http://www.tim-mann.org/Standard).

The general design principle is for pgn4web to try as much as possible
to automatically recover from minor errors in the PGN data and only stop
the game replay after unrecoverable errors.

Notable exceptions and limitations with respect to the PGN standard:

- only pieces initials in the English language are supported, the use of
alternative languages as specified by the PGN standard is not supported
(pgn4web can however display chess moves text using figurine notation, so
the language issue should not be much of a problem, just make sure your
chess software produces PGN data with English pieces initials).

pgn4web also follows a set of proposed extensions to the PGN standard
(see http://www.enpassant.dk/chess/palview/enhancedpgn.htm), more
specifically:

- understands the [%clk 1:59:58] tag in the PGN comment section as the
  clock time after each move
- understands the PGN tags [WhiteClock "2:00:00"] and
  [BlackClock "2:00:00"] as the clock times at the beginning of the game
- understands the PGN tag [Clock "W/1:59:59"] as the clock time of the
  running clock
- allows parsing of generic comment tags using the function
  customPgnCommentTag()

pgn4web also supports null moves in the "--" notation (used by a number of
chess softwares like scid and chessbase), such as in 1. e4 -- 2. d4, and
supports continuations (defined as variations where the last move played
before the variation is not taken back prior to the start of the variation
moves) in the "(*" notation, such as in 1. e4 (* 1... d5 2. exd5) e5

Special characters, such as symbols and accented letters, can appear in PGN
files as comments or as part of the header values; in order for pgn4web to
display those characters correctly, the PGN file should be saved in unicode
UTF-8 format.
If you are forced to use PGN files encoded in a different format, you might
try patching manually the pgn4web.js, search for "// patch: pgn encoding" and
follow instructions.

Please email me for review any PGN file that pgn4web fails parsing correctly.


CHESS960 SUPPORT

pgn4web supports Chess960 (a.k.a. Fischer random chess) and understands both
the X-FEN and the Shredder-FEN extensions to the FEN notation.


JAVASCRIPT CODING

As of pgn4web version 1.72, the pgn4web.js code is checked with the lint
tool (see online version at http://www.javascriptlint.com/online_lint.php).
Plase note that warnings "lint warning: increment (++) and decrement (--)
operators used as part of greater statement" are ignored.
Lint validation should allow for easy compression of the javascript code,
for instance using http://javascriptcompressor.com/
Although a compression beyond 50% can be achieved, only the uncompressed
version is distributed, but if you want to use a compressed version on your
site, the pgn4web.js code should support it.

As of pgn4web version 2.71 strict mode is used, see statement: "use strict";


KNOWN BUGS AND BUG FIXES

Comments starting with "knownbug:" refer to known bugs currently in the pgn4web code.
Commemts starting with "bugfix:" highlight workarounds coping with issues of specific browser versions.


CREDITS AND LICENSE

javascript modifications of Paolo Casaschi (pgn4web@casaschi.net) on code
from the http://ficsgames.org database, in turn likely based on code from the
LT PGN viewer at http://www.lutanho.net/pgn/pgnviewer.html

PNG images from http://ixian.com/chess/jin-piece-sets (creative commons
attribution 4.0 international license) by Eric De Mund.
SVG images from http://commons.wikimedia.org/wiki/Category:SVG_chess_pieces
by Colin M.L. Burnett; licensed under GFDL (www.gnu.org/copyleft/fdl.html),
CC-BY-SA-3.0 (www.creativecommons.org/licenses/by-sa/3.0/) or
GPL (www.gnu.org/licenses/gpl.html), via Wikimedia Commons. SVG images from
http://openclipart.org/search/?query=chess+symbols+set by Igor Krizanovskij
and from http://openclipart.org/search/?query=Chess+tile both dedicated to
the Public Domain (http://creativecommons.org/publicdomain/zero/1.0/) as any
openclipart.org content.

The figurine fonts are derived from the Liberation Sans font (released under
GNU General Public License, see https://fedorahosted.org/liberation-fonts/)
with the addition of chess pieces from freeware fonts: the alpha2 font (Peter
Strickland), the good companion font (David L. Brown), the merida font (Armando
H. Marroquin), the pirate font (Klaus Wolf) and the chess usual font (Armando
H. Marroquin). The original chess fonts and more details are available at
http://www.enpassant.dk/chess/fonteng.htm
The chess informant symbols font is used with permission from the Chess
Informant publishing company (http://www.chessinformant.rs). The chess ole
figurin font is from the ChessOLE project (http://www.chessole.de, David Frank).

Some of the PGN files for the examples are coming from "The Week in Chess" at
http://www.theweekinchess.com (file twic944.pgn), from the scid project at
http://scid.sourceforge.net (file tactics.pgn, with minor modifications), and
from the Chess Informant publishing company at http://www.chessinformant.rs
(file chess-informant-sample.pgn).

The jscolor javascript code is maintained by Honza Odvarko
(http://odvarko.cz/) and released under the GNU Lesser General Public License
(http://www.gnu.org/copyleft/lesser.html)
See http://jscolor.com/

The ECO code (http://en.wikipedia.org/wiki/Encyclopaedia_of_Chess_Openings) for
game opening classification is a trademark of the Chess Informant publishing
company (http://www.chessinformant.rs).


The above items remains subject to their original licenses (if any).


Remaining pgn4web code is copyright (C) 2009-2017 Paolo Casaschi

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

See license-gpl-2.0.txt license file.

You are free to use pgn4web in your website or blog; you are not required to
acknowledge the pgn4web project, but if you want to do so the following line
might be used:
javascript chess viewer courtesy of <a href=http://pgn4web.casaschi.net>pgn4web</a>

You are also encouraged to notify pgn4web@casaschi.net that you are using
pgn4web.

END

