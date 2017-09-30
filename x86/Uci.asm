
Options_Init:
            lea  rdx, [options]
            mov   byte[rdx + Options.displayInfoMove], -1
            mov  dword[rdx + Options.contempt], 0
            mov  dword[rdx + Options.threads], 1
            mov  dword[rdx + Options.hash], 16
            mov   byte[rdx + Options.ponder], 0
            mov  dword[rdx + Options.multiPV], 1
            mov  dword[rdx + Options.moveOverhead], 50
            mov   byte[rdx + Options.chess960], 0
            mov  dword[rdx + Options.syzygyProbeDepth], 1
            mov   byte[rdx + Options.syzygy50MoveRule], -1
            mov  dword[rdx + Options.syzygyProbeLimit], 6
            mov   byte[rdx + Options.largePages], 0

            lea  rcx, [rdx + Options.hashPathBuffer]
            mov  rax, '<empty>'
            mov  qword[rdx + Options.hashPath], rcx
            mov  qword[rcx], rax
if USE_VARIETY
            mov  dword[rdx + Options.varietyMod], 1
            mov  dword[rdx + Options.varietyBound], 0
end if
            mov  qword[ioBuffer + IOBuffer.log], -1
            ret


Options_Destroy:
           push  rbx
            mov  rcx, qword[options.hashPath]
            mov  rdx, qword[options.hashPathSizeB]
            lea  rax, [options.hashPathBuffer]
            cmp  rcx, rax
             je  @1f
           call  Os_VirtualFree
    @1:     
            pop  rbx
            ret


UciLoop:

virtual at rsp
  .th1 Thread
  .th2 Thread
  .states rb 2*sizeof.State
  .limits Limits
  .time  rq 1
  .nodes rq 1
  .extra rq 4
  .localend rb 0
end virtual
.localsize = ((.localend-rsp+15) and (-16))

           push  rbp rsi rdi rbx r11 r12 r13 r14 r15
     _chkstk_ms  rsp, UciLoop.localsize
            sub  rsp, UciLoop.localsize

            mov  byte[options.displayInfoMove], -1

            xor  eax, eax
            mov  qword[UciLoop.th1.rootPos.stateTable], rax

            lea  rcx, [UciLoop.states]
            lea  rdx, [rcx+2*sizeof.State]
            mov  qword[UciLoop.th2.rootPos.state], rcx
            mov  qword[UciLoop.th2.rootPos.stateTable], rcx
            mov  qword[UciLoop.th2.rootPos.stateEnd], rdx

UciNewGame:
            mov  rcx, qword[UciLoop.th1.rootPos.stateTable]
            mov  rdx, qword[UciLoop.th1.rootPos.stateEnd]
            sub  rdx, rcx
           call  Os_VirtualFree
            xor  eax, eax
            lea  rbp, [UciLoop.th1.rootPos]
            mov  qword[UciLoop.th1.rootPos.state], rax
            mov  qword[UciLoop.th1.rootPos.stateTable], rax
            mov  qword[UciLoop.th1.rootPos.stateEnd], rax
            lea  rsi, [szStartFEN]
            xor  ecx, ecx
           call  Position_ParseFEN
           call  Search_Clear
if USE_BOOK
           call  Book_Refresh
end if
            jmp  UciGetInput



UciNextCmdFromCmdLine:
    ; rsi is the address of the current command string to process  (qword[CmdLineStart])
    ; if this string is empty, we should either
    ;      set CmdLineStart=NULL or goto quit depending on USE_CMDLINEQUIT
    ; if this string is not empty, we should
    ;      set CmdLineStart to be the address of the next command

            xor  eax, eax
            mov  r15, rsi  ; save current command address
            mov  qword[ioBuffer.cmdLineStart], rax
            cmp  al, byte[rsi]
if USE_CMDLINEQUIT
             je  UciQuit
else
             je  UciGetInput
end if

    ; find start of next command
.Next:
            mov  al, byte[rsi]
           test  al, al
             jz  .Found
            add  rsi, 1
            cmp  al, ' '
            jae  .Next
	; we have hit the new line char
.Found:
	; rsi is now the address of next command
            mov  qword[ioBuffer.cmdLineStart], rsi
            mov  rsi, r15  ; restore current command address
Display 1, 'processing cmd line command: %S6%n'
            jmp  UciChoose



; UciGetInput is where we expect to get a new command
; this can either come from the command line or from reading from stdin
; when processing this string, we can modify it,
;   but we must not modify anything after the newline char, which signifies the start of next command

