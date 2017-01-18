
MinorBehindPawn 	equ (( 16 shl 16) + (  0))
BishopPawns		equ ((	8 shl 16) + ( 12))
RookOnPawn		equ ((	8 shl 16) + ( 24))
TrappedRook		equ (( 92 shl 16) + (  0))
WeakQueen		equ (( 50 shl 16) + ( 10))
OtherCheck		equ (( 10 shl 16) + ( 10))
CloseEnemies		equ ((	7 shl 16) + (  0))
PawnlessFlank		equ (( 20 shl 16) + ( 80))
LooseEnemies		equ ((	0 shl 16) + ( 25))
ThreatByHangingPawn	equ (( 71 shl 16) + ( 61))
ThreatByRank		equ (( 16 shl 16) + (  3))
Hanging 		equ (( 48 shl 16) + ( 27))
ThreatByPawnPush	equ (( 38 shl 16) + ( 22))
HinderPassedPawn	equ ((	7 shl 16) + (  0))


macro EvalInit Us {
; in:  r13 rook + queen
;      r12 bishop+queen
;      r14 all pieces

local Them, Down
local ..NotUsed, ..PinnedLoop, ..NoPinned, ..YesPinned

match =White, Us
\{
	Them	 equ Black
	Down	 equ DELTA_S
\}

match =Black, Us
\{
	Them	 equ White
	Down	 equ DELTA_N
\}


	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi = ei.pi failed in EvalInit'

	      movzx   ecx, word[rbx+State.npMaterial+2*Us]

		mov   rdx, qword[.ei.attackedBy+8*(8*Them+King)]
		 or   qword[.ei.attackedBy+8*(8*Them+0)], rdx
		mov   rax, qword[rdi+PawnEntry.pawnAttacks+8*Us]
		mov   qword[.ei.attackedBy+8*(8*Us+Pawn)], rax
		 or   qword[.ei.attackedBy+8*(8*Us+0)], rax
		and   rax, qword[.ei.attackedBy+8*(8*Us+King)]
		mov   qword[.ei.attackedBy2+8*Us], rax
	; rdx = b

		xor   r8, r8
		xor   r9d, r9d
		cmp   ecx, QueenValueMg
		 jb   ..NotUsed 	; 10.49%
		mov   r8, rdx
	   shift_bb   Down, r8
		 or   r8, rdx
		and   rdx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
	     popcnt   r9, rdx, rcx
		xor   eax, eax
		mov   dword[.ei.kingAttackersWeight+4*Us], eax
		mov   dword[.ei.kingAdjacentZoneAttacksCount+4*Us], eax
..NotUsed:
		mov   qword[.ei.kingRing+8*Them], r8
		mov   dword[.ei.kingAttackersCount+4*Us], r9d

}







macro EvalPieces Us, Pt {
	; in:  rbp address of Pos struct
	;      rbx address of State struct
	;      rsp address of evaluation info
	;      rdi address of PawnEntry struct
	; io:  esi score accumulated
	;
	; in: r13 all pieces
	;     r12 pieces of type Pt ( qword[rbp+Pos.typeBB+8*Pt])
	;     r15 should be zero  for dirty trick

local addsub, subadd
local Them, OutpostRanks

local RookOnFile0, RookOnFile1
local Outpost0, Outpost1, ReachableOutpost0, ReachableOutpost1, KingAttackWeight
local MobilityBonus

local ..NextPiece, ..NoPinned, ..NoKingRing, ..AllDone
local ..OutpostElse, ..OutpostDone, ..NoBehindPawnBonus
local ..NoEnemyPawnBonus, ..NoOpenFileBonus, ..NoTrappedByKing
local ..SkipQueenPin, ..QueenPinLoop

match =White, Us \{
	addsub	equ add
	subadd	equ sub
	Them	 equ Black
	OutpostRanks equ 0x0000FFFFFF000000
\}

match =Black, Us \{
	addsub	equ sub
	subadd	equ add
	Them	 equ White
	OutpostRanks equ 0x000000FFFFFF0000
\}

	RookOnFile0	equ ((20 shl 16) + (7))
	RookOnFile1	equ ((45 shl 16) + (20))


match =Knight, Pt \{
	Outpost0	  equ ((43 shl 16) + (11))
	Outpost1	  equ ((65 shl 16) + (20))
	ReachableOutpost0 equ ((21 shl 16) + (5) )
	ReachableOutpost1 equ ((35 shl 16) + (8) )
	KingAttackWeight equ 78
	MobilityBonus	 equ MobilityBonus_Knight
\}
match =Bishop, Pt \{
	Outpost0	  equ ((20 shl 16) + (3))
	Outpost1	  equ ((29 shl 16) + (8))
	ReachableOutpost0 equ (( 8 shl 16) + (0) )
	ReachableOutpost1 equ ((14 shl 16) + (4))
	KingAttackWeight equ 56
	MobilityBonus	 equ MobilityBonus_Bishop
\}
match =Rook, Pt \{
	KingAttackWeight equ 45
	MobilityBonus	 equ MobilityBonus_Rook
\}
match =Queen, Pt \{
	KingAttackWeight equ 11
	MobilityBonus	 equ MobilityBonus_Queen
\}

	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi=qword[.ei.pi] failed in EvalPieces'


if PEDANTIC
		xor   eax, eax
		mov   qword[.ei.attackedBy+8*(8*Us+Pt)], rax

		mov   r11, qword[rbp+Pos.typeBB+8*Us]
	; r11 = our pieces
		lea   r15, [rbp+Pos.pieceList+16*(8*Us+Pt)]
	      movzx   r14d, byte[rbp+Pos.pieceList+16*(8*Us+Pt)]
		cmp   r14d, 64
		jae   ..AllDone
..NextPiece:
		add   r15, 1

else
	     Assert   e, r15, 0, 'assertion r15=0 failed in EvalPieces'
	; use the fact that r15 is zero
		mov   qword[.ei.attackedBy+8*(8*Us+Pt)], r15

		mov   r15, qword[rbp+Pos.typeBB+8*Us]
		mov   r11, r15
	; r11 = our pieces

		and   r15, r12
		 jz   ..AllDone
..NextPiece:
		bsf   r14, r15
	       blsr   r15, r15, rcx
end if


	; Find attacked squares, including x-ray attacks for bishops and rooks
    if Pt eq Knight
		mov   r9, qword[KnightAttacks+8*r14]
    else if Pt eq Bishop
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		and   rax, r11
		xor   rax, r13
      BishopAttacks   r9, r14, rax, rdx
    else if Pt eq Rook
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		 or   rax, r12
		and   rax, r11
		xor   rax, r13
	RookAttacks   r9, r14, rax, rdx
    else if Pt eq Queen
       QueenAttacks   r9, r14, r13, rax, rdx
    else
	  display 'bad Pt in EvalPieces'
	  display 13,10
	  err
    end if

	; r9 = b
		mov   r8d, dword[.ei.ksq+4*Us]
	; r8d = our ksq

		mov   rax, qword[.ei.pinnedPieces+8*Us]
		 bt   rax, r14
		jnc   ..NoPinned	; 98.92%
		mov   eax, r8d
		shl   eax, 6+3
		and   r9, qword[LineBB+rax+8*r14]
..NoPinned:
		mov   rax, qword[.ei.attackedBy+8*(8*Us+Pt)]
		mov   rdx, qword[.ei.attackedBy+8*(8*Us+0)]
		mov   rcx, r9
		and   rcx, rdx
		 or   rax, r9
		 or   rdx, rax
		 or   qword[.ei.attackedBy2+8*Us], rcx
		mov   qword[.ei.attackedBy+8*(8*Us+Pt)], rax
		mov   qword[.ei.attackedBy+8*(8*Us+0)], rdx

	       test   r9, qword[.ei.kingRing+8*Them]
		 jz   ..NoKingRing	; 74.44%
		add   dword[.ei.kingAttackersCount+4*Us], 1
		add   dword[.ei.kingAttackersWeight+4*Us], KingAttackWeight
		mov   rax, qword[.ei.attackedBy+8*(8*Them+King)]
		and   rax, r9
	     popcnt   rax, rax, rcx
		add   dword[.ei.kingAdjacentZoneAttacksCount+4*Us], eax
..NoKingRing:

    if Pt eq Queen
		mov   rax, qword[.ei.attackedBy+8*(8*Them+Knight)]
		 or   rax, qword[.ei.attackedBy+8*(8*Them+Bishop)]
		 or   rax, qword[.ei.attackedBy+8*(8*Them+Rook)]
	       andn   r9, rax, r9
    end if

		mov   rax, qword[.ei.mobilityArea+8*Us]
		and   rax, r9
	     popcnt   r10, rax, rcx
	     addsub   esi, dword[MobilityBonus+4*r10]

if (Pt in <Knight, Bishop>)


	; Bonus when behind a pawn
    if Us eq White
		cmp   r14d, SQ_A5
		jae   ..NoBehindPawnBonus
    else if Us eq Black
		cmp   r14d, SQ_A5
		 jb   ..NoBehindPawnBonus
    end if
		mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
		lea   ecx, [r14+8*(Them-Us)]
		 bt   rax, rcx
		sbb   eax, eax
		and   eax, MinorBehindPawn
	     addsub   esi, eax
..NoBehindPawnBonus:

	; Bonus for outpost squares
		mov   rax, OutpostRanks
		mov   rcx, qword[rdi+PawnEntry.pawnAttacksSpan+8*Them]
		mov   rdx, r11
	       andn   rcx, rcx, rax
		mov   rax, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		 bt   rcx, r14
		jnc   ..OutpostElse
		 bt   rax, r14
		sbb   eax, eax
		and   eax, (Outpost1-Outpost0)*(Them-Us)
		lea   esi, [rsi+rax+(Outpost0*(Them-Us))]
		jmp   ..OutpostDone
..OutpostElse:
	       andn   rdx, rdx, rcx
		and   rdx, r9
		 jz   ..OutpostDone
		and   rdx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		neg   rdx
		sbb   eax, eax
		and   eax, (ReachableOutpost1-ReachableOutpost0)*(Them-Us)
		lea   esi, [rsi+rax+(ReachableOutpost0*(Them-Us))]
..OutpostDone:



	; Penalty for pawns on the same color square as the bishop
    if Pt eq Bishop
		xor   ecx, ecx
		mov   rax, DarkSquares
		 bt   rax, r14
		adc   rcx, rdi
	      movzx   eax, byte[rcx+PawnEntry.pawnsOnSquares+2*Us]
	       imul   eax, BishopPawns
	     subadd   esi, eax
    end if

else if Pt eq Rook

    if Us eq White
		cmp   r14d, SQ_A5
		 jb   ..NoEnemyPawnBonus
    else if Us eq Black
		cmp   r14d, SQ_A5
		jae   ..NoEnemyPawnBonus
    end if
		mov   rax, qword[rbp+Pos.typeBB+8*Them]
		and   rax, qword[rbp+Pos.typeBB+8*Pawn]
		and   rax, qword[RookAttacksPDEP+8*r14]
	     popcnt   rax, rax, rcx
	       imul   eax, RookOnPawn
	     addsub   esi, eax
..NoEnemyPawnBonus:

		mov   ecx, r14d
		and   ecx, 7
	      movzx   eax, byte[rdi+PawnEntry.semiopenFiles+1*Us]
	      movzx   edx, byte[rdi+PawnEntry.semiopenFiles+1*Them]
		 bt   eax, ecx
		jnc   ..NoOpenFileBonus
		 bt   edx, ecx
		sbb   eax, eax
		and   eax, (RookOnFile1-RookOnFile0)*(Them-Us)
		lea   esi, [rsi+rax+(RookOnFile0*(Them-Us))]
		jmp   ..NoTrappedByKing
..NoOpenFileBonus:

		mov   ecx, r14d
		and   ecx, 7
		mov   eax, r8d
		cmp   r10d, 4
		jae   ..NoTrappedByKing
		mov   edx, eax
		and   eax, 7
		sub   ecx, eax
		sub   eax, 4
		xor   ecx, eax
		 js   ..NoTrappedByKing
		mov   ecx, r8d
		and   ecx, 7
		mov   edx, ecx
		mov   eax, r14d
		and   eax, 7
		sub   ecx, eax
if PEDANTIC
		sub   ecx, 1
end if
		sar   ecx, 31
		sub   edx, ecx
		xor   eax, eax
		bts   eax, edx
		sub   eax, 1
		xor   eax, ecx
	       test   al, byte[rdi+PawnEntry.semiopenFiles+1*Us]
		jnz   ..NoTrappedByKing
	      movzx   eax, byte[rbx+State.castlingRights]
		and   eax, 3 shl (2*Us)
	       setz   al
		add   eax, 1
	       imul   r10d, 22*65536
		sub   r10d, TrappedRook
	       imul   r10d, eax
	     addsub   esi, r10d
..NoTrappedByKing:

else if Pt eq Queen
		xor   edx, edx
		mov   rax, r12
		 or   rax, qword[rbp+Pos.typeBB+8*Rook]
		and   rax, qword[RookAttacksPDEP+8*r14]
		mov   rcx, r12
		 or   rcx, qword[rbp+Pos.typeBB+8*Bishop]
		and   rcx, qword[BishopAttacksPDEP+8*r14]
		 or   rax, rcx
		mov   r9, qword[rbp+Pos.typeBB+8*Rook]
		 or   r9, qword[rbp+Pos.typeBB+8*Bishop]
		and   r9, qword[rbp+Pos.typeBB+8*Them]
		and   rax, r9
		 jz   ..SkipQueenPin
		shl   r14d, 6+3
		bsf   rcx, rax
..QueenPinLoop:
		mov   rcx, qword[BetweenBB+r14+8*rcx]
	       blsr   rax, rax, r9
		and   rcx, r13
	       blsr   r8, rcx, r9
		neg   r8
		sbb   r8, r8
	       andn   rcx, r8, rcx
		 or   rdx, rcx
		bsf   rcx, rax
		jnz   ..QueenPinLoop
		and   rdx, r13
		neg   rdx
		sbb   eax, eax
		and   eax, WeakQueen
	     subadd   esi, eax
..SkipQueenPin:


end if


if PEDANTIC
	      movzx   r14d, byte[r15]
		cmp   r14d, 64
		 jb   ..NextPiece
else
	       test   r15 ,r15
		jnz   ..NextPiece
end if

..AllDone:



ED_String ' evaluate_pieces<'
ED_Int Us
ED_String ', '
ED_Int Pt
ED_String '>: '
ED_Score rsi
ED_NewLine

}



