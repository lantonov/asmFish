/*
 *  pgn4web javascript chessboard
 *  copyright (C) 2009-2013 Paolo Casaschi
 *  see README file and http://pgn4web.casaschi.net
 *  for credits, license and more details
 *
 *  Huffman encoding/decoding derived from code at http://rumkin.com/tools/compression/compress_huff.php
 */

// version 1 of PGN encoding:
//   encodedPGN = nnn$xxx0
//   nnn = number representing bytes length of the decoded message
//   $ = dollar char (delimiter for length info)
//   xxx = encoded text (using LetterCodes below)
//   0 = zero char (version marker)

"use strict";

var encodingCharSet_dec;
var encodingCharSet_enc;
var encodingCharSet = encodingCharSet_enc = "$0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_";
var encodingVersion_dec;
var encodingVersion_enc;
var encodingVersion = encodingVersion_enc = 1;
var errorString;

if (((encodingCharSet_dec != undefined) && (encodingCharSet_enc != encodingCharSet_dec)) ||
    ((encodingVersion_dec != undefined) && (encodingVersion_enc != encodingVersion_dec))) {
  errorString = "error: PGN encoding/decoding version/charset mismatch";
  if (typeof myAlert == "function") { myAlert(errorString); }
  else { alert(errorString); }
}

