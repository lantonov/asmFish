
macro UpdateCmStats ss, offset, bonus32, absbonus, t1
	; bonus32 is 32*bonus
	; absbonus is abs(bonus)
	; clobbers rax, rcx, rdx, t1
  local over1, over2, over3
	     Assert   b, absbonus, 324, 'assertion abs(bonus)<324 failed in UpdateCmStats'

		mov   t1, qword[ss-1*sizeof.State+State.counterMoves]
		cmp   dword[ss-1*sizeof.State+State.currentMove], 1
		 jl   over1
	apply_bonus   (t1+4*(offset)), bonus32, absbonus, 936
over1:

		mov   t1, qword[ss-2*sizeof.State+State.counterMoves]
		cmp   dword[ss-2*sizeof.State+State.currentMove], 1
		 jl   over2
	apply_bonus   (t1+4*(offset)), bonus32, absbonus, 936
over2:

		mov   t1, qword[ss-4*sizeof.State+State.counterMoves]
		cmp   dword[ss-4*sizeof.State+State.currentMove], 1
		 jl   over3
	apply_bonus   (t1+4*(offset)), bonus32, absbonus, 936
over3:
end macro




macro UpdateStats move, quiets, quietsCnt, bonus32, absbonus, prevOffset
	; clobbers rax, rcx, rdx, r8, r9
	; it also might clobber rsi and change the sign of bonus32
  local DontUpdateKillers, DontUpdateOpp, BonusTooBig, NextQuiet, Return


  if DEBUG
		mov   eax, dword[rbx-1*sizeof.State+State.currentMove]
		and   eax, 63
	      movzx   ecx, byte[rbp+Pos.board+rax]
		shl   ecx, 6
		add   eax, ecx
	     Assert   e, prevOffset, rax, 'assertion prevOffset = offset of [piece_on(prevSq),prevSq] failed in UpdateStats'
  end if


		mov   eax, dword[rbx+State.killers+4*0]
		cmp   eax, move
		 je   DontUpdateKillers
		mov   dword[rbx+State.killers+4*1], eax
		mov   dword[rbx+State.killers+4*0], move
DontUpdateKillers:

		cmp   dword[rbx-1*sizeof.State+State.currentMove], 1
		 jl   DontUpdateOpp
		mov   r8, qword[rbp+Pos.counterMoves]
		mov   dword[r8+4*prevOffset], move
DontUpdateOpp:

	       imul   bonus32, absbonus, 32
		cmp   absbonus, 324
		jae   BonusTooBig

		mov   eax, move
		and   eax, 64*64-1
		mov   r8d, dword[rbp+Pos.sideToMove]
		shl   r8d, 12+2
		add   r8, qword[rbp+Pos.history]
		lea   r8, [r8+4*rax]
	apply_bonus   r8, bonus32, absbonus, 324

		mov   r9d, move
		and   r9d, 63
		mov   eax, move
		shr   eax, 6
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
		shl   eax, 6
		add   r9d, eax
      UpdateCmStats   (rbx-0*sizeof.State), r9, bonus32, absbonus, r8


  match =0, quiets
  else
	; Decrease all the other played quiet moves
		neg   bonus32
		xor   esi, esi
		cmp   esi, quietsCnt
		 je   Return
NextQuiet:
		mov   edx, dword[quiets+4*rsi]
		mov   ecx, edx
		mov   eax, edx

		and   edx, 64*64-1
		mov   r8d, dword[rbp+Pos.sideToMove]
		shl   r8d, 12+2
		add   r8, qword[rbp+Pos.history]
		lea   r8, [r8+4*rdx]

		and   ecx, 63
		shr   eax, 6
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
		shl   eax, 6
		lea   r9d, [rax+rcx]

	apply_bonus   r8, bonus32, absbonus, 324

      UpdateCmStats   (rbx-0*sizeof.State), r9, bonus32, absbonus, r8

		add   esi, 1
		cmp   esi, quietsCnt
		 jb   NextQuiet
  end match

BonusTooBig:
Return:
end macro
