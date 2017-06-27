





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
		mov   dword[rbx+Vector.elemCnt], eax
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
	       push   rbx
		mov   rbx, rcx
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
	; rcx address of NeuralNet
	       push   rbx rsi rdi
		mov   rbx, rcx

	; destroy output vector
		lea   rcx, [rbx+NeuralNet.output]
	       call   Vector_Destroy

	; destroy intermediate layers
		xor   edi, edi
.NextLayer:
	       imul   ecx, edi, sizeof.Layer
		lea   rcx, [rbx+NeuralNet.layers+rcx]
	       call   Layer_Destroy
		add   edi, 1
		cmp   edi, dword[rbx+NeuralNet.len]
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

	 vzeroupper
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

	 vzeroupper
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
;.matrix_A  Matrix
;.vector_x Vector
;.vector_b Vector
;.vector_y Vector

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


;TEST_SIZE=16*16
;                lea   rcx, [.matrix_A]
;                mov   edx, TEST_SIZE
;                mov   r8d, TEST_SIZE
;               call   Matrix_Create
;                lea   rcx, [.vector_x]
;                mov   edx, TEST_SIZE
;               call   Vector_Create
;                lea   rcx, [.vector_b]
;                mov   edx, TEST_SIZE
;               call   Vector_Create
;                lea   rcx, [.vector_y]
;                mov   edx, TEST_SIZE
;               call   Vector_Create
;
;                lea   rcx, [.matrix_A]
;               call   Matrix_Random
;                lea   rcx, [.vector_x]
;               call   Vector_Random
;                lea   rcx, [.vector_b]
;               call   Vector_Random
;
;call _GetTime
;mov qword[nnetTime1], rax
;
;mov r14d, 100000
;xor r15, r15
;.testloop:
;                lea   rax, [.vector_y]
;                lea   rcx, [.matrix_A]
;                lea   rdx, [.vector_x]
;                lea   r8, [.vector_b]
;               call   Matrix_TransposeDot
;
;                add  r15d, 1
;                cmp  r15d, r14d
;                 jb  .testloop
;call _GetTime
;sub rax, qword[nnetTime1]
;vcvtsi2sd xmm0, xmm0, rax
;mov rax, 2*TEST_SIZE*TEST_SIZE
;imul rax, r14
;vcvtsi2sd xmm1, xmm1, rax
;mov eax, 1000000
;vcvtsi2sd xmm2, xmm2, eax
;vmulsd xmm0, xmm0, xmm2
;vdivsd xmm1, xmm1, xmm0
;movq rax, xmm1
;AD Double, rax
;AD String, ' GFLOPS'
;AD NewLine
;                lea   rcx, [.matrix_A]
;               call   Matrix_Destroy
;                lea   rcx, [.vector_x]
;               call   Vector_Destroy
;                lea   rcx, [.vector_b]
;               call   Vector_Destroy
;                lea   rcx, [.vector_y]
;               call   Vector_Destroy




AD String, 'creating 784 -> 128 -> 64 -> 10  net'
AD NewLine


		lea   rcx, [.net]
		lea   rdx, [.junk]
		mov   dword[rdx+4*0], 28*28
		mov   dword[rdx+4*1], 256
		mov   dword[rdx+4*2], 64
		mov   dword[rdx+4*3], 10
		mov   r8d, 3
	       call   NeuralNet_Create


call _GetTime
mov qword[nnetTime1], rax
xor eax, eax
mov qword[nnetFlops], rax


NN_BATCH_SIZE = 20
NN_BATCH_RUNS = 1000
NN_TOTAL_RUNS = 400



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
	; compute gradient and add it to Ad and bd members
		lea   rcx, [.net]
	       call   NeuralNet_TrainOne

		add   r14d, 1
		cmp   r14d, NN_BATCH_SIZE
		 jb   .BatchLoop


	; add to A and b members -1.0/NN_BATCH_SIZE * Ad and bd members
	; also zero the Ad and bd members
		mov   eax, -0.3
	      vmovd   xmm0, eax
		mov   eax, NN_BATCH_SIZE
	  vcvtsi2ss   xmm1, xmm1, eax
	     vdivss   xmm0, xmm0, xmm1
		lea   rcx, [.net]
	       call   NeuralNet_UpdateTraining

		add   r13d, 1
		cmp   r13d, NN_BATCH_RUNS
		 jb   .eloop


	; now see how the net performes on testing data
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

	; find the biggest output and call this the digit that the net thinks it is
		mov   rdx, qword[.net+NeuralNet.output.data]
	     vmovss   xmm0, dword[rdx+4*0]
		xor   edi, edi		; edi = digit
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

