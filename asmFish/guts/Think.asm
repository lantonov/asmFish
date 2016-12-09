Thread_Think:
	; in: rcx address of Thread struct

	       push   rbp rbx rsi rdi r13 r14 r15
virtual at rsp
 .completedDepth rd 1
 .alpha      rd 1
 .beta	     rd 1
 .delta      rd 1
 .bestValue  rd 1
 .easyMove   rd 1
 .multiPV    rd 1
 .lend	     rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		lea   rbp, [rcx+Thread.rootPos]
		mov   rbx, qword[rbp+Pos.state]
;GD_String <db 'Thread_Think',10>

		mov   dword[.easyMove], 0
		mov   dword[.alpha], -VALUE_INFINITE
		mov   dword[.beta], +VALUE_INFINITE
		mov   dword[.delta], -VALUE_INFINITE
		mov   dword[.bestValue], -VALUE_INFINITE
		mov   dword[.completedDepth], 0

	; clear the search stack
		lea   rdx, [rbx-5*sizeof.State]
		lea   r8, [rbx+3*sizeof.State]
.clear_stack:
		xor   eax, eax
		lea   rdi, [rdx+State._stack_start]
		mov   ecx, State._stack_end-State._stack_start
	  rep stosb
		add   rdx, sizeof.State
		cmp   rdx, r8
		 jb   .clear_stack

	; set move list for current state
		mov   rax, qword[rbp+Pos.moveList]
		mov   qword[rbx-1*sizeof.State+State.endMoves], rax

	; resets for main thread
		xor   eax, eax
		mov   byte[rbp-Thread.rootPos+Thread.easyMovePlayed], al
		mov   byte[rbp-Thread.rootPos+Thread.failedLow], al
		mov   qword[rbp-Thread.rootPos+Thread.bestMoveChanges], rax
		cmp   eax, dword[rbp-Thread.rootPos+Thread.idx]
		jne   .skip_easymove
		mov   rcx, qword[rbx+State.key]
	       call   EasyMoveMng_Get
		mov   dword[.easyMove], eax
	       call   EasyMoveMng_Clear
.skip_easymove:

	; set multiPV
		lea   rcx, [rbp+Pos.rootMovesVec]
	       call   RootMovesVec_Size
		mov   ecx, dword[options.multiPV]
		cmp   eax, ecx
	      cmova   eax, ecx
		mov   dword[.multiPV], eax

	; id loop
		mov   r15d, dword[rbp-Thread.rootPos+Thread.rootDepth]	 ; this should be set to 0 by ThreadPool_StartThinking
.id_loop:
		xor   eax, eax
		mov   ecx, dword[limits.depth]
		cmp   eax, dword[rbp-Thread.rootPos+Thread.idx]
	     cmovne   ecx, eax
		sub   ecx, 1
		cmp   al, byte[signals.stop]
		jne   .id_loop_done
		cmp   r15d, ecx
		 ja   .id_loop_done
		add   r15d, 1
		mov   dword[rbp-Thread.rootPos+Thread.rootDepth], r15d
		cmp   r15d, MAX_PLY
		jge   .id_loop_done

	; skip depths for helper threads
		mov   eax, dword[rbp-Thread.rootPos+Thread.idx]
		mov   ecx, HalfDensitySize
		sub   eax, 1
		 jc   .age_out
		xor   edx, edx
		div   ecx
		mov   r8d, dword[HalfDensityRows+8*rdx+4*0]
		mov   r9d, dword[HalfDensityRows+8*rdx+4*1]
		mov   eax, dword[rbp+Pos.gamePly]
		add   eax, r15d
		xor   edx, edx
		div   r8d
		 bt   r9d, edx
		 jc   .id_loop
		jmp   .save_prev_score
.age_out:
	; Age out PV variability metric
	     vmovsd   xmm0, qword[rbp-Thread.rootPos+Thread.bestMoveChanges]
	     vmulsd   xmm0, xmm0, qword[constd.0p505]
		mov   byte[rbp-Thread.rootPos+Thread.failedLow], 0
	     vmovsd   qword[rbp-Thread.rootPos+Thread.bestMoveChanges], xmm0

