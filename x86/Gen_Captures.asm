; generate_CAPTURES generates all pseudo-legal captures and queen
; promotions. Returns a pointer to the end of the move list.

	     calign   16
Gen_Captures:
	; in: rbp address of position
	;     rbx address of state
	; io: rdi address to write moves

	       push   rsi r12 r13 r14 r15
		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
		cmp   byte[rbp+Pos.sideToMove],0
		jne   Gen_Captures_Black
Gen_Captures_White:
		mov   r15, qword[rbp+Pos.typeBB+8*Black]
       generate_all   White, CAPTURES
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, CAPTURES

Gen_Captures_Black:
		mov   r15, qword[rbp+Pos.typeBB+8*White]
       generate_all   Black, CAPTURES
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, CAPTURES