; we usually display something before getting new input or even need to put a newline on the end of it
UciWriteOut_NewLine:
        PrintNL
UciWriteOut:
           call  WriteLine_Output
UciGetInput:
            mov  rsi, qword[ioBuffer.cmdLineStart]
           test  rsi, rsi
            jnz  UciNextCmdFromCmdLine
           call  ReadLine
           test  eax, eax
            jnz  UciQuit

UciChoose:
    ; rsi is the address of the string to process

            cmp  byte[rsi], ' '
             jb  UciGetInput     ; don't process empty lines

           call  SkipSpaces

            lea  rcx, [sz_go]
           call  CmpString
           test  eax, eax
            jnz  UciGo

            lea  rcx, [sz_position]
           call  CmpString
           test  eax, eax
            jnz  UciPosition

            lea  rcx, [sz_stop]
           call  CmpString
           test  eax, eax
            jnz  UciStop

            lea  rcx, [sz_isready]
           call  CmpString
           test  eax, eax
            jnz  UciIsReady

            lea  rcx, [sz_ponderhit]
           call  CmpString
           test  eax, eax
            jnz  UciPonderHit

            lea  rcx, [sz_ucinewgame]    ; check before uci :)
           call  CmpString
           test  eax, eax
            jnz  UciNewGame

            lea  rcx, [sz_uci]
           call  CmpString
           test  eax, eax
            jnz  UciUci

            lea  rcx, [sz_setoption]
           call  CmpString
           test  eax, eax
            jnz  UciSetOption

            lea  rcx, [sz_quit]
           call  CmpString
           test  eax, eax
            jnz  UciQuit

            lea  rcx, [sz_wait]
           call  CmpString
           test  eax, eax
            jnz  UciWait

            lea  rcx, [sz_perft]
           call  CmpString
           test  eax, eax
            jnz  UciPerft

            lea  rcx, [sz_bench]
           call  CmpString
           test  eax, eax
            jnz  UciBench

if VERBOSE > 0
         szcall  CmpString, 'show'
           test  eax, eax
            jnz  UciShow
         szcall  CmpString, 'undo'
           test  eax, eax
            jnz  UciUndo
         szcall  CmpString, 'moves'
           test  eax, eax
            jnz  UciMoves
         szcall  CmpString, 'donull'
           test  eax, eax
            jnz  UciDoNull
         szcall  CmpString, 'eval'
           test  eax, eax
            jnz  UciEval
end if

if USE_BOOK > 0
         szcall  CmpString, 'bookprobe'
           test  eax, eax
             jz  @1f
           call  Book_DisplayProbe
            jmp  UciGetInput
        @1:
end if

if PROFILE > 0
         szcall  CmpString, 'profile'
           test  eax, eax
            jnz  UciProfile
end if

UciUnknown:
            lea  rdi, [Output]
            lea  rcx, [sz_error_unknown]
           call  PrintString
            mov  ecx, 64
           call  ParseToken
        PrintNL
            jmp  UciWriteOut



UciQuit:
            mov  byte[signals.stop], -1
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_StartSearching_TRUE
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_WaitForSearchFinished
            mov  rcx, qword[UciLoop.th1.rootPos.stateTable]
            mov  rdx, qword[UciLoop.th1.rootPos.stateEnd]
            sub  rdx, rcx
           call  Os_VirtualFree
            add  rsp, UciLoop.localsize
            pop  r15 r14 r13 r12 r11 rbx rdi rsi rbp
            ret


;;;;;;;;
; uci
;;;;;;;;


UciUci:
            lea  rcx, [szUciResponse]
            lea  rdi, [szUciResponseEnd]
           call  WriteLine
            jmp  UciGetInput


;;;;;;;;;;;;
; isready
;;;;;;;;;;;;

UciIsReady:
            mov  al, byte[options.changed]
           test  al, al
             jz  .ok
           call  UciSync
    .ok:
            lea  rdi, [Output]
            mov  rax, 'readyok'
          stosq
            sub  rdi, 1
        PrintNL
            jmp  UciWriteOut


;;;;;;;;;;;;;
; ponderhit
;;;;;;;;;;;;;

UciPonderHit:
          movzx  eax, byte[signals.stopOnPonderhit]
           test  al, al
            jnz  .stop
            mov  byte[limits.ponder], al
if USE_BOOK
    ; if have a book move, the search should be stopped
            cmp  eax, dword[book.move]
             je  @1f
            mov  byte[signals.stop], -1
    @1:
end if
    ; we are now switching to normal search mode
    ; check the time in case we have to abort the search asap
           call  CheckTime
            jmp  UciGetInput
.stop:
            mov  byte[signals.stop], -1
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_StartSearching_TRUE
            jmp  UciGetInput


;;;;;;;;
; stop
;;;;;;;;

UciStop:
            mov  byte[signals.stop], -1
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_StartSearching_TRUE
UciWait:
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_WaitForSearchFinished
            jmp  UciGetInput


UciSync:
           push  rbx
           call  MainHash_ReadOptions
           call  ThreadPool_ReadOptions
            mov  byte[options.changed], 0
            pop  rbx
            ret


;;;;;;;
; go
;;;;;;;

UciGo:
xor ebx, ebx
            mov  al, byte[options.changed]
           test  al, al
             jz  .ok
           call  UciSync
	.ok:
            lea  rcx, [UciLoop.limits]
           call  Limits_Init
.ReadLoop:
           call  SkipSpaces
            cmp  byte[rsi], ' '
             jb  .ReadLoopDone

            lea  rdi, [UciLoop.limits.time+4*White]
            lea  rcx, [sz_wtime]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.time+4*Black]
            lea  rcx, [sz_btime]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.incr+4*White]
            lea  rcx, [sz_winc]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.incr+4*Black]
            lea  rcx, [sz_binc]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.infinite]
            lea  rcx, [sz_infinite]
           call  CmpString
           test  eax, eax
            jnz  .parse_true

            lea  rdi, [UciLoop.limits.movestogo]
            lea  rcx, [sz_movestogo]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.nodes]
            lea  rcx, [sz_nodes]
           call  CmpString
           test  eax, eax
            jnz  .parse_qword

            lea  rdi, [UciLoop.limits.movetime]
            lea  rcx, [sz_movetime]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.depth]
            lea  rcx, [sz_depth]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.mate]
            lea  rcx, [sz_mate]
           call  CmpString
           test  eax, eax
            jnz  .parse_dword

            lea  rdi, [UciLoop.limits.ponder]
            lea  rcx, [sz_ponder]
           call  CmpString
           test  eax, eax
            jnz  .parse_true

            lea  rcx, [sz_searchmoves]
           call  CmpString
           test  eax, eax
            jnz  .parse_searchmoves

.Error:
            lea  rdi, [Output]
            lea  rcx, [sz_error_token]
           call  PrintString
            mov  ecx, 64
           call  ParseToken
        PrintNL
            jmp  UciWriteOut

.ReadLoopDone:
            lea  rcx, [UciLoop.limits]
           call  Limits_Set
            lea  rcx, [UciLoop.limits]
           call  ThreadPool_StartThinking
            jmp  UciGetInput

.parse_qword:
           call  SkipSpaces
           call  ParseInteger
            mov  qword[rdi], rax
            jmp  .ReadLoop
.parse_dword:
           call  SkipSpaces
           call  ParseInteger
            mov  dword[rdi], eax
            jmp  .ReadLoop
.parse_true:
            mov  byte[rdi], -1
            jmp  .ReadLoop
.parse_searchmoves:
           call  SkipSpaces
           call  ParseUciMove
           test  eax, eax
             jz  .ReadLoop
            mov  ecx, dword[UciLoop.limits.moveVecSize]
            lea  rdi, [UciLoop.limits.moveVec]
    repne scasw
           test  ecx, ecx		   ; is the move already in the list?
            jnz  .parse_searchmoves
          stosw
            add  dword[UciLoop.limits.moveVecSize], 1
            jmp  .parse_searchmoves


;;;;;;;;;;;;
; position
;;;;;;;;;;;;

UciPosition:

xor ebx, ebx
           call  SkipSpaces
            cmp  byte[rsi], ' '
             jb  UciUnknown

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
            lea   rcx, [sz_moves]
           call   CmpString
            lea   rdi, [Output]
           test   eax, eax
             jz   .CheckJunk
           call   UciParseMoves
           test   rax, rax
             jz   UciGetInput
.badmove:
            mov   rsi, rax
            lea   rcx, [sz_error_moves]
           call   PrintString
            mov   ecx, 6
           call   ParseToken
        PrintNL
            lea   rbp, [UciLoop.th1.rootPos]
            jmp   UciWriteOut
.illegal:
            lea   rdi, [Output]
            lea   rcx, [sz_error_fen]
           call   PrintString
        PrintNL
            lea   rbp, [UciLoop.th1.rootPos]
            jmp   UciWriteOut
