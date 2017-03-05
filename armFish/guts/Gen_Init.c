
SlidingAttacks:
// in: x14 address of directions null terminated
//     x21 square  (preserved)
//     x7 occupation (preserved)
//     x8 step count (preserved)
// out: x0 bitboard
        mov  x0, 0
          b  SlidingAttacks.NextDirection
SlidingAttacks.NextSquare:
	add  x9, x9, 1
	cmp  x9, x8
	bhi  SlidingAttacks.NextDirection
// in: x1 square
//     x4 x coord
//     x5 y coord
// out: x1 square x1 + (x,y)
        and  x2, x1, 0x07
       ubfx  x3, x1, 3, 3
        add  x2, x2, x4
        add  x3, x3, x5
        cmp  x2, 8
       ccmp  x3, 8, 0b0010, lo  // nzcv
        bhs  SlidingAttacks.NextDirection
        add  x1, x2, x3,lsl 3
        mov  x2, 1
        lsl  x2, x2, x1
        orr  x0, x0, x2
        tst  x7, x2
        beq  SlidingAttacks.NextSquare
SlidingAttacks.NextDirection:
      ldrsb  x4, [x14],1
      ldrsb  x5, [x14],1
	mov  x1, x21
	mov  x9, 0
        orr  x2, x4, x5
       cbnz  x2, SlidingAttacks.NextSquare
	ret


Directions.KingAttacks:
        .byte +1,+1, +1,00, +1,-1, 00,+1, 00,-1, -1,+1, -1,00, -1,-1,  0,0
Directions.KnightAttacks:
        .byte +2,+1, +2,-1, -2,+1, -2,-1, +1,+2, -1,+2, +1,-2, -1,-2,  0,0
Directions.RookAttacks:
        .byte +1,00, -1,00, 00,+1,  0,-1,  0,0
Directions.BishopAttacks:
        .byte +1,+1, -1,+1, +1,-1, -1,-1,  0,0
Directions.WhitePawnAttacks:
        .byte +1,+1, -1,+1,  0,0
Directions.BlackPawnAttacks:
        .byte +1,-1, -1,-1,  0,0


Gen_Init:
        stp  x29, x30, [sp, -16]!


Init_FileBB:
       adrp  x15, FileBB
        add  x15, x15, :lo12:FileBB
	mov  x1, 8
        ldr  x0, =FileABB
Init_FileBB.Next:
        str  x0, [x15], 8
        lsl  x0, x0, 1
       subs  x1, x1, 1
        bne  Init_FileBB.Next


Init_RankBB:
       adrp  x15, RankBB
        add  x15, x15, :lo12:RankBB
	mov  x1, 8
        mov  x0, 0x0ff
Init_RankBB.Next:
        str  x0, [x15], 8
        lsl  x0, x0, 8
       subs  x1, x1, 1
        bne  Init_RankBB.Next


// Fixed shift magics found by Volker Annuss.
// From: http://talkchess.com/forum/viewtopic.php?p=670709#670709

Init_Attacks:
        mov  x21, 0

Init_Attacks.NextSquare:
        mov  x7, 0
        mov  x8, 1

        adr  x14, Directions.KnightAttacks
         bl  SlidingAttacks
        Lea  x16, KnightAttacks
	str  x0, [x16, x21, lsl 3]

        adr  x14, Directions.KingAttacks
         bl  SlidingAttacks
        Lea  x16, KingAttacks
	str  x0, [x16, x21, lsl 3]

        adr  x14, Directions.WhitePawnAttacks
         bl  SlidingAttacks
        Lea  x16, WhitePawnAttacks
	str  x0, [x16, x21, lsl 3]

        adr  x14, Directions.BlackPawnAttacks
         bl  SlidingAttacks
        Lea  x16, BlackPawnAttacks
	str  x0, [x16, x21, lsl 3]

        Lea  x15, FileBB
        Lea  x14, RankBB

        and  x0, x21, 7
	ldr  x23, = ~ (FileABB | FileHBB)
        ldr  x0, [x15, x0, lsl 3]
	orr  x23, x23, x0

       ubfx  x0, x21, 3, 3
	ldr  x22, = ~ (Rank1BB | Rank8BB)
        ldr  x0, [x14, x0, lsl 3]
	orr  x22, x22, x0
	and  x23, x23, x22

        mov  x8, -1

        adr  x14, Directions.RookAttacks
         bl  SlidingAttacks
        Lea  x16, RookAttacksPDEP
        Lea  x17, RookAttacksPEXT
        str  x0, [x16, x21, lsl 3]
        and  x0, x0, x23
        str  x0, [x17, x21, lsl 3]

        adr  x14, Directions.BishopAttacks
         bl  SlidingAttacks
        Lea  x16, BishopAttacksPDEP
        Lea  x17, BishopAttacksPEXT
        str  x0, [x16, x21, lsl 3]
        and  x0, x0, x23
        str  x0, [x17, x21, lsl 3]

        lsl  x21, x21, 4        
        Lea  x19, SlidingAttacksBB
        adr  x16, Init_Attacks.RookData
        adr  x17, Init_Attacks.BishopData
        add  x5, x21, 8
        ldr  x0, [x16,x21]
        ldr  x1, [x16,x5]
        ldr  x2, [x17,x21]
        ldr  x3, [x17,x5]
        add  x1, x19, x1,lsl 3
        add  x3, x19, x3,lsl 3
        lsr  x21, x21, 4

        Lea  x16, RookAttacksIMUL
        Lea  x17, RookAttacksMOFF       
        str  x0, [x16, x21,lsl 3]
        str  x1, [x17, x21,lsl 3]
        Lea  x16, BishopAttacksIMUL
        Lea  x17, BishopAttacksMOFF
        str  x2, [x16,x21,lsl 3]
        str  x3, [x17,x21,lsl 3]

        mov  x7, 0
