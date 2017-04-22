; Search::clear() resets search state to zero, to obtain reproducible results

Search_Clear:
	       push   rbx rsi rdi

	       call   MainHash_Clear
		mov   byte[mainHash.date], 0

		mov   esi, dword[threadPool.threadCnt]
.NextThread:
		sub   esi, 1
		 js   .ThreadsDone
		mov   rbx, qword[threadPool.threadTable+8*rsi]

	; mainThread.previousScore is used in the time management part of idloop
	;  +VALUE_INFINITE causes us to think alot on the first move
		mov   dword[rbx+Thread.previousScore], VALUE_INFINITE

	; clear thread stats
		mov   rdi, qword[rbx+Thread.rootPos.history]
		mov   ecx, (sizeof.HistoryStats + sizeof.MoveStats)/4
		xor   eax, eax
	  rep stosd

	; clear cmh table - some overlap possible here
		mov   rdi, qword[rbx+Thread.rootPos.counterMoveHistory]
		mov   ecx, (sizeof.CounterMoveHistoryStats)/4
		xor   eax, eax
	  rep stosd

                mov   rdi, qword[rbx+Thread.rootPos.counterMoveHistory]
                add   rdi, CmhDeadOffset
		mov   ecx, 16*64
		mov   eax, CounterMovePruneThreshold - 1
	  rep stosd

		jmp   .NextThread
.ThreadsDone:

		pop   rdi rsi rbx
		ret
