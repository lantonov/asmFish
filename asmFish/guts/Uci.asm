Options_Init:
		lea   rdx, [options]
		mov   byte[rdx+Options.displayInfoMove], -1
		mov   dword[rdx+Options.contempt], 0
		mov   dword[rdx+Options.threads], 1
		mov   dword[rdx+Options.hash], 16
		mov   byte[rdx+Options.ponder], 0
		mov   dword[rdx+Options.multiPV], 1
		mov   dword[rdx+Options.moveOverhead], 30
		mov   dword[rdx+Options.minThinkTime], 20
		mov   dword[rdx+Options.slowMover], 89
		mov   byte[rdx+Options.chess960], 0
		mov   dword[rdx+Options.syzygyProbeDepth], 1
		mov   byte[rdx+Options.syzygy50MoveRule], -1
		mov   dword[rdx+Options.syzygyProbeLimit], 6
		mov   byte[rdx+Options.largePages], 0

		lea   rcx, [rdx+Options.hashPathBuffer]
		mov   rax, '<empty>'
		mov   qword[rdx+Options.hashPath], rcx
		mov   qword[rcx], rax

		ret


UciLoop:


virtual at rsp
  .th1 Thread
  .th2 Thread
  .states rb 2*sizeof.State
  .limits Limits
  .time  rq 1
  .nodes rq 1
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

	       push   rbp rsi rdi rbx r11 r12 r13 r14 r15
	 _chkstk_ms   rsp, UciLoop.localsize
		sub   rsp, UciLoop.localsize

		mov   byte[options.displayInfoMove], -1

		xor   eax, eax
		mov   qword[UciLoop.th1.rootPos.stateTable], rax

		lea   rcx, [UciLoop.states]
		lea   rdx, [rcx+2*sizeof.State]
		mov   qword[UciLoop.th2.rootPos.state], rcx
		mov   qword[UciLoop.th2.rootPos.stateTable], rcx
		mov   qword[UciLoop.th2.rootPos.stateEnd], rdx

UciNewGame:
		mov   rcx, qword[UciLoop.th1.rootPos.stateTable]
		mov   rdx, qword[UciLoop.th1.rootPos.stateEnd]
		sub   rdx, rcx
	       call   _VirtualFree
		xor   eax, eax
		lea   rbp, [UciLoop.th1.rootPos]
		mov   qword[UciLoop.th1.rootPos.state], rax
		mov   qword[UciLoop.th1.rootPos.stateTable], rax
		mov   qword[UciLoop.th1.rootPos.stateEnd], rax
		lea   rsi, [szStartFEN]
		xor   ecx, ecx
	       call   Position_ParseFEN
	       call   Search_Clear

		mov   rsi, qword[CmdLineStart]
	       test   rsi, rsi
		jnz   UciChoose
		jmp   UciGetInput



UciNextCmdFromCmdLine:
	; skip to next cmd
	;  if we reach null char, it is time to read from stdin

		lea   rdi, [Output]
		lea   rcx, [sz_Info]
	       call   PrintString
	       call   _WriteOut_Output

		xor   r15, r15
.Next:
	      lodsb
	       test   al, al
		 jz   .Done
		cmp   al, ' '
		jae   .Next
	       call   SkipSpaces
		mov   r15, rsi
.Done:
		mov   rcx, qword[CmdLineStart]
		lea   rdi, [rsi-1]
	       call   _WriteOut
		lea   rcx, [sz_NewLine]
		lea   rdi, [sz_NewLineEnd]
	       call   _WriteOut

		mov   qword[CmdLineStart], r15
		mov   rsi, r15
	       test   r15, r15
		jnz   UciChoose
		jmp   UciQuit

UciWriteOut_NewLine:
       PrintNewLine

UciWriteOut:
	       call   _WriteOut_Output
UciGetInput:

GD_ResponseTime
		mov   rsi, qword[CmdLineStart]
	       test   rsi, rsi
		jnz   UciNextCmdFromCmdLine

	       call   _ReadIn
	       test   eax, eax
		jnz   UciQuit
GD_GetTime
		cmp   byte[rsi], ' '
		 jb   UciGetInput     ; don't process empty lines


