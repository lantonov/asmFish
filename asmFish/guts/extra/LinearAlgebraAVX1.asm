align 32
NNData:
.mod8mask dd -1,-1,-1,-1,-1,-1,-1,-1
	  dd -1, 0, 0, 0, 0, 0, 0, 0
	  dd -1,-1, 0, 0, 0, 0, 0, 0
	  dd -1,-1,-1, 0, 0, 0, 0, 0
	  dd -1,-1,-1,-1, 0, 0, 0, 0
	  dd -1,-1,-1,-1,-1, 0, 0, 0
	  dd -1,-1,-1,-1,-1,-1, 0, 0
	  dd -1,-1,-1,-1,-1,-1,-1, 0
.absmask dd 8 dup 0x7FFFFFFF
.one dd 8 dup 1.0

.a dq 0.5
.b dq 0.1
.testImageFile	db 'guts/testIM.ubyte',0
.testLabelFile	db 'guts/testLB.ubyte',0
.trainImageFile db 'guts/trainIM.ubyte',0
.trainLabelFile db 'guts/trainLB.ubyte',0


;;;;;;;;;;;;;;;;;;;;;;;
;
; sigma function is
;                  1 + x + |x|
;      sigma(x) = -------------
;                  2*(1 + |x|)
;
; the derivative is also cheap
;                        1
;     sigma'(x) = -------------
;                  2*(1 + |x|)^2


Vector_Sigma:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vandps   ymm1, ymm0, qqword[NNData.absmask]
	     vaddps   ymm1, ymm1, qqword[NNData.one]
	     vaddps   ymm0, ymm0, ymm1
	     vaddps   ymm1, ymm1, ymm1
	     vrcpps   ymm1, ymm1
	     vmulps   ymm0, ymm0, ymm1
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   qword[nnetFlops], 8*6
		add   edx, 8
		cmp   edx, ecx
		 jb   .Loop
		and   ecx, 7
		shl   ecx, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+rcx]
	    vmovaps   qqword[rax+4*(rdx-8)], ymm0
		ret



Vector_SigmaPrime:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vandps   ymm0, ymm0, qqword[NNData.absmask]
	     vaddps   ymm0, ymm0, qqword[NNData.one]
	     vmulps   ymm0, ymm0, ymm0
	     vaddps   ymm0, ymm0, ymm0
	     vrcpps   ymm0, ymm0
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   qword[nnetFlops], 8*5
		add   edx, 8
		cmp   edx, ecx
		 jb   .Loop
		and   ecx, 7
		shl   ecx, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+rcx]
	    vmovaps   qqword[rax+4*(rdx-8)], ymm0
		ret


Vector_Zero:
	; rax address of vector x to zero
	       push   rdi
		mov   ecx, dword[rax+Vector.elemCnt]
		mov   rdi, qword[rax+Vector.data]
		xor   eax, eax
	  rep stosd
		pop   rdi
		ret

Vector_Subtract:
	; rcx address of vector x
	; rdx address of vector y
	; rax address of vector to write x-y
		mov   r8d, dword[rcx+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]
		mov   rdx, qword[rdx+Vector.data]

		xor   r9d, r9d
.Loop:
	    vmovaps   ymm0, qqword[rcx+4*r9]
	     vsubps   ymm0, ymm0, qqword[rdx+4*r9]
	    vmovaps   qqword[rax+4*r9], ymm0
		add   qword[nnetFlops], 8*1
		add   r9d, 8
		cmp   r9d, r8d
		 jb   .Loop
		ret


Vector_Add:
	; rcx address of vector x
	; rdx address of vector y
	; rax address of vector to write x+y
		mov   r8d, dword[rcx+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]
		mov   rdx, qword[rdx+Vector.data]

		xor   r9d, r9d
.Loop:
	    vmovaps   ymm0, qqword[rcx+4*r9]
	     vaddps   ymm0, ymm0, qqword[rdx+4*r9]
	    vmovaps   qqword[rax+4*r9], ymm0
		add   qword[nnetFlops], 8*1
		add   r9d, 8
		cmp   r9d, r8d
		 jb   .Loop
		ret

Vector_Times:
	; rcx address of vector x
	; rdx address of vector y
	; rax address of vector to write x*y
		mov   r8d, dword[rcx+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]
		mov   rdx, qword[rdx+Vector.data]

		xor   r9d, r9d
