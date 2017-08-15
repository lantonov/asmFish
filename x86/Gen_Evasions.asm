; generate<EVASIONS> generates all pseudo-legal check evasions when the side
; to move is in check. Returns a pointer to the end of the move list.

	     calign   16
Gen_Evasions:
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
	      _andn   rsi, rsi, qword[rbx+State.checkersBB]

; r12 = sliderAttacks
		mov   r9, r14
		shl   r9, 6+3
		xor   r12, r12
		bsf   rdx, rsi
		 jz   .SlidersDone
.NextSlider:
	      _blsr   rsi, rsi, r8
		mov   rax, [LineBB+r9+8*rdx]
		btr   rax, rdx
		 or   r12, rax
		bsf   rdx, rsi
		jnz   .NextSlider
.SlidersDone:

; generate moves for the king to safe squares
		mov   rsi, qword[rbp+Pos.typeBB+8*r13]
	      _andn   rsi, rsi, qword[KingAttacks+8*r14]
	      _andn   r12, r12, rsi
		shl   r14d, 6
		bsf   rax, r12
		 jz   .KingMoveDone
.NextKingMove:
	      _blsr   r12, r12, r8
		 or   eax, r14d
		mov   dword [rdi], eax
		lea   rdi, [rdi+sizeof.ExtMove]
		bsf   rax, r12
		jnz   .NextKingMove
.KingMoveDone:

; if there are multiple checkers, only king moves can be evasions
		mov   rcx, qword[rbx+State.checkersBB]
	      _blsr   rax, rcx
		jnz   Gen_Evasions_White.Ret
		bsf   rax, rcx
		mov   r15, qword[BetweenBB+r9+8*rax]
		 or   r15, rcx

		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
	       test   r13d,r13d
		jnz   Gen_Evasions_Black
Gen_Evasions_White:
       generate_all   White, EVASIONS
.Ret:
                pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, EVASIONS

Gen_Evasions_Black:
       generate_all   Black, EVASIONS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, EVASIONS
