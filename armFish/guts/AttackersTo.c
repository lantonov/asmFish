
AttackersTo:
/*
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
*/
        lea  x16, PawnAttacks
        add  x16, x16, x1, lsl 3
        ldr  x0, [x16, KingAttacks-PawnAttacks]
        ldr  x4, [x20, 8*King]
        and  x0, x0, x4

        ldr  x8, [x16, KnightAttacks-PawnAttacks]
        ldr  x4, [x20, 8*Knight]
        and  x8, x8, x4
        orr  x0, x0, x8

        ldr  x8, [x16, WhitePawnAttacks-PawnAttacks]
        ldr  x4, [x20, 8*Black]
        and  x8, x8, x4
        ldr  x9, [x16, BlackPawnAttacks-PawnAttacks]
        ldr  x4, [x20, 8*White]
        and  x9, x9, x4
        orr  x8, x8, x9
        ldr  x4, [x20, 8*Pawn]
        and  x8, x8, x4
        orr  x0, x0, x8

        ldr  x5, [x20, 8*Queen]
        RookAttacks  x8, x1, x2, x9, x10
        ldr  x9, [x20, 8*Rook]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8
        BishopAttacks  x8, x1, x2, x9, x10
        ldr  x9, [x20, 8*Bishop]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8
        ret


AttackersTo_Side:
/*
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
*/
        ldr  x10, [x20, x1, lsl 3]
        eor  x4, x1, 1
        ldr  x11, [x20, x4, lsl 3]
        lsl  x1, x1, 6+3
        orr  x10, x10, x11
        
        lea  x16, PawnAttacks
        add  x16, x16, x2, lsl 3
        ldr  x0, [x16, KingAttacks-PawnAttacks]
        ldr  x4, [x20, 8*King]
        and  x0, x0, x4

        ldr  x8, [x16, KnightAttacks-PawnAttacks]
        ldr  x4, [x20, 8*Knight]
        and  x8, x8, x4
        orr  x0, x0, x8
        
        add  x16, x16, x1
        ldr  x8, [x16, WhitePawnAttacks-PawnAttacks]
        ldr  x4, [x20, 8*Pawn]
        and  x8, x8, x4
        orr  x0, x0, x8

        ldr  x5, [x20, 8*Queen]
        RookAttacks  x8, x2, x10, x9, x4
        ldr  x9, [x20, 8*Rook]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8

        BishopAttacks  x8, x2, x10, x9, x4
        ldr  x9, [x20, 8*Bishop]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8
        and  x0, x0, x11
        ret

