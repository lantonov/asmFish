
ThreadIdxToNode:
/*
; in: ecx index (n) of thread
; out: rax address of numa noda

		mov   r8d, dword[threadPool.coreCnt]
		mov   r9d, dword[threadPool.nodeCnt]
		lea   r10, [threadPool.nodeTable]
		mov   eax, ecx
		xor   edx, edx
		div   r8d
		xor   eax, eax
		cmp   r8d, 1
		 je   .Return
		cmp   ecx, r8d
		jae   .MoreThreadsThanCores
	       imul   ecx, r9d, sizeof.NumaNode
.NextNode:	sub   edx, dword[r10+rax+NumaNode.coreCnt]
		 js   .Return
		add   eax, sizeof.NumaNode
		cmp   eax, ecx
		 jb   .NextNode
	; shouldn't get here
	; just return first node
		xor   eax, eax
.Return:
		add   rax, r10
		ret

.MoreThreadsThanCores:
		mov   eax, edx
		xor   edx, edx
		div   r9d
	       imul   eax, edx, sizeof.NumaNode
		jmp   .Return
*/
        lea  x0, threadPool
        mov  w4, sizeof.NumaNode
        ldr  w8, [x0, ThreadPool.coreCnt]
        ldr  w9, [x0, ThreadPool.nodeCnt]
        add  x0, x0, ThreadPool.nodeTable
       udiv  w3, w1, w8
       msub  w2, w3, w8, w1
       madd  x1, x9, x4, x0
        cmp  w8, 1
        beq  ThreadIdxToNode.Return
        cmp  w1, w8
        bhs  ThreadIdxToNode.MoreThreadsThanCores
ThreadIdxToNode.NextNode:
        ldr  w3, [x0, NumaNode.coreCnt]
       subs  w2, w2, w3
        bmi  ThreadIdxToNode.Return
        add  x0, x0, x4
        cmp  x0, x1
        blo  ThreadIdxToNode.NextNode
        sub  x0, x0, x4
ThreadIdxToNode.Return:
        ret
ThreadIdxToNode.MoreThreadsThanCores:
       udiv  w3, w2, w9
       msub  w2, w3, w9, w2 
       madd  x0, x2, x4, x0
        ret


Thread_Create:
/*
	; in: ecx index of thread
	       push   rbx rsi rdi r14 r15
		mov   esi, ecx
*/
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        stp  x24, x25, [sp, -16]!
        mov  x14, x1
/*
	; get the right node to put this thread
	       call   ThreadIdxToNode
		mov   rdi, rax
		mov   r15d, dword[rdi+NumaNode.nodeNumber]
*/
         bl  ThreadIdxToNode
Display "Thread Create: idx: %i14  node: %x0\n"
        mov  x15, x0
        ldr  w25, [x15, NumaNode.nodeNumber]
/*
	; allocate self
		mov   ecx, sizeof.Thread
		mov   edx, r15d
	       call   _VirtualAllocNuma
		mov   qword[threadPool.threadTable+8*rsi], rax
		mov   rbx, rax
*/
        mov  x1, sizeof.Thread
        mov  x2, x25
         bl  Os_VirtualAllocNuma
        lea  x16, threadPool
        str  x0, [x21, Thread.numaNode]
        mov  x21, x0
/*
	; fill in address of numanode struct
		mov   qword[rbx+Thread.numaNode], rdi

	; init some thread data
		xor   eax, eax
		mov   byte[rbx+Thread.exit], al
		mov   dword[rbx+Thread.resetCnt], eax
		mov   dword[rbx+Thread.callsCnt], eax
		mov   dword[rbx+Thread.idx], esi
		mov   qword[rbx+Thread.numaNode], rdi
*/
       strb  wzr, [x21, Thread.exit]
        str  wzr, [x21, Thread.resetCnt]
        str  wzr, [x21, Thread.callsCnt]
        str  w14, [x21, Thread.idx]
        str  x15, [x21, Thread.numaNode]