Init_Attacks.NextRookSubset:
        adr  x14, Directions.RookAttacks
         bl  SlidingAttacks
        Lea  x16, RookAttacksPEXT
        Lea  x17, RookAttacksIMUL
        Lea  x19, RookAttacksMOFF

        ldr  x1, [x16, x21, lsl 3]
        ldr  x2, [x17, x21, lsl 3]
        ldr  x9, [x19, x21, lsl 3]
        and  x3, x1, x7
        mul  x3, x3, x2
        lsr  x3, x3, 64-12
        str  x0, [x9,x3,lsl 3]
        sub  x7, x7, x1
       ands  x7, x7, x1
        bne  Init_Attacks.NextRookSubset
        
        mov  x7, 0
Init_Attacks.NextBishopSubset:
        adr  x14, Directions.BishopAttacks
         bl  SlidingAttacks
        Lea  x16, BishopAttacksPEXT
        Lea  x17, BishopAttacksIMUL
        Lea  x19, BishopAttacksMOFF

        ldr  x1, [x16, x21, lsl 3]
        ldr  x2, [x17, x21, lsl 3]
        ldr  x9, [x19, x21, lsl 3]
        and  x3, x1, x7
        mul  x3, x3, x2
        lsr  x3, x3, 64-9
        str  x0, [x9,x3,lsl 3]
        sub  x7, x7, x1
       ands  x7, x7, x1
        bne  Init_Attacks.NextBishopSubset

	add   x21, x21, 1
	cmp   x21, 64
        blo   Init_Attacks.NextSquare

Init_Attacks.Done:
        ldp  x29, x30, [sp],16
	ret

Init_Attacks.RookData:
   .dword 0x00280077ffebfffe,  41305
   .dword 0x2004010201097fff,  14326
   .dword 0x0010020010053fff,  24477
   .dword 0x0030002ff71ffffa,   8223
   .dword 0x7fd00441ffffd003,  49795
   .dword 0x004001d9e03ffff7,  60546
   .dword 0x004000888847ffff,  28543
   .dword 0x006800fbff75fffd,  79282
   .dword 0x000028010113ffff,   6457
   .dword 0x0020040201fcffff,   4125
   .dword 0x007fe80042ffffe8,  81021
   .dword 0x00001800217fffe8,  42341
   .dword 0x00001800073fffe8,  14139
   .dword 0x007fe8009effffe8,  19465
   .dword 0x00001800602fffe8,   9514
   .dword 0x000030002fffffa0,  71090
   .dword 0x00300018010bffff,  75419
   .dword 0x0003000c0085fffb,  33476
   .dword 0x0004000802010008,  27117
   .dword 0x0002002004002002,  85964
   .dword 0x0002002020010002,  54915
   .dword 0x0001002020008001,  36544
   .dword 0x0000004040008001,  71854
   .dword 0x0000802000200040,  37996
   .dword 0x0040200010080010,  30398
   .dword 0x0000080010040010,  55939
   .dword 0x0004010008020008,  53891
   .dword 0x0000040020200200,  56963
   .dword 0x0000010020020020,  77451
   .dword 0x0000010020200080,  12319
   .dword 0x0000008020200040,  88500
   .dword 0x0000200020004081,  51405
   .dword 0x00fffd1800300030,  72878
   .dword 0x007fff7fbfd40020,    676
   .dword 0x003fffbd00180018,  83122
   .dword 0x001fffde80180018,  22206
   .dword 0x000fffe0bfe80018,  75186
   .dword 0x0001000080202001,    681
   .dword 0x0003fffbff980180,  36453
   .dword 0x0001fffdff9000e0,  20369
   .dword 0x00fffeebfeffd800,   1981
   .dword 0x007ffff7ffc01400,  13343
   .dword 0x0000408104200204,  10650
   .dword 0x001ffff01fc03000,  57987
   .dword 0x000fffe7f8bfe800,  26302
   .dword 0x0000008001002020,  58357
   .dword 0x0003fff85fffa804,  40546
   .dword 0x0001fffd75ffa802,      0
   .dword 0x00ffffec00280028,  14967
   .dword 0x007fff75ff7fbfd8,  80361
   .dword 0x003fff863fbf7fd8,  40905
   .dword 0x001fffbfdfd7ffd8,  58347
   .dword 0x000ffff810280028,  20381
   .dword 0x0007ffd7f7feffd8,  81868
   .dword 0x0003fffc0c480048,  59381
   .dword 0x0001ffffafd7ffd8,  84404
   .dword 0x00ffffe4ffdfa3ba,  45811
   .dword 0x007fffef7ff3d3da,  62898
   .dword 0x003fffbfdfeff7fa,  45796
   .dword 0x001fffeff7fbfc22,  66994
   .dword 0x0000020408001001,  67204
   .dword 0x0007fffeffff77fd,  32448
   .dword 0x0003ffffbf7dfeec,  62946
   .dword 0x0001ffff9dffa333,  17005

