
macro search NT {
	; in:
	;  rbp: address of Pos struct in thread struct
	;  rbx: address of State
	;  ecx: alpha
	;  edx: beta
	;  r8d: depth
	;  r9l: cutNode  must be 0 or -1 (=FFh)
	; out:
	;  eax: score


match =_ROOT_NODE, NT
\{
ProfileInc Search_ROOT
 .PvNode equ 1
 .RootNode equ 1
\}

match =_PV_NODE, NT
\{
ProfileInc Search_PV
 .PvNode equ 1
 .RootNode equ 0
\}

match =_NONPV_NODE, NT
\{
ProfileInc Search_NONPV
 .PvNode equ 0
 .RootNode equ 0
\}


virtual at rsp
  .tte	      rq 1    ;0
  .ltte       rq 1    ;8
  .posKey	rq 1
  .ttMove	    rd 1
  .ttValue	    rd 1
  .move 	    rd 1
  .excludedMove     rd 1
  .bestMove	  rd 1
  .ext		  rd 1
  .newDepth	  rd 1
  .predictedDepth rd 1
  .moveCount	    rd 1
  .quietCount	    rd 1
  .alpha	    rd 1
  .beta 	    rd 1
  .depth	  rd 1
  .bestValue	  rd 1
  .value	  rd 1
  .eval 	  rd 1
  .nullValue	    rd 1
  .futilityValue    rd 1
  .extension	    rd 1
  .success	    rd 1   ; for tb
  .rbeta		  rd 1
  .moved_piece_to_sq	  rd 1
  .givesCheck		  rb 1
  .singularExtensionNode  rb 1
  .improving		  rb 1
  .captureOrPromotion	  rb 1	; nonzero for true
  .doFullDepthSearch	  rb 1
  .cutNode		  rb 1	; -1 for true
  .ttHit		  rb 1
  .moveCountPruning	  rb 1
  .quietsSearched    rd 64
if .PvNode eq 1
  .pv  rd MAX_PLY+1
end if
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))


	       push   rbx rsi rdi r12 r13 r14 r15
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

match =2, VERBOSE \{
push rcx rdx r8 r9 r13 r14 r15
mov r15, rcx
mov r14, rdx
mov r13, r8
lea rdi, [VerboseOutput]
mov eax,'s<'
stosw
match =_ROOT_NODE, NT
\\{
mov al, '2'
\\}
match =_PV_NODE, NT
\\{
mov al, '1'
\\}
match =_NONPV_NODE, NT
\\{
mov al, '0'
\\}
stosb
mov eax, '> ('
stosd
sub rdi, 1
movsxd rax, r15d
call PrintSignedInteger
mov ax, ', '
stosw
movsxd rax, r14d
call PrintSignedInteger
mov eax, ')  '
stosd
sub rdi, 1
movsxd rax, r13d
call PrintSignedInteger
PrintNewLine
lea rcx, [VerboseOutput]
call _WriteOut
pop r15 r14 r13 r9 r8 rdx rcx
\}


		mov   dword[.alpha], ecx
		mov   dword[.beta], edx
		mov   dword[.depth], r8d
		mov   byte[.cutNode], r9l
match =1, DEBUG \{
		lea   eax, [r9+1]
	     Assert   b, al, 2, 'assertion .cutNode == 0 or -1 failed in Search'
\}
	; Step 1. initialize node
		xor   eax, eax
		mov   dword[.moveCount], eax
		mov   dword[.quietCount], eax
		mov   dword[rbx+State.moveCount], eax
		mov   dword[rbx+State.history], eax
		mov   dword[.bestValue], -VALUE_INFINITE
	      movzx   r12d, byte[rbx-1*sizeof.State+State._ply]
		add   r12d, 1
		mov   byte[rbx+State._ply], r12l

if USE_SELDEPTH
    if .PvNode eq 1
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.maxPly]
		cmp   eax, r12d
	      cmovb   eax, r12d
		mov   byte[rbp-Thread.rootPos+Thread.maxPly], al
    end if
end if

		mov   al, byte[rbp-Thread.rootPos+Thread.resetCalls]
		mov   edx, dword[rbp-Thread.rootPos+Thread.callsCnt]
	       test   al, al
		 jz   .dontreset
		xor   edx, edx
		mov   byte[rbp-Thread.rootPos+Thread.resetCalls], 0
	.dontreset:
		add   edx, 1
		mov   dword[rbp-Thread.rootPos+Thread.callsCnt], edx
		cmp   edx, 4096+1
		 jb   .dontchecktime
		mov   ecx, dword[threadPool.threadCnt]
	     Assert   g, ecx, 0, 'Assertion dword[threadPool.threadCnt] > 0 failed in Search'
	.ResetNextThread:
		sub   ecx, 1
		mov   rax, qword[threadPool.threadTable+8*rcx]
		mov   byte[rax+Thread.resetCalls], -1
		jnz   .ResetNextThread
	       call   CheckTime
		mov   byte[rbp-Thread.rootPos+Thread.skipCurrMove], al
	.dontchecktime:


    if .RootNode eq 0
	; Step 2. check for aborted search and immediate draws
	      movzx   eax, word[rbx+State.rule50]
	      movzx   r8d, word[rbx+State.pliesFromNull]
		mov   r9, qword[rbx+State.key]
		cmp   r12d, MAX_PLY
		jae   .AbortSearch_PlyBigger
		cmp   byte[signals.stop], 0
		jne   .AbortSearch_PlySmaller
		cmp   eax, 100
		jae   .CheckDrawBy50
		cmp   eax, r8d
	      cmova   eax, r8d
		shr   eax, 1
		 jz   .NoDrawBy50
	       imul   rax, -2*sizeof.State
	@@:	cmp   r9, qword[rbx+rax+State.key]
		 je   .AbortSearch_PlySmaller
		add   rax, 2*sizeof.State
		jnz   @b
     .NoDrawBy50:


	; Step 3. mate distance pruning
		mov   ecx, dword[.alpha]
		mov   edx, dword[.beta]
		mov   eax, r12d
		sub   eax, VALUE_MATE
		cmp   ecx, eax
	      cmovl   ecx, eax
		not   eax
		cmp   edx, eax
	      cmovg   edx, eax
		mov   dword[.alpha], ecx
		mov   dword[.beta], edx
		mov   eax, ecx
		cmp   ecx, edx
		jge   .Return
    end if ;.RootNode eq 0

		xor   eax, eax
		mov   dword[.bestMove], eax
		mov   dword[rbx+1*sizeof.State+State.excludedMove], eax
		mov   dword[rbx+0*sizeof.State+State.currentMove], eax
		mov   qword[rbx+0*sizeof.State+State.counterMoves], rax
		mov   byte[rbx+1*sizeof.State+State.skipEarlyPruning], al
		mov   dword[rbx+2*sizeof.State+State.killers+4*0], eax
		mov   dword[rbx+2*sizeof.State+State.killers+4*1], eax