UciChoose:
	       call   SkipSpaces

		lea   rcx, [sz_go]
	       call   CmpString
	       test   eax, eax
		jnz   UciGo

		lea   rcx, [sz_position]
	       call   CmpString
	       test   eax, eax
		jnz   UciPosition

		lea   rcx, [sz_stop]
	       call   CmpString
	       test   eax, eax
		jnz   UciStop

		lea   rcx, [sz_isready]
	       call   CmpString
	       test   eax, eax
		jnz   UciIsReady

		lea   rcx, [sz_ponderhit]
	       call   CmpString
	       test   eax, eax
		jnz   UciPonderHit

		lea   rcx, [sz_ucinewgame]    ; check before uci :)
	       call   CmpString
	       test   eax, eax
		jnz   UciNewGame

		lea   rcx, [sz_uci]
	       call   CmpString
	       test   eax, eax
		jnz   UciUci

		lea   rcx, [sz_setoption]
	       call   CmpString
	       test   eax, eax
		jnz   UciSetOption

		lea   rcx, [sz_quit]
	       call   CmpString
	       test   eax, eax
		jnz   UciQuit

		lea   rcx, [sz_perft]
	       call   CmpString
	       test   eax, eax
		jnz   UciPerft

		lea   rcx, [sz_bench]
	       call   CmpString
	       test   eax, eax
		jnz   UciBench

if VERBOSE > 0
	     szcall   CmpString, 'show'
	       test   eax, eax
		jnz   UciShow
	     szcall   CmpString, 'undo'
	       test   eax, eax
		jnz   UciUndo
	     szcall   CmpString, 'moves'
	       test   eax, eax
		jnz   UciMoves
	     szcall   CmpString, 'donull'
	       test   eax, eax
		jnz   UciDoNull
	     szcall   CmpString, 'eval'
	       test   eax, eax
		jnz   UciEval
end if

if USE_BOOK
	     szcall   CmpString, 'brain2polyglot'
	       test   eax, eax
		 jz   @f
	       call   Brain2Polyglot
		jmp   UciGetInput
	@@:


end if

if PROFILE > 0
	     szcall   CmpString, 'profile'
	       test   eax, eax
		jnz   UciProfile
end if

UciUnknown:
		lea   rdi, [Output]
	     szcall   PrintString, 'error: unknown command '
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut




UciQuit:
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_WaitForSearchFinished
		mov   rcx, qword[UciLoop.th1.rootPos.stateTable]
		mov   rdx, qword[UciLoop.th1.rootPos.stateEnd]
		sub   rdx, rcx
	       call   _VirtualFree
		xor   eax, eax
		add   rsp, UciLoop.localsize
		pop   r15 r14 r13 r12 r11 rbx rdi rsi rbp
		ret

;;;;;;;;
; uci
;;;;;;;;


UciUci:
		lea   rcx, [szUciResponse]
		lea   rdi, [szUciResponseEnd]
	       call   _WriteOut
		jmp   UciGetInput


;;;;;;;;;;;;
; isready
;;;;;;;;;;;;

UciIsReady:
		mov   al, byte[options.changed]
	       test   al, al
		 jz   .ok
	       call   UciSync
.ok:
		lea   rdi, [Output]
		mov   rax, 'readyok'
	      stosq
		sub   rdi, 1
       PrintNewLine
		jmp   UciWriteOut



;;;;;;;;;;;;;
; ponderhit
;;;;;;;;;;;;;

UciPonderHit:
		mov   al, byte[signals.stopOnPonderhit]
	       test   al, al
		jnz   @f
		mov   byte[limits.ponder], al
		jmp   UciGetInput
@@:
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
		jmp   UciGetInput
;;;;;;;;
; stop
;;;;;;;;

UciStop:
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_WaitForSearchFinished
		jmp   UciGetInput


UciSync:
	       push   rbx
	       call   MainHash_ReadOptions
	       call   ThreadPool_ReadOptions
		mov   byte[options.changed], 0
		pop   rbx
		ret

;;;;;;;
; go
;;;;;;;

UciGo:
		mov   al, byte[options.changed]
	       test   al, al
		 jz   .ok
	       call   UciSync
.ok:
		lea   rcx, [UciLoop.limits]
	       call   Limits_Init
.ReadLoop:
	       call   SkipSpaces
		cmp   byte[rsi], ' '
		 jb   .ReadLoopDone

		lea   rdi, [UciLoop.limits.time+4*White]
		lea   rcx, [sz_wtime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.time+4*Black]
		lea   rcx, [sz_btime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.incr+4*White]
		lea   rcx, [sz_winc]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.incr+4*Black]
		lea   rcx, [sz_binc]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.infinite]
		lea   rcx, [sz_infinite]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_true

		lea   rdi, [UciLoop.limits.movestogo]
		lea   rcx, [sz_movestogo]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.nodes]
		lea   rcx, [sz_nodes]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_qword

		lea   rdi, [UciLoop.limits.movetime]
		lea   rcx, [sz_movetime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.depth]
		lea   rcx, [sz_depth]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.mate]
		lea   rcx, [sz_mate]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword

		lea   rdi, [UciLoop.limits.ponder]
		lea   rcx, [sz_ponder]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_true

		lea   rcx, [sz_searchmoves]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_searchmoves


