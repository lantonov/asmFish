
Position_Init.prng = 0
Position_Init.localsize = 16

Position_Init:
        stp  x29, x30, [sp, -16]!
        sub  sp, sp, Position_Init.localsize
/*
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
*/
        ldr  x0, = 1070372
        str  x0, [sp, Position_Init.prng]

        mov  x21, 0
Position_Init.PieceLoop0:
        lsl  x14, x21, 6+3
        lea  x15, Zobrist_Pieces
        add  x15, x15, x14, lsl 3
        mov  x14, 64*Pawn
Position_Init.PieceLoop1:
        add  x1, sp, Position_Init.prng
         bl  Math_Rand_i
        str  x0, [x15, x14, lsl 3]
        add  x14, x14, 1
        cmp  x14, 64*(King+1)
        blo  Position_Init.PieceLoop1
        add  x21, x21, 1
        cmp  x21, 2
        blo  Position_Init.PieceLoop0
/*
		lea   rdi, [Zobrist_Ep]
		xor   esi, esi
	.l3:	lea   rcx, [.prng]
	       call   Math_Rand_i
		mov   qword[rdi+8*rsi], rax
		add   esi, 1
		cmp   esi, 8
		 jb   .l3
*/
//Display "pieces done\n"

        lea  x15, Zobrist_Ep
        mov  x14, 0
Position_Init.l3:
        add  x1, sp, Position_Init.prng
         bl  Math_Rand_i
        str  x0, [x15, x14, lsl 3]
        add  x14, x14, 1
        cmp  x14, 8
        blo  Position_Init.l3
/*
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
*/
        lea  x15, Zobrist_Castling
        mov  x14, 0
        mov  x24, 1
Position_Init.CastlingLoop0:
        add  x1, sp, Position_Init.prng
         bl  Math_Rand_i
        mov  x21, 0
Position_Init.CastlingLoop1:
        tst  x21, x24
       csel  x1, xzr, x0, eq
        ldr  x16, [x15, x21, lsl 3]
        eor  x16, x16, x1
        str  x16, [x15, x21, lsl 3]
        add  x21, x21, 1
        cmp  x21, 16
        blo  Position_Init.CastlingLoop1
        add  x14, x14, 1
        lsl  x24, x24, 1
        cmp  x14, 4
        blo  Position_Init.CastlingLoop0
/*
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
*/
        add  x1, sp, Position_Init.prng
         bl  Math_Rand_i
        lea  x16, Zobrist_side
        str  x0, [x16]

        add  x1, sp, Position_Init.prng
         bl  Math_Rand_i
        lea  x16, Zobrist_noPawns
        str  x0, [x16]


        ldr  x0, =0x00ff0000
        lea  x16, IsPawnMasks
        str  x0, [x16, 0]
        str  x0, [x16, 8]
        mvn  x0, x0
        lea  x16, IsNotPawnMasks
        str  x0, [x16, 0]
        str  x0, [x16, 8]    
        mov  x0, 0x0ff
        lea  x16, IsNotPieceMasks
        str  x0, [x16, 0]
        str  x0, [x16, 8]     
/*
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
*/
        lea  x16, PieceValue_MG
        lea  x17, PieceValue_EG

        mov  x0, x16
        adr  x1, Position_Init.PieceValue_MG
        mov  x2, 4*8
         bl  MemoryCopy
        add  x0, x16, 4*8
        adr  x1, Position_Init.PieceValue_MG
        mov  x2, 4*8
         bl  MemoryCopy
        mov  x0, x17
        adr  x1, Position_Init.PieceValue_EG
        mov  x2, 4*8
         bl  MemoryCopy
        add  x0, x17, 4*8
        adr  x1, Position_Init.PieceValue_EG
        mov  x2, 4*8
         bl  MemoryCopy
/*
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

		lea   edi, [8*r14+r13]
		mov   dword[r12+8*rdi+0], eax
		mov   dword[r12+8*rdi+4], edx

		xor   edi, 0000111b
		mov   dword[r12+8*rdi+0], eax
		mov   dword[r12+8*rdi+4], edx

		neg   eax
		shl   edx, 16

		xor   edi, 0111000b
		mov   dword[r11+8*rdi+0], eax
		mov   dword[r11+8*rdi+4], edx

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
*/
        lea  x14, Position_Init.PSQR
        mov  x25, Pawn
