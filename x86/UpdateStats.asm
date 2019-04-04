
macro UpdateCmStats ss, offset, weightedbonus, absbonus, t1
	; weightedbonus is bonus * BONUS_MULTIPLIER
	; absbonus is abs(bonus)
	; clobbers rax, rcx, rdx, t1
		local over1, over2, over3
		Assert   b, absbonus, BONUS_MAX, 'assertion abs(bonus)<BONUS_MAX failed in UpdateCmStats'

		mov   t1, qword[ss-1*sizeof.State+State.counterMoves]
		cmp   dword[ss-1*sizeof.State+State.currentMove], 1
		jl   over1

		cms_update   (t1+4*(offset)), weightedbonus, absbonus

over1:
		mov   t1, qword[ss-2*sizeof.State+State.counterMoves]
		cmp   dword[ss-2*sizeof.State+State.currentMove], 1
		jl   over2

		cms_update  (t1+4*(offset)), weightedbonus, absbonus

over2:
		mov   t1, qword[ss-4*sizeof.State+State.counterMoves]
		cmp   dword[ss-4*sizeof.State+State.currentMove], 1
		jl   over3

		cms_update   (t1+4*(offset)), weightedbonus, absbonus

over3:
end macro

macro UpdateStats move, quiets, quietsCnt, weightedbonus, absbonus, prevOffset
	; clobbers rax, rcx, rdx, r8, r9
	; it also might clobber rsi and change the sign of weightedbonus
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

		imul   weightedbonus, absbonus, BONUS_MULTIPLIER
		cmp   absbonus, BONUS_MAX
		jae   BonusTooBig

		mov   eax, move
		and   eax, 64*64-1
		mov   r8d, dword[rbp+Pos.sideToMove]
		shl   r8d, 12+2
		add   r8, qword[rbp+Pos.history]
		lea   r8, [r8+4*rax]
		abs_bonus weightedbonus, r9d
		history_update r8, weightedbonus, r9d

		mov   r9d, move
		and   r9d, 63
		mov   eax, move
		shr   eax, 6
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
		shl   eax, 6
		add   r9d, eax
		abs_bonus weightedbonus, r12d
		UpdateCmStats  (rbx-0*sizeof.State), r9, weightedbonus, r12d, r8

  match =0, quiets
  else
	; Decrease all the other played quiet moves
		neg   weightedbonus
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

		abs_bonus weightedbonus, r10d

		history_update r8, weightedbonus, r10d

		UpdateCmStats (rbx-0*sizeof.State), r9, weightedbonus, r10d, r8

		add   esi, 1
		cmp   esi, quietsCnt
		 jb   NextQuiet
  end match

BonusTooBig:
Return:
end macro


macro UpdateCaptureStats move, captures, captureCnt, bonusW, absbonus
	; clobbers rax, rcx, rdx, r8, r9
	; it also might clobber rsi
  local BonusTooBig, NextCapture, Return

            imul  bonusW, absbonus, BONUS_MULTIPLIER;
            mov  r9, qword[rbp + Pos.captureHistory]
            cmp  absbonus, BONUS_MAX
            jae  BonusTooBig

            test r8b, dl
            jz   @1f

            mov  eax, move
            mov  ecx, move
            shr  ecx, 6
            and  eax, 63
            and  ecx, 63
          movzx  ecx, byte[rbp + Pos.board + rcx]
            shl  ecx, 6
            add  ecx, eax
          movzx  eax, byte[rbp + Pos.board + rax]
            and  eax, 7
            shl  ecx, 3
            add  ecx, eax
            lea  r8, [r9 + 4*rcx]
            abs_bonus bonusW, r10d
            apply_capture_bonus  r8, bonusW, r10d

@1:
  match =0, quiets
  else
            neg  bonusW
            xor  esi, esi
            cmp  esi, captureCnt
             je  Return
NextCapture:
            mov  eax, dword[captures + 4*rsi]
            mov  ecx, dword[captures + 4*rsi]
            shr  ecx, 6
            and  eax, 63
            and  ecx, 63
            lea  esi, [rsi + 1]
          movzx  ecx, byte[rbp + Pos.board + rcx]
            shl  ecx, 6
            add  ecx, eax
          movzx  eax, byte[rbp + Pos.board + rax]
            and  eax, 7
            shl  ecx, 3
            add  ecx, eax
            lea  r8, [r9 + 4*rcx]
            abs_bonus bonusW, r10d
            apply_capture_bonus  r8, bonusW, r10d
            cmp  esi, captureCnt
             jb  NextCapture
  end match

BonusTooBig:
Return:
end macro



