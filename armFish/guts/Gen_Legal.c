
Gen_Legal:
/*
	; in rbp address of position
	;    rbx address of state
	; io rdi address to write moves

	       push   rsi r12 r13 r14 r15

	; generate moves
		mov   rax, qword[rbx+State.checkersBB]
		mov   rsi, rdi
		mov   r15, qword[rbx+State.pinned]
		mov   r13d, dword[rbp+Pos.sideToMove]
		mov   r12, qword[rbp+Pos.typeBB+8*King]
		and   r12, qword[rbp+Pos.typeBB+8*r13]
		bsf   r14, r12
	; r15  = pinned pieces
	; r14d = our king square
	; r13d = side
	; r12 = our king bitboard
*/
        stp  x22, x23, [sp, -16]!
        stp  x24, x25, [sp, -16]!
        stp  x26, x30, [sp, -16]!

//Display "Gen_Legal called\n"

        ldr  x0, [x21, State.checkersBB]
        mov  x26, x27
        ldr  x25, [x21, State.pinned]
        ldr  w23, [x20, Pos.sideToMove]
        ldr  x22, [x20, 8*King]
        ldr  x4, [x20, x23, lsl 3]
        and  x22, x22, x4
       rbit  x24, x22
        clz  x24, x24        
/*
	       test   rax, rax
		jnz   .InCheck
.NotInCheck:   call   Gen_NonEvasions
		jmp   .GenDone
.InCheck:      call   Gen_Evasions
.GenDone:
		shl   r14d, 6
		mov   edx, dword[rsi]
		mov   ecx, edx
		mov   eax, edx
		cmp   rsi, rdi
		 je   .FilterDone
	       test   r15, r15
		jne   .FilterYesPinned
*/
       cbnz  x0, Gen_Legal.InCheck
Gen_Legal.NotInCheck:
         bl  Gen_NonEvasions
          b  Gen_Legal.GenDone
Gen_Legal.InCheck:
         bl  Gen_Evasions
Gen_Legal.GenDone:
        lsl  x24, x24, 6
        ldr  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        beq  Gen_Legal.FilterDone

Gen_Legal.FilterNoPinned:
/*
		and   ecx, 0x0FC0    ; ecx shr 6 = source square
		add   rsi, sizeof.ExtMove
		cmp   ecx, r14d
		 je   .KingMove
		cmp   edx, MOVE_TYPE_EPCAP shl 12
		jae   .EpCapture
		mov   edx, dword[rsi]
		mov   ecx, edx	 ; move is legal at this point
		mov   eax, edx
		cmp   rsi, rdi
		jne   .FilterNoPinned
*/
        and  w1, w1, 0x0FC0
        add  x26, x26, sizeof.ExtMove
        cmp  w1, w24
        beq  Gen_Legal.KingMove
        cmp  w2, MOVE_TYPE_EPCAP << 12
        bhs  Gen_Legal.EpCapture
        ldr  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        bne  Gen_Legal.FilterNoPinned

Gen_Legal.FilterDone:
/*
		pop   r15 r14 r13 r12 rsi
		ret
*/
        ldp  x26, x30, [sp], 16
        ldp  x24, x25, [sp], 16
        ldp  x22, x23, [sp], 16
        ret

Gen_Legal.KingMove:
/*
	; if they have an attacker to king's destination square, then move is illegal
		and   eax, 63	; eax = destination square
		mov   ecx, r13d
		shl   ecx, 6+3
		mov   rcx, qword[PawnAttacks+rcx+8*rax]
*/
        and  x0, x0, 63
        lea  x7, PawnAttacks
        add  x7, x7, x23, lsl 9
        ldr  x1, [x7, x0, lsl 3]        
/*
	; pseudo legal castling moves are always legal  ep captures have already been caught
		cmp   edx, MOVE_TYPE_CASTLE shl 12
		jae   .FilterLegalChoose
*/
        cmp  w2, MOVE_TYPE_CASTLE << 12
        bhs  Gen_Legal.FilterLegalChoose
/*
		mov   r9, qword[rbp+Pos.typeBB+8*r13]
		xor   r13d, 1
		mov   r10, qword[rbp+Pos.typeBB+8*r13]
		 or   r9, r10
		xor   r13d, 1
*/
        ldr  x9, [x20, x23, lsl 3]
        eor  x4, x23, 1
        ldr  x10, [x20, x23, lsl 3]
        orr  x9, x9, x10
