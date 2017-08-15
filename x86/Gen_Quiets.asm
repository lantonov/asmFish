; generate_QUIETS generates all pseudo-legal non-captures and
; underpromotions. Returns a pointer to the end of the move list.

	     calign  16
Gen_Quiets:
	; in: rbp address of position
	;     rbx address of state
	; io: rdi address to write moves

	       push   rsi r12 r13 r14 r15
		mov   r15, qword[rbp+Pos.typeBB+8*White]
		 or   r15, qword[rbp+Pos.typeBB+8*Black]
		mov   r14, r15
		not   r15
		cmp   byte [rbp+Pos.sideToMove], 0
		jne   Gen_Quiets_Black
Gen_Quiets_White:
       generate_all   White, QUIETS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, QUIETS

Gen_Quiets_Black:
       generate_all   Black, QUIETS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, QUIETS
