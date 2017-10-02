
MinorBehindPawn 	= (( 16 shl 16) + (  0))
BishopPawns		= ((  8 shl 16) + ( 12))
RookOnPawn		= ((  8 shl 16) + ( 24))
TrappedRook		= (( 92 shl 16) + (  0))
WeakQueen		= (( 50 shl 16) + ( 10))
OtherCheck		= (( 10 shl 16) + ( 10))
CloseEnemies		= ((  7 shl 16) + (  0))
PawnlessFlank		= (( 20 shl 16) + ( 80))
ThreatByHangingPawn	= (( 71 shl 16) + ( 61))
ThreatBySafePawn        = ((182 shl 16) + (175))
ThreatByRank		= (( 16 shl 16) + (  3))
Hanging 		= (( 48 shl 16) + ( 27))
ThreatByPawnPush	= (( 38 shl 16) + ( 22))
HinderPassedPawn	= ((  7 shl 16) + (  0))
LongRangedBishop        =  (22 shl 16)  +  0
TrappedBishopA1H1       =  (50 shl 16)  + 50


LazyThreshold = 1500


macro EvalInit Us
; in:  r13 rook + queen
;      r12 bishop+queen
;      r14 all pieces

  local Them, Down
  local NotUsed, PinnedLoop, NoPinned, YesPinned

  if Us = White
	Them = Black
	Down = DELTA_S
  else
	Them = White
	Down = DELTA_N
  end if


;	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi = ei.pi failed in EvalInit'

	      movzx   ecx, word[rbx+State.npMaterial+2*Us]

              movzx   eax, byte[rbp+Pos.pieceList+16*(8*Them+King)]
  if Them = White
                cmp   eax, SQ_A2
               setb   al
  else
                cmp   eax, SQ_A8
              setae   al
  end if

		mov   r9, qword[.ei.attackedBy+8*(8*Them+King)]
		 or   qword[.ei.attackedBy+8*(8*Them+0)], r9
		mov   r10, qword[rdi+PawnEntry.pawnAttacks+8*Us]
		mov   qword[.ei.attackedBy+8*(8*Us+Pawn)], r10
		 or   qword[.ei.attackedBy+8*(8*Us+0)], r10
	; rdx = b

		xor   r8, r8
		xor   edx, edx
		cmp   ecx, RookValueMg + KnightValueMg
		 jb   NotUsed
		mov   r8, r9
                neg   rax
	   ShiftBB   Down, r8
                and   r8, rax
		 or   r8, r9
		and   r9, r10
	    _popcnt   rdx, r9, rcx
                xor   eax, eax
		mov   dword[.ei.kingAttackersWeight+4*Us], eax
		mov   dword[.ei.kingAdjacentZoneAttacksCount+4*Us], eax
NotUsed:
		mov   qword[.ei.kingRing+8*Them], r8
		mov   dword[.ei.kingAttackersCount+4*Us], edx
		and   r10, qword[.ei.attackedBy+8*(8*Us+King)]
		mov   qword[.ei.attackedBy2+8*Us], r10
end macro



macro EvalPieces Us, Pt
	; in:  rbp address of Pos struct
	;      rbx address of State struct
	;      rsp address of evaluation info
	;      rdi address of PawnEntry struct
	; io:  esi score accumulated
	;
	; in: r13 all pieces
	;     r12 pieces of type Pt ( qword[rbp+Pos.typeBB+8*Pt])

  local addsub, subadd
  local Them, OutpostRanks

  local RookOnFile0, RookOnFile1
  local Outpost0, Outpost1, KingAttackWeight
  local MobilityBonus, ProtectorBonus

  local NextPiece, NoPinned, NoKingRing, AllDone
  local OutpostElse, OutpostDone, NoBehindPawnBonus
  local NoEnemyPawnBonus, NoOpenFileBonus, NoTrappedByKing
  local SkipQueenPin, QueenPinLoop

  if Us = White
	;addsub		  equ add
	;subadd		  equ sub
        macro addsub a, b
                add  a, b
        end macro
        macro subadd a, b
                sub  a, b
        end macro
	Them		  = Black
	OutpostRanks	  = 0x0000FFFFFF000000
  else
	;addsub		  equ sub
	;subadd		  equ add
        macro addsub a, b
                sub  a, b
        end macro
        macro subadd a, b
                add  a, b
        end macro
	Them		  = White
	OutpostRanks	  = 0x000000FFFFFF0000
  end if

	RookOnFile0	  = ((20 shl 16) + (7))
	RookOnFile1	  = ((45 shl 16) + (20))

  if Pt = Knight
	Outpost0	  = ((22 shl 16) + ( 6))
	Outpost1	  = ((36 shl 16) + (12))
	KingAttackWeight  = 78
	MobilityBonus	  equ MobilityBonus_Knight
        KingProtector_Pt  = ((-3 shl 16) + (-5))
  else if Pt = Bishop
	Outpost0	  = (( 9 shl 16) + (2))
	Outpost1	  = ((15 shl 16) + (5))
	KingAttackWeight  = 56
	MobilityBonus	  equ MobilityBonus_Bishop
        KingProtector_Pt  = ((-4 shl 16) + (-3))
  else if Pt = Rook
	KingAttackWeight  = 45
	MobilityBonus	  equ MobilityBonus_Rook
        KingProtector_Pt  = ((-3 shl 16) + (0))
  else if Pt = Queen
	KingAttackWeight  = 11
	MobilityBonus	  equ MobilityBonus_Queen
        KingProtector_Pt  = ((-1 shl 16) + (1))
  else
    err 'bad Pt in Eval Pieces'
  end if

;	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi=qword[.ei.pi] failed in EvalPieces'

		xor   eax, eax
		mov   qword[.ei.attackedBy+8*(8*Us+Pt)], rax

		mov   r11, qword[rbp+Pos.typeBB+8*Us]
	; r11 = our pieces
		lea   r15, [rbp+Pos.pieceList+16*(8*Us+Pt)]
	      movzx   r14d, byte[rbp+Pos.pieceList+16*(8*Us+Pt)]
		cmp   r14d, 64
		jae   AllDone
NextPiece:
		add   r15, 1

        ; r14 = square s


	; Find attacked squares, including x-ray attacks for bishops and rooks
  if Pt = Knight
		mov   r9, qword[KnightAttacks+8*r14]
  else if Pt = Bishop
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		and   rax, r11
		xor   rax, r13
      BishopAttacks   r9, r14, rax, rdx
  else if Pt = Rook
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		 or   rax, r12
		and   rax, r11
		xor   rax, r13
	RookAttacks   r9, r14, rax, rdx
  else if Pt = Queen
       QueenAttacks   r9, r14, r13, rax, rdx
  else
    err 'bad Pt in EvalPieces'
  end if

	; r9 = b
              movzx   r8d, byte[rbp+Pos.pieceList+16*(8*Us+King)]
	; r8d = our ksq

		mov   rax, qword[.ei.pinnedPieces+8*Us]
		 bt   rax, r14
		jnc   NoPinned	; 98.92%
		mov   eax, r8d
		shl   eax, 6+3
		and   r9, qword[LineBB+rax+8*r14]
