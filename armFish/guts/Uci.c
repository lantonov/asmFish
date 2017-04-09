Options_Init:
        lea  x1, options
        mov  w0, -1
       strb  w0, [x1, Options.displayInfoMove]
        mov  w0, 0
        str  w0, [x1, Options.contempt]
        mov  w0, 1
        str  w0, [x1, Options.threads]
        mov  w0, 16
        str  w0, [x1, Options.hash]
        mov  w0, 0
       strb  w0, [x1, Options.ponder]
        mov  w0, 1
	str  w0, [x1, Options.multiPV]
        mov  w0, 30
	str  w0, [x1, Options.moveOverhead]
        mov  w0, 20
	str  w0, [x1, Options.minThinkTime]
        mov  w0, 89
	str  w0, [x1, Options.slowMover]
        mov  w0, 0
       strb  w0, [x1, Options.chess960]
        mov  w0, 0
       strb  w0, [x1, Options.largePages]
        ret


Options_Destroy:
        ret


UciLoop:

UciLoop.th1    = 0
UciLoop.th2    = sizeof.Thread + UciLoop.th1
UciLoop.states = sizeof.Thread + UciLoop.th2
UciLoop.limits = 2*sizeof.State + UciLoop.states
UciLoop.time   = sizeof.Limits + UciLoop.limits
UciLoop.nodes  = 8 + UciLoop.time
UciLoop.localsize = 8 + UciLoop.nodes
UciLoop.localsize = (UciLoop.localsize + 15) & (-16)


        stp  x29, x30, [sp, -16]!
        stp  x20, x21, [sp, -16]!
        stp  x22, x23, [sp, -16]!
        stp  x24, x25, [sp, -16]!
        stp  x26, x27, [sp, -16]!
        sub  sp, sp, UciLoop.localsize


/*
	        mov   byte[options.displayInfoMove], -1
*/
        lea  x16, options
        mov  w4, -1
       strb  w4, [x16, Options.displayInfoMove]
/*
		xor   eax, eax
		mov   qword[UciLoop.th1.rootPos.stateTable], rax
*/
        str  xzr, [sp, UciLoop.th1+Thread.rootPos+Pos.stateTable]
/*
		lea   rcx, [UciLoop.states]
		lea   rdx, [rcx+2*sizeof.State]
		mov   qword[UciLoop.th2.rootPos.state], rcx
		mov   qword[UciLoop.th2.rootPos.stateTable], rcx
		mov   qword[UciLoop.th2.rootPos.stateEnd], rdx
*/
        add  x1, sp, UciLoop.states
        add  x2, x1, 2*sizeof.State
        str  x1, [sp, UciLoop.th2+Thread.rootPos+Pos.state]
        str  x1, [sp, UciLoop.th2+Thread.rootPos+Pos.stateTable]
        str  x2, [sp, UciLoop.th2+Thread.rootPos+Pos.stateEnd]


UciNewGame:
/*
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
		jmp   UciGetInput
*/
        ldr  x1, [sp, UciLoop.th1+Thread.rootPos+Pos.stateTable]
        ldr  x2, [sp, UciLoop.th1+Thread.rootPos+Pos.stateEnd]
        sub  x2, x2, x1
         bl  Os_VirtualFree
        add  x20, sp, UciLoop.th1+Thread.rootPos
        str  xzr, [x20, Pos.state]
        str  xzr, [x20, Pos.stateTable]
        str  xzr, [x20, Pos.stateEnd]
        lea  x26, szStartFEN
        mov  w1, 0
         bl  Position_ParseFen
         bl  Search_Clear
          b  UciGetInput


UciNextCmdFromCmdLine:
/*
	; rsi is the address of the current command string to process  (qword[CmdLineStart])
	; if this string is empty, we should either
	;      set CmdLineStart=NULL or goto quit depending on USE_CMDLINEQUIT
	; if this string is not empty, we should
	;      set CmdLineStart to be the address of the next command

		xor   eax, eax
		mov   r15, rsi			; save current command address
		mov   qword[ioBuffer.cmdLineStart], rax
		cmp   al, byte[rsi]
	if USE_CMDLINEQUIT
		 je   UciQuit
	else
		 je   UciGetInput
	end if

	; find start of next command
.Next:
		mov   al, byte[rsi]
	       test   al, al
		 jz   .Found
		add   rsi, 1
		cmp   al, ' '
		jae   .Next
	; we have hit the new line char
.Found:
	; rsi is now the address of next command
		mov   qword[ioBuffer.cmdLineStart], rsi
		mov   rsi, r15			; restore current command address

GD String, 'processing cmd line command: '
GD String, rsi
GD NewLine
		jmp   UciChoose
*/
        mov  x25, x26
        lea  x16, [ioBuffer]
        str  xzr, [x16, IOBuffer.cmdLineStart]
       ldrb  w0, [x26]
        cbz  w0, UciQuit
UciNextCmdFromCmdLine.Next:       
       ldrb  w0, [x26]
        cbz  w0, UciNextCmdFromCmdLine.Found
        add  x26, x26, 1
        cmp  w0, ' '
        bhs  UciNextCmdFromCmdLine.Next
UciNextCmdFromCmdLine.Found:
        str  x26, [x16, IOBuffer.cmdLineStart]
        mov  x26, x25
          b  UciChoose