Position_Init.TypeLoop:
        lea  x22, Scores_Pieces
        add  x22, x22, x25, lsl (3+6)
        add  x11, x22, 8*8*64
        mov  x24, 0
Position_Init.RankLoop:
        mov  x23, 0
Position_Init.FileLoop:
        ldr  w0, [x17, x25, lsl 2]
        ldr  w1, [x16, x25, lsl 2]
        add  w0, w0, w1, lsl 16
        ldr  w4, [x14], 4
        add  w0, w0, w4
        cmp  x25, Pawn
       csel  w1, wzr, w1, eq
        add  x15, x23, x24, lsl 3
        add  x4, x22, x15, lsl 3
        stp  w0, w1, [x4]
        eor  x15, x15, 7
        add  x4, x22, x15, lsl 3
        stp  w0, w1, [x4]
        neg  w0, w0
        lsl  w1, w1, 16
        eor  x15, x15, 56
        add  x4, x11, x15, lsl 3
        stp  w0, w1, [x4]
        eor  x15, x15, 7
        add  x4, x11, x15, lsl 3
        stp  w0, w1, [x4]
        add  x23, x23, 1
        cmp  x23, 4
        blo  Position_Init.FileLoop
        add  x24, x24, 1
        cmp  x24, 8
        blo  Position_Init.RankLoop
        add  x25, x25, 1
        cmp  x25, King
        ble  Position_Init.TypeLoop
/*
	      .Return:
		add   rsp, .localsize
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret
*/
        add  sp, sp, Position_Init.localsize
        ldp  x29, x30, [sp], 16
        ret


Position_Init.PieceValue_MG:
 .word 0, 0, PawnValueMg, KnightValueMg, BishopValueMg, RookValueMg, QueenValueMg, 0
Position_Init.PieceValue_EG:
 .word 0, 0, PawnValueEg, KnightValueEg, BishopValueEg, RookValueEg, QueenValueEg, 0


