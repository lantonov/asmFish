
Search_Init:

	       push   r14 r13 r12 rbp rdi rsp rbx				     ; 09D0 _ 41: 56
		lea   r12, [Reductions] 		      ; 0A15 _ 4C: 8D. 25, 0041D6C0(rel)
		xor   ebp, ebp				      ; 0A1C _ 31. ED
		xor   ebx, ebx				      ; 0A1E _ 31. DB
	     vmovsd   xmm6, qword[._2729]		      ; 0A20 _ F2: 0F 10. 35, 00001AB0(rel)
	     vmovsd   xmm8, qword[._2730]		      ; 0A28 _ F2 44: 0F 10. 05, 00001AB8(rel)
._0048: 	mov   rax, rbp				      ; 0A31 _ 48: 89. E8
		mov   esi, ebp				      ; 0A34 _ 89. EE
		mov   edi, 1				      ; 0A36 _ BF, 00000001
		shl   rax, 14				      ; 0A3B _ 48: C1. E0, 0E
		xor   esi, 01H				      ; 0A3F _ 83. F6, 01
		lea   r14, [r12+rax+100H]		      ; 0A42 _ 4D: 8D. B4 04, 00000100
		and   esi, 01H				      ; 0A4A _ 83. E6, 01
._0049:       vpxor   xmm0, xmm0, xmm0				    ; 0A4D _ 66: 0F EF. C0
	  vcvtsi2sd   xmm0, xmm0, edi				   ; 0A51 _ F2: 0F 2A. C7
		xor   r13d, r13d			      ; 0A55 _ 45: 31. ED
	       call   Math_Log_d_d				 ; 0A58 _ E8, 00000183
	    vmovapd   xmm7, xmm0			      ; 0A5D _ 66: 0F 28. F8
._0050: 	lea   edx, [r13+1H]			      ; 0A61 _ 41: 8D. 55, 01
	      vpxor   xmm0, xmm0, xmm0				    ; 0A65 _ 66: 0F EF. C0
	  vcvtsi2sd   xmm0, xmm0, edx				   ; 0A69 _ F2: 0F 2A. C2
	       call   Math_Log_d_d			      ; 0A6D _ E8, 0000016E
	     vmulsd   xmm1, xmm0, xmm7				    ; 0A76 _ F2: 0F 59. CF
	     vmulsd   xmm1, xmm1, xmm6				    ; 0A7A _ F2: 0F 59. CE
		xor   r8d, r8d
		lea   rcx, [r13*4]			      ; 0A89 _ 4A: 8D. 0C AD, 00000000
	    vcomisd   xmm8, xmm1			      ; 0A7E _ 66 44: 0F 2E. C1
		 ja   ._0051				      ; 0A83 _ 77, 3D
	     vaddsd   xmm1, xmm1, xmm6				    ; 0A85 _ F2: 0F 58. CE
	 vcvttsd2si   r8d, xmm1 			    ; 0A91 _ F2 44: 0F 2C. C1
		lea   r9d, [r8-1H]			      ; 0A96 _ 45: 8D. 48, FF
	       test   r9d, r9d				      ; 0A9F _ 45: 85. C9
	      cmovs   r9d, ebx				      ; 0AA2 _ 44: 0F 48. CB
;cmp  dword [r14+rcx+8004H], r9d
;je @f
;int3
;@@:
		mov   dword[r14+rcx+8004H], r9d 	     ; 0AAA _ 45: 89. 8C 0E, 00008004
		cmp   r8d, 1				      ; 0AA6 _ 41: 83. F8, 01
		jle   ._0051				      ; 0AB2 _ 7E, 0E
	       test   sil, sil				      ; 0AB4 _ 40: 84. F6
		 jz   ._0051				      ; 0AB7 _ 74, 09
		add   r8d, 1				      ; 0AB9 _ 41: 83. C0, 01
._0051:
;cmp  dword [r14+rcx+4H], r8d
;je @f
;int3
;@@:
		mov   dword[r14+rcx+4H], r8d		     ; 0ABD _ 45: 89. 44 0E, 04
		add   r13, 1				      ; 0AC2 _ 49: 83. C5, 01
		cmp   r13, 63				      ; 0AC6 _ 49: 83. FD, 3F
		jnz   ._0050				      ; 0ACA _ 75, 95
		add   edi, 1				      ; 0ACC _ 83. C7, 01
		add   r14, 256				      ; 0ACF _ 49: 81. C6, 00000100
		cmp   edi, 64				      ; 0AD6 _ 83. FF, 40
		jne   ._0049				      ; 0AD9 _ 0F 85, FFFFFF6E
		sub   rbp, 1				      ; 0ADF _ 48: 83. ED, 01
		 jz   ._0052				      ; 0AE3 _ 74, 0A
		mov   ebp, 1				      ; 0AE5 _ BD, 00000001
		jmp   ._0048				      ; 0AEA _ E9, FFFFFF42