/*
; UciGetInput is where we expect to get a new command
; this can either come from the command line or from reading from stdin
; when processing this string, we can modify it,
;   but we must not modify anything after the newline char, which signifies the start of next command

; we usually display something before getting new input or even need to put a newline on the end of it
UciWriteOut_NewLine:
       PrintNewLine
UciWriteOut:
	       call   _WriteOut_Output
UciGetInput:
GD ResponseTime

		mov   rsi, qword[ioBuffer.cmdLineStart]
	       test   rsi, rsi
		jnz   UciNextCmdFromCmdLine

	       call   GetLine
	       test   eax, eax
		jnz   UciQuit

GD GetTime
*/
UciWriteOut_NewLine:
        PrintNewLine
UciWriteOut:
         bl  Os_WriteOut_Output
UciGetInput:
        lea  x16, ioBuffer
        ldr  x26, [x16, IOBuffer.cmdLineStart]
       cbnz  x26, UciNextCmdFromCmdLine
         bl  GetLine
       cbnz  w0, UciQuit

UciChoose:
/*
	; rsi is the address of the string to process

		cmp   byte[rsi], ' '
		 jb   UciGetInput     ; don't process empty lines

	       call   SkipSpaces
*/
       ldrb  w0, [x26]
        cmp  w0, ' '
        blo  UciGetInput
         bl  SkipSpaces
/*
		lea   rcx, [sz_go]
	       call   CmpString
	       test   eax, eax
		jnz   UciGo
*/
        lea  x1, sz_go
         bl  CmpString
       cbnz  w0, UciGo
/*
		lea   rcx, [sz_position]
	       call   CmpString
	       test   eax, eax
		jnz   UciPosition
*/
        lea  x1, sz_position
         bl  CmpString
       cbnz  w0, UciPosition
/*		lea   rcx, [sz_stop]
	       call   CmpString
	       test   eax, eax
		jnz   UciStop
*/
        lea  x1, sz_stop
         bl  CmpString
       cbnz  w0, UciStop
/*
		lea   rcx, [sz_isready]
	       call   CmpString
	       test   eax, eax
		jnz   UciIsReady
*/
        lea  x1, sz_isready
         bl  CmpString
       cbnz  w0, UciIsReady
/*
		lea   rcx, [sz_ponderhit]
	       call   CmpString
	       test   eax, eax
		jnz   UciPonderHit
*/
        lea  x1, sz_ponderhit
         bl  CmpString
       cbnz  w0, UciPonderHit
/*
		lea   rcx, [sz_ucinewgame]    ; check before uci :)
	       call   CmpString
	       test   eax, eax
		jnz   UciNewGame
*/
        lea  x1, sz_ucinewgame
         bl  CmpString
       cbnz  w0, UciNewGame
/*
		lea   rcx, [sz_uci]
	       call   CmpString
	       test   eax, eax
		jnz   UciUci
*/
        lea  x1, sz_uci
         bl  CmpString
       cbnz  w0, UciUci
/*
		lea   rcx, [sz_setoption]
	       call   CmpString
	       test   eax, eax
		jnz   UciSetOption
*/
        lea  x1, sz_setoption
         bl  CmpString
       cbnz  w0, UciSetOption
/*
		lea   rcx, [sz_quit]
	       call   CmpString
	       test   eax, eax
		jnz   UciQuit
*/
        lea  x1, sz_quit
         bl  CmpString
       cbnz  w0, UciQuit
/*
		lea   rcx, [sz_wait]
	       call   CmpString
	       test   eax, eax
		jnz   UciWait
*/
        lea  x1, sz_wait
         bl  CmpString
       cbnz  w0, UciWait
/*
		lea   rcx, [sz_perft]
	       call   CmpString
	       test   eax, eax
		jnz   UciPerft
*/
        lea  x1, sz_perft
         bl  CmpString
       cbnz  w0, UciPerft
/*
		lea   rcx, [sz_bench]
	       call   CmpString
	       test   eax, eax
		jnz   UciBench
*/
        lea  x1, sz_bench
         bl  CmpString
       cbnz  w0, UciBench

        lea  x1, sz_show
         bl  CmpString
       cbnz  w0, UciShow

        lea  x1, sz_moves
         bl  CmpString
       cbnz  w0, UciMoves


UciUnknown:
/*
		lea   rdi, [Output]
                lea   rcx, [sz_error_unknown]
	       call   PrintString
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut
*/
        lea  x27, Output
        lea  x1, sz_error_unknown
         bl  PrintString
        mov  x1, 64
         bl  ParseToken
          b  UciWriteOut_NewLine



UciQuit:
/*
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_WaitForSearchFinished
		mov   rcx, qword[UciLoop.th1.rootPos.stateTable]
		mov   rdx, qword[UciLoop.th1.rootPos.stateEnd]
		sub   rdx, rcx
	       call   _VirtualFree
		add   rsp, UciLoop.localsize
		pop   r15 r14 r13 r12 r11 rbx rdi rsi rbp
		ret
*/
        mov  w0, -1
        lea  x16, signals
       strb  w0, [x16, Signals.stop]
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_StartSearching_TRUE
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_WaitForSearchFinished

        add  x0, sp, UciLoop.th1+Thread.rootPos
        ldr  x1, [sp, UciLoop.th1+Thread.rootPos+Pos.stateTable]
        ldr  x2, [sp, UciLoop.th1+Thread.rootPos+Pos.stateEnd]
        sub  x2, x2, x1
         bl  Os_VirtualFree
        add  sp, sp, UciLoop.localsize
        ldp  x26, x27, [sp], 16
        ldp  x24, x25, [sp], 16
        ldp  x22, x23, [sp], 16
        ldp  x20, x21, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


