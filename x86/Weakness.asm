
Weakness_AdjustTime:
        ; bring maximum time closer to optimumtime
         _vcvtsi2sd   xmm0, xmm0, dword[time.optimumTime]
         _vcvtsi2sd   xmm1, xmm1, dword[time.maximumTime]
            _vmovsd   xmm2, qword[weakness.targetLoss]
            _vmovsd   xmm3, qword[.a]
            _vmulsd   xmm0, xmm0, xmm2
            _vmulsd   xmm1, xmm1, xmm3
            _vaddsd   xmm0, xmm0, xmm1
            _vaddsd   xmm2, xmm2, xmm3
            _vdivsd   xmm0, xmm0, xmm2
         _vcvtsd2si   eax, xmm0
                mov   dword[time.maximumTime], eax
                ret

             calign   8
.a dq 12.0


Weakness_SetMultiPV:
    ; in: rbp address of position  root moves vector is assumed to be sorted
    ; out: set weakness.multipv

virtual at rsp
  .bestscore   rq 1
  .worstscore  rq 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

               push   rbx rsi rdi
                sub   rsp, .localsize

                mov   edi, dword[weakness.multiPV]
                mov   rsi, qword[rbp+Pos.rootMovesVec.table]
               imul   ebx, edi, sizeof.RootMove
                add   rbx, rsi
             Assert   be, rbx, qword[rbp+Pos.rootMovesVec.ender], 'grave error in Weakness_SetMultiPV'
        ; rbx = end of moves to consider

                mov   ecx, dword[rsi+RootMove.score]
               call   Weakness_ScoreToDouble
            _vmovsd   qword[.bestscore], xmm0
.Loop:
                add   rsi, sizeof.RootMove
                cmp   rsi, rbx
                jae   .LoopDone
                mov   ecx, dword[rsi+RootMove.score]
                cmp   ecx, -VALUE_INFINITE
                jne   .Loop
.Return:
                add   rsp, .localsize
                pop   rdi rsi rbx
                ret

.LoopDone:
               call   Weakness_ScoreToDouble
            _vmovsd   qword[.worstscore], xmm0

    ; if difference falls out side of (1.8*target, 2.2*target), adjust
                lea   rcx, [rbp+Pos.rootMovesVec]
               call   RootMovesVec_Size
                xor   edx, edx
            _vmovsd   xmm0, qword[.bestscore]
            _vmovsd   xmm2, qword[weakness.targetLoss]
            _vsubsd   xmm0, xmm0, qword[.worstscore]
            _vmulsd   xmm1, xmm2, qword[.lower]
            _vmulsd   xmm2, xmm2, qword[.upper]
           _vcomisd   xmm2, xmm0
                sbb   edi, edx
              cmovs   edi, edx
           _vcomisd   xmm0, xmm1
                adc   edi, edx
                cmp   edi, eax
              cmova   edi, eax
                mov   dword[weakness.multiPV], edi
                jmp   .Return

             calign   8
.lower dq 1.8
.upper dq 2.2


Weakness_ScoreToDouble:
    ; convert from internal score ecx to something reasonable
    ;   mate scores have bigger distance between them
    ;             x
    ;  xmm0 = ---------
    ;         a*x^2 + 1
         _vcvtsi2sd   xmm0, xmm0, ecx
            _vmulsd   xmm1, xmm0, xmm0
            _vmulsd   xmm1, xmm1, qword[.a]
            _vaddsd   xmm1, xmm1, qword[constd._1p0]
            _vdivsd   xmm0, xmm0, xmm1
                ret

             calign   8
.a: dq -8.65052e-10




Weakness_PickMove:
        ; in: rbp address of position  root moves vector is assumed to be sorted
        ;     weakness.averageCpLoss  is weakness level
        ;     weakness.multiPv         is max moves to consider
        ; out: the root moves vector will have the top move swapped with a lower one