.Loop:
	    vmovaps   ymm0, qqword[rcx+4*r9]
	     vmulps   ymm0, ymm0, qqword[rdx+4*r9]
	    vmovaps   qqword[rax+4*r9], ymm0
		add   qword[nnetFlops], 8*1
		add   r9d, 8
		cmp   r9d, r8d
		 jb   .Loop
		ret


Vector_MulAddTo:
	; rcx address of vector y
	; rax address of vector x to write x + xmm0*y
                sub   rsp, 8*3
              vmovd   dword[rsp], xmm0
       vbroadcastss   ymm0, dword[rsp]
		mov   r8d, dword[rax+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]
		xor   r9d, r9d
.Loop:
	     vmulps   ymm1, ymm0, qqword[rcx+4*r9]
	     vaddps   ymm1, ymm1, qqword[rax+4*r9]
	    vmovaps   qqword[rax+4*r9], ymm1
		add   qword[nnetFlops], 8*2
		add   r9d, 8
		cmp   r9d, r8d
		 jb   .Loop
		and   r8d, 7
		shl   r8d, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+r8]
	    vmovaps   qqword[rax+4*(r9-8)], ymm0
                add   rsp, 8*3
		ret



Matrix_DotAdd:
	; in rcx address of matrix A
	;    rdx address of vector x
	;    r8  address of vector b
	;    rax address of vector to write A.x+b
	       push   rbp rbx rsi rdi r15
		mov   rbp, qword[r8+Vector.data]
		mov   rdx, qword[rdx+Vector.data]
		mov   rax, qword[rax+Vector.data]
		mov   rbx, qword[rcx+Matrix.stride]
		mov   r8, qword[rcx+Matrix.data]
		lea   r9, [r8+rbx]
		lea   r10, [r9+rbx]
		lea   r11, [r10+rbx]
		xor   r15d, r15d
.NextRow:
	     vxorps   ymm8, ymm8, ymm8
	     vxorps   ymm9, ymm9, ymm9
	     vxorps   ymm10, ymm10, ymm10
	     vxorps   ymm11, ymm11, ymm11
	     vxorps   ymm12, ymm12, ymm12
	     vxorps   ymm13, ymm13, ymm13
	     vxorps   ymm14, ymm14, ymm14
	     vxorps   ymm15, ymm15, ymm15
		xor   edi, edi
		mov   esi, ebx
.NextCol:
	    vmovaps   ymm0, qqword[rdx+4*rdi]
	     vmulps   ymm4, ymm0, qqword[r8+4*rdi]
	     vmulps   ymm5, ymm0, qqword[r9+4*rdi]
	     vmulps   ymm6, ymm0, qqword[r10+4*rdi]
	     vmulps   ymm7, ymm0, qqword[r11+4*rdi]
	     vaddps   ymm8, ymm8, ymm4
	     vaddps   ymm9, ymm9, ymm5
	     vaddps   ymm10, ymm10, ymm6
	     vaddps   ymm11, ymm11, ymm7
	     vmulps   ymm4, ymm0, qqword[r8+4*rsi]
	     vmulps   ymm5, ymm0, qqword[r9+4*rsi]
	     vmulps   ymm6, ymm0, qqword[r10+4*rsi]
	     vmulps   ymm7, ymm0, qqword[r11+4*rsi]
	     vaddps   ymm12, ymm12, ymm4
	     vaddps   ymm13, ymm13, ymm5
	     vaddps   ymm14, ymm14, ymm6
	     vaddps   ymm15, ymm15, ymm7
		add   edi, 8
		add   esi, 8
		cmp   edi, dword[rcx+Matrix.colCnt]
		 jb   .NextCol
	    vhaddps   ymm8, ymm8, ymm9
	    vhaddps   ymm10, ymm10, ymm11
	    vhaddps   ymm12, ymm12, ymm13
	    vhaddps   ymm14, ymm14, ymm15
	    vhaddps   ymm8, ymm8, ymm10
	    vhaddps   ymm12, ymm12, ymm14
	 vperm2f128   ymm0, ymm8, ymm12, 0x20
	 vperm2f128   ymm1, ymm8, ymm12, 0x31
	     vaddps   ymm0, ymm0, qqword[rbp+4*r15]
	     vaddps   ymm0, ymm0, ymm1
	    vmovaps   qqword[rax+4*r15], ymm0
		lea   r8, [r8+8*rbx]
		lea   r9, [r9+8*rbx]
		lea   r10, [r10+8*rbx]
		lea   r11, [r11+8*rbx]
		add   r15d, 8
		cmp   r15d, dword[rcx+Matrix.rowCnt]
		 jb   .NextRow
		mov   eax, dword[rcx+Matrix.rowCnt]
	       imul   eax, dword[rcx+Matrix.colCnt]
		add   rax, rax
		add   qword[nnetFlops], rax
		pop   r15 rdi rsi rbx rbp
		ret




