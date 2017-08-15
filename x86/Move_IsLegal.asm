
	     calign   16
Move_IsLegal:
	; in: rbp  address of Pos
	;     rbx  address of State - pinned member must be filled in
	;     ecx  move - assumed to pass IsMovePseudoLegal test
	; out: eax =  0 if move is not legal
	;      eax = -1 if move is legal

;ProfileInc Move_IsLegal

	       push   r13 r14 r15

		mov   edx, ecx
		shr   edx, 12
	; edx = move type

		mov   eax, ecx
		and   eax, 64*64-1
	; load next move

		mov   r15, qword[rbx+State.pinned]
		mov   r13d, dword[rbp+Pos.sideToMove]
		mov   r11, qword[rbp+Pos.typeBB+8*King]
		and   r11, qword[rbp+Pos.typeBB+8*r13]
		bsf   r14, r11
	; r14 = our king square
	; r11 = our king bitboard

		shr   ecx, 6
		and   ecx, 63
	; ecx = source square

;ProfileInc moveUnpack

	; pseudo legal castling moves are always legal
	; ep captures require special attention
		cmp   edx, MOVE_TYPE_EPCAP
		jae   .Special

	; if we are moving king, have to check destination square
		 bt   r11, rcx
		 jc   .KingMove

	; if piece is not pinned, then move is legal
		 bt   r15, rcx
		 jc   .CheckPinned
		 or   eax, -1
		pop   r15 r14 r13
		ret

	     calign   8
.CheckPinned:
	; if something is pinned, its movement should becaligned with our king
		and   r11, qword[LineBB+8*rax]
		neg   r11
		sbb   eax, eax
		pop   r15 r14 r13
		ret


	     calign   8
.KingMove:
	; if they have an attacker to king's destination square, then move is illegal
		and   eax, 63
		mov   ecx, r13d
		shl   ecx, 6+3
		mov   rcx, qword[PawnAttacks+rcx+8*rax]

		mov   r9, qword[rbp+Pos.typeBB+8*r13]
		xor   r13d, 1
		mov   r10, qword[rbp+Pos.typeBB+8*r13]
		 or   r9, r10
		xor   r13d, 1
	; pawn
		and   rcx, qword[rbp+Pos.typeBB+8*Pawn]
	       test   rcx, r10
		jnz   .Illegal
	; king
		mov   rdx, qword[KingAttacks+8*rax]
		and   rdx, qword[rbp+Pos.typeBB+8*King]
	       test   rdx, r10
		jnz   .Illegal
	; knight
		mov   rdx, qword[KnightAttacks+8*rax]
		and   rdx, qword[rbp+Pos.typeBB+8*Knight]
	       test   rdx, r10
		jnz   .Illegal
	; bishop + queen
      BishopAttacks   rdx, rax, r9, r8
		mov   r8, qword[rbp+Pos.typeBB+8*Bishop]
		 or   r8, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r10
	       test   rdx, r8
		jnz   .Illegal
	; rook + queen
	RookAttacks   rdx, rax, r9, r8
		mov   r8, qword[rbp+Pos.typeBB+8*Rook]
		 or   r8, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r10
	       test   rdx, r8
		jnz   .Illegal

.Legal:
		 or   eax, -1
		pop   r15 r14 r13
		ret


	     calign   8
.Illegal:
		xor   eax, eax
		pop   r15 r14 r13
		ret


	     calign   8
.Special:
	; pseudo legal castling moves are always legal
		cmp   edx, MOVE_TYPE_CASTLE
		jae   .Legal

.EpCapture:
	; for ep captures, just make the move and test if our king is attacked
		xor   r13d, 1
		mov   r10, qword[rbp+Pos.typeBB+8*r13]
		xor   r13d, 1
	; all pieces
		mov   rdx, qword[rbp+Pos.typeBB+8*White]
		 or   rdx, qword[rbp+Pos.typeBB+8*Black]
	; remove source square
		btr   rdx, rcx
	; add destination square (ep square)
		and   eax, 63
		bts   rdx, rax
	; get queens
		mov   r9, qword[rbp+Pos.typeBB+8*Queen]
	; remove captured pawn
		lea   ecx, [2*r13-1]
		lea   ecx, [rax+8*rcx]
		btr   rdx, rcx
	; check for rook attacks
	RookAttacks   rax, r14, rdx, r8
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, r9
		and   rcx, r10
	       test   rax, rcx
		jnz   .Illegal
	; check for bishop attacks
      BishopAttacks   rax, r14, rdx, r8
		mov   rcx, qword[rbp+Pos.typeBB+8*Bishop]
		 or   rcx, r9
		and   rcx, r10
	       test   rax, rcx
		jnz   .Illegal
		 or   eax, -1
		pop   r15 r14 r13
		ret