UciUci:
/*		lea   rcx, [szUciResponse]
		lea   rdi, [szUciResponseEnd]
	       call   _WriteOut
		jmp   UciGetInput
*/
        lea  x1, szUciResponse
        lea  x27, szUciResponseEnd
         bl  UciWriteOut

UciIsReady:
/*
		mov   al, byte[options.changed]
	       test   al, al
		 jz   .ok
	       call   UciSync
*/
        lea  x16, options
       ldrb  w0, [x16, Options.changed]
        cbz  w0, UciIsReady.ok
         bl  UciSync
UciIsReady.ok:
/*
		lea   rdi, [Output]
		mov   rax, 'readyok'
	      stosq
		sub   rdi, 1
       PrintNewLine
		jmp   UciWriteOut
*/
        lea  x27, Output
        lea  x1, sz_readyok
         bl  PrintString
          b  UciWriteOut_NewLine
        

UciPonderHit:
/*
		mov   al, byte[signals.stopOnPonderhit]
	       test   al, al
		jnz   .stop
		mov   byte[limits.ponder], al
        ; we are now switching to normal search mode
        ; check the time in case we have to abort the search asap
               call   CheckTime
		jmp   UciGetInput
*/
        lea  x16, signals
       ldrb  w0, [x16, Signals.stopOnPonderhit]
       cbnz  w0, UciPonderHit.stop
        lea  x16, limits
       strb  w0, [x16, Limits.ponder]
         bl  CheckTime
          b  UciGetInput
UciPonderHit.stop:
/*
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
		jmp   UciGetInput
*/
        mov  w0, -1
       strb  w0, [x16, Signals.stop]
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_StartSearching_TRUE
          b  UciGetInput

UciStop:
/*
		mov   byte[signals.stop], -1
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_StartSearching_TRUE
*/
        lea  x16, signals
        mov  w0, -1
       strb  w0, [x16, Signals.stop]
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_StartSearching_TRUE
                
UciWait:
/*
		mov   rcx, qword[threadPool.threadTable+8*0]
	       call   Thread_WaitForSearchFinished
		jmp   UciGetInput
*/
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_WaitForSearchFinished
          b  UciGetInput

UciSync:
/*
	       push   rbx
	       call   MainHash_ReadOptions
	       call   ThreadPool_ReadOptions
		mov   byte[options.changed], 0
		pop   rbx
		ret
*/
        stp  x21, x30, [sp, -16]!
         bl  MainHash_ReadOptions
         bl  ThreadPool_ReadOptions
        lea  x16, options
       strb  wzr, [x16, Options.changed]
        ldp  x21, x30, [sp], 16
        ret


UciGo:
/*
		mov   al, byte[options.changed]
	       test   al, al
		 jz   .ok
	       call   UciSync
*/
        lea  x16, options
       ldrb  w0, [x16, Options.changed]
        cbz  w0, UciGo.ok
         bl  UciSync
UciGo.ok:
/*
		lea   rcx, [UciLoop.limits]
	       call   Limits_Init
*/
        add  x1, sp, UciLoop.limits
         bl  Limits_Init
        
UciGo.ReadLoop:
/*
	       call   SkipSpaces
		cmp   byte[rsi], ' '
		 jb   .ReadLoopDone
*/
         bl  SkipSpaces
       ldrb  w0, [x26]
        cmp  w0, ' '
        blo  UciGo.ReadLoopDone
/*
		lea   rdi, [UciLoop.limits.time+4*White]
		lea   rcx, [sz_wtime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.time+4*White
        lea  x1, sz_wtime
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.time+4*Black]
		lea   rcx, [sz_btime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.time+4*Black
        lea  x1, sz_btime
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.incr+4*White]
		lea   rcx, [sz_winc]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.incr+4*White
        lea  x1, sz_winc
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.incr+4*Black]
		lea   rcx, [sz_binc]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.incr+4*Black
        lea  x1, sz_binc
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.infinite]
		lea   rcx, [sz_infinite]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_true
*/
        add  x27, sp, UciLoop.limits+Limits.infinite
        lea  x1, sz_infinite
         bl  CmpString
       cbnz  w0, UciGo.parse_true
/*
		lea   rdi, [UciLoop.limits.movestogo]
		lea   rcx, [sz_movestogo]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.movestogo
        lea  x1, sz_movestogo
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.nodes]
		lea   rcx, [sz_nodes]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_qword
*/
        add  x27, sp, UciLoop.limits+Limits.nodes
        lea  x1, sz_nodes
         bl  CmpString
       cbnz  w0, UciGo.parse_qword
/*
		lea   rdi, [UciLoop.limits.movetime]
		lea   rcx, [sz_movetime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.movetime
        lea  x1, sz_movetime
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.depth]
		lea   rcx, [sz_depth]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.depth
        lea  x1, sz_depth
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.mate]
		lea   rcx, [sz_mate]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_dword
*/
        add  x27, sp, UciLoop.limits+Limits.mate
        lea  x1, sz_mate
         bl  CmpString
       cbnz  w0, UciGo.parse_dword
/*
		lea   rdi, [UciLoop.limits.ponder]
		lea   rcx, [sz_ponder]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_true
*/
        add  x27, sp, UciLoop.limits+Limits.ponder
        lea  x1, sz_ponder
         bl  CmpString
       cbnz  w0, UciGo.parse_true 
/*
		lea   rcx, [sz_searchmoves]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_searchmoves
*/
        lea  x1, sz_searchmoves
         bl  CmpString
       cbnz  w0, UciGo.parse_searchmoves 

