
Pawn_Init:
               push   rbp rbx rsi rdi r12
                xor   r8d, r8d
                mov   r12d, 2
                mov   ebp, 4
.opposedLoop:
               imul   r11, r8, 192
                mov   ecx, r8d
                xor   r10d, r10d
.phalanxLoop:
                mov   rbx, r11
                xor   r9d, r9d
.supportLoop:
                mov   edi, 1
.rankLoop:
                xor   eax, eax
               test   r10d, r10d
                mov   esi, dword[.Seed+4*rdi]
                 je   .phalanxIsZero
                mov   eax, dword[.Seed+4*(rdi+1)]
                sub   eax, esi
                cdq
               idiv   r12d
    .phalanxIsZero:
                add   esi, eax
                lea   eax, [rdi-2]
                sar   esi, cl
                add   esi, r9d
               imul   eax, esi
                sal   esi, 16
                cdq
               idiv   ebp
                add   eax, esi
                mov   dword[Connected+rbx+rdi*4], eax
                inc   rdi
                cmp   rdi, 7
                jne   .rankLoop
                add   r9d, 17
                add   rbx, 32
                cmp   r9d, 51
                jne   .supportLoop
                add   r11, 96
                add   r10d, 1
                cmp   r10d, 2
                 jb   .phalanxLoop
                add   r8d, 1
                cmp   r8d, 2
                 jb   .opposedLoop
                pop   r12 rdi rsi rbx rbp
                ret

             calign   8
.Seed:
        dd 0, 13, 24, 18, 76, 100, 175, 330