macro EvalKing Us {
	; in  rbp address of Pos struct
	;     rbx address of State struct
	;     rsp address of evaluation info
	; add/sub score to dword[.ei.score]

local Them, Up, Camp

local QueenContactCheck, QueenCheck, RookCheck, BishopCheck, KnightCheck

local ..AllDone, ..KingSafetyDone, ..DoKingSafety, ..KingSafetyDoneRet
local ..RookDone, ..BishopDone, ..KnightDone
local ..NoKingSide, ..NoQueenSide, ..NoPawns

match =White, Us
\{
	Them  equ Black
	Up    equ DELTA_N
	Camp  equ (Rank1BB or Rank2BB or Rank3BB or Rank4BB or Rank5BB)

\}

match =Black, Us
\{
	Them  equ White
	Up    equ DELTA_S
	Camp  equ (Rank4BB or Rank5BB or Rank6BB or Rank7BB or Rank8BB)
\}

	QueenContactCheck equ 997
	QueenCheck  equ 745
	RookCheck   equ 688
	BishopCheck equ 588
	KnightCheck equ 924

	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi=qword[.ei.pi] failed in EvalKing'

		mov   ecx, dword[.ei.ksq+4*Us]
		mov   r15d, ecx
	; r15d = our king square
	      movzx   eax, byte[rbx+State.castlingRights]
	      movzx   edx, byte[rdi+PawnEntry.castlingRights]
		mov   esi, dword[rdi+PawnEntry.kingSafety+4*Us]
		cmp   cl, byte[rdi+PawnEntry.kingSquares+1*Us]
		jne   ..DoKingSafety	; 27.75%
		xor   eax, edx
	       test   eax, 3 shl (2*Us)
		jne   ..DoKingSafety	; 0.68%
..KingSafetyDoneRet:
		mov   dword[rdi+PawnEntry.kingSafety+4*Us], esi

ED_String 'ks:'
ED_Int rsi


		mov   r11d, dword[.ei.kingAttackersCount+4*Them]
	       test   r11d, r11d
		 jz   ..AllDone

		mov   r8, qword[.ei.attackedBy2+8*Us]
	       andn   r8, r8, qword[.ei.attackedBy+8*(8*Us+King)]
		and   r8, qword[.ei.attackedBy+8*(8*Them+0)]
	; r8=undefended

		mov   r9, qword[rbp+Pos.typeBB+8*Them]
		 or   r9, qword[.ei.attackedBy+8*(8*Us+0)]
	       andn   r9, r9, qword[.ei.kingRing+8*Us]
		and   r9, qword[.ei.attackedBy+8*(8*Them+0)]
	; r9=b
		mov   eax, 807
		mov   edi, dword[.ei.kingAttackersCount+4*Them]
	       imul   edi, dword[.ei.kingAttackersWeight+4*Them]
		cmp   edi, eax
	      cmovg   edi, eax
	       imul   eax, dword[.ei.kingAdjacentZoneAttacksCount+4*Them], 101
		add   edi, eax
	     popcnt   rax, r8, rcx
	       imul   eax, 235
		add   edi, eax
	     popcnt   rax, r9, rcx
		mov   rdx, qword[.ei.pinnedPieces+8*Us]
		neg   rdx
		adc   eax, 0
	       imul   eax, 134
		add   edi, eax
		mov   rax, qword[rbp+Pos.typeBB+8*Them]
		and   rax, qword[rbp+Pos.typeBB+8*Queen]
		cmp   rax, 1
		sbb   eax, eax
		and   eax, 717
		sub   edi, eax
	; the following does edi += - 7*mg_value(score)/5 - 5
		lea   edx, [rsi+0x08000]
		sar   edx, 16
		lea   ecx, [8*rdx]
		sub   ecx, edx
		mov   eax, 0x66666667
	       imul   ecx
		sar   ecx, 31
		sar   edx, 1
		lea   edi, [rdi+rcx-5]
		sub   edi, edx
	; edi = kingDanger

		mov   r9, qword[rbp+Pos.typeBB+8*Them]
	       andn   r9, r9, qword[.ei.attackedBy+8*(8*Them+Queen)]
		and   r9, r8
		and   r9, qword[.ei.attackedBy2+8*Them]
	     popcnt   rax, r9, rcx
	       imul   eax, QueenContactCheck
		add   edi, eax

		mov   r8, qword[.ei.attackedBy+8*(8*Us+0)]
		 or   r8, qword[rbp+Pos.typeBB+8*Them]
		not   r8
	; r8 = safe

		mov   r9, qword[rbp+Pos.typeBB+8*Pawn]
		mov   rax, qword[rbp+Pos.typeBB+8*Them]
		and   rax, r9
	   shift_bb   Up, r9
		and   r9, rax
		 or   r9, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		not   r9
	; r9 = other

		mov   r12, qword[rbp+Pos.typeBB+8*White]
		 or   r12, qword[rbp+Pos.typeBB+8*Black]
	RookAttacks   r10, r15, r12, rdx
	; r10 = b1 = pos.attacks_from<ROOK  >(ksq)
      BishopAttacks   r11, r15, r12, rdx
	; r11 = b1 = pos.attacks_from<BISHOP>(ksq)



	; Enemy queen safe checks
		mov   rax, r10
		 or   rax, r11
		and   rax, qword[.ei.attackedBy+8*(8*Them+Queen)]
		and   rax, r8
		lea   ecx, [rdi+QueenCheck]
	     cmovnz   edi, ecx

	; For other pieces, also consider the square safe if attacked twice,
	; and only defended by a queen.
		mov   rax, qword[rbp+Pos.typeBB+8*Them]
		 or   rax, qword[.ei.attackedBy2+8*Us]
		not   rax
		and   rax, qword[.ei.attackedBy+8*(8*Us+Queen)]
		and   rax, qword[.ei.attackedBy2+8*Them]
		 or   r8, rax
	; r8 = safe


	; Enemy rooks safe and other checks

		and   r10, qword[.ei.attackedBy+8*(8*Them+Rook)]
	; r10 = b1 & ei.attackedBy[Them][ROOK]
	       test   r10, r8
		lea   ecx, [rdi+RookCheck]
	     cmovnz   edi, ecx
		jnz   ..RookDone
	       test   r10, r9
		lea   ecx, [rsi-OtherCheck]
	     cmovnz   esi, ecx
    ..RookDone:


	; Enemy bishops safe and other checks

		and   r11, qword[.ei.attackedBy+8*(8*Them+Bishop)]
	; r11 = b1 & ei.attackedBy[Them][BISHOP]

	       test   r11, r8
		lea   ecx, [rdi+BishopCheck]
	     cmovnz   edi, ecx
		jnz   ..BishopDone
	       test   r11, r9
		lea   ecx, [rsi-OtherCheck]
	     cmovnz   esi, ecx
    ..BishopDone:

	; Enemy knights safe and other checks
		mov   r12, qword[KnightAttacks+8*r15]
		and   r12, qword[.ei.attackedBy+8*(8*Them+Knight)]
	; r12 = b
	       test   r12, r8
		lea   ecx, [rdi+KnightCheck]
	     cmovnz   edi, ecx
		jnz   ..KnightDone
	       test   r12, r9
		lea   ecx, [rsi-OtherCheck]
	     cmovnz   esi, ecx
    ..KnightDone:


	; Compute the king danger score and subtract it from the evaluation
		mov   eax, 2*BishopValueMg
	       test   edi, edi
		 js   ..AllDone
	       imul   edi, edi
		shr   edi, 12
		cmp   edi, eax
	      cmova   edi, eax
		shl   edi, 16
		sub   esi, edi

		jmp   ..AllDone

..DoKingSafety:
	; rdi = address of PawnEntry
		mov   ecx, dword[.ei.ksq+4*Us]
	      movzx   eax, byte[rbx+State.castlingRights]
	      movzx   edx, byte[rdi+PawnEntry.castlingRights]
		mov   r12d, eax
		and   eax, 3 shl (2*Us)
		and   edx, 3 shl (2*Them)
		add   edx, eax
		mov   byte[rdi+PawnEntry.kingSquares+1*Us], cl
		mov   byte[rdi+PawnEntry.castlingRights], dl

	       call   ShelterStorm#Us
		mov   esi, eax
		mov   ecx, SQ_G1 + Us*(SQ_G8-SQ_G1)
	       test   r12d, 1 shl (2*Us+0)
		 jz   ..NoKingSide
	       call   ShelterStorm#Us
		cmp   esi, eax
	      cmovl   esi, eax
..NoKingSide:
		mov   ecx, SQ_C1 + Us*(SQ_C8-SQ_C1)
	       test   r12d, 1 shl (2*Us+1)
		 jz   ..NoQueenSide
	       call   ShelterStorm#Us
		cmp   esi, eax
	      cmovl   esi, eax
..NoQueenSide:
		shl   esi, 16
	; esi = score
		mov   ecx, dword[.ei.ksq+4*Us]
		shl   ecx, 3+3
		lea   rcx, [DistanceRingBB+rcx]
		mov   rdx, qword[rbp+Pos.typeBB+8*Us]
		and   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		 jz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*0]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*1]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*2]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*3]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*4]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*5]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
	       test   rdx, qword[rcx+8*6]
		jnz   ..KingSafetyDoneRet
		sub   esi, 16
