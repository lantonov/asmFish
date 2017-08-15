
Search_Init:
	       push   r14 r13 r12 rbp rdi rsp rbx
		lea   r12, [Reductions]
		xor   ebp, ebp
		xor   ebx, ebx
._0048:
		mov   rax, rbp
		mov   esi, ebp
		mov   edi, 1
		shl   rax, 14
		xor   esi, 01H
		lea   r14, [r12+rax+100H]
		and   esi, 01H
._0049:
	     _vpxor   xmm0, xmm0, xmm0
	 _vcvtsi2sd   xmm0, xmm0, edi
		xor   r13d, r13d
	       call   Math_Log_d_d
	   _vmovapd   xmm7, xmm0
._0050:
		lea   edx, [r13+1H]
	     _vpxor   xmm0, xmm0, xmm0
	 _vcvtsi2sd   xmm0, xmm0, edx
	       call   Math_Log_d_d
	    _vmulsd   xmm1, xmm0, xmm7
	    _vdivsd   xmm1, xmm1, qword[.constd_1p95]
		xor   r8d, r8d
		lea   rcx, [r13*4]
	    _vaddsd   xmm1, xmm1, qword[.constd_0p5]
	_vcvttsd2si   r8d, xmm1
		lea   r9d, [r8-1H]
	       test   r9d, r9d
	      cmovs   r9d, ebx
		mov   dword[r14+rcx+8004H], r9d
		cmp   r8d, 1
		jle   ._0051
	       test   sil, sil
		 jz   ._0051
		add   r8d, 1
._0051:
		mov   dword[r14+rcx+4H], r8d
		add   r13, 1
		cmp   r13, 63
		jnz   ._0050
		add   edi, 1
		add   r14, 256
		cmp   edi, 64
		jne   ._0049
		sub   rbp, 1
		 jz   ._0052
		mov   ebp, 1
		jmp   ._0048
._0052:


		xor   ebp, ebp
	    _vmovsd   xmm6, qword[.constd_2p4]
	    _vmovsd   xmm7, qword[.constd_0p74]
	    _vmovsd   xmm8, qword[.constd_5p0]
	    _vmovsd   xmm9, qword[.constd_1p0]
.FutilityLoop:
	 _vcvtsi2sd   xmm0, xmm0, ebp
	    _vmovsd   xmm1, qword[.constd_1p78]
	       call   Math_Power_d_dd
	   _vmovapd   xmm1, xmm6
	  _vfmaddsd   xmm0, xmm0, xmm7, xmm6
	_vcvttsd2si   eax, xmm0
		mov   dword[FutilityMoveCounts+rbp*4], eax

	 _vcvtsi2sd   xmm0, xmm0, ebp
	    _vmovsd   xmm1, qword[.constd_2p0]
	       call   Math_Power_d_dd
	  _vfmaddsd   xmm0, xmm0, xmm9, xmm8
	_vcvttsd2si   eax, xmm0
		mov   dword[FutilityMoveCounts+(rbp+16)*4], eax

		add   ebp, 1
		cmp   ebp, 16
		 jb   .FutilityLoop


                lea   rsi, [.RazorMargin]
                lea   rdi, [RazorMargin]
                mov   ecx, 4
          rep movsd

                lea   rsi, [._CaptureOrPromotion_or]
                lea   rdi, [_CaptureOrPromotion_or]
                mov   ecx, 8    ; copy both or and and
          rep movsb

		pop   rbx rsi rdi rbp r12 r13 r14
		ret


             calign 8
.constd_0p5     dq 0.5
.constd_1p95    dq 1.95

.constd_2p4     dq 2.4
.constd_0p74    dq 0.74
.constd_5p0     dq 5.0
.constd_1p0     dq 1.0
.constd_1p78    dq 1.78
.constd_2p0     dq 2.0

.RazorMargin             dd 0, 570, 603, 554
._CaptureOrPromotion_or  db  0,-1,-1, 0
._CaptureOrPromotion_and db -1,-1,-1, 0