/*
    ; per thread memory allocations
	; create sync objects
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexCreate
		lea   rcx, [rbx+Thread.sleep1]
	       call   _EventCreate
		lea   rcx, [rbx+Thread.sleep2]
	       call   _EventCreate
*/
        add  x1, x21, Thread.mutex
         bl  Os_MutexCreate
        add  x1, x21, Thread.sleep1
         bl  Os_EventCreate
        add  x1, x21, Thread.sleep2
         bl  Os_EventCreate
/*
	; the states will be allocated when copying position to thread
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos+Pos.state], rax
		mov   qword[rbx+Thread.rootPos+Pos.stateTable], rax
		mov   qword[rbx+Thread.rootPos+Pos.stateEnd], rax
*/
        str  xzr, [x21, Thread.rootPos+Pos.state]
        str  xzr, [x21, Thread.rootPos+Pos.stateTable]
        str  xzr, [x21, Thread.rootPos+Pos.stateEnd]
/*
	; create the vector of root moves
		lea   rcx, [rbx+Thread.rootPos+Pos.rootMovesVec]
		mov   edx, r15d
	       call   RootMovesVec_Create
*/
        add  x1, x21, Thread.rootPos+Pos.rootMovesVec
        mov  w2, w25
         bl  RootMovesVec_Create
/*
	; allocate stats
		mov   ecx, sizeof.HistoryStats + sizeof.MoveStats
		mov   edx, r15d
	       call   _VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos.history], rax
		add   rax, sizeof.HistoryStats
		mov   qword[rbx+Thread.rootPos.counterMoves], rax
*/
        mov  x1, sizeof.HistoryStats + sizeof.MoveStats
        mov  w2, w25
         bl  Os_VirtualAllocNuma
        str  x0, [x21, Thread.rootPos+Pos.history]
        add  x0, x0, sizeof.HistoryStats
        str  x0, [x21, Thread.rootPos+Pos.counterMoves]
/*
	; allocate pawn hash
		mov   ecx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
		mov   edx, r15d
	       call   _VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.pawnTable], rax
*/
        mov  x1, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
        mov  w2, w25
         bl  Os_VirtualAllocNuma
        str  x0, [x21, Thread.rootPos+Pos.pawnTable]
/*
	; allocate material hash
		mov   ecx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
		mov   edx, r15d
	       call   _VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.materialTable], rax
*/
        mov  x1, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
        mov  w2, w25
         bl  Os_VirtualAllocNuma
        str  x0, [x21, Thread.rootPos+Pos.materialTable]
/*
	; allocate move list
		mov   ecx, AVG_MOVES*MAX_PLY*sizeof.ExtMove
		mov   edx, r15d
	       call   _VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.moveList], rax
*/
        mov  x1, AVG_MOVES*MAX_PLY*sizeof.ExtMove
        mov  w2, w25
         bl  Os_VirtualAllocNuma
        str  x0, [x21, Thread.rootPos+Pos.moveList]
/*
    ; per node memory allocations
	; use cmh table from node(group) or allocate new one
		mov   r14, qword[rdi+NumaNode.parent]
		mov   rax, qword[r14+NumaNode.cmhTable]
		mov   ecx, sizeof.CounterMoveHistoryStats
		mov   edx, r15d
	       test   rax, rax
		jnz   @f
	       call   _VirtualAllocNuma
		mov   qword[r14+NumaNode.cmhTable], rax
	@@:	mov   qword[rbx+Thread.rootPos.counterMoveHistory], rax
*/
        ldr  x24, [x15, NumaNode.parent]
        ldr  x0, [x24, NumaNode.cmhTable]
        mov  x1, sizeof.CounterMoveHistoryStats
        mov  w2, w25
       cbnz  x0, 1f
         bl  Os_VirtualAllocNuma
        str  x0, [x24, NumaNode.cmhTable]
1:      str  x0, [x21, Thread.rootPos+Pos.counterMoveHistory]

