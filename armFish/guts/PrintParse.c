
StringLength:
// in:  x0 address of null terminated string
// out: x0 length
        sub  x1, x0, 1
StringLength.Next:
       ldrb  w2, [x1,1]!
       cbnz  w2, StringLength.Next
        sub  x0, x1, x0
        ret


PrintString.Next:
       strb  w1, [x15], 1
PrintString:
// in: x0 address of source string
// io: x15 string
       ldrb  w1, [x0], 1
       cbnz  w1, PrintString.Next
        ret


PrintFancy:
// in: x0 address of source string
//     x1 address of dword array
// io: x15 string with ie %x3 replaced by x1[3] ect
        stp  x29, x30, [sp, -16]!
        stp  x28, x14, [sp, -16]!
        mov  x14, x0
        mov  x29, x1
PrintFancy.Loop:
       ldrb  w0, [x14], 1
        cmp  w0, '%'
        beq  PrintFancy.GotOne
        cbz  w0, PrintFancy.Done
       strb  w0, [x15], 1
          b  PrintFancy.Loop
PrintFancy.Done:
        ldp  x28, x14, [sp], 16
        ldp  x29, x30, [sp], 16
        ret
PrintFancy.GotOne:
       ldrb  w28, [x14], 1   
         bl  ParseInteger
        and  x0, x0, 31
        add  x1, x29, 8*32
        ldr  d0, [x1, x0, lsl 3]
        ldr  x0, [x29, x0, lsl 3]
        adr  x1, PrintHex
        adr  x2, PrintInt
        adr  x3, PrintUInt
        adr  x4, PrintDouble
        cmp  x28, 'i'
       csel  x1, x1, x2, ne
        cmp  x28, 'u'
       csel  x1, x1, x3, ne
        cmp  x28, 'd'
       csel  x1, x1, x4, ne
        blr  x1
          b  PrintFancy.Loop


CmpString:
// if beginning of string at x14 matches null terminated string at x0
// then advance x14 to end of match and return x0 = -1
// else return x0 = 0 and do nothing
        mov  x3, x14
CmpString.Next:
       ldrb  w1, [x0], 1
        cbz  w1, CmpString.Found
       ldrb  w2, [x3], 1
        cmp  w1, w2
        beq  CmpString.Next
CmpString.NoMatch:
        mov  x0, 0
        ret
CmpString.Found:
        mov  x14, x3
        mov  x0, -1
        ret


SkipSpaces.Next:
        add  x14, x14, 1
SkipSpaces:
// io: x14
       ldrb  w0, [x14]
        cmp  w0, ' '
        beq  SkipSpaces.Next
        ret


ParseToken.Next:
        add  x14, x14, 1
       strb  w1, [x15], 1
ParseToken:
// write at most x0 characters of string at x14 to x15
       ldrb  w1, [x14]
       subs  x0, x0, 1
        blo  ParseToken.Done
        cmp  w1, '/'
        blo  ParseToken.Done
        cmp  w1, ':'
        blo  ParseToken.Next
        cmp  w1, 'A'
        blo  ParseToken.Done
        cmp  w1, '['
        blo  ParseToken.Next
        cmp  w1, '\'
        beq  ParseToken.Next
        cmp  w1, 'a'
        blo  ParseToken.Done
        cmp  w1, 128
        blo  ParseToken.Next
ParseToken.Done:
        ret


PrintHex:
// in: x0
// io: x15 string
        mov  w4, 16                
PrintHex.Next:
        ror  x0, x0, 64-4
        and  x1, x0, 15
        cmp  w1, 10
        add  w2, w1, '0'
        add  w3, w1, 'a'-10
       csel  w1, w2, w3, lo
       strb  w1, [x15], 1                
        sub  w4, w4, 1
       cbnz  w4, PrintHex.Next
        ret


PrintDouble:
// in: d0 double
// io: x15 string
        stp  x29, x30, [sp, -16]!
        mov  x1, 1000
      scvtf  d1, x1
       fmul  d0, d0, d1
     fcvtzs  x2, d0
        tst  x2, x2
        mov  w4, '-'
       strb  w4, [x15]
       cinc  x15, x15, lt
       cneg  x2, x2, lt
       sdiv  x0, x2, x1
       msub  x29, x0, x1, x2
         bl  PrintUInt
        mov  w4, '.'
       strb  w4, [x15], 1
        mov  x2, 100
       udiv  x4, x29, x2
       msub  x3, x4, x2, x29
        mov  x0, 10
        add  w4, w4, '0'
       strb  w4, [x15], 1
       udiv  x2, x3, x0
        add  w4, w2, '0'
       strb  w4, [x15], 1
       msub  x2, x2, x0, x3
        add  w2, w2, '0'
       strb  w2, [x15], 1
        ldp  x29, x30, [sp], 16
        ret