match=1,DEBUG\{ and   rdx, qword[rcx+8*7] \}
	     Assert   ne, rdx, 0, 'assertion rdx !=0 failed in  ..DoKingSafety'
		jmp   ..KingSafetyDoneRet

..AllDone:

		and   r15d, 7
		mov   r15, qword[KingFlank+8*r15]
	; r15 = KingFlank[kf]   ksq is not used anymore

		mov   rax, Camp
		and   rax, r15
		and   rax, qword[.ei.attackedBy+8*(8*Them+0)]

		mov   rdi, qword[.ei.pi]	; we may have clobbered rdi with kingDanger

	       test   r15, qword[rbp+Pos.typeBB+8*Pawn]
		lea   ecx, [rsi-PawnlessFlank]
	      cmovz   esi, ecx		; pawnless flank


		mov   rdx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		not   rdx
		and   rdx, qword[.ei.attackedBy2+8*Them]
		and   rdx, rax
	if Us eq White
		shl   rax, 4
	else if Us eq Black
		shr   rax, 4
	else
	  display 'bad color in EvalKing'
	  err
	end if
		 or   rax, rdx
	     popcnt   rax, rax, r9
	       imul   eax, CloseEnemies
		sub   esi, eax		; king tropism

	if Us eq White
		add   dword[.ei.score], esi
	else if Us eq Black
		sub   dword[.ei.score], esi
	end if


ED_String ' evaluate_king<'
ED_Int Us
ED_String '>: '
ED_Score rsi
ED_NewLine

}



Macro ShelterStorm Us {
	; in: rbp position
	;     rbx state
	;     ecx ksq
	; out: eax saftey

match =White, Us
\{
	Them  equ Black
	Up    equ DELTA_N
\}

match =Black, Us
\{
	Them  equ White
	Up    equ DELTA_S
\}

	MaxSafetyBonus equ 258

	       push   rsi rdi r12 r13 r14 r15

		mov   r15d, ecx
	; r15 = ksq
		mov   r14d, ecx
		shr   r14d, 3
		mov   r8, qword[InFrontBB+8*(8*Us+r14)]
		 or   r8, qword[RankBB+8*r14]
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
	; r8 = b
		mov   r9, qword[rbp+Pos.typeBB+8*Us]
		and   r9, r8
	; r9 = ourPawns
		mov   r10, qword[rbp+Pos.typeBB+8*Them]
		and   r10, r8
	; r10 = theirPawns
		mov   eax, MaxSafetyBonus
	; eax = saftey
	if Us eq Black
		xor   r14d, 7
	end if
		add   r14d, 1
	; r14d = relative_rank(Us, ksq)+1


		mov   edi, r15d
		mov   edx, 6
		and   edi, 7
		sub   edx, edi
		sar   edx, 31
		sub   edi, 1
		adc   edi, edx


rept 3 i \{
\local ..AddStormDanger

		mov   r13d, edi
		xor   r13d, 7
		cmp   r13d, edi
	      cmova   r13d, edi
	; r13d = std::min(f, FILE_H - f)
		shl   r13d, 3+2

		mov   r8, qword[FileBB+8*rdi]
		and   r8, r9
	if Us eq White
		xor   edx, edx
		bsf   r11, r8
	      cmovz   r11d, edx
		shr   r11d, 3
	else if Us eq Black
		mov   edx, 7 shl 3
		bsr   r11, r8
	      cmovz   r11d, edx
		shr   r11d, 3
		xor   r11d, 7
	end if
	; r11d = rkUs

		mov   r8, qword[FileBB+8*rdi]
		and   r8, r10
	if Us eq White
		xor   edx, edx
		bsf   r12, r8
	      cmovz   r12d, edx
		shr   r12d, 3
	else if Us eq Black
		mov   edx, 7 shl 3
		bsr   r12, r8
	      cmovz   r12d, edx
		shr   r12d, 3
		xor   r12d, 7
	end if
	; r12d = rkThem

		sub   eax, dword[ShelterWeakness+r13+4*r11]

		add   r11d, 1
	; r11d = rkUs+1

		lea   rsi, [StormDanger_BlockedByKing+r13]
		mov   edx, r15d
		and   edx, 7
		sub   edx, edi
		mov   ecx, r14d
		sub   ecx, r12d
		add   edi, 1
		 or   edx, ecx
		 jz   ..AddStormDanger
		lea   rsi, [StormDanger_NoFriendlyPawn+r13]
		cmp   r11d, 1
		 je   ..AddStormDanger
		lea   rsi, [StormDanger_BlockedByPawn+r13]
		cmp   r11d, r12d
		 je   ..AddStormDanger
		lea   rsi, [StormDanger_Unblocked+r13]
	..AddStormDanger:
		sub   eax, dword[rsi+4*r12]
\}

		pop   r15 r14 r13 r12 rdi rsi
		ret
}






