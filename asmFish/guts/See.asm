;Value Position::see(Move m) const {
;
;  Square from, to;
;  Bitboard occupied, attackers, stmAttackers;
;  Value swapList[32];
;  int slIndex = 1;
;  PieceType captured;
;  Color stm;
;
;  assert(is_ok(m));
;
;  from = from_sq(m);
;  to = to_sq(m);
;  swapList[0] = PieceValue[MG][piece_on(to)];
;  stm = color_of(piece_on(from));
;  occupied = pieces() ^ from;
;
;  // Castling moves are implemented as king capturing the rook so cannot
;  // be handled correctly. Simply return VALUE_ZERO that is always correct
;  // unless in the rare case the rook ends up under attack.
;  if (type_of(m) == CASTLING)
;      return VALUE_ZERO;
;
;  if (type_of(m) == ENPASSANT)
;  {
;      occupied ^= to - pawn_push(stm); // Remove the captured pawn
;      swapList[0] = PieceValue[MG][PAWN];
;  }
;
;  // Find all attackers to the destination square, with the moving piece
;  // removed, but possibly an X-ray attacker added behind it.
;  attackers = attackers_to(to, occupied) & occupied;
;
;  // If the opponent has no attackers we are finished
;  stm = ~stm;
;  stmAttackers = attackers & pieces(stm);
;  if (!stmAttackers)
;      return swapList[0];
;
;  // The destination square is defended, which makes things rather more
;  // difficult to compute. We proceed by building up a "swap list" containing
;  // the material gain or loss at each stop in a sequence of captures to the
;  // destination square, where the sides alternately capture, and always
;  // capture with the least valuable piece. After each capture, we look for
;  // new X-ray attacks from behind the capturing piece.
;  captured = type_of(piece_on(from));
;
;  do {
;      assert(slIndex < 32);
;
;      // Add the new entry to the swap list
;      swapList[slIndex] = -swapList[slIndex - 1] + PieceValue[MG][captured];
;
;      // Locate and remove the next least valuable attacker
;      captured = min_attacker<PAWN>(byTypeBB, to, stmAttackers, occupied, attackers);
;      stm = ~stm;
;      stmAttackers = attackers & pieces(stm);
;      ++slIndex;
;
;  } while (stmAttackers && (captured != KING || (--slIndex, false))); // Stop before a king capture
;
;  // Having built the swap list, we negamax through it to find the best
;  // achievable score from the point of view of the side to move.
;  while (--slIndex)
;      swapList[slIndex - 1] = std::min(-swapList[slIndex], swapList[slIndex - 1]);
;
;  return swapList[0];
;}






	      align   16, See.HaveFromTo
See:
	; in: rbp address of Pos
	;     ecx = capture move (preserved)
	;            type = 0 or MOVE_TYPE_EPCAP
	; out: eax > 0 good capture
	;      eax < 0 bad capture

from equ r8d
to   equ r9d
from_ equ r8
to_   equ r9
attackers    equ r15
occupied     equ r14
stm	     equ r13
b	     equ r12
stmAttackers equ r11

	; r8 = from
	; r9 = to
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63
		mov   r9d, ecx
		and   r9d, 63
.HaveFromTo:

SD_String 'see'
ProfileInc See

	       push   r12 r13 r14 r15 rcx rsi rdi
	      vmovq   xmm7, rsp

		shr   ecx, 12

	; rsi = bishops + queens
	; rdi = rooks + queens
		mov   rax, qword[rbp+Pos.typeBB+8*Queen]
		mov   rsi, qword[rbp+Pos.typeBB+8*Bishop]
		mov   rdi, qword[rbp+Pos.typeBB+8*Rook]
		 or   rdi, rax
		 or   rsi, rax

	; r12d = type
	; r13d = (side to move) *8
	      movzx   r12d, byte[rbp+Pos.board+r8]
		mov   stm, r12
		and   r12d, 7
		and   stm, 8

	; set initial gain
	      movzx   eax, byte[rbp+Pos.board+to_]
		mov   eax, dword[PieceValue_MG+4*rax]
	       push   rax

SD_String 'p'
SD_Int rax


	; r14 = occupied
	; r15 = attackers

		mov   occupied, qword[rbp+Pos.typeBB+8*White]
		 or   occupied, qword[rbp+Pos.typeBB+8*Black]
		btr   occupied, from_

		cmp   ecx, MOVE_TYPE_EPCAP
		jae   .Special