if USE_SYZYGY
    if .RootNode eq 0
	; get a count of the piece for tb
		mov   rax, qword[rbp+Pos.typeBB+8*White]
		 or   rax, qword[rbp+Pos.typeBB+8*Black]
	     popcnt   rax, rax, rdx
		mov   r15d, dword[Tablebase_Cardinality]
		sub   r15d, eax
	      movzx   eax, word[rbx+State.rule50]
	      movzx   ecx, byte[rbx+State.castlingRights]
		 or   eax, ecx
		neg   eax
		 or   r15d, eax
	; if r15d <0, don't do tb probe
    end if
end if

	; Step 4. transposition table look up
		mov   ecx, dword[rbx+State.excludedMove]
		mov   dword[.excludedMove], ecx
		xor   rcx, qword[rbx+State.key]
		mov   qword[.posKey], rcx
	       call   MainHash_Probe
		mov   qword[.tte], rax
		mov   qword[.ltte], rcx
		mov   byte[.ttHit], dl
		mov   rdi, rcx
		sar   rdi, 48
	      movsx   eax, ch
		mov   r13d, edx
	if .RootNode eq 0
		shr   ecx, 16
	else
	       imul   ecx, dword[rbp-Thread.rootPos+Thread.PVIdx], sizeof.RootMove
		add   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   ecx, dword[rcx+RootMove.pv+4*0]
	end if
		mov   dword[.ttMove], ecx
		;mov   dword[.ttValue], edi

		lea   r8d, [rdi+VALUE_MATE_IN_MAX_PLY]
	       test   edx, edx
		 jz   .DontReturnTTValue

		cmp   edi, VALUE_NONE
		 je   .DontReturnTTValue
		cmp   r8d, 2*VALUE_MATE_IN_MAX_PLY
		jae   .ValueFromTT
.ValueFromTTRet:

    if .PvNode eq 0
		cmp   eax, dword[.depth]
		 jl   .DontReturnTTValue
		mov   eax, BOUND_UPPER
		mov   r8d, BOUND_LOWER
		cmp   edi, dword[.beta]
	     cmovge   eax, r8d
	       test   al, byte[.ltte+MainHashEntry.genBound]
		jnz   .ReturnTTValue
    end if

.DontReturnTTValue:
		mov   dword[.ttValue], edi





if USE_SYZYGY
    if .RootNode eq 0
	; Step 4a. Tablebase probe
	       test   r15d, r15d
		jns   .CheckTablebase
.CheckTablebaseReturn:
    end if
end if


	; step 5. evaluate the position statically
		mov   eax, VALUE_NONE
		mov   dword [.eval], eax
		mov   dword[rbx+State.staticEval], eax
		mov   rcx, qword[rbx+State.checkersBB]
	       test   rcx, rcx
		jnz   .moves_loop
		mov   edx, dword[rbx-1*sizeof.State+State.currentMove]
	      movsx   eax, word[.ltte+MainHashEntry.eval]
	       test   r13d, r13d
		jnz   .StaticValueYesTTHit
.StaticValueNoTTHit:
;SD_String 'ttHit=f|'
		mov   eax, dword[rbx-1*sizeof.State+State.staticEval]
		neg   eax
		add   eax, 2*Eval_Tempo
		mov   r12, qword[.tte]
		cmp   edx, MOVE_NULL
		 je   @f
	       call   Evaluate
	@@:	mov   r8d, eax
		mov   dword[rbx+State.staticEval], eax
		mov   dword[.eval], eax
		mov   r9, qword [.posKey]
		shr   r9, 48
		mov   edx, VALUE_NONE
      MainHash_Save   .ltte, r12, r9w, edx, BOUND_NONE, DEPTH_NONE, 0, r8w
		jmp   .StaticValueDone
.StaticValueYesTTHit:
;SD_String 'ttHit=t|'
		cmp   eax, VALUE_NONE
		jne   @f
	       call   Evaluate
	@@:	xor   ecx, ecx
		mov   dword[rbx+State.staticEval], eax
		cmp   edi, eax
	       setg   cl
		add   ecx, BOUND_UPPER
		cmp   edi, VALUE_NONE
		 je   @f
	       test   cl, byte[.ltte+MainHashEntry.genBound]
	     cmovnz   eax, edi
	@@:	mov   dword[.eval], eax
.StaticValueDone:


		mov   al, byte[rbx+State.skipEarlyPruning]
	       test   al, al
		jnz   .moves_loop


	; Step 6. Razoring (skipped when in check)
    if .PvNode eq 0
		mov   edx, dword[.depth]
		cmp   edx, 4*ONE_PLY
		jge   .6skip
		mov   eax, dword[.ttMove]
	       test   eax, eax
		jnz   .6skip
		mov   ecx, dword[.eval]
		mov   eax, dword[RazorMargin+4*rdx]
		add   eax, ecx
		cmp   eax, dword[.alpha]
		 jg   .6skip

		mov   ecx, dword[.alpha]
		xor   r8d, r8d
		cmp   edx, ONE_PLY
		 jg   .6b
.6a:
		mov   edx, dword[.beta]
	       call   QSearch_NonPv_NoCheck
		jmp   .Return
.6b:
		sub   ecx, dword[RazorMargin+4*rdx]
		lea   edx, [rcx+1]
		mov   esi, ecx
	       call   QSearch_NonPv_NoCheck
		cmp   eax, esi
		jle   .Return
.6skip:
    end if



	; Step 7. Futility pruning: child node (skipped when in check)
    if .RootNode eq 0
		mov   edx, dword[.depth]
		mov   ecx, dword[rbp+Pos.sideToMove]
		cmp   edx, 7*ONE_PLY
		jge   .7skip
	       imul   edx, -150
		mov   eax, dword[.eval]
		cmp   eax, VALUE_KNOWN_WIN
		jge   .7skip
		add   edx, eax
		cmp   edx, dword[.beta]
		 jl   .7skip
	      movzx   ecx, word[rbx+State.npMaterial+2*rcx]
	       test   ecx, ecx
		jnz   .Return
.7skip:
    end if



	; Step 8. Null move search with verification search (is omitted in PV nodes)
    if .PvNode eq 0
		mov   edx, dword[.depth]
	       imul   eax, edx, 35
		add   eax, dword[rbx+State.staticEval]
		mov   esi, dword[.beta]
		mov   ecx, dword[rbp+Pos.sideToMove]
		cmp   esi, dword[.eval]
		 jg   .8skip
	      movzx   ecx, word[rbx+State.npMaterial+2*rcx]
		add   esi, 35*6
	       test   ecx, ecx
		 jz   .8skip
		sub   edx, 13*ONE_PLY
		sub   eax, esi
		and   edx, eax
		 js   .8skip

		xor   eax, eax
		mov   dword[rbx+State.currentMove], MOVE_NULL
		mov   qword[rbx+State.counterMoves], rax

		mov   eax, dword[.eval]
		sub   eax, dword[.beta]
		mov   ecx, PawnValueMg
		xor   edx, edx
	       idiv   ecx
		mov   ecx, 3
		cmp   eax, ecx
	      cmovg   eax, ecx
	       imul   ecx, dword[.depth], 67
		add   ecx, 823
		sar   ecx, 8
		add   eax, ecx

	     Assert   ge, eax, 0, 'assertion eax >= 0 failed in Search'

		mov   esi, dword[.depth]
		sub   esi, eax
	; esi = depth-R

	       call   Move_DoNull
		mov   byte[rbx+State.skipEarlyPruning], -1
		mov   r8d, esi
		xor   eax, eax
		lea   r12, [QSearch_NonPv_NoCheck]
		lea   rcx, [Search_NonPv]
		cmp   esi, ONE_PLY
	     cmovge   r12, rcx
	      cmovl   r8d, eax
		mov   ecx, dword[.beta]
		neg   ecx
		lea   edx, [rcx+1]
		mov   r9l, byte[.cutNode]
		xor   r9l, -1	     ; not used in qsearch case
	       call   r12
		neg   eax
		mov   byte[rbx+State.skipEarlyPruning], 0
		xor   dword[rbp+Pos.sideToMove], 1	  ;undo null move
		sub   rbx, sizeof.State 		  ;

		mov   edx, dword[.beta]
		cmp   eax, edx
		 jl   .8skip

		cmp   eax, VALUE_MATE_IN_MAX_PLY
	     cmovge   eax, edx
		mov   edi, eax
	; edi = nullValue

		mov   ecx, dword[.depth]
		cmp   ecx, 12*ONE_PLY
		jge   .8check
		lea   ecx, [rdx+VALUE_KNOWN_WIN-1]
		cmp   ecx, 2*(VALUE_KNOWN_WIN-1)
		jbe   .Return