lea eax, [r12+1]
vcvtsi2sd xmm0, xmm0, eax
mov eax, NN_BATCH_RUNS*NN_BATCH_SIZE
vcvtsi2sd xmm1, xmm1, eax
vmulsd xmm0, xmm0, xmm1
mov eax, 60000
vcvtsi2sd xmm1, xmm1, eax
vdivsd xmm0, xmm0, xmm1
vmovq rax, xmm0
AD String, 'epoch: '
AD Double, rax


mov eax, 10000
sub eax, r14d
vcvtsi2sd xmm0, xmm0, eax
mov eax, 100
vcvtsi2sd xmm1, xmm1, eax
vdivsd xmm0, xmm0, xmm1
vmovq rax, xmm0
AD String, '  error: '
AD Double, rax
AD String, '%   '

call _GetTime
sub rax, qword[nnetTime1]
vcvtsi2sd xmm0, xmm0, rax
vcvtsi2sd xmm1, xmm1, qword[nnetFlops]
mov eax, 1000000
vcvtsi2sd xmm2, xmm2, eax
vmulsd xmm0, xmm0, xmm2
vdivsd xmm1, xmm1, xmm0
movq rax, xmm1
AD Double, rax
AD String, ' GFLOPS'
AD NewLine



		add   r12d, 1
		cmp   r12d, NN_TOTAL_RUNS
		 jb   .floop

		lea   rcx, [.net]
	       call   NeuralNet_Destroy


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









EvalNet_Create:
	       push   rbx

		lea   rcx, [evalNet.Layer0]
		mov   edx, 640
		mov   r8d, 128
	       call   Layer_Create
		lea   rcx, [evalNet.Layer1]
		mov   edx, 128
		mov   r8d, 64
	       call   Layer_Create
		lea   rcx, [evalNet.Layer2]
		mov   edx, 64
		mov   r8d, 1
	       call   Layer_Create
		lea   rcx, [evalNet.output]
		mov   edx, 1
	       call   Vector_Create

		lea   rcx, [.file]
	       call   _FileOpenRead
		cmp   rax, -1
		jne   .WeGotData
.LoadRet:

		xor   eax, eax
		mov   qword[evalNet.errorTotal], rax
		mov   dword[evalNet.trainingCount], eax
		mov   qword[evalNet.trainingOverallCount], 1
		mov   qword[evalNet.errorOverallTotal], rax
		pop   rbx
		ret

.WeGotData:
		mov   rbx, rax

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer0.A.data]
		mov   r8d, 640*128*4
	       call   _FileRead
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer0.b.data]
		mov   r8d, 128*4
	       call   _FileRead

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer1.A.data]
		mov   r8d, 128*64*4
	       call   _FileRead
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer1.b.data]
		mov   r8d, 64*4
	       call   _FileRead

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer2.A.data]
		mov   r8d, 64*1*4
	       call   _FileRead
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer2.b.data]
		mov   r8d, 1*4
	       call   _FileRead

		mov   rcx, rbx
	       call   _FileClose

AD String, 'info string net data loaded'
AD NewLine

		jmp   .LoadRet



.file: db 'C:\Users\pc\train.data',0


EvalNet_Destroy:
	       push   rbx

		lea   rcx, [EvalNet_Create.file]
	       call   _FileOpenWrite
		mov   rbx, rax

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer0.A.data]
		mov   r8d, 640*128*4
	       call   _FileWrite
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer0.b.data]
		mov   r8d, 128*4
	       call   _FileWrite

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer1.A.data]
		mov   r8d, 128*64*4
	       call   _FileWrite
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer1.b.data]
		mov   r8d, 64*4
	       call   _FileWrite

		mov   rcx, rbx
		mov   rdx, [evalNet.Layer2.A.data]
		mov   r8d, 64*1*4
	       call   _FileWrite
		mov   rcx, rbx
		mov   rdx, [evalNet.Layer2.b.data]
		mov   r8d, 1*4
	       call   _FileWrite

		mov   rcx, rbx
	       call   _FileClose


		lea   rcx, [evalNet.Layer0]
	       call   Layer_Destroy
		lea   rcx, [evalNet.Layer1]
	       call   Layer_Destroy
		lea   rcx, [evalNet.Layer2]
	       call   Layer_Destroy
		lea   rcx, [evalNet.output]
	       call   Vector_Destroy
		pop   rbx
		ret