/*
	; pawn
		and   rcx, qword[rbp+Pos.typeBB+8*Pawn]
	       test   rcx, r10
		jnz   .FilterIllegalChoose
*/
        ldr  x4, [x20, 8*Pawn]
        and  x1, x1, x4
        tst  x1, x10
        bne  Gen_Legal.FilterIllegalChoose
/*
	; king
		mov   rdx, qword[KingAttacks+8*rax]
		and   rdx, qword[rbp+Pos.typeBB+8*King]
	       test   rdx, r10
		jnz   .FilterIllegalChoose
*/
        lea  x7, KingAttacks
        ldr  x2, [x7, x0, lsl 3]
        ldr  x4, [x20, 8*King]
        and  x2, x2, x4
        tst  x2, x10
        bne  Gen_Legal.FilterIllegalChoose
/*
	; knight
		mov   rdx, qword[KnightAttacks+8*rax]
		and   rdx, qword[rbp+Pos.typeBB+8*Knight]
	       test   rdx, r10
		jnz   .FilterIllegalChoose
*/
        lea  x7, KnightAttacks
        ldr  x2, [x7, x0, lsl 3]
        ldr  x4, [x20, 8*Knight]
        and  x2, x2, x4
        tst  x2, x10
        bne  Gen_Legal.FilterIllegalChoose
/*
	; bishop + queen
      BishopAttacks   rdx, rax, r9, r8
		mov   r8, qword[rbp+Pos.typeBB+8*Bishop]
		 or   r8, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r10
	       test   rdx, r8
		jnz   .FilterIllegalChoose
*/
        BishopAttacks  x2, x0, x9, x8, x4
        ldr  x8, [x20, 8*Bishop]
        ldr  x4, [x20, 8*Queen]
        orr  x8, x8, x4
        and  x8, x8, x10
        tst  x2, x8
        bne  Gen_Legal.FilterIllegalChoose
/*
	; rook + queen
	RookAttacks   rdx, rax, r9, r8
		mov   r8, qword[rbp+Pos.typeBB+8*Rook]
		 or   r8, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r10
	       test   rdx, r8
		jnz   .FilterIllegalChoose
*/
        RookAttacks  x2, x0, x9, x8, x4
        ldr  x8, [x20, 8*Rook]
        ldr  x4, [x20, 8*Queen]
        orr  x8, x8, x4
        and  x8, x8, x10
        tst  x2, x8
        bne  Gen_Legal.FilterIllegalChoose
Gen_Legal.FilterLegalChoose:
/*
		mov   edx, dword[rsi]
		mov   ecx, edx	 ; move is legal at this point
		mov   eax, edx
		cmp   rsi, rdi
		 je   .FilterDone
	       test   r15, r15
		 jz   .FilterNoPinned
		jmp   .FilterYesPinned
*/
        ldr  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        beq  Gen_Legal.FilterDone
        cbz  x25, Gen_Legal.FilterNoPinned
          b  Gen_Legal.FilterYesPinned

Gen_Legal.FilterIllegalChoose:
/*
		sub   rdi, sizeof.ExtMove
		sub   rsi, sizeof.ExtMove
		mov   edx, dword [rdi]
		mov   dword [rsi], edx
		mov   ecx, edx	 ; move is legal at this point
		mov   eax, edx
		cmp   rsi, rdi
		 je   .FilterDone
	       test   r15, r15
		 jz   .FilterNoPinned

*/
        sub  x27, x27, sizeof.ExtMove
        sub  x26, x26, sizeof.ExtMove
        ldr  w2, [x27]
        str  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        beq  Gen_Legal.FilterDone
        cbz  x25, Gen_Legal.FilterNoPinned

Gen_Legal.FilterYesPinned:
/*
		and   ecx, 0x0FC0    ; ecx shr 6 = source square
		add   rsi, sizeof.ExtMove
		cmp   ecx, r14d
		 je   .KingMove
		cmp   edx, MOVE_TYPE_EPCAP shl 12
		jae   .EpCapture
		shr   ecx, 6
		and   eax, 0x0FFF
		 bt   r15, rcx
		 jc   .FilterYesPinnedWeArePinned
*/
        and  w1, w1, 0x0FC0
        add  x26, x26, sizeof.ExtMove
        cmp  w1, w24
        beq  Gen_Legal.KingMove
        cmp  w2, MOVE_TYPE_EPCAP << 12
        bhs  Gen_Legal.EpCapture
        lsr  w1, w1, 6
        and  w0, w0, 0x0FFF
        lsr  x4, x15, x1
       tbnz  x4, 0,Gen_Legal.FilterYesPinnedWeArePinned

