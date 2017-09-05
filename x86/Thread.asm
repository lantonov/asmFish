
ThreadIdxToNode:
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
.NextNode:
                sub   edx, dword[r10+rax+NumaNode.coreCnt]
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



Thread_Create:
	; in: ecx index of thread
	       push   rbx rsi rdi r14 r15
		mov   esi, ecx

	; get the right node to put this thread
	       call   ThreadIdxToNode
		mov   rdi, rax
		mov   r15d, dword[rdi+NumaNode.nodeNumber]

	; allocate self
		mov   ecx, sizeof.Thread
		mov   edx, r15d
	       call   Os_VirtualAllocNuma
		mov   qword[threadPool.threadTable+8*rsi], rax
		mov   rbx, rax

	; fill in address of numanode struct
		mov   qword[rbx+Thread.numaNode], rdi

	; init some thread data
		xor   eax, eax
		mov   byte[rbx+Thread.exit], al
                mov   dword[rbx+Thread.resetCnt], eax   ; resetCnt is set to minimum in 
                mov   dword[rbx+Thread.callsCnt], eax   ;  ThreadPool_StartThinking
		mov   dword[rbx+Thread.idx], esi
		mov   qword[rbx+Thread.numaNode], rdi
if USE_VARIETY = 1
               call   Os_GetTime
                xor   rax, rdx
                 or   rax, 1
mov rax, 1
                mov   qword[rbx+Thread.randSeed], rax
end if

    ; per thread memory allocations
	; create sync objects
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexCreate
		lea   rcx, [rbx+Thread.sleep1]
	       call   Os_EventCreate
		lea   rcx, [rbx+Thread.sleep2]
	       call   Os_EventCreate

	; the states will be allocated when copying position to thread
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos+Pos.state], rax
		mov   qword[rbx+Thread.rootPos+Pos.stateTable], rax
		mov   qword[rbx+Thread.rootPos+Pos.stateEnd], rax

	; create the vector of root moves
		lea   rcx, [rbx+Thread.rootPos+Pos.rootMovesVec]
		mov   edx, r15d
	       call   RootMovesVec_Create

	; allocate stats
		mov   ecx, sizeof.HistoryStats + sizeof.MoveStats
		mov   edx, r15d
	       call   Os_VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos.history], rax
		add   rax, sizeof.HistoryStats
		mov   qword[rbx+Thread.rootPos.counterMoves], rax

	; allocate pawn hash
		mov   ecx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
		mov   edx, r15d
	       call   Os_VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.pawnTable], rax

	; allocate material hash
		mov   ecx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
		mov   edx, r15d
	       call   Os_VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.materialTable], rax

	; allocate move list
		mov   ecx, AVG_MOVES*MAX_PLY*sizeof.ExtMove
		mov   edx, r15d
	       call   Os_VirtualAllocNuma
		mov   qword[rbx+Thread.rootPos+Pos.moveList], rax

    ; per node memory allocations
	; use cmh table from node(group) or allocate new one
		mov   r14, qword[rdi+NumaNode.parent]
		mov   rax, qword[r14+NumaNode.cmhTable]
		mov   ecx, sizeof.CounterMoveHistoryStats
		mov   edx, r15d
	       test   rax, rax
		jnz   @f
	       call   Os_VirtualAllocNuma
		mov   qword[r14+NumaNode.cmhTable], rax
	@@:	
                mov   qword[rbx+Thread.rootPos.counterMoveHistory], rax

	; start the thread and wait for it to enter the idle loop
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock

		mov   byte[rbx+Thread.searching], -1
		lea   rcx, [Thread_IdleLoop]
		mov   rdx, rbx
		mov   r8, rdi
		lea   r9, [rbx+Thread.threadHandle]
	       call   Os_ThreadCreate
		jmp   .Check
    .Wait:
		lea   rcx, [rbx+Thread.sleep2]
		lea   rdx, [rbx+Thread.mutex]
	       call   Os_EventWait
    .Check:     mov   al, byte[rbx+Thread.searching]
	       test   al, al
		jnz   .Wait
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock

		pop   r15 r14 rdi rsi rbx
		ret


