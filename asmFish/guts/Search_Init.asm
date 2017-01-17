
Search_Init:
	       push   r14 r13 r12 rbp rdi rsp rbx
		lea   r12, [Reductions]
		xor   ebp, ebp
		xor   ebx, ebx
	     vmovsd   xmm6, qword[._2729]
._0048:
		mov   rax, rbp
		mov   esi, ebp
		mov   edi, 1
		shl   rax, 14
		xor   esi, 01H
		lea   r14, [r12+rax+100H]
		and   esi, 01H
._0049:
	      vpxor   xmm0, xmm0, xmm0
	  vcvtsi2sd   xmm0, xmm0, edi
		xor   r13d, r13d
	       call   Math_Log_d_d
	    vmovapd   xmm7, xmm0
._0050:
		lea   edx, [r13+1H]
	      vpxor   xmm0, xmm0, xmm0
	  vcvtsi2sd   xmm0, xmm0, edx
	       call   Math_Log_d_d
	     vmulsd   xmm1, xmm0, xmm7
	     vmulsd   xmm1, xmm1, xmm6
		xor   r8d, r8d
		lea   rcx, [r13*4]
	     vaddsd   xmm1, xmm1, xmm6
	 vcvttsd2si   r8d, xmm1
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
	     vmovsd   xmm6, qword[._2731]
		xor   ebp, ebp
	      vpxor   xmm13, xmm13, xmm13
	     vmovsd   xmm12, qword[._2732]
		lea   r14, [FutilityMoveCounts]
	     vmovsd   xmm11, qword[._2733]
		lea   rdi, [r14+16*4]
	     vmovsd   xmm10, qword[._2734]
	     vmovsd   xmm8, qword[._2735]
	     vmovsd   xmm7, qword[._2736]
._0053:
	      vpxor   xmm9, xmm9, xmm9
	  vcvtsi2sd   xmm9, xmm9, ebp
	    vmovapd   xmm1, xmm6
	     vaddsd   xmm0, xmm9, xmm13
	       call   Math_Power_d_dd
	    vmovapd   xmm1, xmm6
	   vfmaddsd   xmm0, xmm0, xmm12, xmm11
	 vcvttsd2si   r10d, xmm0
	     vaddsd   xmm0, xmm9, xmm10
		mov   dword[r14+rbp*4], r10d
	       call   Math_Power_d_dd
	   vfmaddsd   xmm0, xmm0, xmm8, xmm7
	 vcvttsd2si   r11d, xmm0
		mov   dword[rdi+rbp*4], r11d
		add   rbp, 1
		cmp   rbp, 16
		jnz   ._0053

		pop   rbx rsi rdi rbp r12 r13 r14
		ret


align 8
._2729: dq 3FE0000000000000H				      ; 1AB0 _ 0.5
._2736: dq 4007333333333333H				      ; 1AE8 _ 2.9
._2731: dq 3FFCCCCCCCCCCCCDH				      ; 1AC0 _ 1.8
._2732: dq 3FE8BC6A7EF9DB23H				      ; 1AC8 _ 0.773
._2733: dq 4003333333333333H				      ; 1AD0 _ 2.4
._2734: dq 3FDF5C28F5C28F5CH				      ; 1AD8 _ 0.49
._2735: dq 3FF0B851EB851EB8H				      ; 1AE0 _ 1.045
