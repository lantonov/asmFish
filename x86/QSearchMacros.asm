
macro QSearch PvNode, InCheck
        ; in:
        ;  rbp: address of Pos struct in thread struct
        ;  rbx: address of State
        ;  ecx: alpha
        ;  edx: beta
        ;  r8d: depth


virtual at rsp
  .tte	     rq 1      ; 0
  .ltte      rq 1      ; 8
  .searchFxn rq 1      ; 16
  .stage rq 1

  .ttMove	  rd 1 ; 24
  .ttValue	  rd 1
  .ttDepth	  rd 1
  .move 	  rd 1
  .excludedMove   rd 1
  .bestMove	  rd 1
  .ext		  rd 1
  .newDepth	  rd 1
  .predictedDepth rd 1
  .moveCount	  rd 1
  .oldAlpha	  rd 1
  .alpha	  rd 1
  .beta 	  rd 1
  .depth	  rd 1
  .bestValue	  rd 1
  .value	  rd 1
  .evalu 	  rd 1
  .nullValue	  rd 1
  .futilityValue  rd 1
  .futilityBase   rd 1

  .inCheck		   rb 1   ;  104
                           rb 1   ;  105
  .singularExtensionNode   rb 1   ;  106
  .improving		   rb 1   ;  107
  .captureOrPromotion	   rb 1   ;  108
  .dangerous		   rb 1   ;  109
  .doFullDepthSearch	   rb 1   ;  110
  .cutNode		   rb 1   ;  111
  .ttHit		   rb 1
			   rb 1
			   rb 1
			   rb 1
			   rb 1
			   rb 1
			   rb 1
			   rb 1
if PvNode = 1
  ._pv		   rd MAX_PLY+1
end if

  .lend rb 0

end virtual
.localsize = ((.lend-rsp+15) and (-16))


	       push   rbx rsi rdi r12 r13 r14 r15
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

if PvNode = 1
  if InCheck = 1
Display 2, "QSearch<1,1>(alpha=%i1, beta=%i2, depth=%i8) called%n"
  else
Display 2, "QSearch<1,0>(alpha=%i1, beta=%i2, depth=%i8) called%n"
  end if
else
  if InCheck = 1
Display 2, "QSearch<0,1>(alpha=%i1, beta=%i2, depth=%i8) called%n"
  else
Display 2, "QSearch<0,0>(alpha=%i1, beta=%i2, depth=%i8) called%n"
  end if
end if

		mov   dword[.alpha], ecx
		mov   dword[.beta], edx
		mov   dword[.depth], r8d
             Assert   le, r8d, 0, 'assertion depth<=0 failed in qsearch'

	      movzx   eax, byte[rbx-1*sizeof.State+State.ply]
		add   eax, 1
		xor   edx, edx
	if PvNode = 1
		lea   r8, [._pv]
		mov   r9, qword[rbx+State.pv]
		mov   dword[.oldAlpha], ecx
		mov   qword[rbx+1*sizeof.State+State.pv], r8
		mov   dword[r9], edx
	end if
                mov   dword[.moveCount], 2
		mov   dword[.bestMove], edx
		mov   dword[rbx+State.currentMove], edx
		mov   byte[rbx+State.ply], al

	; check for instant draw or max ply
	      movzx   edx, word[rbx+State.rule50]
	      movzx   rcx, word[rbx+State.pliesFromNull]
		mov   r8, qword[rbx+State.key]
		cmp   eax, MAX_PLY
		jae   .AbortSearch_PlyBigger

	; ss->ply < MAX_PLY holds at this point, so if we should
	;   go to .AbortSearch_PlySmaller if a draw is detected
	  PosIsDraw   .AbortSearch_PlySmaller, .CheckDraw_Cold, .CheckDraw_ColdRet

	if InCheck = 1
		mov   r12d, DEPTH_QS_CHECKS
		mov   dword[.ttDepth],r12d
	else
		mov   eax, DEPTH_QS_CHECKS
		mov   r12d, DEPTH_QS_NO_CHECKS
		cmp   eax, dword[.depth]
	     cmovle   r12d, eax
		mov   dword[.ttDepth], r12d
	end if

	; transposition table lookup
		mov   rcx, qword[rbx+State.key]
		sub   r12d, 1
	       call   MainHash_Probe

		mov   qword[.tte], rax
		mov   qword[.ltte], rcx
		mov   byte[.ttHit], dl
		mov   rdi, rcx
		sar   rdi, 48
	      movsx   eax, ch
		sub   r12d, eax
		sar   r12d, 31
	; r12d = 0 if tte.depth <  ttDepth
	;      =-1 if tte.depth >= ttDepth
		shr   rcx, 16
		mov   r13d, edx
	      movzx   ecx, cx
		mov   dword[.ttMove], ecx
		mov   dword[.ttValue], edi

		lea   r8d, [rdi+VALUE_MATE_IN_MAX_PLY]
	       test   edx, edx
		 jz   .DontReturnTTValue

		mov   eax, edi
		sub   eax, dword[.beta]
		sar   eax, 31
	; eax = 0 if ttValue<beta
	;     =-1 if ttvalue>=beta
		cmp   edi, VALUE_NONE
		 je   .DontReturnTTValue
		cmp   r8d, 2*VALUE_MATE_IN_MAX_PLY
		jae   .ValueFromTT