/*
	; start the thread and wait for it to enter the idle loop
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock

		mov   byte[rbx+Thread.searching], -1
		lea   rcx, [Thread_IdleLoop]
		mov   rdx, rbx
		mov   r8, rdi
		lea   r9, [rbx+Thread.threadHandle]
	       call   _ThreadCreate
		jmp   .check
    .wait:
		lea   rcx, [rbx+Thread.sleep2]
		lea   rdx, [rbx+Thread.mutex]
	       call   _EventWait
    .check:	mov   al, byte[rbx+Thread.searching]
	       test   al, al
		jnz   .wait
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
.done:
		pop   r15 r14 rdi rsi rbx
		ret
*/
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock

        mov  w0, -1
       strb  w0, [x21, Thread.searching]
        adr  x1, Thread_IdleLoop
        mov  x2, x21
        mov  x3, x15
        add  x4, x21, Thread.threadHandle
         bl  Os_ThreadCreate
          b  Thread_Create.check
Thread_Create.wait:
        add  x1, x21, Thread.sleep2
        add  x2, x21, Thread.mutex
         bl  Os_EventWait
Thread_Create.check:
       ldrb  w0, [x21, Thread.searching]
       cbnz  w0, Thread_Create.wait
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock

        ldp  x24, x25, [sp], 16
        ldp  x14, x15, [sp], 16
        ldp  x21, x30, [sp], 16
        ret




Thread_Delete:
/*
	; ecx: index of thread
	       push   rsi rdi rbx
		mov   esi, ecx
		mov   rbx, qword[threadPool.threadTable+8*rcx]
*/
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x14, x1
        lea  x16, threadPool+ThreadPool.threadTable
        ldr  x21, [x16, x1, lsl 3]
/*
	; terminate the thread
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		mov   byte[rbx+Thread.exit], -1
		lea   rcx, [rbx+Thread.sleep1]
	       call   _EventSignal
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
		lea   rcx, [rbx+Thread.threadHandle]
	       call   _ThreadJoin
*/
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
        mov  w0, -1
       strb  w0, [x21, Thread.exit]
        add  x1, x21, Thread.sleep1
         bl  Os_EventSignal
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock
        add  x1, x21, Thread.threadHandle
         bl  Os_ThreadJoin
/*
	; free move list
		mov   rcx, qword[rbx+Thread.rootPos.moveList]
		mov   edx, AVG_MOVES*MAX_PLY*sizeof.ExtMove
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.moveList], rax
*/
        ldr  x1, [x21, Thread.rootPos+Pos.moveList]
        mov  x2, AVG_MOVES*MAX_PLY*sizeof.ExtMove
         bl  Os_VirtualFree
        str  xzr, [x21, Thread.rootPos+Pos.moveList]
/*
	; free material hash
		mov   rcx, qword[rbx+Thread.rootPos.materialTable]
		mov   edx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.materialTable], rax
*/
        ldr  x1, [x21, Thread.rootPos+Pos.materialTable]
        mov  x2, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
         bl  Os_VirtualFree
        str  xzr, [x21, Thread.rootPos+Pos.materialTable]
/*
	; free pawn hash
		mov   rcx, qword[rbx+Thread.rootPos.pawnTable]
		mov   edx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.pawnTable], rax
*/
        ldr  x1, [x21, Thread.rootPos+Pos.pawnTable]
        mov  x2, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
         bl  Os_VirtualFree
        str  xzr, [x21, Thread.rootPos+Pos.pawnTable]
/*
	; free stats
		mov   rcx, qword[rbx+Thread.rootPos.history]
		mov   edx, sizeof.HistoryStats + sizeof.MoveStats
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.history], rax
		mov   qword[rbx+Thread.rootPos.counterMoves], rax
*/
        ldr  x1, [x21, Thread.rootPos+Pos.history]
        mov  x2, sizeof.HistoryStats + sizeof.MoveStats
         bl  Os_VirtualFree
        str  xzr, [x21, Thread.rootPos+Pos.history]
        str  xzr, [x21, Thread.rootPos+Pos.counterMoves]