NoPinned:
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
		 jz   NoKingRing	; 74.44%
		add   dword[.ei.kingAttackersCount+4*Us], 1
		add   dword[.ei.kingAttackersWeight+4*Us], KingAttackWeight
		mov   rax, qword[.ei.attackedBy+8*(8*Them+King)]
		and   rax, r9
	    _popcnt   rax, rax, rcx
		add   dword[.ei.kingAdjacentZoneAttacksCount+4*Us], eax
NoKingRing:

		mov   rax, qword[.ei.mobilityArea+8*Us]
		and   rax, r9
	    _popcnt   r10, rax, rcx
	     addsub   esi, dword[MobilityBonus+4*r10]

                lea   eax, [8*r8]
              movzx   eax, byte[SquareDistance+8*rax+r14]
               imul   eax, KingProtector_Pt
	     addsub   esi, eax


  if Pt = Knight | Pt = Bishop

	; Bonus when behind a pawn
    if Us = White
		cmp   r14d, SQ_A5
		jae   NoBehindPawnBonus
    else
		cmp   r14d, SQ_A5
		 jb   NoBehindPawnBonus
    end if
		mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
		lea   ecx, [r14+8*(Them-Us)]
		 bt   rax, rcx
                lea   eax, [rsi+MinorBehindPawn*(Them-Us)]
              cmovc   esi, eax
NoBehindPawnBonus:

	; Bonus for outpost squares
		mov   rax, OutpostRanks
		mov   rcx, qword[rdi+PawnEntry.pawnAttacksSpan+8*Them]
		mov   rdx, r11
	      _andn   rcx, rcx, rax
		mov   rax, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		 bt   rcx, r14
		jnc   OutpostElse
		lea   ecx, [rsi+2*Outpost1*(Them-Us)]
		add   esi, 2*Outpost0*(Them-Us)
		 bt   rax, r14
	      cmovc   esi, ecx
		jmp   OutpostDone
OutpostElse:
	      _andn   rdx, rdx, rcx
		and   rdx, r9
		 jz   OutpostDone
		lea   ecx, [rsi+Outpost1*(Them-Us)]
		add   esi, Outpost0*(Them-Us)
	       test   rdx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
	     cmovnz   esi, ecx
OutpostDone:

	; Penalty for pawns on the same color square as the bishop
    if Pt = Bishop
            xor  ecx, ecx
            mov  rax, DarkSquares
             bt  rax, r14
            adc  rcx, rdi
          movzx  eax, byte[rcx+PawnEntry.pawnsOnSquares+2*Us]
           imul  eax, BishopPawns
         subadd  esi, eax

            mov  rdx, qword[.ei.attackedBy + 8*(8*Them + Pawn)]
            mov  rax, 0x8142241818244281
            mov  rcx, (FileDBB or FileEBB) and (Rank4BB or Rank5BB)
          _andn  rax, rdx, rax
            lea  edx, [rsi + LongRangedBishop*(Them - Us)]
             bt  rax, r14
            jnc  @1f
            and  rcx, qword[BishopAttacksPDEP + 8*r14]
           test  rcx, qword[rbp + Pos.typeBB + 8*Pawn]
          cmovz  esi, edx
    @1:
    end if

    if PEDANTIC = 1 & Pt = Bishop
            lea  rdx, [rbp + Pos.board + r14]
            cmp  byte[rbp + Pos.chess960], 0
             je  @2f
            mov  rcx, DELTA_E + 8*(1-2*Us)
            cmp  r14d, SQ_A1 xor (56*Us)
             je  @1f
            mov  rcx, DELTA_W + 8*(1-2*Us)
            cmp  r14d, SQ_H1 xor (56*Us)
            jne  @2f
    @1:
            cmp  byte[rdx + rcx], 8*Us + Pawn
            jne  @2f
            mov  eax, 4*TrappedBishopA1H1
            cmp  byte[rdx + rcx + 8*(1-2*Us)], 0
            jne  @1f
            mov  eax, 2*TrappedBishopA1H1
            cmp  byte[rdx + rcx + rcx], 8*Us + Pawn
             je  @1f
            mov  eax, TrappedBishopA1H1
    @1:
         subadd  esi, eax
    @2:
    end if


  else if Pt = Rook

    if Us = White
		cmp   r14d, SQ_A5
		 jb   NoEnemyPawnBonus
    else
		cmp   r14d, SQ_A5
		jae   NoEnemyPawnBonus
    end if
		mov   rax, qword[rbp+Pos.typeBB+8*Them]
		and   rax, qword[rbp+Pos.typeBB+8*Pawn]
		and   rax, qword[RookAttacksPDEP+8*r14]
	    _popcnt   rax, rax, rcx
	       imul   eax, RookOnPawn
	     addsub   esi, eax
NoEnemyPawnBonus:

		mov   ecx, r14d
		and   ecx, 7
	      movzx   eax, byte[rdi+PawnEntry.semiopenFiles+1*Us]
	      movzx   edx, byte[rdi+PawnEntry.semiopenFiles+1*Them]
		 bt   eax, ecx
		jnc   NoOpenFileBonus
                lea   eax, [rsi+RookOnFile0*(Them-Us)]
                lea   esi, [rsi+RookOnFile1*(Them-Us)]
		 bt   edx, ecx
             cmovnc   esi, eax
		jmp   NoTrappedByKing
NoOpenFileBonus:

		mov   ecx, r14d
		and   ecx, 7
		mov   eax, r8d
		cmp   r10d, 4
		jae   NoTrappedByKing
		mov   edx, eax
		and   eax, 7
		sub   ecx, eax
		sub   eax, 4
		xor   ecx, eax
		 js   NoTrappedByKing
		mov   ecx, r8d
		and   ecx, 7
		mov   edx, ecx
		mov   eax, r14d
		and   eax, 7
		sub   ecx, eax
		sub   ecx, 1
		sar   ecx, 31
		sub   edx, ecx
		xor   eax, eax
		bts   eax, edx
		sub   eax, 1
		xor   eax, ecx
	       test   al, byte[rdi+PawnEntry.semiopenFiles+1*Us]
		jnz   NoTrappedByKing
	      movzx   eax, byte[rbx+State.castlingRights]
		and   eax, 3 shl (2*Us)
	       setz   al
		add   eax, 1
	       imul   r10d, 22*65536
		sub   r10d, TrappedRook
	       imul   r10d, eax
	     addsub   esi, r10d
NoTrappedByKing:

  else if Pt = Queen
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
		 jz   SkipQueenPin
		shl   r14d, 6+3
		bsf   rcx, rax
QueenPinLoop:
		mov   rcx, qword[BetweenBB+r14+8*rcx]
	      _blsr   rax, rax, r9
		and   rcx, r13
	      _blsr   r8, rcx, r9
		neg   r8
		sbb   r8, r8
	      _andn   rcx, r8, rcx
		 or   rdx, rcx
		bsf   rcx, rax
		jnz   QueenPinLoop
               test   rdx, r13
                lea   eax, [rsi+WeakQueen*(Us-Them)]
             cmovnz   esi, eax
SkipQueenPin:

  end if

	      movzx   r14d, byte[r15]
		cmp   r14d, 64
		 jb   NextPiece
AllDone:
end macro



