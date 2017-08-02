		and   rsp, -16

	       call   _SetStdHandles
	       call   _InitializeTimer
	       call   _CheckCPU

match ='X', VERSION_OS {
Display 0, "Hello!%n"

call _GetTime
Display 0, "      time: %X0.%X2%n"
push rax rdx
call _GetTime_SYS
Display 0, "check time: %X0.%X2%n"
push rax rdx

mov ecx, 1000000000
mov eax, ecx
@@:
mul rcx
sub ecx, 1
jnz @b

call _GetTime
Display 0, "      time: %X0.%X2%n"
push rax rdx
call _GetTime_SYS
Display 0, "check time: %X0.%X2%n"
push rax rdx

mov rdx, qword[rsp+16*1+8*0]
mov rax, qword[rsp+16*1+8*1]
sub rdx, qword[rsp+16*3+8*0]
sbb rax, qword[rsp+16*3+8*1]
Display 0, "      diff: %X0.%X2%n"
mov rdx, qword[rsp+16*0+8*0]
mov rax, qword[rsp+16*0+8*1]
sub rdx, qword[rsp+16*2+8*0]
sbb rax, qword[rsp+16*2+8*1]
Display 0, "check diff: %X0.%X2%n"

mov ecx, 1000000
call _VirtualAlloc
Display 0, "memory: %X0%n"
mov rcx, rax
mov edx, 1000000
call _VirtualFree
Display 0, "freed!%n"
mov ecx, 1
call _ExitProcess
}

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

	     Assert   e, qword[DebugBalance], 0, 'assertion DebugBalance=0 failed'

	       call   _ExitProcess