.ValueFromTTRet:
	if PvNode = 0
		add   eax, 2
	; eax = 2 if ttValue<beta     ie BOUND_UPPER
	;     = 1 if ttvalue>=beta    ie BOUND_LOWER
		and   eax, r12d
	       test   al, byte[.ltte+MainHashEntry.genBound]
		mov   eax, edi
		jnz   .Return
	end if

.DontReturnTTValue:

	; Evaluate the position statically
	;  r13d = ttHit

	if InCheck = 1
		mov   eax, -VALUE_INFINITE
		mov   dword[rbx+State.staticEval], VALUE_NONE
		mov   dword[.bestValue], eax
		mov   dword[.futilityBase], eax
	else
		mov   edx, dword[rbx-1*sizeof.State+State.currentMove]
	       test   r13d, r13d
		 jz   .StaticValueNoTTHit
.StaticValueYesTTHit:
	      movsx   eax, word[.ltte+MainHashEntry.eval_]
		cmp   eax, VALUE_NONE
		jne   @f
	       call   Evaluate
	@@:
                xor   ecx, ecx
		mov   dword[rbx+State.staticEval], eax
		cmp   edi, eax
	       setg   cl
		add   ecx, 1
	; ecx = 2 if ttValue > bestValue   ie BOUND_LOWER
	;     = 1 if ttValue <=bestValue   ie BOUND_UPPER
		cmp   edi, VALUE_NONE
		 je   .StaticValueDone
	       test   cl, byte[.ltte+MainHashEntry.genBound]
	     cmovnz   eax, edi
		jmp   .StaticValueDone

.StaticValueNoTTHit:
		mov   eax, dword[rbx+State.staticEval-1*sizeof.State]
		neg   eax
		add   eax, 2*Eval_Tempo
		cmp   edx, MOVE_NULL
		 je   @f
	       call   Evaluate
	@@:
                mov   dword[rbx+State.staticEval], eax
.StaticValueDone:
		mov   dword[.bestValue], eax

	; Return immediately if static value is at least beta
		cmp   eax, dword[.beta]
		jge   .ReturnStaticValue


    if PvNode = 1
		mov   ecx, dword[.alpha]
		cmp   ecx, eax
	      cmovl   ecx, eax
		mov   dword[.alpha], ecx
    end if
		add   eax, 128
		mov   dword[.futilityBase], eax

    end if ; InCheck = 1



	; initialize move picker
		mov   ecx, dword[.ttMove]
	if InCheck = 1
		lea   r15, [MovePick_ALL_EVASIONS]
		lea   r14, [MovePick_EVASIONS]
	else
		mov   edx, dword[.depth]
		lea   r15, [MovePick_QCAPTURES_CHECKS_GEN]
		lea   r14, [MovePick_QSEARCH_WITH_CHECKS]
		cmp   edx, DEPTH_QS_NO_CHECKS
		 jg   .MovePickInitGo
		lea   r15, [MovePick_QCAPTURES_NO_CHECKS_GEN]
		lea   r14, [MovePick_QSEARCH_WITHOUT_CHECKS]
		cmp   edx, DEPTH_QS_RECAPTURES
		 jg   .MovePickInitGo
		lea   r15, [MovePick_RECAPTURES_GEN]
		mov   eax, dword[rbx-1*sizeof.State+State.currentMove]
		and   eax, 63
		mov   dword[rbx+State.recaptureSquare], eax
		xor   edi, edi
		jmp   .MovePickNoTTMove
	end if
    .MovePickInitGo:
		mov   edi, ecx
	       test   ecx, ecx
		 jz   .MovePickNoTTMove
	       call   Move_IsPseudoLegal
	       test   rax, rax
	      cmovz   edi, eax
	     cmovnz   r15, r14
    .MovePickNoTTMove:
		mov   dword[rbx+State.ttMove], edi
		mov   qword[rbx+State.stage], r15

	     calign   8