macro EvalKing Us
	; in  rbp address of Pos struct
	;     rbx address of State struct
	;     rsp address of evaluation info
	; add/sub score to dword[.ei.score]

  local Them, Up, Camp
  local PiecesUs, PiecesThem
  local QueenCheck, RookCheck, BishopCheck, KnightCheck
  local AllDone, DoKingSafety, KingSafetyDoneRet
  local RookDone, BishopDone, KnightDone
  local NoKingSide, NoQueenSide, NoPawns

  if Us = White
	Them            = Black
	Up              = DELTA_N
	AttackedByUs    = r12
	AttackedByThem  = r13
	PiecesUs        = r14
	PiecesThem      = r15
	Camp            = Rank1BB or Rank2BB or Rank3BB or Rank4BB or Rank5BB
  else
	Them            = White
	Up              = DELTA_S
	AttackedByUs    = r13
	AttackedByThem  = r12
	PiecesUs        = r15
	PiecesThem      = r14
	Camp            = Rank4BB or Rank5BB or Rank6BB or Rank7BB or Rank8BB
  end if

	QueenCheck      = 780
	RookCheck       = 880
	BishopCheck     = 435
	KnightCheck	= 790

	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi=qword[.ei.pi] failed in EvalKing'
	     Assert   e, AttackedByUs, qword[.ei.attackedBy+8*(8*Us+0)], 'assertion AttackedByUs failed in EvalKing'
	     Assert   e, AttackedByThem, qword[.ei.attackedBy+8*(8*Them+0)], 'assertion AttackedByThem failed in EvalKing'
	     Assert   e, PiecesUs, qword[rbp+Pos.typeBB+8*Us], 'assertion PiecesUs failed in EvalKing'
	     Assert   e, PiecesThem, qword[rbp+Pos.typeBB+8*Them], 'assertion PiecesThem failed in EvalKing'

              movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Us+King)]

		mov   r11d, ecx
	; r11d = our king square
	      movzx   eax, byte[rbx+State.castlingRights]
	      movzx   edx, byte[rdi+PawnEntry.castlingRights]
		mov   esi, dword[rdi+PawnEntry.kingSafety+4*Us]
		cmp   cl, byte[rdi+PawnEntry.kingSquares+1*Us]
		jne   DoKingSafety	; 27.75%
		xor   eax, edx
	       test   eax, 3 shl (2*Us)
		jne   DoKingSafety	; 0.68%
KingSafetyDoneRet:

		mov   edi, dword[.ei.kingAttackersCount+4*Them]
              movzx   ecx, byte[rbp+Pos.pieceEnd+(8*Them+Queen)]
		and   ecx, 15
                add   ecx, edi

		mov   r8, qword[.ei.attackedBy2+8*Us]
	      _andn   r8, r8, qword[.ei.attackedBy+8*(8*Us+King)]
		and   r8, AttackedByThem
	; r8=kingOnlyDefended
		mov   r9, PiecesThem
		 or   r9, AttackedByUs
	      _andn   r9, r9, qword[.ei.kingRing+8*Us]
		and   r9, AttackedByThem
	; r9=undefended
                 or   r9, r8
	        cmp   ecx, 2
		 jb   AllDone

	       imul   edi, dword[.ei.kingAttackersWeight+4*Them]
	       imul   eax, dword[.ei.kingAdjacentZoneAttacksCount+4*Them], 102
		add   edi, eax

	    _popcnt   rax, r9, rcx
	       imul   eax, 191
		add   edi, eax
		mov   rdx, qword[.ei.pinnedPieces+8*Us]
		neg   rdx
		sbb   eax, eax
	        and   eax, 143
		add   edi, eax
	       test   PiecesThem, qword[rbp+Pos.typeBB+8*Queen]
		lea   eax, [rdi-848]
	      cmovz   edi, eax
	; the following does edi += - 5*mg_value(score)/8 + 40
		lea   ecx, [rsi+0x08000]
                add   edi, 40
		sar   ecx, 16
		lea   edx, [9*rcx]
		lea   eax, [9*rcx+7]
              cmovs   edx, eax
                sar   edx, 3
		sub   edi, edx
	; edi = kingDanger

		and   r8, qword[.ei.attackedBy2+8*Them]
              _andn   r8, r8, AttackedByUs
                 or   r8, PiecesThem
                not   r8
	; r8 = safe

		mov   r9, qword[rbp+Pos.typeBB+8*Pawn]
		mov   rax, PiecesThem
		and   rax, r9
	   ShiftBB   Up, r9
		and   r9, rax
		 or   r9, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		not   r9
	; r9 = other

		xor   PiecesUs, PiecesThem
	RookAttacks   r10, r11, PiecesUs, rax
	; r10 = b1 = pos.attacks_from<ROOK  >(ksq)
      BishopAttacks   rdx, r11, PiecesUs, rax
	; rdx = b1 = pos.attacks_from<BISHOP>(ksq)
		xor   PiecesUs, PiecesThem


	; Enemy queen safe checks
		mov   rax, r10
		 or   rax, rdx
		and   rax, qword[.ei.attackedBy+8*(8*Them+Queen)]
		and   rax, r8
		lea   ecx, [rdi+QueenCheck]
	     cmovnz   edi, ecx

	; For other pieces, also consider the square safe if attacked twice,
	; and only defended by a queen.
		mov   rax, PiecesThem
		 or   rax, qword[.ei.attackedBy2+8*Us]
		not   rax
		and   rax, qword[.ei.attackedBy+8*(8*Us+Queen)]
		and   rax, qword[.ei.attackedBy2+8*Them]
		 or   r8, rax
	; r8 = safe


		and   r10, qword[.ei.attackedBy+8*(8*Them+Rook)]
	; r10 = b1 & ei.attackedBy[Them][ROOK]
		and   rdx, qword[.ei.attackedBy+8*(8*Them+Bishop)]
	; rdx = b1 & ei.attackedBy[Them][BISHOP]
		mov   rcx, qword[KnightAttacks+8*r11]
		and   rcx, qword[.ei.attackedBy+8*(8*Them+Knight)]
	; rcx = b


	; Enemy rooks safe and other checks
	       test   r10, r8
		lea   eax, [rdi+RookCheck]
	     cmovnz   edi, eax
		jnz   RookDone
	       test   r10, r9
		lea   eax, [rsi-OtherCheck]
	     cmovnz   esi, eax
    RookDone:

	; Enemy bishops safe and other checks
	       test   rdx, r8
		lea   eax, [rdi+BishopCheck]
	     cmovnz   edi, eax
		jnz   BishopDone
	       test   rdx, r9
		lea   eax, [rsi-OtherCheck]
	     cmovnz   esi, eax
    BishopDone:

	; Enemy knights safe and other checks
	       test   rcx, r8
		lea   eax, [rdi+KnightCheck]
	     cmovnz   edi, eax
		jnz   KnightDone
	       test   rcx, r9
		lea   eax, [rsi-OtherCheck]
	     cmovnz   esi, eax
    KnightDone:


	; Compute the king danger score and subtract it from the evaluation
	       test   edi, edi
		 js   AllDone
                mov   eax, edi
                shr   eax, 4                ; kingDanger>=0 here
                sub   esi, eax
	       imul   edi, edi
		shr   edi, 12
		shl   edi, 16
		sub   esi, edi

		jmp   AllDone

