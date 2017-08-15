
	     calign   8
MovePick_MAIN_SEARCH:
		mov   r15, qword[rbx-1*sizeof.State+State.endMoves]
		mov   eax, dword[rbx+State.ttMove]
		lea   rdx, [MovePick_CAPTURES_GEN]
		mov   qword[rbx+State.stage], rdx
		ret


	     calign   16, MovePick_GOOD_CAPTURES
MovePick_CAPTURES_GEN:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
		mov   qword[rbx+State.endBadCaptures], rdi
	       call   Gen_Captures
		mov   r15, rdi
		mov   r13, r14
      ScoreCaptures   r13, rdi
		lea   rdx, [MovePick_GOOD_CAPTURES]
		mov   qword[rbx+State.stage], rdx


MovePick_GOOD_CAPTURES:
		cmp   r14, r15
		 je   .WhileDone
	   PickBest   r14, r13, r15
		mov   edi, ecx
		cmp   ecx, dword[rbx+State.ttMove]
		 je   MovePick_GOOD_CAPTURES
	SeeSignTest   .Positive
		mov   rdx, qword[rbx+State.endBadCaptures]
	       test   eax, eax
		 jz   .Negative
	.Positive:
		mov   eax, edi
		ret
	.Negative:
		mov   dword[rdx+ExtMove.move], edi
		add   rdx, sizeof.ExtMove
		mov   qword[rbx+State.endBadCaptures], rdx
		jmp   MovePick_GOOD_CAPTURES

	     calign   16, MovePick_QUIETS
    .WhileDone:
		lea   rdx, [MovePick_KILLERS]
		mov   qword[rbx+State.stage], rdx

	; first killer
		mov   edi, dword[rbx+State.mpKillers+4*0]
		mov   eax, edi
		mov   ecx, edi
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
	       test   edi, edi
		 jz   MovePick_KILLERS
		cmp   edi, dword[rbx+State.ttMove]
		 je   MovePick_KILLERS
		cmp   edi, MOVE_TYPE_EPCAP shl 12
		jae   .special
	       test   eax, eax
		jnz   MovePick_KILLERS
    .check:
	       call   Move_IsPseudoLegal
	       test   rax, rax
		 jz   MovePick_KILLERS
		mov   eax, edi
		ret
.special:
		cmp   edi, MOVE_TYPE_CASTLE shl 12
		jae   .check


MovePick_KILLERS:
		lea   rdx, [MovePick_KILLERS2]
		mov   qword[rbx+State.stage], rdx
		mov   edi, dword[rbx+State.mpKillers+4*1]
		mov   eax, edi
		mov   ecx, edi
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
	       test   edi, edi
		 jz   MovePick_KILLERS2
		cmp   edi, dword[rbx+State.ttMove]
		 je   MovePick_KILLERS2
		cmp   edi, MOVE_TYPE_EPCAP shl 12
		jae   .special
	       test   eax, eax
		jnz   MovePick_KILLERS2
    .check:
	       call   Move_IsPseudoLegal
	       test   rax, rax
		 jz   MovePick_KILLERS2
		mov   eax, edi
		ret
.special:
		cmp   edi, MOVE_TYPE_CASTLE shl 12
		jae   .check


MovePick_KILLERS2:
		lea   rdx, [MovePick_QUIET_GEN]
		mov   qword[rbx+State.stage], rdx
		mov   edi, dword[rbx+State.countermove]
		mov   eax, edi
		mov   ecx, edi
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
	       test   edi, edi
		 jz   MovePick_QUIET_GEN
		cmp   edi, dword[rbx+State.ttMove]
		 je   MovePick_QUIET_GEN
		cmp   edi, dword[rbx+State.mpKillers+4*0]
		 je   MovePick_QUIET_GEN
		cmp   edi, dword[rbx+State.mpKillers+4*1]
		 je   MovePick_QUIET_GEN
		cmp   edi, MOVE_TYPE_EPCAP shl 12
		jae   .special
	       test   eax, eax
		jnz   MovePick_QUIET_GEN
    .check:
	       call   Move_IsPseudoLegal
	       test   rax, rax
		 jz   MovePick_QUIET_GEN
		mov   eax, edi
		ret
