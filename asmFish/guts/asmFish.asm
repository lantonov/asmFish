; sanity check on compile options
if (not CPU_HAS_POPCNT) and (CPU_HAS_AVX1 or CPU_HAS_AVX2 or CPU_HAS_BMI1 or CPU_HAS_BMI2)
	  display 'WARNING: if cpu does not have POPCNT, it probably does not have higher capabilities'
	  display 13,10
end if

if (not CPU_HAS_AVX1) and CPU_HAS_AVX2
	  display 'ERROR: if cpu does not have AVX1, it definitely does not have AVX2'
	  display 13,10
	  err
end if

if (not CPU_HAS_BMI1) and CPU_HAS_BMI2
	  display 'ERROR: if cpu does not have BMI1, it definitely does not have BMI2'
	  display 13,10
	  err
end if




include 'fasmMacros.asm'
include 'Def.asm'


match ='W', VERSION_OS {
format PE64 console
stack THREAD_STACK_SIZE
entry Start
include 'myWin64a.asm'
}
match ='L', VERSION_OS {
format ELF64 executable 3
entry Start
include 'linux64.asm'
}
match ='X', VERSION_OS {
format ELF64
include 'mac64.asm'
}
match ='C', VERSION_OS {
format ELF64
include 'libc64.asm'
}


include 'BasicMacros.asm'
include 'Structs.asm'
include 'Debug.asm'


match ='W', VERSION_OS {
section '.data' data readable writeable
}
match ='L', VERSION_OS {
segment readable writeable
}
match ='X', VERSION_OS {
section '.data' writeable align 64
}
match ='C', VERSION_OS {
section '.data' writeable align 64
}

include 'dataSection.asm'



match ='W', VERSION_OS {
section '.bss' data readable writeable
}
match ='L', VERSION_OS {
segment readable writeable
}
match ='X', VERSION_OS {
section '.bss' writeable align 4096
}
match ='C', VERSION_OS {
section '.bss' writeable align 4096
}

include 'bssSection.asm'



match ='W', VERSION_OS {
section '.code' code readable executable
}
match ='L', VERSION_OS {
segment readable executable
}
match ='X', VERSION_OS {
section '.code' executable align 64
}
match ='C', VERSION_OS {
section '.code' executable align 64
}

; these are all macros
include 'AvxMacros.asm'
include 'AttackMacros.asm'
include 'GenMacros.asm'
include 'MovePickMacros.asm'
include 'SearchMacros.asm'
include 'QSearchMacros.asm'
include 'MainHashMacros.asm'
include 'PosIsDrawMacro.asm'
include 'Pawn.asm'
include 'SliderBlockers.asm'
include 'UpdateStats.asm'



if USE_SYZYGY
 include 'TablebaseCore.asm'
 include 'Tablebase.asm'
end if

include 'Endgame.asm'
include 'Evaluate.asm'

include 'MainHash_Probe.asm'

include 'Move_IsPseudoLegal.asm'
include 'SetCheckInfo.asm'
include 'Move_GivesCheck.asm'

include 'Gen_Captures.asm'
include 'Gen_Quiets.asm'
include 'Gen_QuietChecks.asm'
include 'Gen_Evasions.asm'
include 'MovePick.asm'

include 'Move_IsLegal.asm'
include 'Move_Do.asm'
include 'Move_Undo.asm'


	      align   16
QSearch_NonPv_NoCheck:
	    QSearch   _NONPV_NODE, 0
	      align   16
QSearch_NonPv_InCheck:
	    QSearch   _NONPV_NODE, 1
	      align   16
QSearch_Pv_InCheck:
	    QSearch   _PV_NODE, 1
	      align   16
QSearch_Pv_NoCheck:
	    QSearch   _PV_NODE, 0


	      align   64
Search_NonPv:
	    search   _NONPV_NODE

include 'SeeTest.asm'
if DEBUG
 include 'See.asm'
end if
include 'Move_DoNull.asm'
include 'CheckTime.asm'
include 'Castling.asm'

	     align   16
Search_Pv:
	    search   _PV_NODE
	     align   16
Search_Root:
	    search   _ROOT_NODE



include 'Gen_NonEvasions.asm'
include 'Gen_Legal.asm'
include 'Perft.asm'

include 'AttackersTo.asm'

include 'EasyMoveMng.asm'
include 'Think.asm'
include 'TimeMng.asm'

if USE_WEAKNESS
include 'Weakness.asm'
end if

include 'Position.asm'
include 'MainHash.asm'

include 'RootMoves.asm'
include 'Limits.asm'