DoKingSafety:
	; rdi = address of PawnEntry
              movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Us+King)]

	      movzx   eax, byte[rbx+State.castlingRights]
	      movzx   edx, byte[rdi+PawnEntry.castlingRights]
		and   eax, 3 shl (2*Us)
		and   edx, 3 shl (2*Them)
		add   edx, eax
		mov   byte[rdi+PawnEntry.kingSquares+1*Us], cl
		mov   byte[rdi+PawnEntry.castlingRights], dl

	       call   ShelterStorm#Us
		mov   esi, eax
		mov   ecx, SQ_G1 + Us*(SQ_G8-SQ_G1)
	       test   byte[rbx+State.castlingRights], 1 shl (2*Us+0)
		 jz   NoKingSide
	       call   ShelterStorm#Us
		cmp   esi, eax
	      cmovl   esi, eax
NoKingSide:
		mov   ecx, SQ_C1 + Us*(SQ_C8-SQ_C1)
	       test   byte[rbx+State.castlingRights], 1 shl (2*Us+1)
		 jz   NoQueenSide
	       call   ShelterStorm#Us
		cmp   esi, eax
	      cmovl   esi, eax
NoQueenSide:
		shl   esi, 16
	; esi = score
		lea   ecx, [8*r11]		; r11d = ksq
		lea   rcx, [DistanceRingBB+8*rcx]
		mov   rdi, qword[.ei.pi]	; clobbered by ShelterStorm
		mov   rdx, PiecesUs
		and   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		mov   dword[rdi+PawnEntry.kingSafety+4*Us], esi
		 jz   KingSafetyDoneRet
  iterate i, 0, 1, 2, 3, 4, 5, 6
		sub   esi, 16
		mov   dword[rdi+PawnEntry.kingSafety+4*Us], esi
	       test   rdx, qword[rcx+8*i]
		jnz   KingSafetyDoneRet
  end iterate
		sub   esi, 16
		mov   dword[rdi+PawnEntry.kingSafety+4*Us], esi
  if DEBUG
                and   rdx, qword[rcx+8*7]
	     Assert   ne, rdx, 0, 'assertion rdx !=0 failed in  DoKingSafety'
  end if
		jmp   KingSafetyDoneRet

AllDone:

		and   r11d, 7
		mov   r11, qword[KingFlank+8*r11]
	; r11 = KingFlank[kf]   ksq is not used anymore

		mov   rax, Camp
		and   rax, r11
		and   rax, AttackedByThem

		mov   rdi, qword[.ei.pi]	; we may have clobbered rdi with kingDanger

	       test   r11, qword[rbp+Pos.typeBB+8*Pawn]
		lea   ecx, [rsi-PawnlessFlank]
	      cmovz   esi, ecx		; pawnless flank

		mov   rdx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
		not   rdx
		and   rdx, qword[.ei.attackedBy2+8*Them]
		and   rdx, rax
  if Us eq White
		shl   rax, 4
  else
		shr   rax, 4
  end if
		 or   rax, rdx
	    _popcnt   rax, rax, r9
	       imul   eax, CloseEnemies
		sub   esi, eax		; king tropism

  if Us eq White
		add   dword[.ei.score], esi
  else
		sub   dword[.ei.score], esi
  end if
end macro



macro ShelterStorm Us
	; in: rbp position
	;     rbx state
	;     ecx ksq
	; out: eax saftey

  if Us = White
	Them		= Black
	Up		= DELTA_N
	PiecesUs	equ r14
	PiecesThem	equ r15
  else
	Them		= White
	Up		= DELTA_S
	PiecesUs	equ r15
	PiecesThem	equ r14
  end if

	MaxSafetyBonus = 258

	       push   rsi rdi r11 r12 r13


	     Assert   e, PiecesUs, qword[rbp+Pos.typeBB+8*Us], 'assertion PiecesUs failed in EvalPassedPawns'
	     Assert   e, PiecesThem, qword[rbp+Pos.typeBB+8*Them], 'assertion PiecesThem failed in EvalPassedPawns'

	; ecx = ksq
		mov   r13d, ecx
		shr   r13d, 3
		mov   r8, qword[InFrontBB+8*(8*Us+r13)]
		 or   r8, qword[RankBB+8*r13]
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
	; r8 = b
		mov   r9, PiecesUs
		and   r9, r8
	; r9 = ourPawns
		mov   r10, PiecesThem
		and   r10, r8
	; r10 = theirPawns
		mov   eax, MaxSafetyBonus
	; eax = saftey
	if Us eq Black
		xor   r13d, 7
	end if
		add   r13d, 1
	; r13d = relative_rank(Us, ksq)+1
		and   ecx, 7
	; ecx = file of ksq
		lea   r12d, [5*rcx]
		lea   r12d, [r12+8*rcx+2]
		shr   r12d, 4
	; r12d = max(FILE_B, min(FILE_G, ecx))-1


  macro ShelterStormAcc
    local AddStormDanger, TryNext

	if Us eq White
		xor   edx, edx
	else
		mov   edx, 7 shl 3
	end if


	if Us eq White
		mov   r8, qword[FileBB+8*r12]
		and   r8, r10
		bsf   rdi, r8
	      cmovz   edi, edx
		shr   edi, 3
	else
		mov   r8, qword[FileBB+8*r12]
		and   r8, r10
		bsr   rdi, r8
	      cmovz   edi, edx
		shr   edi, 3
		xor   edi, 7
	end if
	; edi = rkThem


	if Us eq White
		mov   r8, qword[FileBB+8*r12]
		and   r8, r9
		bsf   rsi, r8
	      cmovz   esi, edx
		shr   esi, 3
	else
		mov   r8, qword[FileBB+8*r12]
		and   r8, r9
		bsr   rsi, r8
	      cmovz   esi, edx
		shr   esi, 3
		xor   esi, 7
	end if
	; esi = rkUs


		mov   edx, r12d
		shl   edx, 3+2
	; ShelterWeakness and StormDanger are twice as big
	; to avoid an anoying min(f,FILE_H-f) in ShelterStorm


		add   esi, 1
	; esi = rkUs+1

		lea   r11, [StormDanger_BlockedByKing+rdx]
                lea   r8, [ShelterWeakness_No - 4*1 + rdx]
		cmp   ecx, r12d
		lea   r12d, [r12+1]
		jne   TryNext
                lea   r8, [ShelterWeakness_Yes - 4*1 + rdx]
		cmp   edi, r13d
		 je   AddStormDanger
	TryNext:
		lea   r11, [StormDanger_NoFriendlyPawn + rdx]
		cmp   esi, 1
		 je   AddStormDanger
		lea   r11, [StormDanger_BlockedByPawn + rdx]
		cmp   esi, edi
		 je   AddStormDanger
		lea   r11, [StormDanger_Unblocked + rdx]
	AddStormDanger:
		sub   eax, dword[r8 + 4*rsi]
		sub   eax, dword[r11 + 4*rdi]
  end macro

    ShelterStormAcc
    ShelterStormAcc
    ShelterStormAcc
                

		pop   r13 r12 r11 rdi rsi
		ret
end macro






