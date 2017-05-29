guts for aarch64, port of x86-64 version
the registers of x86-64 have been renamed following these guidelines:

aarch64|x86-64
------volatile-------
x0      rax
x1      rcx
x2      rdx
x3      rbx (leaf)
x4      
x5      
x6      
x7      
x8      r8
x9      r9
x10     r10
x11     r11
x12     r12 (leaf)
x13     r13 (leaf)
x14     r14 (leaf)
x15     r15 (leaf)
x16     rsi (leaf)
x17     rdi (leaf)
----non-volatile-----
x19     
x20     rbp
x21     rbx
x22     r12
x23     r13
x24     r14
x25     r15
x26     rsi
x27     rdi
x28     
x29     
----special---------
x18     *dont use*
x30     *link*
sp      rsp


TranspositionTable::probe(unsigned long, bool&) const:
        mov     x4, x0
        lsr     x5, x1, 48
        ldp     x3, x0, [x0]
        sub     x3, x3, #1
        and     x1, x3, x1
        lsl     x1, x1, 5
        ldrh    w3, [x0, x1]
        add     x1, x0, x1
        cbz     w3, .L9
        cmp     w5, w3
        beq     .L10
        ldrh    w3, [x1, 10]
        add     x0, x1, 10
        cbz     w3, .L2
        cmp     w5, w3
        beq     .L3
        ldrh    w3, [x1, 20]
        add     x8, x1, 20
        cbz     w3, .L19
        cmp     w5, w3
        beq     .L20
        ldrb    w3, [x4, 24]
        ldrb    w9, [x1, 8]
        ldrb    w4, [x0, 8]
        add     w3, w3, 259
        sub     w5, w3, w9
        ldrsb   w7, [x0, 9]
        sub     w6, w3, w4
        ldrsb   w10, [x1, 9]
        and     w5, w5, 252
        and     w6, w6, 252
        sub     w5, w10, w5, lsl 1
        sub     w6, w7, w6, lsl 1
        cmp     w6, w5
        ldrb    w5, [x8, 8]
        csel    w4, w4, w9, lt
        csel    w7, w7, w10, lt
        csel    x0, x1, x0, ge
        ldrsb   w1, [x8, 9]
        sub     w4, w3, w4, uxtb
        sub     w3, w3, w5
        and     w4, w4, 252
        and     w3, w3, 252
        sxtb    w7, w7
        strb    wzr, [x2]
        sub     w3, w1, w3, lsl 1
        sub     w2, w7, w4, lsl 1
        cmp     w2, w3
        csel    x0, x8, x0, gt
        ret
.L9:
        mov     x0, x1
.L2:
        mov     w3, 0
.L5:
        strb    w3, [x2]
        ret
.L20:
        mov     x0, x8
.L3:
        ldrb    w3, [x0, 8]
        ldrb    w1, [x4, 24]
        and     w4, w3, 252
        cmp     w4, w1
        beq     .L21
        and     w3, w3, 3
        cmp     w5, wzr
        orr     w1, w3, w1
        cset    w3, ne
        strb    w1, [x0, 8]
        b       .L5
.L10:
        mov     x0, x1
        b       .L3
.L19:
        mov     x0, x8
        b       .L2
.L21:
        cmp     w5, wzr
        cset    w3, ne
        b       .L5

