
macro apply_bonus address, bonus32, absbonus, denominator
		mov   eax, dword[address]
	       imul   eax, absbonus
		cdq
		mov   ecx, denominator
	       idiv   ecx
		mov   ecx, bonus32

;SD_String 'v'
;SD_Int rcx

		sub   ecx, eax
		add   ecx, dword[address]
		mov   dword[address], ecx

;SD_String 'u'
;SD_Int rcx
;SD_String "|"

end macro



macro GetNextMove
	; in: rbp Position
	;     rbx State
        ;     esi skipQuiets (0 for false, -1 for true)
	; out: ecx move
	; rdi r12 r13 r14 r15 are clobbered

		mov   rax, qword[rbx+State.stage]
		mov   r14, qword[rbx+State.cur]
		mov   r15, qword[rbx+State.endMoves]
	       call   rax
		mov   qword[rbx+State.cur], r14
		mov   qword[rbx+State.endMoves], r15
end macro

macro InsertionSort begin, ender, p, q
local Outer, Inner, InnerDone, OuterDone
		lea   p, [begin+sizeof.ExtMove]
		cmp   p, ender
		jae   OuterDone
Outer:
		mov   rax, qword[p]
		mov   edx, dword[p+ExtMove.value]
		mov   q, p

		cmp   q, begin
		jbe   InnerDone
		mov   rcx, qword[q-sizeof.ExtMove+ExtMove.move]
		cmp   edx, dword[q-sizeof.ExtMove+ExtMove.value]
		jle   InnerDone
Inner:
		mov   qword [q], rcx
		sub   q, sizeof.ExtMove

		cmp   q, begin
		jbe   InnerDone
		mov   rcx, qword[q-sizeof.ExtMove+ExtMove.move]
		cmp   edx, dword[q-sizeof.ExtMove+ExtMove.value]
		 jg   Inner
InnerDone:
		mov   qword[q], rax
		add   p, sizeof.ExtMove
		cmp   p, ender
		 jb   Outer
OuterDone:
end macro




; we have two implementation of partition

macro Partition2  cur, ender
; at return ender point to start of elements that are <=0
  local _048, _049, _050, _051, Done
		cmp   cur, ender
		lea   cur, [cur+8]
		 je   Done
_048:		mov   eax, dword [cur-4]
		lea   rcx, [cur-8]
	       test   eax, eax
		 jg   _051
		mov   eax, dword [ender-4]
		lea   ender, [ender-8]
		cmp   ender, rcx
		 jz   Done
	       test   eax, eax
		 jg   _050
_049:		sub   ender, 8
		cmp   ender, rcx
		 jz   Done
		mov   eax, dword [ender+4]
	       test   eax, eax
		jle   _049
_050:		mov   rdx, qword [cur-8]
		mov   rcx, qword [ender]
		mov   qword [cur-8], rcx
		mov   qword [ender], rdx
_051:		cmp   ender, cur
		lea   cur, [cur+8]
		jnz   _048

Done:
end macro



macro Partition1  first, last
; at return first point to start of elements that are <=0
  local Done, FindNext, FoundNot, PFalse, WLoop
		cmp   first, last
		 je   Done
FindNext:
		cmp   dword[first+4], 0
		jle   FoundNot
		add   first, 8
		cmp   first, last
		jne   FindNext
		jmp   Done
FoundNot:
		lea   rcx, [first+8]
WLoop:
		cmp   rcx, last
		 je   Done
		cmp   dword[rcx+4], 0
		jle   PFalse
		mov   rax, qword[first]
		mov   rdx, qword[rcx]
		mov   qword[first], rdx
		mov   qword[rcx], rax
		add   first, 8
PFalse:
		add   rcx, 8
		jmp   WLoop
Done:
end macro


macro PickBest	beg, start, ender
	; out: ecx best move
  local Next, Done
		mov   ecx, dword[beg+0]
		mov   eax, dword[beg+4]
		mov   rdx, beg
		add   beg, sizeof.ExtMove
		mov   start, beg
		cmp   beg, ender
		jae   Done
Next:
		mov   ecx, dword[start+4]
		cmp   ecx, eax
	      cmovg   rdx, start
	      cmovg   eax, ecx
		add   start, sizeof.ExtMove
		cmp   start, ender
		 jb   Next
		mov   rcx, qword[rdx]
		mov   rax, qword[beg-sizeof.ExtMove]
		mov   qword[rdx], rax
		mov   qword[beg-sizeof.ExtMove], rcx
Done:
end macro



; use assembler to set mask of bits used in see sign
;SeeSignBitMask = 0
;
;_from = 0
;while _from < 8
; _to = 0
; while _to < 8
;
;   _fromvalue = 0
;   if Pawn <= _from & _from <= Queen
;    _fromvalue = _from
;   end if
;
;   _tovalue = 0
;   if Pawn <= _to & _to <= Queen
;    _tovalue = _to
;   end if
;
;   if _fromvalue > _tovalue
;    SeeSignBitMask = SeeSignBitMask or (1 shl (_from+8*_to))
;   end if
;
;  _to = _to+1
; end while
; _from = _from+1
;end while
SeeSignBitMask = 0x7c00406070787c7c