virtual at rsp
  .weights  rq MAX_MOVES
  .rootMove rb sizeof.RootMove
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

               push   rbx rsi rdi r14 r15
         _chkstk_ms   rsp, .localsize
                sub   rsp, .localsize

        ; assign weights based on target and accumulate them into xmm5
                mov   rsi, qword[rbp+Pos.rootMovesVec.table]
                mov   ecx, dword[rsi+RootMove.score]
               call   Weakness_ScoreToDouble
                lea   rdx, [.weights]
            _vmovsd   xmm5, qword[weakness.targetLoss]
            _vsubsd   xmm4, xmm0, xmm5	; xmm4 = target score d
            _vxorps   xmm8, xmm8, xmm8
            _vmulsd   xmm7, xmm5, xmm5	; xmm7 = d^2
           _vsqrtsd   xmm5, xmm5, xmm5
            _vaddsd   xmm5, xmm5, xmm5	; xmm5 = 2*Sqrt[d]
            _vaddsd   xmm6, xmm7, qword[.mind]  ; xmm6 = d^2+e
               imul   ebx, dword[weakness.multiPV], sizeof.RootMove
                add   rbx, qword[rbp+Pos.rootMovesVec.table]	     ; rbx = end of moves to consider
    @1:
                mov   ecx, dword[rsi+RootMove.score]
                cmp   ecx, -VALUE_INFINITE
              cmove   ecx, dword[rsi+RootMove.prevScore]
               call   Weakness_ScoreToDouble
            _vsubsd   xmm0, xmm0, xmm4
            _vmulsd   xmm0, xmm0, xmm0
            _vmulsd   xmm0, xmm0, xmm5
            _vaddsd   xmm0, xmm0, xmm6
            _vdivsd   xmm1, xmm7, xmm0
            _vaddsd   xmm8, xmm8, xmm1
            _vmovsd   qword[rdx], xmm8
                add   rsi, sizeof.RootMove
                add   rdx, 8
                cmp   rsi, rbx
                 jb   @1b

        ; get a random number in [0,xmm8)
               call   Os_GetTime
                xor   rax, rdx
                lea   rcx, [weakness.prng]
                xor   qword[rcx], rax
               call   Math_Rand_d
            _vmulsd   xmm0, xmm0, xmm8

        ; find the move corresponding to xmm0
                lea   rdx, [.weights]
                mov   rsi, qword[rbp+Pos.rootMovesVec.table]
.FindMoveLoop:
           _vcomisd   xmm0, qword[rdx]
                jbe   .Found
                add   rsi, sizeof.RootMove
                add   rdx, 8
                cmp   rsi, rbx
                 jb   .FindMoveLoop
        ; if we get here, something bad happened so don't swap any lines
                jmp   .Return

.Found:
        ; swap that move with the top move
                mov   ecx, (sizeof.RootMove/4) - 1
                mov   rdi, qword[rbp+Pos.rootMovesVec.table]
	@1:
                mov   eax, dword[rsi+4*rcx]
                mov   edx, dword[rdi+4*rcx]
                mov   dword[rdi+4*rcx], eax
                mov   dword[rsi+4*rcx], edx
                sub   ecx, 1
                jns   @1b
.Return:
                add   rsp, .localsize
                pop   r15 r14 rdi rsi rbx
                ret

             calign   8
.mind: dq 0.00000001


Weakness_Create:
                mov   byte[weakness.enabled], 0
                mov   ecx, 1000

Weakness_SetElo:
        ; in: ecx target Elo
        ;  should set targetLoss
         _vcvtsi2sd   xmm0, xmm0, ecx
                lea   rcx, [.Table]
                lea   rdx, [.TableEnd]
               call   Math_Lerp
            _vmovsd   qword[weakness.targetLoss], xmm0
                ret

             calign   16
.Table: 		; tunings at 120 + 0.4 tc
 dq    0.0, 200.0
 dq 1473.0, 100.0	; tarrasch toy engine
 dq 2312.0,  64.0	; sungorus
 dq 3125.0,  13.0	; houdini 1.5a
 dq 3300.0,   0.1
.TableEnd:
