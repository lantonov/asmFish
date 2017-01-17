
	      align   16
SetPinned:	
	; in: rbp  address of Pos
	;     rbx  address of State
	; fills in the pinned bitboard of state

	       push   rdi

		mov   ecx, dword[rbp+Pos.sideToMove]
		mov   r8, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r9, qword[rbp+Pos.typeBB+8*Rook]
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		mov   rdx, qword[rbp+Pos.typeBB+8*rcx]
		 or   r9, rax
		 or   r8, rax
		xor   ecx, 1
		mov   r10, qword[rbp+Pos.typeBB+8*rcx]
		mov   r11, rdx		; r11 = our pieces
		mov   rdi, rdx
		and   rdx, qword[rbp+Pos.typeBB+8*King]
		bsf   rdx, rdx		; rdx = our king

		mov   rax, qword[RookAttacksPDEP+8*rdx]
		and   rax, r9
		mov   rcx, qword[BishopAttacksPDEP+8*rdx]
		and   rcx, r8
		 or   rax, rcx
		and   rax, r10
		jnz   .Pinned
		mov   qword[rbx+State.pinned], rax
.PinnedRet:
		pop   rdi
		ret

	      align   8
.Pinned:
		 or   rdi, r10		; rdi = all pieces
		xor   r10, r10
		shl   edx, 6+3
		lea   rdx, [BetweenBB+rdx]
		bsf   rcx, rax
	@@:	mov   rcx, qword[rdx+8*rcx]
	       blsr   rax, rax, r9
		and   rcx, rdi
	       blsr   r8, rcx, r9
		neg   r8
		sbb   r8, r8
	       andn   rcx, r8, rcx
		 or   r10, rcx
		bsf   rcx, rax
		jnz   @b
		and   r10, r11
		mov   qword [rbx+State.pinned], r10
		jmp   .PinnedRet