Init_Attacks.BishopData:
   .dword 0x0000404040404040,  33104
   .dword 0x0000a060401007fc,   4094
   .dword 0x0000401020200000,  24764
   .dword 0x0000806004000000,  13882
   .dword 0x0000440200000000,  23090
   .dword 0x0000080100800000,  32640
   .dword 0x0000104104004000,  11558
   .dword 0x0000020020820080,  32912
   .dword 0x0000040100202004,  13674
   .dword 0x0000020080200802,   6109
   .dword 0x0000010040080200,  26494
   .dword 0x0000008060040000,  17919
   .dword 0x0000004402000000,  25757
   .dword 0x00000021c100b200,  17338
   .dword 0x0000000400410080,  16983
   .dword 0x000003f7f05fffc0,  16659
   .dword 0x0004228040808010,  13610
   .dword 0x0000200040404040,   2224
   .dword 0x0000400080808080,  60405
   .dword 0x0000200200801000,   7983
   .dword 0x0000240080840000,     17
   .dword 0x000018000c03fff8,  34321
   .dword 0x00000a5840208020,  33216
   .dword 0x0000058408404010,  17127
   .dword 0x0002022000408020,   6397
   .dword 0x0000402000408080,  22169
   .dword 0x0000804000810100,  42727
   .dword 0x000100403c0403ff,    155
   .dword 0x00078402a8802000,   8601
   .dword 0x0000101000804400,  21101
   .dword 0x0000080800104100,  29885
   .dword 0x0000400480101008,  29340
   .dword 0x0001010102004040,  19785
   .dword 0x0000808090402020,  12258
   .dword 0x0007fefe08810010,  50451
   .dword 0x0003ff0f833fc080,   1712
   .dword 0x007fe08019003042,  78475
   .dword 0x0000202040008040,   7855
   .dword 0x0001004008381008,  13642
   .dword 0x0000802003700808,   8156
   .dword 0x0000208200400080,   4348
   .dword 0x0000104100200040,  28794
   .dword 0x0003ffdf7f833fc0,  22578
   .dword 0x0000008840450020,  50315
   .dword 0x0000020040100100,  85452
   .dword 0x007fffdd80140028,  32816
   .dword 0x0000202020200040,  13930
   .dword 0x0001004010039004,  17967
   .dword 0x0000040041008000,  33200
   .dword 0x0003ffefe0c02200,  32456
   .dword 0x0000001010806000,   7762
   .dword 0x0000000008403000,   7794
   .dword 0x0000000100202000,  22761
   .dword 0x0000040100200800,  14918
   .dword 0x0000404040404000,  11620
   .dword 0x00006020601803f4,  15925
   .dword 0x0003ffdfdfc28048,  32528
   .dword 0x0000000820820020,  12196
   .dword 0x0000000010108060,  32720
   .dword 0x0000000000084030,  26781
   .dword 0x0000000001002020,  19817
   .dword 0x0000000040408020,  24732
   .dword 0x0000004040404040,  25468
   .dword 0x0000404040404040,  10186
