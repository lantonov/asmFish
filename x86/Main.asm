Start:
if VERSION_OS = 'L'
            mov  qword[rspEntry], rsp
else if VERSION_OS = 'W'

else if VERSION_OS = 'X'
            mov  qword[rspEntry], rsp
end if

            and  rsp, -16

           call  Os_SetStdHandles
           call  Os_InitializeTimer
           call  Os_CheckCPU

    ; init the engine
           call  Options_Init
           call  MoveGen_Init
           call  BitBoard_Init
           call  Position_Init
           call  BitTable_Init
           call  Search_Init
           call  Evaluate_Init
           call  Pawn_Init
           call  Endgame_Init

    ; setup logger
if LOG_FILE = '<empty>'
            xor  ecx, ecx
else
        lstring  rcx, @1f, LOG_FILE
     @1:
end if
           call  Log_Init

    ; write engine name
if VERBOSE = 0
            lea  rdi, [szGreetingEnd]
            lea  rcx, [szGreeting]
           call  WriteLine
end if

    ; set up threads, hash, and tablebases
           call  MainHash_Create
            xor  ecx, ecx
           call  ThreadPool_Create
if USE_SYZYGY
            xor  ecx, ecx
           call  Tablebase_Init
end if
if USE_BOOK
           call  Book_Create
end if
if USE_WEAKNESS
	       call  Weakness_Create
end if

    ; command line could contain commands
    ; this function also initializes InputBuffer
    ; which contains the commands we should process first
           call  Os_ParseCommandLine

    ; enter the main loop
           call  UciLoop

    ; clean up threads, hash, and tablebases
if USE_BOOK
           call  Book_Destroy
end if
if USE_SYZYGY
            xor  ecx, ecx
           call  Tablebase_Init
end if
           call  ThreadPool_Destroy
           call  MainHash_Destroy

    ; release logger file if in use
            xor  ecx, ecx
           call  Log_Init

    ; options may also require cleaning
           call  Options_Destroy

    ; clean up input buffer
            mov  rcx, qword[ioBuffer.inputBuffer]
            mov  rdx, qword[ioBuffer.inputBufferSizeB]
           call  Os_VirtualFree

            xor  ecx, ecx
           call  Os_ExitProcess