UciGo.Error:
/*
		lea   rdi, [Output]
                lea   rcx, [sz_error_token]
	       call   PrintString
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut
*/
        lea  x27, Output
        lea  x1, sz_error_token
         bl  PrintString
        mov  x1, 64
         bl  ParseToken
          b  UciWriteOut_NewLine
        
UciGo.ReadLoopDone:
/*
		lea   rcx, [UciLoop.limits]
	       call   Limits_Set
		lea   rcx, [UciLoop.limits]
	       call   ThreadPool_StartThinking
		jmp   UciGetInput
*/
        add  x1, sp, UciLoop.limits
         bl  Limits_Set
        add  x1, sp, UciLoop.limits
         bl  ThreadPool_StartThinking
	  b  UciGetInput

UciGo.parse_qword:
/*
	       call   SkipSpaces
	       call   ParseInteger
		mov   qword[rdi], rax
		jmp   .ReadLoop
*/
         bl  SkipSpaces
         bl  ParseInteger
        str  x0, [x27]
          b  UciGo.ReadLoop

UciGo.parse_dword:
/*
	       call   SkipSpaces
	       call   ParseInteger
		mov   dword[rdi], eax
		jmp   .ReadLoop
*/
         bl  SkipSpaces
         bl  ParseInteger
        str  w0, [x27]
          b  UciGo.ReadLoop

UciGo.parse_true:
/*
		mov   byte[rdi], -1
		jmp   .ReadLoop
*/
        mov  w0, -1
          b  UciGo.ReadLoop

UciGo.parse_searchmoves:
/*
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
*/
         bl  SkipSpaces
         bl  ParseUciMove
        cbz  w0, UciGo.ReadLoop
        ldr  w1, [sp, UciLoop.limits+Limits.moveVecSize]
        add  w5, w1, 1
        add  x27, sp, UciLoop.limits+Limits.moveVec
UciGo.parse_searchmoves_loop:
        cbz  x1, UciGo.parse_searchmoves_new
        sub  x1, x1, 1
       ldrh  w4, [x27], 2
        cmp  w4, w0
        beq  UciGo.parse_searchmoves
          b  UciGo.parse_searchmoves_loop
UciGo.parse_searchmoves_new:
       strh  w0, [x27], 2
        str  w5, [sp, UciLoop.limits+Limits.moveVecSize]
          b  UciGo.parse_searchmoves

UciPosition:
/*
	       call   SkipSpaces
		cmp   byte[rsi], ' '
		 jb   UciUnknown

	; write to pos2 in case of failure
		lea   rbp, [UciLoop.th2.rootPos]
*/
         bl  SkipSpaces
       ldrb  w0, [x26]
        cmp  w0, ' '
        blo  UciUnknown
        add  x20, sp, UciLoop.th2+Thread.rootPos
/*
		lea   rcx, [sz_fen]
	       call   CmpString
	       test   eax, eax
		jnz   .Fen
*/
        lea  x1, sz_fen
         bl  CmpString
       cbnz  w0, UciPosition.Fen
/*
		lea   rcx, [sz_startpos]
	       call   CmpString
	       test   eax, eax
		 jz   .BadCmd
*/
        lea  x1, sz_startpos
         bl  CmpString
        cbz  w0, UciPosition.BadCmd

UciPosition.Start:
/*
		mov   r15, rsi
		lea   rsi, [szStartFEN]
		xor   ecx, ecx
	       call   Position_ParseFEN
		mov   rsi, r15
		jmp   .check
*/
        mov  x25, x26
        lea  x26, szStartFEN
        lea  x7, options
       ldrb  w1, [x7, Options.chess960]
         bl  Position_ParseFen
        mov  x26, x25
          b  UciPosition.check

UciPosition.Fen:
/*
	      movzx   ecx, byte[options.chess960]
	       call   Position_ParseFEN
*/
        lea  x16, [options]
       ldrb  w1, [x16, Options.chess960]
         bl  Position_ParseFen
        
UciPosition.check:
/*
	       test   eax, eax
		jnz   .illegal
*/
       cbnz  w0, UciPosition.illegal

UciPosition.moves:
/*
	; copy pos2 to pos  before parsing moves
		lea   rcx, [UciLoop.th1.rootPos]
	       call   Position_CopyTo
		lea   rbp, [UciLoop.th1.rootPos]

	       call   SkipSpaces
                lea   rcx, [sz_moves]
	       call   CmpString
	       test   eax, eax
		 jz   UciGetInput
	       call   UciParseMoves
	       test   rax, rax
		 jz   UciGetInput
*/
        add  x1, sp, UciLoop.th1 + Thread.rootPos
         bl  Position_CopyTo
        add  x20, sp, UciLoop.th1 + Thread.rootPos
         bl  SkipSpaces
        lea  x1, sz_moves
         bl  CmpString
        cbz  w0, UciGetInput
         bl  UciParseMoves
        cbz  x0, UciGetInput

UciPosition.badmove:
/*
		mov   rsi, rax
		lea   rdi, [Output]
                lea   rcx, [sz_error_moves]
	       call   PrintString
		mov   ecx, 6
	       call   ParseToken
       PrintNewLine
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciWriteOut
*/
        mov  x26, x0
        lea  x27, Output
        lea  x1, sz_error_moves
         bl  PrintString
        mov  x1, 6
         bl  ParseToken
        PrintNewLine
        add  x20, sp, UciLoop.th1 + Thread.rootPos
          b  UciWriteOut