.8check:
		mov   byte[rbx+State.skipEarlyPruning], -1
		mov   r8d, esi
		xor   eax, eax
		lea   r12, [QSearch_NonPv_NoCheck]
		lea   rcx, [Search_NonPv]
		cmp   esi, ONE_PLY
	     cmovge   r12, rcx
	      cmovl   r8d, eax
		lea   ecx, [rdx-1]
		xor   r9d, r9d
	       call   r12
		mov   byte[rbx+State.skipEarlyPruning], 0
		cmp   eax, dword[.beta]
		mov   eax, edi
		jge   .Return
.8skip:
    end if



	; Step 9. ProbCut (skipped when in check)
    if .PvNode eq 0
		mov   eax, dword[.depth]
		cmp   eax, 5*ONE_PLY
		 jl   .9skip
		mov   eax, dword[.beta]
		add   eax, VALUE_MATE_IN_MAX_PLY-1
		cmp   eax, 2*(VALUE_MATE_IN_MAX_PLY-1)
		 ja   .9skip

	     Assert   ne, dword[rbx-1*sizeof.State+State.currentMove], 0	, 'assertion dword[rbx-1*sizeof.State+State.currentMove] != MOVE_NONE failed in Search.Step9'
	     Assert   ne, dword[rbx-1*sizeof.State+State.currentMove], MOVE_NULL, 'assertion dword[rbx-1*sizeof.State+State.currentMove] != MOVE_NULL failed in Search.Step9'


		mov   edi, dword[.beta]
		add   edi, 200
		mov   eax, VALUE_INFINITE
		cmp   edi, eax
	      cmovg   edi, eax
		mov   dword[.rbeta], edi
		sub   edi, dword[rbx+State.staticEval]


	; initialize movepick

SD_String 'init MovePick probcut'
SD_NewLine
	     Assert   e, qword[rbx+State.checkersBB], 0, 'assertion qword[rbx+State.checkersBB] == 0 failed in Search.Step9'
		lea   r15, [MovePick_PROBCUT_GEN]
		mov   dword[rbx+State.threshold], edi
		mov   ecx, dword[.ttMove]
		mov   eax, ecx
		mov   edx, ecx
		and   edx, 63
		shr   eax, 12
	      movzx   edx, byte[rbp+Pos.board+rdx]
		xor   edi, edi
	       test   ecx, ecx
		 jz   .9NoTTMove
		cmp   eax, MOVE_TYPE_CASTLE
		 je   .9NoTTMove
		cmp   eax, MOVE_TYPE_EPCAP
		 je   @f
	       test   edx, edx
		 jz   .9NoTTMove
	@@:	mov   ecx, dword[.ttMove]
	       call   Move_IsPseudoLegal
	       test   rax, rax
		 jz   .9NoTTMove
		mov   ecx, dword[.ttMove]
		mov   edx, dword[rbx+State.threshold]
		add   edx, 1
	       call   SeeTest
	       test   eax, eax
		 jz   .9NoTTMove
		mov   edi, dword[.ttMove]
		lea   r15, [MovePick_PROBCUT]
.9NoTTMove:	mov   qword[rbx+State.stage], r15
		mov   dword[rbx+State.ttMove], edi

.9moveloop:
	GetNextMove
		mov   dword[.move], eax
		mov   ecx, eax
	       test   eax, eax
		 jz   .9moveloop_done
	       call   Move_IsLegal
	       test   eax, eax
		 jz   .9moveloop

		mov   ecx, dword[.move]
		mov   dword[rbx+State.currentMove], ecx
		mov   eax, ecx
		shr   eax, 6
		and   eax, 63
		and   ecx, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
		shl   eax, 6
		add   eax, ecx
	       imul   eax, 4*16*64
		add   rax, qword[rbp+Pos.counterMoveHistory]
		mov   qword[rbx+State.counterMoves], rax

		mov   ecx, dword[.move]
	       call   Move_GivesCheck
		mov   ecx, dword[.move]
		mov   edx, eax
	       call   Move_Do__ProbCut
		mov   ecx, dword[.rbeta]
		mov   edi, ecx
		neg   ecx
		lea   edx, [rcx+1]
		mov   r8d, dword[.depth]
		sub   r8d, 4*ONE_PLY
		mov   r9l, byte[.cutNode]
		xor   r9l, -1
	       call   Search_NonPv
		neg   eax
		mov   esi, eax
		mov   ecx, dword[.move]
	       call   Move_Undo
		mov   eax, esi
		cmp   esi, edi
		 jl   .9moveloop
		jmp   .Return

.9moveloop_done:
.9skip:
    end if



	; Step 10. Internal iterative deepening (skipped when in check)

		mov   r8d, dword[.depth]
		mov   ecx, dword[.ttMove]
	       test   ecx, ecx
		jnz   .10skip
		cmp   r8d, 6*ONE_PLY
		 jl   .10skip
		lea   r8d, [3*r8]
		sar   r8d, 2
		sub   r8d, 2*ONE_PLY
	if .PvNode eq 1
		mov   ecx, dword[.alpha]
		mov   edx, dword[.beta]
		mov   r9l, byte[.cutNode]
		mov   byte[rbx+State.skipEarlyPruning], -1
	       call   Search_Pv
	else
		mov   eax, dword[rbx+State.staticEval]
		add   eax, 256
		cmp   eax, dword[.beta]
		 jl   .10skip
		mov   ecx, dword[.alpha]
		mov   edx, dword[.beta]
		mov   r9l, byte[.cutNode]
		mov   byte[rbx+State.skipEarlyPruning], -1
	       call   Search_NonPv
	end if
		mov   byte[rbx+State.skipEarlyPruning], 0
		mov   rcx, qword[.posKey]
	       call   MainHash_Probe
		mov   qword[.tte], rax
		mov   qword[.ltte], rcx
		mov   byte[.ttHit], dl
		shr   ecx, 16
		mov   dword[.ttMove], ecx