Position_Init.PSQR:
 .word 0,0,0,0
 .word (-11 << 16) + ( 7), (  6 << 16) + (-4), ( 7 << 16) + ( 8), ( 3 << 16) + (-2)
 .word (-18 << 16) + (-4), ( -2 << 16) + (-5), (19 << 16) + ( 5), (24 << 16) + ( 4)
 .word (-17 << 16) + ( 3), ( -9 << 16) + ( 3), (20 << 16) + (-8), (35 << 16) + (-3)
 .word ( -6 << 16) + ( 8), (  5 << 16) + ( 9), ( 3 << 16) + ( 7), (21 << 16) + (-6)
 .word ( -6 << 16) + ( 8), ( -8 << 16) + (-5), (-6 << 16) + ( 2), (-2 << 16) + ( 4)
 .word ( -4 << 16) + ( 3), ( 20 << 16) + (-9), (-8 << 16) + ( 1), (-4 << 16) + (18)
 .word 0,0,0,0

 .word (-144 << 16) + (-98), (-96 << 16) + (-82), (-80 << 16) + (-46), (-73 << 16) + (-14)
 .word (-83 << 16) + (-69), (-43 << 16) + (-54), (-21 << 16) + (-17), (-10 << 16) + (9)
 .word (-71 << 16) + (-50), (-22 << 16) + (-39), (0 << 16) + (-7), (9 << 16) + (28)
 .word (-25 << 16) + (-41), (18 << 16) + (-25), (43 << 16) + (6), (47 << 16) + (38)
 .word (-26 << 16) + (-46), (16 << 16) + (-25), (38 << 16) + (3), (50 << 16) + (40)
 .word (-11 << 16) + (-54), (37 << 16) + (-38), (56 << 16) + (-7), (65 << 16) + (27)
 .word (-62 << 16) + (-65), (-17 << 16) + (-50), (5 << 16) + (-24), (14 << 16) + (13)
 .word (-194 << 16) + (-109), (-66 << 16) + (-89), (-42 << 16) + (-50), (-29 << 16) + (-13)

 .word (-44 << 16) + (-58), (-13 << 16) + (-31), (-25 << 16) + (-37), (-34 << 16) + (-19)
 .word (-20 << 16) + (-34), (20 << 16) + (-9),	(12 << 16) + (-14),   (1 << 16) + (4)
 .word (-9 << 16) + (-23), (27 << 16) + (0),	(21 << 16) + (-3),  (11 << 16) + (16)
 .word (-11 << 16) + (-26), (28 << 16) + (-3),	(21 << 16) + (-5),  (10 << 16) + (16)
 .word (-11 << 16) + (-26), (24 << 16) + (-4),	(16 << 16) + (-7),   (9 << 16) + (14)
 .word (-17 << 16) + (-24), (16 << 16) + (-2),	(12 << 16) + (0),   (2 << 16) + (13)
 .word (-23 << 16) + (-34), (17 << 16) + (-10),	(6 << 16) + (-12),  (-2 << 16) + (6)
 .word (-35 << 16) + (-55), (-11 << 16) + (-32), (-19 << 16) + (-36), (-29 << 16) + (-17)

 .word (-25 << 16) + (0), (-16 << 16) + (0), (-16 << 16) + (0), (-9 << 16) + (0)
 .word (-21 << 16) + (0), (-8 << 16) + (0), (-3 << 16) + (0), (0 << 16) + (0)
 .word (-21 << 16) + (0), (-9 << 16) + (0), (-4 << 16) + (0), (2 << 16) + (0)
 .word (-22 << 16) + (0), (-6 << 16) + (0), (-1 << 16) + (0), (2 << 16) + (0)
 .word (-22 << 16) + (0), (-7 << 16) + (0), (0 << 16) + (0), (1 << 16) + (0)
 .word (-21 << 16) + (0), (-7 << 16) + (0), (0 << 16) + (0), (2 << 16) + (0)
 .word (-12 << 16) + (0), (4 << 16) + (0), (8 << 16) + (0), (12 << 16) + (0)
 .word (-23 << 16) + (0), (-15 << 16) + (0), (-11 << 16) + (0), (-5 << 16) + (0)

 .word (0 << 16) + (-71),  (-4 << 16) + (-56), (-3 << 16) + (-42), (-1 << 16) + (-29)
 .word (-4 << 16) + (-56), (6 << 16) + (-30),  (9 << 16) + (-21),  (8 << 16) + (-5)
 .word (-2 << 16) + (-39), (6 << 16) + (-17),  (9 << 16) + (-8),   (9 << 16) + (5)
 .word (-1 << 16) + (-29), (8 << 16) + (-5),   (10 << 16) + (9),   (7 << 16) + (19)
 .word (-3 << 16) + (-27), (9 << 16) + (-5),   (8 << 16) + (10),   (7 << 16) + (21)
 .word (-2 << 16) + (-40), (6 << 16) + (-16),  (8 << 16) + (-10),  (10 << 16) + (3)
 .word (-2 << 16) + (-55), (7 << 16) + (-30),  (7 << 16) + (-21),  (6 << 16) + (-6)
 .word (-1 << 16) + (-74), (-4 << 16) + (-55), (-1 << 16) + (-43), (0 << 16) + (-30)

 .word (267 << 16) + (  0), (320 << 16) + ( 48), (270 << 16) + ( 75), (195 << 16) + ( 84)
 .word (264 << 16) + ( 43), (304 << 16) + ( 92), (238 << 16) + (143), (180 << 16) + (132)
 .word (200 << 16) + ( 83), (245 << 16) + (138), (176 << 16) + (167), (110 << 16) + (165)
 .word (177 << 16) + (106), (185 << 16) + (169), (148 << 16) + (169), (110 << 16) + (179)
 .word (149 << 16) + (108), (177 << 16) + (163), (115 << 16) + (200), ( 66 << 16) + (203)
 .word (118 << 16) + ( 95), (159 << 16) + (155), ( 84 << 16) + (176), ( 41 << 16) + (174)
 .word ( 86 << 16) + ( 50), (128 << 16) + ( 99), ( 63 << 16) + (122), ( 18 << 16) + (139)
 .word ( 63 << 16) + (  9), ( 89 << 16) + ( 55), ( 47 << 16) + ( 80), (  0 << 16) + ( 90)