.save_prev_score:
	; Save the last iteration's scores before first PV line is searched and all the move scores except the (new) PV are set to -VALUE_INFINITE.
		mov   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   rdx, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
    .save_next:
		mov   eax, dword[rcx+RootMove.score]
		mov   dword[rcx+RootMove.prevScore], eax
		add   rcx, sizeof.RootMove
		cmp   rcx, rdx
		 jb   .save_next

if USE_WEAKNESS
	; if using weakness, reset multiPV local variable
		cmp   byte[weakness.enabled], 0
		 je   @f
		mov   eax, dword[weakness.multiPV]
		mov   dword[.multiPV], eax
	@@:
end if

	; MultiPV loop. We perform a full root search for each PV line
		 or   r14d, -1
.multipv_loop:
		add   r14d, 1
		mov   al, byte[signals.stop]
		mov   dword[rbp-Thread.rootPos+Thread.PVIdx], r14d
		cmp   r14d, dword[.multiPV]
		jae   .multipv_done
	       test   al, al
		jnz   .multipv_done

	; Reset aspiration window starting size
	       imul   r8d, r14d, sizeof.RootMove
		mov   edx, 18
		add   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		cmp   r15d, 5
		 jl   .reset_window_done
		mov   eax, dword[r8+RootMove.prevScore]
		mov   ecx, -VALUE_INFINITE
		sub   eax, edx
		cmp   eax, ecx
	      cmovl   eax, ecx
		mov   dword[.alpha], eax
		mov   eax, dword[r8+RootMove.prevScore]
		mov   ecx, VALUE_INFINITE
		add   eax, edx
		cmp   eax, ecx
	      cmovg   eax, ecx
		mov   dword[.beta], eax
		mov   dword[.delta], edx
    .reset_window_done:

	; Start with a small aspiration window and, in the case of a fail high/low, re-search with a bigger window until we're not failing high/low anymore.
.search_loop:
		mov   ecx, dword[.alpha]
		mov   edx, dword[.beta]
		mov   r8d, r15d
		xor   r9d, r9d
	       call   Search_Root ; rootPos is in rbp, ss is in rbx
		mov   r12d, eax
		mov   dword[.bestValue], eax
	       imul   ecx, r14d, sizeof.RootMove
		add   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   rdx, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
	       call   RootMovesVec_StableSort

	; If search has been stopped, break immediately. Sorting and writing PV back to TT is safe because RootMoves is still valid, although it refers to the previous iteration.
		mov   al, byte[signals.stop]
	       test   al, al
		jnz   .search_done

	; When failing high/low give some update before a re-search.
		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .dont_print_pv
		mov   eax, dword[.multiPV]
		cmp   eax, 1
		jne   .dont_print_pv
		cmp   r12d, dword[.alpha]
		jle   @f
		cmp   r12d, dword[.beta]
		 jl   .dont_print_pv
	@@:    call   _GetTime
		sub   rax, qword[time.startTime]
match =0, VERBOSE {
		cmp   rax, 3000
		jbe   .dont_print_pv
}
		mov   ecx, r15d
		mov   edx, dword[.alpha]
		mov   r8d, dword[.beta]
		mov   r9, rax
		mov   r10d, dword[.multiPV]
	       call   DisplayInfo_Uci
	.dont_print_pv:

	; In case of failing low/high increase aspiration window and re-search, otherwise exit the loop.
		mov   r8d, dword[.alpha]
		mov   r9d, dword[.beta]
		mov   eax, dword[.delta]
		mov   r10d, eax
		cdq
		and   edx, 3
		add   eax, edx
		sar   eax, 2
		lea   r10d, [r10+rax+5]
	; r10d = delta + delta / 4 + 5
		lea   eax, [r8+r9]
		cdq
		sub   eax, edx
		sar   eax, 1
	; eax = (alpha + beta) / 2
		mov   edx, r12d
		cmp   r12d, r8d
		jle   .fail_low
		cmp   r12d, r9d
		 jl   .search_done
    .fail_high:
		add   edx, dword[.delta]
		mov   ecx, VALUE_INFINITE
		cmp   edx, ecx
	      cmovg   edx, ecx
		mov   dword[.alpha], eax
		mov   dword[.beta], edx
		mov   dword[.delta], r10d
		jmp   .search_loop
    .fail_low:
		sub   edx, dword[.delta]
		mov   ecx, -VALUE_INFINITE
		cmp   edx, ecx
	      cmovl   edx, ecx
		mov   dword[.alpha], edx
		mov   dword[.beta], eax
		mov   dword[.delta], r10d
		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .search_loop
		mov   byte[rbp-Thread.rootPos+Thread.failedLow], -1
		mov   byte[signals.stopOnPonderhit], 0
		jmp   .search_loop
