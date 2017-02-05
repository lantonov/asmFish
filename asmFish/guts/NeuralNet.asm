

struct Vector
 data	 rq 1
 elemCnt rd 1
	 rd 1
ends

struct Matrix
 data	rq 1
 stride rq 1
 colCnt rd 1
 rowCnt rd 1
	rq 1
ends

struct Layer
 a  Vector
 z  Vector
 e  Vector
 A  Matrix
 Ad Matrix
 b  Vector
 bd Vector
ends

struct NeuralNet
 len	rd 1
	rd 1
 output Vector
 layers Layer
ends







Vector_Create:
	; rcx address of Vector
	; edx elem count
	       push   rbx
		mov   rbx, rcx
		mov   dword[rbx+Vector.elemCnt], edx
		mov   ecx, dword[rbx+Vector.elemCnt]
		add   ecx, 7
		and   ecx, -8
		shl   ecx, 2
	       call   _VirtualAlloc
		mov   qword[rbx+Vector.data], rax
		pop   rbx
		ret

Vector_Destroy:
	; rcx address of Vector
	       push   rbx
		mov   rbx, rcx
		mov   rcx, qword[rbx+Vector.data]
		mov   edx, dword[rbx+Vector.elemCnt]
		add   edx, 7
		and   edx, -8
		shl   edx, 2
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Vector.data], rax
		pop   rbx
		ret


Matrix_Create:
	; rcx address of Matrix
	; edx row count
	; r8d col count
	       push   rbx
		mov   rbx, rcx
		mov   dword[rbx+Matrix.rowCnt], edx
		mov   dword[rbx+Matrix.colCnt], r8d
		add   r8d, 7
		and   r8d, -8
		shl   r8d, 2
		mov   qword[rbx+Matrix.stride], r8
		mov   ecx, dword[rbx+Matrix.rowCnt]
		add   ecx, 7
		and   ecx, -8
	       imul   rcx, r8
	       call   _VirtualAlloc
		mov   qword[rbx+Matrix.data], rax
		pop   rbx
		ret

Matrix_Destroy:
	; rcx address of Matrix
		mov   rcx, qword[rbx+Matrix.data]
		mov   edx, dword[rbx+Matrix.rowCnt]
		add   edx, 7
		and   edx, -8
	       imul   rdx, qword[rbx+Matrix.stride]
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbx+Matrix.data], rax
		mov   qword[rbx+Matrix.stride], rax
		mov   dword[rbx+Matrix.rowCnt], eax
		mov   dword[rbx+Matrix.colCnt], eax
		pop   rbx
		ret


Layer_Create:
	; rcx address of Layer
	; edx input count
	; r8d output count
	       push   rbx rsi rdi
		mov   rbx, rcx
		mov   esi, edx
		mov   edi, r8d

		lea   rcx, [rbx+Layer.a]
		mov   edx, esi
	       call   Vector_Create
		lea   rcx, [rbx+Layer.z]
		mov   edx, edi
	       call   Vector_Create
		lea   rcx, [rbx+Layer.e]
		mov   edx, edi
	       call   Vector_Create

		lea   rcx, [rbx+Layer.b]
		mov   edx, edi
	       call   Vector_Create
		lea   rcx, [rbx+Layer.bd]
		mov   edx, edi
	       call   Vector_Create

		lea   rcx, [rbx+Layer.A]
		mov   edx, edi
		mov   r8d, esi
	       call   Matrix_Create
		lea   rcx, [rbx+Layer.Ad]
		mov   edx, edi
		mov   r8d, esi
	       call   Matrix_Create

		lea   rcx, [rbx+Layer.A]
	       call   Matrix_Random
		lea   rcx, [rbx+Layer.b]
	       call   Vector_Random

		pop   rdi rsi rbx
		ret


