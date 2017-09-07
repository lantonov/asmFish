
macro ShiftBB delta, b, t
  if delta = DELTA_N
            shl   b, 8
  else if delta = DELTA_S
            shr   b, 8
  else if delta = DELTA_NE
            mov   t, not FileHBB
            and   b, t
            shl   b, 9
  else if delta = DELTA_SE
            mov   t, not FileHBB
            and   b, t
            shr   b, 7
  else if delta = DELTA_NW
            mov   t, not FileABB
            and   b, t
            shl   b, 7
  else if delta = DELTA_SW
            mov   t, not FileABB
            and   b, t
            shr   b, 9
  else
    err 'delta in shift_bb strange'
  end if
end macro


macro attacks_from_pawn color, res, square
  if color = White
            mov   res, qword[WhitePawnAttacks+8*square]
  else if color = Black
            mov   res, qword[BlackPawnAttacks+8*square]
  else
    err 'color in attacks_from_pawn strange'
  end if
end macro



macro CastlingJmp Rights, JmpTrue, JmpFalse
	; in: rbp  address of Pos
	;     r13  their pieces
	;     r14  all pieces
	; out eax =  0 if castling is illegal
	;     eax = -1 if castling is legal
	; assumed to have passed path test and rights test
  local ksq_loop
            mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
             or   rax, qword[rbp+Pos.typeBB+8*King]
            and   rax, r13
           test   rax, qword[rbp-Thread.rootPos+Thread.castling_kingpawns+8*(Rights)]
            jnz   JmpFalse
            mov   rdx, qword[rbp+Pos.typeBB+8*Knight]
            and   rdx, r13
           test   rdx, qword[rbp-Thread.rootPos+Thread.castling_knights+8*(Rights)]
            jnz   JmpFalse
          movzx   r11d, byte[rbp-Thread.rootPos+Thread.castling_ksqpath+8*(Rights)]
            mov   r10, qword[rbp+Pos.typeBB+8*Rook]
             or   r10, qword[rbp+Pos.typeBB+8*Queen]
            and   r10, r13
            mov   r9, qword[rbp+Pos.typeBB+8*Bishop]
             or   r9, qword[rbp+Pos.typeBB+8*Queen]
            and   r9, r13
          movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rfrom+Rights]
            mov   rdx, r14
            btr   rdx, rax
    RookAttacks   rax, 56*(((Rights) and 2) shr 1)+(((Rights) and 1) xor 1)*(SQ_G1-SQ_C1)+SQ_C1, rdx, r8
           test   rax, r10
            jnz   JmpFalse
           test   r11d, r11d
             jz   JmpTrue
ksq_loop:
           movzx   edx, byte[rbp-Thread.rootPos+Thread.castling_ksqpath+8*(Rights)+r11]
     RookAttacks   rax, rdx, r14, r8
            test   rax, r10
             jnz   JmpFalse
   BishopAttacks   rax, rdx, r14, r8
            test   rax, r9
             jnz   JmpFalse
             sub   r11d, 1
             jnz   ksq_loop
end macro


macro generate_promotions Type, Delta, pon7, target
  local Outer, OuterDone, Inner, InnerDone
  if Type = QUIET_CHECKS
          movzx   eax, byte [rbx+State.ksq]
            xor   ecx, ecx
            bts   rcx, rax
  end if
            mov   rsi, pon7
        ShiftBB   Delta, rsi, rdx
            and   rsi, target
             jz   OuterDone
Outer:
            bsf   rdx, rsi
  if Type = CAPTURES | Type = EVASIONS | Type = NON_EVASIONS
           imul   eax, edx, 65
            add   eax, 64*64*(MOVE_TYPE_PROM+3) - 64*Delta
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
  end if
  if Type = QUIETS | Type = EVASIONS | Type = NON_EVASIONS
           imul   eax, edx, 65
            add   eax, 64*64*(MOVE_TYPE_PROM+2) - 64*Delta
            mov   dword[rdi+0*sizeof.ExtMove], eax
            sub   eax, 64*64*(1)
            mov   dword[rdi+1*sizeof.ExtMove], eax
            sub   eax, 64*64*(1)
            mov   dword[rdi+2*sizeof.ExtMove], eax
            lea   rdi, [rdi+3*sizeof.ExtMove]
  end if
  if Type = QUIET_CHECKS
           imul   eax, edx, 65
           test   rcx, qword[KnightAttacks+8*rdx]
             jz   InnerDone
            add   eax, 64*64*(MOVE_TYPE_PROM+0) - 64*Delta
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
  end if
InnerDone:
          _blsr   rsi, rsi, rax
            jnz   Outer
OuterDone:
end macro