UciPosition.illegal:
/*
		lea   rdi, [Output]
                lea   rcx, [sz_error_fen]
	       call   PrintString
       PrintNewLine
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciWriteOut
UciPosition.BadCmd:
		lea   rbp, [UciLoop.th1.rootPos]
		jmp   UciUnknown
*/
        lea  x27, Output
        lea  x1, sz_error_fen
         bl  PrintString
        PrintNewLine
        add  x20, sp, UciLoop.th1+Thread.rootPos
          b  UciWriteOut

UciPosition.BadCmd:
        add  x20, sp, UciLoop.th1+Thread.rootPos
          b  UciUnknown


UciParseMoves:
/*
	; in: rbp position
	;     rsi string
	; rax = 0 if full string could be parsed
	;     = address of illegal move if there is one
	       push   rbx rsi rdi
UciParseMoves.get_move:
	       call   SkipSpaces
		xor   eax, eax
		cmp   byte[rsi], ' '
		 jb   .done
	       call   ParseUciMove
		mov   edi, eax
	       test   eax, eax
		mov   rax, rsi
		 jz   .done
		mov   ecx, 2
	       call   Position_SetExtraCapacity
		mov   rbx, qword[rbp+Pos.state]
		mov   ecx, edi
		mov   dword[rbx+sizeof.State+State.currentMove], edi
	       call   Move_GivesCheck
		mov   ecx, edi
		mov   edx, eax
	       call   Move_Do__UciParseMoves
		inc   dword[rbp+Pos.gamePly]
		mov   qword[rbp+Pos.state], rbx
	       call   SetCheckInfo
		jmp   .get_move
UciParseMoves.done:
		pop   rdi rsi rbx
		ret
*/
        stp  x21, x30, [sp, -16]!
        stp  x26, x27, [sp, -16]!
UciParseMoves.get_move:
         bl  SkipSpaces
        mov  x0, 0
       ldrb  w4, [x26]
        cmp  w4, ' '
        blo  UciParseMoves.done
         bl  ParseUciMove
        mov  x27, x0
        tst  x0, x0
        mov  x0, x26
        beq  UciParseMoves.done
        mov  x1, 2
         bl  Position_SetExtraCapacity
        ldr  x21, [x20, Pos.state]
        mov  x1, x27
        str  w27, [x21, sizeof.State + State.currentMove]
         bl  Move_GivesCheck
        mov  x1, x27
       strb  w0, [x21, State.givesCheck]
         bl  Move_Do__UciParseMoves
        ldr  w4, [x20, Pos.gamePly]
        add  w4, w4, 1
        str  w4, [x20, Pos.gamePly]
        str  x21, [x20, Pos.state]
         bl  SetCheckInfo
          b  UciParseMoves.get_move
UciParseMoves.done:
        ldp  x26, x27, [sp], 16
        ldp  x21, x30, [sp], 16
        ret

UciSetOption:
/*
		mov   rax, qword[threadPool.threadTable+8*0]
		mov   al, byte[rax+Thread.searching]
		lea   rcx, [sz_error_think]
	       test   al, al
		jnz   .Error
*/
        lea  x16, threadPool
        ldr  x0, [x16, ThreadPool.threadTable+8*0]
       ldrb  w0, [x0, Thread.searching]
        lea  x1, sz_error_think
       cbnz  w0, UciSetOption.Error
UciSetOption.Read:
/*
	       call   SkipSpaces
		lea   rcx, [sz_name]
	       call   CmpString
		lea   rcx, [sz_error_name]
	       test   eax, eax
		 jz   .Error
	       call   SkipSpaces
*/
         bl  SkipSpaces
        lea  x1, sz_name
         bl  CmpString
        lea  x1, sz_error_name
        cbz  w0, UciSetOption.Error
         bl  SkipSpaces
/*
		lea   rcx, [sz_threads]
	       call   CmpStringCaseless
		lea   rbx, [.Threads]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_threads
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Threads
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_hash]
	       call   CmpStringCaseless
		lea   rbx, [.Hash]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_hash
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Hash
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_largepages]
	       call   CmpStringCaseless
		lea   rbx, [.LargePages]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_largepages
         bl  CmpStringCaseless
        adr  x21, UciSetOption.LargePages
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_nodeaffinity]
	       call   CmpStringCaseless
		lea   rbx, [.NodeAffinity]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_nodeaffinity
         bl  CmpStringCaseless
        adr  x21, UciSetOption.NodeAffinity
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_priority]
	       call   CmpStringCaseless
		lea   rbx, [.Priority]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_priority
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Priority
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_clear_hash]  ; arena may send Clear Hash
	       call   CmpStringCaseless     ;  instead of ClearHash
	       test   eax, eax		    ;
		jnz   .ClearHash	    ;
*/
        lea  x1, sz_clear_hash
         bl  CmpStringCaseless
       cbnz  w0, UciSetOption.ClearHash