Layer_Destroy:
	; rcx address of Layer
	       push   rbx
		mov   rbx, rcx

		lea   rcx, [rbx+Layer.a]
	       call   Vector_Destroy
		lea   rcx, [rbx+Layer.z]
	       call   Vector_Destroy
		lea   rcx, [rbx+Layer.e]
	       call   Vector_Destroy

		lea   rcx, [rbx+Layer.b]
	       call   Vector_Destroy
		lea   rcx, [rbx+Layer.bd]
	       call   Vector_Destroy

		lea   rcx, [rbx+Layer.A]
	       call   Matrix_Destroy
		lea   rcx, [rbx+Layer.Ad]
	       call   Matrix_Destroy

		pop   rbx
		ret




NeuralNet_Create:
	; rcx address of NeuralNet
	; rdx address of array of counts (length edx+1)
	; r8d length, this should be >=1

	       push   rbx rsi rdi
		mov   rbx, rcx
		mov   rsi, rdx

	; set the number of layers
		mov   dword[rbx+NeuralNet.len], r8d

	; create intermediate layers
		xor   edi, edi
.NextLayer:
	       imul   ecx, edi, sizeof.Layer
		lea   rcx, [rbx+NeuralNet.layers+rcx]
		mov   edx, dword[rsi+4*rdi]
		mov   r8d, dword[rsi+4*(rdi+1)]
	       call   Layer_Create
		add   edi, 1
		cmp   edi, dword[rbx+NeuralNet.len]
		 jb   .NextLayer

	; create output vector
		lea   rcx, [rbx+NeuralNet.output]
		mov   edx, dword[rsi+4*rdi]
	       call   Vector_Create

		pop   rdi rsi rbx
		ret

NeuralNet_Destroy:

	       push   rbx rsi rdi

	; destroy output vector
		lea   rcx, [rbx+NeuralNet.output]
	       call   Vector_Create

	; destroy intermediate layers
		xor   edi, edi
.NextLayer:
	       imul   ecx, edi, sizeof.Layer
		lea   rcx, [rbx+NeuralNet.layers+rcx]
	       call   Layer_Destroy
		add   edi, 1
		cmp   edi, dword[NeuralNet.len]
		 jb   .NextLayer


		mov   dword[rbx+NeuralNet.len], 0

		pop   rdi rsi rbx
		ret




NeuralNet_Run:
	; in: rcx address of NeuralNet
	;     the input vector in the 'a' member of the first layer
	;     output is in the output member of the net

	       push   rbp rbx rsi rdi r15
		mov   rbp, rcx

		xor   edi, edi
		lea   rsi, [rbp+NeuralNet.layers]
.ForwardProp:
		lea   rax, [rsi+Layer.z]
		lea   rcx, [rsi+Layer.A]
		lea   rdx, [rsi+Layer.a]
		lea   r8, [rsi+Layer.b]
	       call   Matrix_DotAdd
		add   edi, 1
		cmp   edi, dword[rbp+NeuralNet.len]
		jae   .ForwardDone
		lea   rax, [rsi+Layer.a+1*sizeof.Layer]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_Sigma
		add   rsi, sizeof.Layer
		jmp   .ForwardProp
.ForwardDone:

		lea   rax, [rbp+NeuralNet.output]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_Sigma

		pop   r15 rdi rsi rbx rbp
		ret






NeuralNet_TrainOne:
	; in: rcx address of NeuralNet
	;     the input vector in the 'a' member of the first layer
	;     the desired output in the output member of the net
	;
	; Ad and bd are incremented by the gradient

	       push   rbp rbx rsi rdi r15
		mov   rbp, rcx

		xor   edi, edi
		lea   rsi, [rbp+NeuralNet.layers]
.ForwardProp:
		lea   rax, [rsi+Layer.z]
		lea   rcx, [rsi+Layer.A]
		lea   rdx, [rsi+Layer.a]
		lea   r8, [rsi+Layer.b]
	       call   Matrix_DotAdd
		add   edi, 1
		cmp   edi, dword[rbp+NeuralNet.len]
		jae   .ForwardDone
		lea   rax, [rsi+Layer.a+1*sizeof.Layer]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_Sigma
		add   rsi, sizeof.Layer
		jmp   .ForwardProp