function EncodePGN(ov) {

  function BitsToBytes(i) {
    var o = 0;
    if (i.charAt(0) == '1') { o += 32; }
    if (i.charAt(1) == '1') { o += 16; }
    if (i.charAt(2) == '1') { o +=  8; }
    if (i.charAt(3) == '1') { o +=  4; }
    if (i.charAt(4) == '1') { o +=  2; }
    if (i.charAt(5) == '1') { o +=  1; }
    return encodingCharSet.charAt(o);
  }

  var LetterCodes = new Array(256);
  LetterCodes[0]   = '00111111111111110';
  LetterCodes[1]   = '0101101';
  LetterCodes[2]   = '00111111111111111';
  LetterCodes[3]   = '00111111111111100';
  LetterCodes[4]   = '00111111111111101';
  LetterCodes[5]   = '000011111111111010';
  LetterCodes[6]   = '000011111111111011';
  LetterCodes[7]   = '000011111111111000';
  LetterCodes[8]   = '000011111111111001';
  LetterCodes[9]   = '000011111111111110';
  LetterCodes[10]  = '0101100';
  LetterCodes[11]  = '000011111111111111';
  LetterCodes[12]  = '000011111111111100';
  LetterCodes[13]  = '0011100';
  LetterCodes[14]  = '000011111111111101';
  LetterCodes[15]  = '000011111111110010';
  LetterCodes[16]  = '000011111111110011';
  LetterCodes[17]  = '000011111111110000';
  LetterCodes[18]  = '000011111111110001';
  LetterCodes[19]  = '000011111111110110';
  LetterCodes[20]  = '000011111111110111';
  LetterCodes[21]  = '000011111111110100';
  LetterCodes[22]  = '000011111111110101';
  LetterCodes[23]  = '1111111111110101010';
  LetterCodes[24]  = '1111111111110101011';
  LetterCodes[25]  = '1111111111110101000';
  LetterCodes[26]  = '1111111111110101001';
  LetterCodes[27]  = '1111111111110101110';
  LetterCodes[28]  = '1111111111110101111';
  LetterCodes[29]  = '1111111111110101100';
  LetterCodes[30]  = '1111111111110101101';
  LetterCodes[31]  = '1111111111110100010';
  LetterCodes[32]  = '1000';
  LetterCodes[33]  = '101111111110';
  LetterCodes[34]  = '00010';
  LetterCodes[35]  = '11111111110';
  LetterCodes[36]  = '0011111111110';
  LetterCodes[37]  = '1011111111110';
  LetterCodes[38]  = '00001111111110';
  LetterCodes[39]  = '00111111110';
  LetterCodes[40]  = '0011101';
  LetterCodes[41]  = '111111110';
  LetterCodes[42]  = '11001111111110';
  LetterCodes[43]  = '1111110';
  LetterCodes[44]  = '000011110';
  LetterCodes[45]  = '0011110';
  LetterCodes[46]  = '00000';
  LetterCodes[47]  = '0110110';
  LetterCodes[48]  = '010100';
  LetterCodes[49]  = '00110';
  LetterCodes[50]  = '01000';
  LetterCodes[51]  = '01100';
  LetterCodes[52]  = '11000';
  LetterCodes[53]  = '11010';
  LetterCodes[54]  = '11100';
  LetterCodes[55]  = '001010';
  LetterCodes[56]  = '011100';
  LetterCodes[57]  = '0001110';
  LetterCodes[58]  = '001111111110';
  LetterCodes[59]  = '1111111111100';
  LetterCodes[60]  = '10111111110';
  LetterCodes[61]  = '1100110100';
  LetterCodes[62]  = '000011111110';
  LetterCodes[63]  = '00011110';
  LetterCodes[64]  = '1100111111110';
  LetterCodes[65]  = '110011100';
  LetterCodes[66]  = '000010';
  LetterCodes[67]  = '10111110';
  LetterCodes[68]  = '00111110';
  LetterCodes[69]  = '0010110';
  LetterCodes[70]  = '110011101';
  LetterCodes[71]  = '110011110';
  LetterCodes[72]  = '1100110101';
  LetterCodes[73]  = '0010111110';
  LetterCodes[74]  = '11001111110';
  LetterCodes[75]  = '101110';
  LetterCodes[76]  = '1100111110';
  LetterCodes[77]  = '101111110';
  LetterCodes[78]  = '000110';
  LetterCodes[79]  = '0101110';
  LetterCodes[80]  = '1011110';
  LetterCodes[81]  = '011101';
  LetterCodes[82]  = '11101';
  LetterCodes[83]  = '11001100';
  LetterCodes[84]  = '001111110';
  LetterCodes[85]  = '0000111110';
  LetterCodes[86]  = '1111111110';
  LetterCodes[87]  = '11111110';
  LetterCodes[88]  = '110011111110';
  LetterCodes[89]  = '0000111111110';
  LetterCodes[90]  = '1011111110';
  LetterCodes[91]  = '10010';
  LetterCodes[92]  = '00111111111110';
  LetterCodes[93]  = '10011';
  LetterCodes[94]  = '11001111111111';
  LetterCodes[95]  = '11111111111010';
  LetterCodes[96]  = '10111111111110';
  LetterCodes[97]  = '11110';
  LetterCodes[98]  = '011010';
  LetterCodes[99]  = '10100';
  LetterCodes[100] = '11011';
  LetterCodes[101] = '00100';
  LetterCodes[102] = '010010';
  LetterCodes[103] = '010011';
  LetterCodes[104] = '011110';
  LetterCodes[105] = '0000110';
  LetterCodes[106] = '00001111110';
  LetterCodes[107] = '00001110';
  LetterCodes[108] = '110010';
  LetterCodes[109] = '000111110';
  LetterCodes[110] = '010101';
  LetterCodes[111] = '111110';
  LetterCodes[112] = '0110111';
  LetterCodes[113] = '1100110110';
  LetterCodes[114] = '0111110';
  LetterCodes[115] = '0111111';
  LetterCodes[116] = '10110';
  LetterCodes[117] = '0101111';
  LetterCodes[118] = '00101110';
  LetterCodes[119] = '000111111';
  LetterCodes[120] = '10101';
  LetterCodes[121] = '001011110';
  LetterCodes[122] = '1100110111';
  LetterCodes[123] = '0010111111';
  LetterCodes[124] = '001111111111110';
  LetterCodes[125] = '0011111110';
  LetterCodes[126] = '111111111110110';
  LetterCodes[127] = '1111111111110100011';
  LetterCodes[128] = '1111111111110100000';
  LetterCodes[129] = '1111111111110100001';
  LetterCodes[130] = '1111111111110100110';
  LetterCodes[131] = '1111111111110100111';
  LetterCodes[132] = '1111111111110100100';
  LetterCodes[133] = '1111111111110100101';
  LetterCodes[134] = '1111111111110111010';
  LetterCodes[135] = '1111111111110111011';
  LetterCodes[136] = '1111111111110111000';
  LetterCodes[137] = '1111111111110111001';
  LetterCodes[138] = '1111111111110111110';
  LetterCodes[139] = '1111111111110111111';
  LetterCodes[140] = '1111111111110111100';
  LetterCodes[141] = '1111111111110111101';
  LetterCodes[142] = '1111111111110110010';
  LetterCodes[143] = '1111111111110110011';
  LetterCodes[144] = '1111111111110110000';
  LetterCodes[145] = '1111111111110110001';
  LetterCodes[146] = '1111111111110110110';
  LetterCodes[147] = '1111111111110110111';
  LetterCodes[148] = '1111111111110110100';
  LetterCodes[149] = '1111111111110110101';
  LetterCodes[150] = '1111111111110001010';
  LetterCodes[151] = '1111111111110001011';
  LetterCodes[152] = '1111111111110001000';
  LetterCodes[153] = '1111111111110001001';
  LetterCodes[154] = '1111111111110001110';
  LetterCodes[155] = '1111111111110001111';
  LetterCodes[156] = '1111111111110001100';
  LetterCodes[157] = '1111111111110001101';
  LetterCodes[158] = '1111111111110000010';
  LetterCodes[159] = '1111111111110000011';
  LetterCodes[160] = '1111111111110000000';
  LetterCodes[161] = '1111111111110000001';
  LetterCodes[162] = '1111111111110000110';
  LetterCodes[163] = '1111111111110000111';
  LetterCodes[164] = '1111111111110000100';
  LetterCodes[165] = '1111111111110000101';
  LetterCodes[166] = '1111111111110011010';
  LetterCodes[167] = '1111111111110011011';
  LetterCodes[168] = '1111111111110011000';
  LetterCodes[169] = '1111111111110011001';
  LetterCodes[170] = '1111111111110011110';
  LetterCodes[171] = '1111111111110011111';
  LetterCodes[172] = '1111111111110011100';
  LetterCodes[173] = '1111111111110011101';
  LetterCodes[174] = '1111111111110010010';
  LetterCodes[175] = '1111111111110010011';
  LetterCodes[176] = '1111111111110010000';
  LetterCodes[177] = '1111111111110010001';
  LetterCodes[178] = '1111111111110010110';
  LetterCodes[179] = '1111111111110010111';
  LetterCodes[180] = '1111111111110010100';
  LetterCodes[181] = '1111111111110010101';
  LetterCodes[182] = '1111111111111101010';
  LetterCodes[183] = '1111111111111101011';
  LetterCodes[184] = '1111111111111101000';
  LetterCodes[185] = '1111111111111101001';
  LetterCodes[186] = '1111111111111101110';
  LetterCodes[187] = '1111111111111101111';
  LetterCodes[188] = '1111111111111101100';
  LetterCodes[189] = '1111111111111101101';
  LetterCodes[190] = '1111111111111100010';
  LetterCodes[191] = '1111111111111100011';
  LetterCodes[192] = '1111111111111100000';
  LetterCodes[193] = '1111111111111100001';
  LetterCodes[194] = '1111111111111100110';
  LetterCodes[195] = '1111111111111100111';
  LetterCodes[196] = '1111111111111100100';
  LetterCodes[197] = '1111111111111100101';
  LetterCodes[198] = '1111111111111111010';
  LetterCodes[199] = '1111111111111111011';
  LetterCodes[200] = '1111111111111111000';
  LetterCodes[201] = '1111111111111111001';
  LetterCodes[202] = '1111111111111111110';
  LetterCodes[203] = '1111111111111111111';
  LetterCodes[204] = '1111111111111111100';
  LetterCodes[205] = '1111111111111111101';
  LetterCodes[206] = '1111111111111110010';
  LetterCodes[207] = '1111111111111110011';
  LetterCodes[208] = '1111111111111110000';
  LetterCodes[209] = '1111111111111110001';
  LetterCodes[210] = '1111111111111110110';
  LetterCodes[211] = '1111111111111110111';
  LetterCodes[212] = '1111111111111110100';
  LetterCodes[213] = '1111111111111110101';
  LetterCodes[214] = '1111111111111001010';
  LetterCodes[215] = '1111111111111001011';
  LetterCodes[216] = '1111111111111001000';
  LetterCodes[217] = '1111111111111001001';
  LetterCodes[218] = '1111111111111001110';
  LetterCodes[219] = '1111111111111001111';
  LetterCodes[220] = '1111111111111001100';
  LetterCodes[221] = '1111111111111001101';
  LetterCodes[222] = '1111111111111000010';
  LetterCodes[223] = '1111111111111000011';
  LetterCodes[224] = '1111111111111000000';
  LetterCodes[225] = '1111111111111000001';
  LetterCodes[226] = '1111111111111000110';
  LetterCodes[227] = '1111111111111000111';
  LetterCodes[228] = '1111111111111000100';
  LetterCodes[229] = '1111111111111000101';
  LetterCodes[230] = '1111111111111011010';
  LetterCodes[231] = '1111111111111011011';
  LetterCodes[232] = '1111111111111011000';
  LetterCodes[233] = '1111111111111011001';
  LetterCodes[234] = '1111111111111011110';
  LetterCodes[235] = '1111111111111011111';
  LetterCodes[236] = '1111111111111011100';
  LetterCodes[237] = '1111111111111011101';
  LetterCodes[238] = '1111111111111010010';
  LetterCodes[239] = '1111111111111010011';
  LetterCodes[240] = '1111111111111010000';
  LetterCodes[241] = '1111111111111010001';
  LetterCodes[242] = '1111111111111010110';
  LetterCodes[243] = '1111111111111010111';
  LetterCodes[244] = '1111111111111010100';
  LetterCodes[245] = '1111111111111010101';
  LetterCodes[246] = '10111111111111010';
  LetterCodes[247] = '10111111111111011';
  LetterCodes[248] = '10111111111111000';
  LetterCodes[249] = '10111111111111001';
  LetterCodes[250] = '10111111111111110';
  LetterCodes[251] = '10111111111111111';
  LetterCodes[252] = '10111111111111100';
  LetterCodes[253] = '10111111111111101';
  LetterCodes[254] = '1111111111101110';
  LetterCodes[255] = '1111111111101111';

  // Build resulting data stream
  // The bits string could get very large
  var bits = "";
  var bytes = ov.length + "$";
  for (var i = 0; i < ov.length; i ++) {
    // converts ASCII chars above 255 to a star (code 42) avoiding decoding failure
    if (ov.charCodeAt(i) > 255) { bits += LetterCodes[42]; }
    else { bits += LetterCodes[ov.charCodeAt(i)]; }
    while (bits.length > 5) {
      bytes += BitsToBytes(bits);
      bits = bits.slice(6, bits.length);
    }
  }
  bytes += BitsToBytes(bits);

  bytes += encodingCharSet.charAt(encodingVersion);

  return bytes;
}

