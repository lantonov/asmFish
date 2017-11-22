/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2012 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

//
// some parameters that might need reconfiguring for implementing pgn4web on your server
//

"use strict";

//
// the URL for the board widged to be used in the board-generator tool, default = "board.html"
// used by: board-generator.html
//
var pgn4web_board_url = "board.html";
// var pgn4web_board_url = "http://pgn4web-board.casaschi.net/";
//

//
// the URL for the board generator tool, default = "board-generator.html"
// used by: board-generator.html, home.html, widget.html
//
var pgn4web_generator_url = "board-generator.html";
// var pgn4web_generator_url = "http://pgn4web-board-generator.casaschi.net/";
//

//
// login/key pair for the bitly URL shortening service, default blank (then tinyurl is used instead)
// used by: board-generator.html
//
var pgn4web_bitly_login = "";
var pgn4web_bitly_apiKey = "";
// var pgn4web_bitly_login = "";
// var pgn4web_bitly_apiKey = "";
//

//
// pointer URL for the live games broadcast, default = "."
// used by: flash-replacement.html, home.html, live.html, live/index.html
//
var pgn4web_live_pointer_url = ".";
// var pgn4web_live_pointer_url = "http://pgn4web-live.casaschi.net";
//