.ForwardDone:

		lea   rax, [rsi+Layer.e]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_Sigma
		lea   rax, [rsi+Layer.e]
		lea   rcx, [rsi+Layer.e]
		lea   rdx, [rbp+NeuralNet.output]
	       call   Vector_Subtract
		lea   rax, [rsi+Layer.z]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_SigmaPrime
		lea   rax, [rsi+Layer.e]
		lea   rcx, [rsi+Layer.e]
		lea   rdx, [rsi+Layer.z]
	       call   Vector_Times

		mov   edi, dword[rbp+NeuralNet.len]
		sub   edi, 1
.BackwardProp:
		sub   rsi, sizeof.Layer
		lea   rax, [rsi+Layer.z]
		lea   rcx, [rsi+Layer.z]
	       call   Vector_SigmaPrime
		lea   rax, [rsi+Layer.e]
		lea   rcx, [rsi+Layer.A+1*sizeof.Layer]
		lea   rdx, [rsi+Layer.e+1*sizeof.Layer]
	       call   Matrix_TransposeDot
		lea   rax, [rsi+Layer.e]
		lea   rcx, [rsi+Layer.e]
		lea   rdx, [rsi+Layer.z]
	       call   Vector_Times
		sub   edi, 1
		jnz   .BackwardProp

		xor   edi, edi
		lea   rsi, [rbp+NeuralNet.layers]
.Gradient:
		lea   rax, [rsi+Layer.Ad]
		lea   rcx, [rsi+Layer.e]
		lea   rdx, [rsi+Layer.a]
	       call   Matrix_AddToOuterTimes
		lea   rax, [rsi+Layer.bd]
		lea   rcx, [rsi+Layer.bd]
		lea   rdx, [rsi+Layer.e]
	       call   Vector_Add
		add   edi, 1
		add   rsi, sizeof.Layer
		cmp   edi, dword[rbp+NeuralNet.len]
		 jb   .Gradient

		pop   r15 rdi rsi rbx rbp
		ret


;Vector_Print:
;        ; in rcx address of Vector
;
;                mov   rax, qword[rcx+Vector.data]
;                xor   edx, edx
;.Loop:
;AD Float, qword[rax+4*rdx]
;AD String, ' '
;                add   edx, 1
;                cmp   edx, dword[rcx+Vector.elemCnt]
;                 jb   .Loop
;                ret




NeuralNet_UpdateTraining:
	; in: rcx address of NeuralNet
	;     xmm0


virtual at rsp
  .factor   rd 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

	       push   rbp rbx rsi rdi r15
		sub   rsp, .localsize
		mov   rbp, rcx
	     vmovss   dword[.factor], xmm0

		xor   edi, edi
		lea   rsi, [rbp+NeuralNet.layers]
.Loop:
		lea   rax, [rsi+Layer.A]
		lea   rcx, [rsi+Layer.Ad]
	     vmovss   xmm0, dword[.factor]
	       call   Matrix_MulAddTo
		lea   rax, [rsi+Layer.Ad]
	       call   Matrix_Zero

		lea   rax, [rsi+Layer.b]
		lea   rcx, [rsi+Layer.bd]
	     vmovss   xmm0, dword[.factor]
	       call   Vector_MulAddTo
		lea   rax, [rsi+Layer.bd]
	       call   Vector_Zero

		add   rsi, sizeof.Layer
		add   edi, 1
		cmp   edi, dword[rbp+NeuralNet.len]
		 jb   .Loop


		add   rsp, .localsize
		pop   r15 rdi rsi rbx rbp
		ret




