
SQ_A1 = (0+8*0)
SQ_B1 = (1+8*0)
SQ_C1 = (2+8*0)
SQ_D1 = (3+8*0)
SQ_E1 = (4+8*0)
SQ_F1 = (5+8*0)
SQ_G1 = (6+8*0)
SQ_H1 = (7+8*0)

SQ_A2 = (0+8*1)
SQ_B2 = (1+8*1)
SQ_C2 = (2+8*1)
SQ_D2 = (3+8*1)
SQ_E2 = (4+8*1)
SQ_F2 = (5+8*1)
SQ_G2 = (6+8*1)
SQ_H2 = (7+8*1)

SQ_A3 = (0+8*2)
SQ_B3 = (1+8*2)
SQ_C3 = (2+8*2)
SQ_D3 = (3+8*2)
SQ_E3 = (4+8*2)
SQ_F3 = (5+8*2)
SQ_G3 = (6+8*2)
SQ_H3 = (7+8*2)

SQ_A4 = (0+8*3)
SQ_B4 = (1+8*3)
SQ_C4 = (2+8*3)
SQ_D4 = (3+8*3)
SQ_E4 = (4+8*3)
SQ_F4 = (5+8*3)
SQ_G4 = (6+8*3)
SQ_H4 = (7+8*3)

SQ_A5 = (0+8*4)
SQ_B5 = (1+8*4)
SQ_C5 = (2+8*4)
SQ_D5 = (3+8*4)
SQ_E5 = (4+8*4)
SQ_F5 = (5+8*4)
SQ_G5 = (6+8*4)
SQ_H5 = (7+8*4)

SQ_A6 = (0+8*5)
SQ_B6 = (1+8*5)
SQ_C6 = (2+8*5)
SQ_D6 = (3+8*5)
SQ_E6 = (4+8*5)
SQ_F6 = (5+8*5)
SQ_G6 = (6+8*5)
SQ_H6 = (7+8*5)

SQ_A7 = (0+8*6)
SQ_B7 = (1+8*6)
SQ_C7 = (2+8*6)
SQ_D7 = (3+8*6)
SQ_E7 = (4+8*6)
SQ_F7 = (5+8*6)
SQ_G7 = (6+8*6)
SQ_H7 = (7+8*6)

SQ_A8 = (0+8*7)
SQ_B8 = (1+8*7)
SQ_C8 = (2+8*7)
SQ_D8 = (3+8*7)
SQ_E8 = (4+8*7)
SQ_F8 = (5+8*7)
SQ_G8 = (6+8*7)
SQ_H8 = (7+8*7)

// some bitboards
DarkSquares  = 0xAA55AA55AA55AA55
LightSquares = 0x55AA55AA55AA55AA
FileABB   = 0x0101010101010101
FileBBB   = 0x0202020202020202
FileCBB   = 0x0404040404040404
FileDBB   = 0x0808080808080808
FileEBB   = 0x1010101010101010
FileFBB   = 0x2020202020202020
FileGBB   = 0x4040404040404040
FileHBB   = 0x8080808080808080
Rank8BB   = 0xFF00000000000000
Rank7BB   = 0x00FF000000000000
Rank6BB   = 0x0000FF0000000000
Rank5BB   = 0x000000FF00000000
Rank4BB   = 0x00000000FF000000
Rank3BB   = 0x0000000000FF0000
Rank2BB   = 0x000000000000FF00
Rank1BB   = 0x00000000000000FF
//CornersBB = 0b0111111011111111111111111111111111111111111111111111111101111110


White  = 0
Black  = 1
Pawn   = 2
Knight = 3
Bishop = 4
Rook   = 5
Queen  = 6
King   = 7

// piece values
PawnValueMg   = 188
KnightValueMg = 753
BishopValueMg = 814
RookValueMg   = 1285
QueenValueMg  = 2513

PawnValueEg   = 248
KnightValueEg = 832
BishopValueEg = 890
RookValueEg   = 1371
QueenValueEg  = 2648

MidgameLimit = 15258
EndgameLimit = 3915

// values for evaluation
Eval_Tempo = 20

// values from stats tables
HistoryStats_Max = 268435456


ENDGAME_EVAL_MAX_INDEX = 16
ENDGAME_SCALE_MAX_INDEX = 16



// hacky structs defs

EndgameMapEntry.key     = 0
EndgameMapEntry.entri   = 8 + EndgameMapEntry.key
sizeof.EndgameMapEntry  = 16


IOBuffer.inputBuffer       = 0
IOBuffer.inputBufferSizeB  = 8 + IOBuffer.inputBuffer
IOBuffer.tmp_i             = 8 + IOBuffer.inputBufferSizeB
IOBuffer.tmp_j             = 4 + IOBuffer.tmp_i
IOBuffer.tmpBuffer         = 4 + IOBuffer.tmp_j
sizeof.IOBuffer.tmpBuffer  = 512
sizeof.IOBuffer            = 512+IOBuffer.tmpBuffer

Options.hash                    = 0
Options.threads                 = 8 + Options.hash
Options.largePages              = 8 + Options.threads
Options.changed                 = 1 + Options.largePages
Options.multiPV                 = 3 + Options.changed
Options.chess960	        = 4 + Options.multiPV
Options.minThinkTime	        = 4 + Options.chess960
Options.slowMover	        = 4 + Options.minThinkTime
Options.moveOverhead	        = 4 + Options.slowMover
Options.contempt	        = 4 + Options.moveOverhead
Options.ponder 	                = 4 + Options.contempt
Options.displayInfoMove         = 1 + Options.ponder
sizeof.Options                  = 3 + Options.displayInfoMove
sizeof.Options = sizeof.Options & -16
