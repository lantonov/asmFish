
Position_Init:

 push   rbx rsi rdi r11 r12 r13 r14 r15
 ; PushAll

virtual at rsp
  .prng        rq 1
  .ckoo_key    rq 1
  .ckoo_index  rd 1
  .ckoo_move   rd 1
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		mov   qword[.prng], 1070372

		xor   ebx, ebx

; This is the double-for loop
	.HashKeyInitLoopA:
		shl   ebx, 6+3
		mov   esi, ebx
		lea   rdi, [Zobrist_Pieces+8*rsi]
		mov   esi, 64*Pawn
		xor   r8, r8

	.HashKeyInitLoopB:
		xor   r9, r9

	.HashKeyInitLoopC:
		lea   rcx, [.prng]
		call   Math_Rand_i
		mov   qword[rdi+8*rsi], rax

		add   esi, 1
		add   r9, 1
		cmp   r9, 64
		 jb   .HashKeyInitLoopC

		 add   r8, 1
		 cmp   r8, 6
		 jb   .HashKeyInitLoopB

		add   ebx, 1
		cmp   ebx, 2
		 jb   .HashKeyInitLoopA

	; // end of double-for loop

		lea   rdi, [Zobrist_Ep]
		xor   esi, esi

	.l3: ; for-loop for files and Zobrist_Ep
		lea   rcx, [.prng]
		call   Math_Rand_i
		mov   qword[rdi+8*rsi], rax ; rax is result of Math_Rand_i
		add   esi, 1
		cmp   esi, 8 ; there are only 8 files
		 jb   .l3

		lea   rdi, [Zobrist_Castling]
		xor   esi, esi

	.l2: ; This is the castling for-loop
		lea   rcx, [.prng]
		call   Math_Rand_i ; rax has random key
		xor   ebx, ebx ; Zobrist::castling[cr] = 0;

	.l1: ; while (b)
		bt    ebx, esi
		sbb   rcx, rcx ; store flag result from bit test (bt) into rcx
		and   rcx, rax
		xor   qword[rdi+8*rbx], rcx ;  Zobrist::castling[cr] ^= k (but k never happens)
		add   ebx, 1
		cmp   ebx, 16
		 jb   .l1

		add   esi, 1
		cmp   esi, 4 ; there are only 4 castling states
		 jb   .l2

		lea   rcx, [.prng]
		call   Math_Rand_i
		mov   qword[Zobrist_side], rax

		lea   rcx, [.prng]
		call   Math_Rand_i
		mov   qword[Zobrist_noPawns], rax

		xor  ebx, ebx

	.CuckooLoopColor:
		mov   r8, Pawn

	.CuckooLoopPieceType:
		xor   r14, r14

	.CuckooLoopS1Squares:
		mov  r11, r14
		add  r11, 1 ; Square s2 = Square(s1+1)

	.CuckooLoopS2Squares:
		cmp r8, Pawn
		je .cuckoo_init_end

		; r9 = BitBoard Output
		; r8 = PieceType
		; r14 = the s1 square
		; r10 = a safe register for the PseudoAttacks macro to use internally (related to queen processing)

		PseudoAttacksAtFreshBoardState r9, r8, r14, r10

		mov r15, 1
		mov rcx, r11
		shl r15, cl  ; shl only allows the CL register to be used as a shift amount
		and r15, r9  ; Logically AND in the r9 bitboard output from our earlier pseudoattacks call
		jz .cuckoo_init_end

		;-------------------------------------------
		; <*><*><*><*><*><*><*><*><*><*><*><*><*><*>
		; <*>      Cuckoo table init logic       <*>
		; <*><*><*><*><*><*><*><*><*><*><*><*><*><*>
		;-------------------------------------------

	; Move move = make_move(s1, s2);
		cuckoo_makeMove rax, r14, r11
		mov qword[.ckoo_move], rax  ; save the cuckoo move

	; Key key = Zobrist::psq[pc][s1] ^ Zobrist::psq[pc][s2] ^ Zobrist::side;
		imul  esi, ebx, 64*8 				; get offset to keys for white or black
		lea   rdi, [Zobrist_Pieces+8*rsi]	; now get address to that set of keys
		mov   rsi, r8 						; get piecetype into rsi
		shl   rsi, 6						; get offset to polyglots for current pieceType (64*pt)
		add   rsi, r14						; add in s1 square offset within addressed table

		mov  r10, qword[rdi+8*rsi]
		mov   rcx, r10 			; get the s1 component of the key;

		mov   rdx, rcx						; save the s1 component

		sub   rsi, r14						; back out the s1 offset
		add   rsi, r11						; add in the s2 offset
		mov  r10, qword[rdi+8*rsi]
		mov   rcx, r10			; get the s2 component of the key;

		xor   rcx, rdx						; xor the s1 and s2 components together.
		mov   rdx, qword[Zobrist_side]
		xor   rcx, rdx						; xor the zobrist side to obtain the key
		mov   qword[.ckoo_key], rcx 		; save the cuckoo key

		cuckoo_H1 r12, rcx
		mov dword[.ckoo_index], r12d

	.cuckoo_swapping_loop:
	; Swap move
		mov   ecx, dword[.ckoo_move]
		lea   rdi, [cuckooMove]
		mov  r15d, dword[rdi+4*r12]

		mov   edx, r15d

		mov   dword[rdi+4*r12], ecx
		mov   dword[.ckoo_move], edx

		mov   rcx, qword[.ckoo_key]
		lea   rdi, [cuckoo]

		mov   rdx, qword[rdi+8*r12]
		mov   qword[rdi+8*r12], rcx
		mov   qword[.ckoo_key], rdx

	; if (move == 0)   // Arrived at empty slot ?
		mov   edx, dword[.ckoo_move]
		test edx, edx
		je .cuckoo_init_end

	; i = (i == H1(key)) ? H2(key) : H1(key); // Push victim to alternative slot
		mov   rcx, qword[.ckoo_key]
		mov   r12d, dword[.ckoo_index]
		cuckoo_H1 rdx, rcx

	; (i == H1(key)) ?
		cmp   r12,rdx
		jne   @f

	; then i = H2(key)
		cuckoo_H2 r12, rcx  ; new index is h2-based

		mov   dword[.ckoo_index],r12d
		jmp .cuckoo_swapping_loop

	@@:
	; else i = H1(key)
		cuckoo_H1 r12,rcx ; new index is h1-based
		mov   dword[.ckoo_index], r12d
		jmp .cuckoo_swapping_loop
		; } // end while loop

	.cuckoo_init_end:
		add   r11, 1  ; s2++
		cmp   r11, 64
		jb   .CuckooLoopS2Squares

		add   r14, 1  ; s1++
		cmp   r14, 63
		jb   .CuckooLoopS1Squares

		add   r8, 1
		cmp   r8, (King+1)
		jb   .CuckooLoopPieceType

		add   ebx, 1
		cmp   ebx, 2
		jb   .CuckooLoopColor

