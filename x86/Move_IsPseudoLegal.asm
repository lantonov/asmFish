
	     calign   16
Move_IsPseudoLegal:
	; in: rbp address of Pos
	;     rbx address of State
	;     ecx move
	; out: rax = 0 if move is not pseudo legal
	;      rax !=0 if move is pseudo legal      could be anything nonzero
	;
	;  we need to make sure the move is legal for the special types
	;    promotion
	;    castling
	;    epcapture
	;  so we also require checkinfo to be set

;ProfileInc Move_IsPseudoLegal

	       push   rsi rdi r12 r13 r14 r15

		mov   eax, dword[rbp+Pos.sideToMove]
		mov   esi, eax
		xor   eax, 1

	; r8d = from
	; r9d = to
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63
		mov   r9d, ecx
		and   r9d, 63

;ProfileInc moveUnpack

	; r11 = FROM PIECE
	      movzx   r11d, byte[rbp+Pos.board+r8]

	; r14 = bitboard of our pieces
	; r15 = bitboard of all pieces
		mov   r14, qword[rbp+Pos.typeBB+8*rsi]
		mov   r15, qword[rbp+Pos.typeBB+8*rax]
		 or   r15, r14

	; ecx = MOVE_TYPE
	; rdi = bitboard of to square r9d
	; r10 = -(MOVE_TYPE==0) & rdi
	; eax = move
		mov   eax, ecx
		shr   ecx, 12
		cmp   ecx, 1
		sbb   r10, r10
		xor   edi, edi
		bts   rdi, r9
		and   r10, rdi

	; r13 = checkers
	; r12 = -1 if checkers!=0
	;     =  0 if checkers==0
		mov   r12, qword[rbx+State.checkersBB]
		mov   r13, r12
		neg   r12
		sbb   r12, r12

	; make sure that our piece is on from square
		and   r11d, 7
		 bt   r14, r8
		jnc   .ReturnFalse

		cmp   ecx, MOVE_TYPE_PROM
		jae   .Special

	; make sure that we don't capture our own piece
		mov   eax, dword[.JmpTable+4*r11]
		 bt   r14, r9
		 jc   .ReturnFalse

		jmp   rax

             calign   8
.JmpTable:
		dd .NoPiece
		dd .NoPiece
		dd .Pawn
		dd .Knight
		dd .Bishop
		dd .Rook
		dd .Queen
		dd .King


	     calign   8
    .NoPiece:
    .ReturnFalse:
		xor   eax, eax
		pop   r15 r14 r13 r12 rdi rsi
		ret



	     calign   8
.Knight:
		mov   rax, qword[KnightAttacks+8*r8]
		and   rax, r10
	       test   rax, r12
		jnz   .Checkers
		pop   r15 r14 r13 r12 rdi rsi
		ret

	     calign   8
.Bishop:
      BishopAttacks   rax, r8, r15, r11
		and   rax, r10
	       test   rax, r12
		jnz   .Checkers
		pop   r15 r14 r13 r12 rdi rsi
		ret

	     calign   8
.Rook:
	RookAttacks   rax, r8, r15, r11
		and   rax, r10
	       test   rax, r12
		jnz   .Checkers
		pop   r15 r14 r13 r12 rdi rsi
		ret

	     calign   8
.Queen:
	RookAttacks   rax, r8, r15, r11
      BishopAttacks   r9, r8, r15, r11
		 or   rax, r9
		and   rax, r10
	       test   rax, r12
		jnz   .Checkers
		pop   r15 r14 r13 r12 rdi rsi
		ret

	     calign   8
.Checkers:
	; if moving P|R|B|Q and in check, filter some moves out
		mov   rcx, qword [rbp+Pos.typeBB+8*King]
		bsf   rax, r13
		shl   eax, 6+3
		and   rcx, r14
		bsf   rcx, rcx
		mov   rax, qword[BetweenBB+rax+8*rcx]
		 or   rax, r13

	; if more than one checker, must move king
		lea   rcx, [r13-1]
	       test   rcx, r13
		jnz   .ReturnFalse

	; move must be a blocking evasion or a capture of the checking piece
		and   rax, rdi

		pop   r15 r14 r13 r12 rdi rsi
		ret

	     calign  8