/*
		lea   rcx, [sz_ponder]
	       call   CmpStringCaseless
		lea   rbx, [.Ponder]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_ponder
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Ponder
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_contempt]
	       call   CmpStringCaseless
		lea   rbx, [.Contempt]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_contempt
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Contempt
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_multipv]
	       call   CmpStringCaseless
		lea   rbx, [.MultiPv]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_multipv
         bl  CmpStringCaseless
        adr  x21, UciSetOption.MultiPv
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_moveoverhead]
	       call   CmpStringCaseless
		lea   rbx, [.MoveOverhead]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_moveoverhead
         bl  CmpStringCaseless
        adr  x21, UciSetOption.MoveOverhead
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_minthinktime]
	       call   CmpStringCaseless
		lea   rbx, [.MinThinkTime]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_minthinktime
         bl  CmpStringCaseless
        adr  x21, UciSetOption.MinThinkTime
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_slowmover]
	       call   CmpStringCaseless
		lea   rbx, [.SlowMover]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_slowmover
         bl  CmpStringCaseless
        adr  x21, UciSetOption.SlowMover
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rcx, [sz_uci_chess960]
	       call   CmpStringCaseless
		lea   rbx, [.Chess960]
	       test   eax, eax
		jnz   .CheckValue
*/
        lea  x1, sz_uci_chess960
         bl  CmpStringCaseless
        adr  x21, UciSetOption.Chess960
       cbnz  w0, UciSetOption.CheckValue
/*
		lea   rdi, [Output]
		lea   rcx, [sz_error_option]
	       call   PrintString
		mov   ecx, 64
	       call   ParseToken
       PrintNewLine
		jmp   UciWriteOut
*/
        lea  x27, Output
        lea  x1, sz_error_option
         bl  PrintString
        mov  x1, 64
         bl  ParseToken
          b  UciWriteOut_NewLine

UciSetOption.Error:
/*
		lea   rdi, [Output]
	       call   PrintString
       PrintNewLine
	       call   _WriteOut_Output
		jmp   UciGetInput
*/
        lea  x27, Output
         bl  PrintString
          b  UciWriteOut_NewLine
        
UciSetOption.CheckValue:
/*
	       call   SkipSpaces
		lea   rcx, [sz_value]
	       call   CmpString
		lea   rcx, [sz_error_value]
	       test   eax, eax
		 jz   .Error
	       call   SkipSpaces
		jmp   rbx
*/
         bl  SkipSpaces
        lea  x1, sz_value
         bl  CmpString
        lea  x1, sz_error_value
       cbnz  w0, UciSetOption.Error
         bl  SkipSpaces
         br  x21

UciSetOption.LargePages:
/*
	       call   ParseBoole
		mov   byte[options.largePages], al
		mov   byte[options.changed], -1
		jmp   UciGetInput
*/
         bl  ParseBoole
        lea  x16, options
       strb  w0, [x16, Options.largePages]
        mov  w0, -1
       strb  w0, [x16, Options.changed]
          b  UciGetInput

UciSetOption.Hash:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 1, 1 shl MAX_HASH_LOG2MB
		mov   ecx, eax
		mov   dword[options.hash], eax
		mov   byte[options.changed], -1
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 1
        mov  w5, 1 << MAX_HASH_LOG2MB
        ClampUnsigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.hash]
        mov  w0, -1
       strb  w0, [x16, Options.changed]
          b  UciGetInput

UciSetOption.Threads:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_THREADS
		mov   dword[options.threads], eax
		mov   byte[options.changed], -1
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 1
        mov  w5, MAX_THREADS
        ClampUnsigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.threads]
        mov  w0, -1
       strb  w0, [x16, Options.changed]
          b  UciGetInput
        

UciSetOption.NodeAffinity:
/*
	       call   ThreadPool_Destroy
		mov   rcx, rsi
	       call   ThreadPool_Create
	       call   _DisplayThreadPoolInfo
	       call   ThreadPool_ReadOptions
		jmp   UciGetInput
*/
         bl  ThreadPool_Destroy
        mov  x1, x26
         bl  ThreadPool_Create
         bl  Os_DisplayThreadPoolInfo
         bl  ThreadPool_ReadOptions
          b  UciGetInput

UciSetOption.Priority:
/*
	       call   SkipSpaces

		lea   rcx, [sz_none]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   UciGetInput
*/
         bl  SkipSpaces
        lea  x1, sz_none
         bl  CmpStringCaseless
       cbnz  w0, UciGetInput
/*
		lea   rcx, [sz_normal]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityNormal
*/
        lea  x1, sz_normal
         bl  CmpStringCaseless
       cbnz  w0, UciSetOption.PriorityNormal
/*
		lea   rcx, [sz_low]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityLow
*/
        lea  x1, sz_low
         bl  CmpStringCaseless
       cbnz  w0, UciSetOption.PriorityLow
        
/*
		lea   rcx, [sz_idle]
	       call   CmpStringCaseless
	       test   eax, eax
		jnz   .PriorityIdle
*/
        lea  x1, sz_idle
         bl  CmpStringCaseless
       cbnz  w0, UciSetOption.PriorityIdle

/*
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
*/
        lea  x27, Output
        lea  x1, sz_error_priority
         bl  PrintString
        mov  x1, 64
         bl  ParseToken
          b  UciWriteOut_NewLine

UciSetOption.PriorityNormal:
/*
	       call   _SetPriority_Normal
		jmp   UciGetInput
*/
         bl  Os_SetPriority_Normal
          b  UciGetInput
UciSetOption.PriorityLow:
/*
	       call   _SetPriority_Low
		jmp   UciGetInput
*/
         bl  Os_SetPriority_Low
          b  UciGetInput
UciSetOption.PriorityIdle:
/*
	       call   _SetPriority_Idle
		jmp   UciGetInput
*/
         bl  Os_SetPriority_Idle
          b  UciGetInput

UciSetOption.ClearHash:
/*
	       call   Search_Clear
		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing hash'
	      stosq
		mov   rax, ' cleared'
	      stosq
		jmp   UciWriteOut_NewLine
*/
         bl  Search_Clear
        lea  x27, Output
        lea  x1, sz_hash_cleared
         bl  PrintString
          b  UciWriteOut_NewLine

