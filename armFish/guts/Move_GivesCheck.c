
Move_GivesCheck:
// in:  x20 Pos
//      x21 State
//      x1 move assumed to be psuedo legal
// out: x0.byte = 0 if not check, otherwise != 0
/*
	; in:  rbp  address of Pos
	;      rbx  address of State - check info must be filled in
	;      ecx  move assumed to be psuedo legal
	; out: eax =  0 if does not give check
	;      eax = -1 if does give check
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to
		mov   r11, qword[rbx+State.dcCandidates]
	      movzx   r10d, byte[rbp+Pos.board+r8]     ; r10 = FROM PIECE
		and   r10d, 7
		 or   eax, -1
		mov   rdx, qword[rbx+State.checkSq+8*r10]
		 bt   rdx, r9
		 jc   .Ret
		 bt   r11, r8
		 jc   .DiscoveredCheck
		xor   eax, eax
		cmp   ecx, MOVE_TYPE_PROM shl 12
		jae   .Special
*/
       ubfx  x8, x1, 6, 6
        and  x9, x1, 63
        ldr  x11, [x21, State.dcCandidates]
        add  x7, x20, Pos.board
       ldrb  w10, [x7, x8]
        and  w10, w10, 7
        mov  w0, -1
        add  x6, x21, State.checkSq
        ldr  x2, [x6, x10, lsl 3]
        lsr  x2, x2, x9
       tbnz  x2, 0, Move_GivesCheck.Ret
        lsr  x4, x11, x8
       tbnz  x4, 0, Move_GivesCheck.DiscoveredCheck
        mov  w0, 0
        cmp  x1, MOVE_TYPE_PROM << 12
        bhs  Move_GivesCheck.Special

Move_GivesCheck.Ret:
/*
		ret
*/
        ret

Move_GivesCheck.Special:
/*
	       push   rsi rdi
*/
Move_GivesCheck.Special.AfterPrologue:
/*
		shr   ecx, 12	; ecx = move type
		mov   esi, dword[rbp+Pos.sideToMove]
	      movzx   edi, byte[rbx+State.ksq]
		mov   rdx, qword[rbp+Pos.typeBB+8*White]
		 or   rdx, qword[rbp+Pos.typeBB+8*Black]
		btr   rdx, r8
		bts   rdx, r9

		mov   eax, dword[.JmpTable+4*(rcx-MOVE_TYPE_PROM)]
		jmp   rax


.JmpTable:   dd .PromKnight,.PromBishop,.PromRook,.PromQueen
	     dd .EpCapture,0,0,0
	     dd .Castling,0,0,0


*/
        lsr  x1, x1, 12
        ldr  w16, [x20, Pos.sideToMove]
       ldrb  w17, [x21, State.ksq]
        ldr  x2, [x20, 8*White]
        ldr  x4, [x20, 8*Black]
        orr  x2, x2, x4
        mov  x4, 1
        lsl  x4, x4, x8
        bic  x2, x2, x4
        mov  x4, 1
        lsl  x4, x4, x9
        orr  x2, x2, x4
        adr  x4, Move_GivesCheck.JmpTable - 4*MOVE_TYPE_PROM
        ldr  w0, [x4, x1, lsl 2]
        adr  x4, Move_GivesCheck
        add  x0, x0, x4
         br  x0
Move_GivesCheck.JmpTable:
        .word Move_GivesCheck.PromKnight - Move_GivesCheck
        .word Move_GivesCheck.PromBishop - Move_GivesCheck
        .word Move_GivesCheck.PromRook - Move_GivesCheck
        .word Move_GivesCheck.EpCapture - Move_GivesCheck
        .word 1
        .word 1
        .word 1
        .word Move_GivesCheck.Castling - Move_GivesCheck

Move_GivesCheck.Castling:
/*
		cmp   r9d, r8d
		adc   esi, esi
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rfrom+rsi]
	      movzx   r11d, byte[rbp-Thread.rootPos+Thread.castling_rto+rsi]
		btr   rdx, rax
		bts   rdx, r11
		bts   rdx, r9  ; set king again if nec
	RookAttacks   rax, r11, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret
*/
        cmp  x8, x9
        adc  x16, x16, x16
        add  x7, x20, -Thread.rootPos + Thread.castling_rfrom
       ldrb  w0, [x7, x16]
        add  x7, x20, -Thread.rootPos + Thread.castling_rto
       ldrb  w11, [x7, x16]
        mov  x4, 1
        lsl  x4, x4, x0
        bic  x2, x2, x4
        mov  x4, 1
        lsl  x4, x4, x11
        orr  x2, x2, x4
        mov  x4, 1
        lsl  x4, x4, x9
        orr  x2, x2, x4
        RookAttacks  x0, x11, x2, x10, x4
        lsr  x0, x0, x17
        and  x0, x0, 1
        ret

