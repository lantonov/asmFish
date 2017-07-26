
; MAX_RESETCNT should NOT be more than the number of times search is called per second/core,
; which is about half of nps/core (the other half comes from qsearch). Higher setting are 
; dangerous but lower settings lead to increased polling of the time
; MIN_RESETCNT should be fairly low, not more than 50, say.
; official sf polls the timer every 4096 calls, which is much too often
MAX_RESETCNT equ 100000
MIN_RESETCNT equ 40

; if USE_SPAMFILTER, wait at least this ms before writing out info string
SPAMFILTER_DELAY equ 100

; if USE_CURRMOVE, don't print current move info before this number of ms
CURRMOVE_MIN_TIME equ 3000


; some bounds
MAX_MOVES equ 224	; maximum number of pseudo legal moves for any position
AVG_MOVES equ 96	; safe average number of moves per position, used for memory allocation
MAX_THREADS equ 256
MAX_NUMANODES equ 32
MAX_LINUXCPUS equ 512			; should be a multiple of 64
MAX_HASH_LOG2MB equ 16			; max hash size is (2^MAX_HASH_LOG2MB) MiB
THREAD_STACK_SIZE equ 1048576
PAWN_HASH_ENTRY_COUNT equ 16384 	; should be a power of 2
MATERIAL_HASH_ENTRY_COUNT equ 8192	; should be a power of 2


match ='W', VERSION_OS {
SEP_CHAR equ ';'
}
match ='L', VERSION_OS {
SEP_CHAR equ ':'
}
match ='X', VERSION_OS {
SEP_CHAR equ ':'
}




; some bitboards
  DarkSquares equ 0xAA55AA55AA55AA55
  LightSquares equ 0x55AA55AA55AA55AA
  FileABB   equ 0x0101010101010101
  FileBBB   equ 0x0202020202020202
  FileCBB   equ 0x0404040404040404
  FileDBB   equ 0x0808080808080808
  FileEBB   equ 0x1010101010101010
  FileFBB   equ 0x2020202020202020
  FileGBB   equ 0x4040404040404040
  FileHBB   equ 0x8080808080808080
  Rank8BB   equ 0xFF00000000000000
  Rank7BB   equ 0x00FF000000000000
  Rank6BB   equ 0x0000FF0000000000
  Rank5BB   equ 0x000000FF00000000
  Rank4BB   equ 0x00000000FF000000
  Rank3BB   equ 0x0000000000FF0000
  Rank2BB   equ 0x000000000000FF00
  Rank1BB   equ 0x00000000000000FF
  CornersBB equ 0111111011111111111111111111111111111111111111111111111101111110b


; move types
 MOVE_TYPE_NORMAL equ 0
 MOVE_TYPE_PROM   equ 4
 MOVE_TYPE_EPCAP  equ 8
 MOVE_TYPE_CASTLE equ 12

; special moves
 MOVE_NONE    equ 0
 MOVE_NULL    equ (65 + 0x0FFFFF000)



; piece types. these need to be fixed for conditional preprocessing in movegen
 White	 fix 0
 Black	 fix 1
 Pawn	 fix 2
 Knight  fix 3
 Bishop  fix 4
 Rook	 fix 5
 Queen	 fix 6
 King	 fix 7

; piece values
 PawnValueMg   equ 188
 KnightValueMg equ 764
 BishopValueMg equ 826
 RookValueMg   equ 1282
 QueenValueMg  equ 2526

 PawnValueEg   equ 248
 KnightValueEg equ 848
 BishopValueEg equ 891
 RookValueEg   equ 1373
 QueenValueEg  equ 2646

 MidgameLimit equ 15258
 EndgameLimit equ  3915

; values for evaluation
 Eval_Tempo equ 20

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
 CAPTURES     equ 0
 QUIETS       equ 1
 QUIET_CHECKS equ 2
 EVASIONS     equ 3
 NON_EVASIONS equ 4
 LEGAL	      equ 5

 DELTA_N equ  8
 DELTA_E equ  1
 DELTA_S equ -8
 DELTA_W equ -1

 DELTA_NN equ 16
 DELTA_NE equ 9
 DELTA_SE equ -7
 DELTA_SS equ -16
 DELTA_SW equ -9
 DELTA_NW equ 7


; bounds           don't change
 BOUND_NONE  equ 0
 BOUND_UPPER equ 1
 BOUND_LOWER equ 2
 BOUND_EXACT equ 3


; endgame eval fxn indices  see Endgames_Int.asm for details
EndgameEval_KPK_index	equ 1  ; KP vs K
EndgameEval_KNNK_index	equ 2  ; KNN vs K
EndgameEval_KBNK_index	equ 3  ; KBN vs K
EndgameEval_KRKP_index	equ 4  ; KR vs KP
EndgameEval_KRKB_index	equ 5  ; KR vs KB
EndgameEval_KRKN_index	equ 6  ; KR vs KN
EndgameEval_KQKP_index	equ 7  ; KQ vs KP
EndgameEval_KQKR_index	equ 8  ; KQ vs KR

