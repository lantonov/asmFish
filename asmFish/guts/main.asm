		and   rsp, -16

	       call   _SetStdHandles
	       call   _InitializeTimer
	       call   _CheckCPU

GD GetTime

        ; init the engine
	       call   Options_Init
	       call   MoveGen_Init
	       call   BitBoard_Init
	       call   Position_Init
	       call   BitTable_Init
	       call   Search_Init
	       call   Evaluate_Init
	       call   Pawn_Init
	       call   Endgame_Init

GD String, 'init done'
GD NewLine


	; write engine name
match =0, VERBOSE {
		lea   rdi, [szGreetingEnd]
		lea   rcx, [szGreeting]
	       call   _WriteOut
}

	; set up threads, hash, and tablebases
	       call   MainHash_Create
		xor   ecx, ecx
	       call   ThreadPool_Create
if USE_SYZYGY
		xor   ecx, ecx
	       call   Tablebase_Init
end if
if USE_BOOK
	       call   Book_Create
end if
if USE_WEAKNESS
	       call   Weakness_Create
end if


	; command line could contain commands
	; this function also initializes InputBuffer
	; which contains the commands we should process first
	       call   _ParseCommandLine

GD ResponseTime
GD GetTime

	; enter the main loop
	       call   UciLoop

	; clean up threads, hash, and tablebases

if USE_BOOK
	       call   Book_Destroy
end if
if USE_SYZYGY
		xor   ecx, ecx
	       call   Tablebase_Init
end if
	       call   ThreadPool_Destroy
	       call   MainHash_Destroy

	; options may also require cleaning
	       call   Options_Destroy

	; clean up input buffer
		mov   rcx, qword[ioBuffer.inputBuffer]
		mov   rdx, qword[ioBuffer.inputBufferSizeB]
	       call   _VirtualFree

match =1, DEBUG {
GD String, 'DebugBalance: '
GD Hex, qword[DebugBalance]
GD NewLine
}
	     Assert   e, qword[DebugBalance], 0, 'assertion DebugBalance=0 failed'

	       call   _ExitProcess