RunNNet:
virtual at rsp
  .net	  rb 10*sizeof.Layer
  .rand   rq 1
  .testImages rq 1
  .testLabels rq 1
  .trainImages rq 1
  .trainLabels rq 1
  .timage rb 28*28
  .junk   rb 100
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

	       push   rbp rbx rsi rdi r15
		sub   rsp, .localsize

	; import labels

		mov   ecx, 10000
	       call   _VirtualAlloc
		mov   qword[.testLabels], rax

		lea   rcx, [NNData.testLabelFile]
	       call   _FileOpenRead
		mov   r15, rax


		mov   rcx, r15
		lea   rdx, [.junk]
		mov   r8d, 8
	       call   _FileRead

		mov   rcx, r15
		mov   rdx, qword[.testLabels]
		mov   r8d, 10000
	       call   _FileRead

		mov   rcx, r15
	       call   _FileClose



	; import images
		mov   ecx, 10000*28*28*4
	       call   _VirtualAlloc
		mov   qword[.testImages], rax
		mov   rdi, rax

		lea   rcx, [NNData.testImageFile]
	       call   _FileOpenRead
		mov   r15, rax

		mov   rcx, r15
		lea   rdx, [.junk]
		mov   r8d, 16
	       call   _FileRead


		xor   esi, esi
.nextImage:
		mov   rcx, r15
		lea   rdx, [.timage]
		mov   r8d, 28*28
	       call   _FileRead

		mov   eax, 255
	  vcvtsi2ss   xmm1, xmm1, eax
		xor   r8d, r8d
.nextPixel:
	      movzx   eax, byte[.timage+r8]
	  vcvtsi2ss   xmm0, xmm0, eax
	     vdivss   xmm0, xmm0, xmm1
	     vmovss   dword[rdi], xmm0
		add   rdi, 4
		add   r8d, 1
		cmp   r8d, 28*28
		 jb   .nextPixel


		add   esi, 1
		cmp   esi, 10000
		 jb   .nextImage

		mov   rcx, r15
	       call   _FileClose







	; import labels

		mov   ecx, 60000
	       call   _VirtualAlloc
		mov   qword[.trainLabels], rax

		lea   rcx, [NNData.trainLabelFile]
	       call   _FileOpenRead
		mov   r15, rax


		mov   rcx, r15
		lea   rdx, [.junk]
		mov   r8d, 8
	       call   _FileRead

		mov   rcx, r15
		mov   rdx, qword[.trainLabels]
		mov   r8d, 60000
	       call   _FileRead

		mov   rcx, r15
	       call   _FileClose



	; import images
		mov   ecx, 60000*28*28*4
	       call   _VirtualAlloc
		mov   qword[.trainImages], rax
		mov   rdi, rax

		lea   rcx, [NNData.trainImageFile]
	       call   _FileOpenRead
		mov   r15, rax

		mov   rcx, r15
		lea   rdx, [.junk]
		mov   r8d, 16
	       call   _FileRead


		xor   esi, esi
.nextTrainImage:
		mov   rcx, r15
		lea   rdx, [.timage]
		mov   r8d, 28*28
	       call   _FileRead

		mov   eax, 255
	  vcvtsi2ss   xmm1, xmm1, eax
		xor   r8d, r8d
.nextTrainPixel:
	      movzx   eax, byte[.timage+r8]
	  vcvtsi2ss   xmm0, xmm0, eax
	     vdivss   xmm0, xmm0, xmm1
	     vmovss   dword[rdi], xmm0
		add   rdi, 4
		add   r8d, 1
		cmp   r8d, 28*28
		 jb   .nextTrainPixel


		add   esi, 1
		cmp   esi, 60000
		 jb   .nextTrainImage

		mov   rcx, r15
	       call   _FileClose







		lea   rcx, [.net]
		lea   rdx, [.junk]
		mov   dword[rdx+4*0], 28*28
		mov   dword[rdx+4*1], 32
		mov   dword[rdx+4*2], 10
		mov   r8d, 2
	       call   NeuralNet_Create