; End of cuckoo init processing
;======================================================

		lea   rdi, [IsPawnMasks]
		mov   eax, 00FF0000H
              stosq
              stosq
                lea   rdi, [IsNotPawnMasks]
		not   rax
              stosq
              stosq
                lea   rdi, [IsNotPieceMasks]
		mov   eax, 00FFH
              stosq
              stosq

		lea   rdi, [PieceValue_MG]
		lea   rsi, [.PieceValue_MG]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.PieceValue_MG]
		mov   ecx, 8
	  rep movsd
		lea   rdi, [PieceValue_EG]
		lea   rsi, [.PieceValue_EG]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.PieceValue_EG]
		mov   ecx, 8
	  rep movsd

		lea   rsi, [.PSQR]
		mov   r15d, Pawn
.TypeLoop:
	       imul   r12d, r15d, 8*64
		lea   r12, [r12+Scores_Pieces]
		lea   r11, [r12+8*8*64]

		xor   r14d, r14d
  .RankLoop:
		xor   r13d, r13d
    .FileLoop:
		mov   eax, dword[PieceValue_EG+4*r15]
		mov   edx, dword[PieceValue_MG+4*r15]
		shl   edx, 16
		add   eax, edx
		shr   edx, 16
		add   eax, dword[rsi]
		add   rsi, 4
		cmp   r15d, Pawn
		 ja   @f
		xor   edx, edx
	      @@:
	; eax = piece square value
	; edx = non pawn material

	; set white abcd
		lea   edi, [8*r14+r13]
		mov   dword[r12+8*rdi+0], eax
		mov   dword[r12+8*rdi+4], edx

	; set white efgh
		xor   edi, 0000111b
		mov   dword[r12+8*rdi+0], eax
		mov   dword[r12+8*rdi+4], edx

		neg   eax
		shl   edx, 16

	; set black efgh
		xor   edi, 0111000b
		mov   dword[r11+8*rdi+0], eax
		mov   dword[r11+8*rdi+4], edx

	; set black abcd
		xor   edi, 0000111b
		mov   dword[r11+8*rdi+0], eax
		mov   dword[r11+8*rdi+4], edx

		add   r13d, 1
		cmp   r13d, 4
		 jb   .FileLoop
		add   r14d, 1
		cmp   r14d, 8
		 jb   .RankLoop
		add   r15d, 1
		cmp   r15d, King
		jbe   .TypeLoop

	      .Return:
		add   rsp, .localsize
		pop   r15 r14 r13 r12 r11 rdi rsi rbx
		; PopAll
		ret


             calign   4