.Error:
		lea   rdi, [Output]
	     szcall   PrintString, 'error: unexpected token '
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut

.ReadLoopDone:
		lea   rcx, [UciLoop.limits]
	       call   Limits_Set
		lea   rcx, [UciLoop.limits]
	       call   ThreadPool_StartThinking
		jmp   UciGetInput

.parse_qword:
	       call   SkipSpaces
	       call   ParseInteger
		mov   qword[rdi], rax
		jmp   .ReadLoop
.parse_dword:
	       call   SkipSpaces
	       call   ParseInteger
		mov   dword[rdi], eax
		jmp   .ReadLoop
.parse_true:
		mov   byte[rdi], -1
		jmp   .ReadLoop
.parse_searchmoves:
	       call   SkipSpaces
	       call   ParseUciMove
	       test   eax, eax
		 jz   .ReadLoop
		mov   ecx, dword[UciLoop.limits.moveVecSize]
		lea   rdi, [UciLoop.limits.moveVec]
	repne scasw
	       test   ecx, ecx		   ; is the move already in the list?
		jnz   .parse_searchmoves
	      stosw
		add   dword[UciLoop.limits.moveVecSize], 1
		jmp   .parse_searchmoves


;;;;;;;;;;;;
; position
;;;;;;;;;;;;

UciPosition:
	       call   SkipSpaces
		cmp   byte[rsi], ' '
		 jb   UciUnknown

	; write to pos2 in case of failure
		lea   rbp, [UciLoop.th2.rootPos]

		lea   rcx, [sz_fen]
	       call   CmpString
	       test   eax, eax
		jnz   .Fen

		lea   rcx, [sz_startpos]
	       call   CmpString
	       test   eax, eax
		 jz   .BadCmd
.Start:
		mov   r15, rsi
		lea   rsi, [szStartFEN]
		xor   ecx, ecx
	       call   Position_ParseFEN
		mov   rsi, r15
		jmp   .check
.Fen:
	      movzx   ecx, byte[options.chess960]
	       call   Position_ParseFEN
.check:
	       test   eax, eax
		jnz   .illegal
.moves:
	; copy pos2 to pos  before parsing moves
		lea   rcx, [UciLoop.th1.rootPos]
	       call   Position_CopyTo
		lea   rbp, [UciLoop.th1.rootPos]

	       call   SkipSpaces
	     szcall   CmpString, 'moves'
	       test   eax, eax
		 jz   UciGetInput
	       call   UciParseMoves
	       test   rax, rax
		 jz   UciGetInput
.badmove:
		mov   rsi, rax
		lea   rdi, [Output]
	     szcall   PrintString, 'error: illegal move '
		mov   ecx, 6
	       call   ParseToken
       PrintNewLine
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciWriteOut
.illegal:
		lea   rdi, [Output]
	     szcall   PrintString, 'error: illegal fen'
       PrintNewLine
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciWriteOut
.BadCmd:
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciUnknown
UciParseMoves:
	; in: rbp position
	;     rsi string
	; rax = 0 if full string could be parsed
	;     = address of illegal move if there is one
	       push   rbx rsi rdi
.get_move:
	       call   SkipSpaces
		xor   eax, eax
		cmp   byte[rsi], ' '
		 jb   .done
	       call   ParseUciMove
		mov   edi, eax
	       test   eax, eax
		mov   rax, rsi
		 jz   .done
		mov   rbx, qword[rbp+Pos.state]
		mov   rax, rbx
		sub   rax, qword[rbp+Pos.stateTable]
		xor   edx, edx
		mov   ecx, sizeof.State
		div   ecx
	     Assert   e, edx, 0, 'weird remainder in UciParseMoves'
		lea   ecx, [rax+8]
		shr   ecx, 2
		add   ecx, eax
	       call   Position_SetExtraCapacity
		mov   rbx, qword[rbp+Pos.state]
		mov   ecx, edi
		mov   dword[rbx+sizeof.State+State.currentMove], edi
	       call   Move_GivesCheck
		mov   ecx, edi
		mov   edx, eax
	       call   Move_Do__UciParseMoves
	; when VERBOSE=0, domove/undomove don't update gamPly
match =0, VERBOSE {
		inc   dword[rbp+Pos.gamePly]
}
		mov   qword[rbp+Pos.state], rbx
	       call   SetCheckInfo
		jmp   .get_move
.done:
		pop   rdi rsi rbx
		ret



;;;;;;;;;;;;
; setoption
;;;;;;;;;;;;


UciSetOption:
		mov   rax, qword[threadPool.threadTable+8*0]
		mov   al, byte[rax+Thread.searching]
		lea   rcx, [sz_error_think]
	       test   al, al
		jnz   .Error
