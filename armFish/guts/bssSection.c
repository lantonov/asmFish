
asdf:
        .space 1024
options:
        .space 1024
Output:
        .space 1024

// data for move generation

        .balign 64
SlidingAttacksBB:    .space 8*89524
        .balign 64
BishopAttacksSTUFF:
BishopAttacksPEXT:   .space 8*64
BishopAttacksMOFF:   .space 8*64
BishopAttacksPDEP:   .space 8*64
RookAttacksSTUFF:
RookAttacksPEXT:     .space 8*64
RookAttacksMOFF:     .space 8*64
RookAttacksPDEP:     .space 8*64
BishopAttacksIMUL:   .space 8*64
RookAttacksIMUL:     .space 8*64

PawnAttacks:
WhitePawnAttacks:    .space 8*64
BlackPawnAttacks:    .space 8*64
KnightAttacks:	     .space 8*64
KingAttacks:	     .space 8*64


// bitboards 
        .balign 4096
BetweenBB:	   .space 8*64*64
LineBB:            .space 8*64*64
SquareDistance:    .space 64*64
DistanceRingBB:    .space 8*8*64
ForwardBB:	   .space 8*2*64
PawnAttackSpan:    .space 8*2*64
PassedPawnMask:    .space 8*2*64
InFrontBB:	   .space 8*2*8
AdjacentFilesBB:   .space 8*8
FileBB: 	   .space 8*8
RankBB: 	   .space 8*8

/*
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
Connected rd 2*2*2*8
Protector_Knight rd 8
Protector_Bishop rd 8
Protector_Rook   rd 8
Protector_Queen  rd 8
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
ThreatBySafePawn           rd 16
Threat_Minor               rd 16
Threat_Rook                rd 16
PassedRank                 rd 8
PassedFile                 rd 8

DoMaterialEval_Data:
.QuadraticOurs:            rd 8*6
.QuadraticTheirs:          rd 8*6



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

*/