macro EvalThreats Us
	; in: rbp position
	;     rbx state
	;     rsp evaluation info
	;     r10-r15 various bitboards
	; io: esi score accumulated

  local addsub, Them, Up, Left, Right
  local AttackedByUs, AttackedByThem, PiecesPawn, PiecesUs, PiecesThem
  local TRank2BB, TRank7BB
  local ThreatByKing0, ThreatByKing1
  local SafeThreatsDone, SafeThreatsLoop, WeakDone
  local ThreatMinorLoop, ThreatMinorDone, ThreatRookLoop, ThreatRookDone
  local ThreatMinorSkipPawn, ThreatRookSkipPawn

        ThreatByKing0   = (( 3 shl 16) + ( 62))
        ThreatByKing1   = (( 9 shl 16) + (138))

  if Us = White
	;addsub		equ add
        macro addsub a, b
                add  a, b
        end macro

	AttackedByUs	equ r12
	AttackedByThem	equ r13
	PiecesPawn	equ r11
	PiecesUs	equ r14
	PiecesThem	equ r15
	Them            = Black
	Up              = DELTA_N
	Left            = DELTA_NW
	Right           = DELTA_NE
	TRank2BB        = Rank2BB
	TRank7BB        = Rank7BB
  else
	;addsub		equ sub
        macro addsub a, b
                sub  a, b
        end macro
	AttackedByUs	equ r13
	AttackedByThem	equ r12
	PiecesPawn	equ r11
	PiecesUs	equ r15
	PiecesThem	equ r14
	Them		= White
	Up              = DELTA_S
	Left            = DELTA_SE
	Right           = DELTA_SW
	TRank2BB        = Rank7BB
	TRank7BB        = Rank2BB
  end if

	     Assert   e, PiecesPawn, qword[rbp+Pos.typeBB+8*Pawn], 'assertion PiecesPawn failed in EvalThreats'
	     Assert   e, AttackedByUs, qword[.ei.attackedBy+8*(8*Us+0)], 'assertion AttackedByUs failed in EvalThreats'
	     Assert   e, AttackedByThem, qword[.ei.attackedBy+8*(8*Them+0)], 'assertion AttackedByThem failed in EvalThreats'
	     Assert   e, PiecesUs, qword[rbp+Pos.typeBB+8*Us], 'assertion PiecesUs failed in EvalThreats'
	     Assert   e, PiecesThem, qword[rbp+Pos.typeBB+8*Them], 'assertion PiecesThem failed in EvalThreats'

		mov   r8, PiecesThem
		mov   r9, PiecesPawn
		and   r9, PiecesThem
		xor   r8, r9
		and   r8, qword[.ei.attackedBy+8*(8*Us+Pawn)]
	; r8 = weak
		 jz   SafeThreatsDone

		mov   r9, AttackedByThem
		not   r9
		 or   r9, AttackedByUs
		and   r9, PiecesUs
		and   r9, PiecesPawn
		mov   rdx, r9
	   ShiftBB   Right, r9, rcx
	   ShiftBB   Left, rdx, rcx
		 or   r9, rdx
		and   r9, r8
	; r9 = safeThreats
		xor   r8, r9
                lea   eax, [rsi + ThreatByHangingPawn*(Them-Us)]
             cmovnz   esi, eax

            _popcnt   rcx, r9, rax
               imul   ecx, ThreatBySafePawn
	     addsub   esi, ecx

SafeThreatsDone:

                mov   r9, qword[.ei.attackedBy2+8*Us]
              _andn   r9, r9, qword[.ei.attackedBy2+8*Them]
                 or   r9, qword[.ei.attackedBy+8*(8*Them+Pawn)]
        ; r9 = stronglyProtected
                mov   r8, PiecesPawn
              _andn   r8, r8, PiecesThem
                and   r8, r9
	; r8 = defended (= pos.pieces(Them) & ~pos.pieces(PAWN) & stronglyProtected)
	      _andn   r9, r9, PiecesThem
		and   r9, AttackedByUs
	; r9 = weak  (stronglyProtected variable is not used anymore)
		 or   r8, r9
	; r8 = defended | weak
		 jz   WeakDone


		mov   rax, qword[.ei.attackedBy+8*(8*Us+Knight)]
		 or   rax, qword[.ei.attackedBy+8*(8*Us+Bishop)]
		and   r8, rax
		 jz   ThreatMinorDone
ThreatMinorLoop:
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
	      _blsr   r8, r8, rcx
		jnz   ThreatMinorLoop
ThreatMinorDone:

		mov   rdx, PiecesThem
		and   rdx, qword[rbp+Pos.typeBB+8*Queen]
		 or   rdx, r9
		and   rdx, qword[.ei.attackedBy+8*(8*Us+Rook)]
		 jz   ThreatRookDone
ThreatRookLoop:
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

	      _blsr   rdx, rdx, rcx
		jnz   ThreatRookLoop
ThreatRookDone:

	      _andn   rax, AttackedByThem, r9
	    _popcnt   rax, rax, rcx
	       imul   eax, Hanging
	     addsub   esi, eax

		mov   rcx, qword[.ei.attackedBy+8*(8*Us+King)]
		and   rcx, r9
		mov   rdx, rcx
		neg   rdx
		sbb   edx, edx
	      _blsr   rcx, rcx, rax
		neg   rcx
		sbb   eax, eax
		and   eax, ThreatByKing1-ThreatByKing0
		add   eax, ThreatByKing0
		and   eax, edx
	     addsub   esi, eax

WeakDone:

        WeakUnopposedPawn = (5 shl 16) + 25

            mov  rcx, qword[rbp + Pos.typeBB + 8*Rook]
             or  rcx, qword[rbp + Pos.typeBB + 8*Queen]
          movzx  edx, byte[rdi + PawnEntry.weakUnopposed]
            mov  rax, not TRank7BB
            and  rax, PiecesUs
            and  rax, PiecesPawn
           test  rcx, PiecesUs
             jz  @1f
  if Us = White
            shr  edx, 4
  else
            and  edx, 0x0F
  end if
           imul  edx, WeakUnopposedPawn
         addsub  esi, edx
    @1:

            mov  r8, PiecesUs
             or  r8, PiecesThem

            mov  rcx, TRank2BB
            and  rcx, rax
        ShiftBB  Up, rcx
          _andn  rdx, r8, rcx
             or  rax, rdx
        ShiftBB  Up, rax

            mov  rdx, r8
            not  rdx
            and  rax, rdx
            mov  rcx, qword[.ei.attackedBy+8*(8*Them+Pawn)]
            not  rcx
            and  rax, rcx
            mov  rdx, AttackedByThem
            not  rdx
             or  rdx, AttackedByUs
            and  rax, rdx

            mov  rdx, rax
        ShiftBB  Left, rax, rcx
        ShiftBB  Right, rdx, rcx
             or  rax, rdx
            and  rax, PiecesThem
            mov  rcx, qword[.ei.attackedBy+8*(8*Us+Pawn)]
            not  rcx
            and  rax, rcx
        _popcnt  rax, rax, rdx
           imul  eax, ThreatByPawnPush
         addsub  esi, eax
end macro




