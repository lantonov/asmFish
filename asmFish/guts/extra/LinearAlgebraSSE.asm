align 32
NNData:
.absmask dd 8 dup 0x7FFFFFFF
.one dd 1.0
.a dq 0.5
.b dq 0.1
.testImageFile	db 'guts\testIM.ubyte',0
.testLabelFile	db 'guts\testLB.ubyte',0
.trainImageFile db 'guts\trainIM.ubyte',0
.trainLabelFile db 'guts\trainLB.ubyte',0





Vector_Sigma:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		xor   edx, edx
.Loop:
	      movss   xmm0, dword[r8+4*rdx]
	     movaps   xmm1, dqword[NNData.absmask]
	      andps   xmm1, xmm0
	      addss   xmm1, dword[NNData.one]
	      addss   xmm0, xmm1
	      addss   xmm1, xmm1
	      rcpss   xmm1, xmm1
	      mulss   xmm0, xmm1
	      movss   dword[rax+4*rdx], xmm0
		add   qword[nnetFlops], 6
		add   edx, 1
		cmp   edx, dword[rcx+Vector.elemCnt]
		 jb   .Loop
		ret



Vector_SigmaPrime:
	; rcx address of vector x
	; rax address of vector to write sigma(x)
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[rcx+Vector.data]
		xor   edx, edx
.Loop:
	      movss   xmm0, dword[r8+4*rdx]
	      andps   xmm0, dqword[NNData.absmask]
	      addss   xmm0, dword[NNData.one]
	      mulss   xmm0, xmm0
	      addss   xmm0, xmm0
	      rcpss   xmm0, xmm0
	      movss   dword[rax+4*rdx], xmm0
		add   qword[nnetFlops], 5
		add   edx, 1
		cmp   edx, dword[rcx+Vector.elemCnt]
		 jb   .Loop
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
	      movss   xmm0, dword[rcx+4*r9]
	      subss   xmm0, dword[rdx+4*r9]
	      movss   dword[rax+4*r9], xmm0
		add   qword[nnetFlops], 1
		add   r9d, 1
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
	      movss   xmm0, dword[rcx+4*r9]
	      addss   xmm0, dword[rdx+4*r9]
	      movss   dword[rax+4*r9], xmm0
		add   qword[nnetFlops], 1
		add   r9d, 1
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
	      movss   xmm0, dword[rcx+4*r9]
	      mulss   xmm0, dword[rdx+4*r9]
	      movss   dword[rax+4*r9], xmm0
		add   qword[nnetFlops], 1
		add   r9d, 1
		cmp   r9d, r8d
		 jb   .Loop
		ret



Vector_MulAddTo:
	; rcx address of vector y
	; rax address of vector x to write x + xmm0*y
		mov   r8d, dword[rax+Vector.elemCnt]
		mov   rax, qword[rax+Vector.data]
		mov   rcx, qword[rcx+Vector.data]

		xor   r9d, r9d
.Loop:
	      movss   xmm1, dword[rcx+4*r9]
	      mulss   xmm1, xmm0
	      addss   xmm1, dword[rax+4*r9]
	      movss   dword[rax+4*r9], xmm1
		add   qword[nnetFlops], 2
		add   r9d, 1
		cmp   r9d, r8d
		 jb   .Loop
		ret




Matrix_DotAdd:
 ; in rcx address of matrix A
 ;    rdx address of vector x
 ;    r8  address of vector b
 ;    rax address of vector to write A.x+b
	       push   r14 r15
		mov   rdx, qword[rdx+Vector.data]
		mov   rax, qword[rax+Vector.data]
		mov   r8, qword[r8+Vector.data]
		mov   r9, qword[rcx+Matrix.data]
		xor   r14d, r14d
.NextRow:
	      movss   xmm0, dword[r8+4*r14]
		xor   r15d, r15d
.NextCol:
	      movss   xmm1, dword[r9+4*r15]
	      mulss   xmm1, dword[rdx+4*r15]
	      addss   xmm0, xmm1
		add   qword[nnetFlops], 2
		add   r15d, 1
		cmp   r15d, dword[rcx+Matrix.colCnt]
		 jb   .NextCol
	      movss   dword[rax+4*r14], xmm0
		add   r14d, 1
		add   r9, qword[rcx+Matrix.stride]
		cmp   r14d, dword[rcx+Matrix.rowCnt]
		 jb   .NextRow
		pop   r15 r14
		ret

