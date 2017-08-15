
Tablebase_Probe_AB:
	; in: rbp address of position
	;     rbx address of state
	;     ecx  alpha
	;     edx  beta
	;     r15  address of success
	; out: eax v

               push   rsi rdi r12 r13 r14
                mov   rax, qword[rbx+State.checkersBB]
                mov   r12d, ecx
                mov   r13d, edx
        ; r12d = alpha, r13d = beta

        ; Generate (at least) all legal captures including (under)promotions.
        ; It is OK to generate more, as long as they are filtered out below.
                mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
                mov   rsi, rdi
               call   Gen_Legal
                mov   qword[rbx+State.endMoves], rdi

        ; loop through moves
                sub   rsi, sizeof.ExtMove
.MoveLoop:
		add   rsi, sizeof.ExtMove
		mov   ecx, dword[rsi+ExtMove.move]
                mov   eax, ecx
		and   eax, 63
                mov   edx, ecx
                shr   edx, 14
	      movzx   eax, byte[rbp+Pos.board+rax]
		cmp   rsi, rdi
		jae   .MovesDone
		 or   al, byte[_CaptureOrPromotion_or+rdx]
		and   al, byte[_CaptureOrPromotion_and+rdx]
		 jz   .MoveLoop
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+ExtMove.move]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_ProbeAB
		mov   ecx, r13d
		mov   edx, r12d
		neg   ecx
		neg   edx
	       call   Tablebase_Probe_AB
		neg   eax
	       push   rax
		mov   ecx, dword[rsi+ExtMove.move]
	       call   Move_Undo
		pop   rax
		xor   edx, edx
		cmp   edx, dword[r15]
	      cmove   eax, edx
		 je   .Return	     ; failed
		cmp   eax, r12d
		jle   .MoveLoop
		cmp   eax, r13d
		jge   .Return
		mov   r12d, eax
		jmp   .MoveLoop
.MovesDone:

		mov   rcx, rbp
		mov   rdx, r15
		sub   rsp, 8*4
	       call   _ZN13TablebaseCore15probe_wdl_tableER8PositionPi
		add   rsp, 8*4

		cmp   eax, r12d
             cmovle   eax, r12d
.Return:
		pop   r14 r13 r12 rdi rsi
		ret






Tablebase_Probe_WDL:
	; in: rbp address of position
	;     rbx address of state
	;     r15  address of success
	; out: eax v

               push   rsi rdi r12 r13 r14
                mov   dword[r15], 1

        ; Generate (at least) all legal captures including (under)promotions.
                mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
                mov   rsi, rdi
               call   Gen_Legal
                mov   qword[rbx+State.endMoves], rdi

                mov   r12d, -3
                mov   r13d, r12d
        ; r12d = best_cap, r13d = best_ep

        ; We do capture resolution, letting best_cap keep track of the best
        ; capture without ep rights and letting best_ep keep track of still
        ; better ep captures if they exist.
                sub   rsi, sizeof.ExtMove
.MoveLoop:
		add   rsi, sizeof.ExtMove
		mov   ecx, dword[rsi+ExtMove.move]
                mov   eax, ecx
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
                mov   edx, ecx
                shr   edx, 14
		cmp   rsi, rdi
		jae   .MovesDone
		 or   al, byte[_CaptureOrPromotion_or+rdx]
		and   al, byte[_CaptureOrPromotion_and+rdx]
		 jz   .MoveLoop
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+ExtMove.move]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_ProbeWDL
		mov   edx, r12d
		mov   ecx, -2
		neg   edx
	       call   Tablebase_Probe_AB
		neg   eax
	       push   rax
		mov   ecx, dword[rsi+ExtMove.move]
	       call   Move_Undo
		pop   rax
		xor   edx, edx
		mov   ecx, dword[rsi+ExtMove.move]
		cmp   edx, dword[r15]
	      cmove   eax, edx
		 je   .Return	     ; failed
                add   edx, 2
                cmp   eax, r12d
                jle   .MoveLoop
                cmp   eax, edx
                 je   .ReturnStoreSuccess
                shr   ecx, 12
                cmp   ecx, MOVE_TYPE_EPCAP
             cmovne   r12d, eax
                jne   .MoveLoop
                cmp   eax, r13d
              cmovg   r13d, eax
                jmp   .MoveLoop