call _GetTime
mov qword[nnetTime1], rax

		xor   r12d, r12d
.floop:
		xor   r13d, r13d
.eloop:
		xor   r14d, r14d
.BatchLoop:
		lea   rcx, [nnetrand]
	       call   Math_Rand_i
		mov   ecx, 60000
		xor   edx, edx
		div   rcx
		mov   r15, rdx

	; set output vector
		mov   eax, 0.0
		mov   rdi, qword[.net+NeuralNet.output.data]
		mov   ecx, 10
	  rep stosd
		mov   rax, qword[.trainLabels]
	      movzx   ecx, byte[rax+r15]
		mov   rax, qword[.net+NeuralNet.output.data]
		mov   dword[rax+4*rcx], 1.0
	; set input vector
		mov   rdi, qword[.net+NeuralNet.layers+0*sizeof.Layer+Layer.a.data]
	       imul   rsi, r15, 28*28*4
		add   rsi, qword[.trainImages]
		mov   ecx, 28*28
	  rep movsd
		lea   rcx, [.net]
	       call   NeuralNet_TrainOne
		add   r14d, 1
		cmp   r14d, 20
		 jb   .BatchLoop



		mov   eax, -1.0
	      vmovd   xmm0, eax
		mov   eax, 20
	  vcvtsi2ss   xmm1, xmm1, eax
	     vdivss   xmm0, xmm0, xmm1
		lea   rcx, [.net]
	       call   NeuralNet_UpdateTraining

		add   r13d, 1
		cmp   r13d, 400
		 jb   .eloop


		xor   r15d, r15d
		xor   r14d, r14d
.testnext:
		mov   rdi, qword[.net+NeuralNet.layers+0*sizeof.Layer+Layer.a.data]
	       imul   rsi, r15, 28*28*4
		add   rsi, qword[.testImages]
		mov   ecx, 28*28
	  rep movsd
		lea   rcx, [.net]
	       call   NeuralNet_Run

		mov   rdx, qword[.net+NeuralNet.output.data]
	     vmovss   xmm0, dword[rdx+4*0]
		xor   edi, edi
		mov   ecx, 1
	.lloop:
	    vcomiss   xmm0, dword[rdx+4*rcx]
	      cmovb   edi, ecx
	     vmaxss   xmm0, xmm0, dword[rdx+4*rcx]
		add   ecx, 1
		cmp   ecx, 10
		 jb   .lloop

		mov   rax, qword[.testLabels]
		cmp   dil, byte[rax+r15]
	       sete   cl
		add   r14d, ecx

		add   r15d, 1
		cmp   r15d, 10000
		 jb   .testnext

mov eax, 10000
sub eax, r14d
vcvtsi2sd xmm0, xmm0, eax
mov eax, 100
vcvtsi2sd xmm1, xmm1, eax
vdivsd xmm0, xmm0, xmm1
vmovq rax, xmm0
AD String, 'error: '
AD Double, rax
AD String, '%   '

call _GetTime
sub rax, qword[nnetTime1]
vcvtsi2sd xmm0, xmm0, rax
vcvtsi2sd xmm1, xmm1, qword[nnetFlops]
mov eax, 1000
vcvtsi2sd xmm2, xmm2, eax
vmulsd xmm0, xmm0, xmm2
vdivsd xmm1, xmm1, xmm0
movq rax, xmm1
AD Double, rax
AD String, ' MFLOPS'
AD NewLine



		add   r12d, 1
		cmp   r12d, 30
		 jb   .floop


		mov   rcx, qword[.trainLabels]
		mov   edx, 60000
	       call   _VirtualFree

		mov   rcx, qword[.trainImages]
		mov   edx, 60000*28*28*4
	       call   _VirtualFree


		mov   rcx, qword[.testLabels]
		mov   edx, 10000
	       call   _VirtualFree

		mov   rcx, qword[.testImages]
		mov   edx, 10000*28*28*4
	       call   _VirtualFree

		add   rsp, .localsize
		pop   r15 rdi rsi rbx rbp
		ret











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
	     vmovss   xmm0, dword[r8+4*rdx]
	     vandps   xmm1, xmm0, dqword[NNData.absmask]
	     vaddss   xmm1, xmm1, dword[NNData.one]
	     vaddss   xmm0, xmm0, xmm1
	     vaddss   xmm1, xmm1, xmm1
	     vrcpss   xmm1, xmm1, xmm1
	     vmulss   xmm0, xmm0, xmm1