UciSetOption.MultiPv:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_MOVES
		mov   dword[options.multiPV], eax
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 1
        mov  w5, MAX_MOVES
        ClampUnsigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.multiPV]
          b  UciGetInput

UciSetOption.Chess960:
/*
	       call   ParseBoole
		mov   byte[options.chess960], al
		jmp   UciGetInput
*/
         bl  ParseBoole
        lea  x16, options
       strb  w0, [x16, Options.chess960]
          b  UciGetInput

UciSetOption.Ponder:
/*
	       call   ParseBoole
		mov   byte[options.ponder], al
		jmp   UciGetInput
*/
         bl  ParseBoole
        lea  x16, options
       strb  w0, [x16, Options.ponder]
          b  UciGetInput

UciSetOption.Contempt:
/*
	       call   ParseInteger
	ClampSigned   eax, -100, 100
		mov   dword[options.contempt], eax
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, -100
        mov  w5, 100
        ClampSigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.contempt]
          b  UciGetInput

UciSetOption.MoveOverhead:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 0, 5000
		mov   dword[options.moveOverhead], eax
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 0
        mov  w5, 5000
        ClampUnsigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.moveOverhead]
          b  UciGetInput
UciSetOption.MinThinkTime:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 0, 5000
		mov   dword[options.minThinkTime], eax
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 0
        mov  w5, 5000
        ClampUnsigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.minThinkTime]
          b  UciGetInput

UciSetOption.SlowMover:
/*
	       call   ParseInteger
      ClampUnsigned   eax, 0, 1000
		mov   dword[options.slowMover], eax
		jmp   UciGetInput
*/
         bl  ParseInteger
        mov  w4, 0
        mov  w5, 1000
        ClampSigned w0, w4, w5
        lea  x16, options
        str  w0, [x16, Options.slowMover]
          b  UciGetInput





UciPerft:
/*
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
*/
         bl  SkipSpaces
         bl  ParseInteger
        cbz  x0, UciPerft.bad_depth
        cmp  x0, 10
        bhi  UciPerft.bad_depth
        mov  x26, x0
        mov  x1, x0
         bl  Position_SetExtraCapacity
        mov  x1, x26
         bl  Perft_Root
          b  UciGetInput
UciPerft.bad_depth:
/*
		lea   rdi, [Output]
                lea   rcx, [sz_error_depth]
	       call   PrintString
		mov   ecx, 8
	       call   ParseToken
		jmp   UciWriteOut_NewLine
*/
        lea  x27 Output
        lea  x1, sz_error_depth
         bl  PrintString
        mov  x1, 8
         bl  ParseToken
          b  UciWriteOut_NewLine

UciBench:
/*
		mov   r12d, 13	 ; depth
		mov   r13d, 1	 ; threads
		mov   r14d, 16	 ; hash
		xor   r15d, r15d ; realtime

		lea   rdi, [.parse_hash]
*/
        mov  x22, 13
        mov  x23, 1
        mov  x24, 16
        mov  x25, 0
        adr  x27, UciBench.parse_hash
UciBench.parse_loop:
/*
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
*/
         bl  SkipSpaces
       ldrb  w1, [x26]
        cmp  w1, ' '
        blo  UciBench.parse_done
        sub  w0, w1, '0'
        cmp  w0, 10
        bhs  UciBench.GotToken
        cbz  x27, UciBench.parse_done
         br  x27
UciBench.GotToken:
/*
		lea   rcx, [sz_threads]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_threads
*/
        lea  x1, sz_threads
         bl  CmpString
       cbnz  w0, UciBench.parse_threads
/*
		lea   rcx, [sz_depth]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_depth
*/
        lea  x1, sz_depth
         bl  CmpString
       cbnz  w0, UciBench.parse_depth
/*
		lea   rcx, [sz_hash]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_hash
*/
        lea  x1, sz_hash
         bl  CmpString
       cbnz  w0, UciBench.parse_hash
/*
		lea   rcx, [sz_realtime]
	       call   CmpString
	       test   eax, eax
		jnz   .parse_realtime
		jmp   .parse_done
*/
        lea  x1, sz_realtime
         bl  CmpString
       cbnz  w0, UciBench.parse_realtime
          b  UciBench.parse_done
UciBench.parse_hash:
/*
		lea   rdi, [.parse_threads]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, 1 shl MAX_HASH_LOG2MB
		mov   r14d, eax
		jmp   .parse_loop
*/
        adr  x27, UciBench.parse_threads
         bl  SkipSpaces
         bl  ParseInteger
        mov  w4, 1
        mov  w5, 1 << MAX_HASH_LOG2MB
        ClampUnsigned w0, w4, w5
        mov  w24, w0
          b  UciBench.parse_loop
UciBench.parse_threads:
/*
		lea   rdi, [.parse_depth]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, MAX_THREADS
		mov   r13d, eax
		jmp   .parse_loop
*/
        adr  x27, UciBench.parse_depth
         bl  SkipSpaces
         bl  ParseInteger
        mov  w4, 1
        mov  w5, MAX_THREADS
        ClampUnsigned w0, w4, w5
        mov  w23, w0
          b  UciBench.parse_loop