EvalNet_Run:
	; in: rbp position
	;     rbx state
	;     eax evaluation from Evaluate
	;          + is good for us
	;          - is bad for us
	;
	; out:
	;     eax evaluation from net


virtual at rsp
	   rq 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

	       push   rsi rdi r13 r14 r15
		sub   rsp, .localsize
		mov   r15d, eax

	       call   EvalNet_UpdateTraining


		mov   rsi, qword[evalNet.output.data]
	  vcvtsi2ss   xmm0, xmm0, r15d
		mov   eax, PawnValueMg
	  vcvtsi2ss   xmm1, xmm1, eax
	     vdivss   xmm0, xmm0, xmm1
	     vmovss   dword[rsi+4*0], xmm0

;AD String, 'goal: '
;AD Float, qword[rsi+4*0]





	; we have 640 nodes to initialize from the position
	;  if black is to move, flip the pieces
	;  so that the net always gets a position where white is to move

		mov   rdi, qword[evalNet.Layer0.a.data]
		mov   rsi, rdi
		mov   ecx, 10*64
		xor   eax, eax
	  rep stosd

		xor   ecx, ecx
.NextSquare:
	      movzx   eax, byte[rbp+Pos.board+rcx]
		mov   edx, dword[rbp+Pos.sideToMove]
		neg   edx
		and   edx, 0111000b
		xor   edx, ecx
	; edx = fipped square

	       test   eax, eax
		 jz   .Continue

		mov   r8d, dword[rbp+Pos.sideToMove]
		neg   r8d
		and   r8d, 8
		xor   eax, r8d
	; eax = flipped piece

		cmp   eax, 8*White+Pawn
		 je   .WhitePawn
		cmp   eax, 8*Black+Pawn
		 je   .BlackPawn
		cmp   eax, 8*White+Knight
		 je   .WhiteKnight
		cmp   eax, 8*Black+Knight
		 je   .BlackKnight
		cmp   eax, 8*White+Bishop
		 je   .WhiteBishop
		cmp   eax, 8*Black+Bishop
		 je   .BlackBishop
		cmp   eax, 8*White+Rook
		 je   .WhiteRook
		cmp   eax, 8*Black+Rook
		 je   .BlackRook
		cmp   eax, 8*White+Queen
		 je   .WhiteQueen
		cmp   eax, 8*Black+Queen
		 je   .BlackQueen
		cmp   eax, 8*White+King
		 je   .WhiteKing
		cmp   eax, 8*Black+King
		 je   .BlackKing
		jmp   .Continue


.WhiteKing:
		mov   dword[rsi+4*(64*0+rdx)], 1.0
		jmp   .Continue
.BlackKing:
		mov   dword[rsi+4*(64*1+rdx)], 1.0
		jmp   .Continue
.WhiteKnight:
		mov   dword[rsi+4*(64*2+rdx)], 1.0
		jmp   .Continue
.BlackKnight:
		mov   dword[rsi+4*(64*3+rdx)], 1.0
		jmp   .Continue

.WhitePawn:
		mov   dword[rsi+4*(64*4+rdx)], 1.0
		jmp   .Continue
.BlackPawn:
		mov   dword[rsi+4*(64*5+rdx)], 1.0
		jmp   .Continue
.WhiteBishop:
		mov   dword[rsi+4*(64*6+rdx)], 1.0
		jmp   .Continue
.BlackBishop:
		mov   dword[rsi+4*(64*7+rdx)], 1.0
		jmp   .Continue
.WhiteRook:
		mov   dword[rsi+4*(64*8+rdx)], 1.0
		jmp   .Continue
.BlackRook:
		mov   dword[rsi+4*(64*9+rdx)], 1.0
		jmp   .Continue
.WhiteQueen:
		mov   dword[rsi+4*(64*6+rdx)], 1.0
		mov   dword[rsi+4*(64*8+rdx)], 1.0
		jmp   .Continue
.BlackQueen:
		mov   dword[rsi+4*(64*7+rdx)], 1.0
		mov   dword[rsi+4*(64*9+rdx)], 1.0
		jmp   .Continue