.Read:
	       call   SkipSpaces
		lea   rcx, [sz_name]
	       call   CmpString
		lea   rcx, [sz_error_name]
	       test   eax, eax
		 jz   .Error
	       call   SkipSpaces

		lea   rcx, [sz_threads]
	       call   CmpStringCaseless
		lea   rbx, [.Threads]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_hash]
	       call   CmpStringCaseless
		lea   rbx, [.Hash]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_largepages]
	       call   CmpStringCaseless
		lea   rbx, [.LargePages]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_nodeaffinity]
	       call   CmpStringCaseless
		lea   rbx, [.NodeAffinity]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_priority]
	       call   CmpStringCaseless
		lea   rbx, [.Priority]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_clear_hash]  ; arena may send Clear Hash
	       call   CmpStringCaseless     ;  instead of ClearHash
	       test   eax, eax		    ;
		jnz   .ClearHash	    ;

		lea   rcx, [sz_ponder]
	       call   CmpStringCaseless
		lea   rbx, [.Ponder]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_contempt]
	       call   CmpStringCaseless
		lea   rbx, [.Contempt]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_multipv]
	       call   CmpStringCaseless
		lea   rbx, [.MultiPv]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_moveoverhead]
	       call   CmpStringCaseless
		lea   rbx, [.MoveOverhead]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_minthinktime]
	       call   CmpStringCaseless
		lea   rbx, [.MinThinkTime]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_slowmover]
	       call   CmpStringCaseless
		lea   rbx, [.SlowMover]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_uci_chess960]
	       call   CmpStringCaseless
		lea   rbx, [.Chess960]
	       test   eax, eax
		jnz   .CheckValue

if USE_SYZYGY
		lea   rcx, [sz_syzygypath]
	       call   CmpStringCaseless
		lea   rbx, [.SyzygyPath]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_syzygyprobedepth]
	       call   CmpStringCaseless
		lea   rbx, [.SyzygyProbeDepth]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_syzygy50moverule]
	       call   CmpStringCaseless
		lea   rbx, [.Syzygy50MoveRule]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_syzygyprobelimit]
	       call   CmpStringCaseless
		lea   rbx, [.SyzygyProbeLimit]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_syzygyprobelimit]
	       call   CmpStringCaseless
		lea   rbx, [.SyzygyProbeLimit]
	       test   eax, eax
		jnz   .CheckValue
end if

		lea   rcx, [sz_ttfile]
	       call   CmpStringCaseless
		lea   rbx, [.HashFile]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_ttsave]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .HashSave

		lea   rcx, [sz_ttload]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .HashLoad

if USE_BOOK
		lea   rcx, [sz_bookfile]
	       call   CmpStringCaseless
		lea   rbx, [.BookFile]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_ownbook]
	       call   CmpStringCaseless
		lea   rbx, [.OwnBook]
	       test   eax, eax
		jnz   .CheckValue
end if

if USE_WEAKNESS
		lea   rcx, [sz_uci_limitstrength]
	       call   CmpStringCaseless
		lea   rbx, [.UciLimitStrength]
	       test   eax, eax
		jnz   .CheckValue

		lea   rcx, [sz_uci_elo]
	       call   CmpStringCaseless
		lea   rbx, [.UciElo]
	       test   eax, eax
		jnz   .CheckValue
end if

		lea   rdi, [Output]
		lea   rcx, [sz_error_option]
	       call   PrintString
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut

.Error:
		lea   rdi, [Output]
	       call   PrintString
       PrintNewLine
	       call   _WriteOut_Output
		jmp   UciGetInput
.CheckValue:
	       call   SkipSpaces
		lea   rcx, [sz_value]
	       call   CmpString
		lea   rcx, [sz_error_value]
	       test   eax, eax
		 jz   .Error
	       call   SkipSpaces
		jmp   rbx

; these options require further careful processing in UciSync and set changed = true
.LargePages:
	       call   ParseBoole
		mov   byte[options.largePages], al
		mov   byte[options.changed], -1
		jmp   UciGetInput
.Hash:
	       call   ParseInteger
      ClampUnsigned   eax, 1, 1 shl MAX_HASH_LOG2MB
		mov   ecx, eax
		mov   dword[options.hash], eax
		mov   byte[options.changed], -1
		jmp   UciGetInput
.Threads:
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_THREADS
		mov   dword[options.threads], eax
		mov   byte[options.changed], -1
		jmp   UciGetInput


; these options are processed right away
.NodeAffinity:
	       call   ThreadPool_Destroy
		mov   rcx, rsi
	       call   ThreadPool_Create
	       call   _DisplayThreadPoolInfo
	       call   ThreadPool_ReadOptions
		jmp   UciGetInput


