
remaining:
    ; in: ebx us
    ;     r8d ply (preserved)
    ;     r9d type
    ; out: time
                mov   edi, dword[limits.time+4*rbx]
                mov   esi, dword[limits.incr+4*rbx]
                mov   edx, dword[options.moveOverhead]
                mov   ecx, dword[limits.movestogo]

                xor   eax, eax
               test   edi, edi
                mov   r10d, edx
                jle   .Return
                lea   eax, [r8+1]
                mov   r11d, 2
             vmovsd   xmm0, [.LC6]
             vmovsd   xmm3, [.LC7]
                shr   eax, 1
          vcvtsi2sd   xmm2, xmm2, esi
               test   ecx, ecx
             vmovsd   xmm4, [.LC1]
                lea   edx, [rax-25]
          vcvtsi2sd   xmm1, xmm1, edx
             vmulsd   xmm0, xmm0, xmm1
             vmulsd   xmm1, xmm1, xmm0
             vsubsd   xmm3, xmm3, xmm1
             vmaxsd   xmm0, xmm3, [.LC0]
             vmulsd   xmm3, xmm2, xmm0
                 je   .NoMovesToGo
.YesMovesToGo:
             vmovsd   xmm2, [.LC1+8*r9]
                cmp   ecx, 49
                jle   @f
                mov   ecx, 50
        @@:
          vcvtsi2sd   xmm0, xmm0, ecx
                cmp   eax, 40
             vmovsd   xmm1, [.LC5]
             vdivsd   xmm2, xmm2, xmm0
                 jg   .L8
                sub   eax, 20
          vcvtsi2sd   xmm0, xmm0, eax
             vmulsd   xmm5, xmm0, [.LC8]
             vmulsd   xmm5, xmm5, xmm0
             vmovsd   xmm0, [.LC9]
             vsubsd   xmm0, xmm0, xmm5
             vmulsd   xmm2, xmm2, xmm0
                jmp   .L21
.L8:
             vmulsd   xmm2, xmm2, [.LC10]
.L21:
            vmovapd   xmm0, xmm1
                jmp   .L9
.NoMovesToGo:
          vcvtsi2sd   xmm0, xmm0, eax
               imul   edx, eax, 20
             vmovsd   xmm2, [.LC3]
          vcvtsi2sd   xmm1, xmm1, edx
             vaddsd   xmm0, xmm0, [.LC11]
             vdivsd   xmm1, xmm1, xmm0
             vaddsd   xmm0, xmm1, xmm4
             vmulsd   xmm2, xmm0, [.LC3+8*r9]
.L9:
          vcvtsi2sd   xmm1, xmm1, edi
                mov   eax, 0
                sub   edi, r10d
              cmovs   edi, eax
             vmulsd   xmm0, xmm0, xmm1
             vdivsd   xmm3, xmm3, xmm0
            vmovapd   xmm0, xmm3
             vaddsd   xmm0, xmm0, xmm4
             vmulsd   xmm2, xmm2, xmm0
          vcvtsi2sd   xmm0, xmm0, edi
             vminsd   xmm2, xmm2, xmm4
             vmulsd   xmm0, xmm0, xmm2
         vcvttsd2si   eax, xmm0
.Return:
                ret

              align   8
.LC0:   dq 55.0
.LC1:   dq 1.0, 6.0
.LC3:   dq 0.017, 0.07
.LC5:   dq 8.5
.LC6:   dq 0.12
.LC7:   dq 120.0
.LC8:   dq 0.001
.LC9:   dq 1.1
.LC10:  dq 1.5
.LC11:  dq 500.0


TimeMng_Init:
	; in: ecx color us
	;     edx ply

               push   rbx rsi rdi
                mov   ebx, ecx
                mov   r8d, edx

       		mov   rax, qword[limits.startTime]
       		mov   qword[time.startTime], rax

                xor   r9d, r9d
               call   remaining
                mov   qword[time.optimumTime], rax
                mov   r9d, 1
               call   remaining
                mov   qword[time.maximumTime], rax

GD String, 'optimumTime: '
GD Int64, qword[time.optimumTime]
GD NewLine
GD String, 'maximumTime: '
GD Int64, qword[time.maximumTime]
GD NewLine

                pop  rdi rsi rbx
                ret