.search_done:

	; Sort the PV lines searched so far and update the GUI
	       imul   edx, r14d, sizeof.RootMove
		mov   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		lea   rdx, [rcx+rdx+sizeof.RootMove]
	       call   RootMovesVec_StableSort

		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .multipv_loop
	       call   _GetTime
		mov   r9, rax
		sub   r9, qword[time.startTime]
		cmp   byte[signals.stop], 0
		jne   .print_pv2
		lea   eax, [r14+1]
		cmp   eax, dword[.multiPV]
		 je   .print_pv2
match =0, VERBOSE {
		cmp   r9, 3000
		 jb   .multipv_loop
}
.print_pv2:
		mov   ecx, r15d
		mov   edx, dword[.alpha]
		mov   r8d, dword[.beta]
		mov   r10d, dword[.multiPV]
	       call   DisplayInfo_Uci



if USE_WEAKNESS
		cmp   byte[weakness.enabled], 0
		 je   .multipv_loop
	       call   Weakness_SetMultiPV
end if
		jmp   .multipv_loop

.multipv_done:
		mov   al, byte[signals.stop]
	       test   al, al
		jnz   @f
		mov   dword[rbp-Thread.rootPos+Thread.completedDepth], r15d
	@@:
		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .id_loop

	; If skill level is enabled and time is up, pick a sub-optimal best move
		; not implemented

	; Have we found a "mate in x"
		; not implemented

	; r12d = bestValue  remember

		mov   al, byte[limits.useTimeMgmt]
	       test   al, al
		 jz   .id_loop

		mov   al, byte[signals.stop]
		 or   al, byte[signals.stopOnPonderhit]
		jnz   .handle_easymove

	       call   _GetTime
		sub   rax, qword[time.startTime]
		mov   r11, rax
	; r11 = Time.elapsed()

		xor   eax, eax
		cmp   al, byte[rbp-Thread.rootPos+Thread.failedLow]
	      setne   al
	       imul   eax, 119
		add   eax, 357
		mov   ecx, r12d
		sub   ecx, dword[rbp-Thread.rootPos+Thread.previousScore]
	       imul   ecx, 6
		sub   eax, ecx
		mov   edx, 229
		cmp   eax, edx
	      cmovl   eax, edx
		mov   edx, 715
		cmp   eax, edx
	      cmovg   eax, edx
	  vcvtsi2sd   xmm3, xmm3, eax
	; xmm3 = improvingFactor

		mov   eax, dword[time.optimumTime]
		mov   ecx, 5
		mul   ecx
		mov   ecx, 42
		div   ecx
	; eax = Time.optimum() * 5 / 42
		mov   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   ecx, dword[r8+RootMove.pv+4*0]

	     vmovsd   xmm0, qword[rbp-Thread.rootPos+Thread.bestMoveChanges]
	     vmovsd   xmm2, qword[constd.1p0]
	     vaddsd   xmm2, xmm2, xmm0
	; xmm2 = unstablePvFactor

		xor   r9d, r9d
		cmp   r11d, eax
		jbe   @f
		cmp   ecx, dword[.easyMove]
		jne   @f
	    vcomisd   xmm0, qword[constd.0p03]
		sbb   r9d, r9d
		@@:
	; r9d = doEasyMove

	     vmulsd   xmm2, xmm2, xmm3
	  vcvtsi2sd   xmm0, xmm0, r11d
	     vmulsd   xmm0, xmm0, qword[constd.628p0]
	  vcvtsi2sd   xmm1, xmm1, dword[time.optimumTime]
	     vmulsd   xmm1, xmm1, xmm2
		add   r8, sizeof.RootMove
		cmp   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
		 je   .set_stop
	    vcomisd   xmm0, xmm1
		 ja   .set_stop
		mov   byte[rbp-Thread.rootPos+Thread.easyMovePlayed], r9l
	       test   r9d, r9d
		 jz   .handle_easymove
    .set_stop:
		mov   al, byte[limits.ponder]
	       test   al, al
		jnz   @f
		mov   byte[signals.stop], -1
		jmp   .handle_easymove
	@@:	mov   byte[signals.stopOnPonderhit], -1


    .handle_easymove:
		mov   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   eax, dword[rcx+RootMove.pvSize]
		cmp   eax, 3
		 jb   @f
	       call   EasyMoveMng_Update
		jmp   .id_loop
	@@:    call   EasyMoveMng_Clear
		jmp   .id_loop