.10skip:






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.moves_loop:	    ; this is actually not the head of the loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


if PEDANTIC
	; The data at tte could have been changed by
	;   Step 6. Razoring
	;   Step 9. ProbCut
	; Note that after
	;   Step 10. Internal iterative deepening
	; the data is reloaded
	; Also, in the case of a tt miss, tte points to junk but must be used anyways.
	; We reload the data in .ltte for its use in .singularExtensionNode.
		mov   rax, qword[.tte]
		mov   rax, qword[rax]
		mov   qword[.ltte], rax
end if


	; not sure if these need to be stored on the fxn stack as well
;                mov   rax, qword[rbx-1*sizeof.State+State.counterMoves]
;                mov   rcx, qword[rbx-2*sizeof.State+State.counterMoves]
;                mov   rdx, qword[rbx-4*sizeof.State+State.counterMoves]
;                mov   qword[.cmh], rax
;                mov   qword[.fmh], rcx
;                mov   qword[.fmh2], rdx

;.CMH  equ qword[.cmh]
;.FMH  equ qword[.fmh]
;.FMH2 equ qword[.fmh2]


.CMH  equ (rbx-1*sizeof.State+State.counterMoves)
.FMH  equ (rbx-2*sizeof.State+State.counterMoves)
.FMH2 equ (rbx-4*sizeof.State+State.counterMoves)


SD_String 'init MovePick main'
SD_NewLine

		mov   ecx, dword[.ttMove]
		mov   edx, dword[.depth]

		mov   dword[rbx+State.depth], edx

		mov   rdi, qword[rbp+Pos.counterMoves]
		mov   eax, dword[rbx-1*sizeof.State+State.currentMove]
		and   eax, 63
	      movzx   edx, byte[rbp+Pos.board+rax]
		shl   edx, 6
		add   edx, eax
		mov   eax, dword[rdi+4*rdx]
		mov   dword[rbx+State.countermove], eax



		lea   r15, [MovePick_CAPTURES_GEN]
		lea   r14, [MovePick_ALL_EVASIONS]
		mov   edi, ecx
	       test   ecx, ecx
		 jz   .NoTTMove
	       call   Move_IsPseudoLegal
	       test   rax, rax
	      cmovz   edi, eax
		 jz   .NoTTMove
		lea   r15, [MovePick_MAIN_SEARCH]
		lea   r14, [MovePick_EVASIONS]
	.NoTTMove:
		mov   r8, qword[rbx+State.checkersBB]
	       test   r8, r8
	     cmovnz   r15, r14
		mov   dword[rbx+State.ttMove], edi
		mov   qword[rbx+State.stage], r15


		mov   eax, dword[.bestValue]
		mov   dword[.value], eax

		mov   edx, dword[rbx-0*sizeof.State+State.staticEval]
		mov   ecx, dword[rbx-2*sizeof.State+State.staticEval]
		cmp   edx, ecx
	      setge   al
		cmp   edx, VALUE_NONE
	       sete   dl
		cmp   ecx, VALUE_NONE
	       sete   cl
		 or   al, dl
		 or   al, cl
	     Assert   b, al, 2, 'assertion al<2 in Search failed'
		mov   byte[.improving], al   ; should be 0 or 1



    if .RootNode eq 1
		mov   byte[.singularExtensionNode], 0
    else
		mov   eax, 1
		mov   ecx, dword[.depth]
		cmp   ecx, 8*ONE_PLY
	      setge   cl
		and   al, cl
		mov   edx, dword[.ttMove]
	       test   edx, edx
	      setne   cl
		and   al, cl
		mov   edx, dword[.ttValue]
		cmp   edx, VALUE_NONE
	      setne   cl

		and   al, cl
		mov   edx, dword[.excludedMove]
	       test   edx, edx
	       setz   cl
		and   al, cl
		mov   dl, byte[.ltte+MainHashEntry.genBound]
	       test   dl, BOUND_LOWER
	      setnz   cl
		and   al, cl
	      movsx   edx, byte[.ltte+MainHashEntry.depth]
		add   edx, 3*ONE_PLY
		cmp   edx, dword[.depth]
	      setge   cl
		and   al, cl
		mov   byte[.singularExtensionNode], al
    end if




	; Step 11. Loop through moves
	      align   8
.MovePickLoop:	     ; this is the head of the loop

	GetNextMove
		mov   dword[.move], eax
	       test   eax, eax
		 jz   .MovePickDone

SD_String 'mp='
SD_Move rax
SD_String '|'


		cmp   eax, dword[.excludedMove]
		 je   .MovePickLoop


		; at the root search only moves in the move list
	if .RootNode eq 1
	       imul   ecx, dword[rbp-Thread.rootPos+Thread.PVIdx], sizeof.RootMove
		add   rcx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		mov   rdx, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender]
	@@:	cmp   rcx, rdx
		jae   .MovePickLoop
		cmp   eax, dword[rcx+RootMove.pv+4*0]
		lea   rcx, [rcx+sizeof.RootMove]
		jne   @b

	end if

		mov   eax, dword[.moveCount]
		add   eax, 1
		mov   dword[rbx+State.moveCount], eax
		mov   dword[.moveCount], eax

;SD_String 'mc='
;SD_Int rax
;SD_String '|'


		xor   eax, eax
	if .PvNode eq 1
		mov   qword[rbx+1*sizeof.State+State.pv], rax
	end if
		mov   dword[.extension], eax

if USE_CURRMOVE
if VERBOSE < 2
	if .RootNode eq 1
		mov   edx, dword[.depth]
	      movsx   eax, byte[rbp-Thread.rootPos+Thread.skipCurrMove]
		cmp   edx, CURRMOVE_MIN_DEPTH*ONE_PLY
		 jb   @f
		 or   eax, dword[rbp-Thread.rootPos+Thread.idx]
		 jz   .PrintCurrentMove
.PrintCurrentMoveRet:
		@@:
	end if
end if
end if

		mov   ecx, dword[.move]
		mov   edx, ecx
		shr   edx, 6
		and   edx, 63

	      movzx   edx, byte[rbp+Pos.board+rdx]
		mov   eax, ecx
		and   eax, 63
		shl   edx, 6
		add   edx, eax
		mov   dword[.moved_piece_to_sq], edx
	; moved_piece_to_sq = index of [moved_piece][to_sq(move)]
		shr   ecx, 14
	      movzx   eax, byte[rbp+Pos.board+rax]
		 or   al, byte[_CaptureOrPromotion_or+rcx]
		and   al, byte[_CaptureOrPromotion_and+rcx]
		mov   byte[.captureOrPromotion], al


		mov   ecx, dword[.move]
	       call   Move_GivesCheck
		mov   byte[.givesCheck], al

		mov   edx, dword[.depth]
	      movzx   ecx, byte[.improving]
	       imul   ecx, 16*4
		mov   ecx, dword[FutilityMoveCounts+rcx+4*rdx]
		sub   ecx, dword[.moveCount]
		sub   ecx, 1
		sub   edx, 16*ONE_PLY
		and   edx, ecx
		sar   edx, 31
		mov   byte[.moveCountPruning], dl