; generate_pawn_jmp generates targets for uncommon operations in pawn move gen
;  first we have promotions
;  then ep captures
macro generate_pawn_jmp Us, Type
  local Them, TRank8BB, TRank7BB, TRank3BB, Up, Right, Left
  local b1, b2, eS, pawnsNotOn7, pawnsOn7, enemies
        b1 equ r8
        b2 equ r9
        eS equ r10
        pawnsNotOn7 equ r11
        pawnsOn7 equ r12
        enemies  equ r13
  if Us = White
	Them	 = Black
	TRank8BB = Rank8BB
	TRank7BB = Rank7BB
	TRank3BB = Rank3BB
	Up	 = DELTA_N
	Right	 = DELTA_NE
	Left	 = DELTA_NW
  else
	Them	 = White
	TRank8BB = Rank1BB
	TRank7BB = Rank2BB
	TRank3BB = Rank6BB
	Up	 = DELTA_S
	Right	 = DELTA_SW
	Left	 = DELTA_SE
  end if
	     calign   8
.CheckProm:

  if Type = CAPTURES
            mov   eS, r14
            not   eS
  else if Type = EVASIONS
            and   eS, r15
  end if
generate_promotions   Type, Right, pawnsOn7, enemies
generate_promotions   Type, Left, pawnsOn7, enemies
generate_promotions   Type, Up, pawnsOn7, eS
            jmp   .PromDone
  if Type = CAPTURES | Type = EVASIONS | Type = NON_EVASIONS
	     calign   8
.CaptureEp:
            bsf   rax, b1
            shl   eax, 6
             or   eax, edx
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   b1, b1, rcx
            jnz   .CaptureEp
            jmp   .CaptureEpDone
  end if
end macro


macro generate_pawn_moves Us, Type
  local Them, TRank8BB, TRank7BB, TRank3BB, Up, Right, Left
  local b1, b2, eS, pawnsNotOn7, pawnsOn7, enemies
  local SkipDCPawns, SinglePush, SinglePushDone, DoublePush, DoublePushDone
  local CaptureRight, CaptureRightDone, CaptureLeft, CaptureLeftDone

  if Us = White
	Them	 = Black
	TRank8BB = Rank8BB
	TRank7BB = Rank7BB
	TRank3BB = Rank3BB
	Up	 = DELTA_N
	Right	 = DELTA_NE
	Left	 = DELTA_NW
  else
	Them	 = White
	TRank8BB = Rank1BB
	TRank7BB = Rank2BB
	TRank3BB = Rank6BB
	Up	 = DELTA_S
	Right	 = DELTA_SW
	Left	 = DELTA_SE
  end if
        b1 equ r8
        b2 equ r9
        eS equ r10
        pawnsNotOn7 equ r11
        pawnsOn7 equ r12
        enemies  equ r13
            mov   rax, qword[rbp+Pos.typeBB+8*Pawn]
            and   rax, qword[rbp+Pos.typeBB+8*Us]
            mov   pawnsOn7, TRank7BB
          _andn   pawnsNotOn7, pawnsOn7, rax
            and   pawnsOn7, rax
  if Type = EVASIONS
            mov   enemies, qword[rbp+Pos.typeBB+8*Them]
            and   enemies, r15
  else if Type = CAPTURES
            mov   enemies, r15
  else
            mov   enemies, qword[rbp+Pos.typeBB+8*Them]
  end if
    ; Single and double pawn pushes, no promotions
  if Type <> CAPTURES
    if Type = QUIETS | Type = QUIET_CHECKS
            mov   eS, r15
    else
            mov   eS, r14
            not   eS
    end if
            mov   b1, pawnsNotOn7
        ShiftBB   Up, b1, rax
            and   b1, eS

            mov   b2, TRank3BB
            and   b2, b1
        ShiftBB   Up, b2, rax
            and   b2, eS
    if Type = EVASIONS
            and   b1, r15
            and   b2, r15
    end if
    if Type = QUIET_CHECKS
          movzx   edx, byte[rbx+State.ksq]
  attacks_from_pawn   Them, rax, rdx
            and   b1, rax
            and   b2, rax

            and   rdx, 7
            mov   rax, pawnsNotOn7
            mov   rcx, qword [FileBB+8*rdx]
          _andn   rcx, rcx, eS
            and   rax, qword[rbx+State.dcCandidates]
             jz   SkipDCPawns
        ShiftBB   Up, rax, rdx
            and   rax, rcx
            mov   rcx, TRank3BB
            and   rcx, rax
        ShiftBB   Up, rcx, rdx
            and   rcx, eS
             or   b1, rax
             or   b2, rcx
SkipDCPawns:
    end if
           test   b1, b1
             jz   SinglePushDone
