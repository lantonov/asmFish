/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2013 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 */

"use strict";

if ((typeof(blockChessInformantNAGSymbols) != "boolean") || (!blockChessInformantNAGSymbols)) {

  if (typeof(ii) == "undefined") { var ii; }

  var jsre = new RegExp("chess-informant-NAG-symbols-alternative\.js$", "");
  var FontPath = detectJavascriptLocation(jsre).replace(jsre, "");

  document.write('<link href="' + FontPath + 'pgn4web-font-ChessOleFigurin.css" type="text/css" rel="stylesheet" />');
  document.write('<style type="text/css">.NAGs, .NAGl { font-family: "pgn4web ChessOleFigurin"; line-height: 1em; }</style>');

  var Ns = '<span class="NAGs">';
  var Nl = '<span class="NAGl">';
  var Ne = '</span>';

  var basicNAGs = /^([\?!+#\s]|<span class="NAGs">[^<]*<.span>)+(\s|$)/;

  if (typeof(NAGstyle) == "undefined") { var NAGstyle; }
  NAGstyle = 'olefigurin';

  NAG[0] = '';
  NAG[1] = '!';  // 'good move';
  NAG[2] = '?';  // 'bad move';
  NAG[3] = '!!'; // 'very good move';
  NAG[4] = '??'; // 'very bad move';
  NAG[5] = '!?'; // 'speculative move';
  NAG[6] = '?!'; // 'questionable move';
  NAG[7] = NAG[8] = Ns + '&#86;' + Ne; // 'forced move';
  NAG[9] = '??'; // 'worst move';
  NAG[10] = NAG[11] = NAG[12] = Ns + '&#61;' + Ne; // 'drawish position';
  NAG[13] = Ns + '&#53;' + Ne; // 'unclear position';
  NAG[14] = Ns + '&#49;' + Ne; // 'White has a slight advantage';
  NAG[15] = Ns + '&#50;' + Ne; // 'Black has a slight advantage';
  NAG[16] = Ns + '&#48;' + Ne; // 'White has a moderate advantage';
  NAG[17] = Ns + '&#51;' + Ne; // 'Black has a moderate advantage';
  NAG[18] = NAG[20] = Ns + '&#43;&#45;' + Ne; // 'White has a decisive advantage';
  NAG[19] = NAG[21] = Ns + '&#45;&#43;' + Ne; // 'Black has a decisive advantage';
  NAG[22] = NAG[23] = Ns + '&#74;' + Ne; // 'zugzwang';
  NAG[24] = NAG[25] = NAG[26] = NAG[27] = NAG[28] = NAG[29] = Ns + '&#70;' + Ne; // 'space advantage';
  NAG[30] = NAG[31] = NAG[32] = NAG[33] = NAG[34] = NAG[35] = Ns + '&#69;' + Ne; // 'time (development) advantage';
  NAG[36] = NAG[37] = NAG[38] = NAG[39] = Ns + '&#73;' + Ne; // 'initiative';
  NAG[40] = NAG[41] = Ns + '&#72;' + Ne; // 'attack';
  NAG[42] = NAG[43] = Ns + '&#52;' + Ne; // 'insufficient compensation for material deficit';
  NAG[44] = NAG[45] = NAG[46] = NAG[47] = Ns + '&#54;' + Ne; // 'sufficient compensation for material deficit';
  NAG[48] = NAG[49] = NAG[50] = NAG[51] = NAG[52] = NAG[53] = Ns + '&#90;' + Ne; // 'center control advantage';
  for (ii = 54; ii <= 129; ii++) { NAG[ii] = ''; }
  NAG[130] = NAG[131] = NAG[132] = NAG[133] = NAG[134] = NAG[135] = Ns + '&#71;' + Ne; // 'counterplay';
  NAG[136] = NAG[137] = NAG[138] = NAG[139] = Ns + '&#33;' + Ne; // 'time control pressure';

  NAG[140] = Nl + '&#85;' + Ne; // 'with the idea';
  NAG[141] = ''; // 'aimed against';
  NAG[142] = Nl + '&#87;' + Ne; // 'better is';
  NAG[143] = ''; // 'worse is';
  NAG[144] = Nl + '&#61;' + Ne; // 'equivalent is';
  NAG[145] = 'RR'; // 'editorial comment';
  NAG[146] = 'N'; // 'novelty';
  NAG[147] = NAG[244] = Nl + '&#88;' + Ne; // 'weak point';
  NAG[148] = NAG[245] = Nl + '&#89;' + Ne; // 'endgame';
  NAG[149] = NAG[239] = Nl + '&#58;' + Ne; // 'file';
  NAG[150] = NAG[240] = Nl + '&#59;' + Ne; // 'diagonal';
  NAG[151] = NAG[152] = NAG[246] = Nl + '&#55;' + Ne; // 'bishop pair';
  NAG[153] = NAG[247] = Nl + '&#56;' + Ne; // 'opposite bishops';
  NAG[154] = NAG[248] = Nl + '&#57;' + Ne; // 'same bishops';
  NAG[155] = NAG[156] = NAG[193] = NAG[249] = Nl + '&#80;&#80;' + Ne; // 'connected pawns';
  NAG[157] = NAG[158] = NAG[192] = NAG[250] = Nl + '&#80;&#46;&#46;&#80;' + Ne; // 'isolated pawns';
  NAG[159] = NAG[160] = NAG[191] = NAG[251] = Nl + '&#81;' + Ne; // 'doubled pawns';
  NAG[161] = NAG[162] = NAG[252] = Nl + '&#82;' + Ne; // 'passed pawn';
  NAG[163] = NAG[164] = NAG[253] = '>'; // 'pawn majority';
  for (ii = 165; ii <= 189; ii++) { NAG[ii] = ''; }
  NAG[190] = Nl + '&#37;' + Ne; // 'etc';
  NAG[194] = ''; // 'hanging pawns';
  NAG[195] = ''; // 'backward pawns';
  for (ii = 196; ii <= 200; ii++) { NAG[ii] = ''; }
  NAG[201] = NAG[220] = NAG[221] = ''; // 'diagram';
  for (ii = 202; ii <= 219; ii++) { NAG[ii] = ''; }
  for (ii = 222; ii <= 237; ii++) { NAG[ii] = ''; }
  NAG[238] = Nl + '&#70;' + Ne; // 'space advantage';
  NAG[241] = Nl + '&#90;' + Ne; // 'center';
  NAG[242] = Nl + '&#62;' + Ne; // 'kingside';
  NAG[243] = Nl + '&#60;' + Ne; // 'queenside';
  NAG[254] = Nl + '&#34;' + Ne; // 'with';
  NAG[255] = Nl + '&#36;' + Ne; // 'without';

}