.special:
		cmp   edi, MOVE_TYPE_CASTLE shl 12
		jae   .check

MovePick_QUIET_GEN:
		mov   rdi, qword[rbx+State.endBadCaptures]
		mov   r14, rdi
		mov   r12, rdi
	       call   Gen_Quiets
		mov   r15, rdi
	ScoreQuiets   r12, rdi

        ; partial insertion sort
                lea   r10, [r14+sizeof.ExtMove]
               imul   edx, dword[rbx+State.depth], -4000
                mov   r8, r10
                cmp   r10, r15
                jae   .SortDone
.SortLoop:
                mov   edi, dword[r8+ExtMove.value]
                mov   r9, qword[r8+ExtMove.move]
                cmp   edi, edx
                 jl   .SortLoopSkip
                mov   rax, qword[r10]
                mov   qword[r8], rax
                mov   rcx, r10
                cmp   r10, r14
                 je   .SortInnerDone
.SortInner:
                mov   r11, qword[rcx-sizeof.ExtMove]
                lea   rax, [rcx-sizeof.ExtMove]
                cmp   edi, dword[rcx-sizeof.ExtMove+ExtMove.value]
                jle   .SortInnerDone
                mov   qword[rcx], r11
                mov   rcx, rax
                cmp   rax, r14
                jne   .SortInner
.SortInnerDone:
                add   r10, sizeof.ExtMove
                mov   qword[rcx], r9
.SortLoopSkip:
                add   r8, sizeof.ExtMove
                cmp   r8, r15
                 jb   .SortLoop
.SortDone:

		lea   rdx, [MovePick_QUIETS]
		mov   qword[rbx+State.stage], rdx


MovePick_QUIETS:
		mov   eax, dword[r14]
		cmp   r14, r15
		jae   .WhileDone
               test   esi, dword[r14+ExtMove.value]
                 js   .WhileDone
		add   r14, sizeof.ExtMove
		cmp   eax, dword[rbx+State.ttMove]
		 je   MovePick_QUIETS
		cmp   eax, dword[rbx+State.mpKillers+4*0]
		 je   MovePick_QUIETS
		cmp   eax, dword[rbx+State.mpKillers+4*1]
		 je   MovePick_QUIETS
		cmp   eax, dword[rbx+State.countermove]
		 je   MovePick_QUIETS
		ret

	     calign   16, MovePick_BAD_CAPTURES
    .WhileDone:
		lea   rdx, [MovePick_BAD_CAPTURES]
		mov   qword[rbx+State.stage], rdx
		mov   r14, qword[rbx-1*sizeof.State+State.endMoves]


MovePick_BAD_CAPTURES:
		mov   eax, dword[r14]
		cmp   r14, qword[rbx+State.endBadCaptures]
		jae   .IfDone
		add   r14, sizeof.ExtMove
		ret
    .IfDone:
		xor   eax, eax
		ret


	     calign   8
MovePick_EVASIONS:
		mov   r15, qword[rbx-1*sizeof.State+State.endMoves]
		mov   eax, dword[rbx+State.ttMove]
		lea   rdx, [MovePick_ALL_EVASIONS]
		mov   qword[rbx+State.stage], rdx
		ret

	     calign   8
MovePick_ALL_EVASIONS:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_Evasions
		mov   r15, rdi
		mov   r12, r14
      ScoreEvasions   r12, r15
		lea   rdx, [MovePick_REMAINING]
		mov   qword[rbx+State.stage], rdx
		jmp   MovePick_REMAINING

	     calign   8
MovePick_QSEARCH_WITH_CHECKS:
		mov   r15, qword[rbx-1*sizeof.State+State.endMoves]
		mov   eax, dword[rbx+State.ttMove]
		lea   rdx, [MovePick_QCAPTURES_CHECKS_GEN]
		mov   qword[rbx+State.stage], rdx
		ret

	     calign   8