SinglePush:
            bsf   rax, b1
           imul   eax, (1 shl 6) + (1 shl 0)
            sub   eax, (Up shl 6) + (0 shl 0)
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   b1, b1, rcx
            jnz   SinglePush
SinglePushDone:
           test   b2, b2
             jz   DoublePushDone
DoublePush:
            bsf   rax, b2
           imul   eax, (1 shl 6) + (1 shl 0)
            sub   eax, ((Up+Up) shl 6)
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   b2, b2, rcx
            jnz   DoublePush
DoublePushDone:
  end if
  if Type = EVASIONS
            mov   rax, TRank8BB
           test   pawnsOn7, pawnsOn7
             jz   .PromDone
           test   rax, r15
            jnz   .CheckProm
  else
            mov   rax, TRank8BB
           test   pawnsOn7, pawnsOn7
            jnz   .CheckProm
  end if
.PromDone:
  if Type = CAPTURES | Type = EVASIONS | Type = NON_EVASIONS
            mov   b1, pawnsNotOn7
            mov   b2, pawnsNotOn7
        ShiftBB   Right, b1, rax
        ShiftBB   Left, b2, rax
            and   b1, enemies
            and   b2, enemies
           test   b1, b1
             jz   CaptureRightDone
CaptureRight:
            bsf   rax, b1
           imul   eax, (1 shl 6) + (1 shl 0)
            sub   eax, (Right shl 6) + (0 shl 0)
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   b1, b1, rcx
            jnz   CaptureRight
CaptureRightDone:
           test   b2, b2
             jz   CaptureLeftDone
CaptureLeft:
            bsf   rax, b2
           imul   eax, (1 shl 6) + (1 shl 0)
            sub   eax, (Left shl 6) + (0 shl 0)
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
           _blsr   b2, b2, rcx
            jnz   CaptureLeft
CaptureLeftDone:
          movzx   edx, byte[rbx+State.epSquare]
            lea   eax, [rdx-Up]
            cmp   edx, 64
            jae   .CaptureEpDone
    if Type = EVASIONS
             bt   r15, rax
            jnc   .CaptureEpDone
    end if
  attacks_from_pawn   Them, b1, rdx
            or   edx, MOVE_TYPE_EPCAP shl 12
            and   b1, pawnsNotOn7
            jnz   .CaptureEp
.CaptureEpDone:
  end if
end macro


; generate moves Knight, Bishop, Rook, and Queen
macro generate_moves  Us, Pt, Checks
  local  Outer, OuterDone, Inner, InnerDone
            lea   r11, [rbp+Pos.pieceList+16*(8*Us+Pt)]
          movzx   edx, byte[r11]
            cmp   edx, 64
            jae   OuterDone
Outer:
  if Checks = QUIET_CHECKS
            mov   r10, qword[rbx+State.checkSq+8*Pt]
            mov   rsi, qword[rbx+State.dcCandidates]
    if Pt = Bishop
            mov   rax, qword[BishopAttacksPDEP+8*rdx]
            and   rax, r10
           test   rax, r15
             jz   InnerDone
    else if Pt = Rook
            mov   rax, qword[RookAttacksPDEP+8*rdx]
            and   rax, r10
           test   rax, r15
             jz   InnerDone
    else if Pt = Queen
            mov   rax, qword[BishopAttacksPDEP+8*rdx]
             or   rax, qword[RookAttacksPDEP+8*rdx]
            and   rax, r10
           test   rax, r15
             jz   InnerDone
    end if
             bt   rsi, rdx
             jc   InnerDone
    if  Pt = Knight
            mov   rsi, qword[KnightAttacks+8*rdx]
    else if Pt = Bishop
  BishopAttacks   rsi, rdx, r14, rax
    else if Pt = Rook
	RookAttacks   rsi, rdx, r14, rax
    else if Pt = Queen
  BishopAttacks   rsi, rdx, r14, rax
	RookAttacks   r9, rdx, r14, rax
             or   rsi, r9
    end if
  else
    if  Pt = Knight
            mov   rsi, qword[KnightAttacks+8*rdx]
    else if Pt = Bishop
  BishopAttacks   rsi, rdx, r14, rax
    else if Pt = Rook
	RookAttacks   rsi, rdx, r14, rax
    else if Pt = Queen
      BishopAttacks   rsi, rdx, r14, rax
	RookAttacks   r9, rdx, r14, rax
             or   rsi, r9
    end if

  end if
  if Checks = QUIET_CHECKS
            and   rsi, r10
  end if
            shl   edx, 6
            and   rsi, r15
             jz   InnerDone
Inner:
            bsf   rax, rsi
             or   eax, edx
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   rsi, rsi, rax
            jnz   Inner
