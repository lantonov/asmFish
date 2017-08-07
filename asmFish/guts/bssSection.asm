; todo: see if the order/alignment of these variables affects performance
align 16
 Output 	  rb 4096  ; output buffer has static allocation

align 16
 ioBuffer	IOBuffer


if USE_WEAKNESS
align 16
 weakness	Weakness
end if

if USE_BOOK
align 16
 book		Book
end if

align 16
 options	Options
align 16
 time		Time
align 16
 signals	Signals
align 16
 limits 	Limits
align 16
 easyMoveMng	EasyMoveMng
align 16
 mainHash	MainHash
align 16
 threadPool	ThreadPool


;;;;;;;;;;;; data for move generation  ;;;;;;;;;;;;;;;

align 4096
match =1, CPU_HAS_BMI2 {
 SlidingAttacksBB    rq 107648
}
match =0, CPU_HAS_BMI2 {
 SlidingAttacksBB    rq 89524
}
 BishopAttacksPEXT   rq 64     ; bitboards
 BishopAttacksMOFF   rd 64     ; addresses, only 32 bits needed
 BishopAttacksPDEP   rq 64     ; bitboards
 RookAttacksPEXT     rq 64     ; bitboards
 RookAttacksMOFF     rd 64     ; addresses, only 32 bits needed
 RookAttacksPDEP     rq 64     ; bitboards
match =0, CPU_HAS_BMI2 {
 BishopAttacksIMUL   rq 64
 RookAttacksIMUL     rq 64
}

PawnAttacks:
 WhitePawnAttacks    rq 64     ; bitboards
 BlackPawnAttacks    rq 64     ; bitboards
 KnightAttacks	     rq 64     ; bitboards
 KingAttacks	     rq 64     ; bitboards


;;;;;;;;;;;;;;;;;;; bitboards ;;;;;;;;;;;;;;;;;;;;;
align 4096
 BetweenBB	   rq 64*64
 LineBB 	   rq 64*64
 SquareDistance    rb 64*64
 DistanceRingBB    rq 8*64
 ForwardBB	   rq 2*64
 PawnAttackSpan    rq 2*64
 PassedPawnMask    rq 2*64
 InFrontBB	   rq 2*8
 AdjacentFilesBB   rq 8
 FileBB 	   rq 8
 RankBB 	   rq 8

;;;;;;;;;;;;;;;;;;;; DoMove data ;;;;;;;;;;;;;;;;;;;;;;;;

align 64
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

align 4096
Reductions	        rd 2*2*64*64
FutilityMoveCounts      rd 16*2
RazorMargin             rd 4
_CaptureOrPromotion_or  rb 4
_CaptureOrPromotion_and rb 4
DrawValue	        rd 2    ; it is updated when threads start to think


;;;;;;;;;;;;;;;;;;;; data for evaluation ;;;;;;;;;;;;;;;;;;;;

align 64
Connected rd 2*2*3*8
MobilityBonus_Knight rd 16
MobilityBonus_Bishop rd 16
MobilityBonus_Rook   rd 16
MobilityBonus_Queen  rd 32
Lever                      rd 8
ShelterWeakness            rd 8*8
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

align 64
EndgameEval_Map            rb 2*ENDGAME_EVAL_MAX_INDEX*sizeof.EndgameMapEntry
EndgameScale_Map           rb 2*ENDGAME_SCALE_MAX_INDEX*sizeof.EndgameMapEntry
EndgameEval_FxnTable       rd ENDGAME_EVAL_MAX_INDEX
EndgameScale_FxnTable      rd ENDGAME_SCALE_MAX_INDEX
KPKEndgameTable            rq 48*64
PushToEdges                rb 64
PushToCorners              rb 64
PushClose                  rb 8
PushAway                   rb 8


align 4096

include 'TablebaseBss.asm'
