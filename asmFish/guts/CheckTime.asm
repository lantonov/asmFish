	      align   16
CheckTime:
; out eax = 0 if a lot of time has passed
;     eax = -1 if not a lot of time has passed
	       push   rcx
 AssertStackAligned   'CheckTime'

		xor   eax, eax
		cmp   al, byte[limits.ponder]
		jne   .return

	       call   _GetTime
		sub   rax, qword[time.startTime]
		add   rax, 10
		cmp   byte[limits.useTimeMgmt], 0
		 je   @f
		cmp   rax, qword[time.maximumTime]
		 ja   .stop
	@@:
		cmp   dword[limits.movetime], 0
		 je   @f
		sub   rax, 10
		cmp   eax, dword[limits.movetime]
		jae   .stop
	@@:
		cmp   byte[limits.nodes], 0
		 je   @f
	       call   ThreadPool_NodesSearched_TbHits
		cmp   rax, qword[limits.nodes]
		jae   .stop
	@@:
.return:
		sub   rax, CURRMOVE_MIN_TIME
		sar   eax, 31
		pop   rcx
		ret

.stop:

match =1, VERBOSE {
push   rax
GD_String 'setting signals.stop in CheckTime'
GD_NewLine
pop   rax
}
		 or   eax, -1
		mov   byte[signals.stop], al
		pop   rcx
		ret