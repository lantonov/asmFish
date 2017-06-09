

Vector_Tenuate:
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
	      vpxor   ymm3, ymm3, ymm3
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vandps   ymm1, ymm0, qqword[NNData.absmask]
	     vsubps   ymm1, ymm1, qqword[NNData.eight]
	     vmaxps   ymm1, ymm1, ymm3
	     vandps   ymm2, ymm0, qqword[NNData.signmask]
	     vxorps   ymm1, ymm1, ymm2
	vfmadd231ps   ymm0, ymm1, qqword[NNData.tfactor]
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   edx, 8
		cmp   edx, ecx
		 jb   .Loop
		ret

Matrix_Tenuate:
		mov   rax, qword[rax+Matrix.data]
		mov   r8, qword[rcx+Matrix.data]
		mov   r9d, dword[rcx+Matrix.rowCnt]
	       imul   r9d, dword[rcx+Matrix.colCnt]
		xor   edx, edx
	      vpxor   ymm3, ymm3, ymm3
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vandps   ymm1, ymm0, qqword[NNData.absmask]
	     vsubps   ymm1, ymm1, qqword[NNData.eight]
	     vmaxps   ymm1, ymm1, ymm3
	     vandps   ymm2, ymm0, qqword[NNData.signmask]
	     vxorps   ymm1, ymm1, ymm2
	vfmadd231ps   ymm0, ymm1, qqword[NNData.tfactor]
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   edx, 8
		cmp   edx, r9d
		 jb   .Loop
		ret




Vector_Clamp:
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vminps   ymm0, ymm0, qqword[NNData.one]
	     vmaxps   ymm0, ymm0, qqword[NNData.mone]
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   edx, 8
		cmp   edx, ecx
		 jb   .Loop
		ret

Matrix_Clamp:
		mov   rax, qword[rax+Matrix.data]
		mov   r8, qword[rcx+Matrix.data]
		mov   r9d, dword[rcx+Matrix.rowCnt]
	       imul   r9d, dword[rcx+Matrix.colCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
	     vminps   ymm0, ymm0, qqword[NNData.one]
	     vmaxps   ymm0, ymm0, qqword[NNData.mone]
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   edx, 8
		cmp   edx, r9d
		 jb   .Loop
		ret



Vector_Identity:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[r8+4*rdx]
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


Vector_IdentityPrime:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		mov   ecx, dword[rcx+Vector.elemCnt]
		xor   edx, edx
.Loop:
	    vmovaps   ymm0, qqword[NNData.one]
	    vmovaps   qqword[rax+4*rdx], ymm0
		add   edx, 8
		cmp   edx, ecx
		 jb   .Loop
		and   ecx, 7
		shl   ecx, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+rcx]
	    vmovaps   qqword[rax+4*(rdx-8)], ymm0
		ret



Vector_Ramp:
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
	     vsubps   ymm0, ymm0, ymm1
	     vmulps   ymm0, ymm0, ymm0
	     vaddps   ymm0, ymm0, qqword[NNData.one]
	     vrcpps   ymm0, ymm0
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


Vector_RampPrime:
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
		and   r8d, 7
		shl   r8d, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+r8]
	    vmovaps   qqword[rax+4*(r9-8)], ymm0
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
		and   r8d, 7
		shl   r8d, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+r8]
	    vmovaps   qqword[rax+4*(r9-8)], ymm0
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
		and   r8d, 7
		shl   r8d, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+r8]
	    vmovaps   qqword[rax+4*(r9-8)], ymm0
		ret


Vector_MulAddTo:
	; rcx address of vector y
	; rax address of vector x to write x + xmm0*y
       vbroadcastss   ymm0, xmm0
		mov   r8d, dword[rax+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]
		xor   r9d, r9d