.MovesDone:

		mov   rcx, rbp
		mov   rdx, r15
		sub   rsp, 8*4
	       call   _ZN13TablebaseCore15probe_wdl_tableER8PositionPi
		add   rsp, 8*4
                mov   edx, dword[r15]

                mov   r14d, eax
                xor   eax, eax
                cmp   eax, dword[r15]
                 je   .Return
        ; r14d = v

        ; Now max(v, best_cap) is the WDL value of the position without ep rights.
        ; If the position without ep rights is not stalemate or no ep captures
        ; exist, then the value of the position is max(v, best_cap, best_ep).
        ; If the position without ep rights is stalemate and best_ep > -3,
        ; then the value of the position is best_ep (and we will have v == 0).
                mov   eax, r13d
                mov   edx, 2
                cmp   r13d, r12d
                jle   @f
                cmp   r13d, r14d
                 jg   .ReturnStoreSuccess
                mov   r12d, r13d
        @@:

        ; Now max(v, best_cap) is the WDL value of the position unless
        ; the position without ep rights is stalemate and best_ep > -3.
                mov   eax, r12d
                lea   ecx, [rax-1]
                sar   ecx, 31
                add   edx, ecx
                cmp   r12d, r14d
                jge   .ReturnStoreSuccess

        ; Now handle the stalemate case.
                mov   eax, r14d
                cmp   r13d, -3
                jle   .Return
               test   eax, eax
                jnz   .Return
        ; check for stalemate in the position with ep captures
                mov   rsi, qword[rbx-1*sizeof.State+State.endMoves]
		jmp   .CheckLoop
.CheckNext:	mov   ecx, dword[rsi+ExtMove.move]
		shr   ecx, 12
		cmp   ecx, MOVE_TYPE_EPCAP
		jne   .Return
		add   rsi, sizeof.ExtMove
.CheckLoop:	cmp   rsi, rdi
		 jb   .CheckNext
                mov   edx, 2
                mov   eax, r13d

.ReturnStoreSuccess:
                mov   dword[r15], edx
.Return:
		pop   r14 r13 r12 rdi rsi
		ret



Tablebase_Probe_DTZ:
	; in: rbp address of position
	;     rbx address of state
	;     r15  address of success
	; out: eax v

               push   rsi rdi r12 r13 r14

               call   Tablebase_Probe_WDL
                mov   r14d, eax
                mov   edx, dword[r15]
                xor   eax, eax
               test   edx, edx
                 jz   .Return
               test   r14d, r14d
                 je   .Return
                lea   eax, [r14+2]
              movsx   eax, byte[WDLtoDTZ+rax]

                mov   r13d, eax
                cmp   edx, 2
                 je   .Return

                mov   rdi, qword[rbx-1*sizeof.State+State.endMoves]
                mov   rsi, rdi
               call   Gen_Legal
                mov   qword[rbx+State.endMoves], rdi

        ; If winning, check for a winning pawn move.
                sub   rsi, sizeof.ExtMove
                cmp   r14d, 0
                jle   .MovesDone1
.MoveLoop1:
		add   rsi, sizeof.ExtMove
		mov   ecx, dword[rsi+ExtMove.move]
                mov   eax, ecx
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
                mov   edx, ecx
                shr   edx, 14
		cmp   rsi, rdi
		jae   .MovesDone1
		 or   al, byte[_CaptureOrPromotion_or+rdx]
		and   al, byte[_CaptureOrPromotion_and+rdx]
		jnz   .MoveLoop1
                mov   eax, ecx
                shr   eax, 6
                and   eax, 63
              movzx   eax, byte[rbp+Pos.board+rax]
                and   eax, 7
                cmp   eax, Pawn
                jne   .MoveLoop1
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+ExtMove.move]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_ProbeDTZ
	       call   Tablebase_Probe_WDL
		neg   eax
	       push   rax
		mov   ecx, dword[rsi+ExtMove.move]
	       call   Move_Undo
		pop   rax

		xor   edx, edx
		cmp   edx, dword[r15]
	      cmove   eax, edx
		 je   .Return	     ; failed


                cmp   eax, r14d
                mov   eax, r13d
                 je   .Return
                jmp   .MoveLoop1