.BadCmd:
            lea   rbp, [UciLoop.th1.rootPos]
            jmp   UciUnknown
.CheckJunk:
            mov   al, byte[rsi]
            cmp   al, ' '
             jb   UciGetInput
            lea   rcx, [sz_error_token]
           call   PrintString
            mov   ecx, 6
           call   ParseToken
            jmp   UciWriteOut_NewLine

UciParseMoves:
    ; in: rbp position
    ;     rsi string
    ; rax = 0 if full string could be parsed
    ;     = address of illegal move if there is one
           push  rbx rsi rdi
.get_move:
           call  SkipSpaces
            xor  eax, eax
            cmp  byte[rsi], ' '
             jb  .done
           call  ParseUciMove
            mov  edi, eax
           test  eax, eax
            mov  rax, rsi
             jz  .done
            mov  ecx, 2
           call  Position_SetExtraCapacity
            mov  rbx, qword[rbp + Pos.state]
            mov  ecx, edi
            mov  dword[rbx + sizeof.State+State.currentMove], edi
           call  Move_GivesCheck
            mov  ecx, edi
            mov  byte[rbx + State.givesCheck], al
           call  Move_Do__UciParseMoves
            inc  dword[rbp + Pos.gamePly]
            mov  qword[rbp + Pos.state], rbx
           call  SetCheckInfo
            jmp  .get_move
.done:
            pop  rdi rcx rbx
            ret



;;;;;;;;;;;;
; setoption
;;;;;;;;;;;;


UciSetOption:
            mov  rax, qword[threadPool.threadTable+8*0]
            mov  al, byte[rax+Thread.searching]
            lea  rcx, [sz_error_think]
           test  al, al
            jnz  .Error
.Read:
           call  SkipSpaces
            lea  rcx, [sz_name]
           call  CmpString
            lea  rcx, [sz_error_name]
           test  eax, eax
             jz  .Error
           call  SkipSpaces

            lea  rcx, [sz_threads]
           call  CmpStringCaseless
            lea  rbx, [.Threads]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_hash]
           call  CmpStringCaseless
            lea  rbx, [.Hash]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_largepages]
           call  CmpStringCaseless
            lea  rbx, [.LargePages]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_nodeaffinity]
           call  CmpStringCaseless
            lea  rbx, [.NodeAffinity]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_priority]
           call  CmpStringCaseless
            lea  rbx, [.Priority]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_clear_hash]  ; arena may send Clear Hash
           call  CmpStringCaseless     ;  instead of ClearHash
           test  eax, eax		    ;
            jnz  .ClearHash	    ;

            lea  rcx, [sz_ponder]
           call  CmpStringCaseless
            lea  rbx, [.Ponder]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_contempt]
           call  CmpStringCaseless
            lea  rbx, [.Contempt]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_multipv]
           call  CmpStringCaseless
            lea  rbx, [.MultiPv]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_moveoverhead]
           call  CmpStringCaseless
            lea  rbx, [.MoveOverhead]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_uci_chess960]
           call  CmpStringCaseless
            lea  rbx, [.Chess960]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_logfile]
           call  CmpStringCaseless
            lea  rbx, [.Log]
           test  eax, eax
            jnz  .CheckValue

if USE_SYZYGY = 1
            lea  rcx, [sz_syzygypath]
           call  CmpStringCaseless
            lea  rbx, [.SyzygyPath]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_syzygyprobedepth]
           call  CmpStringCaseless
            lea  rbx, [.SyzygyProbeDepth]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_syzygy50moverule]
           call  CmpStringCaseless
            lea  rbx, [.Syzygy50MoveRule]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_syzygyprobelimit]
           call  CmpStringCaseless
            lea  rbx, [.SyzygyProbeLimit]
           test  eax, eax
            jnz  .CheckValue
end if

            lea  rcx, [sz_ttfile]
           call  CmpStringCaseless
            lea  rbx, [.HashFile]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_ttsave]
           call  CmpStringCaseless
           test  eax, eax
            jnz  .HashSave

            lea  rcx, [sz_ttload]
           call  CmpStringCaseless
           test  eax, eax
            jnz  .HashLoad

if USE_BOOK = 1
            lea  rcx, [sz_bookfile]
           call  CmpStringCaseless
            lea  rbx, [.BookFile]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_ownbook]
           call  CmpStringCaseless
            lea  rbx, [.OwnBook]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_bestbookmove]
           call  CmpStringCaseless
            lea  rbx, [.BestBookMove]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_bookdepth]
           call  CmpStringCaseless
            lea  rbx, [.BookDepth]
           test  eax, eax
            jnz  .CheckValue