macro EvalThreats Us {
	; in: rbp position
	;     rbx state
	;     rsp evaluation info
	;     r10-r15 various bitboards
	; io: esi score accumulated

local ThreatByKing0, ThreatByKing1
local ..SafeThreatsDone, ..SafeThreatsLoop, ..WeakDone
local ..ThreatMinorLoop, ..ThreatMinorDone, ..ThreatRookLoop, ..ThreatRookDone
local ..ThreatMinorSkipPawn, ..ThreatRookSkipPawn

ThreatByKing0		equ (( 3 shl 16) + ( 62))
ThreatByKing1		equ (( 9 shl 16) + (138))


match =White, Us
\{
	addsub	       equ add
	AttackedByUs   equ r10
	AttackedByThem equ r11
	PiecesPawn     equ r12
	PiecesAll      equ r13
	PiecesUs       equ r14
	PiecesThem     equ r15
	Them  equ Black
	Up    equ DELTA_N
	Left  equ DELTA_NW
	Right equ DELTA_NE
	TRank2BB equ Rank2BB
	TRank7BB equ Rank7BB
\}

match =Black, Us
\{
	addsub	       equ sub
	AttackedByUs   equ r11
	AttackedByThem equ r10
	PiecesPawn     equ r12
	PiecesAll      equ r13
	PiecesUs       equ r15
	PiecesThem     equ r14
	Them  equ White
	Up    equ DELTA_S
	Left  equ DELTA_SE
	Right equ DELTA_SW
	TRank2BB equ Rank7BB
	TRank7BB equ Rank2BB
\}

		mov   rax, AttackedByUs
		 or   rax, AttackedByThem
		mov   rdx, qword[rbp+Pos.typeBB+8*Queen]
		 or   rdx, qword[rbp+Pos.typeBB+8*King]
		and   rdx, PiecesThem
		xor   rdx, PiecesThem
	       andn   rax, rax, rdx
		neg   rax
		sbb   eax, eax
		and   eax, LooseEnemies
	     addsub   esi, eax

		mov   r8, PiecesThem
		mov   r9, PiecesPawn
		and   r9, PiecesThem
		xor   r8, r9
		and   r8, qword[.ei.attackedBy+8*(8*Us+Pawn)]
	; r8 = weak
		 jz   ..SafeThreatsDone

		mov   r9, AttackedByThem
		not   r9
		 or   r9, AttackedByUs
		and   r9, PiecesUs
		and   r9, PiecesPawn
		mov   rdx, r9
	   shift_bb   Right, r9, rcx
	   shift_bb   Left, rdx, rcx
		 or   r9, rdx
		and   r9, r8
	; r9 = safeThreats
		xor   r8, r9
		neg   r8
		sbb   eax, eax
		and   eax, ThreatByHangingPawn
	     addsub   esi, eax

	       test   r9, r9
		 jz   ..SafeThreatsDone
..SafeThreatsLoop:
		bsf   rax, r9
	      movzx   eax, byte[rbp+Pos.board+rax]
	     addsub   esi, dword[ThreatBySafePawn+4*rax]
	       blsr   r9, r9, rcx
		jnz   ..SafeThreatsLoop
..SafeThreatsDone:

		mov   r8, PiecesThem
		mov   r9, PiecesPawn
		and   r9, r8
		xor   r8, r9
		mov   r9, qword[.ei.attackedBy+8*(8*Them+Pawn)]
		and   r8, r9
	; r8 = defended
	       andn   r9, r9, PiecesThem
		and   r9, AttackedByUs
	; r9 = weak
		 or   r8, r9
	; r8 = defended | weak
		 jz   ..WeakDone
		mov   rax, qword[.ei.attackedBy+8*(8*Us+Knight)]
		 or   rax, qword[.ei.attackedBy+8*(8*Us+Bishop)]
		and   r8, rax
		 jz   ..ThreatMinorDone
..ThreatMinorLoop:
		bsf   rax, r8
	      movzx   ecx, byte[rbp+Pos.board+rax]
	     addsub   esi, dword[Threat_Minor+4*rcx]
		shr   eax, 3
    if Us eq White
		xor   eax, Them*7
    end if
	; tricky: we want only the lower byte of the memory here,
	;  but the upper 3 bytes of eax are zero anyways
		and   eax, dword[IsNotPawnMasks+rcx]
	       imul   eax, ThreatByRank
	     addsub   esi, eax
	       blsr   r8, r8, rcx
		jnz   ..ThreatMinorLoop
..ThreatMinorDone:

		mov   rdx, PiecesThem
		and   rdx, qword[rbp+Pos.typeBB+8*Queen]
		 or   rdx, r9
		and   rdx, qword[.ei.attackedBy+8*(8*Us+Rook)]
		 jz   ..ThreatRookDone
..ThreatRookLoop:
		bsf   rax, rdx
	      movzx   ecx, byte[rbp+Pos.board+rax]
	     addsub   esi, dword[Threat_Rook+4*rcx]

		shr   eax, 3
    if Us eq White
		xor   eax, Them*7
    end if
		and   eax, dword[IsNotPawnMasks+rcx]
	       imul   eax, ThreatByRank
	     addsub   esi, eax

	       blsr   rdx, rdx, rcx
		jnz   ..ThreatRookLoop
..ThreatRookDone:

	       andn   rax, AttackedByThem, r9
	     popcnt   rax, rax, rcx
	       imul   eax, Hanging
	     addsub   esi, eax

		mov   rcx, qword[.ei.attackedBy+8*(8*Us+King)]
		and   rcx, r9
		mov   rdx, rcx
		neg   rdx
		sbb   edx, edx
	       blsr   rcx, rcx, rax
		neg   rcx
		sbb   eax, eax
		and   eax, ThreatByKing1-ThreatByKing0
		add   eax, ThreatByKing0
		and   eax, edx
	     addsub   esi, eax

..WeakDone:
		mov   rax, not TRank7BB
		and   rax, PiecesUs
		and   rax, PiecesPawn

		mov   rcx, TRank2BB
		and   rcx, rax
	   shift_bb   Up, rcx
	       andn   rdx, PiecesAll, rcx
		 or   rax, rdx
	   shift_bb   Up, rax

		mov   rdx, PiecesAll
		not   rdx
		and   rax, rdx
		mov   rcx, qword[.ei.attackedBy+8*(8*Them+Pawn)]
		not   rcx
		and   rax, rcx
		mov   rdx, AttackedByThem
		not   rdx
		 or   rdx, AttackedByUs
		and   rax, rdx

		mov   rdx, rax
	   shift_bb   Left, rax, rcx
	   shift_bb   Right, rdx, rcx
		 or   rax, rdx
		and   rax, PiecesThem
		mov   rcx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		not   rcx
		and   rax, rcx
	     popcnt   rax, rax, rdx
	       imul   eax, ThreatByPawnPush
	     addsub   esi, eax


ED_String ' evaluate_threats<'
ED_Int Us
ED_String '>: '
ED_Score rsi
ED_NewLine


restore PiecesPawn
restore PiecesAll
restore PiecesUs
restore PiecesThem
}