.Pawn:
		mov   r11d, esi
		shl   r11d, 6+3
		mov   rdx, 0x00FFFFFFFFFFFF00
		mov   eax, r8d
		xor   eax, r9d
		cmp   eax, 16
		 je   .DoublePawn
		xor   eax, eax
		xor   esi, 1
		lea   ecx, [2*rsi-1]
		lea   ecx, [r8+8*rcx]
		bts   rax, rcx
	      _andn   rax, r15, rax
		mov   rcx, [rbp+Pos.typeBB+8*rsi]
		and   rcx, qword[PawnAttacks+r11+8*r8]
		 or   rax, rcx
		and   rax, rdx

		and   rax, r10
	       test   rax, r12
		jnz   .Checkers

		pop   r15 r14 r13 r12 rdi rsi
		ret


	     calign   8
 .DoublePawn:
	; make sure that two squares are clear
		lea   eax, [r8+r9]
		shr   eax, 1
		mov   rdx, rdi
		bts   rdx, rax
	       test   rdx, r15
		jnz   .DPawnReturnFalse
	; make sure that from is on home
		mov   eax, r8d
		shr   eax, 3
		lea   ecx, [1+5*rsi]
		cmp   eax, ecx
		jne   .DPawnReturnFalse
		 or   eax, -1
	       test   r12, r12
		jnz   .Checkers
		pop   r15 r14 r13 r12 rdi rsi
		ret
    .DPawnReturnFalse:
		xor   eax, eax
		pop   r15 r14 r13 r12 rdi rsi
		ret



	     calign  8
.King:
		mov   r11d, esi
		shl   r11d, 6+3
		mov   rdx, qword[rbx+State.checkersBB]
		mov   rax, qword[KingAttacks+8*r8]
		and   rax, r10
	       test   rax, r12
		jnz   .KingCheckers
		pop   r15 r14 r13 r12 rdi rsi
		ret

		     calign   8
 .KingCheckers:
	; r14 = their pieces
	; r15 = pieces ^ our king
	      _andn   r14, r14, r15
		btr   r15, r8

		mov   rax, qword[KingAttacks+8*r9]
		and   rax, qword[rbp+Pos.typeBB+8*King]

		mov   rdx, qword[KnightAttacks+8*r9]
		and   rdx, qword[rbp+Pos.typeBB+8*Knight]
		 or   rax, rdx

		mov   rdx, qword[PawnAttacks+r11+8*r9]
		and   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rax, rdx

	RookAttacks   rdx, r9, r15, r10
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rdx, rcx
		 or   rax, rdx

      BishopAttacks   rdx, r9, r15, r10
		mov   rcx, qword[rbp+Pos.typeBB+8*Bishop]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rdx, rcx
		 or   rax, rdx

		and   rax, r14
		cmp   rax, 1
		sbb   eax, eax

		pop   r15 r14 r13 r12 rdi rsi
		ret


	     calign   8
.Special:
		cmp   ecx, MOVE_TYPE_EPCAP
		 je   .EpCapture
		jae   .Castle
.Promotion:

		cmp   r11d, Pawn
		jne   .ReturnFalse
		 bt   r14, r9
		 jc   .ReturnFalse

		mov   r11d, esi
		shl   r11d, 6+3

		lea   ecx, [rsi-1]
		xor   esi, 1
		and   ecx, 56
		mov   edx, 0x0FF
		shl   rdx, cl

		xor   eax, eax

		lea   ecx, [2*rsi-1]
		lea   ecx, [r8+8*rcx]
		bts   rax, rcx
	      _andn   rax, r15, rax
		mov   rcx, [rbp+Pos.typeBB+8*rsi]
		and   rcx, qword[PawnAttacks+r11+8*r8]
		 or   rax, rcx
		and   rax, rdx

		xor   esi, 1

		and   rax, rdi
		 jz   .ReturnFalse
	       test   rax, r12
		jnz   .PromotionCheckers

	; we are not in check so make sure pawn is not pinned

.PromotionCheckPinned:
		 or   eax, -1
		mov   rcx, qword[rbx+State.pinned]
		 bt   rcx, r8
		jnc   @f

		shl   r8d, 6+3
		mov   rax, qword[rbp+Pos.typeBB+8*King]
		and   rax, qword[rbp+Pos.typeBB+8*rsi]
		and   rax, qword[LineBB+r8+8*r9]
@@:
		pop   r15 r14 r13 r12 rdi rsi
		ret


.PromotionCheckers:
	; if moving P|R|B|Q and in check, filter some moves out
		mov   rcx, qword [rbp+Pos.typeBB+8*King]
		bsf   rax, r13
		shl   eax, 6+3
		and   rcx, r14
		bsf   rcx, rcx
		mov   rax, qword[BetweenBB+rax+8*rcx]
		 or   rax, r13

	; if more than one checker, must move king
		lea   rcx, [r13-1]
	       test   rcx, r13
		jnz   .ReturnFalse

	; move must be a blocking evasion or a capture of the checking piece
	       test   rax, rdi
		 jz   .ReturnFalse
		jmp   .PromotionCheckPinned




