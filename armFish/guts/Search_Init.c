Search_Init:
        stp  x29, x30, [sp, -144]!
        add  x29, sp, 0
        stp  x23, x24, [sp, 48]
        lea  x24, Reductions
        stp  d8, d9, [sp, 88]
       fmov  d9, 5.0e-1
        stp  x19, x20, [sp, 16]
        mov  x20, 0
        stp  x25, x26, [sp, 64]
        mov  x26, -16384
        stp  x21, x22, [sp, 32]
        str  x27, [sp, 80]
        stp  d10, d11, [sp, 104]
        stp  d12, d13, [sp, 120]
Search_Init.L5:
        mov  w22, 1
        lsl  x19, x20, 14
        eor  w25, w20, w22
        add  x19, x19, 260
        mul  x27, x20, x26
        add  x19, x24, x19
        and  w25, w25, w22
Search_Init.L4:
      scvtf  d10, w22
        mov  x21, x19
        mov  w23, 1
Search_Init.L3:
       fmov  d0, d10
         bl  log
       fmov  d8, d0
      scvtf  d0, w23
         bl  log
       fmul  d0, d8, d0
        add  x2, x21, 32768
       fmul  d0, d0, d9
     fcvtas  w0, d0
       subs  w1, w0, #1
        str  w0, [x21]
       csel  w1, w1, wzr, pl
        cmp  w0, 1
        str  w1, [x2]
       cset  w1, gt
        tst  w1, w25
        beq  Search_Init.L2
        add  w0, w0, 1
        str  w0, [x21, x27]
Search_Init.L2:
        add  w23, w23, 1
        add  x21, x21, 4
        cmp  w23, 64
        bne  Search_Init.L3
        add  w22, w22, 1
        add  x19, x19, 256
        cmp  w22, 64
        bne  Search_Init.L4
        add  x20, x20, 1
        cmp  x20, 2
        bne  Search_Init.L5

       fmov  d12, xzr
        lea  x19, FutilityMoveCounts
        ldr  d8, Search_Init.LC0
        ldr  d11, Search_Init.LC1
        add  x19, x19, 320
        ldr  d10, Search_Init.LC2
        mov  w20, 0
        ldr  d9, Search_Init.LC3
Search_Init.L6:
      scvtf  d13, w20
       fmov  d1, d8
        add  w20, w20, 1
       fadd  d0, d13, d12
         bl  pow
      fmadd  d0, d0, d11, d10
       fmov  d1, d8
     fcvtzs  w0, d0
       fadd  d0, d13, d9
        str  w0, [x19, -64]
         bl  pow
        ldr  d1, .LC4
        cmp  w20, 16
        ldr  d2, .LC5
      fmadd  d0, d0, d1, d2
     fcvtzs  w0, d0
        str  w0, [x19], 4
        bne  Search_Init.L6
        ldp  x19, x20, [sp, 16]
        ldp  x21, x22, [sp, 32]
        ldp  x23, x24, [sp, 48]
        ldp  x25, x26, [sp, 64]
        ldp  d8, d9, [sp, 88]
        ldp  d10, d11, [sp, 104]
        ldp  d12, d13, [sp, 120]
        ldr  x27, [sp, 80]
        ldp  x29, x30, [sp], 144
        ret

Search_Init.LC0:
        .word   3435973837
        .word   1073532108
Search_Init.LC1:
        .word   2130303779
        .word   1072217194
Search_Init.LC2:
        .word   858993459
        .word   1073951539
Search_Init.LC3:
        .word   4123168604
        .word   1071602728
Search_Init.LC4:
        .word   3951369912
        .word   1072740433
Search_Init.LC5:
        .word   858993459
        .word   1074213683