.Priority:
	       call   SkipSpaces

		lea   rcx, [sz_normal]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityNormal

		lea   rcx, [sz_low]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityLow

		lea   rcx, [sz_idle]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityIdle

		lea   rdi, [Output]
		mov   rax, 'error: u'
	      stosq
		mov   rax, 'nknown p'
	      stosq
		mov   rax, 'riority '
	      stosq
		mov   ecx, 64
	       call   ParseToken
		jmp   UciWriteOut_NewLine

    .PriorityNormal:
	       call   _SetPriority_Normal
		jmp   UciGetInput

    .PriorityLow:
	       call   _SetPriority_Low
		jmp   UciGetInput

    .PriorityIdle:
	       call   _SetPriority_Idle
		jmp   UciGetInput


.ClearHash:
	       call   Search_Clear
		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing hash'
	      stosq
		mov   rax, ' cleared'
	      stosq
		jmp   UciWriteOut_NewLine

if USE_SYZYGY
.SyzygyPath:
	; find terminator and replace it with zero
		mov   rcx, rsi
	@@:	add   rsi, 1
		cmp   byte[rsi], ' '
		jae   @b
		mov   byte[rsi], 0
	       call   TableBase_Init
		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing foun'
	      stosq
		mov   eax, 'd '
	      stosw
		mov   eax, dword[_ZL10TBnum_pawn]
		add   eax, dword[_ZL11TBnum_piece]
	       call   PrintUnsignedInteger
		mov   rax, ' tableba'
	      stosq
		mov   eax, 'ses'
	      stosd
		sub   rdi, 1
		jmp   UciWriteOut_NewLine
end if

.HashFile:
	       call   SkipSpaces
	; find terminator and replace it with zero
		 or   ebx, -1
	@@:	add   ebx, 1
		cmp   byte[rsi+rbx], ' '
		jae   @b
	; back up if any spaces are present on the end
		add   ebx, 1
	@@:	sub   ebx, 1
		mov   byte[rsi+rbx], 0
		 jz   @f
		cmp   byte[rsi+rbx-1], ' '
		 je   @b
	@@:
		add   ebx, 1
	; null term string is now at rsi
	; null terminated length is in ebx

		mov   rcx, qword[options.hashPath]
		mov   rdx, qword[options.hashPathSizeB]
		lea   rax, [options.hashPathBuffer]
		cmp   rcx, rax
		 je   @f
	       call   _VirtualFree
	@@:	mov   ecx, ebx
		lea   rax, [options.hashPathBuffer]
		cmp   ecx, 100
		 jb   @f
	       call   _VirtualAlloc
	@@:
		mov   rdi, rax
		mov   qword[options.hashPath], rax
		mov   qword[options.hashPathSizeB], rbx

	; copy null terminated string
		mov   ecx, ebx
	  rep movsb

		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing path'
	      stosq
		mov   rax, ' set to '
	      stosq
		mov   rcx, qword[options.hashPath]
	       call   PrintString
		jmp   UciWriteOut_NewLine

.HashSave:
	       call   MainHash_SaveFile
		jmp   UciGetInput
.HashLoad:
	       call   MainHash_LoadFile
		jmp   UciGetInput


; these options don't require any processing
.MultiPv:
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_MOVES
		mov   dword[options.multiPV], eax
		jmp   UciGetInput
.Chess960:
	       call   ParseBoole
		mov   byte[options.chess960], al
		jmp   UciGetInput
.Ponder:
	       call   ParseBoole
		mov   byte[options.ponder], al
		jmp   UciGetInput
.Contempt:
	       call   ParseInteger
	ClampSigned   eax, -100, 100
		mov   dword[options.contempt], eax
		jmp   UciGetInput
.MoveOverhead:
	       call   ParseInteger
      ClampUnsigned   eax, 0, 5000
		mov   dword[options.moveOverhead], eax
		jmp   UciGetInput
.MinThinkTime:
	       call   ParseInteger
      ClampUnsigned   eax, 0, 5000
		mov   dword[options.minThinkTime], eax
		jmp   UciGetInput
.SlowMover:
	       call   ParseInteger
      ClampUnsigned   eax, 0, 1000
		mov   dword[options.slowMover], eax
		jmp   UciGetInput

if USE_SYZYGY
.SyzygyProbeDepth:
	       call   ParseInteger
      ClampUnsigned   eax, 1, 100
		mov   dword[options.syzygyProbeDepth], eax
		jmp   UciGetInput
.Syzygy50MoveRule:
	       call   ParseBoole
		mov   byte[options.syzygy50MoveRule], al
		jmp   UciGetInput
