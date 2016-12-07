Position_Init:

	       push   rbx rsi rdi r12 r13 r14 r15
virtual at rsp
  .prng        rq 1
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		mov   qword[.prng], 1070372

		xor   ebx, ebx
	.l:    imul   esi, ebx, 64*8
		lea   rdi, [Zobrist_Pieces+8*rsi]
		mov   esi, 64*Pawn
	.l0:	lea   rcx, [.prng]
	       call   Math_Rand_i
		mov   qword[rdi+8*rsi], rax
		add   esi, 1
		cmp   esi, 64*(King+1)
		 jb   .l0
		add   ebx, 1
		cmp   ebx, 2
		 jb   .l

		lea   rdi, [Zobrist_Ep]
		xor   esi, esi
	.l3:	lea   rcx, [.prng]
	       call   Math_Rand_i
		mov   qword[rdi+8*rsi], rax
		add   esi, 1
		cmp   esi, 8
		 jb   .l3

		lea   rdi, [Zobrist_Castling]
		xor   esi, esi
	.l2:	lea   rcx, [.prng]
	       call   Math_Rand_i
		xor   ebx, ebx
	.l1:	 bt   ebx, esi
		sbb   rcx, rcx
		and   rcx, rax
		xor   qword[rdi+8*rbx], rcx
		add   ebx, 1
		cmp   ebx, 16
		 jb   .l1
		add   esi, 1
		cmp   esi, 4
		 jb   .l2

		lea   rcx, [.prng]
	       call   Math_Rand_i
		mov   qword[Zobrist_side], rax

		mov   rax, 00FF0000H
		mov   qword[IsPawnMasks+0], rax
		mov   qword[IsPawnMasks+8], rax
		not   rax
		mov   qword[IsNotPawnMasks+0], rax
		mov   qword[IsNotPawnMasks+8], rax
		mov   rax, 00FFH
		mov   qword[IsNotPieceMasks+0], rax
		mov   qword[IsNotPieceMasks+8], rax


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
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret


align 4
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

 dd (-143 shl 16) + (-97), (-96 shl 16) + (-82), (-80 shl 16) + (-46), (-73 shl 16) + (-14)
 dd (-83 shl 16) + (-69), (-43 shl 16) + (-55), (-21 shl 16) + (-17), (-10 shl 16) + (9)
 dd (-71 shl 16) + (-50), (-22 shl 16) + (-39), (0 shl 16) + (-8), (9 shl 16) + (28)
 dd (-25 shl 16) + (-41), (18 shl 16) + (-25), (43 shl 16) + (7), (47 shl 16) + (38)
 dd (-26 shl 16) + (-46), (16 shl 16) + (-25), (38 shl 16) + (2), (50 shl 16) + (41)
 dd (-11 shl 16) + (-55), (37 shl 16) + (-38), (56 shl 16) + (-8), (71 shl 16) + (27)
 dd (-62 shl 16) + (-64), (-17 shl 16) + (-50), (5 shl 16) + (-24), (14 shl 16) + (13)
 dd (-195 shl 16) + (-110), (-66 shl 16) + (-90), (-42 shl 16) + (-50), (-29 shl 16) + (-13)

 dd (-54 shl 16) + (-68), (-23 shl 16) + (-40), (-35 shl 16) + (-46), (-44 shl 16) + (-28)
 dd (-30 shl 16) + (-43), (10 shl 16) + (-17),	(2 shl 16) + (-23),   (-9 shl 16) + (-5)
 dd (-19 shl 16) + (-32), (17 shl 16) + (-9),	(11 shl 16) + (-13),  (1 shl 16) + (8)
 dd (-21 shl 16) + (-36), (18 shl 16) + (-13),	(11 shl 16) + (-15),  (0 shl 16) + (7)
 dd (-21 shl 16) + (-36), (14 shl 16) + (-14),	(6 shl 16) + (-17),   (-1 shl 16) + (3)
 dd (-27 shl 16) + (-35), (6 shl 16) + (-13),	(2 shl 16) + (-10),   (-8 shl 16) + (1)
 dd (-33 shl 16) + (-44), (7 shl 16) + (-21),	(-4 shl 16) + (-22),  (-12 shl 16) + (-4)
 dd (-45 shl 16) + (-65), (-21 shl 16) + (-42), (-29 shl 16) + (-46), (-39 shl 16) + (-27)

 dd (-25 shl 16) + (0), (-16 shl 16) + (0), (-16 shl 16) + (0), (-9 shl 16) + (0)
 dd (-21 shl 16) + (0), (-8 shl 16) + (0), (-3 shl 16) + (0), (0 shl 16) + (0)
 dd (-21 shl 16) + (0), (-9 shl 16) + (0), (-4 shl 16) + (0), (2 shl 16) + (0)
 dd (-22 shl 16) + (0), (-6 shl 16) + (0), (-1 shl 16) + (0), (2 shl 16) + (0)
 dd (-22 shl 16) + (0), (-7 shl 16) + (0), (0 shl 16) + (0), (1 shl 16) + (0)
 dd (-21 shl 16) + (0), (-7 shl 16) + (0), (0 shl 16) + (0), (2 shl 16) + (0)
 dd (-12 shl 16) + (0), (4 shl 16) + (0), (8 shl 16) + (0), (12 shl 16) + (0)
 dd (-23 shl 16) + (0), (-15 shl 16) + (0), (-11 shl 16) + (0), (-5 shl 16) + (0)

 dd (0 shl 16) + (-70),  (-3 shl 16) + (-57), (-4 shl 16) + (-41), (-1 shl 16) + (-29)
 dd (-4 shl 16) + (-58), (6 shl 16) + (-30),  (9 shl 16) + (-21),  (8 shl 16) + (-4)
 dd (-2 shl 16) + (-39), (6 shl 16) + (-17),  (9 shl 16) + (-7),   (9 shl 16) + (5)
 dd (-1 shl 16) + (-29), (8 shl 16) + (-5),   (10 shl 16) + (9),   (7 shl 16) + (17)
 dd (-3 shl 16) + (-27), (9 shl 16) + (-5),   (8 shl 16) + (10),   (7 shl 16) + (23)
 dd (-2 shl 16) + (-40), (6 shl 16) + (-16),  (8 shl 16) + (-11),  (10 shl 16) + (3)
 dd (-2 shl 16) + (-54), (7 shl 16) + (-30),  (7 shl 16) + (-21),  (6 shl 16) + (-7)
 dd (-1 shl 16) + (-75), (-4 shl 16) + (-54), (-1 shl 16) + (-44), (0 shl 16) + (-30)

 dd (291 shl 16) + (28), (344 shl 16) + (76), (294 shl 16) + (103), (219 shl 16) + (112)
 dd (289 shl 16) + (70), (329 shl 16) + (119), (263 shl 16) + (170), (205 shl 16) + (159)
 dd (226 shl 16) + (109), (271 shl 16) + (164), (202 shl 16) + (195), (136 shl 16) + (191)
 dd (204 shl 16) + (131), (212 shl 16) + (194), (175 shl 16) + (194), (137 shl 16) + (204)
 dd (177 shl 16) + (132), (205 shl 16) + (187), (143 shl 16) + (224), (94 shl 16) + (227)
 dd (147 shl 16) + (118), (188 shl 16) + (178), (113 shl 16) + (199), (70 shl 16) + (197)
 dd (116 shl 16) + (72), (158 shl 16) + (121), (93 shl 16) + (142), (48 shl 16) + (161)
 dd (94 shl 16) + (30), (120 shl 16) + (76), (78 shl 16) + (101), (31 shl 16) + (111)