.id_loop_done:
		mov   al, byte[rbp-Thread.rootPos+Thread.easyMovePlayed]
		mov   ecx, dword[easyMoveMng.stableCnt]
		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .done
		cmp   ecx, 6
		 jb   @f
	       test   al, al
		 jz   .done
	@@:    call   EasyMoveMng_Clear

.done:

;GD_String <db 'Thread_Think returning',10>

		add   rsp, .localsize
		pop   r15 r14 r13 rdi rsi rbx rbp
		ret






MainThread_Think:
	; in: rcx address of Thread struct   should be mainThread

	       push   rbp rbx rsi rdi r15
		lea   rbp, [rcx+Thread.rootPos]
		mov   rbx, qword[rbp+Pos.state]

GD_String 'MainThread_Think'
GD_NewLine

		mov   ecx, dword[rbp+Pos.sideToMove]
		mov   edx, dword[rbp+Pos.gamePly]
	       call   TimeMng_Init

		mov   eax, dword[options.contempt]
		cdq
	       imul   eax, PawnValueEg
		mov   ecx, 100
	       idiv   ecx
		mov   ecx, eax
		mov   eax, dword[rbp+Pos.sideToMove]
		neg   ecx
		mov   dword[DrawValue+4*rax], ecx
		xor   eax, 1
		neg   ecx
		mov   dword[DrawValue+4*rax], ecx
		add   byte[mainHash.date], 4

if USE_WEAKNESS
	; set multipv and change maximumTime
		cmp   byte[weakness.enabled], 0
		 je   @f
	; start with one line, may be changed by Weakness_PickMove
		mov   dword[weakness.multiPV], 1
	       call   Weakness_AdjustTime
	@@:
end if

	; check for mate
		mov   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
		cmp   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		 je   .mate

if USE_BOOK
		xor   eax, eax
		cmp   al, byte[limits.useTimeMgmt]
		 je   @f
		cmp   al, byte[book.use]
		 je   @f
		cmp   rax, qword[book.buffer]
		 je   @f
	       call   Book_GetMove
	       test   eax, eax
		jnz   .PlayBookMove
	@@:
end if

	; start workers
		xor   esi, esi
    .next_worker:
		add   esi, 1
		cmp   esi, dword[threadPool.threadCnt]
		jae   .workers_done
		mov   rcx, qword[threadPool.threadTable+8*rsi]
	       call   Thread_StartSearching
		jmp   .next_worker
    .workers_done:

	; start searching
		lea   rcx, [rbp-Thread.rootPos]
	       call   Thread_Think

.search_done:

	; check for wait
		mov   al, byte[signals.stop]
	       test   al, al
		jnz   .dont_wait
		mov   al, byte[limits.ponder]
		 or   al, byte[limits.infinite]
		 jz   .dont_wait
		mov   byte[signals.stopOnPonderhit], -1
		lea   rcx, [rbp-Thread.rootPos]
		lea   rdx, [signals.stop]
	       call   Thread_Wait
	.dont_wait:
		mov   byte[signals.stop], -1


	; wait for workers
		xor   esi, esi
	.next_worker2:
		add   esi, 1
		cmp   esi, dword[threadPool.threadCnt]
		jae   .workers_done2
		mov   rcx, qword[threadPool.threadTable+8*rsi]
	       call   Thread_WaitForSearchFinished
		jmp   .next_worker2
	.workers_done2:


	; check for mate again
		mov   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
		cmp   r8, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		 je   .mate_bestmove

if USE_WEAKNESS
		cmp   byte[weakness.enabled], 0
		jne   .pick_weak_move