macro EvalPassedPawns Us {
	; in: rbp position
	;     rbx state
	;     rsp evaluation info
	;     r15 qword[rdi+PawnEntry.passedPawns+8*Us]
	; io  esi accumulated score

local addsub, subadd
local Them, Up
local ..NextPawn, ..AllDone, ..AddBonus, ..Continue

match =White, Us
\{
	addsub	equ add
	subadd	equ sub
	Them	equ Black
	Up	equ DELTA_N
\}

match =Black, Us
\{
	addsub	equ sub
	subadd	equ add
	Them	equ White
	Up	equ DELTA_S
\}

	     Assert   ne, r15, 0, "assertion r15!=0 failed in EvalPassedPawns"

..NextPawn:
		bsf   rcx, r15
	       blsr   r15, r15, rax

		mov   r12d,  ecx
		shr   r12d, 3
	if Us eq Black
		xor   r12d, 7
	end if
	; r12d = r+1
	     addsub   esi, dword[PassedRank+4*r12]
		mov   eax, ecx
		and   eax, 7
	     addsub   esi, dword[PassedFile+4*rax]

		mov   rax, qword[ForwardBB+8*(64*Us+rcx)]
		mov   rdx, qword[.ei.attackedBy+8*(8*Them+0)]
		 or   rdx, qword[rbp+Pos.typeBB+8*Them]
		and   rax, rdx
	     popcnt   rax, rax, r8
	       imul   eax, HinderPassedPawn
	     subadd   esi, eax

		lea   r13d, [r12-2]
		sub   r12d, 1
	       imul   r13d, r12d
	; r12d = r
	; r13d = rr = r*(r-1)

		lea   r14d, [rcx+Up]
	; r14d = blockSq

	if Us eq White
		cmp   ecx, SQ_A4
		 jb   ..Continue
	else if Us eq Black
		cmp   ecx, SQ_A6
		jae   ..Continue
	end if

		mov   r8d, dword[.ei.ksq+4*Them]
		mov   r9d, dword[.ei.ksq+4*Us]
		shl   r8d, 6
		shl   r9d, 6
		xor   r10d, r10d
	      movzx   eax, byte[SquareDistance+r8+r14]
	      movzx   edx, byte[SquareDistance+r9+r14]
	      movzx   r11d, byte[SquareDistance+r9+r14+Up]
		lea   eax, [5*rax]
	if Us eq White
		cmp   ecx, SQ_A7
	      cmovb   r10d, r11d
	else if Us eq Black
		cmp   ecx, SQ_A3
	     cmovae   r10d, r11d
	end if
		lea   edx, [2*rdx+r10]
		sub   eax, edx
	       imul   eax, r13d
	     addsub   esi, eax

		mov   r8, qword[rbp+Pos.typeBB+8*Us]
		mov   r9, qword[rbp+Pos.typeBB+8*Them]
		mov   r10, qword[ForwardBB+8*(64*Us+r14-Up)]
		lea   eax, [r13+2*r12]
		 bt   r8, r14
		 jc   ..AddBonus  ; the pawn is blocked by us
		mov   r11, r10
		mov   r12, r10
		 bt   r9, r14
		 jc   ..Continue  ; the pawn is blocked by them

		xor   r9, r8
	RookAttacks   rax, (r14-Up), r9, rdx
		xor   r9, r8
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, qword[ForwardBB+8*(64*Them+r14-Up)]
		and   rax, rcx

		 or   rcx, -1
	       test   r8, rax
	      cmovz   rcx, qword[.ei.attackedBy+8*(8*Us+0)]
		and   r10, rcx

		 or   rcx, -1
	       test   r9, rax
	      cmovz   rcx, qword[.ei.attackedBy+8*(8*Them+0)]
		 or   rcx, r9
		and   r11, rcx

		 bt   r11, r14
		sbb   eax, eax
		neg   r11
		sbb   ecx, ecx
		lea   ecx, [5*rcx]
		lea   eax, [rcx+4*rax+9]
	; eax = k/2
		xor   ecx, ecx
		 bt   r10, r14
		adc   ecx, ecx
		xor   r10, qword[ForwardBB+8*(64*Us+r14-Up)]
		cmp   r10, 1
		adc   ecx, ecx
		add   eax, ecx
	; eax = k/2

ED_String 'k/2: '
ED_Int rax
ED_NewLine


		add   r13d, r13d
	       imul   eax, r13d
..AddBonus:
	       imul   eax, 0x00010001
	     addsub   esi, eax

..Continue:		

	; Assign a small bonus when the opponent has no pieces left
		lea   eax, [esi+20*(1-2*Us)]
	       test   dword[rbx+State.npMaterial], 0x0FFFF shl (16*Them)
	      cmovz   esi, eax

	       test   r15, r15
		jnz   ..NextPawn

..AllDone:


ED_String ' evaluate_passed_pawns<'
ED_Int Us
ED_String '>: '
ED_Score rsi
ED_NewLine

}









macro EvalSpace Us {
	; in: rbp position
	;     rbx state
	;     rdi qword[.ei.pi]
	;     r10-r15 various bitboards
	;     rsp evaluation info

match =White, Us
\{
	addsub	       equ add
	AttackedByUs   equ r10
	AttackedByThem equ r11
	PiecesPawn     equ r12
	PiecesAll      equ r13
	PiecesUs       equ r14
	PiecesThem     equ r15

	Them  equ Black
	SpaceMask  equ ((FileCBB or FileDBB or FileEBB or FileFBB) \
			and (Rank2BB or Rank3BB or Rank4BB))
\}

match =Black, Us
\{
	addsub	       equ sub
	AttackedByUs   equ r11
	AttackedByThem equ r10
	PiecesPawn     equ r12
	PiecesAll      equ r13
	PiecesUs       equ r15
	PiecesThem     equ r14

	Them  equ White
	SpaceMask  equ ((FileCBB or FileDBB or FileEBB or FileFBB) \
			and (Rank7BB or Rank6BB or Rank5BB))

\}

		mov   rdx, PiecesUs
		and   rdx, PiecesPawn
	; rdx = pos.pieces(Us, PAWN)

	       andn   rax, AttackedByUs, AttackedByThem
		 or   rax, qword[.ei.attackedBy+8*(8*Them+Pawn)]
		 or   rax, rdx
		mov   rcx, SpaceMask
	       andn   rax, rax, rcx
	; rax = safe

		mov   rcx, rdx
	if Us eq White
		shr   rdx, 8
		 or   rcx, rdx
		mov   rdx, rcx
		shr   rdx, 16
		 or   rcx, rdx
	else if Us eq Black
		shl   rdx, 8
		 or   rcx, rdx
		mov   rdx, rcx
		shl   rdx, 16
		 or   rcx, rdx
	end if
	; rcx = behind

		and   rcx, rax
	if Us eq White
		shl   rax, 32
	else if Us eq Black
		shr   rax, 32
	end if
		 or   rax, rcx
	     popcnt   rax, rax, rdx
		mov   ecx, 16
		cmp   eax, ecx
	      cmova   eax, ecx


	      movzx   ecx, byte[rdi+PawnEntry.openFiles]
		add   ecx, ecx
	     popcnt   rdx, qword[rbp+Pos.typeBB+8*Us], r8
		sub   edx, ecx
	       imul   edx, edx

	       imul   eax, edx
		xor   edx, edx
		mov   ecx, 18
	       idiv   ecx
		shl   eax, 16

	     addsub   esi, eax

ED_String ' evaluate_space<'
ED_Int Us
ED_String '>: '
ED_Score rsi
ED_NewLine


restore PiecesPawn
restore PiecesAll
restore PiecesUs
restore PiecesThem
}



Evaluate_Cold:


virtual at rsp
 .ei EvalInfo
end virtual
	      align   16
.DoPawnEval:
	  EvalPawns   White
		mov   dword[rdi+PawnEntry.score], esi
	  EvalPawns   Black
	      movzx   ecx, byte[rdi+PawnEntry.semiopenFiles+0]
	      movzx   eax, byte[rdi+PawnEntry.semiopenFiles+1]
		mov   r8, qword[rbx+State.pawnKey]
		mov   edx, ecx
		xor   ecx, eax
		and   edx, eax
		mov   eax, dword[rdi+PawnEntry.score]
		sub   eax, esi
	     popcnt   rcx, rcx, r9
	     popcnt   rdx, rdx, r9
		mov   qword[rdi+PawnEntry.key], r8
		mov   dword[rdi+PawnEntry.score], eax
		mov   byte[rdi+PawnEntry.asymmetry], cl
		mov   byte[rdi+PawnEntry.openFiles], dl
		jmp   Evaluate.DoPawnEvalReturn


.ReturnLazyEval:

ProfileInc EvaluateLazy

	      movsx   eax, word[.ei.score+0]
	      movsx   edx, word[.ei.score+2]
		mov   ecx, dword[rbp+Pos.sideToMove]
		neg   ecx
		 bt   eax, 15
		adc   eax, edx
		cdq		     ; divide eax by 2
		sub   eax, edx	     ;
		sar   eax, 1	     ;
		sub   eax, r8d
		lea   edx, [rax+3]   ; divide eax by 4
	      cmovs   eax, edx	     ;
		sar   eax, 2	     ;
		add   eax, r8d
		xor   eax, ecx
		sub   eax, ecx

		add   rsp, sizeof.EvalInfo
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret


	      align   16
ShelterStorm0:
	ShelterStorm White


	      align   16
ShelterStorm1:
	ShelterStorm Black





	      align   64
Evaluate:
	; in  rbp address of Pos struct
	;     rbx address of State struct
	; out eax evaluation

ProfileInc Evaluate

	       push   rbx rsi rdi r12 r13 r14 r15
		sub   rsp, sizeof.EvalInfo
virtual at rsp
 .ei EvalInfo