macro EvalPassedPawns Us
	; in: rbp position
	;     rbx state
	;     rsp evaluation info
	;     r15 qword[rdi+PawnEntry.passedPawns+8*Us]
	; add to dword[.ei.score]

  local addsub, subadd, Them, Up, s, PiecesUs, PiecesThem
  local NextPawn, AllDone, AddToBonus, Continue
  local DoScaleDown, DontScaleDown

  if Us = White
	;addsub		equ add
	;subadd		equ sub
        macro addsub a, b
                add  a, b
        end macro
        macro subadd a, b
                sub  a, b
        end macro

	Them		equ Black
	Up		equ DELTA_N
	AttackedByUs	equ r12
	AttackedByThem	equ r13
	PiecesUs	equ r14
	PiecesThem	equ r15
  else
	;addsub		equ sub
	;subadd		equ add
        macro addsub a, b
                sub  a, b
        end macro
        macro subadd a, b
                add  a, b
        end macro

	Them		equ White
	Up		equ DELTA_S
	AttackedByUs	equ r13
	AttackedByThem	equ r12
	PiecesUs	equ r15
	PiecesThem	equ r14
  end if

;ProfileInc EvalPassedPawns

	     Assert   e, rdi, qword[.ei.pi], 'assertion rdi = ei.pi failed in EvalPassedPawns'
	     Assert   ne, r9, 0, 'assertion r9!=0 failed in EvalPassedPawns'
	     Assert   e, AttackedByUs, qword[.ei.attackedBy+8*(8*Us+0)], 'assertion AttackedByUs failed in EvalPassedPawns'
	     Assert   e, AttackedByThem, qword[.ei.attackedBy+8*(8*Them+0)], 'assertion AttackedByThem failed in EvalPassedPawns'
	     Assert   e, PiecesUs, qword[rbp+Pos.typeBB+8*Us], 'assertion PiecesUs failed in EvalPassedPawns'
	     Assert   e, PiecesThem, qword[rbp+Pos.typeBB+8*Them], 'assertion PiecesThem failed in EvalPassedPawns'

NextPawn:
		bsf   r8, r9
	      _blsr   r9, r9, rax

		mov   ecx,  r8d
		shr   ecx, 3
  if Us = Black
		xor   ecx, 7
  end if
	; ecx = r+1
		mov   esi, dword[PassedRank+4*rcx]
	; esi = (mbonus, ebonus)

		mov   rax, qword[ForwardBB+8*(64*Us+r8)]
		add   r8d, Up
	; r8d = blockSq
		mov   rdx, AttackedByThem
		 or   rdx, PiecesThem
		and   rax, rdx
	    _popcnt   rax, rax, r10
	       imul   eax, HinderPassedPawn
	     subadd   dword[.ei.score], eax

		lea   edi, [rcx-2]
		sub   ecx, 1
	       imul   edi, ecx
	; ecx = r
	; edi = rr = r*(r-1)


  if Us = White
		cmp   r8d, SQ_A4+Up
		 jb   Continue
  else
		cmp   r8d, SQ_A6+Up
		jae   Continue
  end if
	; at this point rr!=0


	; ecx is free because s = r8-Up
	s equ (r8-Up)

              movzx   eax, byte[rbp+Pos.pieceList+16*(8*Them+King)]
              movzx   edx, byte[rbp+Pos.pieceList+16*(8*Us+King)]
		shl   eax, 6
		shl   edx, 6
		xor   r10d, r10d
	      movzx   r11d, byte[SquareDistance+rdx+r8+Up]
	      movzx   eax, byte[SquareDistance+rax+r8]
	      movzx   edx, byte[SquareDistance+rdx+r8]
		lea   eax, [5*rax]
  if Us = White
		cmp   r8d, SQ_A7+Up
	      cmovb   r10d, r11d
  else
		cmp   r8d, SQ_A3+Up
	     cmovae   r10d, r11d
  end if
		lea   edx, [2*rdx+r10]
		sub   eax, edx
	       imul   eax, edi
		add   esi, eax

		mov   r10, qword[ForwardBB+8*(64*Us+s)]
		lea   eax, [rdi+2*rcx]
		 bt   PiecesUs, r8
		 jc   AddToBonus	; the pawn is blocked by us
		mov   r11, r10
		 bt   PiecesThem, r8
		 jc   Continue	; the pawn is blocked by them

		xor   PiecesThem, PiecesUs
	RookAttacks   rax, s, PiecesThem, rdx
		xor   PiecesThem, PiecesUs
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, qword[ForwardBB+8*(64*Them+s)]
		and   rax, rcx

		 or   rcx, -1
	       test   PiecesUs, rax
	      cmovz   rcx, AttackedByUs
		and   r10, rcx

		 or   rcx, -1
	       test   PiecesThem, rax
	      cmovz   rcx, AttackedByThem
		 or   rcx, PiecesThem
		and   r11, rcx

		 bt   r11, r8
		sbb   eax, eax
		neg   r11
		sbb   edx, edx
		lea   edx, [5*rdx]
		lea   eax, [rdx+4*rax+9]
	; eax = k/2
		xor   edx, edx
		 bt   r10, r8
		adc   edx, edx
		xor   r10, qword[ForwardBB+8*(64*Us+s)]
		cmp   r10, 1
		adc   edx, edx
		add   eax, edx
	; eax = k/2
		add   edi, edi
	       imul   eax, edi
AddToBonus:
	       imul   eax, 0x00010001
		add   esi, eax

Continue:		
	; r8d = blockSq

	; scale down bonus for candidate passers which need more than one pawn
	; push to become passed
		lea   ecx, [rsi+0x08000]
		sar   ecx, 16
	      movsx   eax, si
		mov   r10, qword[rbp+Pos.typeBB+8*Pawn]
               test   r10, qword[ForwardBB+8*(64*Us+s)]
                jnz   DoScaleDown
		and   r10, PiecesThem
	       test   r10, qword[PassedPawnMask+8*(r8+64*(Us))]
		 jz   DontScaleDown
DoScaleDown:
		cdq
		sub   eax, edx
		sar   eax, 1
	       xchg   eax, ecx
		cdq
		sub   eax, edx
		sar   eax, 1
		shl   eax, 16
		lea   esi, [rax+rcx]
DontScaleDown:

		and   r8d, 7
		add   esi, dword[PassedFile+4*r8]
	     addsub   dword[.ei.score], esi


	       test   r9, r9
		jnz   NextPawn

AllDone:
		mov   rdi, qword[.ei.pi]
end macro