.MovePickLoop:
                xor   esi, esi
	GetNextMove
		mov   dword[.move], eax
		mov   ecx, eax
	       test   eax, eax
		 jz   .MovePickDone

                sub   [.moveCount], 1

	; check for check and get address of search function
	       call   Move_GivesCheck
		mov   byte[rbx+State.givesCheck], al
	        mov   r13d, eax
	if PvNode = 1
		lea   rdx, [QSearch_Pv_NoCheck]
		lea   rcx, [QSearch_Pv_InCheck]
	else
		lea   rdx, [QSearch_NonPv_NoCheck]
		lea   rcx, [QSearch_NonPv_InCheck]
	end if
	       test   eax, eax
	     cmovnz   rdx, rcx
		mov   qword[.searchFxn], rdx



		mov   ecx, dword[.move]
		mov   edi, dword[.bestValue]
		mov   esi, ecx
		shr   esi, 12

		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63			      ; r8d = from
	      movzx   eax, byte[rbp+Pos.board+r8]     ; r14d = from piece
		mov   r14d, eax

		mov   r9d, ecx
		and   r9d, 63			       ; r9d = to
	      movzx   r15d, byte[rbp+Pos.board+r9]     ; r15d = to piece

		; futility pruning
	if InCheck = 0
		mov   r12d, dword[.futilityBase]
	       test   r13d, r13d
		jnz   .SkipFutilityPruning
		and   eax, 7
		cmp   r12d, -VALUE_KNOWN_WIN
		jle   .SkipFutilityPruning

		mov   edx, dword[rbp+Pos.sideToMove]
		neg   edx
		cmp   eax, Pawn
		 je   .CheckAdvancedPawnPush
.DoFutilityPruning:


		mov   edx, dword[PieceValue_EG+4*r15]
		add   edx, r12d
		cmp   edx, dword[.alpha]
		jle   .ContinueFromFutilityValue
		cmp   r12d, dword[.alpha]
		jle   .ContinueFromFutilityBase
.SkipFutilityPruning:
	end if


	; do not search moves with negative see value
	if InCheck = 0
		lea   eax, [rsi-MOVE_TYPE_PROM]
		shl   r14d, 9
		shl   r15d, 9
		cmp   eax, 4
		 jb   .DontContinue
	else
	     Assert   ne, esi, MOVE_TYPE_CASTLE, 'castling encountered in qsearch<InCheck=true>'

		mov   eax, VALUE_MATED_IN_MAX_PLY
                sub   eax, edi
		shl   r14d, 9
                mov   edx, dword[.moveCount]
		shl   r15d, 9
		jnz   .DontContinue
                 or   edx, dword[.depth]
		cmp   esi, MOVE_TYPE_PROM
		jae   .DontContinue	   ; catch MOVE_TYPE_EPCAP
               test   eax, edx
                jns   .DontContinue
	end if


	SeeSignTest   .DontContinue
		mov   ecx, dword[.move]
	       test   eax, eax
		 jz   .MovePickLoop