end virtual

		mov   rdi, qword[rbx+State.pawnKey]
		and   edi, PAWN_HASH_ENTRY_COUNT-1
	       imul   edi, sizeof.PawnEntry
		add   rdi, qword[rbp+Pos.pawnTable]
		mov   r15, qword[rdi+PawnEntry.key]
		mov   qword[.ei.pi], rdi


		mov   eax, dword[rbx+State.psq]
		mov   dword[.ei.score], eax

ED_String 'psq score: '
ED_Score qword[.ei.score]
ED_NewLine



		mov   r12, qword[rbp+Pos.typeBB+8*Queen]
		mov   r13, qword[rbp+Pos.typeBB+8*Rook]
		 or   r13, r12
		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
		 or   r12, qword[rbp+Pos.typeBB+8*Bishop]
		mov   esi, dword[rbp+Pos.sideToMove]

	if PEDANTIC
	      movzx   eax, byte[rbp+Pos.pieceList+16*(8*White+King)]
	      movzx   edx, byte[rbp+Pos.pieceList+16*(8*Black+King)]
	else
		mov   rax, qword[rbp+Pos.typeBB+8*King]
		and   rax, qword[rbp+Pos.typeBB+8*White]
		bsf   rax, rax
		mov   rdx, qword[rbp+Pos.typeBB+8*King]
		and   rdx, qword[rbp+Pos.typeBB+8*Black]
		bsf   rdx, rdx
	end if

		mov   dword[.ei.ksq+4*White], eax
		mov   dword[.ei.ksq+4*Black], edx
		mov   rax, qword[KingAttacks+8*rax]
		mov   rdx, qword[KingAttacks+8*rdx]
		xor   rcx, rcx
		mov   qword[.ei.attackedBy+8*(8*White+0   )], rcx
		mov   qword[.ei.attackedBy+8*(8*White+King)], rax
		mov   qword[.ei.attackedBy+8*(8*Black+0   )], rcx
		mov   qword[.ei.attackedBy+8*(8*Black+King)], rdx

		mov   rax, qword[rbp+Pos.typeBB+8*White]
		mov   rdx, qword[rbp+Pos.typeBB+8*Black]
		and   rax, qword[rbx+State.blockersForKing+8*White]
		and   rdx, qword[rbx+State.blockersForKing+8*Black]
		mov   qword[.ei.pinnedPieces+8*White], rax
		mov   qword[.ei.pinnedPieces+8*Black], rdx



		mov   rsi, qword[rbx+State.materialKey]
		and   esi, MATERIAL_HASH_ENTRY_COUNT-1
	       imul   esi, sizeof.MaterialEntry
		add   rsi, qword[rbp+Pos.materialTable]
		mov   rdx, qword[rsi+MaterialEntry.key]
	      movsx   eax, word[rsi+MaterialEntry.value]
	      movzx   ecx, byte[rsi+MaterialEntry.evaluationFunction]
		mov   qword[.ei.me], rsi

		cmp   rdx, qword[rbx+State.materialKey]
		jne   DoMaterialEval	; 0.87%
.DoMaterialEvalReturn:
	       imul   eax, 0x00010001
		add   dword[.ei.score], eax
	       test   ecx, ecx
		jnz   HaveSpecializedEval

		mov   eax, dword[rdi+PawnEntry.score]
		cmp   r15, qword[rbx+State.pawnKey]
		jne   Evaluate_Cold.DoPawnEval	 ; 6.34%
.DoPawnEvalReturn:
		add   eax, dword[.ei.score]
		mov   dword[.ei.score], eax


	; We have taken into account all cheap evaluation terms.
	; If score exceeds a threshold return a lazy evaluation.
	;  lazy eval is called about 5% of the time

	; checking if the components of a score (mg,eg) are BOTH >= 0 can be
	;  done by testing the sign bits in the packed representation.
	;  this is correct
		sub   eax, 0x00010001 * (LazyEval+1)
		mov   edx, 0x00010001 * ((-2*LazyEval)-2)
		mov   r8d, LazyEval
	       test   eax, 0x80008000
		 jz   Evaluate_Cold.ReturnLazyEval
		sub   edx, eax
		neg   r8d
	       test   edx, 0x80008000
		 jz   Evaluate_Cold.ReturnLazyEval


	   EvalInit   White
	   EvalInit   Black

		mov   r8, qword[rbp+Pos.typeBB+8*White]
		mov   r9, qword[rbp+Pos.typeBB+8*Black]
		mov   rcx, Rank2BB+Rank3BB
		mov   rsi, Rank7BB+Rank6BB
		mov   rax, r8
		 or   rax, r9
		mov   rdx, rax
		mov   r13, rax
	; r13 = all pieces
	   shift_bb   DELTA_S, rax
	   shift_bb   DELTA_N, rdx
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
		and   r9, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rax, rcx
		 or   rdx, rsi
		and   rax, r8
		and   rdx, r9
		mov   ecx, dword[.ei.ksq+4*White]
		mov   esi, dword[.ei.ksq+4*Black]
		 or   rax, qword[.ei.attackedBy+8*(8*Black+Pawn)]
		 or   rdx, qword[.ei.attackedBy+8*(8*White+Pawn)]
		bts   rax, rcx
		bts   rdx, rsi
		not   rax
		not   rdx
		mov   qword[.ei.mobilityArea+8*White], rax
		mov   qword[.ei.mobilityArea+8*Black], rdx


	; EvalPieces adds to esi
		mov   esi, dword[.ei.score]
		xor   r15, r15		; prepare for dirty trick
		mov   r12, qword[rbp+Pos.typeBB+8*Knight]
	 EvalPieces   White, Knight
	 EvalPieces   Black, Knight
		mov   r12, qword[rbp+Pos.typeBB+8*Bishop]
	 EvalPieces   White, Bishop
	 EvalPieces   Black, Bishop
		mov   r12, qword[rbp+Pos.typeBB+8*Rook]
	 EvalPieces   White, Rook
	 EvalPieces   Black, Rook
		mov   r12, qword[rbp+Pos.typeBB+8*Queen]
	 EvalPieces   White, Queen
	 EvalPieces   Black, Queen

	; EvalKing adds to dword[.ei.score]
		mov   dword[.ei.score], esi
	   EvalKing   Black
	   EvalKing   White
		mov   esi, dword[.ei.score]

	; EvalPassedPawns, EvalThreats, EvalSpace add to esi
	; EvalPassedPawns and EvalThreats are switched because
	;    EvalThreats and EvalSpace share r10-r15
		mov   r15, qword[rdi+PawnEntry.passedPawns+8*White]
	       test   r15, r15
		jnz   Evaluate_Cold2.EvalPassedPawns0
		mov   r15, qword[rdi+PawnEntry.passedPawns+8*Black]
	       test   r15, r15
		jnz   Evaluate_Cold2.EvalPassedPawns1
.EvalPassedPawnsRet:

		mov   r14, qword[rbp+Pos.typeBB+8*White]
		mov   r15, qword[rbp+Pos.typeBB+8*Black]
		mov   r12, qword[rbp+Pos.typeBB+8*Pawn]
		mov   r13, r14
		 or   r13, r15
		mov   r10, qword[.ei.attackedBy+8*(8*White+0)]
		mov   r11, qword[.ei.attackedBy+8*(8*Black+0)]
	EvalThreats   Black
	EvalThreats   White

	      movzx   eax, word[rbx+State.npMaterial+2*0]
	      movzx   ecx, word[rbx+State.npMaterial+2*1]
		add   eax, ecx
		cmp   eax, 12222
		 jb   .SkipSpace
	  EvalSpace   Black
	  EvalSpace   White
.SkipSpace:



	; Evaluate position potential for the winning side
	     popcnt   r9, qword[rbp+Pos.typeBB+8*Pawn], rcx
	      movzx   edx, byte[rdi+PawnEntry.asymmetry]
		lea   edx, [rdx+r9-15]
		shl   edx, 3
		lea   r9d, [rdx+4*r9]
	; r9d = 8*(asy+pawns-15)+4*pawns
	      movsx   r10d, si
	; r11d = eg score
		sar   r10d, 31
		mov   r11d, r10d
		mov   eax, dword[.ei.ksq+4*White]
		mov   ecx, dword[.ei.ksq+4*Black]
		and   eax, 7
		and   ecx, 7
		sub   eax, ecx
		cdq
		xor   eax, edx
		sub   eax, edx
		mov   r8d, eax
		mov   eax, dword[.ei.ksq+4*White]
		mov   ecx, dword[.ei.ksq+4*Black]
		shr   eax, 3
		shr   ecx, 3
		sub   eax, ecx
		cdq
		xor   eax, edx
		sub   eax, edx
		sub   r8d, eax
		lea   eax, [r9+8*r8]
	; eax = initiative
	      movsx   edx, si
		xor   edx, r11d
		sub   edx, r11d
		shr   edx, 1
		neg   edx
		cmp   eax, edx
	      cmovl   eax, edx
	; eax = std::max(initiative, -abs(eg / 2))
	       test   esi, 0x0FFFF
	      cmovz   r10d, eax
		xor   eax, r10d
		sub   eax, r11d
		add   esi, eax

ED_String ' evaluate_initiative: '
ED_Score rsi
ED_String 'partial score: '
ED_Score rsi

	; esi = score
	; r14 = ei.pi
	; Evaluate scale factor for the winning side

		mov   r14, qword[.ei.pi]
		mov   r15, qword[.ei.me]