PrintInt:
// in: x0 signed integer
// io: x15 string
        tst  x0, x0
        mov  w1, '-'
       strb  w1, [x15]
       cinc  x15, x15, lt
       cneg  x0, x0, lt

PrintUInt:
// in: x0 unsigned integer
// io: x15 string
        sub  sp, sp, 64
        mov  x3, 0
        mov  x2, 10
PrintUInt.PushLoop:
       udiv  x1, x0, x2
       msub  x0, x1, x2, x0
       strb  w0, [sp, x3]
        add  x3, x3, 1
        mov  x0, x1
       cbnz  x1, PrintUInt.PushLoop
PrintUInt.PopLoop:
       subs  x3, x3, 1
       ldrb  w0, [sp, x3]
        add  w0, w0, '0'
       strb  w0, [x15], 1
        bhi  PrintUInt.PopLoop
        add  sp, sp, 64
        ret


ParseInteger:
// io: x14 string
// out: x0
       ldrb  w1, [x14]
        mov  x2, 0
        mov  x0, 0
        cmp  w1, '-'
        beq  ParseInteger.Neg
        cmp  w1, '+'
        beq  ParseInteger.Pos
          b  ParseInteger.Loop
ParseInteger.Neg:
        mvn  x2, x2
ParseInteger.Pos:
        add  x14, x14, 1
ParseInteger.Loop:     
       ldrb  w1, [x14]
       subs  x1, x1, '0'
        blo  ParseInteger.Done
        cmp  x1, 9
        bhi  ParseInteger.Done
        add  x14, x14, 1
        add  x0, x0, x0, lsl 2
        add  x0, x1, x0, lsl 1
          b  ParseInteger.Loop
ParseInteger.Done:      
        eor  x0, x0, x2
        sub  x0, x0, x2
        ret


GetLine:
// out: x0 = 0 if success, = -1 if failed
//      x1 length of string
//      x14 address of string
        stp  x29, x30, [sp,-16]!
        stp  x27, x28, [sp,-16]!
        stp  x25, x26, [sp,-16]!
        stp  x23, x24, [sp,-16]!
        stp  x21, x22, [sp,-16]!
        stp  x19, x20, [sp,-16]!
        lea  x29, ioBuffer
        ldr  w22, [x29, IOBuffer.tmp_i]
        ldr  w23, [x29, IOBuffer.tmp_j]
        ldr  x24, [x29, IOBuffer.inputBufferSizeB]
        ldr  x25, [x29, IOBuffer.inputBuffer]
        mov  x28, 0
GetLine.NextChar:
        cmp  x28, x24
        bhs  GetLine.Realloc
GetLine.ReallocRet:
        cmp  x22, x23
        bhs  GetLine.GetMore
GetLine.GetMoreRet:
        add  x0, x29, IOBuffer.tmpBuffer
       ldrb  w0, [x0, x22]
        add  x22, x22, 1
       strb  w0, [x25, x28]
        add  x28, x28, 1
        cmp  w0, ' '
        bhs  GetLine.NextChar
        mov  x0, 0
GetLine.Done:
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
GetLine.GetMore:
        mov  x22, 0
        add  x0, x29, IOBuffer.tmpBuffer
        mov  x1, sizeof.IOBuffer.tmpBuffer
         bl  Os_ReadStdIn
        mov  x23, x0
        cmp  x0, 1
        bge  GetLine.GetMoreRet
GetLine.Failed:
        mov  x0, -1
        mov  x23, 0
          b  GetLine.Done
GetLine.Realloc:
        add  x0, x24, 4096
         bl  Os_VirtualAlloc
        mov  x23, x0
        mov  x1, x25
        mov  x2, x24
         bl  MemoryCopy
        mov  x0, x25
        mov  x1, x24
         bl  Os_VirtualFree
        mov  x25, x23
        add  x24, x24, 4096
          b  GetLine.ReallocRet


MemoryCopy.Next:
        sub  x2, x2, 1
       ldrb  w3, [x1], 1
       strb  w3, [x0], 1
MemoryCopy:
// copy x2 bytes from x1 to x0
       cbnz  x2, MemoryCopy.Next
        ret


MemoryFill.Next:
        sub  x2, x2, 1
       strb  w1, [x0], 1
MemoryFill:
// fill x2 bytes from the lower byte in x1 to x0
       cbnz  x2, MemoryFill.Next
        ret