.Loop:
	    vmovaps   ymm1, qqword[rax+4*r9]
	vfmadd231ps   ymm1, ymm0, qqword[rcx+4*r9]
	    vmovaps   qqword[rax+4*r9], ymm1
		add   qword[nnetFlops], 8*2
		add   r9d, 8
		cmp   r9d, r8d
		 jb   .Loop
		and   r8d, 7
		shl   r8d, 5
	     vandps   ymm0, ymm0, qqword[NNData.mod8mask+r8]
	    vmovaps   qqword[rax+4*(r9-8)], ymm0
		ret


_Matrix_DotAdd:
	; in rcx address of matrix A
	;    rdx address of vector x
	;    r8  address of vector b
	;    rax address of vector to write A.x+b
	       push   rbp rbx rsi rdi r15
		sub   rsp, 32*8
		mov   rbp, qword[r8+Vector.data]
		mov   rdx, qword[rdx+Vector.data]
		mov   rax, qword[rax+Vector.data]
		mov   rbx, qword[rcx+Matrix.stride]
		mov   r8, qword[rcx+Matrix.data]
		lea   rbx, [8*rbx]
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
.NextCol:
	    vmovaps   ymm0, qqword[rdx+4*(rdi+0)]

	    vmovaps   ymm1, qqword[rsp+32*0]
	vfmadd231ps   ymm1, ymm0, qqword[r8+4*8*0+4*8*0]
	    vmovaps   qqword[rsp+32*0], ymm1
	    vmovaps   ymm1, qqword[rsp+32*1]
	vfmadd231ps   ymm1, ymm0, qqword[r8+4*8*0+4*8*1]
	    vmovaps   qqword[rsp+32*1], ymm1
	vfmadd231ps   ymm2, ymm0, qqword[r8+4*8*0+4*8*2]
	vfmadd231ps   ymm3, ymm0, qqword[r8+4*8*0+4*8*3]
	vfmadd231ps   ymm4, ymm0, qqword[r8+4*8*0+4*8*4]
	vfmadd231ps   ymm5, ymm0, qqword[r8+4*8*0+4*8*5]
	vfmadd231ps   ymm6, ymm0, qqword[r8+4*8*0+4*8*6]
	vfmadd231ps   ymm7, ymm0, qqword[r8+4*8*0+4*8*7]

	    vmovaps   ymm0, qqword[rdx+4*(rdi+8)]
	vfmadd231ps   ymm8, ymm0, qqword[r8+4*8*1+4*8*0]
	vfmadd231ps   ymm9, ymm0, qqword[r8+4*8*1+4*8*1]
	vfmadd231ps   ymm10, ymm0, qqword[r8+4*8*1+4*8*2]
	vfmadd231ps   ymm11, ymm0, qqword[r8+4*8*1+4*8*3]
	vfmadd231ps   ymm12, ymm0, qqword[r8+4*8*1+4*8*4]
	vfmadd231ps   ymm13, ymm0, qqword[r8+4*8*1+4*8*5]
	vfmadd231ps   ymm14, ymm0, qqword[r8+4*8*1+4*8*6]
	vfmadd231ps   ymm15, ymm0, qqword[r8+4*8*1+4*8*7]
		add   r8, 2*4*8*8
		add   edi, 16
		cmp   edi, dword[rcx+Matrix.colCnt]
		 jb   .NextCol
	     vaddps   ymm8, ymm8, qqword[rsp+32*0]
	     vaddps   ymm9, ymm9, qqword[rsp+32*1]
	     vaddps   ymm10, ymm10, ymm2
	     vaddps   ymm11, ymm11, ymm3
	     vaddps   ymm12, ymm12, ymm4
	     vaddps   ymm13, ymm13, ymm5
	     vaddps   ymm14, ymm14, ymm6
	     vaddps   ymm15, ymm15, ymm7

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
	       ; add   r8, rbx
		add   r15d, 8
		cmp   r15d, dword[rcx+Matrix.rowCnt]
		 jb   .NextRow
	   ;     mov   eax, dword[rcx+Matrix.rowCnt]
	   ;    imul   eax, dword[rcx+Matrix.colCnt]
	   ;     add   rax, rax
	   ;     add   qword[nnetFlops], rax
		add   rsp, 32*8
		pop   r15 rdi rsi rbx rbp
		ret