;SD_String 'mcp='
;SD_Bool8 rdx
;SD_NewLine



      ; Step 12. Extend checks
		mov   ecx, dword[.move]
	       test   eax, eax
		 jz   .12dont_extend
	       test   edx, edx
		jnz   .12dont_extend
	SeeSignTest   .12extend_oneply
	       test   eax, eax
		 jz   .12dont_extend
.12extend_oneply:
		mov   dword[.extension], 1
.12dont_extend:

		mov   al, byte[.singularExtensionNode]
	       test   al, al
		 jz   .12done
		mov   ecx, dword[.move]
		cmp   ecx, dword[.ttMove]
		jne   .12done
		mov   eax, dword[.extension]
	       test   eax, eax
		jnz   .12done
	       call   Move_IsLegal
		mov   edx, dword[.ttValue]
		mov   r8d, dword[.depth]
		mov   r9l, byte[.cutNode]
	       test   eax, eax
		 jz   .12done
		mov   eax, -VALUE_MATE
		sub   edx, r8d
		sub   edx, r8d
		cmp   edx, eax
	      cmovl   edx, eax
		lea   ecx, [rdx-1]
		mov   edi, edx
		sar   r8d, 1
		mov   eax, dword[.move]
		mov   dword[rbx+State.excludedMove], eax
		mov   byte[rbx+State.skipEarlyPruning], -1

      ; The call to search_NonPV with the same value of ss messed up our
      ; move picker data. So we fix it.
		mov   r12, qword[rbx+State.stage]
		mov   r13d, dword[rbx+State.ttMove]
		mov   r14d, dword[rbx+State.countermove]
	       call   Search_NonPv
		xor   ecx, ecx
		mov   byte[rbx+State.skipEarlyPruning], cl
		mov   dword[rbx+State.excludedMove], ecx
		cmp   eax, edi
	       setl   cl
		mov   dword[.extension], ecx
      ; The call to search_NonPV with the same value of ss messed up our
      ; move picker data. So we fix it.
		mov   edx, dword[.depth]
		mov   qword[rbx+State.stage], r12
		mov   dword[rbx+State.depth], edx
		mov   dword[rbx+State.ttMove], r13d
		mov   dword[rbx+State.countermove], r14d


.12done:



	; Step 13. Pruning at shallow depth

		mov   r12d, dword[.move]
		shr   r12d, 6
		and   r12d, 63				; r12d = from
		mov   r13d, dword[.move]
		and   r13d, 63				; r13d = to
	      movzx   r14d, byte[rbp+Pos.board+r12]	; r14d = from piece
	      movzx   r15d, byte[rbp+Pos.board+r13]	; r15d = to piece


		mov   eax, dword[.extension]
		mov   edx, dword[.depth]
		sub   eax, 1
		add   eax, edx
		mov   dword[.newDepth], eax

	; edx = depth

    if .RootNode eq 0

		mov   ecx, dword[.bestValue]
		cmp   ecx, VALUE_MATED_IN_MAX_PLY
		jle   .13done

		mov   al, byte[.captureOrPromotion]
		 or   al, byte[.givesCheck]
		jnz   .13else
		mov   eax, dword[rbp+Pos.sideToMove]
		lea   ecx, [8*rax+Pawn]
		cmp   r14d, ecx
		jne   .13do
		mov   ecx, r12d
		shr   ecx, 3
	       imul   eax, 7
		xor   ecx, eax
		cmp   ecx, RANK_4
		 ja   .13else
.13do:

	; Move count based pruning
		mov   al, byte[.moveCountPruning]
	       test   al, al
		jnz   .MovePickLoop

		mov   esi, 63
	      movzx   eax, byte[.improving]
		;mov   ecx, dword[.depth]
		mov   ecx, edx
		cmp   edx, esi
	      cmova   ecx, esi
	       imul   eax, 64
		add   eax, ecx
		mov   ecx, dword[.moveCount]
		cmp   ecx, esi
	      cmova   ecx, esi
	       imul   eax, 64
		add   eax, ecx
		mov   edi, dword[.newDepth]
		sub   edi, dword[Reductions+4*(rax+2*64*64*.PvNode)]
	; edi = lmrDepth

	; Countermoves based pruning
		mov   r8, qword[.CMH]
		mov   r9, qword[.FMH]
		mov   r10, qword[.FMH2]
		cmp   edi, 3*ONE_PLY
		jge   .13DontSkip2

	       imul   eax, r14d, 64
		add   eax, r13d
	       test   r8, r8
		 jz   @f
		cmp   dword[r8+4*rax], 0
		jge   .13DontSkip2
	@@:    test   r9, r9
		 jz   @f
		cmp   dword[r9+4*rax], 0
		jge   .13DontSkip2
	@@:    test   r10, r10
		 jz   .MovePickLoop
		cmp   dword[r10+4*rax], 0
		 jl   .MovePickLoop
	       test   r8, r8
		 jz   .13DontSkip2
	       test   r9, r9
		jnz   .MovePickLoop
	.13DontSkip2:

	; Futility pruning: parent node
		xor   edx, edx
		cmp   edi, 7*ONE_PLY
		 jg   .13done
		 je   .13check_see
	       test   edi, edi
	      cmovs   edi, edx
	       imul   eax, edi, 200
		add   eax, 256
		cmp   rdx, qword[rbx+State.checkersBB]
		jne   .13check_see
		add   eax, dword[rbx+State.staticEval]
		cmp   eax, dword[.alpha]
		jle   .MovePickLoop
.13check_see:
	; Prune moves with negative SEE at low depths
		mov   ecx, dword[.move]
	       imul   edx, edi, -35
	       imul   edx, edi
	       call   SeeTest
	       test   eax, eax
		 jz   .MovePickLoop

		jmp   .13done
.13else:
		mov   ecx, dword[.move]
		cmp   edx, 7*ONE_PLY
		jge   .13done
		cmp   byte[.extension], 0
		jne   .13done
	       imul   edx, edx
	       imul   edx, -35

		add   edx, -399
	if .PvNode eq 1
		add   edx, dword[.beta]
		sub   edx, dword[.alpha]
		sub   edx, 1
	end if

	       call   SeeTest
	       test   eax, eax
		 jz   .MovePickLoop

