
; MAX_RESETCNT should NOT be more than the number of times search is called per second/core,
; which is about half of nps/core (the other half comes from qsearch). Higher setting are 
; dangerous but lower settings lead to increased polling of the time
; MIN_RESETCNT should be fairly low, not more than 50, say.
; official sf polls the timer every 4096 calls, which is much too often
MAX_RESETCNT = 100000
MIN_RESETCNT = 40

; if USE_SPAMFILTER, wait at least this ms before writing out info string
SPAMFILTER_DELAY = 100

; if USE_CURRMOVE, don't print current move info before this number of ms
CURRMOVE_MIN_TIME = 3000

if VERSION_OS = 'W'
  SEP_CHAR = ';'
else
  SEP_CHAR = ':'
end if

; some bounds
MAX_MOVES = 224	; maximum number of pseudo legal moves for any position
AVG_MOVES = 96	; safe average number of moves per position, used for memory allocation
MAX_THREADS = 256
MAX_NUMANODES = 32
MAX_LINUXCPUS = 512			; should be a multiple of 64
MAX_HASH_LOG2MB = 16			; max hash size is (2^MAX_HASH_LOG2MB) MiB
THREAD_STACK_SIZE = 1048576
PAWN_HASH_ENTRY_COUNT = 16384 	; should be a power of 2
MATERIAL_HASH_ENTRY_COUNT = 8192	; should be a power of 2

CAPTURES     = 0
QUIETS       = 1
QUIET_CHECKS = 2
EVASIONS     = 3
NON_EVASIONS = 4
LEGAL        = 5

; some bitboards
  DarkSquares = 0xAA55AA55AA55AA55
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
  CornersBB = 0111111011111111111111111111111111111111111111111111111101111110b


; move types
 MOVE_TYPE_NORMAL = 0
 MOVE_TYPE_PROM   = 4
 MOVE_TYPE_EPCAP  = 8
 MOVE_TYPE_CASTLE = 12

; special moves
 MOVE_NONE    = 0
 MOVE_NULL    = (65 + 0x0FFFFF000)



; piece types. these need to be fixed for conditional preprocessing in movegen
 White	 = 0
 Black	 = 1
 Pawn	 = 2
 Knight  = 3
 Bishop  = 4
 Rook	 = 5
 Queen	 = 6
 King	 = 7

; piece values
 PawnValueMg   = 171
 KnightValueMg = 764
 BishopValueMg = 826
 RookValueMg   = 1282
 QueenValueMg  = 2526

 PawnValueEg   = 240
 KnightValueEg = 848
 BishopValueEg = 891
 RookValueEg   = 1373
 QueenValueEg  = 2646

 MidgameLimit = 15258
 EndgameLimit =  3915

; values for evaluation
 Eval_Tempo = 20

; values from stats tables
 HistoryStats_Max  = 268435456
 CmhDeadOffset     =  4*(8*64)*(16*64)
 CounterMovePruneThreshold = 0

; depths for search
 ONE_PLY = 1
 MAX_PLY = 128
 MAX_SYZYGY_PLY = 20 ; how many times can the syzygy probe recurse?

 VALUE_ZERO	 = 0
 VALUE_DRAW	 = 0
 VALUE_KNOWN_WIN = 10000
 VALUE_MATE	 = 32000
 VALUE_INFINITE  = 32001
 VALUE_NONE	 = 32002
 VALUE_MATE_IN_MAX_PLY	= +VALUE_MATE - 2*MAX_PLY
 VALUE_MATED_IN_MAX_PLY = -VALUE_MATE + 2*MAX_PLY

 PHASE_MIDGAME	      = 128

 SCALE_FACTOR_DRAW    = 0
 SCALE_FACTOR_ONEPAWN = 48
 SCALE_FACTOR_NORMAL  = 64
 SCALE_FACTOR_MAX     = 128
 SCALE_FACTOR_NONE    = 255


 DEPTH_QS_CHECKS     =	0
 DEPTH_QS_NO_CHECKS  = -1
 DEPTH_QS_RECAPTURES = -5
 DEPTH_NONE	     = -6

; definitions for move gen macros
 CAPTURES     = 0
 QUIETS       = 1
 QUIET_CHECKS = 2
 EVASIONS     = 3
 NON_EVASIONS = 4
 LEGAL	      = 5

 DELTA_N =  8
 DELTA_E =  1
 DELTA_S = -8
 DELTA_W = -1

 DELTA_NN = 16
 DELTA_NE = 9
 DELTA_SE = -7
 DELTA_SS = -16
 DELTA_SW = -9
 DELTA_NW = 7


; bounds           don't change
 BOUND_NONE  = 0
 BOUND_UPPER = 1
 BOUND_LOWER = 2
 BOUND_EXACT = 3


; endgame eval fxn indices  see Endgames_Int.asm for details
EndgameEval_KPK_index	= 1  ; KP vs K
EndgameEval_KNNK_index	= 2  ; KNN vs K
EndgameEval_KBNK_index	= 3  ; KBN vs K
EndgameEval_KRKP_index	= 4  ; KR vs KP
EndgameEval_KRKB_index	= 5  ; KR vs KB
EndgameEval_KRKN_index	= 6  ; KR vs KN
EndgameEval_KQKP_index	= 7  ; KQ vs KP
EndgameEval_KQKR_index	= 8  ; KQ vs KR

ENDGAME_EVAL_MAP_SIZE = 8  ; this should be number of functions added to the eval map

EndgameEval_KXK_index	= 10 ; Generic "mate lone king" eval

ENDGAME_EVAL_MAX_INDEX = 16

; endgame scale fxn indices  see Endgames_Int.asm for details
EndgameScale_KNPK_index    = 1  ; KNP vs K
EndgameScale_KNPKB_index   = 2  ; KNP vs KB
EndgameScale_KRPKR_index   = 3  ; KRP vs KR
EndgameScale_KRPKB_index   = 4  ; KRP vs KB
EndgameScale_KBPKB_index   = 5  ; KBP vs KB
EndgameScale_KBPKN_index   = 6  ; KBP vs KN
EndgameScale_KBPPKB_index  = 7  ; KBPP vs KB
EndgameScale_KRPPKRP_index = 8  ; KRPP vs KRP

ENDGAME_SCALE_MAP_SIZE = 8  ; this should be number of functions added to the eval map


EndgameScale_KBPsK_index   = 10 ; KB and pawns vs K
EndgameScale_KQKRPs_index  = 11 ; KQ vs KR and pawns
EndgameScale_KPsK_index    = 12 ; K and pawns vs K
EndgameScale_KPKP_index    = 13 ; KP vs KP

ENDGAME_SCALE_MAX_INDEX = 16


RANK_8 = 7
RANK_7 = 6
RANK_6 = 5
RANK_5 = 4
RANK_4 = 3
RANK_3 = 2
RANK_2 = 1
RANK_1 = 0

FILE_H = 7
FILE_G = 6
FILE_F = 5
FILE_E = 4
FILE_D = 3
FILE_C = 2
FILE_B = 1
FILE_A = 0

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