/*
	; destroy the vector of root moves
		lea   rcx, [rbx+Thread.rootPos.rootMovesVec]
	       call   RootMovesVec_Destroy
*/
        add  x1, x21, Thread.rootPos+Pos.rootMovesVec
         bl  RootMovesVec_Destroy
/*
	; destroy the state table
		mov   rcx, qword[rbx+Thread.rootPos.stateTable]
		mov   rdx, qword[rbx+Thread.rootPos.stateEnd]
		sub   rdx, rcx
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.state], rax
		mov   qword[rbx+Thread.rootPos.stateTable], rax
		mov   qword[rbx+Thread.rootPos.stateEnd], rax
*/
        ldr  x1, [x21, Thread.rootPos+Pos.stateTable]
        ldr  x2, [x21, Thread.rootPos+Pos.stateEnd]
        sub  x2, x2, x1
         bl  Os_VirtualFree
        str  xzr, [x21, Thread.rootPos+Pos.state]
        str  xzr, [x21, Thread.rootPos+Pos.stateTable]
        str  xzr, [x21, Thread.rootPos+Pos.stateEnd]
/*
	; destroy sync objects
		lea   rcx, [rbx+Thread.sleep2]
	       call   _EventDestroy
		lea   rcx, [rbx+Thread.sleep1]
	       call   _EventDestroy
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexDestroy
*/
        add  x1, x21, Thread.sleep2
         bl  Os_EventDestroy
        add  x1, x21, Thread.sleep1
         bl  Os_EventDestroy
        add  x1, x21, Thread.mutex
         bl  Os_MutexDestroy
/*
	; free self
		mov   rcx, qword[threadPool.threadTable+8*rsi]
		mov   edx, sizeof.Thread
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[threadPool.threadTable+8*rsi], rax

		pop   rbx rdi rsi
		ret
*/
        lea  x16, threadPool+ThreadPool.threadTable
        ldr  x1, [x16, x14, lsl 3]
         bl  Os_VirtualFree
        lea  x16, threadPool+ThreadPool.threadTable
        str  xzr, [x16, x14, lsl 3]
        ldp  x14, x15, [sp], 16
        ldp  x21, x30, [sp], 16
        ret








Thread_IdleLoop:
/*
	; in: rcx address of Thread struct
	       push   rbx rsi rdi
		mov   rbx, rcx
		lea   rdi, [Thread_Think]
		lea   rdx, [MainThread_Think]
		mov   eax, dword[rbx+Thread.idx]
	       test   eax, eax
	      cmovz   rdi, rdx
		jmp   .lock
*/
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x21, x1
        adr  x15, Thread_Think
        adr  x2, MainThread_Think
        ldr  w0, [x21, Thread.idx]
        cmp  w0, 0
       csel  x15, x2, x15, eq
          b  Thread_IdleLoop.lock
Thread_IdleLoop.loop:
/*
		mov   rcx, rbx
	       call   rdi
*/
        mov  x1, x21
        blr  x15
Thread_IdleLoop.lock:
/*
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		mov   byte[rbx+Thread.searching], 0
*/
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
       strb  wzr, [x21, Thread.searching]

Thread_IdleLoop.check_exit:
/*
		mov   al, byte[rbx+Thread.exit]
	       test   al, al
		jnz   .unlock
		lea   rcx, [rbx+Thread.sleep2]
	       call   _EventSignal
		lea   rcx, [rbx+Thread.sleep1]
		lea   rdx, [rbx+Thread.mutex]
	       call   _EventWait
		mov   al, byte[rbx+Thread.searching]
	       test   al, al
		 jz   .check_exit
*/