.MovesDone1:

        ; If we are here, we know that the best move is not an ep capture.
        ; In other words, the value of wdl corresponds to the WDL value of
        ; the position without ep rights. It is therefore safe to probe the
        ; DTZ table with the current value of wdl.

		sub   rsp, 8*4
		mov   rcx, rbp
		mov   edx, r14d
		mov   r8, r15
	       call   _ZN13TablebaseCore15probe_dtz_tableER8PositioniPi
		add   rsp, 8*4
                mov   edx, dword[r15]

                mov   r12d, 0x7FFFFFFF
                lea   ecx, [r13+rax]
                sub   eax, r13d
                neg   eax
                cmp   r14d, 0
             cmovle   r12d, r13d
              cmovg   eax, ecx


               test   edx, edx
                jns   .Return
        ; r12d = best

        ; *success < 0 means we need to probe DTZ for the other side to move.

        ; We can skip pawn moves and captures.
        ; If wdl > 0, we already caught them. If wdl < 0, the initial value
        ; of best already takes account of them.
                mov   rsi, qword[rbx-1*sizeof.State+State.endMoves]
                sub   rsi, sizeof.ExtMove
.MoveLoop2:
		add   rsi, sizeof.ExtMove
		mov   ecx, dword[rsi+ExtMove.move]
                mov   eax, ecx
		and   eax, 63
	      movzx   eax, byte[rbp+Pos.board+rax]
                mov   edx, ecx
                shr   edx, 14
		cmp   rsi, rdi
		jae   .MovesDone2
		 or   al, byte[_CaptureOrPromotion_or+rdx]
		and   al, byte[_CaptureOrPromotion_and+rdx]
		jnz   .MoveLoop2
                mov   eax, ecx
                shr   eax, 6
                and   eax, 63
              movzx   eax, byte[rbp+Pos.board+rax]
                and   eax, 7
                cmp   eax, Pawn
                 je   .MoveLoop2
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+ExtMove.move]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_ProbeDTZ
	       call   Tablebase_Probe_DTZ
		neg   eax
	       push   rax
		mov   ecx, dword[rsi+ExtMove.move]
	       call   Move_Undo
		pop   rax
		xor   edx, edx
		cmp   edx, dword[r15]
	      cmove   eax, edx
		 je   .Return	     ; failed
                cmp   r14d, 0
                 jg   .WdlIsPos
                sub   eax, 1
                cmp   eax, r12d
              cmovl   r12d, eax
                jmp   .MoveLoop2
     .WdlIsPos:
                add   eax, 1
                cmp   eax, 1
                jle   .MoveLoop2
                cmp   eax, r12d
              cmovl   r12d, eax
                jmp   .MoveLoop2
.MovesDone2:
                mov   eax, r12d
.Return:
		pop   r14 r13 r12 rdi rsi
		ret




Tablebase_RootProbe:
	; in: rbp address of position
	;     rbx address of state
	; out: eax bool
	;          score is in Tablebase_Score
	       push   rbx rsi rdi r12 r13 r14 r15
virtual at rsp
	   rq 1
  .success rd 1
	   rd 1
  .mlist  rb MAX_MOVES*sizeof.ExtMove
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		lea   r15, [.success]
	       call   Tablebase_Probe_DTZ
		mov   edx, dword[.success]
		mov   r13d, eax
	; r13d = dtz
	       test   edx, edx
	      cmovz   eax, edx
		 jz   .Return

		mov   r12, qword[rbp+Pos.rootMovesVec.table]
.RootMoveLoop:
		cmp   r12, qword[rbp+Pos.rootMovesVec.ender]
		jae   .RootMovesDone

		mov   ecx, dword[r12+RootMove.pv+4*0]
	       call   Move_GivesCheck
		mov   ecx, dword[r12+RootMove.pv+4*0]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_RootProbe

		xor   esi, esi
	; esi = v

		mov   rcx, qword[rbx+State.checkersBB]
	       test   rcx, rcx
		 jz   @f
		cmp   r13d, 0
		jle   @f
		lea   rdi, [.mlist]
	       call   Gen_Legal
		lea   rax, [.mlist]
		cmp   rax, rdi
		jne   @f
		mov   esi, 1
                jmp   .UndoMove
	@@:

		cmp   word[rbx+State.rule50], 0
		 je   .Rule50Is0
    .Rule50IsNot0:
	       call   Tablebase_Probe_DTZ
		mov   esi, eax
		neg   esi
		lea   eax, [rsi+1]
		cmp   esi, 0
	      cmovg   esi, eax
		lea   eax, [rsi-1]
	       test   esi, esi
	      cmovs   esi, eax
		jmp   .UndoMove
    .Rule50Is0:
	       call   Tablebase_Probe_WDL
		neg   eax
		add   eax, 2
	      movsx   esi, byte[WDLtoDTZ+rax]

