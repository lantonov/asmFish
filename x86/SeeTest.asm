;// Test whether see(m) >= value.
;int see_test(Pos *pos, Move m, int value)
;{
;  if (type_of_m(m) == CASTLING)
;    return 0 >= value;
;
;  Square from = from_sq(m), to = to_sq(m);
;  Bitboard occ = pieces();
;
;  int swap = PieceValue[MG][piece_on(to)] - value;
;  if (type_of_m(m) == ENPASSANT) {
;    assert(pos_stm() == color_of(piece_on(from)));
;    occ ^= sq_bb(to - pawn_push(pos_stm())); // Remove the captured pawn
;    swap += PieceValue[MG][PAWN];
;  }
;  if (swap < 0)
;    return 0;
;
;  swap = PieceValue[MG][piece_on(from)] - swap;
;  if (swap <= 0)
;    return 1;
;
;  occ ^= sq_bb(from) ^ sq_bb(to);
;  Bitboard attackers = attackers_to_occ(to, occ) & occ;
;  int stm = color_of(piece_on(from)) ^ 1;
;  int res = 1;
;  Bitboard stmAttackers;
;
;  while (1) {
;    stmAttackers = attackers & pieces_c(stm);
;    if (   (stmAttackers & pinned_pieces(pos, stm))
;        && (pos->st->pinnersForKing[stm] & occ) == pos->st->pinnersForKing[stm])
;      stmAttackers &= ~pinned_pieces(pos, stm);
;    if (!stmAttackers) break;
;    Bitboard bb;
;    int captured;
;    for (captured = PAWN; captured < KING; captured++)
;      if ((bb = stmAttackers & pieces_p(captured)))
;        break;
;    if (captured == KING) {
;      stm ^= 1;
;      stmAttackers = attackers & pieces_c(stm);
;      // Introduce error also present in official Stockfish.
;      if (   (stmAttackers & pinned_pieces(pos, stm))
;          && (pos->st->pinnersForKing[stm] & occ) == pos->st->pinnersForKing[stm])
;        stmAttackers &= ~pinned_pieces(pos, stm);
;      return stmAttackers ? res : res ^ 1;
;    }
;    swap = PieceValue[MG][captured] - swap;
;    res ^= 1;
;    // Next line tests alternately for swap < 0 and swap <= 0.
;    if (swap < res) return res;
;    occ ^= (bb & -bb);
;    if (captured & 1) // PAWN, BISHOP, QUEEN
;      attackers |= attacks_bb_bishop(to, occ) & pieces_pp(BISHOP, QUEEN);
;    if (captured & 4) // ROOK, QUEEN
;      attackers |= attacks_bb_rook(to, occ) & pieces_pp(ROOK, QUEEN);
;    attackers &= occ;
;    stm ^= 1;
;  }
;
;  return res;
;}



	     calign  16, SeeTestGe.HaveFromTo
SeeTestGe:
	; in: rbp address of Pos
	;     rbx address of State
	;     ecx capture move
	;     edx value
	; out: eax = 1 if  see >= edx
	;      eax = 0 if  see <  edx

from         equ r8
from_d       equ r8d
to           equ r9
to_d         equ r9d
stm	     equ rsi
stm_d	     equ esi
attackers    equ r15
occupied     equ r14
bb	     equ r13
stmAttackers equ r12
swap	     equ edx
res	     equ eax


	; r8 = from
	; r9 = to
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63
		mov   r9d, ecx
		and   r9d, 63
.HaveFromTo:

	       push   r12 r13 r14 r15 rsi rdi

		mov   occupied, qword[rbp+Pos.typeBB+8*White]
		 or   occupied, qword[rbp+Pos.typeBB+8*Black]
		btr   occupied, from
		btc   occupied, to

	; r10 = bishops + queens
	; r11 = rooks + queens
		mov   rdi, qword[rbp+Pos.typeBB+8*Queen]
		mov   r10, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r11, qword[rbp+Pos.typeBB+8*Rook]
		 or   r10, rdi
		 or   r11, rdi

		neg   swap
		xor   res, res

               test   ecx, 0xFFFFF000
		jnz   .Special

	      movzx   ecx, byte[rbp+Pos.board+to]
		add   swap, dword[PieceValue_MG+4*rcx]
		cmp   swap, res
		 jl   .Return	; 2.35%

