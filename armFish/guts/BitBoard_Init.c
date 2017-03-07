
BitBoard_Init:
        stp  x29, x30, [sp, -16]!
         bl  Init_AdjacentFilesBB
	 bl  Init_InFrontBB
	 bl  Init_ForwardBB_PawnAttackSpan_PassedPawnMask
	 bl  Init_SquareDistance_DistanceRingBB
	 bl  Init_BetweenBB_LineBB
        ldp  x29, x30, [sp], 16
        ret


Init_InFrontBB:
        mov  x2, 0
        lea  x16, RankBB
        lea  x17, InFrontBB
Init_InFrontBB.Next:
        ldr  x1, [x16, x2]
        add  x2, x2, 8
        ldr  x3, [x17, 64]
        cmp  x2, 56
        orr  x1, x3, x1
        str  x1, [x17, 72]
        mvn  x1, x1
        str  x1, [x17], 8
        bne  Init_InFrontBB.Next
        ret


Init_ForwardBB_PawnAttackSpan_PassedPawnMask:
        mov  x3, 0
        mov  w4, 0
        lea  x0, InFrontBB
        lea  x9, FileBB
        lea  x10, ForwardBB
        lea  x11, AdjacentFilesBB
        lea  x12, PawnAttackSpan
        lea  x13, PassedPawnMask
Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L4:
        cmp  w4, 2
        beq  Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L2
      sbfiz  x17, x4, 3, 32
        add  x16, x10, x3
        add  x15, x12, x3
        add  x14, x13, x3
        mov  x1, 0
Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L3:
        asr  w2, w1, 3
        and  x8, x1, 7
        lsl  x6, x1, 3
        add  x1, x1, 1
        add  x2, x17, x2, sxtw
        cmp  x1, 64
        ldr  x7, [x0, x2, lsl 3]
        ldr  x2, [x9, x8, lsl 3]
        and  x5, x7, x2
        ldr  x2, [x11, x8, lsl 3]
        str  x5, [x16, x6]
        and  x2, x7, x2
        str  x2, [x15, x6]
        orr  x2, x5, x2
        str  x2, [x14, x6]
        bne  Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L3
        add  x3, x3, 512
        add  w4, w4, 1
          b  Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L4
Init_ForwardBB_PawnAttackSpan_PassedPawnMask.L2:
        ret


Init_AdjacentFilesBB:
        lea  x0, AdjacentFilesBB
        lea  x1, FileBB
        mov     x2, x0
        add     x1, x1, 8
        mov     x2, 0
Init_AdjacentFilesBB.L4:
        cbz     x2, Init_AdjacentFilesBB.L5
        cmp     w2, 7
        mov     x4, 0
        ldr     x3, [x1, -16]
        bne     Init_AdjacentFilesBB.L2
        b       Init_AdjacentFilesBB.L3
Init_AdjacentFilesBB.L5:
        mov     x3, 0
Init_AdjacentFilesBB.L2:
        ldr     x4, [x1]
Init_AdjacentFilesBB.L3:
        orr     x3, x4, x3
        add     x1, x1, 8
        str     x3, [x0, x2, lsl 3]
        add     x2, x2, 1
        cmp     x2, 8
        bne     Init_AdjacentFilesBB.L4
        ret


Init_BetweenBB_LineBB:
        lea  x16, LineBB
        lea  x17, BetweenBB
        lea  x20, BishopAttacksPDEP
        lea  x21, RookAttacksPDEP
        mov  x15, 0
        mov  x25, 1
Init_BetweenBB_LineBB.Next1:
        mov  x14, 0
        mov  x24, 1
Init_BetweenBB_LineBB.Next2:
        mov  x0, 0
        mov  x1, 0
        ldr  x2, [x20, x15, lsl 3]
        ldr  x3, [x21, x15, lsl 3]
        tst  x2, x24
        bne  Init_BetweenBB_LineBB.Bishop        
        tst  x3, x24
        beq  Init_BetweenBB_LineBB.Done
Init_BetweenBB_LineBB.Rook:
        RookAttacks x0, x15, xzr, x6, x7
        RookAttacks x1, x14, xzr, x6, x7
        and  x0, x0, x1
        orr  x0, x0, x25
        orr  x0, x0, x24
        RookAttacks x1, x15, x24, x6, x7
        RookAttacks x2, x14, x25, x6, x7
        and  x1, x1, x2
          b  Init_BetweenBB_LineBB.Done
Init_BetweenBB_LineBB.Bishop:
        BishopAttacks x0, x15, xzr, x6, x7
        BishopAttacks x1, x14, xzr, x6, x7
        and  x0, x0, x1
        orr  x0, x0, x25
        orr  x0, x0, x24
        BishopAttacks x1, x15, x24, x6, x7
        BishopAttacks x2, x14, x25, x6, x7
        and  x1, x1, x2
Init_BetweenBB_LineBB.Done:
        add  x2, x14, x15, lsl 6
        str  x0, [x16, x2, lsl 3]
        str  x1, [x17, x2, lsl 3]
//Display "sq: %i14  sq: %i15  line: %x0  bet: %x1\n"
        add  x14, x14, 1
        lsl  x24, x24, 1
        cmp  x14, 64
        blo  Init_BetweenBB_LineBB.Next2
        add  x15, x15, 1
        lsl  x25, x25, 1
        cmp  x15, 64
        blo  Init_BetweenBB_LineBB.Next1
        ret


Init_SquareDistance_DistanceRingBB:
        lea  x16, SquareDistance
        lea  x17, DistanceRingBB
        mov  x15, 0
Init_SquareDistance_DistanceRingBB.Next1:
        mov  x14, 0
Init_SquareDistance_DistanceRingBB.Next2:
        and  x0, x14, 7
        and  x1, x15, 7
       subs  x0, x0, x1
      csneg  x0, x0, x0, pl
       ubfx  x2, x14, 3, 3
       ubfx  x3, x15, 3, 3
       subs  x2, x2, x3
      csneg  x2, x2, x2, pl
        cmp  x0, x2
       csel  x0, x0, x2, hi
        add  x4, x14, x15, lsl 6
       strb  w0, [x16, x4]
       subs  x0, x0, 1
       cset  x2, hs
        lsl  x2, x2, x14
        add  x4, x0, x15, lsl 3
        ldr  x1, [x17, x4, lsl 3]
        orr  x1, x1, x2
        str  x1, [x17, x4, lsl 3]
        add  x14, x14, 1
        cmp  x14, 64
        blo  Init_SquareDistance_DistanceRingBB.Next2
        add  x15, x15, 1
        cmp  x15, 64
        blo  Init_SquareDistance_DistanceRingBB.Next1
        ret