.EpCapture:

	; make sure destination is empty
		 bt   r15, r9
		 jc   .ReturnFalse

	; make sure that it is our pawn moving
		mov   eax, r11d
		and   eax, 7
		cmp   eax, Pawn
		jne   .ReturnFalse

	; make sure to is epsquare
		cmp   r9l, byte[rbx+State.epSquare]
		jne   .ReturnFalse

	; make sure from->to is a pawn attack
		mov   r11d, esi
		shl   r11d, 6+3
		mov   rax, qword[PawnAttacks+r11+8*r8]
		 bt   rax, r9
		jnc   .ReturnFalse

	; make sure capsq=r10=r9+pawnpush is their pawn
		lea   r10d, [2*rsi-1]
		lea   r10d, [r9+8*r10]
		xor   esi, 1
		lea   eax, [Pawn+8*rsi]
		cmp   al, byte[rbp+Pos.board+r10]
		jne   .ReturnFalse

	; rdi = ksq = square<KING>(us)
		mov   rdi, qword[rbp+Pos.typeBB+8*King]
		and   rdi, r14
		bsf   rdi, rdi

	; r15 = occupied = (pieces() ^ from ^ capsq) | to
		btr   r15, r8
		btr   r15, r10
		bts   r15, r9

	; r14 = their pieces
		mov   r14, qword[rbp+Pos.typeBB+8*rsi]

	; check for rook attacks
	RookAttacks   rax, rdi, r15, rdx
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, r14
	       test   rax, rcx
		jnz   .ReturnFalse

	; check for bishop attacks
      BishopAttacks   rax, rdi, r15, rdx
		mov   rcx, qword[rbp+Pos.typeBB+8*Bishop]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, r14
	       test   rax, rcx
		jnz   .ReturnFalse

		 or   eax, -1
		pop   r15 r14 r13 r12 rdi rsi
		ret





	     calign   8
.Castle:
	; CastlingJmp expects
	;     r13  their pieces
	;     r14  all pieces
	      _andn   r13, r14, r15
		mov   r14, r15
	       test   r12, r12
		jnz   .CastleReturnFalse
		cmp   ecx, MOVE_TYPE_CASTLE
		jne   .ReturnFalse
	       test   esi, esi
		jnz   .CastleBlack
.CastleWhite:
		cmp   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*0]
		 je   .CastleCheck_WhiteOO
		cmp   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*1]
		 je   .CastleCheck_WhiteOOO
.CastleReturnFalse:
		xor   eax, eax
		pop   r15 r14 r13 r12 rdi rsi
		ret
.CastleBlack:
		cmp   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*2]
		 je   .CastleCheck_BlackOO
		cmp   eax, dword[rbp-Thread.rootPos+Thread.castling_movgen+4*3]
		 je   .CastleCheck_BlackOOO
		jmp   .CastleReturnFalse



  .CastleCheck_WhiteOO:
	      movzx   eax, byte[rbx+State.castlingRights]
		mov   rcx, qword[rbp-Thread.rootPos+Thread.castling_path+8*0]
		and   rcx, r15
		and   eax, 1 shl 0
		xor   eax, 1 shl 0
		 or   rax, rcx
		jnz   .ReturnFalse
	       call   CastleOOLegal_White
		pop   r15 r14 r13 r12 rdi rsi
		ret

  .CastleCheck_BlackOO:
	      movzx   eax, byte[rbx+State.castlingRights]
		mov   rcx, qword[rbp-Thread.rootPos+Thread.castling_path+8*2]
		and   rcx, r15
		and   eax, 1 shl 2
		xor   eax, 1 shl 2
		 or   rax, rcx
		jnz   .CastleReturnFalse
	       call   CastleOOLegal_Black
		pop   r15 r14 r13 r12 rdi rsi
		ret


  .CastleCheck_WhiteOOO:
	      movzx   eax, byte[rbx+State.castlingRights]
		mov   rcx, qword[rbp-Thread.rootPos+Thread.castling_path+8*1]
		and   rcx, r15
		and   eax, 1 shl 1
		xor   eax, 1 shl 1
		 or   rax, rcx
		jnz   .CastleReturnFalse
	       call   CastleOOOLegal_White
		pop   r15 r14 r13 r12 rdi rsi
		ret

  .CastleCheck_BlackOOO:
	      movzx   eax, byte[rbx+State.castlingRights]
		mov   rcx, qword[rbp-Thread.rootPos+Thread.castling_path+8*3]
		and   rcx, r15
		and   eax, 1 shl 3
		xor   eax, 1 shl 3
		 or   rax, rcx
		jnz   .CastleReturnFalse
	       call   CastleOOOLegal_Black
		pop   r15 r14 r13 r12 rdi rsi
		ret
