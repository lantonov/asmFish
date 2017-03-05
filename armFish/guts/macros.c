// macro names seem to be case insensitive

.macro lea Reg, Addr
       adrp  Reg, \Addr
        add  Reg, Reg, :lo12:\Addr
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
        stp  x30, x0, [sp,-16]!
        stp  x28, x29, [sp,-16]!
        stp  x26, x27, [sp,-16]!
        stp  x24, x25, [sp,-16]!
        stp  x22, x23, [sp,-16]!
        stp  x20, x21, [sp,-16]!
        stp  x18, x19, [sp,-16]!
        stp  x16, x17, [sp,-16]!
        stp  x14, x15, [sp,-16]!
        stp  x12, x13, [sp,-16]!
        stp  x10, x11, [sp,-16]!
        stp  x8, x9, [sp,-16]!
        stp  x6, x7, [sp,-16]!
        stp  x4, x5, [sp,-16]!
        stp  x2, x3, [sp,-16]!
        stp  x0, x1, [sp,-16]!
.endm

.macro PopAll
        ldp  x0, x1, [sp],16
        ldp  x2, x3, [sp],16
        ldp  x4, x5, [sp],16
        ldp  x6, x7, [sp],16
        ldp  x8, x9, [sp],16
        ldp  x10, x11, [sp],16
        ldp  x12, x13, [sp],16
        ldp  x14, x15, [sp],16
        ldp  x16, x17, [sp],16
        ldp  x18, x19, [sp],16
        ldp  x20, x21, [sp],16
        ldp  x22, x23, [sp],16
        ldp  x24, x25, [sp],16
        ldp  x26, x27, [sp],16
        ldp  x28, x29, [sp],16
        ldp  x30, x0, [sp],16
.endm

// Display a formated message. Use %[x,i,u]n for displaying
// register xn in hex, signed or unsigned.
// ex: Display "sq: %i14  sq: %i15  line: %x0  bet: %x1\n"
.macro Display Message
        PushAll
        adr  x0, anom\@
          b  anol\@
anom\@:
        .ascii \Message
        .byte 0
        .balign 4
anol\@:
        Lea  x15, Output
        mov  x1, sp
         bl  PrintFancy
         bl  Os_WriteOut_Output
        PopAll
.endm

.macro DisplayString Message
        PushAll
        adr  x0, anom\@
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
        mov  x0, 1000
         bl  Os_Sleep
        PopAll     
.endm

.macro rep_movsb pl
        tst  x1, x1
        beq  \pl&.over\@
\pl&.back\@:
       ldrb  w0, [x14], 1
       strb  w0, [x15], 1
       subs  x1, x1, 1
        bne  \pl&.back\@
\pl&.over\@:
.endm

.macro tester cnt
                mov  w0, \cnt
               strb  w0, [x17], 1
        \cnt = \cnt-1
                mov  w0, \cnt
               strb  w0, [x17], 1

.if \cnt
                
                mov  w0, 'A'
               strb  w0, [x17], 1
.endif

.endm


.macro increment t, reg
.if \t
                add  reg, reg, 1
.else
                sub  reg, reg, 1
.endif

.endm