UciBench.parse_depth:
/*
		lea   rdi, [.parse_realtime]
	       call   SkipSpaces
	       call   ParseInteger
      ClampUnsigned   eax, 1, 40
		mov   r12d, eax
		jmp   .parse_loop
*/
        adr  x27, UciBench.parse_realtime
         bl  SkipSpaces
         bl  ParseInteger
        mov  w4, 1
        mov  w5, 40
        ClampUnsigned w0, w4, w5
        mov  w22, w0
          b  UciBench.parse_loop

UciBench.parse_realtime:
/*
		xor   edi, edi
	       call   SkipSpaces
	       call   ParseInteger
		xor   r15d, r15d
		neg   eax
		adc   r15d, r15d
		jmp   .parse_loop
*/
        mov  x27, 0
         bl  SkipSpaces
         bl  ParseInteger
        cmp  x0, 0
       cset  x27, ne
          b  UciBench.parse_loop
UciBench.parse_done:
/*
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
	       call   _WriteOut_Output
		mov   dword[options.hash], r14d
	       call   MainHash_ReadOptions
		mov   dword[options.threads], r13d
	       call   ThreadPool_ReadOptions
*/
        stp  x22, x25, [sp, -16]!
        stp  x24, x23, [sp, -16]!
        lea  x27, Output
        lea  x1, sz_bench_format1
        add  x2, sp, 0
         bl  PrintFancy
        add  sp, sp, 32
         bl  Os_WriteOut_Output
        lea  x16, options
        str  w24, [x16, Options.hash]
        str  w23, [x16, Options.threads]
         bl  MainHash_ReadOptions
         bl  ThreadPool_ReadOptions

/*
		xor   eax, eax
		mov   qword[UciLoop.nodes], rax
		mov   byte[options.displayInfoMove], al
	       call   Search_Clear
*/
        lea  x16, options
        str  xzr, [sp, UciLoop.nodes]
       strb  wzr, [x16, Options.displayInfoMove]
/*
	       test   r15d, r15d
		 jz   @f
	       call   _SetPriority_Realtime
	@@:
*/
        cbz  x25, 1f
         bl  Os_SetPriority_Realtime
    1:
/*
		xor   r13d, r13d
		mov   qword[UciLoop.time], r13
		mov   qword[UciLoop.nodes], r13
		lea   rsi, [BenchFens]
*/
        mov  x23, 0
        str  xzr, [sp, UciLoop.time]
        str  xzr, [sp, UciLoop.nodes]
        lea  x26, BenchFens

UciBench.nextpos:
/*
		add   r13d, 1
	       call   SkipSpaces
	       call   Position_ParseFEN
		lea   rcx, [UciLoop.limits]
	       call   Limits_Init
		lea   rcx, [UciLoop.limits]
		mov   dword[rcx+Limits.depth], r12d
	       call   Limits_Set
		lea   rcx, [UciLoop.limits]
*/
        add  x23, x23, 1
         bl  SkipSpaces
         bl  Position_ParseFen
        add  x1, sp, UciLoop.limits
         bl  Limits_Init
        add  x1, sp, UciLoop.limits
        str  w22, [x1, Limits.depth]
         bl  Limits_Set
/*
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
*/
         bl  Os_GetTime
        mov  x24, x0
        add  x1, sp, UciLoop.limits
         bl  ThreadPool_StartThinking
        lea  x16, threadPool
        ldr  x1, [x16, ThreadPool.threadTable+8*0]
         bl  Thread_WaitForSearchFinished
         bl  Os_GetTime
        sub  x24, x0, x24
         bl  ThreadPool_NodesSearched_TbHits
        ldr  x4, [sp, UciLoop.time]
        ldr  x5, [sp, UciLoop.nodes]
        add  x4, x4, x24
        add  x5, x5, x0
        str  x4, [sp, UciLoop.time]
        str  x5, [sp, UciLoop.nodes]

/*
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
	       call   _WriteOut_Output

		cmp   rsi, BenchFensEnd
		 jb   .nextpos
*/
        lea  x27, Output
        cmp  x24, 0
       cinc  x1, x24, eq
       udiv  x2, x25, x1
        stp  x23, x0, [sp, -32]!
        str  x2, [sp, 16]
        lea  x1, sz_bench_format2
        add  x2, sp, 0
         bl  PrintFancy
        add  sp, sp, 32
         bl  Os_WriteOut_Output
        lea  x16, BenchFensEnd
        cmp  x26, x16
        blo  UciBench.nextpos

/*
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
	       call   _WriteOut_Output
		mov   byte[options.displayInfoMove], -1


		jmp   UciGetInput
*/
        ldr  x0, [sp, UciLoop.nodes]
        ldr  x1, [sp, UciLoop.time]
        mov  x2, 1000
        cmp  x1, 0
       cinc  x1, x1, eq
      scvtf  d0, x0
      scvtf  d1, x1
      scvtf  d2, x2
       fmul  d0, d0, d2
       fdiv  d0, d0, d1
     fcvtzs  x2, d0
        stp  x0, x1, [sp, -32]!
        str  x2, [sp, 16]
        lea  x1, sz_bench_format3
        add  x2, sp, 0
         bl  PrintFancy
        add  sp, sp, 32
         bl  Os_WriteOut_Output                
          b  UciGetInput


UciShow:
/*
		lea   rdi, [Output]
		mov   rbx, qword[rbp+Pos.state]
	       call   Position_Print
		jmp   UciWriteOut
*/
        lea  x27, Output
        ldr  x21, [x20, Pos.state]
         bl  Position_Print
          b  UciWriteOut

UciMoves:
/*
	       call   UciParseMoves
		jmp   UciShow
*/
         bl  UciParseMoves
          b  UciShow
