
	     calign   16
AttackersTo:
	; in: ecx  square
	;     rdx  occlusion

		mov   rax, qword [KingAttacks+8*rcx]
		and   rax, qword [rbp+Pos.typeBB+8*King]

		mov   r8, qword [KnightAttacks+8*rcx]
		and   r8, qword [rbp+Pos.typeBB+8*Knight]
		 or   rax, r8

		mov   r8, qword [WhitePawnAttacks+8*rcx]
		and   r8, qword [rbp+Pos.typeBB+8*Black]
		mov   r9, qword [BlackPawnAttacks+8*rcx]
		and   r9, qword [rbp+Pos.typeBB+8*White]
		 or   r8, r9
		and   r8, qword [rbp+Pos.typeBB+8*Pawn]
		 or   rax, r8

		mov   r10d, ecx

	RookAttacks   r8, r10, rdx, r9
		mov   r9, qword [rbp+Pos.typeBB+8*Rook]
		 or   r9, qword [rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8

      BishopAttacks   r8, r10, rdx, r9
		mov   r9, qword [rbp+Pos.typeBB+8*Bishop]
		 or   r9, qword [rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8

		ret



	     calign  16

AttackersTo_Side:
	; in: ecx side
	;     edx square
	; out: rax  pieces on side ecx^1 that attack square edx

		mov   r10, qword[rbp+Pos.typeBB+8*rcx]
		xor   ecx,1
		mov   r11, qword[rbp+Pos.typeBB+8*rcx]
		xor   ecx, 1
		shl   ecx, 6+3
		 or   r10, r11

		mov   rax, qword[KingAttacks+8*rdx]
		and   rax, qword[rbp+Pos.typeBB+8*King]

		mov   r8, qword[KnightAttacks+8*rdx]
		and   r8, qword[rbp+Pos.typeBB+8*Knight]
		 or   rax, r8

		mov   r8, qword[WhitePawnAttacks+rcx+8*rdx]
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rax, r8

	RookAttacks   r8, rdx, r10, r9
		mov   r9, qword [rbp+Pos.typeBB+8*Rook]
		 or   r9, qword [rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8

      BishopAttacks   r8, rdx, r10, r9
		mov   r9, qword[rbp+Pos.typeBB+8*Bishop]
		 or   r9, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8

		and   rax, r11
		ret
