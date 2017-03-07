Pawn_Init:
        lea     x1, Connected
        adr     x8, Pawn_Init.Seed
        add     x1, x1, 4
        mov     w3, 0
        mov     w11, 2
        mov     w13, 4
Pawn_Init.L7:
        mov     x9, x1
        mov     w4, 0
Pawn_Init.L6:
        mov     x10, x9
        mov     w5, 0
Pawn_Init.L5:
        add     x7, x8, 4
        mov     x12, x10
        mov     w6, -1
Pawn_Init.L4:
        mov     w2, 0
        ldr     w0, [x7]
        cbz     w4, Pawn_Init.L2
        ldr     w2, [x7, 4]
        sub     w2, w2, w0
        sdiv    w2, w2, w11
Pawn_Init.L2:
        add     w0, w2, w0
        mov     w2, 0
        asr     w0, w0, w3
        cbz     w5, Pawn_Init.L3
        sdiv    w2, w0, w11
Pawn_Init.L3:
        add     w0, w2, w0
        add     x7, x7, 4
        mul     w2, w6, w0
        add     w6, w6, 1
        cmp     w6, 5
        sdiv    w2, w2, w13
        add     w0, w2, w0, lsl 16
        str     w0, [x12], 4
        bne     Pawn_Init.L4
        add     w5, w5, 1
        add     x10, x10, 32
        cmp     w5, 2
        bne     Pawn_Init.L5
        add     w4, w4, 1
        add     x9, x9, 64
        cmp     w4, 2
        bne     Pawn_Init.L6
        add     w3, w3, 1
        add     x1, x1, 128
        cmp     w3, 2
        bne     Pawn_Init.L7
        ret

Pawn_Init.Seed:
        .word   0
        .word   8
        .word   19
        .word   13
        .word   71
        .word   94
        .word   169
        .word   324