; An important function
; This does between 5 and 10 FLOP/cycle
;  depending sizes, which depends heavily on the cache
	      align   16;, Matrix_DotAdd.NextCol
Matrix_DotAdd:
	; in rcx address of matrix A
	;    rdx address of vector x
	;    r8  address of vector b
	;    rax address of vector to write A.x+b
	       push   rbp rbx rsi rdi r14 r15
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
	vfmadd231ps   ymm8, ymm0, qqword[r8+4*rdi]
	vfmadd231ps   ymm9, ymm0, qqword[r9+4*rdi]
	vfmadd231ps   ymm10, ymm0, qqword[r10+4*rdi]
	vfmadd231ps   ymm11, ymm0, qqword[r11+4*rdi]
	vfmadd231ps   ymm12, ymm0, qqword[r8+4*rsi]
	vfmadd231ps   ymm13, ymm0, qqword[r9+4*rsi]
	vfmadd231ps   ymm14, ymm0, qqword[r10+4*rsi]
	vfmadd231ps   ymm15, ymm0, qqword[r11+4*rsi]
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
		pop   r15 r14 rdi rsi rbx rbp
		ret


; Another important function
; This does between 5 and 10 FLOP/cycle
;  depending sizes, which depends heavily on the cache
	      align   16;, Matrix_TransposeDot.NextCol
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
	vfmadd231ps   ymm0, ymm8, qqword[r8+4*rdi]
	vfmadd231ps   ymm0, ymm9, qqword[r9+4*rdi]
	vfmadd231ps   ymm0, ymm10, qqword[r10+4*rdi]
	vfmadd231ps   ymm0, ymm11, qqword[r11+4*rdi]
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


	      align   16;, Matrix_AddToOuterTimes.NextCol
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
	    vmovaps   ymm0, qqword[r8+4*rdi]
	    vmovaps   ymm1, qqword[r9+4*rdi]
	    vmovaps   ymm2, qqword[r10+4*rdi]
	    vmovaps   ymm3, qqword[r11+4*rdi]
	vfmadd231ps   ymm0, ymm8, ymm15
	vfmadd231ps   ymm1, ymm9, ymm15
	vfmadd231ps   ymm2, ymm10, ymm15
	vfmadd231ps   ymm3, ymm11, ymm15
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
       vbroadcastss   ymm0, xmm0
		mov   esi, dword[rax+Matrix.colCnt]
	       imul   esi, dword[rax+Matrix.rowCnt]
		mov   rax, qword[rax+Matrix.data]
		mov   rcx, qword[rcx+Matrix.data]
		xor   edi, edi
.NextBlock:
	    vmovaps   ymm1, qqword[rax+4*(rdi+8*0)]
	    vmovaps   ymm2, qqword[rax+4*(rdi+8*1)]
	    vmovaps   ymm3, qqword[rax+4*(rdi+8*2)]
	    vmovaps   ymm4, qqword[rax+4*(rdi+8*3)]
	vfmadd231ps   ymm1, ymm0, qqword[rcx+4*(rdi+8*0)]
	vfmadd231ps   ymm2, ymm0, qqword[rcx+4*(rdi+8*1)]
	vfmadd231ps   ymm3, ymm0, qqword[rcx+4*(rdi+8*2)]
	vfmadd231ps   ymm4, ymm0, qqword[rcx+4*(rdi+8*3)]
	    vmovaps   qqword[rax+4*(rdi+8*0)], ymm1
	    vmovaps   qqword[rax+4*(rdi+8*1)], ymm2
	    vmovaps   qqword[rax+4*(rdi+8*2)], ymm3
	    vmovaps   qqword[rax+4*(rdi+8*3)], ymm4
		add   qword[nnetFlops], 8*2+8*2+8*2+8*2
		add   edi, 8*4
		cmp   edi, esi
		 jb   .NextBlock
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