macro SeeSign JmpTo
  local Positive
	; ecx move (preserved)
	; jmp to JmpTo if see value is >=0, ecx is not clobbered in this case

		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to

	      movzx   eax, byte[rbp+Pos.board+r8]     ; r10 = FROM PIECE
	      movzx   edx, byte[rbp+Pos.board+r9]     ; r11 = TO PIECE
		mov   r10, SeeSignBitMask
		and   eax, 7
		and   edx, 7
		lea   edx, [rax+8*rdx]
		mov   eax, VALUE_KNOWN_WIN
		 bt   r10, rdx
  match , JmpTo
		jnc   Positive
  else
		jnc   JmpTo
  end match
	       call   See.HaveFromTo
Positive:
end macro




macro SeeSignTest JmpTo
  local Positive
	; eax = 1 if see >= 0
	; eax = 0 if see <  0
	; jmp to JmpTo if see value is >=0  eax is undefined in this case

		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to

	      movzx   eax, byte[rbp+Pos.board+r8]     ; eax = FROM PIECE
	      movzx   edx, byte[rbp+Pos.board+r9]     ; edx = TO PIECE
		mov   r10, SeeSignBitMask
		and   eax, 7
		and   edx, 7
		lea   edx, [rax+8*rdx]
		 bt   r10, rdx
		jnc   JmpTo
		xor   edx, edx
	       call   SeeTestGe.HaveFromTo
end macro



macro ScoreCaptures start, ender
  local WhileLoop, Done

	       imul   ecx, dword[rbp+Pos.sideToMove], 7
		cmp   start, ender
		jae   Done
WhileLoop:
		mov   eax, dword[start+ExtMove.move]
		and   eax, 63
		lea   start, [start+sizeof.ExtMove]
	      movzx   edx, byte[rbp+Pos.board+rax]
		mov   edx, dword[PieceValue_MG+4*rdx]
		shr   eax, 3
		xor   eax, ecx
	       imul   eax, eax, 200
		sub   edx, eax
		mov   dword[start-sizeof.ExtMove+ExtMove.value], edx
		cmp   start, ender
		 jb   WhileLoop
Done:
end macro



macro ScoreQuiets start, ender
  local cmh, fmh, fmh2, history_get_c
  local Loop, Done, TestLoop

	cmh  equ r9
	fmh  equ r10
	fmh2 equ r11

		mov   cmh, qword[rbx-1*sizeof.State+State.counterMoves]
		mov   fmh, qword[rbx-2*sizeof.State+State.counterMoves]
		mov   fmh2, qword[rbx-4*sizeof.State+State.counterMoves]
		mov   r8d, dword[rbp+Pos.sideToMove]
		shl   r8d, 12+2
		add   r8, qword[rbp+Pos.history]

	history_get_c equ r8

		cmp   start, ender
		jae   Done
Loop:
		mov   ecx, dword[start+ExtMove.move]
		mov   eax, ecx
		mov   edx, ecx
		and   eax, 64*64-1
		mov   eax, dword[history_get_c+4*rax]
		shr   edx, 6
		lea   start, [start+sizeof.ExtMove]
		and   ecx, 63
		and   edx, 63
	      movzx   edx, byte[rbp+Pos.board+rdx]
		shl   edx, 6
		add   edx, ecx
		add   eax, dword[cmh+4*rdx]
		add   eax, dword[fmh+4*rdx]
		add   eax, dword[fmh2+4*rdx]
		mov   dword[start-1*sizeof.ExtMove+ExtMove.value], eax
		cmp   start, ender
		 jb   Loop
Done:
end macro


macro ScoreEvasions start, ender
  local history_get_c
  local WhileLoop, Normal, Special, Done, Capture

		mov   edi, dword[rbp+Pos.sideToMove]
		shl   edi, 12+2
		add   rdi, qword[rbp+Pos.history]

	history_get_c equ rdi

		cmp   start, ender
		jae   Done
WhileLoop:
		mov   ecx, dword[start+ExtMove.move]
		mov   r10d, ecx 	; r10d = move
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63
		and   ecx, 63
		lea   start, [start+sizeof.ExtMove]
	      movzx   ecx, byte[rbp+Pos.board+rcx]	; ecx = to piece
	      movzx   edx, byte[rbp+Pos.board+r8]	; edx = from piece
		cmp   r10d, MOVE_TYPE_EPCAP shl 12
		jae   Special
	       test   ecx, ecx
		jnz   Capture
Normal:
		and   r10d, 64*64-1
		mov   eax, dword[history_get_c+4*r10]
		mov   dword[start-1*sizeof.ExtMove+ExtMove.value], eax
		cmp   start, ender
		 jb   WhileLoop
		jmp   Done
Special:
		cmp   r10d, MOVE_TYPE_CASTLE shl 12
		jae   Normal ; castling
Capture:
		mov   eax, dword[PieceValue_MG+4*ecx]
		and   edx, 7
		sub   eax, edx
		add   eax, HistoryStats_Max+1	; match piece types of master
		mov   dword[start-1*sizeof.ExtMove+ExtMove.value], eax
		cmp   start, ender
		 jb   WhileLoop
Done:
end macro
