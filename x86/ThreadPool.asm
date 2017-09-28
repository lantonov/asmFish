
; the thread pool has two possible states
;  depending on whether the numa function are present or not
;
;1. not present:
;  threadPool.nodeCnt = 1 this is semi accurate but works for the purpose of ThreadIdxToNode
;  the lone entry of threadPool.nodeTable has
;    .coreCnt =1         this is not accurate but works for the purpose of ThreadIdxToNode
;    .NodeNumber = -1    to bypass _VirtualAllocNuma for _VirtualAlloc instead
;    .GroupMask.Mask = 0 to bypass any affinity setting if used at all
;
;2. present:
;  entries are as expected, that is for each detected node we have
;   .nodeNumber  rd 1     the >=0 integer
;   .coreCnt     rd 1     number of cores detected on this node
;   .cmhTable    rq 1     our per-node cmh-table
;   .groupMask (win) or .cpuMask (linux)


ThreadPool_Create:
	; in: rcx address of node affinity string
	       push   rbx
	       call   Os_SetThreadPoolInfo
		xor   ecx, ecx
	       call   Thread_Create
		mov   dword[threadPool.threadCnt], 1
		pop   rbx
		ret


ThreadPool_Destroy:
	       push   rsi rdi rbx
		mov   edi, dword[threadPool.threadCnt]
.NextThread:
		lea   ecx, [rdi-1]
	       call   Thread_Delete
		sub   edi, 1
		jnz   .NextThread
		mov   dword[threadPool.threadCnt], edi

		lea   rdi, [threadPool.nodeTable]
	       imul   ebx, dword[threadPool.nodeCnt], sizeof.NumaNode
		add   rbx, rdi
.NextNumaNode:
		mov   rcx, qword[rdi+NumaNode.cmhTable]
		mov   edx, sizeof.CounterMoveHistoryStats
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rdi+NumaNode.cmhTable], rax
		add   rdi, sizeof.NumaNode
		cmp   rdi, rbx
		 jb   .NextNumaNode

		pop   rbx rdi rsi
		ret


ThreadPool_ReadOptions:
	       push   rbx rsi rdi
		mov   esi, dword[options.threads]
		mov   edi, dword[threadPool.threadCnt]
		cmp   edi, esi
		 je   .Skip
.CheckCreate:
		cmp   edi, esi
		 jb   .Create
.CheckDelete:
		cmp   edi, esi
		 ja   .Delete

	       call   ThreadPool_DisplayThreadDistribution
.Skip:
		pop   rdi rsi rbx
		ret
.Create:
		mov   ecx, edi
	       call   Thread_Create
		add   edi, 1
		mov   dword[threadPool.threadCnt], edi
		jmp   .CheckCreate
.Delete:
		sub   edi, 1
		mov   ecx, edi
	       call   Thread_Delete
		mov   dword[threadPool.threadCnt], edi
		jmp   .CheckDelete


ThreadPool_NodesSearched_TbHits:
            xor  ecx, ecx
            xor  eax, eax
            xor  edx, edx
.next_thread:
            mov  r8, qword[threadPool.threadTable+8*rcx]
            add  rax, qword[r8+Thread.nodes]
            add  rdx, qword[r8+Thread.tbHits]
            add  ecx, 1
            cmp  ecx, dword[threadPool.threadCnt]
             jb  .next_thread
            ret

ThreadPool_DisplayThreadDistribution:
	       push  rbx rsi rdi r14 r15
            lea  rdi, [Output]
            lea  rsi, [threadPool.nodeTable]
           imul  r15d, dword[threadPool.nodeCnt], sizeof.NumaNode
            add  r15, rsi
.NextNode:
            lea  rcx, [sz_info_node_threads]
            xor  r8, r8
            mov  eax, dword[rsi+NumaNode.nodeNumber]
           push  rax rax
            mov  rdx, rsp
           call  PrintFancy
            pop  rax rax

             or  ebx, -1
.ThreadLoop:
            add  ebx, 1
            cmp  ebx, dword[threadPool.threadCnt]
            jae  .ThreadLoopDone
            mov  rax, qword[threadPool.threadTable+8*rbx]
            cmp  rsi, qword[rax+Thread.numaNode]
            jne  .ThreadLoop
            mov  al, ' '
          stosb
            mov  eax, ebx
           call  PrintUnsignedInteger
            jmp  .ThreadLoop
