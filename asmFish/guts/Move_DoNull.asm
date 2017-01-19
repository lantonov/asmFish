
	      align   16
Move_DoNull:
	       push   rsi rdi r12 r13 r14 r15

ProfileInc Move_DoNull


match =1, DEBUG {
	       push   rcx rdi
		lea   rdi, [DebugOutput]
		mov   qword[rbp+Pos.state], rbx
	       call   Position_PrintSmall
		mov   eax, 10
	      stosd
		mov   qword[rbp+Pos.state], rbx
	       call   Position_IsLegal
	       test   eax, eax
		jnz   Move_DoNull_posill
		pop   rdi rcx
}

	; null move doesn't use a move picker
		mov   r12, qword[rbx-1*sizeof.State+State.endMoves]
	; copy the other important info
	      movzx   eax, word[rbx+State.rule50]
		mov   edx, dword[rbx+State.epSquare]
		mov   r8, qword[rbx+State.key]
		mov   r9, qword[rbx+State.pawnKey]
		mov   r10, qword[rbx+State.materialKey]
		mov   r11, qword[rbx+State.psq] 	; copy psq and npMaterial

	     Assert   e, qword[rbx+State.checkersBB], 0, 'assertion checkersBB = 0 failed in Move_DoNull'

		mov   qword[rbx+State.endMoves], r12
		add   rbx, sizeof.State
		xor   dword[rbp+Pos.sideToMove], 1
		xor   r8, qword[Zobrist_side]

	       test   edx, 63
		jnz   .epsq
.epsq_ret:
		add   eax, 1		 ; increment 50moves
		xor   ecx, ecx
		mov   qword[rbx+State.key], r8
		mov   qword[rbx+State.pawnKey], r9
		mov   qword[rbx+State.materialKey], r10
		mov   qword[rbx+State.psq], r11
		mov   dword[rbx+State.rule50], eax
		mov   dword[rbx+State.epSquare], edx
		mov   qword[rbx+State.checkersBB], rcx

		and   r8, qword[mainHash.mask]
		shl   r8, 5
		add   r8, qword[mainHash.table]
	prefetchnta   [r8]


match =1, DEBUG {
	       push   rcx
		mov   qword[rbp+Pos.state], rbx
	       call   Position_IsLegal
	       test   eax, eax
		jnz   Move_DoNull_post_posill
		pop   rcx
}

		jmp   SetCheckInfo.AfterPrologue

	      align   8
.epsq:
		mov   ecx, edx
		and   edx, 0xFFFFFF00
		add   edx, 0x00000040
		and   ecx, 7
		xor   r8, qword[Zobrist_Ep+8*rcx]
		jmp   .epsq_ret




match =1, DEBUG {

Move_DoNull_posill:
		lea   rdi, [Output]
	     szcall   PrintString, 'position did not pass Position_IsLegal in DoNullMove'
		jmp   Move_DoNull_GoError
Move_DoNull_post_posill:
		lea   rdi, [Output]
	     szcall   PrintString, 'position not legal after making null move in DoNullMove'
		jmp   Move_DoNull_GoError


		Move_DoNull_GoError:
		PrintNewLine
		mov   rcx, qword[rbp+Pos.debugQWORD1]
	       call   PrintString
		mov   al, 10
	      stosb
		lea   rcx, [DebugOutput]
	       call   PrintString
		xor   eax, eax
	      stosd
		lea   rdi, [Output]
	       call   _ErrorBox
int3

}