macro EvalSpace Us
	; in: rbp position
	;     rbx state
	;     rdi qword[.ei.pi]
	;     r10-r15 various bitboards
	;     rsp evaluation info

  local addsub, Them, SpaceMask
  local AttackedByUs, AttackedByThem
  local PiecesPawn, PiecesAll, PiecesUs, PiecesThem

  if Us = White
	;addsub	       equ add
        macro addsub a, b
                add  a, b
        end macro

	AttackedByUs   equ r12
	AttackedByThem equ r13
	PiecesPawn     equ r11
	PiecesUs       equ r14
	PiecesThem     equ r15
	Them	       = Black
	SpaceMask      = ((FileCBB or FileDBB or FileEBB or FileFBB) \
			    and (Rank2BB or Rank3BB or Rank4BB))
  else
	;addsub	       equ sub
        macro addsub a, b
                sub  a, b
        end macro
	AttackedByUs   equ r13
	AttackedByThem equ r12
	PiecesPawn     equ r11
	PiecesUs       equ r15
	PiecesThem     equ r14
	Them	       = White
	SpaceMask      = ((FileCBB or FileDBB or FileEBB or FileFBB) \
			    and (Rank7BB or Rank6BB or Rank5BB))
  end if


	     Assert   e, PiecesPawn, qword[rbp+Pos.typeBB+8*Pawn], 'assertion PiecesPawn failed in EvalSpace'
	     Assert   e, AttackedByUs, qword[.ei.attackedBy+8*(8*Us+0)], 'assertion AttackedByUs failed in EvalSpace'
	     Assert   e, AttackedByThem, qword[.ei.attackedBy+8*(8*Them+0)], 'assertion AttackedByThem failed in EvalSpace'
	     Assert   e, PiecesUs, qword[rbp+Pos.typeBB+8*Us], 'assertion PiecesUs failed in EvalSpace'
	     Assert   e, PiecesThem, qword[rbp+Pos.typeBB+8*Them], 'assertion PiecesThem failed in EvalSpace'


		mov   rdx, PiecesUs
		and   rdx, PiecesPawn
	; rdx = pos.pieces(Us, PAWN)

	      _andn   rax, AttackedByUs, AttackedByThem
		 or   rax, qword[.ei.attackedBy+8*(8*Them+Pawn)]
		 or   rax, rdx
		mov   rcx, SpaceMask
	      _andn   rax, rax, rcx
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
	    _popcnt   rax, rax, rdx

	      movzx   ecx, byte[rdi+PawnEntry.openFiles]
		add   ecx, ecx
	    _popcnt   rdx, qword[rbp+Pos.typeBB+8*Us], r8
		sub   edx, ecx
	       imul   edx, edx

	       imul   eax, edx
		shr   eax, 4    ; eax>0 so division by 16 is easy
		shl   eax, 16

	     addsub   esi, eax
end macro



Evaluate_Cold:


virtual at rsp
 .ei EvalInfo
end virtual
	     calign   16
.DoPawnEval:
                mov   byte[rdi + PawnEntry.weakUnopposed], 0
                mov   qword[rbp+Pos.state], rbx
	  EvalPawns   White
		mov   dword[rdi+PawnEntry.score], esi
	  EvalPawns   Black
                mov   rbx, qword[rbp+Pos.state]
	      movzx   ecx, byte[rdi+PawnEntry.semiopenFiles+0]
	      movzx   eax, byte[rdi+PawnEntry.semiopenFiles+1]
		mov   r8, qword[rbx+State.pawnKey]
		mov   edx, ecx
		xor   ecx, eax
		and   edx, eax
		mov   eax, dword[rdi+PawnEntry.score]
		sub   eax, esi
	    _popcnt   rcx, rcx, r9
	    _popcnt   rdx, rdx, r9
		mov   qword[rdi+PawnEntry.key], r8
		mov   dword[rdi+PawnEntry.score], eax
		mov   byte[rdi+PawnEntry.asymmetry], cl
		mov   byte[rdi+PawnEntry.openFiles], dl
		jmp   Evaluate.DoPawnEvalReturn


.ReturnLazyEval:

;ProfileInc EvaluateLazy

		add   eax, 2*(LazyThreshold+1)
		mov   ecx, dword[rbp+Pos.sideToMove]
		neg   ecx
		cdq		     ; divide eax by 2
		sub   eax, edx	     ;
		sar   eax, 1	     ;
		xor   eax, ecx
		sub   eax, ecx
Display 2, "Lazy Eval returning %i0%n"
		add   rsp, sizeof.EvalInfo
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret


	     calign   16
ShelterStormWhite:
ShelterStorm0:
	ShelterStorm White


	     calign   16
ShelterStormBlack:
ShelterStorm1:
	ShelterStorm Black





	     calign   64
Evaluate:
	; in  rbp address of Pos struct
	;     rbx address of State struct
	; out eax evaluation

;ProfileInc Evaluate

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

		mov   r12, qword[rbp+Pos.typeBB+8*Queen]
		mov   r13, qword[rbp+Pos.typeBB+8*Rook]
		 or   r13, r12
		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
		 or   r12, qword[rbp+Pos.typeBB+8*Bishop]
		mov   esi, dword[rbp+Pos.sideToMove]

	      movzx   eax, byte[rbp+Pos.pieceList+16*(8*White+King)]
	      movzx   edx, byte[rbp+Pos.pieceList+16*(8*Black+King)]

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
	       ;imul   esi, sizeof.MaterialEntry
                shl   esi, 4
		add   rsi, qword[rbp+Pos.materialTable]
		mov   rdx, qword[rsi+MaterialEntry.key]
	      movsx   eax, word[rsi+MaterialEntry.value]
	      movzx   ecx, byte[rsi+MaterialEntry.evaluationFunction]
		mov   qword[.ei.me], rsi

		cmp   rdx, qword[rbx+State.materialKey]
        ;ProfileCond   ne, DoMaterialEval
		jne   DoMaterialEval	; 0.87%
.DoMaterialEvalReturn:
	       imul   eax, 0x00010001
		add   dword[.ei.score], eax
	       test   ecx, ecx
        ;ProfileCond   nz, HaveSpecializedEval
		jnz   HaveSpecializedEval

		mov   eax, dword[rdi+PawnEntry.score]
		cmp   r15, qword[rbx+State.pawnKey]
        ;ProfileCond   ne, DoPawnEval
		jne   Evaluate_Cold.DoPawnEval	 ; 6.34%
.DoPawnEvalReturn:
		add   eax, dword[.ei.score]
		mov   dword[.ei.score], eax


	; We have taken into account all cheap evaluation terms.
	; If score exceeds a threshold return a lazy evaluation.
	;  lazy eval is called about 5% of the time

	; checking if abs(a/2) > LazyThreshold
	; is the same as checking if a-2*(LazyThreshold+1)
	; is in the unsigned range [0,-4*(LazyThreshold+1)]
		lea   edx, [rax+0x08000]
		sar   edx, 16
	      movsx   eax, ax
		lea   eax, [rax+rdx-2*(LazyThreshold+1)]
		cmp   eax, 1-4*(LazyThreshold+1)
		 jb   Evaluate_Cold.ReturnLazyEval


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
	   ShiftBB   DELTA_S, rax
	   ShiftBB   DELTA_N, rdx
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
		and   r9, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rax, rcx
		 or   rdx, rsi
		and   rax, r8
		and   rdx, r9
              movzx   ecx, byte[rbp+Pos.pieceList+16*(8*White+King)]
	      movzx   esi, byte[rbp+Pos.pieceList+16*(8*Black+King)]
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


		mov   r14, qword[rbp+Pos.typeBB+8*White]
		mov   r15, qword[rbp+Pos.typeBB+8*Black]
		mov   r12, qword[.ei.attackedBy+8*(8*White+0)]
		mov   r13, qword[.ei.attackedBy+8*(8*Black+0)]


	; EvalKing adds to dword[.ei.score]
		mov   dword[.ei.score], esi
	   EvalKing   Black
	   EvalKing   White

	; EvalPassedPawns adds to dword[.ei.score]
		mov   r9, qword[rdi+PawnEntry.passedPawns+8*White]
	       test   r9, r9
		jnz   Evaluate_Cold2.EvalPassedPawns0
		mov   r9, qword[rdi+PawnEntry.passedPawns+8*Black]
	       test   r9, r9
		jnz   Evaluate_Cold2.EvalPassedPawns1