.Continue:
		add   ecx, 1
		cmp   ecx, 64
		 jb   .NextSquare

	       call   EvalNet_TrainOne
		mov   ecx, +(VALUE_KNOWN_WIN-1)
		cmp   eax, ecx
	      cmovg   eax, ecx
		mov   ecx, -(VALUE_KNOWN_WIN-1)
		cmp   eax, ecx
	      cmovl   eax, ecx

		add   rsp, .localsize
		pop   r15 r14 r13 rdi rsi
		ret




EvalNet_TrainOne:

	       push   rbp rbx rsi rdi r13 r14 r15

		lea   rbp, [evalNet]

;                lea   rsi, [rbp+NeuralNet.layers]
;.ForwardProp:
;                lea   rax, [rsi+Layer.z]
;                lea   rcx, [rsi+Layer.A]
;                lea   rdx, [rsi+Layer.a]
;                lea   r8, [rsi+Layer.b]
;               call   Matrix_DotAdd
;                add   edi, 1
;                cmp   edi, dword[rbp+NeuralNet.len]
;                jae   .ForwardDone
;                lea   rax, [rsi+Layer.a+1*sizeof.Layer]
;                lea   rcx, [rsi+Layer.z]
;               call   Vector_Sigma
;                add   rsi, sizeof.Layer
;                jmp   .ForwardProp
;.ForwardDone:


		lea   rax, [rbp+EvalNet.Layer0.z]
		lea   rcx, [rbp+EvalNet.Layer0.A]
		lea   rdx, [rbp+EvalNet.Layer0.a]
		lea   r8, [rbp+EvalNet.Layer0.b]
	       call   Matrix_DotAdd
		lea   rax, [rbp+EvalNet.Layer1.a]
		lea   rcx, [rbp+EvalNet.Layer0.z]
	       call   Vector_Ramp

		lea   rax, [rbp+EvalNet.Layer1.z]
		lea   rcx, [rbp+EvalNet.Layer1.A]
		lea   rdx, [rbp+EvalNet.Layer1.a]
		lea   r8, [rbp+EvalNet.Layer1.b]
	       call   Matrix_DotAdd
		lea   rax, [rbp+EvalNet.Layer2.a]
		lea   rcx, [rbp+EvalNet.Layer1.z]
	       call   Vector_Ramp

		lea   rax, [rbp+EvalNet.Layer2.z]
		lea   rcx, [rbp+EvalNet.Layer2.A]
		lea   rdx, [rbp+EvalNet.Layer2.a]
		lea   r8, [rbp+EvalNet.Layer2.b]
	       call   Matrix_DotAdd

;                lea   rax, [rsi+Layer.e]
;                lea   rcx, [rsi+Layer.z]
;               call   Vector_Sigma

		lea   rax, [rbp+EvalNet.Layer2.e]
		lea   rcx, [rbp+EvalNet.Layer2.z]
	       call   Vector_Identity

		mov   r15, [rbp+EvalNet.Layer2.e.data]


;AD String, ' ouput: '
;AD Float, qword[r15+4*0]


	     vmovss   xmm0, dword[r15+4*0]
		mov   eax, PawnValueMg
	  vcvtsi2ss   xmm1, xmm1, eax
	     vmulss   xmm0, xmm0, xmm1
	  vcvtss2si   r13d, xmm0

		mov   rax, [rbp+EvalNet.output.data]
	  vcvtss2sd   xmm1, xmm1, dword[rax+4*0]
	  vcvtss2sd   xmm0, xmm0, dword[r15+4*0]
	     vsubsd   xmm1, xmm1, xmm0
		mov   rax, 0x7FFFFFFFFFFFFFFF
	       movq   xmm2, rax
	     vandpd   xmm1, xmm1, xmm2
	     vaddsd   xmm0, xmm1, qword[rbp+EvalNet.errorTotal]
	     vmovsd   qword[rbp+EvalNet.errorTotal], xmm0

	     vaddsd   xmm0, xmm1, qword[rbp+EvalNet.errorOverallTotal]
	     vmovsd   qword[rbp+EvalNet.errorOverallTotal], xmm0

		add   dword[rbp+EvalNet.trainingCount], 1
		add   qword[rbp+EvalNet.trainingOverallCount], 1


;AD String, ' errorTotal: '
;AD Double, qword[rbp+EvalNet.errorTotal]
;AD String, ' trainingCount: '
;AD Int32, qword[rbp+EvalNet.trainingCount]
;AD NewLine