end if

if USE_WEAKNESS = 1
            lea  rcx, [sz_uci_limitstrength]
           call  CmpStringCaseless
            lea  rbx, [.UciLimitStrength]
           test  eax, eax
            jnz  .CheckValue

            lea  rcx, [sz_uci_elo]
           call  CmpStringCaseless
            lea  rbx, [.UciElo]
           test  eax, eax
            jnz  .CheckValue
end if

if USE_VARIETY = 1
            lea  rcx, [sz_variety]
           call  CmpStringCaseless
            lea  rbx, [.Variety]
           test  eax, eax
            jnz  .CheckValue
end if

            lea  rdi, [Output]
            lea  rcx, [sz_error_option]
           call  PrintString
            mov  ecx, 64
           call  ParseToken
        PrintNL
            jmp  UciWriteOut

.Error:
            lea  rdi, [Output]
           call  PrintString
        PrintNL
           call  WriteLine_Output
            jmp  UciGetInput
.CheckValue:
           call  SkipSpaces
            lea  rcx, [sz_value]
           call  CmpString
            lea  rcx, [sz_error_value]
           test  eax, eax
             jz  .Error
           call  SkipSpaces
            jmp  rbx

; these options require further careful processing in UciSync and set changed = true
.LargePages:
           call  ParseBoole
            mov  byte[options.largePages], al
            mov  byte[options.changed], -1
            jmp  UciGetInput
.Hash:
           call  ParseInteger
  ClampUnsigned  eax, 1, 1 shl MAX_HASH_LOG2MB
            mov  ecx, eax
            mov  dword[options.hash], eax
            mov  byte[options.changed], -1
            jmp  UciGetInput
.Threads:
           call  ParseInteger
  ClampUnsigned  eax, 1, MAX_THREADS
            mov  dword[options.threads], eax
            mov  byte[options.changed], -1
            jmp  UciGetInput


; these options are processed right away
.NodeAffinity:
           call  ThreadPool_Destroy
            mov  rcx, rsi
           call  ThreadPool_Create
           call  Os_DisplayThreadPoolInfo
           call  ThreadPool_ReadOptions
            jmp  UciGetInput


.Priority:
           call  SkipSpaces

            lea  rcx, [sz_none]
           call  CmpStringCaseless
           test  eax, eax
            jnz  UciGetInput

            lea  rcx, [sz_normal]
           call  CmpStringCaseless
           test  eax, eax
            jnz  .PriorityNormal

            lea  rcx, [sz_low]
           call  CmpStringCaseless
           test  eax, eax
            jnz  .PriorityLow

            lea  rcx, [sz_idle]
           call  CmpStringCaseless
           test  eax, eax
            jnz  .PriorityIdle

            lea  rdi, [Output]
            lea  rcx, [sz_error_priority]
           call  PrintString
            mov  ecx, 64
           call  ParseToken
            jmp  UciWriteOut_NewLine

    .PriorityNormal:
           call  Os_SetPriority_Normal
            jmp  UciGetInput

    .PriorityLow:
           call  Os_SetPriority_Low
            jmp  UciGetInput

    .PriorityIdle:
           call  Os_SetPriority_Idle
            jmp  UciGetInput


.ClearHash:
           call  Search_Clear
            lea  rdi, [Output]
            lea  rcx, [sz_hash_cleared]
           call  PrintString
            jmp  UciWriteOut_NewLine

if USE_SYZYGY = 1
.SyzygyPath:
    ; if path is <empty>, send NULL to init
            lea  rcx, [sz_empty]
           call  CmpString
            xor  ecx, ecx
           test  eax, eax
            jnz  .SyzygyPathDone
    ; find terminator and replace it with zero
            mov  rcx, rsi
	@1:	
            add  rsi, 1
            cmp  byte[rsi], ' '
            jae  @1b
            mov  byte[rsi], 0
.SyzygyPathDone:
           call  Tablebase_Init
           call  Tablebase_DisplayInfo
            jmp  UciGetInput
end if

.HashFile:
	       call  SkipSpaces
    ; find terminator and replace it with zero
             or  ebx, -1
	@1:	
            add  ebx, 1
            cmp  byte[rsi+rbx], ' '
            jae  @1b
    ; back up if any spaces are present on the end
            add  ebx, 1
    @1:
            sub  ebx, 1
            mov  byte[rsi+rbx], 0
             jz  @2f
            cmp  byte[rsi+rbx-1], ' '
             je  @1b
    @2:
            add  ebx, 1
    ; null term string is now at rsi
    ; null terminated length is in ebx

            mov  rcx, qword[options.hashPath]
            mov  rdx, qword[options.hashPathSizeB]
            lea  rax, [options.hashPathBuffer]
            cmp  rcx, rax
             je  @1f
           call  Os_VirtualFree
    @1:	
            mov  ecx, ebx
            lea  rax, [options.hashPathBuffer]
            cmp  ecx, 100
             jb  @1f
           call  Os_VirtualAlloc
    @1:
            mov  rdi, rax
            mov  qword[options.hashPath], rax
            mov  qword[options.hashPathSizeB], rbx

    ; copy null terminated string
            mov  ecx, ebx
      rep movsb

            lea  rdi, [Output]
            lea  rcx, [sz_path_set]
           call  PrintString
            mov  rcx, qword[options.hashPath]
           call  PrintString
            jmp  UciWriteOut_NewLine

.HashSave:
           call  MainHash_SaveFile
            jmp  UciGetInput
.HashLoad:
           call  MainHash_LoadFile
            jmp  UciGetInput


; these options don't require any processing
.MultiPv:
           call  ParseInteger
  ClampUnsigned  eax, 1, MAX_MOVES
            mov  dword[options.multiPV], eax
            jmp  UciGetInput
.Chess960:
           call  ParseBoole
            mov  byte[options.chess960], al
            jmp  UciGetInput
.Ponder:
           call  ParseBoole
            mov  byte[options.ponder], al
            jmp  UciGetInput
.Contempt:
           call  ParseInteger
    ClampSigned  eax, -100, 100
            mov  dword[options.contempt], eax
            jmp  UciGetInput
.MoveOverhead:
           call  ParseInteger
  ClampUnsigned  eax, 0, 5000
            mov  dword[options.moveOverhead], eax
            jmp  UciGetInput

.Log:
    ; if path is <empty>, send NULL to init
            lea  rcx, [sz_empty]
           call  CmpString
            xor  ecx, ecx
           test  eax, eax
            jnz  .LogPathDone
    ; find terminator and replace it with zero
            mov  rcx, rsi
    @1:	
            add  rsi, 1
            cmp  byte[rsi], ' '
            jae  @1b
            mov  byte[rsi], 0
.LogPathDone:
           call  Log_Init
            jmp  UciGetInput



if USE_SYZYGY = 1
.SyzygyProbeDepth:
           call  ParseInteger
  ClampUnsigned  eax, 1, 100
            mov  dword[options.syzygyProbeDepth], eax
            jmp  UciGetInput
.Syzygy50MoveRule:
           call  ParseBoole
            mov  byte[options.syzygy50MoveRule], al
            jmp  UciGetInput
.SyzygyProbeLimit:
           call  ParseInteger
  ClampUnsigned  eax, 0, 6
            mov  dword[options.syzygyProbeLimit], eax
            jmp  UciGetInput
end if

if USE_BOOK = 1
.BookFile:
           call  Book_Load
            jmp  UciGetInput
.OwnBook:
           call  ParseBoole
            mov  byte[book.ownBook], al
            jmp  UciGetInput
.BestBookMove:
           call  ParseBoole
            mov  byte[book.bestBookMove], al
            jmp  UciGetInput
.BookDepth:
           call  ParseInteger
    ClampSigned  eax, -10, 100
            mov  dword[book.bookDepth], eax
            jmp  UciGetInput
end if

if USE_WEAKNESS = 1
.UciLimitStrength:
           call  ParseBoole
            mov  byte[weakness.enabled], al
            jmp  UciGetInput
.UciElo:
           call  ParseInteger
  ClampUnsigned  eax, 0, 3300
            mov  ecx, eax
           call  Weakness_SetElo
            jmp  UciGetInput
end if

if USE_VARIETY = 1
.Variety:
           call  ParseInteger
  ClampUnsigned  eax, 0, 40
            lea  ecx, [rax+1]
            mov  dword[options.varietyMod], ecx
            mov  ecx, -PawnValueEg
           imul  ecx
            mov  ecx, 100
           idiv  ecx
            mov  dword[options.varietyBound], eax
            jmp  UciGetInput
end if


;;;;;;;;;;;;
; *extras*
;;;;;;;;;;;;

UciPerft:
           call  SkipSpaces
           call  ParseInteger
           test  eax, eax
             jz  .bad_depth
            cmp  eax, 10		; probably will take a long time
             ja  .bad_depth
            mov  esi, eax
            mov  ecx, eax
           call  Position_SetExtraCapacity
           call  Os_SetPriority_Realtime
            mov  ecx, esi
           call  Perft_Root
           call  Os_SetPriority_Normal
            jmp  UciGetInput
.bad_depth:
            lea  rdi, [Output]
            lea  rcx, [sz_error_depth]
           call  PrintString
            mov  ecx, 8
           call  ParseToken
            jmp  UciWriteOut_NewLine



UciBench:
            mov  r12d, 13	 ; depth
            mov  r13d, 1	 ; threads
            mov  r14d, 16	 ; hash

            lea  rdi, [.parse_hash]
.parse_loop:
           call  SkipSpaces
            cmp  byte[rsi], ' '
             jb  .parse_done

          movzx  eax, byte[rsi]
            cmp  eax, '1'
             jb  @1f
            cmp  eax, '9'
             ja  @1f
           test  rdi, rdi
             jz  @1f
            jmp  rdi	; we have a number without preceding depth, threads, hash, or realtime token
    @1:
            lea  rcx, [sz_threads]
           call  CmpString
           test  eax, eax
            jnz  .parse_threads

            lea  rcx, [sz_depth]
           call  CmpString
           test  eax, eax
            jnz  .parse_depth

            lea  rcx, [sz_hash]
           call  CmpString
           test  eax, eax
            jnz  .parse_hash
            jmp  .parse_done

.parse_hash:
            lea  rdi, [.parse_threads]
           call  SkipSpaces
           call  ParseInteger
  ClampUnsigned  eax, 1, 1 shl MAX_HASH_LOG2MB
            mov  r14d, eax
            jmp  .parse_loop
.parse_threads:
            lea  rdi, [.parse_depth]
           call  SkipSpaces
           call  ParseInteger
  ClampUnsigned  eax, 1, MAX_THREADS
            mov  r13d, eax
            jmp  .parse_loop
.parse_depth:
            xor  edi, edi
           call  SkipSpaces
           call  ParseInteger
  ClampUnsigned  eax, 1, 40
            mov  r12d, eax
            jmp  .parse_loop

.parse_done:
    ; write out stats for this bench
            lea  rdi, [Output]
            mov  qword[UciLoop.extra+8*0], r14
            mov  qword[UciLoop.extra+8*1], r13
            mov  qword[UciLoop.extra+8*2], r12
            lea  rcx, [sz_format_bench1]
            lea  rdx, [UciLoop.extra]
            xor  r8, r8
           call  PrintFancy
if VERBOSE = 0
	       call  WriteLine_Output
end if
            mov  dword[options.hash], r14d
           call  MainHash_ReadOptions
            mov  dword[options.threads], r13d
           call  ThreadPool_ReadOptions

            xor  eax, eax
            mov  qword[UciLoop.nodes], rax
if VERBOSE = 0
            mov  byte[options.displayInfoMove], al
end if
           call  Search_Clear

            xor  r13d, r13d
            mov  qword[UciLoop.time], r13
            mov  qword[UciLoop.nodes], r13
            lea  rsi, [BenchFens]
.nextpos:
            add  r13d, 1
           call  SkipSpaces

            lea  rcx, [Bench960Fens]
            sub  rcx, rsi
            neg  ecx
            sar  ecx, 31
            not  ecx

            lea  rbp, [UciLoop.th1.rootPos]
            mov  byte[options.chess960], cl
           call  Position_ParseFEN
           call  SkipSpaces
            lea  rcx, [sz_moves]
           call  CmpString
           test  eax, eax
             jz  @1f
           call  UciParseMoves
    @1:
            lea  rcx, [UciLoop.limits]
           call  Limits_Init
            lea  rcx, [UciLoop.limits]
            mov  dword[rcx+Limits.depth], r12d
           call  Limits_Set
            lea  rcx, [UciLoop.limits]

           call  Os_GetTime
            mov  r14, rax
            lea  rcx, [UciLoop.limits]
           call  ThreadPool_StartThinking
            mov  rcx, qword[threadPool.threadTable + 8*0]
           call  Thread_WaitForSearchFinished
           call  Os_GetTime
            sub  r14, rax
            neg  r14
           call  ThreadPool_NodesSearched_TbHits
            add  qword[UciLoop.time], r14
            add  qword[UciLoop.nodes], rax
            mov  r15, rax

    ; write out stats for this position
            lea  rdi, [Output]
            mov  rcx, r14
            cmp  r14, 1
            adc  rcx, 0
            mov  rax, r15
            xor  edx, edx
            div  rcx
            mov  qword[UciLoop.extra + 8*0], r13
            mov  qword[UciLoop.extra + 8*1], r15
            mov  qword[UciLoop.extra + 8*2], rax
            lea  rcx, [sz_format_bench2]
            lea  rdx, [UciLoop.extra]
            xor  r8, r8
           call  PrintFancy


if VERBOSE = 0
           call  WriteLine_Output
else
            lea  rcx, [Output]
           call  Os_WriteError
end if

            cmp  rsi, BenchFensEnd
             jb  .nextpos

    ; write out stats for overall bench
            lea  rdi, [Output]
            mov  rax, qword[UciLoop.nodes]
            mov  rcx, qword[UciLoop.time]
            mov  edx, 1000
            mov  qword[UciLoop.extra+8*0], rcx
            mov  qword[UciLoop.extra+8*1], rax
            mul  rdx
            cmp  rcx, 1
            adc  rcx, 0
            div  rcx
            mov  qword[UciLoop.extra+8*2], rax
            lea  rcx, [sz_format_bench3]
            lea  rdx, [UciLoop.extra]
            xor  r8, r8
           call  PrintFancy

if VERBOSE = 0
           call  WriteLine_Output
else
            lea  rcx, [Output]
           call  Os_WriteError
end if
            mov  byte[options.displayInfoMove], -1
            jmp  UciGetInput




if VERBOSE > 0

UciDoNull:
            mov  rbx, qword[rbp + Pos.state]
            mov  rax, qword[rbx + State.checkersBB]
           test  rax, rax
            jnz  UciGetInput

            mov  rax, rbx
            sub  rax, qword[rbp + Pos.stateTable]
            xor  edx, edx
            mov  ecx, sizeof.State
            div  ecx
            lea  ecx, [rax + 8]
            shr  ecx, 2
            add  ecx, eax
           call  Position_SetExtraCapacity
            mov  rbx, qword[rbp + Pos.state]
            mov  dword[rbx + sizeof.State + State.currentMove], MOVE_NULL
           call  Move_DoNull
            mov  qword[rbp + Pos.state], rbx
           call  SetCheckInfo
            jmp  UciShow

UciShow:
            lea  rdi, [Output]
            mov  rbx, qword[rbp + Pos.state]
           call  Position_Print
            jmp  UciWriteOut

UciUndo:
            mov  rbx, qword[rbp + Pos.state]
           call  SkipSpaces
           call  ParseInteger
            sub  eax, 1
            adc  eax, 0
            mov  r15d, eax
.Undo:
            cmp  rbx, qword[rbp + Pos.stateTable]
            jbe  UciShow
            mov  ecx, dword[rbx + State.currentMove]
           call  Move_Undo
            sub  r15d, 1
            jns  .Undo
            jmp  UciShow


UciMoves:
           call  UciParseMoves
            jmp  UciShow




UciEval:
            mov  rbx, qword[rbp+Pos.state]
    ; allocate pawn hash
            mov  ecx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
           call  Os_VirtualAlloc
            mov  qword[rbp+Pos.pawnTable], rax
    ; allocate material hash
            mov  ecx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
           call  Os_VirtualAlloc
            mov  qword[rbp+Pos.materialTable], rax
           call  Evaluate
            mov  r15d, eax
    ; free material hash
            mov  rcx, qword[rbp+Pos.materialTable]
            mov  edx, MATERIAL_HASH_ENTRY_COUNT*sizeof.MaterialEntry
           call  Os_VirtualFree
            xor  eax, eax
            mov  qword[rbp+Pos.materialTable], rax
    ; free pawn hash
            mov  rcx, qword[rbp+Pos.pawnTable]
            mov  edx, PAWN_HASH_ENTRY_COUNT*sizeof.PawnEntry
           call  Os_VirtualFree
            xor  eax, eax
            mov  qword[rbp+Pos.pawnTable], rax

            lea  rdi, [Output]
         movsxd  rax, r15d
           call  PrintSignedInteger
            mov  eax, ' == '
          stosd
            mov  ecx, r15d
           call  PrintScore_Uci
        PrintNL
            jmp  UciWriteOut

end if