if PEDANTIC
	      movsx   r12d, si
		lea   r13d, [r12-1]
		sar   r13d, 31
		and   r13d, 1
else
		xor   r13d, r13d
		 bt   esi, 15
		adc   r13d, r13d
	      movsx   r12d, si
end if
	      movzx   ecx, byte[r15+MaterialEntry.scalingFunction+r13]
	      movzx   eax, byte[r15+MaterialEntry.factor+r13]
	      movzx   edx, byte[r15+MaterialEntry.gamePhase]
		add   esi, 0x08000
		sar   esi, 16
	       test   ecx, ecx
		jnz   Evaluate_Cold2.HaveScaleFunction	      ; 1.98%
.HaveScaleFunctionReturn:
ED_String ' ei.me->scale_factor(pos, strongSide): '
ED_Int rax
		lea   ecx, [rax-48]
		mov   r10, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r8, qword[rbp+Pos.typeBB+8*White]
		mov   r9, qword[rbp+Pos.typeBB+8*Black]
		mov   edi, dword[rbx+State.npMaterial]
		and   r8, r10
		and   r9, r10
		cmp   edx, PHASE_MIDGAME
		jae   .ScaleFactorDone
	       test   ecx, not 16
		jnz   .ScaleFactorDone
	       blsr   r8, r8, rcx
	       blsr   r9, r9, rcx
		mov   r11, qword[rbp+Pos.typeBB+8*Pawn]
		mov   rcx, DarkSquares
	       test   rcx, r10
		 jz   .NotOppBishop
		mov   rcx, LightSquares
	       test   rcx, r10
		 jz   .NotOppBishop
		 or   r8, r9
		jnz   .NotOppBishop
	       blsr   rcx, r11, r8
		mov   eax, 46
		neg   rcx
		sbb   ecx, ecx
		and   ecx, 31-9
		add   ecx, 9
		cmp   edi, (BishopValueMg shl 16) + BishopValueMg
	      cmove   eax, ecx
		jmp   .ScaleFactorDone
.NotOppBishop:
		lea   r9d, [r12+BishopValueEg]
		and   r11, qword[rbp+Pos.typeBB+8*r13]
		xor   r13d, 1
		cmp   r9d, 2*BishopValueEg+1
		jae   .ScaleFactorDone
		mov   r9d, dword[.ei.ksq+4*r13]
		shl   r13, 6+3
	       test   r11, qword[PassedPawnMask+r13+8*r9]
		 jz   .ScaleFactorDone
	     popcnt   rcx, r11, r9
		cmp   ecx, 3
		jae   .ScaleFactorDone
	       imul   ecx, 7
		add   ecx, 37
		mov   eax, ecx
.ScaleFactorDone:
	; eax = scale factor
	; edx = phase
	; esi = mg_score(score)
	; r12d = eg_value(score)
	; adjust score for side to move

;SD_String 'sf:'
;SD_Int rax
;SD_String '|'

if PEDANTIC
  ;// Interpolate between a middlegame and a (scaled by 'sf') endgame score
  ;Value v =  mg_value(score) * int(ei.me->game_phase())
  ;         + eg_value(score) * int(PHASE_MIDGAME - ei.me->game_phase()) * sf / SCALE_FACTOR_NORMAL;
  ;v /= int(PHASE_MIDGAME);
		mov   ecx, dword[rbp+Pos.sideToMove]
		mov   edi, 128
		sub   edi, edx
	       imul   edi, r12d
		mov   r11d, ecx
	       imul   edi, eax
		lea   r14d, [rdi+3FH]
	       test   edi, edi
	      cmovs   edi, r14d
	       imul   esi, edx
		sar   edi, 6
		lea   edx, [rdi+rsi]
		lea   eax, [rdx+7FH]
	       test   edx, edx
	      cmovs   edx, eax
		neg   r11d
		sar   edx, 7
		xor   edx, r11d
		lea   eax, [rcx+rdx+Eval_Tempo]
else
	; the evaluation should be exactly symmetric
	;  hence the signed division by PHASE_MIDGAME*SCALE_FACTOR_NORMAL
	;  requires some care
	; example: x/16 = sar(x+7-sar(x,31),4)
	;  rounds to the nearest integer  with ties going towards zero
		mov   ecx, dword[rbp+Pos.sideToMove]
		mov   edi, ecx
		neg   ecx
	       imul   esi, edx
		shl   esi, 6
		neg   r12d
		sub   edx, PHASE_MIDGAME
	       imul   edx, r12d
	       imul   eax, edx
		add   eax, esi
		cdq
		add   eax, (1 shl 12) - 1
		sub   eax, edx
		sar   eax, 13
		xor   eax, ecx
		lea   eax, [rax+rdi+Eval_Tempo]
end if

SD_String 'eval:'
SD_Int rax
SD_String '|'

		add   rsp, sizeof.EvalInfo
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret




Evaluate_Cold2:

virtual at rsp
 .ei EvalInfo
end virtual

.HaveScaleFunction:
		mov   eax, ecx
		shr   eax, 1
		mov   eax, dword[EndgameScale_FxnTable+4*rax]
		and   ecx, 1
	       call   rax
		cmp   eax, SCALE_FACTOR_NONE
	      movzx   edx, byte[r15+MaterialEntry.gamePhase]
	      movzx   ecx, byte[r15+MaterialEntry.factor+r13]
	      cmove   eax, ecx
		jmp   Evaluate.HaveScaleFunctionReturn

	      align   16
.EvalPassedPawns0:
    EvalPassedPawns   White
		mov   r15, qword[rdi+PawnEntry.passedPawns+8*Black]
	       test   r15, r15
		 jz   Evaluate.EvalPassedPawnsRet
	      align   8
.EvalPassedPawns1:
    EvalPassedPawns   Black
		jmp   Evaluate.EvalPassedPawnsRet



HaveSpecializedEval:
		mov   eax, ecx
		shr   eax, 1
		mov   eax, dword[EndgameEval_FxnTable+4*rax]
		and   ecx, 1
	       call   rax
		add   rsp, sizeof.EvalInfo
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret



	; this is rarely called and should preserve rdi,r12,r13,r14,r15 (as well as rbx and rbp)
DoMaterialEval:
	; in: rsi address of MaterialEntry
	;     rbp address of position
	;     rbx address of state
	;     rsp address of EvalInfo
	; out:       return is .DoMaterialEvalReturn
	;     eax  sign_ext(word[rsi+MaterialEntry.value])
	;     ecx  zero_ext(byte[rsi+MaterialEntry.evaluationFunction])
	       push   r12 r13 r14 r15

		mov   r12, qword[rbx+State.materialKey]
	      movzx   r14d, word[rbx+State.npMaterial+2*0]
	      movzx   r15d, word[rbx+State.npMaterial+2*1]
		lea   eax, [r14+r15]
		xor   edx, edx
		mov   ecx, MidgameLimit - EndgameLimit
		sub   eax, EndgameLimit
	      cmovs   eax, edx
		cmp   eax, ecx
	     cmovae   eax, ecx
		shl   eax, 7
		div   ecx

		xor   edx, edx
		mov   qword[rsi+MaterialEntry.key], r12
		mov   byte[rsi+MaterialEntry.scalingFunction+0], dl
		mov   byte[rsi+MaterialEntry.scalingFunction+1], dl
		mov   byte[rsi+MaterialEntry.evaluationFunction], dl
		mov   byte[rsi+MaterialEntry.gamePhase], al
		mov   byte[rsi+MaterialEntry.factor+1*White], SCALE_FACTOR_NORMAL
		mov   byte[rsi+MaterialEntry.factor+1*Black], SCALE_FACTOR_NORMAL
		mov   word[rsi+MaterialEntry.value], dx


	; Let's look if we have a specialized evaluation function for this particular
	; material configuration. Firstly we look for a fixed configuration one, then
	; for a generic one if the previous search failed.
		lea   r10, [EndgameEval_Map]
		lea   r11, [EndgameEval_Map+2*ENDGAME_EVAL_MAP_SIZE*sizeof.EndgameMapEntry]
		lea   r13, [rsi+MaterialEntry.evaluationFunction]
.NextEvalKey:
		mov   rdx, qword[r10+EndgameMapEntry.key]
		mov   ecx, dword[r10+EndgameMapEntry.entri]
		add   r10, sizeof.EndgameMapEntry
		cmp   rdx, qword[rsi+MaterialEntry.key]
		 je   .FoundEvalFxn
		cmp   r10, r11
		 jb   .NextEvalKey
		mov   r8, qword[rbp+Pos.typeBB+8*Black]
		mov   r9, qword[rbp+Pos.typeBB+8*White]
.Try_KXK_White:
		mov   ecx, 2*EndgameEval_KXK_index
	       blsr   rdx, r8
		jnz   .Try_KXK_Black
		cmp   r14d, RookValueMg
		jge   .FoundEvalFxn
.Try_KXK_Black:
		add   ecx, 1
	       blsr   rdx, r9
		jnz   .Try_KXK_Done
		cmp   r15d, RookValueMg
		jge   .FoundEvalFxn