include 'Thread.asm'
include 'ThreadPool.asm'
include 'Uci.asm'
include 'Search_Clear.asm'

include 'PrintParse.asm'
include 'Math.asm'

match ='W', VERSION_OS {
include 'OsWindows.asm'
}
match ='L', VERSION_OS {
include 'OsLinux.asm'
}
match ='X', VERSION_OS {
include 'OsX.asm'
}
match ='C', VERSION_OS {
include 'OsLibc.asm'
}

if USE_BOOK
 include 'Book.asm'
end if

match = 'W', VERSION_OS {
Start:
}
match = 'L', VERSION_OS {
Start:
}
match = 'X', VERSION_OS {
public _main
_main:
}
match = 'C', VERSION_OS {
public main
main:
}



match ='L', VERSION_OS {
		mov   qword[rspEntry], rsp
}
match ='X', VERSION_OS {
                mov   qword[argc], rdi
                mov   qword[argv], rsi
}
match ='C', VERSION_OS {
                mov   qword[argc], rdi
                mov   qword[argv], rsi
}
include 'main.asm'

include 'Search_Init.asm'
include 'Position_Init.asm'
include 'MoveGen_Init.asm'
include 'BitBoard_Init.asm'
include 'BitTable_Init.asm'
include 'Evaluate_Init.asm'
include 'Pawn_Init.asm'
include 'Endgame_Init.asm'





if PROFILE > 0
; put this at the very end of code section to collect all the profile names
; in the preprocessor variables hitprofilelist and condprofilelist

DisplayProfileData:
               push   rbx rsi rdi
   PrintProfileData
                pop   rdi rsi rbx
                ret


; we also need a data section to keep track of the counts
match ='W', VERSION_OS {
section '.profile' data readable writeable
}
match ='L', VERSION_OS {
segment readable writeable
}
match ='X', VERSION_OS {
section '.profile' writeable
}
match ='C', VERSION_OS {
section '.profile' writeable
}

MakeProfileData

end if




; windows hides its syscall numbers and changes them from version to version
; so we have no choice but to link with kernel32.dll, which can be assumed to be loaded automatically

match ='W', VERSION_OS {

section '.idata' import data readable writeable

 library kernel,'KERNEL32.DLL'

import kernel,\
	__imp_CreateFileA,'CreateFileA',\
	__imp_CreateMutexA,'CreateMutexA',\
	__imp_CloseHandle,'CloseHandle',\
	__imp_CreateEvent,'CreateEventA',\
	__imp_CreateFileMappingA,'CreateFileMappingA',\
	__imp_CreateThread,'CreateThread',\
	__imp_DeleteCriticalSection,'DeleteCriticalSection',\
	__imp_EnterCriticalSection,'EnterCriticalSection',\
	__imp_ExitProcess,'ExitProcess',\
	__imp_ExitThread,'ExitThread',\
	__imp_FreeLibrary,'FreeLibrary',\
	__imp_GetCommandLineA,'GetCommandLineA',\
	__imp_GetCurrentProcess,'GetCurrentProcess',\
	__imp_GetFileSize,'GetFileSize',\
	__imp_GetLastError,'GetLastError',\
	__imp_GetModuleHandle,'GetModuleHandleA',\
	__imp_GetProcAddress,'GetProcAddress',\
	__imp_GetProcessAffinityMask,'GetProcessAffinityMask',\
	__imp_GetStdHandle,'GetStdHandle',\
	__imp_InitializeCriticalSection,'InitializeCriticalSection',\
	__imp_LeaveCriticalSection,'LeaveCriticalSection',\
	__imp_LoadLibraryA,'LoadLibraryA',\
	__imp_MapViewOfFile,'MapViewOfFile',\
	__imp_QueryPerformanceCounter,'QueryPerformanceCounter',\
	__imp_QueryPerformanceFrequency,'QueryPerformanceFrequency',\
	__imp_ReadFile,'ReadFile',\
	__imp_ReleaseMutex,'ReleaseMutex',\
	__imp_ResumeThread,'ResumeThread',\
	__imp_SetEvent,'SetEvent',\
	__imp_SetPriorityClass,'SetPriorityClass',\
	__imp_SetThreadAffinityMask,'SetThreadAffinityMask',\
	__imp_Sleep,'Sleep',\
	__imp_UnmapViewOfFile,'UnmapViewOfFile',\
	__imp_VirtualAlloc,'VirtualAlloc',\
	__imp_VirtualFree,'VirtualFree',\
	__imp_WaitForSingleObject,'WaitForSingleObject',\
	__imp_WriteFile,'WriteFile'

}
