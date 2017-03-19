
Gen_NonEvasions:
/*
	; in rbp address of position
	;    rbx address of state
	; io rdi address to write moves

	       push   rsi r12 r13 r14 r15
		mov   eax, dword[rbp+Pos.sideToMove]
		mov   r15, qword[rbp+Pos.typeBB+8*rax]
		not   r15
		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
	       test   eax, eax
		jne   Gen_NonEvasions_Black
*/
        ldr  w0, [x20, Pos.sideToMove]
        ldr  x15, [x20, x0, lsl 3]
        mvn  x15, x15
        ldr  x14, [x20, 8*White]
        ldr  x4, [x20, 8*Black]
        orr  x14, x14, x4
       cbnz  w0, Gen_NonEvasions_Black
Gen_NonEvasions_White:
/*
       generate_all   White, NON_EVASIONS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, NON_EVASIONS

*/
        GenAll  Gen_NonEvasions_White, White, NON_EVASIONS
        ret
        GenPawnJmp  Gen_NonEvasions_White, White, NON_EVASIONS
        GenCastlingJmp  Gen_NonEvasions_White, White, NON_EVASIONS

Gen_NonEvasions_Black:
/*
       generate_all   Black, NON_EVASIONS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, NON_EVASIONS
*/
//        GenAll  Gen_NonEvasions_Black, Black, NON_EVASIONS
        ret
//        GenPawnJmp  Gen_NonEvasions_Black, Black, NON_EVASIONS
//        GenCastlingJmp  Gen_NonEvasions_Black, Black, NON_EVASIONS