end if

	; find best thread  index esi, best score in r9d
		xor   esi, esi
		mov   r10, qword[threadPool.threadTable+8*rsi]
		mov   r8d, dword[r10+Thread.completedDepth]
		mov   r9, qword[r10+Thread.rootPos+Pos.rootMovesVec+RootMovesVec.table]
		mov   r9d, dword[r9+0*sizeof.RootMove+RootMove.score]
		mov   eax, dword[options.multiPV]
		sub   eax, 1
		 or   eax, dword[limits.depth]
		 or   al, byte[rbp-Thread.rootPos+Thread.easyMovePlayed]
		jne   .best_done
		mov   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   ecx, dword[rcx+0*sizeof.RootMove+RootMove.pv+4*0]
	       test   ecx, ecx
		 jz   .best_done
		xor   edi, edi
	.next_worker3:
		add   edi, 1
		cmp   edi, dword[threadPool.threadCnt]
		jae   .workers_done3
		mov   r10, qword[threadPool.threadTable+8*rdi]
		mov   eax, dword[r10+Thread.completedDepth]
		mov   rcx, qword[r10+Thread.rootPos+Pos.rootMovesVec+RootMovesVec.table]
		mov   ecx, dword[rcx+0*sizeof.RootMove+RootMove.score]
		cmp   eax, r8d
		jle   .next_worker3
		cmp   ecx, r9d
		jle   .next_worker3
		mov   r8d, eax
		mov   r9d, ecx
		mov   esi, edi
		jmp   .next_worker3
	.workers_done3:
.best_done:
		mov   dword[rbp-Thread.rootPos+Thread.previousScore], r9d
		mov   rcx, qword[threadPool.threadTable+8*rsi]
.display_move:
	       call   DisplayMove_Uci

.return:

GD_String 'MainThread_Think returning'
GD_NewLine

		pop   r15 rdi rsi rbx rbp
		ret

if USE_WEAKNESS
.pick_weak_move:

	       call   Weakness_PickMove
		mov   rax, qword[rbp+Pos.rootMovesVec.table]
		mov   eax, dword[rax+0*sizeof.RootMove+RootMove.score]
		lea   rcx, [rbp-Thread.rootPos]
		mov   dword[rcx+Thread.previousScore], eax
		jmp   .display_move
end if

if USE_BOOK
.PlayBookMove:
		lea   rdi, [Output]
		mov   ecx, eax
		mov   rax, 'bestmove'
	      stosq
		mov   al, ' '
	      stosb
	      movzx   edx, byte[rbp+Pos.chess960]
	       call   PrintUciMove
       PrintNewLine
	       call   _WriteOut_Output
		jmp   .return
end if


.mate:
		lea   rdi, [Output]
		mov   rax, 'info dep'
	      stosq
		mov   rax, 'th 0 sco'
	      stosq
		mov   eax, 're '
	      stosd
		sub   rdi, 1
		cmp   qword[rbx+State.checkersBB], 1
		sbb   ecx, ecx
		and   ecx, VALUE_DRAW+VALUE_MATE
		sub   ecx, VALUE_MATE
	       call   PrintScore_Uci
       PrintNewLine
	       call   _WriteOut_Output
		jmp   .search_done


.mate_bestmove:

		lea   rdi, [Output]
		mov   rax, 'bestmove'
	      stosq
		mov   rax, ' NONE'
	      stosq
		sub   rdi, 3
       PrintNewLine
	       call   _WriteOut_Output
		jmp   .return




DisplayMove_Uci:
	; in: rcx address of best thread
	       push   rsi rdi r15
virtual at rsp
  .output rb 32
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
		mov   rsi, rcx

		mov   al, byte[options.displayInfoMove]
	       test   al, al
		 jz   .return

	; print best move and ponder move
		lea   rdi, [.output]
		mov   rax, 'bestmove'
	      stosq
		mov   al, ' '
	      stosb
		mov   rcx, qword[rsi+Thread.rootPos+Pos.rootMovesVec+RootMovesVec.table]
		mov   ecx, dword[rcx+0*sizeof.RootMove+RootMove.pv+4*0]
	      movzx   edx, byte[rsi+Thread.rootPos+Pos.chess960]
	       call   PrintUciMove

		mov   rcx, qword[rsi+Thread.rootPos+Pos.rootMovesVec+RootMovesVec.table]
		mov   eax, dword[rcx+0*sizeof.RootMove+RootMove.pvSize]
		cmp   eax, 2
		 jb   .get_ponder_from_tt
