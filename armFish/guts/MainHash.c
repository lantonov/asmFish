
MainHash_Create:
        stp  x21, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        lea  x21, mainHash
        lea  x14, options
        ldr  w14, [x14, Options.hash]
        str  w14, [x21, MainHash.sizeMB]
        lsl  x1, x14, 20
         bl  Os_VirtualAlloc
        mov  x2, 0
        lsl  x14, x14, 20-5
        sub  x14, x14, 1
        str  x0, [x21, MainHash.table]
        str  x14, [x21, MainHash.mask]
        str  x2, [x21, MainHash.lpSize]
       strb  w2, [x21, MainHash.date]
        ldp  x14, x15, [sp], 16
        ldp  x21, x30, [sp], 16
        ret


MainHash_ReadOptions:
        stp  x29, x30, [sp, -16]!
        stp  x20, x21, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        lea  x29, mainHash
        lea  x20, options
        ldr  w1, [x20, Options.hash]
        mov  x2, MAX_HASH_LOG2MB
        clz  x0, x1
        cmp  x0, x2
       csel  x0, x2, x0, hi
        mov  x14, 1
        lsl  x14, x14, x0
        ldr  x15, [x29, MainHash.lpSize]
       ldrb  w21, [x20, Options.largePages]
        ldr  w4, [x29, MainHash.sizeMB]
        cmp  w14, w4
        bne  MainHash_ReadOptions.NoMatch
        orr  x4, x15, x21
        cbz  x4, MainHash_ReadOptions.Skip
        cmp  x15, 0
       ccmp  x21, 0, 0b0100, ne
        bne  MainHash_ReadOptions.Skip
MainHash_ReadOptions.NoMatch:
         bl  MainHash_Free
        str  w14, [x29, MainHash.sizeMB]
        lsl  x14, x14, 20
        cbz  x21, MainHash_ReadOptions.NoLP
        mov  x1, x14
         bl  Os_VirtualAlloc_LargePages
       cbnz  x0, MainHash_ReadOptions.Done
MainHash_ReadOptions.NoLP:
        mov  x1, x14
         bl  Os_VirtualAlloc
        mov  x2, 0
MainHash_ReadOptions.Done:
        lsr  x14, x14, 5
        sub  x14, x14, 1
        str  x0, [x29, MainHash.table]
        str  x14, [x29, MainHash.mask]
        str  x2, [x29, MainHash.lpSize]
       strb  wzr, [x29, MainHash.date]
         bl  MainHash_DisplayInfo
MainHash_ReadOptions.Skip:
        ldp  x14, x15, [sp], 16
        ldp  x20, x21, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


MainHash_DisplayInfo:
        stp  x15, x30, [sp, -16]!
        sub  sp, sp, 64
        lea  x15, Output
        lea  x4, mainHash
        ldr  x0, [x4, MainHash.sizeMB]
        ldr  x1, [x4, MainHash.lpSize]
        lea  x2, LargePageMinSize
        ldr  x2, [x2]
        stp  x0, x2, [sp]
        adr  x3, MainHash_DisplayInfo.nolp
        adr  x4, MainHash_DisplayInfo.yeslp
        tst  x1, x1
       csel  x1, x3, x4, eq
        add  x2, sp, 0
         bl  PrintFancy
         bl  Os_WriteOut_Output
        add  sp, sp, 64
        ldp  x15, x30, [sp], 16
        ret
MainHash_DisplayInfo.nolp:
        .ascii "info string hash set to %u0 MB no large pages\n\0"
MainHash_DisplayInfo.yeslp:
        .ascii "info string hash set to %u0 MB page size %u1 KB\n\0"
        .balign 4


MainHash_Clear:
        lea  x0, mainHash
        ldr  x2, [x0, MainHash.sizeMB]
        ldr  x0, [x0, MainHash.table]
        lsl  x2, x2, 20
        mov  x1, 0
          b  MemoryFill


MainHash_Destroy:
MainHash_Free:
        stp  x29, x30, [sp, -16]!
        lea  x29, mainHash
        ldr  x1, [x29, MainHash.table]
        ldr  x0, [x29, MainHash.lpSize]
        ldr  w2, [x29, MainHash.sizeMB]
        lsl  x2, x2, 20
        tst  x0, x0
       csel  x2, x0, x2, ne
         bl  Os_VirtualFree
        mov  x0, 0
        str  x0, [x29, MainHash.table]
        str  x0, [x29, MainHash.lpSize]
        str  x0, [x29, MainHash.sizeMB]
        ldp  x29, x30, [sp], 16
        ret
