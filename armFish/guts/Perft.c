
Perft_Root:
/*
	       push   rbx rsi rdi r14 r15
virtual at rsp
 .time	   dq ?
 .movelist rb sizeof.ExtMove*MAX_MOVES
 .lend	   rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		mov   rbx, qword[rbp+Pos.state]
		mov   r15d, ecx
		xor   r14, r14

	       call   _GetTime
		mov   qword[.time], rax

	       call   SetCheckInfo

		lea   rdi, [.movelist]
		mov   rsi, rdi
	       call   Gen_Legal
		xor   eax, eax
		mov   dword[rdi], eax
*/
Perft_Root.MoveLoop:
/*
		mov   ecx, dword[rsi]
	       test   ecx, ecx
		 jz   .MoveLoopDone
		mov   ecx, dword[rsi]
	       call   Move_GivesCheck
		mov   edx, eax
		mov   ecx, dword[rsi]
	       call   Move_Do__PerftGen_Root
		mov   eax, 1
		lea   ecx, [r15-1]
		cmp   r15d, 1
		jbe   @f
	       call   Perft_Branch
	@@:	add   r14, rax
	       push   rax
		mov   ecx, dword[rsi]
	       call   Move_Undo

		lea   rdi, [Output]
		mov   ecx, dword[rsi]
		mov   edx, dword[rbp+Pos.chess960]
	       call   PrintUciMove
		mov   eax, ' :  '
	      stosd
		pop   rax
	       call   PrintUnsignedInteger
       PrintNewLine
	       call   _WriteOut_Output

		add   rsi, sizeof.ExtMove
		jmp   .MoveLoop
*/
Perft_Root.MoveLoopDone:
/*
	       call   _GetTime
		sub   rax, qword[.time]
		mov   qword[.time], rax

		lea   rdi, [Output]
		mov   al, '='
		mov   ecx, 27
	  rep stosb
       PrintNewLine

		mov   rax, 'Total ti'
	      stosq
		mov   rax, 'me (ms) '
	      stosq
		mov   ax, ': '
	      stosw
		mov   rax, qword[.time]
	       call   PrintUnsignedInteger
       PrintNewLine

		mov   rax, 'Nodes se'
	      stosq
		mov   rax, 'arched  '
	      stosq
		mov   ax, ': '
	      stosw
		mov   rax, r14
	       call   PrintUnsignedInteger
       PrintNewLine

		mov   rax, 'Nodes/se'
	      stosq
		mov   rax, 'cond    '
	      stosq
		mov   ax, ': '
	      stosw

		mov   rax, r14
		mov   ecx, 1000
		mul   rcx
		mov   rcx, qword[.time]
		cmp   rcx, 1
		adc   rcx, 0
		div   rcx
	       call   PrintUnsignedInteger
       PrintNewLine

	       call   _WriteOut_Output
*/
Perft_Root.Done:
/*
		add   rsp, .localsize
		pop   r15 r14 rdi rsi rbx
		ret
*/



Perft_Branch:
/*
	       push   rsi r14 r15
virtual at rsp
.movelist  rb sizeof.ExtMove*MAX_MOVES
.lend	   rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		lea   r15d, [rcx-1]
		xor   r14, r14
		lea   rdi, [.movelist]
		mov   rsi, rdi
		cmp   ecx, 1
		 ja   .DepthN
*/
Perft_Root.Depth1:
/*
	       call   Gen_Legal
		mov   rax, rdi
		sub   rax, rsi
		shr   eax, 3	      ; assume sizeof.ExtMove = 8
		add   rsp, .localsize
		pop   r15 r14 rsi
		ret

*/
Perft_Root.DepthN:
/*
	       call   Gen_Legal
		xor   eax, eax
		mov   dword[rdi], eax

		mov   ecx, dword[rsi]
	       test   ecx, ecx
		 jz   .DepthNDone
*/
Perft_Root.DepthNLoop:
/*
	       call   Move_GivesCheck
		mov   edx, eax
		mov   ecx, dword[rsi]
	       call   Move_Do__PerftGen_Branch
		mov   ecx, r15d
	       call   Perft_Branch
		add   r14, rax
		mov   ecx, dword[rsi]
		add   rsi, sizeof.ExtMove
	       call   Move_Undo
		mov   ecx, dword[rsi]
	       test   ecx, ecx
		jnz   .DepthNLoop
*/
Perft_Root.DepthNDone:
/*
		mov   rax, r14
		add   rsp, .localsize
		pop   r15 r14 rsi
		ret
*/