Matrix_TransposeDot:
	; rcx address of matrix A
	; rdx address of vector x
	; rax address of vector to write A^t.x
	       push   rbx rsi rdi
		mov   rdx, qword[rdx+Vector.data]
		mov   rax, qword[rax+Vector.data]
		mov   rbx, qword[rcx+Matrix.stride]
		mov   r8, qword[rcx+Matrix.data]
		lea   r9, [r8+rbx]
		lea   r10, [r9+rbx]
		lea   r11, [r10+rbx]

		xor   edi, edi
	     vxorps   ymm0, ymm0, ymm0
.ZeroNext:
	    vmovaps   qqword[rax+4*rdi], ymm0
		add   edi, 8
		cmp   edi, dword[rcx+Matrix.colCnt]
		 jb   .ZeroNext

		xor   esi, esi
.NextRow:
       vbroadcastss   ymm8, dword[rdx+4*(rsi+0)]
       vbroadcastss   ymm9, dword[rdx+4*(rsi+1)]
       vbroadcastss   ymm10, dword[rdx+4*(rsi+2)]
       vbroadcastss   ymm11, dword[rdx+4*(rsi+3)]

		xor   edi, edi
.NextCol:
	    vmovaps   ymm0, qqword[rax+4*rdi]
	     vmulps   ymm4, ymm8, qqword[r8+4*rdi]
	     vmulps   ymm5, ymm9, qqword[r9+4*rdi]
	     vmulps   ymm6, ymm10, qqword[r10+4*rdi]
	     vmulps   ymm7, ymm11, qqword[r11+4*rdi]
	     vaddps   ymm4, ymm4, ymm5
	     vaddps   ymm6, ymm6, ymm7
	     vaddps   ymm4, ymm4, ymm6
	     vaddps   ymm0, ymm0, ymm4
	    vmovaps   qqword[rax+4*rdi], ymm0
		add   edi, 8
		cmp   edi, dword[rcx+Matrix.colCnt]
		 jb   .NextCol

		lea   r8, [r8+4*rbx]
		lea   r9, [r9+4*rbx]
		lea   r10, [r10+4*rbx]
		lea   r11, [r11+4*rbx]
		add   esi, 4
		cmp   esi, dword[rcx+Matrix.rowCnt]
		 jb   .NextRow

		mov   eax, dword[rcx+Matrix.rowCnt]
	       imul   eax, dword[rcx+Matrix.colCnt]
		add   rax, rax
		add   qword[nnetFlops], rax
		pop   rdi rsi rbx
		ret



Matrix_AddToOuterTimes:
	; rcx address of vector x
	; rdx address of vector y
	; rax address of Matrix A to write A+x^t.y
	       push   rbx rsi rdi r14 r15
		mov   rcx, qword[rcx+Vector.data]
		mov   rdx, qword[rdx+Vector.data]
		mov   rbx, qword[rax+Matrix.stride]
		mov   r8, qword[rax+Matrix.data]
		lea   r9, [r8+rbx]
		lea   r10, [r9+rbx]
		lea   r11, [r10+rbx]
		lea   rbx, [4*rbx]
		xor   esi, esi
.NextRow:
       vbroadcastss   ymm8, dword[rcx+4*(rsi+0)]
       vbroadcastss   ymm9, dword[rcx+4*(rsi+1)]
       vbroadcastss   ymm10, dword[rcx+4*(rsi+2)]
       vbroadcastss   ymm11, dword[rcx+4*(rsi+3)]
		xor   edi, edi
.NextCol:
	    vmovaps   ymm15, qqword[rdx+4*rdi]
	     vmulps   ymm0, ymm8, ymm15
	     vmulps   ymm1, ymm9, ymm15
	     vmulps   ymm2, ymm10, ymm15
	     vmulps   ymm3, ymm11, ymm15
	     vaddps   ymm0, ymm0, qqword[r8+4*rdi]
	     vaddps   ymm1, ymm1, qqword[r9+4*rdi]
	     vaddps   ymm2, ymm2, qqword[r10+4*rdi]
	     vaddps   ymm3, ymm3, qqword[r11+4*rdi]
	    vmovaps   qqword[r8+4*rdi], ymm0
	    vmovaps   qqword[r9+4*rdi], ymm1
	    vmovaps   qqword[r10+4*rdi], ymm2
	    vmovaps   qqword[r11+4*rdi], ymm3
		add   qword[nnetFlops], 8*2*4
		add   edi, 8
		cmp   edi, dword[rax+Matrix.colCnt]
		 jb   .NextCol
		add   r8, rbx
		add   r9, rbx
		add   r10, rbx
		add   r11, rbx
		add   esi, 4
		cmp   esi, dword[rax+Matrix.rowCnt]
		 jb   .NextRow
		pop   r15 r14 rdi rsi rbx
		ret



	      align   16
