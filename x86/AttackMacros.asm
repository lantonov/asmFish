macro RookAttacks x, sq, occ, t
; x = bitboard of pseudo legal moves for a piece on sq with occ pieces occluding its movement on the board
  if CPU_HAS_BMI2
		mov   x#d, dword[RookAttacksMOFF+4*(sq)]
	       pext   t, occ, qword[RookAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*t]
  else
		mov   t, qword[RookAttacksPEXT+8*(sq)]
		and   t, occ
		mov   x#d, dword[RookAttacksMOFF+4*(sq)]
	       imul   t, qword[RookAttacksIMUL+8*(sq)]
		shr   t, 64-12
		mov   x, qword[x+8*t]
  end if
end macro

macro BishopAttacks x, sq, occ, t
  if CPU_HAS_BMI2
		mov   x#d, dword[BishopAttacksMOFF+4*(sq)]
	       pext   t, occ, qword[BishopAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*(t)]
  else
		mov   t, qword[BishopAttacksPEXT+8*(sq)]
		and   t, occ
		mov   x#d, dword[BishopAttacksMOFF+4*(sq)]
	       imul   t, qword[BishopAttacksIMUL+8*(sq)]
		shr   t, 64-9
		mov   x, qword[x+8*(t)]
  end if
end macro

macro QueenAttacks x, sq, occ, t, s
  if CPU_HAS_BMI2
		mov   x#d, dword[BishopAttacksMOFF+4*sq]
		mov   s#d, dword[RookAttacksMOFF+4*sq]
	       pext   t, occ, qword[BishopAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*(t)]
	       pext   t, occ, qword[RookAttacksPEXT+8*(sq)]
		 or   x, qword[s+8*(t)]
  else
		mov   t, qword[BishopAttacksPEXT+8*(sq)]
		and   t, occ
		mov   x#d, dword[BishopAttacksMOFF+4*(sq)]
	       imul   t, qword[BishopAttacksIMUL+8*(sq)]
		shr   t, 64-9
		mov   x, qword[x+8*(t)]

		mov   t, qword[RookAttacksPEXT+8*(sq)]
		and   t, occ
		mov   s#d, dword[RookAttacksMOFF+4*(sq)]
		imul   t, qword[RookAttacksIMUL+8*(sq)]
		shr   t, 64-12
		 or   x, qword[s+8*(t)]
  end if
end macro

macro PseudoAttacksAtFreshBoardState x, Pt, sq, t
		cmp  Pt, Knight
		jne  @f

		mov   x, qword[KnightAttacks+8*sq]
		jmp  @1f

@@:
		cmp  Pt, Bishop
		jne  @f

		mov   x#d, dword[BishopAttacksMOFF+4*sq]
		mov   x, qword[x]
		jmp  @1f

@@:
		cmp  Pt, Rook
		jne  @f

		mov   x#d, dword[RookAttacksMOFF+4*sq]
		mov   x, qword[x]

		jmp  @1f

@@:
		cmp  Pt, Queen
		jne  @f

		mov   x#d, dword[BishopAttacksMOFF+4*sq]
		mov   x, qword[x]
		mov   t#d, dword[RookAttacksMOFF+4*sq]
		or    x, qword[t]
		jmp  @1f

@@:
		mov   x, qword[KingAttacks+8*sq]

@1:
end macro