; _ZN6Search4initEv End of function

._0052: ; Local function
	     vmovsd   xmm6, qword[._2731]		 ; 0AEF _ F2: 0F 10. 35, 00001AC0(rel)
		xor   ebp, ebp				      ; 0AF7 _ 31. ED
	      vpxor   xmm13, xmm13, xmm13			     ; 0AF9 _ 66 45: 0F EF. ED
	     vmovsd   xmm12, qword[._2732]		 ; 0AFE _ F2 44: 0F 10. 25, 00001AC8(rel)
		lea   r14, [FutilityMoveCounts]; 0B07 _ 4C: 8D. 35, 0042D6C0(rel)
	     vmovsd   xmm11, qword[._2733]		 ; 0B0E _ F2 44: 0F 10. 1D, 00001AD0(rel)
		lea   rdi, [r14+16*4]			    ; 0B17 _ 48: 8D. 3D, 0042D700(rel)
	     vmovsd   xmm10, qword[._2734]		 ; 0B1E _ F2 44: 0F 10. 15, 00001AD8(rel)
	     vmovsd   xmm8, qword[._2735]		 ; 0B27 _ F2 44: 0F 10. 05, 00001AE0(rel)
	     vmovsd   xmm7, qword[._2736]		 ; 0B30 _ F2: 0F 10. 3D, 00001AE8(rel)
._0053:       vpxor   xmm9, xmm9, xmm9				    ; 0B38 _ 66 45: 0F EF. C9
	  vcvtsi2sd   xmm9, xmm9, ebp				   ; 0B3D _ F2 44: 0F 2A. CD
	    vmovapd   xmm1, xmm6			      ; 0B42 _ 66: 0F 28. CE
	     vaddsd   xmm0, xmm9, xmm13 			    ; 0B4B _ F2 41: 0F 58. C5
	       call   Math_Power_d_dd				  ; 0B50 _ E8, 000008A0(rel)
	    vmovapd   xmm1, xmm6			      ; 0B55 _ 66: 0F 28. CE
	   vfmaddsd   xmm0, xmm0, xmm12, xmm11				   ; 0B5E _ F2 41: 0F 58. C3
	 vcvttsd2si   r10d, xmm0			    ; 0B63 _ F2 44: 0F 2C. D0
	     vaddsd   xmm0, xmm9, xmm10 			    ; 0B6D _ F2 41: 0F 58. C2

;cmp  dword [r14+rbp*4], r10d
;je @f
;int3
;@@:
		mov   dword[r14+rbp*4], r10d		     ; 0B72 _ 45: 89. 14 AE
	       call   Math_Power_d_dd				  ; 0B76 _ E8, 000008A0(rel)
	   vfmaddsd   xmm0, xmm0, xmm8, xmm7				  ; 0B80 _ F2: 0F 58. C7
	 vcvttsd2si   r11d, xmm0			    ; 0B84 _ F2 44: 0F 2C. D8

;cmp  dword [rdi+rbp*4], r11d
;je @f
;int3
;@@:

		mov   dword[rdi+rbp*4], r11d		     ; 0B89 _ 44: 89. 1C AF
		add   rbp, 1				      ; 0B8D _ 48: 83. C5, 01
		cmp   rbp, 16				      ; 0B91 _ 48: 83. FD, 10
		jnz   ._0053				      ; 0B95 _ 75, A1

		pop   rbx rsi rdi rbp r12 r13 r14
		ret


align 8
._2729: dq 3FE0000000000000H				; 1AB0 _ 0.5
._2736: dq 4007333333333333H				; 1AE8 _ 2.9
._2730: dq 3FE999999999999AH				; 1AB8 _ 0.8
._2731: dq 3FFCCCCCCCCCCCCDH				; 1AC0 _ 1.8
._2732: dq 3FE8BC6A7EF9DB23H				; 1AC8 _ 0.773
._2733: dq 4003333333333333H				; 1AD0 _ 2.4
._2734: dq 3FDF5C28F5C28F5CH				; 1AD8 _ 0.49
._2735: dq 3FF0B851EB851EB8H				; 1AE0 _ 1.045
