
Gen_Evasions:
/*
	; in rbp address of position
	;    rbx address of state
	; io rdi address to write moves

	       push   rsi r12 r13 r14 r15
		mov   r13d, dword[rbp+Pos.sideToMove]

; r14 = our king square
		mov   r14, qword[rbp+Pos.typeBB+8*King]
		and   r14, qword[rbp+Pos.typeBB+8*r13]
		bsf   r14, r14

; rsi = their sliding checkers
		mov   rsi, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rsi, qword[rbp+Pos.typeBB+8*Knight]
	       andn   rsi, rsi, qword[rbx+State.checkersBB]

; r12 = sliderAttacks
		mov   r9, r14
		shl   r9, 6+3
		xor   r12, r12
		bsf   rdx, rsi
		 jz   .SlidersDone
*/
        ldr  w13, [x20, Pos.sideToMove]
        ldr  x14, [x20, 8*King]
        ldr  x4, [x20, x13, lsl 3]
        and  x14, x14, x4
       rbit  x14, x14
        clz  x14, x14

        ldr  x16, [x20, 8*Pawn]
        ldr  x4, [x20, 8*Knight]
        orr  x16, x16, x4
        ldr  x4, [x21, State.checkersBB]
        bic  x16, x4, x16

        lsl  x9, x14, 9
        mov  x12, 0
       rbit  x2, x16
        clz  x2, x2
        cbz  x16, Gen_Evasions.SlidersDone

Gen_Evasions.NextSlider:
/*
	       blsr   rsi, rsi, r8
		mov   rax, [LineBB+r9+8*rdx]
		btr   rax, rdx
		 or   r12, rax
		bsf   rdx, rsi
		jnz   .NextSlider
*/
        sub  x8, x16, 1
        and  x16, x16, x8
        lea  x7, LineBB
        add  x7, x7, x9
        ldr  x0, [x7, x2, lsl 3]
        mov  x4, 1
        lsl  x4, x4, x2
        bic  x0, x0, x4
        orr  x12, x12, x0
       rbit  x2, x16
        clz  x2, x2
       cbnz  x16, Gen_Evasions.NextSlider
        
Gen_Evasions.SlidersDone:
/*
; generate moves for the king to safe squares
		mov   rsi, qword[rbp+Pos.typeBB+8*r13]
	       andn   rsi, rsi, qword[KingAttacks+8*r14]
	       andn   r12, r12, rsi
		shl   r14d, 6
		bsf   rax, r12
		 jz   .KingMoveDone
*/
        ldr  x16, [x20, x13, lsl 3]
        lea  x7, KingAttacks
        ldr  x4,  [x7, x14, lsl 3]
        bic  x16, x4, x16
        bic  x12, x16, x12
        lsl  x14, x14, 6
       rbit  x0, x12
        clz  x0, x0
       cbnz  x12, Gen_Evasions.KingMoveDone
Gen_Evasions.NextKingMove:
/*
	       blsr   r12, r12, r8
		 or   eax, r14d
		mov   dword [rdi], eax
		lea   rdi, [rdi+sizeof.ExtMove]
		bsf   rax, r12
		jnz   .NextKingMove
*/
        sub  x8, x12, 1
        and  x12, x12, x8
        orr  x0, x0, x14
        str  w0, [x27]
        add  x27, x27, sizeof.ExtMove
       rbit  x0, x12
        clz  x0, x0
       cbnz  x12, Gen_Evasions.KingMoveDone
Gen_Evasions.KingMoveDone:
/*
; if there are multiple checkers, only king moves can be evasions
		mov   rcx, qword[rbx+State.checkersBB]
	       blsr   rax, rcx
		jnz   Gen_Evasions_White.Ret
		bsf   rax, rcx
		mov   r15, qword[BetweenBB+r9+8*rax]
		 or   r15, rcx

		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
	       test   r13d,r13d
		jnz   Gen_Evasions_Black
*/
        ldr  x1, [x21, State.checkersBB]
        sub  x0, x1, 1
        tst  x0, x1
        bne  Gen_Evasions_White.Ret
       rbit  x0, x2
        clz  x0, x0
        lea  x7, BetweenBB
        add  x7, x7, x9
        ldr  x15, [x7, x0, lsl 3]
        orr  x15, x15, x1

        ldr  x14, [x20, 8*White]
        ldr  x4, [x20, 8*Black]
        orr  x14, x14, x4
       cbnz  w13, Gen_Evasions_Black

Gen_Evasions_White:
/*
       generate_all   White, EVASIONS
*/
        GenAll  Gen_Evasions_White, White, EVASIONS
Gen_Evasions_White.Ret:
        ret
/*
                pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, EVASIONS
*/
        GenPawnJmp  Gen_Evasions_White, White, EVASIONS
        GenCastlingJmp  Gen_Evasions_White, White, EVASIONS



Gen_Evasions_Black:
/*
       generate_all   Black, EVASIONS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, EVASIONS
*/
        GenAll  Gen_Evasions_Black, Black, EVASIONS
        ret
        GenPawnJmp  Gen_Evasions_Black, Black, EVASIONS
        GenCastlingJmp  Gen_Evasions_Black, Black, EVASIONS

