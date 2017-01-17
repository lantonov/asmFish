
macro RookAttacks x,sq,occ,t {
; x = bitboard of pseudo legal moves for a piece on sq with occ pieces occluding its movement on the board
local ..skip
 match =1, CPU_HAS_BMI2 \{
		mov   x#d, dword[RookAttacksMOFF+4*(sq)]
	       pext   t, occ, qword[RookAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*t]
 \}
 match =0, CPU_HAS_BMI2 \{
		mov   t, qword[RookAttacksPEXT+8*(sq)]
		and   t, occ
		mov   x#d, dword[RookAttacksMOFF+4*(sq)]
	       imul   t, qword[RookAttacksIMUL+8*(sq)]
		shr   t, 64-12
		mov   x, qword[x+8*t]
 \}
}

; experimential rook attacks with smaller memory requirement, unforunately, also slower
macro RookAttacks2 x, sq, occ, t {
 match =1, CPU_HAS_BMI2 \{
		lea   ecx, [(sq)]
		shl   ecx, 6+3
	       pext   t, occ, qword[VAttacksPEXT+8*(sq)]
		mov   x, qword[VAttacks+rcx+8*t]
	       pext   t, occ, qword[HAttacksPEXT+8*(sq)]
		 or   x, qword[HAttacks+rcx+8*t]
 \}
 match =0, CPU_HAS_BMI2 \{
	err
 \}
}



macro BishopAttacks x,sq,occ,t {
 match =1, CPU_HAS_BMI2 \{
		mov   x#d, dword[BishopAttacksMOFF+4*(sq)]
	       pext   t, occ, qword[BishopAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*(t)]
 \}
 match =0, CPU_HAS_BMI2 \{
		mov   t, qword[BishopAttacksPEXT+8*(sq)]
		and   t, occ
		mov   x#d, dword[BishopAttacksMOFF+4*(sq)]
	       imul   t, qword[BishopAttacksIMUL+8*(sq)]
		shr   t, 64-9
		xor   ecx, ecx
		mov   x, qword[x+8*(t)]
 \}
}

macro QueenAttacks x,sq,occ,t,s  {
 match =1, CPU_HAS_BMI2 \{
		mov   x#d, dword[BishopAttacksMOFF+4*sq]
		mov   s#d, dword[RookAttacksMOFF+4*sq]
	       pext   t, occ, qword[BishopAttacksPEXT+8*(sq)]
		mov   x, qword[x+8*(t)]
	       pext   t, occ, qword[RookAttacksPEXT+8*(sq)]
		 or   x, qword[s+8*(t)]
 \}
 match =0, CPU_HAS_BMI2 \{
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
 \}


}