.DontContinue:


	; speculative prefetch
		mov   edx, ecx
		and   edx, 63				; edx = to
		shr   ecx, 6
		and   ecx, 63				; ecx = from
		mov   rax, qword[rbx+State.key]
		xor   rax, qword[Zobrist_side]
		xor   rax, qword[Zobrist_Pieces+r14+8*rcx]
		xor   rax, qword[Zobrist_Pieces+r14+8*rdx]
		xor   rax, qword[Zobrist_Pieces+r15+8*rdx]
		and   rax, qword[mainHash.mask]
		shl   rax, 5
		add   rax, qword[mainHash.table]
	prefetchnta   [rax]


	; check for legality
		mov   ecx, dword[.move]
	       call   Move_IsLegal
                lea   edx, [rax+1]
                add   dword[.moveCount], edx
	       test   eax, eax
		 jz   .MovePickLoop

	; make the move
		mov   ecx, dword[.move]
		mov   dword[rbx+State.currentMove], ecx
		mov   rsi, qword[.searchFxn]
	       call   Move_Do__QSearch

	; search the move
		mov   ecx, dword[.beta]
		neg   ecx
		mov   edx, dword[.alpha]
		neg   edx
		mov   r8d, dword[.depth]
		sub   r8d, 1
	       call   rsi
		neg   eax
		mov   edi, eax
		mov   dword[.value], eax

	; undo the move
		mov   ecx, dword[.move]
	       call   Move_Undo

	; check for new best move
		cmp   edi, dword[.bestValue]
		jle   .MovePickLoop
		mov   dword[.bestValue], edi
		cmp   edi, dword[.alpha]
		jle   .MovePickLoop

     if PvNode = 1
		mov   ecx, dword[.move]
		mov   r8, qword[rbx+0*sizeof.State+State.pv]
		mov   r9, qword[rbx+1*sizeof.State+State.pv]
		xor   eax, eax
		mov   dword[r8], ecx
		add   r8, 4
	       test   r9, r9
		 jz   .pv_copy_end
	.pv_copy_loop:
		mov   eax, dword[r9]
		add   r9, 4
	.pv_copy_end:
		mov   dword[r8], eax
		add   r8, 4
	       test   eax, eax
		jnz   .pv_copy_loop

		cmp   edi, dword[.beta]
		jge   .FailHigh
		mov   dword[.alpha], edi
		mov   dword[.bestMove], ecx

		jmp   .MovePickLoop
    end if




.FailHigh:
		mov   r9, qword[rbx+State.key]
		mov   r8, qword[.tte]
		shr   r9, 48
		mov   edx, edi
		lea   ecx, [rdi+VALUE_MATE_IN_MAX_PLY]
		cmp   ecx, 2*VALUE_MATE_IN_MAX_PLY
		jae   .FailHighValueToTT
.FailHighValueToTTRet:
		mov   eax, dword[.move]
      MainHash_Save   .ltte, r8, r9w, edx, BOUND_LOWER, byte[.ttDepth], eax, word[rbx+State.staticEval]
		mov   eax, edi
		jmp   .Return

.FailHighValueToTT:
	      movzx   edx, byte[rbx+State.ply]
		mov   eax, edi
		sar   eax, 31
		xor   edx, eax
		sub   edx, eax
		add   edx, edi
		jmp   .FailHighValueToTTRet


.MovePickDone:
                mov   r9, qword[rbx+State.key]
                mov   edi, dword[.bestValue]

  if USE_VARIETY = 1
                mov   rax, qword[rbp-Thread.rootPos+Thread.randSeed]
                mov   rdx, rax
                shr   rdx, 12
                xor   rax, rdx
                mov   rdx, rax
                shl   rdx, 25
                xor   rax, rdx
                mov   rdx, rax
                shr   rdx, 27
                xor   rax, rdx
                mov   edx, 2685821657736338717 and 0x0FFFFFFFF
                mov   qword[rbp-Thread.rootPos+Thread.randSeed], rax
                mul   edx
                cdq
               idiv   dword[options.varietyMod]         ; varietyMod = 1 + variety
                add   edx, edi
                cmp   edi, dword[options.varietyBound]  ; varietyBound = - variety * PawnValueEg / 100
             cmovge   edi, edx
  end if

                lea   ecx, [rdi+VALUE_MATE_IN_MAX_PLY]

  if InCheck = 1
              movzx   eax, byte[rbx+State.ply]
                sub   eax, VALUE_MATE
                cmp   edi, -VALUE_INFINITE
                 je   .Return
  end if

  if PvNode = 1
                mov   esi, dword[.oldAlpha]
                sub   esi, edi
                sar   esi, 31
  end if
                mov   r8, qword[.tte]
                shr   r9, 48
                mov   edx, edi
                cmp   ecx, 2*VALUE_MATE_IN_MAX_PLY
                jae   .ValueToTT