Thread_Delete:
	; ecx: index of thread
	       push   rsi rdi rbx
		mov   esi, ecx
		mov   rbx, qword[threadPool.threadTable+8*rcx]

	; terminate the thread
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		mov   byte[rbx+Thread.exit], -1
		lea   rcx, [rbx+Thread.sleep1]
	       call   Os_EventSignal
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock
		lea   rcx, [rbx+Thread.threadHandle]
	       call   Os_ThreadJoin

	; free move list
		mov   rcx, qword[rbx+Thread.rootPos.moveList]
		mov   edx, AVG_MOVES*MAX_PLY*sizeof.ExtMove
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.moveList], rax

	; free material hash
		mov   rcx, qword[rbx+Thread.rootPos.materialTable]
		mov   edx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.materialTable], rax

	; free pawn hash
		mov   rcx, qword[rbx+Thread.rootPos.pawnTable]
		mov   edx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.pawnTable], rax

	; free stats
		mov   rcx, qword[rbx+Thread.rootPos.history]
		mov   edx, sizeof.HistoryStats + sizeof.MoveStats
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.history], rax
		mov   qword[rbx+Thread.rootPos.counterMoves], rax

	; destroy the vector of root moves
		lea   rcx, [rbx+Thread.rootPos.rootMovesVec]
	       call   RootMovesVec_Destroy

	; destroy the state table
		mov   rcx, qword[rbx+Thread.rootPos.stateTable]
		mov   rdx, qword[rbx+Thread.rootPos.stateEnd]
		sub   rdx, rcx
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[rbx+Thread.rootPos.state], rax
		mov   qword[rbx+Thread.rootPos.stateTable], rax
		mov   qword[rbx+Thread.rootPos.stateEnd], rax

	; destroy sync objects
		lea   rcx, [rbx+Thread.sleep2]
	       call   Os_EventDestroy
		lea   rcx, [rbx+Thread.sleep1]
	       call   Os_EventDestroy
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexDestroy

	; free self
		mov   rcx, qword[threadPool.threadTable+8*rsi]
		mov   edx, sizeof.Thread
	       call   Os_VirtualFree
		xor   eax, eax
		mov   qword[threadPool.threadTable+8*rsi], rax

		pop   rbx rdi rsi
		ret


Thread_IdleLoop:
	; in: rcx address of Thread struct
	       push   rbx rsi rdi

if VERSION_OS = 'L'
		mov   rbx, rcx
else if VERSION_OS = 'W'
		mov   rbx, rcx
else if VERSION_OS = 'X'
		mov   rbx, rdi
end if

		lea   rdi, [Thread_Think]
		lea   rdx, [MainThread_Think]
		mov   eax, dword[rbx+Thread.idx]
	       test   eax, eax
	      cmovz   rdi, rdx

		jmp   .Lock
.Loop:
		mov   rcx, rbx
	       call   rdi
.Lock:
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		mov   byte[rbx+Thread.searching], 0
    .CheckExit:
		mov   al, byte[rbx+Thread.exit]
	       test   al, al
		jnz   .Unlock
		lea   rcx, [rbx+Thread.sleep2]
	       call   Os_EventSignal
		lea   rcx, [rbx+Thread.sleep1]
		lea   rdx, [rbx+Thread.mutex]
	       call   Os_EventWait
		mov   al, byte[rbx+Thread.searching]
	       test   al, al
		 jz   .CheckExit
    .Unlock:
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock
.CheckOut:
		mov   al, byte[rbx+Thread.exit]
	       test   al, al
		 jz   .Loop
if VERSION_OS = 'W'
		xor   ecx, ecx
	       call   Os_ExitThread
else if VERSION_OS = 'X'
		xor   edi, edi
	       call   Os_ExitThread
end if
		pop   rdi rsi rbx
		ret



Thread_StartSearching:
	; rcx: address of Thread struct
	       push   rbx
		mov   rbx, rcx
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		mov   byte[rbx+Thread.searching], -1
.Signal:        lea   rcx, [rbx+Thread.sleep1]
	       call   Os_EventSignal
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock
		pop   rbx
		ret

Thread_StartSearching_TRUE:
	; rcx: address of Thread struct
	       push   rbx
		mov   rbx, rcx
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		jmp   Thread_StartSearching.Signal


Thread_WaitForSearchFinished:
	; rcx: address of Thread struct
	       push   rsi rdi rbx
		mov   rbx, rcx
		cmp   al, byte[rbx]
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		jmp   .Check
.Wait:          lea   rcx, [rbx+Thread.sleep2]
		lea   rdx, [rbx+Thread.mutex]
	       call   Os_EventWait
.Check:         mov   al, byte[rbx+Thread.searching]
	       test   al, al
		jnz   .Wait
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock
		pop   rbx rdi rsi
		ret



Thread_Wait:
	; rcx: address of Thread struct
	; rdx: address of bool
	       push   rsi rdi rbx
		mov   rbx, rcx
		mov   rdi, rdx
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexLock
		jmp   .Check
.Wait:          lea   rcx, [rbx+Thread.sleep1]
		lea   rdx, [rbx+Thread.mutex]
	       call   Os_EventWait
.Check:         mov   al, byte[rdi]
	       test   al, al
		 jz   .Wait
		lea   rcx, [rbx+Thread.mutex]
	       call   Os_MutexUnlock
		pop   rbx rdi rsi
		ret