InnerDone:
            add   r11, 1
          movzx   edx, byte[r11]
            cmp   edx, 64
             jb   Outer
OuterDone:
end macro


; generate_jmp generates targets for uncommon operations in move gen
; first we do castling and then generate_pawn_jmp

macro generate_jmp  Us, Type
  local CastlingOODone, CastlingOOGood, CastlingOOOGood
  local CheckOOQuiteCheck, CheckOOOQuiteCheck


  if Type <> CAPTURES & Type <> EVASIONS

         calign   8
.CastlingOO:
    if Type = NON_EVASIONS
    CastlingJmp   (2*Us+0), CastlingOOGood, CastlingOODone
CastlingOOGood:
            mov   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+0)]
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
    else
      if Us = White
           call   CastleOOLegal_White
      else
           call   CastleOOLegal_Black
      end if
      if Type eq QUIET_CHECKS
            mov   ecx, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+0)]
            mov   dword[rdi], ecx
           test   eax, eax
            jnz   CheckOOQuiteCheck
      else
            and   eax, sizeof.ExtMove
            mov   ecx, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+0)]
            mov   dword[rdi], ecx
            add   rdi, rax
      end if
    end if
CastlingOODone:
          movzx   eax, byte[rbx+State.castlingRights]
            mov   rcx, qword[rbp-Thread.rootPos+Thread.castling_path+8*(2*Us+1)]
            and   eax, 2 shl (2*Us)
            xor   eax, 2 shl (2*Us)
            and   rcx, r14
             or   rax, rcx
            jnz   .CastlingDone
.CastlingOOO:
    if Type = NON_EVASIONS
    CastlingJmp   (2*Us+1), CastlingOOOGood, .CastlingDone
CastlingOOOGood:
            mov   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+1)]
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
            jmp   .CastlingDone
    else
      if Us eq White
           call   CastleOOOLegal_White
      else if Us eq Black
           call   CastleOOOLegal_Black
      end if
      if Type eq QUIET_CHECKS
            mov   ecx, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+1)]
           test   eax, eax
            mov   dword[rdi], ecx
            jnz   CheckOOOQuiteCheck
            jmp   .CastlingDone
      else
            and   eax, sizeof.ExtMove
            mov   ecx, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*(2*Us+1)]
            mov   dword[rdi], ecx
            add   rdi, rax
            jmp   .CastlingDone
      end if
    end if
    if Type = QUIET_CHECKS
         calign   8
CheckOOQuiteCheck:
           call   Move_GivesCheck
            and   eax, 8
            add   rdi, rax
            jmp   CastlingOODone
         calign   8
CheckOOOQuiteCheck:
           call   Move_GivesCheck
            and   eax, 8
            add   rdi, rax
            jmp   .CastlingDone
    end if
  end if
  generate_pawn_jmp   Us, Type
end macro


macro generate_all  Us, Type
  local KingMoves, KingMovesDone
generate_pawn_moves   Us, Type
     generate_moves   Us, Knight, Type
     generate_moves   Us, Bishop, Type
     generate_moves   Us, Rook, Type
     generate_moves   Us, Queen, Type
  if Type <> CAPTURES & Type <> EVASIONS
          movzx   r9d, byte[rbx+State.castlingRights]
            mov   r10, qword[rbp-Thread.rootPos+Thread.castling_path+8*(2*Us+0)]
            mov   r11, qword[rbp-Thread.rootPos+Thread.castling_path+8*(2*Us+1)]
            and   r10, r14
            and   r11, r14
  end if
  if Type <> QUIET_CHECKS & Type <> EVASIONS
            mov   rsi, qword[rbp+Pos.typeBB+8*King]
            and   rsi, qword[rbp+Pos.typeBB+8*Us]
            bsf   rdx, rsi
            mov   rcx, qword[KingAttacks+8*rdx]
            shl   edx, 6
            and   rcx, r15
             jz   KingMovesDone
KingMoves:
            bsf   rax, rcx
             or   eax, edx
            mov   dword[rdi], eax
            lea   rdi, [rdi+sizeof.ExtMove]
          _blsr   rcx, rcx, r8
            jnz   KingMoves
KingMovesDone:
  end if
  if Type <> CAPTURES & Type <> EVASIONS
    ; check for castling; since this is rare, the castling functions are included in generate_jmp
            mov   edx, r9d
            and   r9d, 1 shl (2*Us)
            xor   r9d, 1 shl (2*Us)
            and   edx, 2 shl (2*Us)
            xor   edx, 2 shl (2*Us)
            mov   r13, qword[rbp+Pos.typeBB+8*(Us xor 1)]
             or   r9, r10
             jz   .CastlingOO
             or   rdx, r11
             jz   .CastlingOOO
.CastlingDone:
  end if
end macro
