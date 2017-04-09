
Gen_QuietChecks:
        brk  0
/*
	; in rbp address of position
	;    rbx address of state
	; io rdi address to write moves

	       push   rsi r12 r13 r14 r15

		mov   r15, qword[rbp+Pos.typeBB+8*White]
		 or   r15, qword[rbp+Pos.typeBB+8*Black]

		mov   r14, qword[rbx+State.dcCandidates]
	       test   r14, r14
		 jz   .PopLoopDone
*/
.PopLoop:
/*
		bsf   r13, r14
	       blsr   r14, r14, rax
	      movzx   r12d, byte[rbp+Pos.board+r13]
		and   r12d, 7
		jmp   qword[.JmpTable+8*r12]
*/
.JmpTable:
/*
	dq 0;Gen_QuietChecks_Jmp.PopSkip
	dq 0;Gen_QuietChecks_Jmp.PopSkip
	dq Gen_QuietChecks.PopSkip
	dq Gen_QuietChecks_Jmp.AttacksFromKnight
	dq Gen_QuietChecks_Jmp.AttacksFromBishop
	dq Gen_QuietChecks_Jmp.AttacksFromRook
	dq Gen_QuietChecks_Jmp.AttacksFromQueen
	dq Gen_QuietChecks_Jmp.AttacksFromKing
*/

.AttacksFromRet:
/*
		shl   r13d, 6
	       test   rsi, rsi
		 jz   .MoveLoopDone
*/
.MoveLoop:
/*
		bsf   rax, rsi
		 or   eax, r13d
		mov   dword[rdi], eax
		lea   rdi, [rdi+sizeof.ExtMove]
	       blsr   rsi, rsi, rdx
		jnz   .MoveLoop
*/
.MoveLoopDone:


.PopSkip:
/*
	       test   r14, r14
		jnz   .PopLoop
*/
.PopLoopDone:
/*
		not   r15
		mov   r14, qword[rbp+Pos.typeBB+8*White]
		 or   r14, qword[rbp+Pos.typeBB+8*Black]
		cmp   byte[rbp+Pos.sideToMove], 0
		jne   Gen_QuietChecks_Black
*/
Gen_QuietChecks_White:
/*
       generate_all   White, QUIET_CHECKS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   White, QUIET_CHECKS
*/
Gen_QuietChecks_Black:
/*
       generate_all   Black, QUIET_CHECKS
		pop   r15 r14 r13 r12 rsi
		ret
       generate_jmp   Black, QUIET_CHECKS
*/




Gen_QuietChecks_Jmp:
.AttacksFromKnight:
/*
		mov   rsi, qword[KnightAttacks+8*r13]
	       andn   rsi, r15, rsi
		jmp   Gen_QuietChecks.AttacksFromRet
*/
.AttacksFromKing:
/*
		mov   rsi, qword[KingAttacks+8*r13]
	       andn   rsi, r15, rsi
	      movzx   ecx, byte [rbx+State.ksq]
		mov   rax, qword[RookAttacksPDEP+8*rcx]
		 or   rax, qword[BishopAttacksPDEP+8*rcx]
	       andn   rsi, rax, rsi
		jmp   Gen_QuietChecks.AttacksFromRet
*/
.AttacksFromBishop:
/*
      BishopAttacks   rsi, r13, r15, rax
	       andn   rsi, r15, rsi
		jmp   Gen_QuietChecks.AttacksFromRet
*/
.AttacksFromRook:
/*
	RookAttacks   rsi, r13, r15, rax
	       andn   rsi, r15, rsi
		jmp   Gen_QuietChecks.AttacksFromRet
*/
.AttacksFromQueen:
/*
      BishopAttacks   rsi, r13, r15, rax
	RookAttacks   rdx, r13, r15, rax
		 or   rsi, rdx
	       andn   rsi, r15, rsi
		jmp   Gen_QuietChecks.AttacksFromRet
*/