.EvalPassedPawnsRet:
		mov   esi, dword[.ei.score]

	; EvalThreats, EvalSpace add to esi
	; EvalPassedPawns and EvalThreats are switched because
	;    EvalThreats and EvalSpace share r10-r15
		mov   r11, qword[rbp+Pos.typeBB+8*Pawn]
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

		mov   r14, rdi
		mov   r15, qword[.ei.me]

	; Evaluate position potential for the winning side

                mov   r8, FileABB or FileBBB or FileCBB or FileDBB
                mov   rcx, FileEBB or FileFBB or FileGBB or FileHBB
                and   r8, r11
                and   rcx, r11
                mov   eax, 16
                neg   r8
                sbb   r8, r8
                and   r8, rcx
             cmovnz   r8d, eax

	    _popcnt   rax, r11, rcx
	      movzx   edx, byte[rdi+PawnEntry.asymmetry]
		lea   edx, [rdx+rax-17]
		lea   r8d, [r8+4*rax]
                lea   r8d, [r8+8*rdx]

	      movsx   r9d, si
		sar   r9d, 31
              movsx   edi, si
                sub   esi, r9d
                xor   edi, r9d
                sub   edi, r9d
                neg   edi

              movzx   eax, byte[rbp+Pos.pieceList+16*(8*White+King)]
              movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Black+King)]
		and   eax, 0111000b
		and   ecx, 0111000b
		sub   eax, ecx
		cdq
		xor   eax, edx
		sub   eax, edx
		sub   r8d, eax

              movzx   eax, byte[rbp+Pos.pieceList+16*(8*White+King)]
              movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Black+King)]
		and   eax, 7
		and   ecx, 7
		sub   eax, ecx
		cdq
		xor   eax, edx
		sub   eax, edx
		lea   eax, [r8+8*rax]
        ; eax = initiative

		cmp   eax, edi
	      cmovl   eax, edi
	       test   edi, edi
	      cmovz   r9d, eax
		xor   eax, r9d
		add   esi, eax

	; esi = score
	; r14 = ei.pi
	; Evaluate scale factor for the winning side

	      movsx   r12d, si
		lea   r13d, [r12-1]
		shr   r13d, 31

	      movzx   ecx, byte[r15+MaterialEntry.scalingFunction+r13]
	      movzx   eax, byte[r15+MaterialEntry.factor+r13]
	      movzx   edx, byte[r15+MaterialEntry.gamePhase]
		add   esi, 0x08000
		sar   esi, 16
	       test   ecx, ecx
		jnz   Evaluate_Cold2.HaveScaleFunction	      ; 1.98%
.HaveScaleFunctionReturn:
		lea   ecx, [rax-48]
		mov   r10, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r8, qword[rbp+Pos.typeBB+8*White]
		mov   r9, qword[rbp+Pos.typeBB+8*Black]
		mov   edi, dword[rbx+State.npMaterial]
		and   r8, r10
		and   r9, r10
	       test   ecx, not 16
		jnz   .ScaleFactorDone
	      _blsr   r8, r8, rcx
	      _blsr   r9, r9, rcx
		mov   r11, qword[rbp+Pos.typeBB+8*Pawn]
		mov   rcx, DarkSquares
	       test   rcx, r10
		 jz   .NotOppBishop
		mov   rcx, LightSquares
	       test   rcx, r10
		 jz   .NotOppBishop
		 or   r8, r9
		jnz   .NotOppBishop
	      _blsr   rcx, r11, r8
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
                shl   r13, 4+3
              movzx   r9d, byte[rbp+Pos.pieceList+16*(King)+r13]
                lea   r8, [PassedPawnMask+4*r13]
	       test   r11, qword[r8+8*r9]
		 jz   .ScaleFactorDone
	    _popcnt   rcx, r11, r9
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
Display 2, "Evaluate returning %i0%n"
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
Display 2, "Scale returned %i0%n"
		cmp   eax, SCALE_FACTOR_NONE
	      movzx   edx, byte[r15+MaterialEntry.gamePhase]
	      movzx   ecx, byte[r15+MaterialEntry.factor+r13]
	      cmove   eax, ecx
		jmp   Evaluate.HaveScaleFunctionReturn

	     calign   16
.EvalPassedPawns0:
    EvalPassedPawns   White
		mov   r9, qword[rdi+PawnEntry.passedPawns+8*Black]
	       test   r9, r9
		 jz   Evaluate.EvalPassedPawnsRet
	     calign   8
.EvalPassedPawns1:
    EvalPassedPawns   Black
		jmp   Evaluate.EvalPassedPawnsRet



HaveSpecializedEval:
		mov   eax, ecx
		shr   eax, 1
		mov   eax, dword[EndgameEval_FxnTable+4*rax]
		and   ecx, 1
	       call   rax
Display 2, "Special Eval returned %i0%n"
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
	      _blsr   rdx, r8
		jnz   .Try_KXK_Black
		cmp   r14d, RookValueMg
		jge   .FoundEvalFxn
.Try_KXK_Black:
		add   ecx, 1
	      _blsr   rdx, r9
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
	    _popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Pawn)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Knight]
		and   rax, rdx
	    _popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Knight)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Bishop]
		and   rax, rdx
	    _popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Bishop)], eax
		cmp   eax, 2
		sbb   eax, eax
		add   eax, 1
		mov   dword[rsp+4*(r8+1)], eax		    ; bishop pair
		mov   rax, qword[rbp+Pos.typeBB+8*Rook]
		and   rax, rdx
	    _popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Rook)], eax
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		and   rax, rdx
	    _popcnt   rax, rax, rcx
		mov   dword[rsp+4*(r8+Queen)], eax

		add   r8d, 8
		cmp   r8d, 16
		 jb   .CountLoop

iterate Us, White, Black
  if Us = White
	Them	 equ Black
	npMat	 equ r14d
  else
	Them	 equ White
	npMat	 equ r15d
  end if

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
end iterate



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
		mov   eax, dword[r8+4*Pawn]
                mov   eax, dword[PawnsSet+4*rax]
		mov   ecx, dword[r9+4*Pawn]
                mov   ecx, dword[PawnsSet+4*rcx]
                sub   eax, ecx
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

        ; Special handling of Queen vs. Minors
                mov   edx, [r8+4*Queen]
                sub   edx, 1
                mov   ecx, [r9+4*Knight]
                 or   edx, [r9+4*Queen]
                jnz   .NoQueenImbalance
                add   ecx, [r9+4*Bishop]
		lea   edx, [2*r15-1]
               imul   edx, dword[QueenMinorsImbalance+4*rcx]
                sub   eax, edx
.NoQueenImbalance:

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
restore ThreatByHangingPawn
restore ThreatByRank
restore Hanging
restore ThreatByPawnPush
restore HinderPassedPawn

restore LazyThreshold
