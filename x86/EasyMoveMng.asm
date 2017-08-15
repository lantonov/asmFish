
EasyMoveMng_Clear:
		lea   rcx, [easyMoveMng]
		xor   eax, eax
		mov   qword[rcx+EasyMoveMng.pv+4*0], rax
		mov   qword[rcx+EasyMoveMng.pv+4*2], rax
		mov   qword[rcx+EasyMoveMng.expectedPosKey], rax
		mov   dword[rcx+EasyMoveMng.stableCnt], eax
		ret

EasyMoveMng_Get:
	; in: rcx key
		xor   eax, eax
		cmp   rcx, qword[easyMoveMng.expectedPosKey]
	      cmove   eax, dword[easyMoveMng.pv+4*2]
		ret

EasyMoveMng_Update:
	; in: rbp position
	;     rbx state
	;     rcx address of RootMove struct

	       push   rsi
		lea   rsi, [easyMoveMng]

		mov   edx, dword[rsi+EasyMoveMng.stableCnt]
		xor   r8d, r8d
		add   edx, 1
		mov   eax, dword[rcx+RootMove.pv+4*2]
		cmp   eax, dword[rsi+EasyMoveMng.pv+4*2]
	     cmovne   edx, r8d
		mov   dword[rsi+EasyMoveMng.stableCnt], edx

		mov   rax, qword[rcx+RootMove.pv+4*0]
		cmp   rax, qword[rsi+EasyMoveMng.pv+4*0]
		jne   @f
		mov   ecx, dword[rcx+RootMove.pv+4*2]
		cmp   ecx, dword[rsi+EasyMoveMng.pv+4*2]
		 je   .done
	@@:
		mov   qword[rsi+EasyMoveMng.pv+4*0], rax
		mov   dword[rsi+EasyMoveMng.pv+4*2], ecx

	       call   SetCheckInfo
		mov   ecx, dword[rsi+EasyMoveMng.pv+4*0]
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+EasyMoveMng.pv+4*0]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__EasyMoveMng
	       call   SetCheckInfo
		mov   ecx, dword[rsi+EasyMoveMng.pv+4*1]
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+EasyMoveMng.pv+4*1]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__EasyMoveMng

		mov   rax, qword[rbx+State.key]
		mov   qword[rsi+EasyMoveMng.expectedPosKey], rax

		mov   ecx, dword[rsi+EasyMoveMng.pv+4*1]
	       call   Move_Undo
		mov   ecx, dword[rsi+EasyMoveMng.pv+4*0]
	       call   Move_Undo

.done:
		pop   rsi
		ret