.SyzygyProbeLimit:
	       call   ParseInteger
      ClampUnsigned   eax, 0, 6
		mov   dword[options.syzygyProbeLimit], eax
		jmp   UciGetInput
end if

if USE_BOOK
.BookFile:
	       call   Book_Load
		jmp   UciGetInput

.OwnBook:
	       call   ParseBoole
		mov   byte[book.use], al
		jmp   UciGetInput
end if


if USE_WEAKNESS
.UciLimitStrength:
	       call   ParseBoole
		mov   byte[weakness.enabled], al
		jmp   UciGetInput
.UciElo:
	       call   ParseInteger
      ClampUnsigned   eax, 0, 3300
		mov   ecx, eax
	       call   Weakness_SetElo
		jmp   UciGetInput
end if


;;;;;;;;;;;;
; *extras*
;;;;;;;;;;;;

UciPerft:
	       call   SkipSpaces
	       call   ParseInteger
	       test   eax, eax
		 jz   .bad_depth
		cmp   eax, 10		; probably will take a long time
		 ja   .bad_depth
		mov   esi, eax
		mov   ecx, eax
	       call   Position_SetExtraCapacity
	       call   _SetPriority_Realtime
		mov   ecx, esi
	       call   Perft_Root
	       call   _SetPriority_Normal
		jmp   UciGetInput
.bad_depth:
		lea   rdi, [Output]
	     szcall   PrintString, 'error: bad depth '
		mov   ecx, 8
	       call   ParseToken
		jmp   UciWriteOut_NewLine



UciBench:

		mov   r12d, 13	 ; depth
		mov   r13d, 1	 ; threads
		mov   r14d, 16	 ; hash
		xor   r15d, r15d ; realtime

		lea   rdi, [.parse_hash]