.Try_KXK_Done:


	; OK, we didn't find any special evaluation function for the current material
	; configuration. Is there a suitable specialized scaling function?
		lea   r10, [EndgameScale_Map]
		lea   r11, [EndgameScale_Map+2*ENDGAME_SCALE_MAP_SIZE*sizeof.EndgameMapEntry]
.NextScaleKey:
		mov   rdx, qword[r10+EndgameMapEntry.key]
		mov   ecx, dword[r10+EndgameMapEntry.entri]
		add   r10, sizeof.EndgameMapEntry
		cmp   rdx, qword[rsi+MaterialEntry.key]
		 je   .FoundScaleFxn
		cmp   r10, r11
		 jb   .NextScaleKey

		sub   rsp, 8*16
		jmp   .Continue

.FoundScaleFxn:
		mov   r13d, ecx
		and   r13d, 1
		lea   r13, [rsi+MaterialEntry.scalingFunction+r13]
		xor   eax, eax	; obey out condtions
		mov   byte[r13], cl
		xor   ecx, ecx
		pop   r15 r14 r13 r12
		jmp   Evaluate.DoMaterialEvalReturn
.FoundEvalFxn:
		xor   eax, eax	; obey out condtions
		mov   byte[r13], cl
		pop   r15 r14 r13 r12
		jmp   Evaluate.DoMaterialEvalReturn



.Continue:
	; We didn't find any specialized scaling function, so fall back on generic
	; ones that refer to more than one material distribution. Note that in this
	; case we don't return after setting the function.

		xor   r8d, r8d
.CountLoop:
		mov   rdx, qword[rbp+Pos.typeBB+r8]
		mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
		and   rax, rdx
	     popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Pawn)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Knight]
		and   rax, rdx
	     popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Knight)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Bishop]
		and   rax, rdx
	     popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Bishop)], eax
		cmp   eax, 2
		sbb   eax, eax
		add   eax, 1
		mov   dword[rsp+4*(r8+1)], eax		    ; bishop pair
		mov   rax, qword[rbp+Pos.typeBB+8*Rook]
		and   rax, rdx
	     popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Rook)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		and   rax, rdx
	     popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Queen)], eax

		add   r8d, 8
		cmp   r8d, 16
		 jb   .CountLoop


irps Us, White Black {
match =White, Us \{
	Them	 equ Black
	npMat	 equ r14d \}
match =Black, Us \{
	Them	 equ White
	npMat	 equ r15d\}
.Check_KBPsKs_#Us:
		cmp   npMat, BishopValueMg
		jne   .Check_KQKRPs_#Us
		mov   eax, dword[rsp+4*(8*Us+Bishop)]
		cmp   eax, 1
		jne   .Check_KQKRPs_#Us
		mov   eax, dword[rsp+4*(8*Us+Pawn)]
	       test   eax, eax
		 jz   .Check_KQKRPs_#Us
		mov   byte[rsi+MaterialEntry.scalingFunction+1*Us], 2*EndgameScale_KBPsK_index+Us
		jmp   .Check_sDone_#Us
.Check_KQKRPs_#Us:
		cmp   npMat, QueenValueMg
		jne   .Check_sDone_#Us
		mov   eax, dword[rsp+4*(8*Us+Pawn)]
	       test   eax, eax
		jnz   .Check_sDone_#Us
		mov   eax, dword[rsp+4*(8*Us+Queen)]
		cmp   eax, 1
		jne   .Check_sDone_#Us
		mov   eax, dword[rsp+4*(8*Them+Rook)]
		cmp   eax, 1
		jne   .Check_sDone_#Us
		mov   eax, dword[rsp+4*(8*Them+Pawn)]
	       test   eax, eax
		 jz   .Check_sDone_#Us
		mov   byte[rsi+MaterialEntry.scalingFunction+1*Us], 2*EndgameScale_KQKRPs_index+Us
.Check_sDone_#Us:
}



		mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
	       test   r14d, r14d
		jnz   .NotOnlyPawns
	       test   r15d, r15d
		jnz   .NotOnlyPawns
	       test   rax, rax
		 jz   .NotOnlyPawns
.OnlyPawns:
		mov   ecx, dword[rsp+4*(8*Black+Pawn)]
		mov   eax, ((0) shl 16) + ((2*EndgameScale_KPsK_index+White) shl 0)
	       test   ecx, ecx
		 jz   .OnlyPawnsWrite
		mov   edx, dword[rsp+4*(8*White+Pawn)]
		mov   eax, (((2*EndgameScale_KPsK_index+Black)) shl 8) + ((0) shl 0)
	       test   edx, edx
		 jz   .OnlyPawnsWrite
		xor   eax, eax
		cmp   ecx, 1
		jne   .OnlyPawnsWrite
		cmp   edx, 1
		jne   .OnlyPawnsWrite
		mov   eax, (((2*EndgameScale_KPKP_index+Black)) shl 8) + ((2*EndgameScale_KPKP_index+White) shl 0)
.OnlyPawnsWrite:
		mov   word[rsi+MaterialEntry.scalingFunction], ax  ; write both entries
.NotOnlyPawns:

		mov   eax, dword[rsp+4*(8*White+Pawn)]
	       test   eax, eax
		jnz   .P1
		mov   ecx, r14d
		sub   ecx, r15d
		cmp   ecx, BishopValueMg
		 jg   .P1
		mov   eax, 14
		mov   ecx, 4
		cmp   r15d, BishopValueMg
	     cmovle   eax, ecx
		mov   ecx, SCALE_FACTOR_DRAW
		cmp   r14d, RookValueMg
	      cmovl   eax, ecx
		mov   byte[rsi+MaterialEntry.factor+1*White], al
.P1:
		mov   eax, dword[rsp+4*(8*Black+Pawn)]
	       test   eax, eax
		jnz   .P2
		mov   ecx, r15d
		sub   ecx, r14d
		cmp   ecx, BishopValueMg
		 jg   .P2
		mov   eax, 14
		mov   ecx, 4
		cmp   r14d, BishopValueMg
	     cmovle   eax, ecx
		mov   ecx, SCALE_FACTOR_DRAW
		cmp   r15d, RookValueMg
	      cmovl   eax, ecx
		mov   byte[rsi+MaterialEntry.factor+1*Black], al
.P2:
		mov   eax, dword[rsp+4*(8*White+Pawn)]
		cmp   eax, 1
		jne   .P3
		mov   ecx, r14d
		sub   ecx, r15d
		cmp   ecx, BishopValueMg
		 jg   .P3
		mov   byte[rsi+MaterialEntry.factor+1*White], SCALE_FACTOR_ONEPAWN
.P3:
		mov   eax, dword[rsp+4*(8*Black+Pawn)]
		cmp   eax, 1
		jne   .P4
		mov   ecx, r15d
		sub   ecx, r14d
		cmp   ecx, BishopValueMg
		 jg   .P4
		mov   byte[rsi+MaterialEntry.factor+1*Black], SCALE_FACTOR_ONEPAWN
.P4:



		lea   r8, [rsp+4*0]	;  pieceCount[Us]
		lea   r9, [rsp+4*8]	;  pieceCount[Them]
		xor   eax, eax		; bonus
		xor   r15d, r15d
.ColorLoop:
		xor   r10d, r10d	; partial index into quadatic
		mov   r14d, 1
 .Piece1Loop:
		;mov   r11d, dword[DoMaterialEval_Data.Linear+4*r14]        ; v
		xor   r11d, r11d
		mov   r13d, 1

		cmp   dword[r8+4*r14], 0
		 je   .SkipPiece
  .Piece2Loop:
		mov   ecx, dword[DoMaterialEval_Data.QuadraticOurs+r10+4*r13]
	       imul   ecx, dword[r8+4*r13]
		add   r11d, ecx
		mov   ecx, dword[DoMaterialEval_Data.QuadraticTheirs+r10+4*r13]
	       imul   ecx, dword[r9+4*r13]
		add   r11d, ecx
		add   r13, 1
		cmp   r13d, r14d
		jbe   .Piece2Loop

		lea   edx, [2*r15-1]
	       imul   edx, dword[r8+4*r14]
	       imul   r11d, edx
		sub   eax, r11d
.SkipPiece:
		add   r14, 1
		add   r10d, 8*4
		cmp   r14d, Queen
		jbe   .Piece1Loop

	       xchg   r8, r9
		add   r15d, 1
		cmp   r15d, 2
		 jb   .ColorLoop

	; divide by 16, round towards zero
		cdq
		and   edx, 15
		add   eax, edx
		sar   eax, 4

		mov   word[rsi+MaterialEntry.value], ax
	      movzx   ecx, byte[rsi+MaterialEntry.evaluationFunction]

		add   rsp, 8*16
		pop   r15 r14 r13 r12
		jmp   Evaluate.DoMaterialEvalReturn


restore MinorBehindPawn
restore BishopPawns
restore RookOnPawn
restore TrappedRook
restore WeakQueen
restore OtherCheck
restore CloseEnemies
restore PawnlessFlank
restore LooseEnemies
restore ThreatByHangingPawn
restore ThreatByRank
restore Hanging
restore ThreatByPawnPush
restore HinderPassedPawn