;                lea   rax, [rsi+Layer.e]
;                lea   rcx, [rsi+Layer.e]
;                lea   rdx, [rbp+NeuralNet.output]
;               call   Vector_Subtract

		lea   rax, [rbp+EvalNet.Layer2.e]
		lea   rcx, [rbp+EvalNet.Layer2.e]
		lea   rdx, [rbp+EvalNet.output]
	       call   Vector_Subtract

		lea   rax, [rbp+EvalNet.Layer2.z]
		lea   rcx, [rbp+EvalNet.Layer2.z]
	       call   Vector_IdentityPrime

	    ;    lea   rax, [rsi+Layer.e]
	    ;    lea   rcx, [rsi+Layer.e]
	    ;    lea   rdx, [rsi+Layer.z]
	    ;   call   Vector_Times

;                mov   edi, dword[rbp+NeuralNet.len]
;                sub   edi, 1
;.BackwardProp:
;                sub   rsi, sizeof.Layer
;                lea   rax, [rsi+Layer.z]
;                lea   rcx, [rsi+Layer.z]
;               call   Vector_SigmaPrime
;                lea   rax, [rsi+Layer.e]
;                lea   rcx, [rsi+Layer.A+1*sizeof.Layer]
;                lea   rdx, [rsi+Layer.e+1*sizeof.Layer]
;               call   Matrix_TransposeDot
;                lea   rax, [rsi+Layer.e]
;                lea   rcx, [rsi+Layer.e]
;                lea   rdx, [rsi+Layer.z]
;               call   Vector_Times
;                sub   edi, 1
;                jnz   .BackwardProp



		lea   rax, [rbp+EvalNet.Layer1.z]
		lea   rcx, [rbp+EvalNet.Layer1.z]
	       call   Vector_RampPrime
		lea   rax, [rbp+EvalNet.Layer1.e]
		lea   rcx, [rbp+EvalNet.Layer2.A]
		lea   rdx, [rbp+EvalNet.Layer2.e]
	       call   Matrix_TransposeDot
		lea   rax, [rbp+EvalNet.Layer1.e]
		lea   rcx, [rbp+EvalNet.Layer1.e]
		lea   rdx, [rbp+EvalNet.Layer1.z]
	       call   Vector_Times


		lea   rax, [rbp+EvalNet.Layer0.z]
		lea   rcx, [rbp+EvalNet.Layer0.z]
	       call   Vector_RampPrime
		lea   rax, [rbp+EvalNet.Layer0.e]
		lea   rcx, [rbp+EvalNet.Layer1.A]
		lea   rdx, [rbp+EvalNet.Layer1.e]
	       call   Matrix_TransposeDot
		lea   rax, [rbp+EvalNet.Layer0.e]
		lea   rcx, [rbp+EvalNet.Layer0.e]
		lea   rdx, [rbp+EvalNet.Layer0.z]
	       call   Vector_Times




;                xor   edi, edi
;                lea   rsi, [rbp+NeuralNet.layers]
;.Gradient:
;                lea   rax, [rsi+Layer.Ad]
;                lea   rcx, [rsi+Layer.e]
;                lea   rdx, [rsi+Layer.a]
;               call   Matrix_AddToOuterTimes
;                lea   rax, [rsi+Layer.bd]
;                lea   rcx, [rsi+Layer.bd]
;                lea   rdx, [rsi+Layer.e]
;               call   Vector_Add
;                add   edi, 1
;                add   rsi, sizeof.Layer
;                cmp   edi, dword[rbp+NeuralNet.len]
;                 jb   .Gradient


		lea   rax, [rbp+EvalNet.Layer0.Ad]
		lea   rcx, [rbp+EvalNet.Layer0.e]
		lea   rdx, [rbp+EvalNet.Layer0.a]
	       call   Matrix_AddToOuterTimes
		lea   rax, [rbp+EvalNet.Layer0.bd]
		lea   rcx, [rbp+EvalNet.Layer0.bd]
		lea   rdx, [rbp+EvalNet.Layer0.e]
	       call   Vector_Add

		lea   rax, [rbp+EvalNet.Layer1.Ad]
		lea   rcx, [rbp+EvalNet.Layer1.e]
		lea   rdx, [rbp+EvalNet.Layer1.a]
	       call   Matrix_AddToOuterTimes
		lea   rax, [rbp+EvalNet.Layer1.bd]
		lea   rcx, [rbp+EvalNet.Layer1.bd]
		lea   rdx, [rbp+EvalNet.Layer1.e]
	       call   Vector_Add

		lea   rax, [rbp+EvalNet.Layer2.Ad]
		lea   rcx, [rbp+EvalNet.Layer2.e]
		lea   rdx, [rbp+EvalNet.Layer2.a]
	       call   Matrix_AddToOuterTimes
		lea   rax, [rbp+EvalNet.Layer2.bd]
		lea   rcx, [rbp+EvalNet.Layer2.bd]
		lea   rdx, [rbp+EvalNet.Layer2.e]
	       call   Vector_Add


		mov   eax, r13d
	 vzeroupper
		pop   r15 r14 r13 rdi rsi rbx rbp
		ret