.PieceValue_MG:
 dd 0, 0, PawnValueMg, KnightValueMg, BishopValueMg, RookValueMg, QueenValueMg, 0
.PieceValue_EG:
 dd 0, 0, PawnValueEg, KnightValueEg, BishopValueEg, RookValueEg, QueenValueEg, 0


.PSQR:
 dd 0,0,0,0
 dd (-11 shl 16) + ( 7), (  6 shl 16) + (-4), ( 7 shl 16) + ( 8), ( 3 shl 16) + (-2)
 dd (-18 shl 16) + (-4), ( -2 shl 16) + (-5), (19 shl 16) + ( 5), (24 shl 16) + ( 4)
 dd (-17 shl 16) + ( 3), ( -9 shl 16) + ( 3), (20 shl 16) + (-8), (35 shl 16) + (-3)
 dd ( -6 shl 16) + ( 8), (  5 shl 16) + ( 9), ( 3 shl 16) + ( 7), (21 shl 16) + (-6)
 dd ( -6 shl 16) + ( 8), ( -8 shl 16) + (-5), (-6 shl 16) + ( 2), (-2 shl 16) + ( 4)
 dd ( -4 shl 16) + ( 3), ( 20 shl 16) + (-9), (-8 shl 16) + ( 1), (-4 shl 16) + (18)
 dd 0,0,0,0

 dd (-161 shl 16) + (-105), (-96 shl 16) + (-82), (-80 shl 16) + (-46), (-73 shl 16) + (-14)
 dd (-83 shl 16) + (-69), (-43 shl 16) + (-54), (-21 shl 16) + (-17), (-10 shl 16) + (9)
 dd (-71 shl 16) + (-50), (-22 shl 16) + (-39), (0 shl 16) + (-7), (9 shl 16) + (28)
 dd (-25 shl 16) + (-41), (18 shl 16) + (-25), (43 shl 16) + (6), (47 shl 16) + (38)
 dd (-26 shl 16) + (-46), (16 shl 16) + (-25), (38 shl 16) + (3), (50 shl 16) + (40)
 dd (-11 shl 16) + (-54), (37 shl 16) + (-38), (56 shl 16) + (-7), (65 shl 16) + (27)
 dd (-63 shl 16) + (-65), (-19 shl 16) + (-50), (5 shl 16) + (-24), (14 shl 16) + (13)
 dd (-195 shl 16) + (-109), (-67 shl 16) + (-89), (-42 shl 16) + (-50), (-29 shl 16) + (-13)

 dd (-44 shl 16) + (-58), (-13 shl 16) + (-31), (-25 shl 16) + (-37), (-34 shl 16) + (-19)
 dd (-20 shl 16) + (-34), (20 shl 16) + (-9),	(12 shl 16) + (-14),   (1 shl 16) + (4)
 dd (-9 shl 16) + (-23), (27 shl 16) + (0),	(21 shl 16) + (-3),  (11 shl 16) + (16)
 dd (-11 shl 16) + (-26), (28 shl 16) + (-3),	(21 shl 16) + (-5),  (10 shl 16) + (16)
 dd (-11 shl 16) + (-26), (27 shl 16) + (-4),	(16 shl 16) + (-7),   (9 shl 16) + (14)
 dd (-17 shl 16) + (-24), (16 shl 16) + (-2),	(12 shl 16) + (0),   (2 shl 16) + (13)
 dd (-23 shl 16) + (-34), (17 shl 16) + (-10),	(6 shl 16) + (-12),  (-2 shl 16) + (6)
 dd (-35 shl 16) + (-55), (-11 shl 16) + (-32), (-19 shl 16) + (-36), (-29 shl 16) + (-17)

 dd (-25 shl 16) + (0), (-16 shl 16) + (0), (-16 shl 16) + (0), (-9 shl 16) + (0)
 dd (-21 shl 16) + (0), (-8 shl 16) + (0), (-3 shl 16) + (0), (0 shl 16) + (0)
 dd (-21 shl 16) + (0), (-9 shl 16) + (0), (-4 shl 16) + (0), (2 shl 16) + (0)
 dd (-22 shl 16) + (0), (-6 shl 16) + (0), (-1 shl 16) + (0), (2 shl 16) + (0)
 dd (-22 shl 16) + (0), (-7 shl 16) + (0), (0 shl 16) + (0), (1 shl 16) + (0)
 dd (-21 shl 16) + (0), (-7 shl 16) + (0), (0 shl 16) + (0), (2 shl 16) + (0)
 dd (-12 shl 16) + (0), (4 shl 16) + (0), (8 shl 16) + (0), (12 shl 16) + (0)
 dd (-23 shl 16) + (0), (-15 shl 16) + (0), (-11 shl 16) + (0), (-5 shl 16) + (0)

 dd (0 shl 16) + (-71),  (-4 shl 16) + (-56), (-3 shl 16) + (-42), (-1 shl 16) + (-29)
 dd (-4 shl 16) + (-56), (6 shl 16) + (-30),  (9 shl 16) + (-21),  (8 shl 16) + (-5)
 dd (-2 shl 16) + (-39), (6 shl 16) + (-17),  (9 shl 16) + (-8),   (9 shl 16) + (5)
 dd (-1 shl 16) + (-29), (8 shl 16) + (-5),   (10 shl 16) + (9),   (7 shl 16) + (19)
 dd (-3 shl 16) + (-27), (9 shl 16) + (-5),   (8 shl 16) + (10),   (7 shl 16) + (21)
 dd (-2 shl 16) + (-40), (6 shl 16) + (-16),  (8 shl 16) + (-10),  (10 shl 16) + (3)
 dd (-2 shl 16) + (-55), (7 shl 16) + (-30),  (7 shl 16) + (-21),  (6 shl 16) + (-6)
 dd (-1 shl 16) + (-74), (-4 shl 16) + (-55), (-1 shl 16) + (-43), (0 shl 16) + (-30)

 dd (267 shl 16) + (  0), (320 shl 16) + ( 48), (270 shl 16) + ( 75), (195 shl 16) + ( 84)
 dd (264 shl 16) + ( 43), (304 shl 16) + ( 92), (238 shl 16) + (143), (180 shl 16) + (132)
 dd (200 shl 16) + ( 83), (245 shl 16) + (138), (176 shl 16) + (167), (110 shl 16) + (165)
 dd (177 shl 16) + (106), (185 shl 16) + (169), (148 shl 16) + (169), (110 shl 16) + (179)
 dd (149 shl 16) + (108), (177 shl 16) + (163), (115 shl 16) + (200), ( 66 shl 16) + (203)
 dd (118 shl 16) + ( 95), (159 shl 16) + (155), ( 84 shl 16) + (176), ( 41 shl 16) + (174)
 dd ( 87 shl 16) + ( 50), (128 shl 16) + ( 99), ( 63 shl 16) + (122), ( 20 shl 16) + (139)
 dd ( 63 shl 16) + (  9), ( 88 shl 16) + ( 55), ( 47 shl 16) + ( 80), (  0 shl 16) + ( 90)