.have_ponder_from_tt:
		mov   rax, ' ponder '
	      stosq
		mov   ecx, dword[rcx+0*sizeof.RootMove+RootMove.pv+4*1]
	      movzx   edx, byte[rsi+Thread.rootPos+Pos.chess960]
	       call   PrintUciMove
.skip_ponder:
		lea   rcx, [.output]
		mov   eax, 10
	      stosb
	       call   _WriteOut
.return:
		add   rsp, .localsize
		pop   r15 rdi rsi
		ret

.get_ponder_from_tt:
		lea   rcx, [rsi+Thread.rootPos]
	       call   ExtractPonderFromTT
		mov   rcx, qword[rsi+Thread.rootPos+Pos.rootMovesVec+RootMovesVec.table]
	       test   eax, eax
		jnz   .have_ponder_from_tt
		jmp   .skip_ponder


ExtractPonderFromTT:
	; in: rcx address of position
	       push   rbp rbx rsi rdi r13 r14 r15
virtual at rsp
 .movelist rb sizeof.ExtMove*MAX_MOVES
 .lend	   rb 0
end virtual
.localsize = .lend-rsp
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		mov   r15, qword[rcx+Pos.rootMovesVec+RootMovesVec.table]

		mov   rbp, rcx
		mov   rbx, qword[rcx+Pos.state]
		mov   ecx, dword[r15+RootMove.pv+4*0]
		xor   eax, eax
		cmp   eax, ecx
		 je   .Return
	       call   Move_GivesCheck
		mov   ecx, dword[r15+RootMove.pv+4*0]
		mov   edx, eax
	       call   Move_Do__ExtractPonderFromTT
		mov   rcx, qword[rbx+State.key]
	       call   MainHash_Probe
		mov   esi, ecx
		shr   esi, 16
		xor   r14d, r14d
	       test   edx, edx
		 jz   .done

		lea   rdi, [.movelist]
	       call   Gen_Legal
		lea   rdx, [.movelist-sizeof.ExtMove]
	.loop:
		add   rdx, sizeof.ExtMove
		cmp   rdx, rdi
		jae   .done
		cmp   esi, dword[rdx+ExtMove.move]
		jne   .loop

		 or   r14d, -1
		mov   dword[r15+RootMove.pv+4*1], esi
		mov   dword[r15+RootMove.pvSize], 2
.done:
		mov   ecx, dword[r15+RootMove.pv+4*0]
	       call   Move_Undo
		mov   eax, r14d
.Return:
		add   rsp, .localsize
		pop   r15 r14 r13 rdi rsi rbx rbp
		ret




DisplayInfo_Uci:
	; in: rbp thread pos
	;     ecx depth
	;     edx alpha
	;     r8d beta
	;     r9 elapsed
	;     r10d multipv

	       push   rbx rsi rdi r12 r13 r14 r15
virtual at rsp
 .elapsed    rq 1
 .nodes      rq 1
 .tbHits     rq 1
 .nps	     rq 1
 .depth      rd 1
 .alpha      rd 1
 .beta	     rd 1
 .multiPV    rd 1
 .hashfull   rd 1
	     rd 1
 .output     rb 8*MAX_PLY
 .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
		mov   dword[.depth], ecx
		mov   dword[.alpha], edx
		mov   dword[.beta], r8d
		mov   qword[.elapsed], r9
		mov   dword[.multiPV], r10d

	     Assert   ne, r10d, 0, 'assertion dword[.multiPV]!=0 in Position_WriteOutUciInfo failed'

		mov   al, byte[options.displayInfoMove]
	       test   al, al
		 jz   .return

if USE_SPAMFILTER
		cmp   r9, SPAMFILTER_DELAY
		 jb   .return
end if

if USE_HASHFULL
		 or   eax, -1
		cmp   r9, 1000
		 jb   @f
	       call   MainHash_HashFull
	@@:	mov   dword[.hashfull], eax
