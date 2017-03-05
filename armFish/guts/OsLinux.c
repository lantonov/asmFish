Os_ExitProcess:
// in: x0 exit code
        mov  x8, 94
        svc  0

Os_SetStdHandles:
        ret

Os_InitializeTimer:
        ret

Os_GetTime:
// out: x0, x1 such that x0+x1/2^64 = time in ms
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, 1
        add  x1, sp, 16
        mov  x8, 113
        svc  0
        ldr  x2, [sp, 16]
        ldr  x3, [sp, 24]
        ldr  x4, =18446744073709
        mov  x5, 1000
        mul  x1, x3, x4
      umulh  x0, x3, x4
       madd  x0, x2, x5, x0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_Sleep:
// in: x0 ms to sleep
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x1, 1000
       udiv  x2, x0, x1
       msub  x3, x2, x1, x0
        mul  x1, x1, x1
        mul  x3, x3, x1
        str  x2, [sp,16]
        str  x3, [sp,24]
        add  x0, sp, 16
        mov  x1, 0            
        mov  x8, 101
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_VirtualAlloc:
// in: x0 size
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x5, 0
        mov  x4, -1
        mov  x3, 0x22
        mov  x2, 0x03
        mov  x1, 100
        mov  x0, 0
        mov  x8, 222
        svc  0
        tst  x0, x0
        bmi  Failed_sys_mmap_VirtualAlloc
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_VirtualFree:
// in: x0 address
//     x1 size
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        cbz  x0, 1f
        mov  x8, 215
        svc  0
        cmp  w0, 0
        bne  Failed_sys_unmap_VirtualFree
1:      add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_WriteOut_Output:
       adrp  x0, Output
        add  x0, x0, :lo12:Output
_WriteOut:
// in: x0 address of string start
// in: x15 address of string end
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        sub  x2, x15, x0
        mov  x1, x0
        mov  x0, 1
        mov  x8, 64
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_ReadStdIn:
// in: x0 address of buffer
//     x1 max bytes to read
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x2, x1
        mov  x1, x0
        mov  x0, 0
        mov  x8, 63
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_ParseCommandLine:
// initializes ioBuffer struct  
        stp  x29, x30, [sp, -64]!
        stp  x22, x23, [sp, 16]
        stp  x24, x25, [sp, 32]
        stp  x27, x28, [sp, 48]
       adrp  x29, ioBuffer
        add  x29, x29, :lo12:ioBuffer
        mov  x0, 4096
        str  x0, [x29,IOBuffer.inputBufferSizeB]
         bl  Os_VirtualAlloc
        str  x0, [x29,IOBuffer.inputBuffer]
        ldp  x24, x25, [sp, 32]
        ldp  x22, x23, [sp, 16]
        ldp  x27, x28, [sp, 48]
        ldp  x28, x30, [sp], 64
        ret

Failed_sys_mmap_VirtualAlloc:
        lea  x15, sz_error_sys_mmap_VirtualAlloc
          b  Failed
Failed_sys_unmap_VirtualFree:
        lea  x15, sz_error_sys_unmap_VirtualFree
          b  Failed

Failed:
// x15 address of null terminated string
        mov  x21, x0
        mov  x0, x15
       adrp  x15, Output
        add  x15, x15, :lo12:Output
         bl  PrintString
       adrp  x0, sz_failed_x0
        add  x0, x0, :lo12:sz_failed_x0
         bl  PrintString
        mov  x0, x21
         bl  PrintHex
        mov  w0, 10
       strb  w0, [x15], 1
       adrp  x15, Output
        add  x15, x15, :lo12:Output
         bl  Os_ErrorBox
        mov  x0, 1
         bl  Os_ExitProcess

Os_ErrorBox:
// x15 address of null terminated string
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, x15
         bl  StringLength
        mov  x2, x0
        mov  x1, x15
        mov  x0, 1
        mov  x8, 64
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret     


Os_CheckCPU:
        mov  x0, 0
// make sure that rook attacks are page aligned
        lea  x15, sz_error_rook_page
        add  x0, x0, :lo12:RookAttacksSTUFF
       cbnz  x0, Failed
// make sure that bishop attacks are page aligned        
        lea  x15, sz_error_bishop_page
        add  x0, x0, :lo12:BishopAttacksSTUFF
       cbnz  x0, Failed
        ret





