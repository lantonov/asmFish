
remaining:
    ; in: ebx us
    ;     r8d ply (preserved)
    ;     r9d type
    ; out: time
            mov  edi, dword[limits.time+4*rbx]
            mov  esi, dword[limits.incr+4*rbx]
            mov  edx, dword[options.moveOverhead]
            mov  ecx, dword[limits.movestogo]

            xor  eax, eax
           test  edi, edi
            mov  r10d, edx
            jle  .Return
            lea  eax, [r8+1]
            mov  r11d, 2
        _vmovsd  xmm0, qword[.LC6]
        _vmovsd  xmm3, qword[.LC7]
            shr  eax, 1
     _vcvtsi2sd  xmm2, xmm2, esi
           test  ecx, ecx
        _vmovsd  xmm4, qword[.LC1]
            lea  edx, qword[rax-25]
     _vcvtsi2sd  xmm1, xmm1, edx
        _vmulsd  xmm0, xmm0, xmm1
        _vmulsd  xmm1, xmm1, xmm0
        _vsubsd  xmm3, xmm3, xmm1
        _vmaxsd  xmm0, xmm3, qword[.LC0]
        _vmulsd  xmm3, xmm2, xmm0
             je  .NoMovesToGo
.YesMovesToGo:
        _vmovsd  xmm2, qword[.LC1+8*r9]
            cmp  ecx, 49
            jle  @1f
            mov  ecx, 50
    @1:
     _vcvtsi2sd  xmm0, xmm0, ecx
            cmp  eax, 40
        _vmovsd  xmm1, qword[.LC5]
        _vdivsd  xmm2, xmm2, xmm0
             jg  .L8
            sub  eax, 20
     _vcvtsi2sd  xmm0, xmm0, eax
        _vmulsd  xmm5, xmm0, qword[.LC8]
        _vmulsd  xmm5, xmm5, xmm0
        _vmovsd  xmm0, qword[.LC9]
        _vsubsd  xmm0, xmm0, xmm5
        _vmulsd  xmm2, xmm2, xmm0
            jmp  .L21
.L8:
        _vmulsd  xmm2, xmm2, qword[.LC10]
.L21:
       _vmovapd  xmm0, xmm1
            jmp  .L9
.NoMovesToGo:
     _vcvtsi2sd  xmm0, xmm0, eax
           imul  edx, eax, 20
        _vmovsd  xmm2, qword[.LC3]
     _vcvtsi2sd  xmm1, xmm1, edx
        _vaddsd  xmm0, xmm0, qword[.LC11]
        _vdivsd  xmm1, xmm1, xmm0
        _vaddsd  xmm0, xmm1, xmm4
        _vmulsd  xmm2, xmm0, qword[.LC3+8*r9]
.L9:
     _vcvtsi2sd  xmm1, xmm1, edi
            mov  eax, 0
            sub  edi, r10d
          cmovs  edi, eax
        _vmulsd  xmm0, xmm0, xmm1
        _vdivsd  xmm3, xmm3, xmm0
       _vmovapd  xmm0, xmm3
        _vaddsd  xmm0, xmm0, xmm4
        _vmulsd  xmm2, xmm2, xmm0
     _vcvtsi2sd  xmm0, xmm0, edi
        _vminsd  xmm2, xmm2, xmm4
        _vmulsd  xmm0, xmm0, xmm2
    _vcvttsd2si  eax, xmm0
.Return:
            ret

         calign  8
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
           push  rbx rsi rdi
            mov  ebx, ecx
            mov  r8d, edx
            mov  rax, qword[limits.startTime]
            mov  qword[time.startTime], rax
            xor  r9d, r9d
           call  remaining
            mov  rcx, rax
            shr  rcx, 2
            add  rcx, rax
            cmp  byte[options.ponder], 0
         cmovne  rax, rcx
            mov  qword[time.optimumTime], rax
            mov  r9d, 1
           call  remaining
            mov  qword[time.maximumTime], rax
            pop  rdi rsi rbx
            ret