Display "hello from thread %x21\n"

       ldrb  w0, [x21, Thread.exit]
       cbnz  w0, Thread_IdleLoop.unlock

        add  x1, x21, Thread.sleep2
         bl  Os_EventSignal

        add  x1, x21, Thread.sleep1
        add  x2, x21, Thread.mutex
         bl  Os_EventWait

       ldrb  w0, [x21, Thread.searching]
        cbz  w0, Thread_IdleLoop.check_exit

Thread_IdleLoop.unlock:
/*
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
*/
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock

Thread_IdleLoop.check_out:
/*
		mov   al, byte[rbx+Thread.exit]
	       test   al, al
		 jz   .loop
		pop   rdi rsi rbx
		ret
*/
       ldrb  w0, [x21, Thread.exit]
        cbz  w0, Thread_IdleLoop.loop
        stp  x14, x15, [sp], 16
        stp  x21, x30, [sp], 16
        ret











Thread_StartSearching:
/*
	; rcx: address of Thread struct
	       push   rbx
		mov   rbx, rcx
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		mov   byte[rbx+Thread.searching], -1
*/
        stp  x21, x30, [sp, -16]!
        mov  x21, x1
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
        mov  w0, -1
       strb  w0, [x21, Thread.searching]
Thread_StartSearching.signal:
/*
                lea   rcx, [rbx+Thread.sleep1]
	       call   _EventSignal
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
		pop   rbx
		ret
*/
        add  x1, x21, Thread.sleep1
         bl  Os_EventSignal
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock
        ldp  x21, x30, [sp], 16
        ret
Thread_StartSearching_TRUE:
/*
	; rcx: address of Thread struct
	       push   rbx
		mov   rbx, rcx
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		jmp   Thread_StartSearching.signal
*/
        stp  x21, x30, [sp, -16]!
        mov  x21, x1
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
          b  Thread_StartSearching.signal
        

Thread_WaitForSearchFinished:
/*	; rcx: address of Thread struct
	       push   rsi rdi rbx
		mov   rbx, rcx
		cmp   al, byte[rbx]
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		jmp   .check
*/
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x21, x1
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
          b  Thread_WaitForSearchFinished.check

Thread_WaitForSearchFinished.wait:
/*
		lea   rcx, [rbx+Thread.sleep2]
		lea   rdx, [rbx+Thread.mutex]
	       call   _EventWait
*/
        add  x1, x21, Thread.sleep2
        add  x2, x21, Thread.mutex
         bl  Os_EventWait

Thread_WaitForSearchFinished.check:
/*
 	mov   al, byte[rbx+Thread.searching]
	       test   al, al
		jnz   .wait
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
		pop   rbx rdi rsi
		ret
*/
       ldrb  w0, [x21, Thread.searching]
       cbnz  w0, Thread_WaitForSearchFinished.wait
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock
        ldp  x14, x15, [sp], 16
        ldp  x21, x30, [sp], 16
        ret

Thread_Wait:
/*	; rcx: address of Thread struct
	; rdx: address of bool
	       push   rsi rdi rbx
		mov   rbx, rcx
		mov   rdi, rdx
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexLock
		jmp   .check
*/
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x21, x1
        mov  x15, x2
        add  x1, x21, Thread.mutex
         bl  Os_MutexLock
          b  Thread_Wait.check

Thread_Wait.wait:
/*
		lea   rcx, [rbx+Thread.sleep1]
		lea   rdx, [rbx+Thread.mutex]
	       call   _EventWait
*/
        add  x1, x21, Thread.sleep1
        add  x2, x21, Thread.mutex
         bl  Os_EventWait

Thread_Wait.check:
/*
                mov   al, byte[rdi]
	       test   al, al
		 jz   .wait
		lea   rcx, [rbx+Thread.mutex]
	       call   _MutexUnlock
		pop   rbx rdi rsi
		ret
*/
       ldrb  w0, [x15]
        cbz  w0, Thread_Wait.wait
        add  x1, x21, Thread.mutex
         bl  Os_MutexUnlock
        ldp  x14, x15, [sp], 16
        ldp  x21, x30, [sp], 16
        ret
