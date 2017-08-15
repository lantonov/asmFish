;bool Position::is_draw(int ply) const {
;  if (st->rule50 > 99 && (!checkers() || MoveList<LEGAL>(*this).size()))
;      return true;
;  int end = std::min(st->rule50, st->pliesFromNull);
;  if (end < 4) return false;
;  StateInfo* stp = st->previous->previous;
;  int cnt = 0;
;  for (int i = 4; i <= end; i += 2) {
;      stp = stp->previous->previous;
;      // At root position ply is 1, so return a draw score if a position
;      // repeats once earlier but strictly after the root, or repeats twice
;      // before or at the root.
;      if (   stp->key == st->key
;          && ++cnt + (ply - 1 > i) == 2)
;          return true;
;  }
;  return false;
;}

macro PosIsDraw WeHaveADraw, coldlabel, coldreturnlabel
; in    rbp  address of Position
;       rbx  address of State
;       edx  word[rbx+State.rule50]
;       ecx  word[rbx+State.pliesFromNull]
;       r8   qword[rbx+State.key]
;       eax  ply
;
; out: should jump to WeHaveADraw in case of a draw
;       otherwise fall through
;       r12-r15 should be preserved

  local CheckNext, noDraw, KeysDontMatch

		cmp   edx, 100
		jae   coldlabel
coldreturnlabel:
		cmp   edx, ecx
	      cmova   edx, ecx
		cmp   edx, 4
		 jb   noDraw
	       imul   r10, rdx, -sizeof.State	; r10 = end
		mov   r9, -4*sizeof.State	; r9 = i
		sub   eax, 6			; eax = ply-i-2
		xor   ecx, ecx			; ecx = -cnt
CheckNext:
		cdq				; get the sign of ply-i-2
		cmp   r8, qword[rbx+r9+State.key]
		jne   KeysDontMatch
		cmp   ecx, edx			; 1+cnt + (ply-1>i) == 2 is the same as
		 je   WeHaveADraw		; -cnt == sign(ply-i-2)
		sub   ecx, 1
KeysDontMatch:
		sub   r9, 2*sizeof.State
		sub   eax, 2
		cmp   r9, r10
		jae   CheckNext
noDraw:
end macro


; this macro should be headed by the coldlabel argument of the PosIsDraw macro
macro PosIsDraw_Cold WeHaveADraw, coldreturnlabel
		mov   r11, qword[rbx+State.checkersBB]	; don't clobber eax
	       test   r11, r11				; as it holds ply 
		 jz   WeHaveADraw		; draw if we are not in check
	       push   rax rcx rdx r8 r9 rdi
		mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
	       call   Gen_Legal
		cmp   rdi, qword[rbx-1*sizeof.State+State.endMoves]
		pop   rdi r9 r8 rdx rcx rax
		jne   WeHaveADraw		; draw if we have some moves
		jmp   coldreturnlabel		; otherwise fall through
end macro