Matrix_TransposeDot:
	; rcx address of matrix A
	; rdx address of vector x
	; rax address of vector to write A^t.x
	       push   r14 r15
		mov   rdx, qword[rdx+Vector.data]
		mov   rax, qword[rax+Vector.data]
		xor   r14d, r14d
		mov   r8, qword[rcx+Matrix.data]
.NextRow:
	      xorps   xmm0, xmm0
		xor   r15d, r15d
		mov   r9, r8
.NextCol:
	      movss   xmm1, dword[r9]
	      mulss   xmm1, dword[rdx+4*r15]
	      addss   xmm0, xmm1
		add   qword[nnetFlops], 2
		add   r9, qword[rcx+Matrix.stride]
		add   r15d, 1
		cmp   r15d, dword[rcx+Matrix.rowCnt]
		 jb   .NextCol
	      movss   dword[rax+4*r14], xmm0
		add   r14d, 1
		add   r8, 4
		cmp   r14d, dword[rcx+Matrix.colCnt]
		 jb   .NextRow
		pop   r15 r14
		ret


Matrix_AddToOuterTimes:
	; rcx address of vector x
	; rdx address of vector y
	; rax address of Matrix A to write A+x^t.y
	       push   r14 r15
		mov   rcx, qword[rcx+Vector.data]
		mov   rdx, qword[rdx+Vector.data]
		mov   r8, qword[rax+Matrix.data]
		xor   r14d, r14d
.NextRow:
	      movss   xmm2, dword[rcx+4*r14]
		xor   r15d, r15d
.NextCol:
	      movss   xmm0, dword[rdx+4*r15]
	      mulss   xmm0, xmm2
	      addss   xmm0, dword[r8+4*r15]
	      movss   dword[r8+4*r15], xmm0
		add   qword[nnetFlops], 2
		add   r15d, 1
		cmp   r15d, dword[rax+Matrix.colCnt]
		 jb   .NextCol
		add   r8, qword[rax+Matrix.stride]
		add   r14d, 1
		cmp   r14d, dword[rax+Matrix.rowCnt]
		 jb   .NextRow
		pop   r15 r14
		ret




Matrix_MulAddTo:
	; rcx address of Matrix B
	; rax address of Matrix A to write A + xmm0*B

	       push   r14 r15
		mov   r8, qword[rax+Matrix.data]
		mov   r9, qword[rcx+Matrix.data]
		xor   r14d, r14d
.NextRow:
		xor   r15d, r15d
.NextCol:
	      movss   xmm1, dword[r9+4*r15]
	      mulss   xmm1, xmm0
	      addss   xmm1, dword[r8+4*r15]
	      movss   dword[r8+4*r15], xmm1
		add   qword[nnetFlops], 2
		add   r15d, 1
		cmp   r15d, dword[rax+Matrix.colCnt]
		 jb   .NextCol
		add   r9, qword[rax+Matrix.stride]
		add   r8, qword[rax+Matrix.stride]
		add   r14d, 1
		cmp   r14d, dword[rax+Matrix.rowCnt]
		 jb   .NextRow
		pop   r15 r14
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
	      subsd   xmm0, qword[NNData.a]
	      mulsd   xmm0, qword[NNData.b]
	   cvtsd2ss   xmm0, xmm0
		mov   rax, qword[rbx+Vector.data]
	      movss   dword[rax+4*rdi], xmm0

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
	      subsd   xmm0, qword[NNData.a]
	      mulsd   xmm0, qword[NNData.b]
	   cvtsd2ss   xmm0, xmm0
	      movss   dword[rdi+4*r15], xmm0
		add   r15d, 1
		cmp   r15d, dword[rbx+Matrix.colCnt]
		 jb   .NextCol
		add   rdi, qword[rbx+Matrix.stride]
		add   r14d, 1
		cmp   r14d, dword[rbx+Matrix.rowCnt]
		 jb   .NextRow

		pop   rdi rsi rbx
		ret