.parse_loop:
	       call   SkipSpaces
		cmp   byte[rsi], ' '
		 jb   .parse_done

	      movzx   eax, byte[rsi]
		cmp   eax, '1'
		 jb   @f
		cmp   eax, '9'
		 ja   @f
	       test   rdi, rdi
		 jz   @f
		jmp   rdi	; we have a number without preceding depth, threads, hash, or realtime token
		@@:

		lea   rcx, [sz_threads]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_threads

		lea   rcx, [sz_depth]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_depth

		lea   rcx, [sz_hash]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_hash

		lea   rcx, [sz_realtime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_realtime
		jmp   .parse_done

.parse_hash:
		lea   rdi, [.parse_threads]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, 1 shl MAX_HASH_LOG2MB
		mov   r14d, eax
		jmp   .parse_loop
.parse_threads:
		lea   rdi, [.parse_depth]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_THREADS
		mov   r13d, eax
		jmp   .parse_loop
.parse_depth:
		lea   rdi, [.parse_realtime]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, 40
		mov   r12d, eax
		jmp   .parse_loop
.parse_realtime:
		xor   edi, edi
	       call   SkipSpaces
	       call   ParseInteger
		xor   r15d, r15d
		neg   eax
		adc   r15d, r15d
		jmp   .parse_loop

.parse_done:
		lea   rdi, [Output]
		mov   eax, '*** '
	      stosd
		mov   rax, 'bench ha'
	      stosq
		mov   eax, 'sh '
	      stosd
		sub   rdi, 1
		mov   eax, r14d
	       call   PrintUnsignedInteger
		mov   rax, ' threads'
	      stosq
		mov   al, ' '
	      stosb
		mov   eax, r13d
	       call   PrintUnsignedInteger
		mov   rax, ' depth '
	      stosq
		sub   rdi, 1
		mov   eax, r12d
	       call   PrintUnsignedInteger
		mov   rax, ' realtim'
	      stosq
		mov   eax, 'e '
	      stosw
		mov   eax, r15d
	       call   PrintUnsignedInteger
		mov   eax, ' ***'
	      stosd
       PrintNewLine
if VERBOSE = 0
	       call   _WriteOut_Output
end if
		mov   dword[options.hash], r14d
	       call   MainHash_ReadOptions
		mov   dword[options.threads], r13d
	       call   ThreadPool_ReadOptions

		xor   eax, eax
		mov   qword[UciLoop.nodes], rax
if VERBOSE = 0
		mov   byte[options.displayInfoMove], al
end if
	       call   Search_Clear

	       test   r15d, r15d
		 jz   @f
	       call   _SetPriority_Realtime
	@@:
		xor   r13d, r13d
		mov   qword[UciLoop.time], r13
		mov   qword[UciLoop.nodes], r13
		lea   rsi, [BenchFens]
.nextpos:
		add   r13d, 1
	       call   SkipSpaces
	       call   Position_ParseFEN
		lea   rcx, [UciLoop.limits]
	       call   Limits_Init
		lea   rcx, [UciLoop.limits]
		mov   dword[rcx+Limits.depth], r12d
	       call   Limits_Set
		lea   rcx, [UciLoop.limits]

	       call   _GetTime
		mov   r14, rax
		lea   rcx, [UciLoop.limits]
	       call   ThreadPool_StartThinking
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_WaitForSearchFinished
	       call   _GetTime
		sub   r14, rax
		neg   r14
	       call   ThreadPool_NodesSearched_TbHits
		add   qword[UciLoop.time], r14
		add   qword[UciLoop.nodes], rax
		mov   r15, rax


		lea   rdi, [Output]
		mov   rax, r13
	       call   PrintUnsignedInteger
		mov   al, ':'
	      stosb
		lea   ecx, [rdi-Output]
		neg   ecx
		add   ecx, 8
		 js   @f
		mov   al, ' '
	  rep stosb
		@@:

		mov   rax, 'nodes:  '
	      stosq
		mov   rax, r15
	       call   PrintUnsignedInteger
		lea   ecx, [rdi-Output]
		neg   ecx
		add   ecx, 32
		 js   @f
		mov   al, ' '
	  rep stosb
		@@:

		mov   rcx, r14
		cmp   r14, 1
		adc   rcx, 0
		mov   rax, r15
		xor   edx, edx
		div   rcx
	       call   PrintUnsignedInteger
		mov   al, ' '
	      stosb
		mov   eax, 'knps'
	      stosd
       PrintNewLine
if VERBOSE = 0
	       call   _WriteOut_Output
else
		lea   rcx, [Output]
	       call   _WriteError
end if

		cmp   rsi, BenchFensEnd
		 jb   .nextpos

	       call   _SetPriority_Normal


		lea   rdi, [Output]
		mov   al, '='
		mov   ecx, 27
	  rep stosb
       PrintNewLine

		mov   rax, 'Total ti'
	      stosq
		mov   rax, 'me (ms) '
	      stosq
		mov   ax, ': '
	      stosw
		mov   rax, qword[UciLoop.time]
	       call   PrintUnsignedInteger
       PrintNewLine

		mov   rax, 'Nodes se'
	      stosq
		mov   rax, 'arched  '
	      stosq
		mov   ax, ': '
	      stosw
		mov   rax, qword[UciLoop.nodes]
	       call   PrintUnsignedInteger
       PrintNewLine

		mov   rax, 'Nodes/se'
	      stosq
		mov   rax, 'cond    '
	      stosq
		mov   ax, ': '
	      stosw

		mov   rax, qword[UciLoop.nodes]
		mov   ecx, 1000
		mul   rcx
		mov   rcx, qword[UciLoop.time]
		cmp   rcx, 1
		adc   rcx, 0
		div   rcx
	       call   PrintUnsignedInteger
       PrintNewLine
if VERBOSE = 0
	       call   _WriteOut_Output
else
		lea   rcx, [Output]
	       call   _WriteError
end if
		mov   byte[options.displayInfoMove], -1


if PROFILE > 0
		lea   rdi, [Output]

		lea   r15, [profile.cjmpcounts]

.CountLoop:
		mov   rax, qword[r15+8*0]
		 or   rax, qword[r15+8*1]
		 jz   .CountDone

		lea   rax, [r15-profile.cjmpcounts]
		shr   eax, 4
	       call   PrintUnsignedInteger
		mov   al, ':'
	      stosb
       PrintNewLine


	     szcall   PrintString, '  jmp not taken: '
		mov   rax, qword[r15+8*0]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, '  jmp taken:     '
		mov   rax, qword[r15+8*1]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, '  jmp percent:   '
	  vcvtsi2sd   xmm0, xmm0, qword[r15+8*0]
	  vcvtsi2sd   xmm1, xmm1, qword[r15+8*1]
	     vaddsd   xmm0, xmm0, xmm1
	     vdivsd   xmm1, xmm1, xmm0
		mov   eax, 10000
	  vcvtsi2sd   xmm2, xmm2, eax
	     vmulsd   xmm1, xmm1, xmm2
	  vcvtsd2si   eax, xmm1
		xor   edx, edx
		mov   ecx, 100
		div   ecx
		mov   r12d, edx
	       call   PrintUnsignedInteger
		mov   al, '.'
	      stosb
		mov   eax, r12d
		xor   edx, edx
		mov   ecx, 10
		div   ecx
		add   al, '0'
	      stosb
		lea   eax, [rdx+'0']
	      stosb
		mov   al, '%'
	      stosb
       PrintNewLine

		add   r15, 16
		jmp   .CountLoop

.CountDone:

		jmp   UciWriteOut
end if

		jmp   UciGetInput




if VERBOSE > 0

UciDoNull:
		mov   rbx, qword[rbp+Pos.state]
		mov   rax, qword[rbx+State.checkersBB]
	       test   rax, rax
		jnz   UciGetInput

		mov   rax, rbx
		sub   rax, qword[rbp+Pos.stateTable]
		xor   edx, edx
		mov   ecx, sizeof.State
		div   ecx
	     Assert   e, edx, 0, 'weird remainder in UciDoNull'
		lea   ecx, [rax+8]
		shr   ecx, 2
		add   ecx, eax
	       call   Position_SetExtraCapacity
		mov   rbx, qword[rbp+Pos.state]
		mov   dword[rbx+sizeof.State+State.currentMove], MOVE_NULL
	       call   Move_DoNull
		mov   qword[rbp+Pos.state], rbx
	       call   SetCheckInfo
		jmp   UciShow


UciShow:
		lea   rdi, [Output]
		mov   rbx, qword[rbp+Pos.state]
	       call   Position_Print
		jmp   UciWriteOut

UciUndo:
		mov   rbx, qword[rbp+Pos.state]
	       call   SkipSpaces
	       call   ParseInteger
		sub   eax, 1
		adc   eax, 0
		mov   r15d, eax
.Undo:
		cmp   rbx, qword[rbp+Pos.stateTable]
		jbe   UciShow
		mov   ecx, dword[rbx+State.currentMove]
	       call   Move_Undo
		sub   r15d, 1
		jns   .Undo
		jmp   UciShow


UciMoves:
	       call   UciParseMoves
		jmp   UciShow




UciEval:
		mov   rbx, qword[rbp+Pos.state]
	; allocate pawn hash
		mov   ecx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
	       call   _VirtualAlloc
		mov   qword[rbp+Pos.pawnTable], rax
	; allocate material hash
		mov   ecx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
	       call   _VirtualAlloc
		mov   qword[rbp+Pos.materialTable], rax
	       call   Evaluate
		mov   r15d, eax
	; free material hash
		mov   rcx, qword[rbp+Pos.materialTable]
		mov   edx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbp+Pos.materialTable], rax
	; free pawn hash
		mov   rcx, qword[rbp+Pos.pawnTable]
		mov   edx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[rbp+Pos.pawnTable], rax

		lea   rdi, [Output]
	     movsxd   rax, r15d
	       call   PrintSignedInteger
		mov   eax, ' == '
	      stosd
		mov   ecx, r15d
	       call   PrintScore_Uci
       PrintNewLine
		jmp   UciWriteOut

