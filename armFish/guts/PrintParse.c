StringLength:
// in: x0 address of null terminates string
//     x0 length

        sub  x1, x0, 1
1:
       ldrb  w2, [x1,1]!
       cbnz  w2, 1b
        sub  x0, x1, x0
        ret



1:
       strb  w1, [x15], 1
PrintString:
// in: x0 address of source string
// io: x15 string
       ldrb  w1, [x0], 1
       cbnz  w1, 1b
        ret


PrintFancy:
// in: x0 address of source string
//     x1 address of dword array
// io: x15 string with ie #3 replaced by x1[3] ect
        stp  x29, x30, [sp,-16]!
        stp  x28, x14, [sp,-16]!
        mov  x14, x0
        mov  x28, x1
PrintFancy.Loop:
       ldrb  w0, [x14], 1
        cmp  w0, 35
        beq  PrintFancy.GotOne
        cbz  w0, PrintFancy.Done
       strb  w0, [x15], 1
          b  PrintFancy.Loop
PrintFancy.Done:
        ldp  x28, x14, [sp],16
        ldp  x29, x30, [sp],16
        ret
PrintFancy.GotOne:
         bl  ParseInteger
        ldr  x0, [x28,x0,lsl 3]
         bl  PrintHex  
          b  PrintFancy.Loop
        

        


CmpString:
        mov  x3, x14
1:
       ldrb  w1, [x0], 1
        cbz  w1, 2f
       ldrb  w2, [x3], 1
        cmp  w1, w2
        beq  1b

        mov  w0, 0
        ret
2:
        mov  x14, x3
        mov  w0, -1
        ret

1:
        add  x14, x14, 1
SkipSpaces:
       ldrb  w0, [x14]
        cmp  w0, 32
        beq  1b
        ret

ParseToken.Get:
        add  x14, x14, 1
       strb  w1, [x15], 1
ParseToken:
       ldrb  w1, [x14]
       subs  x0, x0, 1
        blo  ParseToken.Done
        cmp  w1, 47
        blo  ParseToken.Done
        cmp  w1, 58
        blo  ParseToken.Get
        cmp  w1, 56
        blo  ParseToken.Done
        cmp  w1, 91
        blo  ParseToken.Get
        cmp  w1, 92
        beq  ParseToken.Get
        cmp  w1, 97
        blo  ParseToken.Done
        cmp  w1, 128
        blo  ParseToken.Get
ParseToken.Done:
        ret


PrintHex:
        mov  w4, 16                
PrintHex.Next:
        ror  x0, x0, 60
        and  x1, x0, 15
        cmp  w1, 10
        add  w2, w1, 48
        add  w3, w1, 65-10
       csel  w1, w2, w3, lo
       strb  w1, [x15], 1                
        sub  w4, w4, 1
       cbnz  w4, PrintHex.Next
        ret


PrintSignedInteger:
// in: x0 signed integer
// io: x15 string

        tst  x0, x0
        mov  w1, '-'
       strb  w1, [x15]
      csinc  x15, x15, x15, pl
      csneg  x0, x0, x0, pl

PrintUnsignedInteger:
// in: x0 signed integer
// io: x15 string

        sub  sp, sp, 64
        mov  x3, 0
        mov  x2, 10
1:
       udiv  x1, x0, x2
       msub  x0, x1, x2, x0
       strb  w0, [sp, x3]
        add  x3, x3, 1
        mov  x0, x1
       cbnz  x1, 1b
2:
       subs  x3, x3, 1
       ldrb  w0, [sp, x3]
        add  w0, w0, 48
       strb  w0, [x15], 1
        bhi  2b

        add  sp, sp, 64
        ret

ParseInteger:
// io: x14 string
// out: x0
//DisplayString "enter ParseInteger x14: "
//DisplayReg x14
//DisplayString "\n"

       ldrb  w1, [x14]
        mov  x2, 0
        mov  x0, 0
        cmp  w1, 45
        beq  1f
        cmp  w1, 43
        beq  2f
          b  3f
1:      mvn  x2, x2
2:      add  x14, x14, 1
3:     ldrb  w1, [x14]
       subs  w1, w1, 48
        blo  4f
        cmp  w1, 9
        bhi  4f
        add  x14, x14, 1
        add  x0, x0, x0, lsl 2
        add  x0, x1, x0, lsl 1
          b  3b
4:      eor  x0, x0, x2
        sub  x0, x0, x2
//DisplayString "leave ParseInteger x14: "
//DisplayReg x14
//DisplayString "\n"

        ret





GetLine:
// out: w0 = 0 if success, =-1 if failed
//      x1 length of string
//      x14 address of string

        stp  x29, x30, [sp,-16]!
        stp  x27, x28, [sp,-16]!
        stp  x25, x26, [sp,-16]!
        stp  x23, x24, [sp,-16]!
        stp  x21, x22, [sp,-16]!
        stp  x19, x20, [sp,-16]!

       adrp  x29, ioBuffer
        add  x29, x29, :lo12:ioBuffer

        ldr  w22, [x29,IOBuffer.tmp_i]
        ldr  w23, [x29,IOBuffer.tmp_j]
        ldr  x24, [x29,IOBuffer.inputBufferSizeB]
        ldr  x25, [x29,IOBuffer.inputBuffer]
        mov  x28, 0
1:
        cmp  x28, x24
        bhs  7f
2:
        cmp  x22, x23
        bhs  5f
3:
        add  x0, x29, IOBuffer.tmpBuffer
       ldrb  w0, [x0,x22]
        add  x22, x22, 1
       strb  w0, [x25,x28]
        add  x28, x28, 1
        cmp  w0, 32
        bhs  1b

        mov  w0, 0
4:
        str  w22, [x29,IOBuffer.tmp_i]
        str  w23, [x29,IOBuffer.tmp_j]
        str  x24, [x29,IOBuffer.inputBufferSizeB]
        str  x25, [x29,IOBuffer.inputBuffer]

        mov  x14, x25
        mov  x1, x28

        ldp  x19, x20, [sp], 16
        ldp  x21, x22, [sp], 16
        ldp  x23, x24, [sp], 16
        ldp  x25, x26, [sp], 16
        ldp  x27, x28, [sp], 16
        ldp  x29, x30, [sp], 16
        ret
5:
        mov  x22, 0
        add  x0, x29, IOBuffer.tmpBuffer
        mov  x1, 512
         bl  Os_ReadStdIn
        mov  x23, x0
        cmp  x0, 1
        bge  3b
6:
        mov  w0, -1
        mov  x23, 0
          b  4b
7:
// get new buffer
        add  x0, x24, 4096
         bl  Os_VirtualAlloc
        mov  x23, x0
        mov  x19, x0
// copy data
        mov  x20, x25
        mov  x0, x24
         bl  RepMovsb
// free old buffer
        mov  x0, x25
        mov  x1, x24
         bl  Os_VirtualFree
// set new data
        mov  x25, x23
        add  x24, x24, 4096
          b  2b


1:
        sub  x0, x0, 1
       ldrb  w1, [x20], 1
       strb  w1, [x19], 1
RepMovsb:
       cbnz  x0, 1b
        ret
