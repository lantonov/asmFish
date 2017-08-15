
	     calign   16, SetCheckInfo.go
SetCheckInfo:
	; in: rbp  address of Pos
	;     rbx  address of State

	       push   rsi rdi r12 r13 r14 r15
.AfterPrologue:
		mov   esi, dword[rbp+Pos.sideToMove]
		mov   r15, qword[rbp+Pos.typeBB+8*rsi]
		xor   esi, 1
		mov   r14, qword[rbp+Pos.typeBB+8*rsi]
		shl   esi, 6+3
		mov   r13, r15		; r13 = our pieces
		mov   r12, r14		; r12 = their pieces
		mov   rdi, r15
		 or   rdi, r14		; rdi = all pieces
		and   r15, qword[rbp+Pos.typeBB+8*King]
		and   r14, qword[rbp+Pos.typeBB+8*King]
		bsf   r15, r15		; r15 = our king
		bsf   r14, r14		; r14 = their king
.go:
;ProfileInc SetCheckInfo

		mov   byte[rbx+State.ksq], r14l

		mov   rax, qword[WhitePawnAttacks+rsi+8*r14]
		mov   rdx, qword[KnightAttacks+8*r14]
		mov   qword[rbx+State.checkSq+8*Pawn], rax
		mov   qword[rbx+State.checkSq+8*Knight], rdx
		shr   esi, 6+3
      BishopAttacks   rax, r14, rdi, r8
	RookAttacks   rdx, r14, rdi, r8
		xor   r11, r11
		mov   qword[rbx+State.checkSq+8*Bishop], rax
		mov   qword[rbx+State.checkSq+8*Rook], rdx
		 or   rax, rdx
		mov   qword[rbx+State.checkSq+8*Queen], rax
		mov   qword[rbx+State.checkSq+8*King], r11

	; for their king
		xor   eax, eax
     SliderBlockers   rax, r13, r14, r11,\
		      rdi, r12,\
		      rcx, rdx, r8, r9
		mov   qword[rbx+State.pinnersForKing+8*rsi], r11
		mov   qword[rbx+State.blockersForKing+8*rsi], rax
		and   rax, r13
		mov   qword[rbx+State.dcCandidates], rax

	; for our king
		xor   r11, r11
		xor   esi, 1
		xor   eax, eax
     SliderBlockers   rax, r12, r15, r11,\
		      rdi, r13,\
		      rcx, rdx, r8, r9
		mov   qword[rbx+State.pinnersForKing+8*rsi], r11
		mov   qword[rbx+State.blockersForKing+8*rsi], rax
		and   rax, r13
		mov   qword[rbx+State.pinned], rax

		pop   r15 r14 r13 r12 rdi rsi
		ret




 ;               mov   rax, qword[RookAttacksPDEP+8*r14]
;                and   rax, r11
;                mov   rcx, qword[BishopAttacksPDEP+8*r14]
;                and   rcx, r10
;                 or   rax, rcx
;                xor   esi, esi
;                and   rax, r13
;                jnz   .dcCandidates
;                mov   qword[rbx+State.dcCandidates], rax
;.dcCandidatesRet:
;
;                mov   rax, qword[RookAttacksPDEP+8*r15]
;                and   rax, r11
;                mov   rcx, qword[BishopAttacksPDEP+8*r15]
;                and   rcx, r10
;                 or   rax, rcx
;                xor   esi, esi
;                and   rax, r12
;                jnz   .Pinned
;                mov   qword[rbx+State.pinned], rax
;.PinnedRet:
;
;                pop   r15 r14 r13 r12 rdi rsi
;                ret
;
;
;
;
;              align   8
;.Pinned:
;                mov   edx, r15d
;                shl   rdx, 6+3
;                lea   rdx, [BetweenBB+rdx]
;                bsf   rcx, rax
;        @@:     mov   rcx, qword[rdx+8*rcx]
;               blsr   rax, rax, r9
;                and   rcx, rdi
;               blsr   r8, rcx, r9
;                neg   r8
;                sbb   r8, r8
;               andn   rcx, r8, rcx
;                 or   rsi, rcx
;                bsf   rcx, rax
;                jnz   @b
;                and   rsi, r13
;                mov   qword[rbx+State.pinned], rsi
;                jmp   .PinnedRet
;
;              align   8
;.dcCandidates:
;                mov   edx, r14d
;                shl   rdx, 6+3
;                lea   rdx, [BetweenBB+rdx]
;                bsf   rcx, rax
;        @@:     mov   rcx, qword[rdx+8*rcx]
;               blsr   rax, rax, r9
;                and   rcx, rdi
;               blsr   r8, rcx, r9
;                neg   r8
;                sbb   r8, r8
;               andn   rcx, r8, rcx
;                 or   rsi, rcx
;                bsf   rcx, rax
;                jnz   @b
;                and   rsi, r13
;                mov   qword[rbx+State.dcCandidates], rsi
;                jmp   .dcCandidatesRet