Matrix_MulAddTo:
	; rcx address of Matrix B
	; rax address of Matrix A to write A + xmm0*B

	       push   rbx rsi rdi
                sub   rsp, 16
              vmovd   dword[rsp], xmm0
       vbroadcastss   ymm0, dword[rsp]
		mov   esi, dword[rax+Matrix.colCnt]
	       imul   esi, dword[rax+Matrix.rowCnt]
		mov   rax, qword[rax+Matrix.data]
		mov   rcx, qword[rcx+Matrix.data]
		xor   edi, edi
.NextBlock:
	     vmulps   ymm1, ymm0, qqword[rcx+4*(rdi+8*0)]
	     vmulps   ymm2, ymm0, qqword[rcx+4*(rdi+8*1)]
	     vmulps   ymm3, ymm0, qqword[rcx+4*(rdi+8*2)]
	     vmulps   ymm4, ymm0, qqword[rcx+4*(rdi+8*3)]
	     vaddps   ymm1, ymm1, qqword[rax+4*(rdi+8*0)]
	     vaddps   ymm2, ymm2, qqword[rax+4*(rdi+8*1)]
	     vaddps   ymm3, ymm3, qqword[rax+4*(rdi+8*2)]
	     vaddps   ymm4, ymm4, qqword[rax+4*(rdi+8*3)]
	    vmovaps   qqword[rax+4*(rdi+8*0)], ymm1
	    vmovaps   qqword[rax+4*(rdi+8*1)], ymm2
	    vmovaps   qqword[rax+4*(rdi+8*2)], ymm3
	    vmovaps   qqword[rax+4*(rdi+8*3)], ymm4
		add   qword[nnetFlops], 8*2+8*2+8*2+8*2
		add   edi, 8*4
		cmp   edi, esi
		 jb   .NextBlock
                add   rsp, 16
		pop   rdi rsi rbx
		ret



Matrix_Zero:
	; rax address of Matrix to zero
	       push   rdi
		mov   ecx, dword[rax+Matrix.rowCnt]
	       imul   rcx, qword[rax+Matrix.stride]
		mov   rdi, qword[rax+Matrix.data]
		xor   eax, eax
		shr   ecx, 2
	  rep stosd
		pop   rdi
		ret



Vector_Random:
	; rcx
	       push   rbx rsi rdi
		mov   rbx, rcx

		xor   edi, edi
.Loop:
		lea   rcx, [nnetrand]
	       call   Math_Rand_d
	     vsubsd   xmm0, xmm0, qword[NNData.a]
	     vmulsd   xmm0, xmm0, qword[NNData.b]
	  vcvtsd2ss   xmm0, xmm0, xmm0
		mov   rax, qword[rbx+Vector.data]
	     vmovss   dword[rax+4*rdi], xmm0

		add   edi, 1
		cmp   edi, dword[rbx+Vector.elemCnt]
		 jb  .Loop

		pop   rdi rsi rbx
		ret


Matrix_Random:
	; rcx
	       push   rbx rsi rdi
		mov   rbx, rcx

		mov   rdi, qword[rbx+Vector.data]

		xor   r14d, r14d
.NextRow:
		xor   r15d, r15d
.NextCol:
		lea   rcx, [nnetrand]
	       call   Math_Rand_d
	     vsubsd   xmm0, xmm0, qword[NNData.a]
	     vmulsd   xmm0, xmm0, qword[NNData.b]
	  vcvtsd2ss   xmm0, xmm0, xmm0
	     vmovss   dword[rdi+4*r15], xmm0
		add   r15d, 1
		cmp   r15d, dword[rbx+Matrix.colCnt]
		 jb   .NextCol
		add   rdi, qword[rbx+Matrix.stride]
		add   r14d, 1
		cmp   r14d, dword[rbx+Matrix.rowCnt]
		 jb   .NextRow

		pop   rdi rsi rbx
		ret


