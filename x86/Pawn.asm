
macro EvalPawns Us
	; in  rbp address of Pos struct
	;     rdi address of pawn table entry
	; out esi score
  local Them, Up, Right, Left
  local Isolated0, Isolated1, Backward0, Backward1, Doubled
  local NextPiece, AllDone, Done, WritePawnSpan
  local Neighbours_True, Neighbours_True__Lever_False
  local Neighbours_True__Lever_False__RelRank_small, Neighbours_False
  local Neighbours_True__Lever_True, Neighbours_True__Lever_False__RelRank_big
  local Continue, NoPassed, PopLoop
  if Us = White
	Them  = Black
	Up    = DELTA_N
	Right = DELTA_NE
	Left  = DELTA_NW
  else
	Them  = White
	Up    = DELTA_S
	Right = DELTA_SW
	Left  = DELTA_SE
  end if

  Isolated0    = (27 shl 16) + (30)
  Isolated1    = (13 shl 16) + (18)
  Isolated     = (13 shl 16) + (18)

  Backward0    = (40 shl 16) + (26)
  Backward1    = (24 shl 16) + (12)
  Backward     = (24 shl 16) + (12)

  Doubled     = ((18 shl 16) + (38))
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
        ShiftBB   Right, rax, rcx
            mov   rdx, r15
        ShiftBB   Left, rdx, rcx
             or   rax, rdx
            mov   qword[rdi+PawnEntry.pawnAttacks+8*Us], rax
            mov   rax, LightSquares
            and   rax, r15
        _popcnt   rax, rax, rcx
            mov   rdx, DarkSquares
            and   rdx, r15
        _popcnt   rdx, rdx, rcx
            mov   byte[rdi+PawnEntry.pawnsOnSquares+2*Us+White], al
            mov   byte[rdi+PawnEntry.pawnsOnSquares+2*Us+Black], dl
            xor   esi, esi
    ; esi = score
           test   r15, r15
             jz   AllDone
            lea   r15, [rbp+Pos.pieceList+16*(8*Us+Pawn)]
          movzx   ecx, byte[rbp+Pos.pieceList+16*(8*Us+Pawn)]
NextPiece:
            add   r15, 1
            mov   edx, ecx
            and   edx, 7
            mov   r12d, ecx
            shr   r12d, 3
            mov   rbx, qword[RankBB+8*r12]
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
            mov   rdx, qword[AdjacentFilesBB+8*rdx]
    ; rdx = adjacent_files_bb(f)
            mov   r10, qword[PassedPawnMask+8*(64*Us+rcx)]
            and   r10, r14
           push   r10
    ; r10 = stoppers
            mov   r8d, ecx
            shr   r8d, 3
            mov   r8, qword[RankBB+8*r8-Up]
            mov   r9, r13
            and   r9, rdx
    ; r9 = neighbours
            and   r8, r9
    ; r8 = supported
            and   rbx, r9
    ; rbx = phalanx
            lea   eax, [rcx-Up]
             bt   r13, rax
            mov   rax, r8           ; dirty trick relies on fact
            sbb   rax, 0            ; that r8>0 as signed qword
            lea   eax, [rsi-Doubled]
          cmovs   esi, eax
    ; doubled is taken care of
            mov   rax, qword[PawnAttacks+8*(64*Us+rcx)]
           test   r9, r9
             jz   Neighbours_False
Neighbours_True:
            and   rax, r14
         cmovnz   eax, dword[Lever+4*r12]
            lea   esi, [rsi+rax]
            jnz   Neighbours_True__Lever_True
Neighbours_True__Lever_False:
            mov   rax, r9
             or   rax, r10
  if Us = White
            cmp   ecx, SQ_A5
            jae   Neighbours_True__Lever_False__RelRank_big
            bsf   rax, rax
  else
            cmp   ecx, SQ_A5
             jb   Neighbours_True__Lever_False__RelRank_big
            bsr   rax, rax
  end if
Neighbours_True__Lever_False__RelRank_small:
            shr   eax, 3
            mov   rax, qword[RankBB+8*rax]
            and   rdx, rax
        ShiftBB   Up, rdx
             or   rdx, rax
            mov   eax, -Backward
            and   rdx, r10
         cmovnz   edx, eax
    ; edx = backwards ? Backward[opposed] : 0
            lea   eax, [r11 + 1]
         cmovnz   r10d, eax
            jmp   Continue
Neighbours_False:
            and   rax, r14
         cmovnz   eax, dword[Lever+4*r12]
            add   esi, eax
            mov   edx, -Isolated
            lea   r10d, [r11 + 1]
            jmp   Continue

Neighbours_True__Lever_True:
Neighbours_True__Lever_False__RelRank_big:
            xor   edx, edx
            xor   r10, r10
Continue:
        _popcnt   rax, r8, r9
    if CPU_HAS_POPCNT = 1
         popcnt   r9, rbx
    else
           push   r10             
        _popcnt   r9, rbx, r10
            pop   r10
    end if
            neg   r11d
            neg   rbx
            adc   r11d, r11d
            lea   r11d, [3*r11]
            add   r11d, eax
            lea   r11d, [8*r11+r12]
    ; r11 = [opposed][!!phalanx][popcount(supported)][relative_rank(Us, s)]
             or   rbx, r8
         cmovnz   edx, dword[Connected+4*r11]
            jnz   @1f
  if Us = Black
            shl   r10d, 4*Us
  end if
            add   byte[rdi+PawnEntry.weakUnopposed], r10l
    @1:
            add   esi, edx
    ; r8 = supported
    ; r9 = popcnt(phalanx)
    ; rax = popcnt(supported)
            pop   r10
    ; r10 = stoppers
            mov   r11, qword[PawnAttacks+8*(64*Us+rcx)]
            and   r11, r14
	; r11 = lever
            mov   rdx, qword[PawnAttacks+8*(64*Us+rcx+Up)]
            and   rdx, r14
	; rdx = leverPush
            mov   r12, r10
           test   r13, qword[ForwardBB+8*(64*Us+rcx)]
            jnz   NoPassed
            xor   r10, r11
            xor   r10, rdx
            jnz   NoPassed
        _popcnt   r11, r11, r10
        _popcnt   rdx, rdx, r10
            sub   rax, r11
            sub   r9, rdx
             or   rax, r9
             js   NoPassed
            mov   eax, 1
            shl   rax, cl
             or   qword[rdi+PawnEntry.passedPawns+8*Us], rax
            jmp   Done
NoPassed:
            lea   eax, [rcx+Up]
            btc   r12, rax
  if Us eq White
            shl   r8, 8
            cmp   ecx, SQ_A5
             jb   Done
  else
            shr   r8, 8
            cmp   ecx, SQ_A5
            jae   Done
  end if
           test   r12, r12
            jnz   Done
          _andn   r8, r14, r8
             jz   Done
PopLoop:
            bsf   r9, r8
            xor   eax, eax
            mov   r9, qword[PawnAttacks+8*(64*Us+r9)]
            and   r9, r14
          _blsr   rdx, r9
           setz   al                
            shl   rax, cl
             or   qword[rdi+PawnEntry.passedPawns+8*Us], rax
          _blsr   r8, r8, rax
            jnz   PopLoop
Done:
          movzx   ecx, byte[r15]
            cmp   ecx, 64
             jb   NextPiece
AllDone:
end macro