MovePick_QCAPTURES_CHECKS_GEN:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_Captures
		mov   r15, rdi
		mov   r13, r14
      ScoreCaptures   r13, rdi
		lea   rdx, [MovePick_QCAPTURES_CHECKS]
		mov   qword[rbx+State.stage], rdx
		jmp   MovePick_QCAPTURES_CHECKS

	     calign   8
MovePick_QSEARCH_WITHOUT_CHECKS:
		mov   r15, qword[rbx-1*sizeof.State+State.endMoves]
		mov   eax, dword[rbx+State.ttMove]
		lea   rdx, [MovePick_QCAPTURES_NO_CHECKS_GEN]
		mov   qword[rbx+State.stage], rdx
		ret


	     calign   16, MovePick_REMAINING
MovePick_QCAPTURES_NO_CHECKS_GEN:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_Captures
		mov   r15, rdi
		mov   r13, r14
      ScoreCaptures   r13, rdi
		lea   rdx, [MovePick_REMAINING]
		mov   qword[rbx+State.stage], rdx


MovePick_REMAINING:
		cmp   r14, r15
		jae   .WhileDone
	   PickBest   r14, r13, r15
		mov   eax, ecx
		cmp   ecx, dword[rbx+State.ttMove]
		 je   MovePick_REMAINING
		ret
    .WhileDone:
		xor   eax, eax
		ret



	     calign   16
MovePick_QCAPTURES_CHECKS:
		cmp   r14, r15
		jae   .WhileDone
	   PickBest   r14, r13, r15
		mov   eax, ecx
		cmp   ecx, dword[rbx+State.ttMove]
		 je   MovePick_QCAPTURES_CHECKS
		ret

	     calign   16, MovePick_CHECKS
    .WhileDone:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_QuietChecks
		mov   r15, rdi
		lea   rdx, [MovePick_CHECKS]
		mov   qword[rbx+State.stage], rdx
MovePick_CHECKS:
		mov   eax, dword[r14]
		cmp   r14, r15
		jae   .IfDone
		add   r14, sizeof.ExtMove
		cmp   eax, dword[rbx+State.ttMove]
		 je   MovePick_CHECKS
		ret
    .IfDone:
		xor   eax, eax
		ret




	     calign   16, MovePick_RECAPTURES
MovePick_RECAPTURES_GEN:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_Captures
		mov   r15, rdi
		mov   r13, r14
      ScoreCaptures   r13, rdi
		lea   rdx, [MovePick_RECAPTURES]
		mov   qword[rbx+State.stage], rdx


MovePick_RECAPTURES:
		cmp   r14, r15
		 je   .WhileDone
	   PickBest   r14, r13, r15
		mov   eax, ecx
		and   ecx, 63
		cmp   ecx, dword[rbx+State.recaptureSquare]
		jne   MovePick_RECAPTURES
		ret
    .WhileDone:
		xor   eax, eax
		ret





	     calign   8
MovePick_PROBCUT:
		mov   r15, qword[rbx-1*sizeof.State+State.endMoves]
		mov   eax, dword[rbx+State.ttMove]
		lea   rdx, [MovePick_PROBCUT_GEN]
		mov   qword[rbx+State.stage], rdx
		ret


	     calign   16, MovePick_PROBCUT_2
MovePick_PROBCUT_GEN:
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		mov   r14, rdi
	       call   Gen_Captures
		mov   r15, rdi
		mov   r13, r14
      ScoreCaptures   r13, rdi
		lea   rdx, [MovePick_PROBCUT_2]
		mov   qword[rbx+State.stage], rdx


MovePick_PROBCUT_2:
		cmp   r14, r15
		 je   .WhileDone
	   PickBest   r14, r13, r15
		mov   eax, ecx
		mov   edi, ecx
		cmp   ecx, dword[rbx+State.ttMove]
		 je   MovePick_PROBCUT_2
		mov   edx, dword[rbx+State.threshold]
	       call   SeeTestGe
	       test   eax, eax
		 jz   MovePick_PROBCUT_2
		mov   eax, edi
		ret
    .WhileDone:
		xor   eax, eax
		ret
