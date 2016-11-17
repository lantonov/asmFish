
	      align   16
UpdateStats:
	; in: rbp pos
	;     rbx state
	;     ecx move
	;     edx depth   this should be >0
	;     r8  quiets  could be NULL
	;     r9d quietsCnt


	       push   r15 r14 r13 r12 rsi rdi

		mov   r12d, ecx ; r12d = move
		mov   r13d, edx ; r13d = depth
		mov   r15d, r9d ; r15d = quietsCnt
				; r8 = quiets
		mov   eax, edx
	       imul   eax, edx
		lea   r14d, [rax+2*rdx-2]	; r14d = bonus


		mov   eax, dword[rbx-1*sizeof.State+State.currentMove]
		and   eax, 63
	      movzx   ecx, byte[rbp+Pos.board+rax]
		shl   ecx, 6
		lea   edi, [rax+rcx]

; rdi = prevoff

; r11d = bonus*32
; r10d = abs(bonus)


		mov   eax, dword[rbx-1*sizeof.State+State.moveCount]
		cmp   eax, 1
		jne   .SkipExtraPenalty
		mov   al, byte[rbx+State.capturedPiece]
	       test   al, al
		jnz   .SkipExtraPenalty

		lea   r10d, [r14+2*(r13+1)+1]
	       imul   r11d, r10d, -32
		cmp   r10d, 324
		jae   .SkipExtraPenalty

		mov   rsi, qword[rbx-2*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*rdi, r11d, r10d, 936
	@@:
		mov   rsi, qword[rbx-3*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*rdi, r11d, r10d, 936
	@@:
		mov   rsi, qword[rbx-5*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*rdi, r11d, r10d, 936
	@@:
.SkipExtraPenalty:


		mov   ecx, r12d
		mov   edx, r12d
		mov   eax, r12d
		and   eax, 63
		mov   r9d, eax
		shr   edx, 14
	      movzx   eax, byte[rbp+Pos.board+rax]
		 or   al, byte[_CaptureOrPromotion_or+rdx]
		and   al, byte[_CaptureOrPromotion_and+rdx]
		jnz   .Return

		shr   ecx, 6
		and   ecx, 63
	      movzx   eax, byte[rbp+Pos.board+rcx]
		shl   eax, 6
		add   r9d, eax
; r9 = moveoff
		mov   eax, dword[rbx+State.killers+4*0]
		cmp   eax, r12d
		 je   @f
		mov   dword[rbx+State.killers+4*1], eax
		mov   dword[rbx+State.killers+4*0], r12d
	@@:

		mov   r10d, r14d
	       imul   r11d, r14d, 32
		cmp   r14d, 324
		jae   .BonusTooBig


		mov   rsi, qword[rbp+Pos.history]
	apply_bonus   rsi+4*r9, r11d, r10d, 324

		mov   eax, r12d
		and   eax, 64*64-1
		mov   esi, dword[rbp+Pos.sideToMove]
		shl   esi, 12+2
		add   rsi, qword[rbp+Pos.fromTo]
		lea   rsi, [rsi+4*rax]
	apply_bonus   rsi, r11d, r10d, 324


		mov   rsi, qword[rbx-1*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
		mov   rsi, qword[rbp+Pos.counterMoves]
		mov   dword[rsi+4*rdi], r12d
	@@:

		mov   rsi, qword[rbx-2*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
	@@:

		mov   rsi, qword[rbx-4*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
	@@:


	; Decrease all the other played quiet moves
		neg   r11d

		xor   edi, edi
	       test   r15d, r15d
		jnz   .HaveQuiets
.Return:
		pop   rdi rsi r12 r13 r14 r15
		ret

.HaveQuiets:
		mov   eax, dword[r8]
		mov   ecx, dword[r8]
.NextQuiet:
		and   ecx, 63
		shr   eax, 6
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
		shl   eax, 6
		lea   r9d, [rax+rcx]

		mov   rsi, qword[rbp+Pos.history]
	apply_bonus   rsi+4*r9, r11d, r10d, 324

		mov   eax, dword[r8+4*rdi]
		and   eax, 64*64-1
		mov   esi, dword[rbp+Pos.sideToMove]
		shl   esi, 12+2
		add   rsi, qword[rbp+Pos.fromTo]
		lea   rsi, [rsi+4*rax]
	apply_bonus   rsi, r11d, r10d, 324

		mov   rsi, qword[rbx-1*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
	@@:
		mov   rsi, qword[rbx-2*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
	@@:
		mov   rsi, qword[rbx-4*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   @f
	apply_bonus   rsi+4*r9, r11d, r10d, 936
	@@:

		add   edi, 1
		mov   eax, dword[r8+4*rdi]
		mov   ecx, dword[r8+4*rdi]
		cmp   edi, r15d
		 jb   .NextQuiet

.Return2:
		pop   rdi rsi r12 r13 r14 r15
		ret



.BonusTooBig:
		mov   rsi, qword[rbx-1*sizeof.State+State.counterMoves]
	       test   rsi, rsi
		 jz   .Return2
		mov   rsi, qword[rbp+Pos.counterMoves]
		mov   dword[rsi+4*rdi], r12d
		jmp   .Return2