Gen_Legal.FilterYesPinnedLegal:
/*
		mov   edx, dword[rsi]
		mov   ecx, edx	 ; move is legal at this point
		mov   eax, edx
		cmp   rsi, rdi
		jne   .FilterYesPinned
		jmp   .FilterDone
*/
        ldr  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        bne  Gen_Legal.FilterYesPinned
          b  Gen_Legal.FilterDone
        
Gen_Legal.FilterYesPinnedWeArePinned:
/*
	       test   r12, qword[LineBB+8*rax]
		jnz   .FilterYesPinnedLegal
*/
        lea  x7, LineBB
        ldr  x4, [x7, x0, lsl 3]
        tst  x12, x4
        bne  Gen_Legal.FilterYesPinnedLegal

Gen_Legal.FilterYesPinnedIllegal:
/*
		sub   rdi, sizeof.ExtMove
		sub   rsi, sizeof.ExtMove
		mov   edx, dword[rdi]
		mov   dword[rsi], edx
		mov   ecx, edx	 ; move is legal at this point
		mov   eax, edx
		cmp   rsi, rdi
		jne   .FilterYesPinned
		jmp   .FilterDone
*/
        sub  x27, x27, sizeof.ExtMove
        sub  x26, x26, sizeof.ExtMove
        ldr  w2, [x27]
        str  w2, [x26]
        mov  w1, w2
        mov  w0, w2
        cmp  x26, x27
        bne  Gen_Legal.FilterYesPinned
          b  Gen_Legal.FilterDone

Gen_Legal.EpCapture:
/*
	; for ep captures, just make the move and test if our king is attacked
		xor   r13d, 1
		mov   r10, qword[rbp+Pos.typeBB+8*r13]
		xor   r13d, 1
		mov   r9d, r14d
		shr   r9d, 6
*/
        eor  x4, x23, 1
        ldr  x10, [x20, x23, lsl 3]
        lsr  x9, x24, 6
/*
	; all pieces
		mov   rdx, qword[rbp+Pos.typeBB+8*White]
		 or   rdx, qword[rbp+Pos.typeBB+8*Black]
*/
        ldr  x2, [x20, 8*White]
        ldr  x4, [x20, 8*Black]
        orr  x2, x2, x4
/*
	; remove source square
		shr   ecx, 6
		btr   rdx, rcx
*/
        lsr  x6, x6, 6
        mov  x4, 1
        lsl  x4, x4, x1
        bic  x2, x2, x4
/*
	; add destination square (ep square)
		and   eax, 63
		bts   rdx, rax
*/
        and  x0, x0, 63
        mov  x4, 1
        lsl  x4, x4, x0
        orr  x2, x2, x4
/*
	; remove captured pawn
		lea   ecx, [2*r13-1]
		lea   ecx, [rax+8*rcx]
		btr   rdx, rcx
*/
        lsl  x1, x23, 1
        sub  x1, x1, 1
        add  x1, x0, x1, lsl 3
        mov  x4, 1
        lsl  x4, x4, x1
        bic  x2, x2, x1
/*
	; check for rook attacks
	RookAttacks   rax, r9, rdx, r8
		mov   rcx, qword[rbp+Pos.typeBB+8*Rook]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, r10
	       test   rax, rcx
		jnz   .FilterIllegalChoose
*/
        RookAttacks  x0, x9, x2, x8, x4
        ldr  x1, [x20, 8*Rook]
        ldr  x4, [x20, 8*Queen]
        orr  x1, x1, x4
        and  x1, x1, x10
        tst  x0, x1
        bne  Gen_Legal.FilterIllegalChoose
/*
	; check for bishop attacks
      BishopAttacks   rax, r9, rdx, r8
		mov   rcx, qword [rbp+Pos.typeBB+8*Bishop]
		 or   rcx, qword[rbp+Pos.typeBB+8*Queen]
		and   rcx, r10
	       test   rax, rcx
		jnz   .FilterIllegalChoose
		jmp   .FilterLegalChoose
*/
        BishopAttacks  x0, x9, x2, x8, x4
        ldr  x1, [x20, 8*Bishop]
        ldr  x4, [x20, 8*Queen]
        orr  x1, x1, x4
        and  x1, x1, x10
        tst  x0, x1
        bne  Gen_Legal.FilterIllegalChoose
          b  Gen_Legal.FilterLegalChoose

