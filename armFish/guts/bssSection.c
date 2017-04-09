Output:         .space 4096
DisplayOutput:  .space 1024

        .balign 16
time:     .space sizeof.Time
        .balign 16
limits:   .space sizeof.Limits
        .balign 16
signals:   .space sizeof.Signals
        .balign 16
options:    .space sizeof.Options
        .balign 16
ioBuffer:   .space sizeof.IOBuffer
        .balign 16
mainHash:   .space sizeof.MainHash
        .balign 16
threadPool: .space sizeof.ThreadPool


// data for move generation
        .balign 64
SlidingAttacksBB:    .space 8*89524

        .balign 4096
RookAttacksSTUFF:
RookAttacksPEXT:     .space 8*64
RookAttacksMOFF:     .space 8*64
RookAttacksPDEP:     .space 8*64
RookAttacksIMUL:     .space 8*64

PawnAttacks:
WhitePawnAttacks:    .space 8*64
BlackPawnAttacks:    .space 8*64
KnightAttacks:	     .space 8*64
KingAttacks:	     .space 8*64

        .balign 4096
BishopAttacksSTUFF:
BishopAttacksPEXT:   .space 8*64
BishopAttacksMOFF:   .space 8*64
BishopAttacksPDEP:   .space 8*64
BishopAttacksIMUL:   .space 8*64


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


// DoMove data
        .balign 64
Scores_Pieces:	   .space 8*16*64
Zobrist_Pieces:    .space 8*16*64
Zobrist_Castling:  .space 8*16
Zobrist_Ep:	   .space 8*8
Zobrist_side:	   .space 8*1
Zobrist_noPawns:   .space 8*1
PieceValue_MG:	   .space 4*16
PieceValue_EG:	   .space 4*16
IsNotPawnMasks:    .space 1*16
IsNotPieceMasks:   .space 1*16
IsPawnMasks:	   .space 1*16


// data for search
        .balign 4096
Reductions:	         .space 4*2*2*64*64
FutilityMoveCounts:      .space 4*16*2
RazorMargin:             .space 4*4
_CaptureOrPromotion_or:  .space 1*4
_CaptureOrPromotion_and: .space 1*4
DrawValue:	         .space 4*2    // it is updated when threads start to think


// data for evaluation
        .balign 64
Connected:           .space 4*2*2*2*8
Protector_Knight:      .space 4*8
Protector_Bishop:      .space 4*8
Protector_Rook:        .space 4*8
Protector_Queen:       .space 4*8
MobilityBonus_Knight:   .space 4*16
MobilityBonus_Bishop:   .space 4*16
MobilityBonus_Rook:     .space 4*16
MobilityBonus_Queen:    .space 4*32
Lever:                .space 4*8
ShelterWeakness:      .space 4*8*8
StormDanger:
StormDanger_NoFriendlyPawn: .space 4*8*8
StormDanger_Unblocked:	    .space 4*8*8
StormDanger_BlockedByPawn:  .space 4*8*8
StormDanger_BlockedByKing:  .space 4*8*8
KingFlank:                  .space 8*8
ThreatBySafePawn:           .space 4*16
Threat_Minor:               .space 4*16
Threat_Rook:                .space 4*16
PassedRank:                 .space 4*8
PassedFile:                 .space 4*8
DoMaterialEval_Data:
DoMaterialEval_Data.QuadraticOurs:     .space 4*8*6
DoMaterialEval_Data.QuadraticTheirs:   .space 4*8*6


// data for endgames
        .balign 64
EndgameEval_Map:        .space 2*ENDGAME_EVAL_MAX_INDEX*sizeof.EndgameMapEntry
EndgameScale_Map:       .space 2*ENDGAME_SCALE_MAX_INDEX*sizeof.EndgameMapEntry
EndgameEval_FxnTable:   .space 8*ENDGAME_EVAL_MAX_INDEX
EndgameScale_FxnTable:  .space 8*ENDGAME_SCALE_MAX_INDEX
KPKEndgameTable:        .space 8*48*64
PushToEdges:            .space 64
PushToCorners:          .space 64
PushClose:              .space 8
PushAway:               .space 8