end if


match =1, PROFILE {
UciProfile:
		lea   rdi, [Output]

	     szcall   PrintString, 'MainHash_Probe:       '
		mov   rax, qword[profile.MainHash_Probe]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'MainHash_Save:        '
		mov   rax, qword[profile.MainHash_Save] 
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Move_Do:              '
		mov   rax, qword[profile.Move_Do]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Move_DoNull:          '
		mov   rax, qword[profile.Move_DoNull]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Move_GivesCheck:      '
		mov   rax, qword[profile.Move_GivesCheck]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Move_IsLegal:         '
		mov   rax, qword[profile.Move_IsLegal]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Move_IsPseudoLegal:   '
		mov   rax, qword[profile.Move_IsPseudoLegal]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'QSearch_PV_TRUE:      '
		mov   rax, qword[profile.QSearch_PV_TRUE]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'QSearch_PV_FALSE:     '
		mov   rax, qword[profile.QSearch_PV_FALSE]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'QSearch_NONPV_TRUE:   '
		mov   rax, qword[profile.QSearch_NONPV_TRUE]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'QSearch_NONPV_FALSE:  '
		mov   rax, qword[profile.QSearch_NONPV_FALSE]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Search_ROOT:          '
		mov   rax, qword[profile.Search_ROOT]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Search_NONPV:         '
		mov   rax, qword[profile.Search_NONPV]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'Search_PV:            '
		mov   rax, qword[profile.Search_PV]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'See:                  '
		mov   rax, qword[profile.See]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'SeeTest:              '
		mov   rax, qword[profile.SeeTest]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'SetCheckInfo:         '
		mov   rax, qword[profile.SetCheckInfo]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'SetCheckInfo2:        '
		mov   rax, qword[profile.SetCheckInfo2]
	       call   PrintUnsignedInteger
       PrintNewLine


	       push   rdi
		lea   rdi, [profile]
		mov   ecx, profile.ender-profile
		xor   eax, eax
	      stosb
		pop   rdi
		jmp   UciWriteOut

}