.ThreadLoopDone:

        PrintNL
            add  rsi, sizeof.NumaNode
            cmp  rsi, r15
             jb  .NextNode
           call  WriteLine_Output
.Return:
            pop  r15 r14 rdi rsi rbx
            ret



ThreadPool_StartThinking:
	; in: rbp address of position
	;     rcx address of limits struct
	;            this will be copied to the global limits struct
	;            so that search threads can see it
	       push   rbp rbx rsi rdi r13 r14 r15
virtual at rsp
  .moveList rb sizeof.ExtMove*MAX_MOVES
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
		mov   rsi, rcx
		mov   r15, rbp
		mov   r14, qword[threadPool.threadTable+8*0]
	; rsi = address of limits
	; r15 = gui position
	; r14 = main thread

		mov   rcx, r14
	       call   Thread_WaitForSearchFinished

		xor   eax, eax
		mov   byte[signals.stop], al
		mov   byte[signals.stopOnPonderhit], al
		lea   rcx, [limits]
		mov   rdx, rsi
	       call   Limits_Copy

        ; first, get root moves from gui position
		lea   rsi, [limits.moveVec]
		lea   rdi, [.moveList]
		mov   ecx, dword[limits.moveVecSize]
	       test   ecx, ecx
		jnz   .use_searchmoves
		mov   rbx, qword[rbp+Pos.state]
	       call   Gen_Legal
.have_moves:
		lea   rsi, [.moveList]
		lea   rcx, [r14+Thread.rootPos+Pos.rootMovesVec]
	       call   RootMovesVec_Clear
    .push_moves:
		cmp   rsi, rdi
		jae   .push_moves_done
		lea   rcx, [r14+Thread.rootPos+Pos.rootMovesVec]
		mov   edx, dword[rsi+ExtMove.move]
		add   rsi, sizeof.ExtMove
	       call   RootMovesVec_PushBackMove
		jmp   .push_moves
    .push_moves_done:

	; next, copy to mainThread
		xor   eax, eax
		mov   dword[r14+Thread.rootDepth], eax
		mov   qword[r14+Thread.nodes], rax
		mov   qword[r14+Thread.tbHits], rax
		mov   byte[r14+Thread.selDepth], al
                mov   dword[r14+Thread.resetCnt], eax
                mov   dword[r14+Thread.callsCnt], MIN_RESETCNT  ; check time asap
		lea   rcx, [r14+Thread.rootPos]
	       call   Position_CopyToSearch

        ; switch rbp and rbx to position of main thread
		lea   rbp, [r14+Thread.rootPos]
		mov   rbx, qword[rbp+Pos.state]

        ; since gui thread does not have a rootmoves vector
        ;   do filtering of tb moves in the main thread
        ; this behavior will not necessarily match official stockfish if
        ;   tbs are being used
        ;   and multiple go commands are issued after a position command
        ; however, tb probing code is not functionally identical anyways

if USE_SYZYGY
	; Skip TB probing when no TB found
		mov   dl, byte[options.syzygy50MoveRule]
		mov   byte[Tablebase_RootInTB], 0
		mov   byte[Tablebase_UseRule50], dl
		mov   eax, dword[options.syzygyProbeLimit]
		mov   ecx, dword[options.syzygyProbeDepth]
		xor   edx, edx
		cmp   eax, dword[Tablebase_MaxCardinality]
	      cmovg   eax, dword[Tablebase_MaxCardinality]
	      cmovg   ecx, edx
		mov   dword[Tablebase_Cardinality], eax
		mov   dword[Tablebase_ProbeDepth], ecx
	; filter moves
		mov   rcx, qword[rbp+Pos.typeBB+8*White]
		 or   rcx, qword[rbp+Pos.typeBB+8*Black]
	    _popcnt   rcx, rcx, rdx
		mov   rdx, qword[rbp+Pos.rootMovesVec.ender]
		cmp   rdx, qword[rbp+Pos.rootMovesVec.table]
		jbe   .check_tb_ret
		sub   eax, ecx
		sar   eax, 31
		 or   al, byte[rbx+State.castlingRights]
		 jz   .check_tb