.EpCaptureRet:
	; king
		mov   attackers, qword[KingAttacks+8*r9]
		and   attackers, qword[rbp+Pos.typeBB+8*King]
	; pawn
		mov   rax, qword[BlackPawnAttacks+8*r9]
		and   rax, qword[rbp+Pos.typeBB+8*White]
		and   rax, qword[rbp+Pos.typeBB+8*Pawn]
		 or   attackers, rax
		mov   rax, qword[WhitePawnAttacks+8*r9]
		and   rax, qword[rbp+Pos.typeBB+8*Black]
		and   rax, qword[rbp+Pos.typeBB+8*Pawn]
		 or   attackers, rax
	; knight
		mov   rax, qword[KnightAttacks+8*r9]
		and   rax, qword[rbp+Pos.typeBB+8*Knight]
		 or   attackers, rax
	; rook + queen
	RookAttacks   rdx, to_, r14, r10
		and   rdx, rdi
		 or   attackers, rdx
	; bishop + queen
      BishopAttacks   rdx, to_, occupied, r10
		and   rdx, rsi
		 or   attackers, rdx

		btc   occupied, to_
		mov   eax, dword[PieceValue_MG+4*r12]

.GetNew:
		xor   stm, 8
		and   attackers, occupied

		mov   stmAttackers, qword[rbp+Pos.typeBB+stm]
		and   stmAttackers, attackers
		 jz   .NoAttackers
	       test   stmAttackers, qword[rbx+State.blockersForKing+stm]
		 jz   @f
		mov   rdx, qword[rbx+State.pinnersForKing+stm]
		and   rdx, occupied
		cmp   rdx, qword[rbx+State.pinnersForKing+stm]
		jne   @f
		mov   rcx, qword[rbx+State.blockersForKing+stm]
		not   rcx
		and   stmAttackers, rcx
		 jz   .NoAttackers
	@@:

		sub   eax, dword[rsp]
	       push   rax
SD_String 'p'
SD_Int rax

		mov   eax, PawnValueMg
		mov   b, qword[rbp+Pos.typeBB+8*Pawn]
		and   b, stmAttackers
		jnz   .FoundPawn

		mov   b, qword[rbp+Pos.typeBB+8*Knight]
		and   b, stmAttackers
		jnz   .FoundKnight

		mov   eax, BishopValueMg
		mov   b, qword[rbp+Pos.typeBB+8*Bishop]
		and   b, stmAttackers
		jnz   .FoundBishop

		mov   b, qword[rbp+Pos.typeBB+8*Rook]
		and   b, stmAttackers
		jnz   .FoundRook

		mov   b, qword[rbp+Pos.typeBB+8*Queen]
		and   b, stmAttackers
		jnz   .FoundQueen

.FoundKing:
		xor   stm, 8
		mov   stmAttackers, qword[rbp+Pos.typeBB+stm]
		and   stmAttackers, attackers
		 jz   .NoAttackers

		pop   rax

.NoAttackers:
	      vmovq   rdx, xmm7
		pop   rax
		cmp   rsp, rdx
		jae   .Return
	@@:	pop   rcx
		neg   eax
		cmp   eax, ecx
	      cmovg   eax, ecx
		cmp   rsp, rdx
		 jb   @b
.Return:
		pop   rdi rsi rcx r15 r14 r13 r12
SD_String 'r'
SD_Int rax
SD_String '|'
		ret


	      align   8
.FoundQueen:
	       blsi   b, b, rcx
		xor   occupied, b
		mov   eax, QueenValueMg
      BishopAttacks   rdx, to_, occupied, r10
		and   rdx, rsi
		 or   attackers, rdx
	RookAttacks   rdx, r9, occupied, r10
		and   rdx, rdi
		 or   attackers, rdx
		and   attackers, occupied
		jmp   .GetNew


	      align   8
.FoundRook:
	       blsi   b, b, rcx
		xor   occupied, b
		mov   eax, RookValueMg
	RookAttacks   rdx, to_, occupied, r10
		and   rdx, rdi
		 or   attackers, rdx
		and   attackers, occupied
		jmp   .GetNew


	      align   8
.FoundBishop:
.FoundPawn:
	       blsi   b, b, rcx
		xor   occupied, b
      BishopAttacks   rdx, to_, occupied, r10
		and   rdx, rsi
		 or   attackers, rdx
		and   attackers, occupied
		jmp   .GetNew



	      align   8
.FoundKnight:
	       blsi   b, b, rcx
		xor   occupied, b
		mov   eax, KnightValueMg
		and   attackers, occupied
		jmp   .GetNew


	      align   8
.Special:
		cmp   ecx, MOVE_TYPE_CASTLE
		 je   .Castle
.EpCapture:
SD_String 'ep'
		lea   eax, [r9+2*r13-8]
		btr   occupied, rax
		mov   dword[rsp], PawnValueMg
		jmp   .EpCaptureRet


.Castle:
		pop   rax
		xor   eax, eax
		pop   rdi rsi rcx r15 r14 r13 r12
SD_String 'r'
SD_Int rax
SD_String '|'
		ret




restore from
restore to
restore from_
restore to_
restore attackers
restore occupied
restore stm
restore b
restore stmAttackers