.13done:
    end if

	; Speculative prefetch as early as possible
		shl   r14d, 6+3
		shl   r15d, 6+3
		mov   rax, qword[rbx+State.key]
		xor   rax, qword[Zobrist_side]
		xor   rax, qword[Zobrist_Pieces+r14+8*r12]
		xor   rax, qword[Zobrist_Pieces+r14+8*r13]
		xor   rax, qword[Zobrist_Pieces+r15+8*r13]
		and   rax, qword[mainHash.mask]
		shl   rax, 5
		add   rax, qword[mainHash.table]
	prefetchnta   [rax]

	; Check for legality just before making the move
    if .RootNode eq 0
		mov   ecx, dword[.move]
	       call   Move_IsLegal
	       test   rax, rax
		 jz   .IllegalMove
    end if

		mov   ecx, dword[.move]
		mov   eax, dword[.moved_piece_to_sq]
		shl   eax, 2+4+6
		add   rax, qword[rbp+Pos.counterMoveHistory]
		mov   dword[rbx+State.currentMove], ecx
		mov   qword[rbx+State.counterMoves], rax

	; Step 14. Make the move
	      movsx   edx, byte[.givesCheck]
	       call   Move_Do__Search


	; Step 15. Reduced depth search (LMR)
		mov   edx, dword[.depth]
		mov   ecx, dword[.moveCount]
		cmp   edx, 3*ONE_PLY
		 jl   .15skip
		cmp   ecx, 1
		jbe   .15skip
		mov   r8l, byte[.captureOrPromotion]
	       test   r8l, r8l
		 jz   @f
		mov   al, byte[.moveCountPruning]
	       test   al, al
		 jz   .15skip
	@@:

		mov   esi, 63
	      movzx   eax, byte[.improving]
		;mov   edx, dword[.depth]
		cmp   edx, esi
	      cmova   edx, esi
	       imul   eax, 64
		add   eax, edx
		;mov   ecx, dword[.moveCount]
		cmp   ecx, esi
	      cmova   ecx, esi
	       imul   eax, 64
		add   eax, ecx
		mov   edi, dword[Reductions+4*(rax+2*64*64*.PvNode)]

	       test   r8l, r8l
		 jz   .15NotCaptureOrPromotion
		xor   eax, eax
	       test   edi, edi
	      setnz   al
		sub   edi, eax
		jmp   .15ReadyToSearch

.15NotCaptureOrPromotion:


		mov   r12d, dword[.move]
		shr   r12d, 6
		and   r12d, 63				; r12d = from
		mov   r13d, dword[.move]
		and   r13d, 63				; r13d = to
	      movzx   r14d, byte[rbp+Pos.board+r12]	; r14d = from piece   should be 0
	      movzx   r15d, byte[rbp+Pos.board+r13]	; r15d = to piece

		cmp   byte[.cutNode], 0
		 jz   .15testA
		add   edi, 2*ONE_PLY
		jmp   .15skipA
.15testA:
		mov   ecx, dword[.move]
		cmp   ecx, MOVE_TYPE_PROM shl 12
		jae   .15skipA
		mov   r9d, r12d
		mov   r8d, r13d
		xor   edx, edx
	       call   SeeTest.HaveFromTo
	       test   eax, eax
		jnz   .15skipA
		sub   edi, 2*ONE_PLY
.15skipA:

		mov   ecx, dword[.move]
		and   ecx, 64*64-1
		mov   edx, dword[.moved_piece_to_sq]
		mov   r8, qword[rbp+Pos.history]
		mov   r9, qword[.CMH-1*sizeof.State]
		mov   r10, qword[.FMH-1*sizeof.State]
		mov   r11, qword[.FMH2-1*sizeof.State]
		mov   eax, dword[rbp+Pos.sideToMove]
		xor   eax, 1
		shl   eax, 12+2
		add   rax, qword[rbp+Pos.fromTo]
		mov   eax, dword[rax+4*rcx]
		add   eax, dword[r8+4*rdx]
		sub   eax, 8000

		mov   ecx, dword[rbx-2*sizeof.State+State.history]

	       test   r9, r9
		 jz   @f
		add   eax, dword[r9+4*rdx]
	@@:    test   r10, r10
		 jz   @f
		add   eax, dword[r10+4*rdx]
	@@:    test   r11, r11
		 jz   @f
		add   eax, dword[r11+4*rdx]
	@@:

; if a>0 and b<0
;   d=d-1
; else if a<0 and b>0
;   d=d+1
; end if

;cmp eax, 0
;je .if15done
;jl .if15else
;cmp ecx, 0
;jge .if15done
;sub edi, 1
;jmp .if15done
;.if15else:
;cmp ecx, 0
;jle .if15done
;add edi, 1
;.if15done:

; is the same as
;
; d += (b&-a)>>31 - (a&-b)>>31

		mov   edx, eax
		neg   edx
		and   edx, ecx
		neg   ecx
		and   ecx, eax
		sar   edx, 31
		add   edi, edx
		sar   ecx, 31
		sub   edi, ecx

		mov   dword[rbx-1*sizeof.State+State.history], eax

		cdq
		mov   ecx, 20000
	       idiv   ecx
		xor   ecx, ecx
		sub   edi, eax
	      cmovs   edi, ecx

.15ReadyToSearch:
		mov   eax, 1
		mov   r8d, dword[.newDepth]
		sub   r8d, edi
		cmp   r8d, eax
	      cmovl   r8d, eax
		mov   edi, r8d

		mov   edx, dword[.alpha]
		neg   edx
		lea   ecx, [rdx-1]
		 or   r9d, -1
	       call   Search_NonPv
		neg   eax
		mov   dword[.value], eax

		cmp   eax, dword[.alpha]
		jle   .17entry
		cmp   edi, dword[.newDepth]
		 je   .15dontdofulldepthsearch

		xor   r9, r9
		mov   r8d, dword[.newDepth]
		lea   r10, [QSearch_NonPv_InCheck]
		lea   r11, [QSearch_NonPv_NoCheck]
		cmp   byte[.givesCheck], 0
	     cmovne   r11, r10
		lea   rax, [Search_NonPv]
		cmp   r8d, 1
	      cmovl   rax, r11
	      cmovl   r8d, r9d
		mov   edx, dword[.alpha]
		neg   edx
		lea   ecx, [rdx-1]
		mov   r9l, byte[.cutNode]
		xor   r9l, -1
	       call   rax
		neg   eax
		mov   dword[.value], eax

		cmp   eax, dword[.alpha]
		jle   .17entry

.15dontdofulldepthsearch:
    if .PvNode eq 1
	if .RootNode eq 0
		mov   eax, dword[.value]
		cmp   eax, dword[.beta]
		jge   .17entry
	end if
		lea   rax, [.pv]
		mov   qword[rbx+State.pv], rax
		mov   dword[rax], 0

		xor   r9, r9
		mov   r8d, dword [.newDepth]
		lea   r10, [QSearch_Pv_InCheck]
		lea   r11, [QSearch_Pv_NoCheck]
		cmp   byte[.givesCheck], 0
	     cmovne   r11, r10
		lea   rax, [Search_Pv]
		cmp   r8d, 1
	      cmovl   rax, r11
	      cmovl   r8d, r9d
		mov   ecx, dword[.beta]
		neg   ecx
		mov   edx, dword[.alpha]
		neg   edx
		xor   r9d, r9d
	       call   rax
		neg   eax
		mov   dword[.value], eax
    end if
		jmp   .17entry