.ValueToTTRet:


  if PvNode = 0
                mov   eax, dword[.bestMove]
      MainHash_Save   .ltte, r8, r9w, edx, BOUND_UPPER, byte[.ttDepth], eax, word[rbx+State.staticEval]
  else
                mov   eax, dword[.bestMove]
                and   esi, BOUND_EXACT-BOUND_UPPER
                add   esi, BOUND_UPPER
      MainHash_Save   .ltte, r8, r9w, edx, sil, byte[.ttDepth], eax, word[rbx+State.staticEval]
  end if
                mov   eax, edi

             calign   8
.Return:
Display 2, "QSearch returning %i0%n"
                add   rsp, .localsize
                pop   r15 r14 r13 r12 rdi rsi rbx
                ret


  if InCheck = 0

             calign   8
.CheckAdvancedPawnPush:
                and   edx, 7
                shr   r8d, 3
                xor   edx, r8d
                cmp   edx, 4
                 jb   .DoFutilityPruning
                jmp   .SkipFutilityPruning

             calign   8
.ContinueFromFutilityBase:
                mov   edx, 1
               call   SeeTestGe
                mov   ecx, dword[.move]
                mov   edx, r12d
               test   eax, eax
                jnz   .SkipFutilityPruning

             calign   8
.ContinueFromFutilityValue:
                cmp   edi, edx
              cmovl   edi, edx
                mov   dword[.bestValue], edi
                jmp   .MovePickLoop
  end if

             calign   8
.AbortSearch_PlyBigger:
                xor   eax, eax
                cmp   rax, qword[rbx+State.checkersBB]
                jne   .Return
               call   Evaluate
                jmp   .Return

             calign   8
.AbortSearch_PlySmaller:
                xor   eax, eax
                jmp   .Return

             calign   8
.ReturnStaticValue:
                mov   r8, qword[.tte]
                mov   r9, qword[rbx+State.key]
                shr   r9, 48
                mov   edx, eax
               test   r13d, r13d
                jnz   .Return
                add   eax, VALUE_MATE_IN_MAX_PLY
                cmp   eax, 2*VALUE_MATE_IN_MAX_PLY
                jae   .ReturnStaticValue_ValueToTT
.ReturnStaticValue_ValueToTTRet:
      MainHash_Save   .ltte, r8, r9w, edx, BOUND_LOWER, DEPTH_NONE, 0, word[rbx+State.staticEval]
                mov   eax, dword[.bestValue]
                jmp   .Return

.ReturnStaticValue_ValueToTT:
              movzx   ecx, byte[rbx+State.ply]
                mov   eax, edx
                sar   eax, 31
                xor   ecx, eax
                sub   edx, eax
                add   edx, ecx
                jmp   .ReturnStaticValue_ValueToTTRet

             calign   8
.ValueFromTT:
        ; value in edi is not VALUE_NONE
              movzx   r8d, byte[rbx+State.ply]
                mov   r9d, edi
                sar   r9d, 31
                xor   r8d, r9d
                add   edi, r9d
                sub   edi, r8d
                mov   dword[.ttValue], edi
                mov   eax, edi
                sub   eax, dword[.beta]
                sar   eax, 31
                jmp   .ValueFromTTRet

             calign   8
.ValueToTT:
              movzx   edx, byte[rbx+State.ply]
                mov   eax, edi
                sar   eax, 31
                xor   edx, eax
                sub   edx, eax
                add   edx, edi
                jmp   .ValueToTTRet

             calign   8
.CheckDraw_Cold:
     PosIsDraw_Cold   .AbortSearch_PlySmaller, .CheckDraw_ColdRet

end macro