.EpCaptureRet:

		xor   res, 1   ; .res = 1
		neg   swap
	      movzx   stm_d, byte[rbp+Pos.board+from]
		add   swap, dword[PieceValue_MG+4*stm]	; use piece_on(from)
		and   stm_d, 8
		cmp   swap, res
		 jl   .Return	; 13.63%

	; at this point .from register r8 is free
	;  rdi, rcx are also free

		mov   attackers, qword[KingAttacks+8*to]
		and   attackers, qword[rbp+Pos.typeBB+8*King]
		mov   rdi, qword[BlackPawnAttacks+8*to]
		and   rdi, qword[rbp+Pos.typeBB+8*White]
		and   rdi, qword[rbp+Pos.typeBB+8*Pawn]
		 or   attackers, rdi
		mov   rdi, qword[WhitePawnAttacks+8*to]
		and   rdi, qword[rbp+Pos.typeBB+8*Black]
		and   rdi, qword[rbp+Pos.typeBB+8*Pawn]
		 or   attackers, rdi
		mov   rdi, qword[KnightAttacks+8*to]
		and   rdi, qword[rbp+Pos.typeBB+8*Knight]
		 or   attackers, rdi
	RookAttacks   rdi, to, occupied, r8
		and   rdi, r11
		 or   attackers, rdi
      BishopAttacks   rdi, to, occupied, r8
		and   rdi, r10
		 or   attackers, rdi

.Loop:	      ; while (1) {
		xor   stm_d, 8
		and   attackers, occupied

	; modified old
		mov   stmAttackers, qword[rbp+Pos.typeBB+stm]
		and   stmAttackers, attackers
		 jz   .Return	; 44.45%
	       test   stmAttackers, qword[rbx+State.blockersForKing+stm]
		 jz   @f	; 98.90%
		mov   rdi, qword[rbx+State.pinnersForKing+stm]
		and   rdi, occupied
		cmp   rdi, qword[rbx+State.pinnersForKing+stm]
		jne   @f	; 53.42%
		mov   rcx, qword[rbx+State.blockersForKing+stm]
		not   rcx
		and   stmAttackers, rcx
		 jz   .Return	; 45.06%
	@@:

      ;  ; new 0.3% speed loss with or without branches
      ;          xor   ecx, ecx
      ;          mov   stmAttackers, qword[rbp+Pos.typeBB+stm]
      ;          and   stmAttackers, attackers
      ;         andn   rdi, occupied, qword[rbx+State.pinnersForKing+stm]
      ;        cmovz   rcx, qword[rbx+State.blockersForKing+stm]
      ;         andn   stmAttackers, rcx, stmAttackers
      ;           jz   .Return

		neg   swap
		xor   res, 1

		mov   bb, qword[rbp+Pos.typeBB+8*Pawn]
		and   bb, stmAttackers
		jnz   .FoundPawn

		mov   bb, qword[rbp+Pos.typeBB+8*Knight]
		and   bb, stmAttackers
		jnz   .FoundKnight

		mov   bb, qword[rbp+Pos.typeBB+8*Bishop]
		and   bb, stmAttackers
		jnz   .FoundBishop

		mov   bb, qword[rbp+Pos.typeBB+8*Rook]
		and   bb, stmAttackers
		jnz   .FoundRook

		mov   bb, qword[rbp+Pos.typeBB+8*Queen]
		and   bb, stmAttackers
		jnz   .FoundQueen

.FoundKing:
		xor   stm_d, 8
		mov   stmAttackers, qword[rbp+Pos.typeBB+stm]
		and   stmAttackers, attackers
	; .res has already been flipped so we must do
	;    return stmAttackers ? res^1 : res;
		neg   stmAttackers
		adc   res, 0
		and   res, 1

.Return:
		pop   rdi rsi r15 r14 r13 r12
		ret


	     calign   8
.FoundQueen:
		add   swap, QueenValueMg
		cmp   swap, res
		 jl   .Return

	      _blsi   bb, bb, r8
		xor   occupied, bb
      BishopAttacks   rdi, to, occupied, r8
		and   rdi, r10
		 or   attackers, rdi
	RookAttacks   rdi, to, occupied, r8
		and   rdi, r11
		 or   attackers, rdi
		jmp   .Loop


.FoundRook:
		add   swap, RookValueMg
		cmp   swap, res
		 jl   .Return

	      _blsi   bb, bb, r8
		xor   occupied, bb
	RookAttacks   rdi, to, occupied, r8
		and   rdi, r11
		 or   attackers, rdi
		jmp   .Loop


	     calign   8
.FoundBishop:
		add   swap, BishopValueMg-PawnValueMg
.FoundPawn:
		add   swap, PawnValueMg
		cmp   swap, res
		 jl   .Return

	      _blsi   bb, bb, rcx
		xor   occupied, bb
      BishopAttacks   rdi, to, occupied, r8
		and   rdi, r10
		 or   attackers, rdi
		jmp   .Loop



	     calign   8
.FoundKnight:
		add   swap, KnightValueMg
		cmp   swap, res
		 jl   .Return

	      _blsi   bb, bb, rcx
		xor   occupied, bb
		jmp   .Loop

         calign  8
.Special:
    ; if we get here, swap = -value  and  res = 0
            cmp  swap, 0x80000000
            adc  res, res
            pop  rdi rsi r15 r14 r13 r12
            ret



restore from
restore from_d
restore to
restore to_d
restore stm
restore stm_d
restore attackers
restore occupied
restore bb
restore stmAttackers
restore swap
restore res