.check_tb_ret:
		mov   qword[rbp+Pos.state], rbx ; Thread_Think uses Pos.state
end if

	; position is passed to threads by first converting to a fen
	;   and then parsing this fen string
	; the net effect is a fixed order on piece lists
	       call   Position_SetPieceLists

	; copy position in main thread to workers
		xor   eax, eax
                mov   qword[r14+Thread.nodes], rax  ;filtering moves may have incremented mainThread.nodes
		xor   edi, edi
.next_thread:
		add   edi,1
		cmp   edi, dword[threadPool.threadCnt]
		jae   .thread_copy_done

        ; get address of worker thread
		mov   rsi, qword[threadPool.threadTable+8*rdi]

		lea   rcx, [rsi+Thread.rootPos]
	       call   Position_CopyToSearch
		xor   eax, eax
		mov   dword[rsi+Thread.rootDepth], eax
		mov   qword[rsi+Thread.nodes], rax
		mov   qword[rsi+Thread.tbHits], rax
		mov   byte[rsi+Thread.selDepth], al
                mov   dword[rsi+Thread.resetCnt], eax
                mov   dword[rsi+Thread.callsCnt], MAX_RESETCNT  ; main thread already has min


	; copy the filtered moves of main thread to worker thread
		mov   rax, qword[rsi+Thread.rootPos.rootMovesVec.table]
		mov   rdx, qword[r14+Thread.rootPos.rootMovesVec.table]
.copy_moves_loop:
		cmp   rdx, qword[r14+Thread.rootPos.rootMovesVec.ender]
		jae   .copy_moves_done
	   _vmovups   xmm0, dqword[rdx+0]    ; this should be sufficient to copy
	   _vmovups   xmm1, dqword[rdx+16]   ; up to and including first move of pv
	   _vmovups   dqword[rax+0], xmm0    ;
	   _vmovups   dqword[rax+16], xmm1   ;
		add   rax, sizeof.RootMove
		add   rdx, sizeof.RootMove
		jmp   .copy_moves_loop
.copy_moves_done:
		mov   qword[rsi+Thread.rootPos.rootMovesVec.ender], rax

		jmp   .next_thread
.thread_copy_done:

		mov   rcx, r14
	       call   Thread_StartSearching

		add   rsp, .localsize
		pop   r15 r14 r13 rdi rsi rbx rbp
		ret


if USE_SYZYGY
.check_tb:
                mov   rax, qword[rbp+Pos.moveList]
                mov   qword[rbx-1*sizeof.State+State.endMoves], rax
	       call   Tablebase_RootProbe
		mov   byte[Tablebase_RootInTB], al
		xor   edx, edx
	       test   eax, eax
		jnz   .root_in
	       call   Tablebase_RootProbeWDL
		mov   byte[Tablebase_RootInTB], al
		xor   edx, edx
	       test   eax, eax
		 jz   .check_tb_ret
		cmp   edx, dword[Tablebase_Score]
	      cmovl   edx, dword[Tablebase_Cardinality]
    .root_in:
		mov   dword[Tablebase_Cardinality], edx
		lea   rcx, [rbp+Pos.rootMovesVec]
	       call   RootMovesVec_Size
		mov   qword[rbp-Thread.rootPos+Thread.tbHits], rax
	      movzx   edx, byte[Tablebase_UseRule50]
		mov   eax, dword[Tablebase_Score]
	       test   dl, dl
		jnz   .check_tb_ret
		mov   ecx, VALUE_MATE - MAX_PLY - 1
		cmp   eax, edx
	      cmovg   eax, ecx
		neg   ecx
		cmp   eax, edx
	      cmovl   eax, ecx
		mov   dword[Tablebase_Score], eax
		jmp   .check_tb_ret
end if

.use_searchmoves:
	; use the moves obtained from 'searchmoves' command
	; these have already been checked for legality
		xor   eax, eax
	      lodsw
	      stosq
		sub   ecx, 1
		jnz   .use_searchmoves
		jmp   .have_moves