.UndoMove:

		mov   ecx, dword[r12+RootMove.pv+4*0]
	       call   Move_Undo
		mov   edx, dword[r15]
	       test   edx, edx
	      cmovz   eax, edx
		 jz   .Return
		mov   dword[r12+RootMove.score], esi
		add   r12, sizeof.RootMove
		jmp   .RootMoveLoop
.RootMovesDone:


	      movzx   r14d, word[rbx+State.rule50]
	; r14d = cnt50
		xor   edi, edi
	; esi = wdl
		mov   eax, r14d
		cmp   r13d, 0
		 jg   .DtzPos
		 je   @f
		mov   edi, -1
		mov   ecx, -2
		sub   eax, r13d
		cmp   eax, 100
	     cmovle   edi, ecx
		jmp   @f
.DtzPos:
		mov   edi, 1
		mov   ecx, 2
		add   eax, r13d
		cmp   eax, 100
	     cmovle   edi, ecx
@@:
	; edi = wdl
		lea   eax, [rdi+2]
		mov   eax, dword[wdl_to_Value5+4*rax]
	; eax = score
.TestA:
		cmp   edi, 1
		jne   .TestB
		cmp   r13d, 100
		 jg   .TestB
		mov   eax, 200
		sub   eax, r13d
		sub   eax, r14d
		mov   ecx, PawnValueEg
	       imul   eax, ecx
		cdq
		mov   ecx, 200
	       idiv   ecx
		jmp   .TestDone
.TestB:
		cmp   edi, -1
		jne   .TestDone
		cmp   r13d, -100
		 jl   .TestDone
		mov   eax, 200
		add   eax, r13d
		sub   eax, r14d
		mov   ecx, PawnValueEg
	       imul   eax, ecx
		cdq
		mov   ecx, 200
	       idiv   ecx
		neg   eax
.TestDone:
		mov   dword[Tablebase_Score], eax
		mov   rdi, qword[rbp+Pos.rootMovesVec.table]
		cmp   r13d, 0
		 jg   .Winning
		 jl   .Losing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Drawing:
		lea   rsi, [rdi-sizeof.RootMove]
.Drawing1:
		add   rsi, sizeof.RootMove
.Drawing1a:
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .Drawing1Done
		mov   eax, dword[rsi+RootMove.score]
	       test   eax, eax
		jnz   .Drawing1

if VERBOSE = 2
mov ecx, [rsi+RootMove.pv+4*0]
Display 2,"DTZ filtered drawing move %m1%n"
end if

		mov   ecx, sizeof.RootMove
	  rep movsb
		jmp   .Drawing1a
.Drawing1Done:

;;;;;;;;;;;;;;;;;;;;;;;;;
.Resize:
		mov   qword[rbp+Pos.rootMovesVec.ender], rdi

.ReturnTrue:
		 or   eax, -1
.Return:

                add   rsp, .localsize
                pop   r15 r14 r13 r12 rdi rsi rbx
                ret

;;;;;;;;;;;;;;;;;;;;;;;;
.Winning:
		mov   r12d, 0x0FFFF
	; r12d = best
		lea   rsi, [rdi-sizeof.RootMove]
.Winning1:
		add   rsi, sizeof.RootMove
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .Winning1Done
		mov   eax, dword[rsi+RootMove.score]
		cmp   eax, 0
		jle   .Winning1
		cmp   eax, r12d
		jge   .Winning1
		mov   r12d, eax
		jmp   .Winning1
.Winning1Done:
		mov   r11d, r12d
	; r11d = max

		lea   eax, [r12+r14]
		cmp   eax, 99
		 jg   .WinningDontMax

		mov   r8, rbx
	; r8 = st
 .WinningLoop:
		mov   ecx, 4
	; ecx = i
	      movzx   edx, word[r8+State.rule50]
	      movzx   eax, word[r8+State.pliesFromNull]
		cmp   edx, eax
	      cmova   edx, eax
		lea   r9, [r8-2*sizeof.State]
	; r9 = *stp = st->previous->previous
		cmp   edx, ecx
		 jb   .WinningDoMax
  .WinningStateLoop:
		sub   r9, 2*sizeof.State
		mov   rax, qword[r9+State.key]
		cmp   rax, qword[r8+State.key]
		 je   .WinningDontMax
		add   ecx, 2
		cmp   ecx, edx
		jbe   .WinningStateLoop
		sub   r8, 1*sizeof.State
		jmp   .WinningLoop