ENDGAME_EVAL_MAP_SIZE equ 8  ; this should be number of functions added to the eval map

EndgameEval_KXK_index	equ 10 ; Generic "mate lone king" eval

ENDGAME_EVAL_MAX_INDEX equ 16

; endgame scale fxn indices  see Endgames_Int.asm for details
EndgameScale_KNPK_index    equ 1  ; KNP vs K
EndgameScale_KNPKB_index   equ 2  ; KNP vs KB
EndgameScale_KRPKR_index   equ 3  ; KRP vs KR
EndgameScale_KRPKB_index   equ 4  ; KRP vs KB
EndgameScale_KBPKB_index   equ 5  ; KBP vs KB
EndgameScale_KBPKN_index   equ 6  ; KBP vs KN
EndgameScale_KBPPKB_index  equ 7  ; KBPP vs KB
EndgameScale_KRPPKRP_index equ 8  ; KRPP vs KRP

ENDGAME_SCALE_MAP_SIZE equ 8  ; this should be number of functions added to the eval map


EndgameScale_KBPsK_index   equ 10 ; KB and pawns vs K
EndgameScale_KQKRPs_index  equ 11 ; KQ vs KR and pawns
EndgameScale_KPsK_index    equ 12 ; K and pawns vs K
EndgameScale_KPKP_index    equ 13 ; KP vs KP

ENDGAME_SCALE_MAX_INDEX equ 16


RANK_8 equ 7
RANK_7 equ 6
RANK_6 equ 5
RANK_5 equ 4
RANK_4 equ 3
RANK_3 equ 2
RANK_2 equ 1
RANK_1 equ 0

FILE_H equ 7
FILE_G equ 6
FILE_F equ 5
FILE_E equ 4
FILE_D equ 3
FILE_C equ 2
FILE_B equ 1
FILE_A equ 0

SQ_A1 equ (0+8*0)
SQ_B1 equ (1+8*0)
SQ_C1 equ (2+8*0)
SQ_D1 equ (3+8*0)
SQ_E1 equ (4+8*0)
SQ_F1 equ (5+8*0)
SQ_G1 equ (6+8*0)
SQ_H1 equ (7+8*0)

SQ_A2 equ (0+8*1)
SQ_B2 equ (1+8*1)
SQ_C2 equ (2+8*1)
SQ_D2 equ (3+8*1)
SQ_E2 equ (4+8*1)
SQ_F2 equ (5+8*1)
SQ_G2 equ (6+8*1)
SQ_H2 equ (7+8*1)

SQ_A3 equ (0+8*2)
SQ_B3 equ (1+8*2)
SQ_C3 equ (2+8*2)
SQ_D3 equ (3+8*2)
SQ_E3 equ (4+8*2)
SQ_F3 equ (5+8*2)
SQ_G3 equ (6+8*2)
SQ_H3 equ (7+8*2)

SQ_A4 equ (0+8*3)
SQ_B4 equ (1+8*3)
SQ_C4 equ (2+8*3)
SQ_D4 equ (3+8*3)
SQ_E4 equ (4+8*3)
SQ_F4 equ (5+8*3)
SQ_G4 equ (6+8*3)
SQ_H4 equ (7+8*3)

SQ_A5 equ (0+8*4)
SQ_B5 equ (1+8*4)
SQ_C5 equ (2+8*4)
SQ_D5 equ (3+8*4)
SQ_E5 equ (4+8*4)
SQ_F5 equ (5+8*4)
SQ_G5 equ (6+8*4)
SQ_H5 equ (7+8*4)

SQ_A6 equ (0+8*5)
SQ_B6 equ (1+8*5)
SQ_C6 equ (2+8*5)
SQ_D6 equ (3+8*5)
SQ_E6 equ (4+8*5)
SQ_F6 equ (5+8*5)
SQ_G6 equ (6+8*5)
SQ_H6 equ (7+8*5)

SQ_A7 equ (0+8*6)
SQ_B7 equ (1+8*6)
SQ_C7 equ (2+8*6)
SQ_D7 equ (3+8*6)
SQ_E7 equ (4+8*6)
SQ_F7 equ (5+8*6)
SQ_G7 equ (6+8*6)
SQ_H7 equ (7+8*6)

SQ_A8 equ (0+8*7)
SQ_B8 equ (1+8*7)
SQ_C8 equ (2+8*7)
SQ_D8 equ (3+8*7)
SQ_E8 equ (4+8*7)
SQ_F8 equ (5+8*7)
SQ_G8 equ (6+8*7)
SQ_H8 equ (7+8*7)