Move_GivesCheck.PromQueen:
/*
      BishopAttacks   r8, r9, rdx, r10
	RookAttacks   rax, r9, rdx, r10
		 or   rax, r8
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret
*/
        BishopAttacks  x8, x9, x2, x10, x4
        RookAttacks  x0, x9, x2, x10, x4
        orr  x0, x0, x8
        lsr  x0, x0, x17
        and  x0, x0, 1
        ret

Move_GivesCheck.EpCapture:
/*
		lea   ecx, [2*rsi-1]
		lea   ecx, [r9+8*rcx]
		mov   r8, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r9, qword[rbp+Pos.typeBB+8*Rook]
		btr   rdx, rcx
      BishopAttacks   rax, rdi, rdx, r10
	RookAttacks   r11, rdi, rdx, r10
		mov   r10, qword[rbp+Pos.typeBB+8*Queen]
		 or   r8, r10
		 or   r9, r10
		and   rax, r8
		and   r11, r9
		 or   rax, r11
		and   rax, qword[rbp+Pos.typeBB+8*rsi]
		neg   rax
		sbb   eax, eax
		pop   rdi rsi
		ret
*/
        lsl  x1, x16, 1
        sub  x1, x1, 1
        add  x1, x9, x1, lsl 8
        ldr  x8, [x20, 8*Bishop]
        ldr  x9, [x20, 8*Rook]
        mov  x4, 1
        lsl  x4, x4, x1
        bic  x2, x2, x4
        BishopAttacks  x0, x17, x2, x10, x4
        RookAttacks  x11, x17, x2, x10, x4
        ldr  x10, [x20, 8*Queen]
        orr  x8, x8, x10
        orr  x9, x9, x10
        and  x0, x0, x8
        and  x11, x11, x9
        orr  x0, x0, x11
        ldr  x4, [x20, x6, lsl 3]
        tst  x0, x4
       cset  x0, ne
        ret

.PromBishop:
/*
      BishopAttacks   rax, r9, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

*/
        BishopAttacks  x0, x9, x2, x10, x4
        lsr  x0, x0, x17
        and  x0, x0, 1
        ret
Move_GivesCheck.PromRook:
/*
	RookAttacks   rax, r9, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret
*/
        RookAttacks  x0, x9, x2, x10, x4
        lsr  x0, x0, x17
        and  x0, x0, 1
        ret

Move_GivesCheck.PromKnight:
/*
		mov   rax, qword[KnightAttacks+8*r9]
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret
*/
        lea  x7, KnightAttacks
        ldr  x0, [x7, x9, lsl 3]
        and  x0, x0, 1
        ret        
        
Move_GivesCheck.DiscoveredCheck:
/*
	       push   rsi rdi
	      movzx   edi, byte[rbx+State.ksq]
		mov   eax, ecx
		and   eax, 64*64-1
		mov   rax, qword[LineBB+8*rax]
		 bt   rax, rdi
		 jc  .DiscoveredCheckRet
		 or   eax, -1
		pop   rdi rsi
		ret
*/
       ldrb  w17, [x21, State.ksq]
        and  x0, x1, 64*64-1
        lea  x7, LineBB
        ldr  x0, [x7, x0, lsl 3]
        lsr  x0, x0, x17
       tbnz  x0, 0, Move_GivesCheck.DiscoveredCheckRet
        mov  w0, -1
        ret

Move_GivesCheck.DiscoveredCheckRet:
/*
		xor   eax, eax
		cmp   ecx, MOVE_TYPE_PROM shl 12
		jae   .Special.AfterPrologue
		pop   rdi rsi
		ret
*/
        mov  w0, 0
        cmp  x1, MOVE_TYPE_PROM << 12
        bhs  Move_GivesCheck.Special.AfterPrologue
        ret