.WinningDoMax:
		mov   r11d, 99
		sub   r11d, r14d
.WinningDontMax:
		lea   rsi, [rdi-sizeof.RootMove]
.Winning2:
		add   rsi, sizeof.RootMove
.Winning2a:
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .Winning2Done
		mov   eax, dword[rsi+RootMove.score]
		cmp   eax, 0
		jle   .Winning2
		cmp   eax, r11d
		 jg   .Winning2

if VERBOSE = 2
mov ecx, [rsi+RootMove.pv+4*0]
Display 2, "DTZ filtered winning move %m1%n"
end if

		mov   ecx, sizeof.RootMove
	  rep movsb
		jmp   .Winning2a
.Winning2Done:
		jmp   .Resize

;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Losing:
		xor   edx, edx
	; edx = best
		lea   rsi, [rdi-sizeof.RootMove]
.Losing1:
		add   rsi, sizeof.RootMove
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .Losing1Done
		mov   eax, dword[rsi+RootMove.score]
		cmp   eax, edx
	      cmovl   edx, eax
		jmp   .Losing1
.Losing1Done:

		mov   eax, r14d
		sub   eax, edx
		sub   eax, edx
		cmp   eax, 100
		 jl   .ReturnTrue

		lea   rsi, [rdi-sizeof.RootMove]
.Losing2:
		add   rsi, sizeof.RootMove
.Losing2a:
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .Losing2Done
		mov   eax, dword[rsi+RootMove.score]
		cmp   eax, edx
		jne   .Losing2

if VERBOSE = 2
mov ecx, [rsi+RootMove.pv+4*0]
Display 2, "DTZ filtered losing move %m1%n"
end if

		mov   ecx, sizeof.RootMove
	  rep movsb
		jmp   .Losing2a
.Losing2Done:
		jmp   .Resize





Tablebase_RootProbeWDL:
	; in: rbp address of position
	;     rbx address of state
	; out: eax bool
	;          score is in Tablebase_Score

	       push   rsi rdi r12 r13 r15
virtual at rsp
  .success rd 1
	   rd 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
		lea   r15, [.success]

	       call   Tablebase_Probe_WDL
		mov   edx, dword[.success]
	       test   edx, edx
	      cmovz   eax, edx
		 jz   .Return
		add   eax, 2
		mov   eax, dword[wdl_to_Value5+4*rax]
		mov   dword[Tablebase_Score], eax

		mov   r12d, -2
	; r12d = best

		mov   rsi, qword[rbp+Pos.rootMovesVec.table]
.RootMoveLoop:
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .RootMovesDone
		mov   ecx, dword[rsi+RootMove.pv+4*0]
	       call   Move_GivesCheck
		mov   ecx, dword[rsi+RootMove.pv+4*0]
		mov   byte[rbx+State.givesCheck], al
	       call   Move_Do__Tablebase_RootProbeWDL
	       call   Tablebase_Probe_WDL
		neg   eax
		mov   edi, eax
		mov   ecx, dword[rsi+RootMove.pv+4*0]
	       call   Move_Undo
		mov   eax, dword[.success]
	       test   eax, eax
		 jz   .Return
		mov   dword[rsi+RootMove.score], edi
		cmp   edi, r12d
	      cmovg   r12d, edi
		add   rsi, sizeof.RootMove
		jmp   .RootMoveLoop
.RootMovesDone:

		mov   rdi, qword[rbp+Pos.rootMovesVec.table]
		lea   rsi, [rdi-sizeof.RootMove]
.Copy:
		add   rsi, sizeof.RootMove
.Copya:
		cmp   rsi, qword[rbp+Pos.rootMovesVec.ender]
		jae   .CopyDone
		mov   eax, dword[rsi+RootMove.score]
		cmp   eax, r12d
		jne   .Copy

if VERBOSE = 2
mov ecx, [rsi+RootMove.pv+4*0]
Display 2, "WDL filtered move %m1%n"
end if

		mov   ecx, sizeof.RootMove
	  rep movsb
		jmp   .Copya
.CopyDone:
		mov   qword[rbp+Pos.rootMovesVec.ender], rdi
		 or   eax, -1
.Return:
		add   rsp, .localsize
		pop   r15 r13 r12 rdi rsi
		ret
