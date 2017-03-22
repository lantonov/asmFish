
Search_Clear:
/*
	       push   rbx rsi rdi

	       call   MainHash_Clear
		mov   byte[mainHash.date], 0

		mov   esi, dword[threadPool.threadCnt]
*/
        stp  x29, x30, [sp, -16]!
         bl  MainHash_Clear
        lea  x7, mainHash
       strb  wzr, [x7, MainHash.date]
        lea  x7, threadPool
        ldr  w16, [x7, ThreadPool.threadCnt]

Search_Clear.NextThread:
/*
		sub   esi, 1
		 js   .ThreadsDone
		mov   rbx, qword[threadPool.threadTable+8*rsi]

	; mainThread.previousScore is used in the time management part of idloop
	;  +VALUE_INFINITE causes us to think alot on the first move
		mov   dword[rbx+Thread.previousScore], VALUE_INFINITE
*/
       subs  x16, x16, 1
        bmi  Search_Clear.ThreadsDone
        lea  x7, threadPool
        add  x7, x7, ThreadPool.threadTable
        ldr  x14, [x7, x16, lsl 3]
        mov  w4, VALUE_INFINITE
        str  w4, [x14, Thread.previousScore]
/*
	; clear thread stats
		mov   rdi, qword[rbx+Thread.rootPos.history]
		mov   ecx, (sizeof.HistoryStats + sizeof.MoveStats)/4
		xor   eax, eax
	  rep stosd
*/
        ldr  x0, [x14, Thread.rootPos + Pos.history]
        mov  x1, 0
        mov  x2, sizeof.HistoryStats + sizeof.MoveStats
         bl  MemoryFill
/*
	; clear cmh table - some overlap possible here
		mov   rdi, qword[rbx+Thread.rootPos.counterMoveHistory]
		mov   ecx, (sizeof.CounterMoveHistoryStats)/4
		xor   eax, eax
	  rep stosd

		jmp   .NextThread
*/
        ldr  x0, [x14, Thread.rootPos + Pos.counterMoveHistory]
        mov  x1, 0
        mov  x2, sizeof.CounterMoveHistoryStats
         bl  MemoryFill
          b  Search_Clear.NextThread

Search_Clear.ThreadsDone:
/*
		pop   rdi rsi rbx
		ret
*/
        ldp  x29, x30, [sp], 16
        ret