EvalNet_UpdateTraining:

virtual at rsp
  .factor   rd 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

	       push   rbp rbx rsi rdi r15
		sub   rsp, .localsize

		lea   rbp, [evalNet]

		mov   eax, dword[rbp+EvalNet.trainingCount]
		cmp   eax, 100
		 jb   .Return

;          vcvtsi2sd   xmm0, xmm0, dword[rbp+EvalNet.trainingCount]
;             vmovsd   xmm1, qword[rbp+EvalNet.errorTotal]
;             vdivsd   xmm1, xmm1, xmm0
;              vmovq   qword[rbp+EvalNet.errorOverallTotal], xmm1
;AD String, 'avg error: '
;AD Double, rax



		mov   eax, dword -0.003
	      vmovd   xmm0, eax
	  vcvtsi2ss   xmm1, xmm1, dword[rbp+EvalNet.trainingCount]
	     vdivss   xmm0, xmm0, xmm1
	     vmovss   dword[.factor], xmm0

;mov eax, dword[.factor]
;AD String, ' factor: '
;AD Float, rax
;AD NewLine

		xor   edi, edi
		lea   rsi, [rbp+NeuralNet.layers]

irps i, 0 1 2 {

		lea   rax, [rbp+EvalNet.Layer#i#.Ad]
		lea   rcx, [rbp+EvalNet.Layer#i#.Ad]
	       call   Matrix_Clamp
		lea   rax, [rbp+EvalNet.Layer#i#.A]
		lea   rcx, [rbp+EvalNet.Layer#i#.Ad]
	     vmovss   xmm0, dword[.factor]
	       call   Matrix_MulAddTo
		lea   rax, [rbp+EvalNet.Layer#i#.A]
		lea   rcx, [rbp+EvalNet.Layer#i#.A]
	       call   Matrix_Tenuate
		lea   rax, [rbp+EvalNet.Layer#i#.Ad]
	       call   Matrix_Zero


		lea   rax, [rbp+EvalNet.Layer#i#.bd]
		lea   rcx, [rbp+EvalNet.Layer#i#.bd]
	       call   Vector_Clamp
		lea   rax, [rbp+EvalNet.Layer#i#.b]
		lea   rcx, [rbp+EvalNet.Layer#i#.bd]
	     vmovss   xmm0, dword[.factor]
	       call   Vector_MulAddTo
		lea   rax, [rbp+EvalNet.Layer#i#.b]
		lea   rcx, [rbp+EvalNet.Layer#i#.b]
	       call   Vector_Tenuate
		lea   rax, [rbp+EvalNet.Layer#i#.bd]
	       call   Vector_Zero

}
		xor   eax, eax
		mov   qword[rbp+EvalNet.errorTotal], rax
		mov   dword[rbp+EvalNet.trainingCount], eax

.Return:
		add   rsp, .localsize
		pop   r15 rdi rsi rbx rbp
		ret



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
.absmask   dd 8 dup 0x7FFFFFFF
.signmask  dd 8 dup 0x80000000
.one	   dd 8 dup 1.0
.mone	   dd 8 dup -1.0
.eight	   dd 8 dup 10.0

.tfactor   dd 8 dup -0.1

.a dq 0.5
.b dq 0.1
.testImageFile	db 'guts\testIM.ubyte',0
.testLabelFile	db 'guts\testLB.ubyte',0
.trainImageFile db 'guts\trainIM.ubyte',0
.trainLabelFile db 'guts\trainLB.ubyte',0



