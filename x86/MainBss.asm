; todo: see if the order/alignment of these variables affects performance
              align   16
Output 	  rb 4096  ; output buffer has static allocation
if DEBUG = 1
  DebugOutput rb 4096
end if

              align   16
ioBuffer  IOBuffer

if USE_WEAKNESS
              align   16
  weakness	Weakness
end if

if USE_BOOK
              align   16
  book          Book
end if

              align   16
options	Options
              align   16
time            Time
              align   16
signals         Signals
              align   16
limits          Limits
              align   16
easyMoveMng     EasyMoveMng
              align   16
mainHash        MainHash
              align   16
threadPool      ThreadPool


;;;;;;;;;;;; data for move generation  ;;;;;;;;;;;;;;;
              align   4096
if CPU_HAS_BMI2 = 0
  SlidingAttacksBB    rq 89524
else
  SlidingAttacksBB    rq 107648
end if
  BishopAttacksPEXT   rq 64     ; bitboards
  BishopAttacksMOFF   rd 64     ; addresses, only 32 bits needed
  BishopAttacksPDEP   rq 64     ; bitboards
  RookAttacksPEXT     rq 64     ; bitboards
  RookAttacksMOFF     rd 64     ; addresses, only 32 bits needed
  RookAttacksPDEP     rq 64     ; bitboards
if CPU_HAS_BMI2 = 0
  BishopAttacksIMUL   rq 64
  RookAttacksIMUL     rq 64
end if
PawnAttacks:
WhitePawnAttacks    rq 64     ; bitboards
BlackPawnAttacks    rq 64     ; bitboards
KnightAttacks       rq 64     ; bitboards
KingAttacks         rq 64     ; bitboards


;;;;;;;;;;;;;;;;;;; bitboards ;;;;;;;;;;;;;;;;;;;;;
              align   4096
BetweenBB       rq 64*64
LineBB          rq 64*64
SquareDistance  rb 64*64
DistanceRingBB  rq 8*64
ForwardBB       rq 2*64
PawnAttackSpan  rq 2*64
PassedPawnMask  rq 2*64
InFrontBB       rq 2*8
AdjacentFilesBB rq 8
FileBB          rq 8
RankBB          rq 8

;;;;;;;;;;;;;;;;;;;; DoMove data ;;;;;;;;;;;;;;;;;;;;;;;;
              align   64
Scores_Pieces:	   rq 16*64
Zobrist_Pieces:    rq 16*64
Zobrist_Castling:  rq 16
Zobrist_Ep:	   rq 8
Zobrist_side:	   rq 1
Zobrist_noPawns:   rq 1
PieceValue_MG:	   rd 16
PieceValue_EG:	   rd 16

IsNotPawnMasks:    rb 16
IsNotPieceMasks:   rb 16
IsPawnMasks:	   rb 16


;;;;;;;;;;;;;;;;;;;; data for search ;;;;;;;;;;;;;;;;;;;;;;;
              align   4096
Reductions	        rd 2*2*64*64
FutilityMoveCounts      rd 16*2
RazorMargin             rd 4
_CaptureOrPromotion_or  rb 4
_CaptureOrPromotion_and rb 4
DrawValue	        rd 2    ; it is updated when threads start to think


;;;;;;;;;;;;;;;;;;;; data for evaluation ;;;;;;;;;;;;;;;;;;;;
              align   64
Connected      rd 2*2*3*8
MobilityBonus_Knight rd 16
MobilityBonus_Bishop rd 16
MobilityBonus_Rook   rd 16
MobilityBonus_Queen  rd 32
Lever                      rd 8
ShelterWeakness:
ShelterWeakness_No         rd 8*8
ShelterWeakness_Yes        rd 8*8
StormDanger:
StormDanger_NoFriendlyPawn rd 8*8
StormDanger_Unblocked	   rd 8*8
StormDanger_BlockedByPawn  rd 8*8
StormDanger_BlockedByKing  rd 8*8
KingFlank                  rq 8
Threat_Minor               rd 16
Threat_Rook                rd 16
PassedRank                 rd 8
PassedFile                 rd 8
DoMaterialEval_Data:
.QuadraticOurs:            rd 8*6
.QuadraticTheirs:          rd 8*6
PawnsSet                   rd 16
QueenMinorsImbalance       rd 16


;;;;;;;;;;;;;; data for endgames ;;;;;;;;;;;;;;
              align   64
EndgameEval_Map            rb 2*ENDGAME_EVAL_MAX_INDEX*sizeof.EndgameMapEntry
EndgameScale_Map           rb 2*ENDGAME_SCALE_MAX_INDEX*sizeof.EndgameMapEntry
EndgameEval_FxnTable       rd ENDGAME_EVAL_MAX_INDEX
EndgameScale_FxnTable      rd ENDGAME_SCALE_MAX_INDEX
KPKEndgameTable            rq 48*64
PushToEdges                rb 64
PushToCorners              rb 64
PushClose                  rb 8
PushAway                   rb 8

if USE_SYZYGY
              align   4096
Tablebase_MaxCardinality   rd 1
Tablebase_Cardinality      rd 1
Tablebase_ProbeDepth       rd 1
Tablebase_Score            rd 1
Tablebase_RootInTB         rb 1    ; boole 0 or -1
Tablebase_UseRule50        rb 1    ; boole 0 or -1
                           rb 2
                           rd 11

_ZL7pfactor:
	rb    128

_ZL7pawnidx:
	rb    512

_ZL8binomial:
	rb    1280

_ZL9DTZ_table:
	rq    1

L_333:	rq    1

L_334:	rq    184

L_335:
	rb    24

L_336:
	rb    16

L_337:	rq    1

_ZL7TB_hash:
	rb    81920

_ZL7TB_pawn:
	rb    98304

_ZL8TB_piece:
	rb    30480

_ZL10TBnum_pawn:
	rd    1

_ZL11TBnum_piece:
	rd    1

; let n = num_paths
; the paths are stored in paths[0],...,path[n-1]
; the counts of found tbs are stored in paths[n],...,paths[2n-1]
_ZL5paths:
	rq    1

_ZL11path_string:
	rq    1

_ZL9num_paths:
	rd    1


_ZL11initialized:
	rb    4

tb_total_cnt:
        rd 1

align 16
_ZL8TB_mutex:
	rq    6
end if
