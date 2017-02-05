
macro EvalPawns Us {
	; in  rbp address of Pos struct
	;     rbx address of State struct
	;     rdi address of pawn table entry
	; out esi score
local Them, Up, Right, Left
local ..NextPiece, ..AllDone, ..WritePawnSpan
local ..Neighbours_True, ..Lever_False, ..TestUnsupported
local ..Lever_True, ..Neighbours_False, ..Continue

match =White, Us
\{
	Them  equ Black
	Up    equ DELTA_N
	Right equ DELTA_NE
	Left  equ DELTA_NW
\}

match =Black, Us
\{
	Them  equ White
	Up    equ DELTA_S
	Right equ DELTA_SW
	Left  equ DELTA_SE
\}
	Isolated0 equ ((45 shl 16) + (40))
	Isolated1 equ ((30 shl 16) + (27))
	Backward0 equ ((56 shl 16) + (33))
	Backward1 equ ((41 shl 16) + (19))
	Unsupported equ ((17 shl 16) + (8))
	Doubled equ ((18 shl 16) + (38))


		xor   eax, eax
		mov   qword[rdi+PawnEntry.passedPawns+8*Us], rax
		mov   qword[rdi+PawnEntry.pawnAttacksSpan+8*Us], rax
		mov   byte[rdi+PawnEntry.kingSquares+Us], 64
		mov   byte[rdi+PawnEntry.semiopenFiles+Us], 0xFF

		mov   r15, qword[rbp+Pos.typeBB+8*Pawn]
		mov   r14, r15
		and   r14, qword[rbp+Pos.typeBB+8*Them]
		and   r15, qword[rbp+Pos.typeBB+8*Us]
		mov   r13, r15
	; r14 = their pawns
	; r13 = our pawns     = r15

		mov   rax, r15
	   shift_bb   Right, rax, rcx
		mov   rdx, r15
	   shift_bb   Left, rdx, rcx
		 or   rax, rdx
		mov   qword[rdi+PawnEntry.pawnAttacks+8*Us], rax

		mov   rax, LightSquares
		and   rax, r15
	     popcnt   rax, rax, rcx
		mov   rdx, DarkSquares
		and   rdx, r15
	     popcnt   rdx, rdx, rcx
		mov   byte[rdi+PawnEntry.pawnsOnSquares+2*Us+White], al
		mov   byte[rdi+PawnEntry.pawnsOnSquares+2*Us+Black], dl

		xor   esi, esi
	; esi = score

	       test   r15, r15
		 jz   ..AllDone


if PEDANTIC

		lea   r15, [rbp+Pos.pieceList+16*(8*Us+Pawn)]
	      movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Us+Pawn)]
..NextPiece:
		add   r15, 1

else

..NextPiece:
		bsf   rcx, r15
	       blsr   r15, r15, rax

end if

		mov   edx, ecx
		and   edx, 7
		mov   r12d, ecx
		shr   r12d, 3
	if Us eq Black
		xor   r12d, 7
	end if
	; ecx = s, edx = f, r12d = relative_rank(Us, s)

	      movzx   eax, byte[rdi+PawnEntry.semiopenFiles+Us]
		btr   eax, edx
		mov   byte[rdi+PawnEntry.semiopenFiles+Us], al
		mov   rax, [PawnAttackSpan+8*(64*Us+rcx)]
		 or   qword[rdi+PawnEntry.pawnAttacksSpan+8*Us], rax

		mov   r11, r14
		and   r11, qword[ForwardBB+8*(64*Us+rcx)]
		neg   r11
		sbb   r11d, r11d
	; r11d = opposed
		lea   eax, [rcx+Up]
		 bt   r13, rax
		sbb   eax, eax
		and   eax, Doubled
		sub   esi, eax
	; doubled is taken care of
		mov   rdx, qword[AdjacentFilesBB+8*rdx]
	; rdx = adjacent_files_bb(f)
		mov   rax, qword[PawnAttacks+8*(64*Us+rcx)]
		and   rax, r14
	; rax = lever
		mov   r10, qword[PassedPawnMask+8*(64*Us+rcx)]
		and   r10, r14
	; r10 = stoppers
		mov   r8d, ecx
		shr   r8d, 3
		mov   r8, qword[RankBB+8*r8-Up]
	; r8 = supported  (will be after and with r9)
		mov   r9, r13
		and   r9, rdx
	; r9 = neighbours
		 jz   ..Neighbours_False
..Neighbours_True:
		and   r8, r9
	       test   rax, rax
	     cmovnz   eax, dword[Lever+4*r12]
		lea   esi, [rsi+rax]
		jnz   ..TestUnsupported
..Lever_False:
		mov   rax, r9
		 or   rax, r10
	if Us eq White
		cmp   ecx, SQ_A5
		jae   ..TestUnsupported
	else if Us eq Black
		cmp   ecx, SQ_A5
		 jb   ..TestUnsupported
	end if
	if Us eq White
		bsf   rax, rax
	else if Us eq Black
		bsr   rax, rax
	end if
		shr   eax, 3
		mov   rax, qword[RankBB+8*rax]
		and   rdx, rax
	   shift_bb   Up, rdx
		 or   rdx, rax
		mov   eax, r11d
		and   eax, Backward0-Backward1
		lea   eax, [rsi+rax-Backward0]
	       test   rdx, r10
	     cmovnz   esi, eax
		jnz   ..Continue
..TestUnsupported:
		cmp   r8, 1
		sbb   eax, eax
		and   eax, Unsupported
		sub   esi, eax
		jmp   ..Continue

..Neighbours_False:
	       test   rax, rax
	     cmovnz   eax, dword[Lever+4*r12]
		lea   esi, [rsi+rax]

		and   r8, r9
		mov   eax, r11d
		and   eax, Isolated0-Isolated1
		lea   esi, [rsi+rax-Isolated0]

..Continue:
	; at this point we have taken care of
	;       backwards, neighbours, supported, lever

		neg   r11d
		mov   edx, ecx
		shr   edx, 3
		mov   rdx, qword[RankBB+8*rdx]
		and   rdx, r9
		neg   rdx
		adc   r11d, r11d
	       blsr   rax, r8
		neg   rax
		adc   r11d, r11d
		lea   r11d, [8*r11+r12]
		 or   r8, rdx
	     cmovnz   r8d, dword[Connected+4*r11]
		add   esi, r8d
	; connected is taken care of

		mov   rdx, qword[ForwardBB+8*(64*Us+rcx)]
		and   rdx, r13
		xor   eax, eax
		 or   r10, rdx
	       setz   al
		shl   rax, cl
		 or   qword[rdi+PawnEntry.passedPawns+8*Us], rax
	; passed pawns is taken care of


if PEDANTIC
	      movzx   ecx, byte[r15]
		cmp   ecx, 64
		 jb   ..NextPiece

else
	       test   r15, r15
		jnz   ..NextPiece
end if

..AllDone:

restore Them
restore Up
restore Right
restore Left
restore Isolated0
restore Isolated1
restore Backward0
restore Backward1
restore Unsupported0
restore Unsupported1
restore Doubled

}
