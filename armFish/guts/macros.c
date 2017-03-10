// macro names seem to be case insensitive
.macro ClampUnsigned Reg, RegMin, RegMax

.endm

.macro ClampSigned Reg, RegMin, RegMax

.endm

.macro lea Reg, Addr
       adrp  \Reg, \Addr
        add  \Reg, \Reg, :lo12:\Addr
.endm

.macro AddSub T, A, B, C
 .if \T == White
        sub  A, B, C
 .else
        add  A, B, C
 .endif    
.endm

.macro PrintNewLine
        mov  w0, 10
       strb  w0, [x15], 1
.endm

.macro PushAll

        stp  d30, d31, [sp, -16]!
        stp  d28, d29, [sp, -16]!
        stp  d26, d27, [sp, -16]!
        stp  d24, d25, [sp, -16]!
        stp  d22, d23, [sp, -16]!
        stp  d20, d21, [sp, -16]!
        stp  d18, d19, [sp, -16]!
        stp  d16, d17, [sp, -16]!
        stp  d14, d15, [sp, -16]!
        stp  d12, d13, [sp, -16]!
        stp  d10, d11, [sp, -16]!
        stp  d8, d9, [sp, -16]!
        stp  d6, d7, [sp, -16]!
        stp  d4, d5, [sp, -16]!
        stp  d2, d3, [sp, -16]!
        stp  d0, d1, [sp, -16]!

        stp  x30, x0, [sp, -16]!
        stp  x28, x29, [sp, -16]!
        stp  x26, x27, [sp, -16]!
        stp  x24, x25, [sp, -16]!
        stp  x22, x23, [sp, -16]!
        stp  x20, x21, [sp, -16]!
        stp  x18, x19, [sp, -16]!
        stp  x16, x17, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        stp  x12, x13, [sp, -16]!
        stp  x10, x11, [sp, -16]!
        stp  x8, x9, [sp, -16]!
        stp  x6, x7, [sp, -16]!
        stp  x4, x5, [sp, -16]!
        stp  x2, x3, [sp, -16]!
        stp  x0, x1, [sp, -16]!
.endm

.macro PopAll
        ldp  x0, x1, [sp], 16
        ldp  x2, x3, [sp], 16
        ldp  x4, x5, [sp], 16
        ldp  x6, x7, [sp], 16
        ldp  x8, x9, [sp], 16
        ldp  x10, x11, [sp], 16
        ldp  x12, x13, [sp], 16
        ldp  x14, x15, [sp], 16
        ldp  x16, x17, [sp], 16
        ldp  x18, x19, [sp], 16
        ldp  x20, x21, [sp], 16
        ldp  x22, x23, [sp], 16
        ldp  x24, x25, [sp], 16
        ldp  x26, x27, [sp], 16
        ldp  x28, x29, [sp], 16
        ldp  x30, x0, [sp], 16

        ldp  d0, d1, [sp], 16
        ldp  d2, d3, [sp], 16
        ldp  d4, d5, [sp], 16
        ldp  d6, d7, [sp], 16
        ldp  d8, d9, [sp], 16
        ldp  d10, d11, [sp], 16
        ldp  d12, d13, [sp], 16
        ldp  d14, d15, [sp], 16
        ldp  d16, d17, [sp], 16
        ldp  d18, d19, [sp], 16
        ldp  d20, d21, [sp], 16
        ldp  d22, d23, [sp], 16
        ldp  d24, d25, [sp], 16
        ldp  d26, d27, [sp], 16
        ldp  d28, d29, [sp], 16
        ldp  d30, d31, [sp], 16

.endm

// Display a formated message. Use %[x,i,u]n for displaying
// register xn in hex, signed or unsigned.
// ex: Display "sq: %i14  sq: %i15  line: %x0  bet: %x1\n"
.macro Display Message
        PushAll
        adr  x1, anom\@
          b  anol\@
anom\@:
        .ascii \Message
        .byte 0
        .balign 4
anol\@:
        Lea  x15, Output
        mov  x2, sp
         bl  PrintFancy
         bl  Os_WriteOut_Output
        PopAll
.endm

.macro DisplayString Message
        PushAll
        adr  x1, anom\@
          b  anol\@
anom\@:
        .ascii \Message
        .byte 0
        .balign 4
anol\@:
        Lea  x15, Output
         bl  PrintString
         bl  Os_WriteOut_Output
        PopAll
.endm

.macro DisplayReg Reg
        PushAll
        mov  x0, Reg
        Lea  x15, Output
         bl  PrintHex
         bl  Os_WriteOut_Output
        PopAll     
.endm

.macro DisplayPause
        PushAll
        mov  x1, 1000
         bl  Os_Sleep
        PopAll     
.endm

.macro ToLower Reg
        sub  \Reg, \Reg, 'A'
        cmp  \Reg, 'Z'-'A'+1
        bhs  loc_Lower\@
        add  \Reg, \Reg, 'a'-'A'
loc_Lower\@:
        add  \Reg, \Reg, 'A'
.endm