end if

	       call   ThreadPool_NodesSearched_TbHits
		mov   qword[.nodes], rax
		mov   qword[.tbHits], rdx
		mov   edx, 1000
		mul   rdx
		mov   rcx, qword[.elapsed]
		cmp   rcx, 1
		adc   rcx, 0
		div   rcx
		mov   qword[.nps], rax


		xor   r15d, r15d
.multipv_loop:
		xor   eax, eax
		cmp   r15d, dword[rbp-Thread.rootPos+Thread.PVIdx]
	      setbe   al

		mov   ecx, dword[.depth]
		sub   ecx, 1
		mov   edx, eax
		 or   edx, ecx
		 jz   .multipv_cont
		add   ecx, eax

		lea   rdi, [.output]

	       imul   esi, r15d, sizeof.RootMove
		add   rsi, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   r12d, dword[rsi+4*rax]

		mov   rax, 'info dep'
	      stosq
		mov   eax, 'th '
	      stosd
		sub   rdi, 1
		mov   eax, ecx
	       call   PrintUnsignedInteger

if USE_SELDEPTH
		mov   rax, ' seldept'
	      stosq
		mov   eax, 'h '
	      stosw
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.maxPly]
	       call   PrintUnsignedInteger
end if

		mov   al, ' '
	      stosb
		mov   rax, 'multipv '
	      stosq
		lea   eax, [r15+1]
	       call   PrintUnsignedInteger

if VERBOSE<2
		mov   rax, ' time '
	      stosq
		sub   rdi, 2
		mov   rax, qword[.elapsed]
	       call   PrintUnsignedInteger

		mov   rax, ' nps '
	      stosq
		sub   rdi, 3
		mov   rax, qword[.nps]
	       call   PrintUnsignedInteger
end if

	      movsx   r13d, byte[Tablebase_RootInTB]
		mov   eax, r12d
		cdq
		xor   eax, edx
		sub   eax, edx
		sub   eax, VALUE_MATE - MAX_PLY
		sar   eax, 31
		and   r13d, eax
	     cmovnz   r12d, dword[Tablebase_Score]

		mov   rax, ' score '
	      stosq
		sub   rdi, 1
		mov   ecx, r12d
	       call   PrintScore_Uci

	       test   r13d, r13d
		jnz   .no_bound
		cmp   r15d, dword[rbp-Thread.rootPos+Thread.PVIdx]
		jne   .no_bound
		mov   rax, ' lowerbo'
		cmp   r12d, dword[.beta]
		jge   .yes_bound
		mov   rax, ' upperbo'
		cmp   r12d, dword[.alpha]
		 jg   .no_bound
	.yes_bound:
	      stosq
		mov   eax, 'und'
	      stosd
		sub   rdi, 1
	.no_bound:

		mov   rax, ' nodes '
	      stosq
		sub   rdi, 1
		mov   rax, qword[.nodes]
	       call   PrintUnsignedInteger

		mov   rax, ' tbhits '
	      stosq
		mov   rax, qword[.tbHits]
	       call   PrintUnsignedInteger

if USE_HASHFULL
if VERBOSE<2
		mov   ecx, dword[.hashfull]
	       test   ecx, ecx
		 js   @f
		mov   rax, ' hashful'
	      stosq
		mov   ax, 'l '
	      stosw
		mov   eax, ecx
	       call   PrintUnsignedInteger
	@@:
end if
end if

		mov   eax, ' pv'
	      stosd
		sub   rdi, 1

		mov   r13d, dword[rsi+RootMove.pvSize]
		lea   r12, [rsi+RootMove.pv]
		lea   r13, [r12+4*r13]
	.next_move:
		mov   al, ' '
		cmp   r12, r13
		jae   .moves_done
	      stosb
		mov   ecx, dword[r12]
	      movzx   edx, byte[rbp+Pos.chess960]
	       call   PrintUciMove
		add   r12, 4
		jmp   .next_move
	.moves_done:
       PrintNewLine
		lea   rcx, [.output]
	       call   _WriteOut

.multipv_cont:
		add   r15d, 1
		cmp   r15d, dword[.multiPV]
		 jb   .multipv_loop

.return:
		add   rsp, .localsize
		pop   r15 r14 r13 r12 rdi rsi rbx

DisplayMove_None:
DisplayInfo_None:
		ret