add qword[nnetFlops], 6
	     vmovss   dword[rax+4*rdx], xmm0
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
	     vmovss   xmm0, dword[r8+4*rdx]
	     vandps   xmm0, xmm0, dqword[NNData.absmask]
	     vaddss   xmm0, xmm0, dword[NNData.one]
	     vmulss   xmm0, xmm0, xmm0
	     vaddss   xmm0, xmm0, xmm0
	     vrcpss   xmm0, xmm0, xmm0
add qword[nnetFlops], 5
	     vmovss   dword[rax+4*rdx], xmm0
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
	     vmovss   xmm0, dword[rcx+4*r9]
	     vsubss   xmm0, xmm0, dword[rdx+4*r9]
add qword[nnetFlops], 1
	     vmovss   dword[rax+4*r9], xmm0
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
	     vmovss   xmm0, dword[rcx+4*r9]
	     vaddss   xmm0, xmm0, dword[rdx+4*r9]
add qword[nnetFlops], 1
	     vmovss   dword[rax+4*r9], xmm0
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
	     vmovss   xmm0, dword[rcx+4*r9]
	     vmulss   xmm0, xmm0, dword[rdx+4*r9]
add qword[nnetFlops], 1
	     vmovss   dword[rax+4*r9], xmm0
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
	     vmulss   xmm1, xmm0, dword[rcx+4*r9]
	     vaddss   xmm1, xmm1, dword[rax+4*r9]
add qword[nnetFlops], 2
	     vmovss   dword[rax+4*r9], xmm1
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
	     vmovss   xmm0, dword[r8+4*r14]
		xor   r15d, r15d
.NextCol:
	     vmovss   xmm1, dword[r9+4*r15]
	   vfmaddss   xmm0, xmm1, dword[rdx+4*r15], xmm0
add qword[nnetFlops], 2
		add   r15d, 1
		cmp   r15d, dword[rcx+Matrix.colCnt]
		 jb   .NextCol
	     vmovss   dword[rax+4*r14], xmm0
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
	     vxorps   xmm0, xmm0, xmm0
		xor   r15d, r15d
		mov   r9, r8
.NextCol:
	     vmovss   xmm1, dword[r9]
	   vfmaddss   xmm0, xmm1, dword[rdx+4*r15], xmm0
add qword[nnetFlops], 2
		add   r9, qword[rcx+Matrix.stride]
		add   r15d, 1
		cmp   r15d, dword[rcx+Matrix.rowCnt]
		 jb   .NextCol
	     vmovss   dword[rax+4*r14], xmm0
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
	     vmovss   xmm2, dword[rcx+4*r14]
		xor   r15d, r15d
.NextCol:
	     vmovss   xmm0, dword[r8+4*r15]
	   vfmaddss   xmm0, xmm2,dword[rdx+4*r15], xmm0
	     vmovss   dword[r8+4*r15], xmm0
add qword[nnetFlops], 2
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
	     vmovss   xmm1, dword[r9+4*r15]
	     vmulss   xmm1, xmm1, xmm0
	     vaddss   xmm1, xmm1, dword[r8+4*r15]
	     vmovss   dword[r8+4*r15], xmm1
add qword[nnetFlops], 2
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


