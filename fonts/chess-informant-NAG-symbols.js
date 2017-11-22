/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2013 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

"use strict";

if ((typeof(blockChessInformantNAGSymbols) != "boolean") || (!blockChessInformantNAGSymbols)) {

  if (typeof(ii) == "undefined") { var ii; }

  var jsre = new RegExp("chess-informant-NAG-symbols\.js$", "");
  var FontPath = detectJavascriptLocation(jsre).replace(jsre, "");

  document.write('<link href="' + FontPath + 'pgn4web-font-ChessInformantReader.css" type="text/css" rel="stylesheet" />');
  document.write('<style type="text/css">.NAGs, .NAGl { font-family: "pgn4web ChessInformantReader"; line-height: 1em; }</style>');

  var Ns = '<span class="NAGs">';
  var Nl = '<span class="NAGl">';
  var Ne = '</span>';

  var basicNAGs = /^([\?!+#\s]|<span class="NAGs">[^<]*<.span>)+(\s|$)/;

  if (typeof(NAGstyle) == "undefined") { var NAGstyle; }
  NAGstyle = 'informantreader';

  NAG[0] = '';
  NAG[1] = '!';  // 'good move';
  NAG[2] = '?';  // 'bad move';
  NAG[3] = '!!'; // 'very good move';
  NAG[4] = '??'; // 'very bad move';
  NAG[5] = '!?'; // 'speculative move';
  NAG[6] = '?!'; // 'questionable move';
  NAG[7] = NAG[8] = Ns + '&#236;' + Ne; // 'forced move';
  NAG[9] = '??'; // 'worst move';
  NAG[10] = NAG[11] = NAG[12] = Ns + '&#61;' + Ne; // 'drawish position';
  NAG[13] = Ns + '&#213;' + Ne; // 'unclear position';
  NAG[14] = Ns + '&#162;' + Ne; // 'White has a slight advantage';
  NAG[15] = Ns + '&#163;' + Ne; // 'Black has a slight advantage';
  NAG[16] = Ns + '&#165;' + Ne; // 'White has a moderate advantage';
  NAG[17] = Ns + '&#164;' + Ne; // 'Black has a moderate advantage';
  NAG[18] = NAG[20] = Ns + '&#43;&#187;' + Ne; // 'White has a decisive advantage';
  NAG[19] = NAG[21] = Ns + '&#187;&#43;' + Ne; // 'Black has a decisive advantage';
  NAG[22] = NAG[23] = Ns + '&#194;' + Ne; // 'zugzwang';
  NAG[24] = NAG[25] = NAG[26] = NAG[27] = NAG[28] = NAG[29] = Ns + '&#193;' + Ne; // 'space advantage';
  NAG[30] = NAG[31] = NAG[32] = NAG[33] = NAG[34] = NAG[35] = Ns + '&#182;' + Ne; // 'time (development) advantage';
  NAG[36] = NAG[37] = NAG[38] = NAG[39] = Ns + '&#238;' + Ne; // 'initiative';
  NAG[40] = NAG[41] = Ns + '&#239;' + Ne; // 'attack';
  NAG[42] = NAG[43] = ''; // 'insufficient compensation for material deficit';
  NAG[44] = NAG[45] = NAG[46] = NAG[47] = Ns + '&#167;' + Ne; // 'sufficient compensation for material deficit';
  NAG[48] = NAG[49] = NAG[50] = NAG[51] = NAG[52] = NAG[53] = Ns + '&#191;' + Ne; // 'center control advantage';
  for (ii = 54; ii <= 129; ii++) { NAG[ii] = ''; }
  NAG[130] = NAG[131] = NAG[132] = NAG[133] = NAG[134] = NAG[135] = Ns + '&#124;' + Ne; // 'counterplay';
  NAG[136] = NAG[137] = NAG[138] = NAG[139] = Ns + '&#176;' + Ne; // 'time control pressure';

  NAG[140] = Nl + '&#197;' + Ne; // 'with the idea';
  NAG[141] = ''; // 'aimed against';
  NAG[142] = Nl + '&#196;' + Ne; // 'better is';
  NAG[143] = ''; // 'worse is';
  NAG[144] = Nl + '&#61;' + Ne; // 'equivalent is';
  NAG[145] = 'RR'; // 'editorial comment';
  NAG[146] = 'N'; // 'novelty';
  NAG[147] = NAG[244] = Nl + '&#94;' + Ne; // 'weak point';
  NAG[148] = NAG[245] = Nl + '&#207;' + Ne; // 'endgame';
  NAG[149] = NAG[239] = Nl + '&nbsp;&nbsp;&#732;&nbsp;' + Ne; // 'file';
  NAG[150] = NAG[240] = Nl + '&#92;' + Ne; // 'diagonal';
  NAG[151] = NAG[152] = NAG[246] = Nl + '&#210;' + Ne; // 'bishop pair';
  NAG[153] = NAG[247] = Nl + '&#211;' + Ne; // 'opposite bishops';
  NAG[154] = NAG[248] = Nl + '&#212;' + Ne; // 'same bishops';
  NAG[155] = NAG[156] = NAG[193] = NAG[249] = Nl + '&#217;' + Ne; // 'connected pawns';
  NAG[157] = NAG[158] = NAG[192] = NAG[250] = Nl + '&#219;' + Ne; // 'isolated pawns';
  NAG[159] = NAG[160] = NAG[191] = NAG[251] = Nl + '&#218;' + Ne; // 'doubled pawns';
  NAG[161] = NAG[162] = NAG[252] = Nl + '&#8249;' + Ne; // 'passed pawn';
  NAG[163] = NAG[164] = NAG[253] = Nl + '&#8250;' + Ne; // 'pawn majority';
  for (ii = 165; ii <= 189; ii++) { NAG[ii] = ''; }
  NAG[190] = Nl + '&#223;' + Ne; // 'etc';
  NAG[194] = ''; // 'hanging pawns';
  NAG[195] = ''; // 'backward pawns';
  for (ii = 196; ii <= 200; ii++) { NAG[ii] = ''; }
  NAG[201] = NAG[220] = NAG[221] = ''; // 'diagram';
  for (ii = 202; ii <= 219; ii++) { NAG[ii] = ''; }
  for (ii = 222; ii <= 237; ii++) { NAG[ii] = ''; }
  NAG[238] = Nl + '&#193;' + Ne; // 'space advantage';
  NAG[241] = Nl + '&#191;' + Ne; // 'center';
  NAG[242] = Nl + '&#125;' + Ne; // 'kingside';
  NAG[243] = Nl + '&#123;' + Ne; // 'queenside';
  NAG[254] = Nl + '&#8216;' + Ne; // 'with';
  NAG[255] = Nl + '&#95;' + Ne; // 'without';

}