.15skip:

	; Step 16. full depth search   this is for when step 15 is skipped
    if .PvNode eq 1
		cmp   dword[.moveCount], 1
		jbe   .DoFullPvSearch
    end if

 .FullDepthSearch:
		xor   r9, r9
		mov   r8d, dword[.newDepth]
		lea   r10, [QSearch_NonPv_InCheck]
		lea   r11, [QSearch_NonPv_NoCheck]
		cmp   byte[.givesCheck], 0
	     cmovne   r11, r10
		lea   rax, [Search_NonPv]
		cmp   r8d, 1
	      cmovl   rax, r11
	      cmovl   r8d, r9d
		mov   edx, dword[.alpha]
		neg   edx
		lea   ecx, [rdx-1]
		mov   r9l, byte[.cutNode]
		xor   r9l, -1
	       call   rax
		neg   eax
		mov   edi, eax
		mov   dword[.value], eax



    if .PvNode eq 1
		cmp   edi, dword[.alpha]
		jle   .SkipFullPvSearch
	if .RootNode eq 0
		cmp   edi, dword[.beta]
		jge   .SkipFullPvSearch
	end if


 .DoFullPvSearch:
		lea   rax, [.pv]
		mov   qword[rbx+State.pv], rax
		mov   dword[rax], 0

		xor   r9, r9
		mov   r8d, dword [.newDepth]
		lea   r10, [QSearch_Pv_InCheck]
		lea   r11, [QSearch_Pv_NoCheck]
		cmp   byte[.givesCheck], 0
	     cmovne   r11, r10
		lea   rax, [Search_Pv]
		cmp   r8d, 1
	      cmovl   rax, r11
	      cmovl   r8d, r9d
		mov   ecx, dword[.beta]
		neg   ecx
		mov   edx, dword[.alpha]
		neg   edx
		xor   r9d, r9d
	       call   rax
		neg   eax
		mov   edi, eax
		mov   dword[.value], eax
 .SkipFullPvSearch:
    end if



	; Step 17. Undo move
.17entry:
		mov   ecx, dword[.move]
	       call   Move_Undo

	; Step 18. Check for new best move

		mov   edi, dword[.value]
		xor   eax, eax
		cmp   al, byte[signals.stop]
		jne   .Return

    if .RootNode eq 1
		mov   ecx, dword[.move]
		mov   rdx, qword[rbp+Pos.rootMovesVec+RootMovesVec.table]
		lea   rdx, [rdx-sizeof.RootMove]
	.FindRootMove:
		lea   rdx, [rdx+sizeof.RootMove]
	     Assert   b, rdx, qword[rbp+Pos.rootMovesVec+RootMovesVec.ender], 'cant find root move'
		cmp   ecx, dword[rdx+RootMove.pv+4*0]
		jne   .FindRootMove
		mov   esi, 1
		mov   r10d, -VALUE_INFINITE
		cmp   esi, dword[.moveCount]
		 je   .FoundRootMove1
		cmp   edi, dword[.alpha]
		jle   .FoundRootMoveDone
if USE_WEAKNESS
		cmp   dword[rbp-Thread.rootPos+Thread.PVIdx], 0
		jne   .FoundRootMove1
end if
	     vmovsd   xmm0, qword[rbp-Thread.rootPos+Thread.bestMoveChanges]
	     vaddsd   xmm0, xmm0, qword[constd.1p0]
	     vmovsd   qword[rbp-Thread.rootPos+Thread.bestMoveChanges], xmm0
.FoundRootMove1:
		mov   r10d, edi
		mov   rcx, qword[rbx+1*sizeof.State+State.pv]
		jmp   .CopyRootPvw
    .CopyRootPv:
		add   rcx, 4
		mov   dword[rdx+RootMove.pv+4*rsi], eax
		add   esi, 1
    .CopyRootPvw:
		mov   eax, dword[rcx]
	       test   eax, eax
		jnz   .CopyRootPv
		mov   dword[rdx+RootMove.pvSize], esi
.FoundRootMoveDone:
		mov   dword[rdx+RootMove.score], r10d
    end if


	; check for new best move
		mov   ecx, dword[.move]
		cmp   edi, dword[.bestValue]
		jle   .18NoNewBestValue
		mov   dword[.bestValue], edi

		cmp   edi, dword[.alpha]
		jle   .18NoNewAlpha
		mov   dword[.bestMove], ecx

    if .PvNode eq 1
		cmp   dword[rbp-Thread.rootPos+Thread.idx], 0
		jne   .18skipeasy
		mov   rcx, qword[rbx+State.key]
	       call   EasyMoveMng_Get
	       test   eax, eax
		 jz   .18skipeasy
		cmp   eax, dword[.move]
		jne   .18easy
		cmp   dword[.moveCount], 1
		jbe   .18skipeasy
.18easy:
	       call   EasyMoveMng_Clear

.18skipeasy:
    end if

    if .PvNode eq 1
    if .RootNode eq 0

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
    end if
    end if


    if .PvNode eq 1
		cmp   edi, dword[.beta]
		jge   .18fail_high
		mov   dword[.alpha], edi
		jmp   .18NoNewBestValue
    end if

.18fail_high:
	     Assert   ge, edi, dword[.beta], 'did not fail high in Search'
		jmp   .MovePickDone

.18NoNewAlpha:
.18NoNewBestValue:

		mov   ecx, dword[.move]
		mov   eax, dword[.quietCount]
		cmp   byte[.captureOrPromotion], 0
		jnz   .18Done
		cmp   ecx, dword[.bestMove]
		 je   .18Done
		cmp   eax, 64
		jae   .18Done
		mov   dword[.quietsSearched+4*rax], ecx
		add   eax, 1
		mov   dword[.quietCount], eax
.18Done:

		jmp   .MovePickLoop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.MovePickDone:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	; Step 20. Check for mate and stalemate
		mov   edi, dword[.bestValue]
		mov   edx, dword[.bestMove]
		cmp   dword[.moveCount], 0
		 je   .20Mate
	       test   edx, edx
		 jz   .20CheckBonus
.20Quiet:
		mov   ecx, dword[.bestMove]
		mov   edx, dword[.depth]
		lea   r8, [.quietsSearched]
		mov   r9d, dword[.quietCount]
	       call   UpdateStats
		jmp   .20TTStore
.20Mate:
		mov   rax, qword[rbx+State.checkersBB]
		mov   edx, dword[.excludedMove]
		mov   ecx, dword[rbp+Pos.sideToMove]
	      movzx   edi, byte[rbx+State._ply]
		sub   edi, VALUE_MATE
	       test   rax, rax
	      cmovz   edi, dword[DrawValue+4*rcx]
	       test   edx, edx
	     cmovnz   edi, dword[.alpha]
		jmp   .20TTStore
.20CheckBonus:
	; we already checked that bestMove = 0
		mov   eax, dword[rbx-1*sizeof.State+State.currentMove]
		lea   ecx, [eax-1]
		mov   edx, dword[.depth]
		sub   edx, 3*ONE_PLY
		 or   edx, ecx
		 js   .20TTStore
		cmp   byte[rbx+State.capturedPiece], 0
		jne   .20TTStore

		mov   r10d, dword[.depth]
		mov   edx, r10d
	       imul   r10d, r10d
		lea   r10d, [r10+2*rdx-2]

		and   eax, 63
	      movzx   r8d, byte[rbp+Pos.board+rax]
		shl   r8d, 6
		add   r8d, eax
		shl   r8d, 2

	       imul   r11d, r10d, 32
		cmp   r10d, 324
		jae   .20TTStore

		mov   r9, qword[rbx-2*sizeof.State+State.counterMoves]
	       test   r9, r9
		 jz   @f
		add   r9, r8
	apply_bonus   r9, r11d, r10d, 936
	@@:
		mov   r9, qword[rbx-3*sizeof.State+State.counterMoves]
	       test   r9, r9
		 jz   @f
		add   r9, r8
	apply_bonus   r9, r11d, r10d, 936
	@@:
		mov   r9, qword[rbx-5*sizeof.State+State.counterMoves]
	       test   r9, r9
		 jz   @f
		add   r9, r8
	apply_bonus   r9, r11d, r10d, 936
	@@:

.20TTStore:


	; edi = bestValue
		mov   r9, qword[.posKey]
		lea   ecx, [rdi+VALUE_MATE_IN_MAX_PLY]
		mov   r8, qword[.tte]
		shr   r9, 48
		mov   edx, edi
		cmp   ecx, 2*VALUE_MATE_IN_MAX_PLY
		jae   .20ValueToTT
	.20ValueToTTRet:
    if .PvNode eq 0
		mov   eax, dword[.bestMove]
		xor   esi, esi
		cmp   edi, dword[.beta]
	      setge   sil
		add   esi, BOUND_UPPER
    else
		mov   eax, dword[.bestMove]
		mov   ecx, BOUND_LOWER
		cmp   eax, 1
		sbb   esi, esi
		lea   esi, [(BOUND_EXACT-BOUND_UPPER)*rsi+BOUND_EXACT]
		cmp   edi, dword[.beta]
	     cmovge   esi, ecx
    end if
      MainHash_Save   .ltte, r8, r9w, edx, sil, byte[.depth], eax, word[rbx+State.staticEval]
		mov   eax, edi

match =2, VERBOSE \{
push rsi rdi rax rcx rdx r8 r9 r13 r14 r15
mov r15, rax
lea rdi, [VerboseOutput]
mov eax,'s<'
stosw
match =_ROOT_NODE, NT
\\{
mov al, '2'
\\}
match =_PV_NODE, NT
\\{
mov al, '1'
\\}
match =_NONPV_NODE, NT
\\{
mov al, '0'
\\}
stosb
mov eax, '>r'
stosw
movsxd rax, r15d
call PrintSignedInteger
PrintNewLine
lea rcx, [VerboseOutput]
call _WriteOut
pop r15 r14 r13 r9 r8 rdx rcx rax rdi rsi
\}


.Return:
		add   rsp, .localsize
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

.ValueFromTT:
	      movzx   r8d, byte[rbx+State._ply]
		mov   r9d, edi
		sar   r9d, 31
		xor   r8d, r9d
		add   edi, r9d
		sub   edi, r8d
		jmp   .ValueFromTTRet


.IllegalMove:
		mov   eax, dword[.moveCount]
		sub   eax, 1
		mov   dword[rbx+State.moveCount], eax
		mov   dword[.moveCount], eax
		jmp   .MovePickLoop



if .RootNode eq 0
	      align  8
.AbortSearch_PlyBigger:
		mov   rcx, qword[rbx+State.checkersBB]
		mov   eax, dword[rbp+Pos.sideToMove]
		mov   eax, dword[DrawValue+4*rax]
	       test   rcx, rcx
		 jz   .Return
	       call   Evaluate
		jmp   .Return

	      align   8
.AbortSearch_PlySmaller:
		mov   eax, dword[rbp+Pos.sideToMove]
		mov   eax, dword[DrawValue+4*rax]
		jmp   .Return
end if


    if .PvNode eq 0

	      align   8
.ReturnTTValue:
		mov   eax, edi
		;mov   dword[rbx+State.currentMove], ecx
		cmp   edi, dword[.beta]
		 jl   .Return
	       test   ecx, ecx
		 jz   .Return
		mov   edx, dword[.depth]
		xor   r8, r8
		xor   r9d, r9d
	       call   UpdateStats
		mov   eax, edi
		jmp   .Return
    end if


	      align   8
.20ValueToTT:
	      movzx   edx, byte[rbx+State._ply]
		mov   eax, edi
		sar   eax, 31
		xor   edx, eax
		sub   edx, eax
		add   edx, edi
		jmp   .20ValueToTTRet

    if .RootNode eq 0
	      align   8
.CheckDrawBy50:
   PosIsDrawCheck50   .AbortSearch_PlySmaller, r8
		jmp   .NoDrawBy50




if USE_SYZYGY
	      align 8
.CheckTablebase:
		mov   ecx, dword[.depth]
		mov   rax, qword[rbp+Pos.typeBB+8*White]
		 or   rax, qword[rbp+Pos.typeBB+8*Black]
	     popcnt   rax, rax, rdx
		cmp   ecx, dword[Tablebase_ProbeDepth]
		jge   .DoTbProbe
		cmp   eax, dword[Tablebase_Cardinality]
		jge   .CheckTablebaseReturn
.DoTbProbe:
		lea   rcx, [.success]
	       call   Tablebase_ProbeWDL
		mov   edx, dword[.success]
	       test   edx, edx
		 jz   .CheckTablebaseReturn

	      movsx   ecx, byte[Tablebase_UseRule50]
		lea   edx, [2*rax]
		and   edx, ecx
		mov   edi, edx

		mov   r8d, -VALUE_MATE + MAX_PLY
	      movzx   r9d, byte[rbx+State._ply]
		add   r9d, r8d
		cmp   eax, ecx
	      cmovl   edx, r8d
	      cmovl   edi, r9d
		neg   ecx
		mov   r8d, VALUE_MATE - MAX_PLY
		neg   r9d
		cmp   eax, ecx
	      cmovg   edx, r8d
	      cmovg   edi, r9d
	; edi = value
	; edx = value_to_tt(value, ss->ply)

		inc   qword[rbp-Thread.rootPos+Thread.tbHits]

		mov   r9, qword[.posKey]
		lea   ecx, [rdi+VALUE_MATE_IN_MAX_PLY]
		mov   r8, qword[.tte]
		shr   r9, 48
		mov   eax, MAX_PLY - 1
		mov   esi, dword[.depth]
		add   esi, 6
		cmp   esi, eax
	      cmovg   esi, eax
		xor   eax, eax
      MainHash_Save   .ltte, r8, r9w, edx, BOUND_EXACT, sil, eax, VALUE_NONE
		mov   eax, edi
		jmp   .Return
    end if
end if


if USE_CURRMOVE
if VERBOSE < 2
    if .RootNode eq 1
	      align   8
.PrintCurrentMove:
		cmp   byte[options.displayInfoMove], 0
		 je   .PrintCurrentMoveRet
		sub   rsp, 128
		mov   rdi, rsp
		mov   rax, 'info dep'
	      stosq
		mov   eax, 'th '
	      stosd
		sub   rdi, 1
		mov   eax, dword[.depth+128]
	       call   PrintUnsignedInteger
		mov   rax, ' currmov'
	      stosq
		mov   eax, 'e '
	      stosw
		mov   ecx, dword[.move+128]
		mov   edx, dword[rbp+Pos.chess960]
	       call   PrintUciMove
		mov   rax, ' currmov'
	      stosq
		mov   rax, 'enumber '
	      stosq
		mov   eax, dword[.moveCount+128]
		add   eax, dword[rbp-Thread.rootPos+Thread.PVIdx]
	       call   PrintUnsignedInteger
		mov   rcx, rsp
       PrintNewLine
	       call   _WriteOut
		add   rsp, 128
		jmp   .PrintCurrentMoveRet
    end if
end if
end if

}
