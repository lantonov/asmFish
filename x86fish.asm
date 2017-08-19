VERSION_OS = 'W'
VERSION_PRE = 'asmFish'
VERSION_POST = 'popcnt'

CPU_HAS_POPCNT = 1
CPU_HAS_BMI1 = 0
CPU_HAS_BMI2 = 0
CPU_HAS_AVX1 = 0        ; not implemented
CPU_HAS_AVX2 = 0        ; not implemented

DEBUG   = 0
VERBOSE = 0
PROFILE = 0

USE_SYZYGY      = 1
USE_CURRMOVE    = 1
USE_HASHFULL    = 1
USE_CMDLINEQUIT = 1
USE_SPAMFILTER  = 0
USE_WEAKNESS    = 0
USE_VARIETY     = 0
USE_BOOK        = 0
USE_MATEFINDER  = 0


; instruction and format macros
include 'format/format.inc'
include 'bmi2.inc'
include 'avx.inc'

if VERSION_OS = 'L'
  format ELF64 executable 3
  entry Start
else if VERSION_OS = 'W'
  format PE64 console
  stack THREAD_STACK_SIZE
  entry Start
end if

; assembler macros
include 'x86/fasm1macros.asm'

; basic macros
if VERSION_OS = 'L'
  include 'x86/linux64.asm'
else if VERSION_OS = 'W'
  include 'x86/windows64.asm'
end if
include 'x86/Def.asm'
include 'x86/Structs.asm'
include 'x86/AvxMacros.asm'
include 'x86/BasicMacros.asm'
include 'x86/Debug.asm'

; engine macros
include 'x86/AttackMacros.asm'
include 'x86/GenMacros.asm'
include 'x86/MovePickMacros.asm'
include 'x86/SearchMacros.asm'
include 'x86/QSearchMacros.asm'
include 'x86/MainHashMacros.asm'
include 'x86/PosIsDrawMacro.asm'
include 'x86/Pawn.asm'
include 'x86/SliderBlockers.asm'
include 'x86/UpdateStats.asm'


; data section
if VERSION_OS = 'L'
  segment readable writeable
else if VERSION_OS = 'W'
  section '.bss' data readable writeable
end if
include 'x86/MainData.asm'
if USE_SYZYGY
  include 'x86/TablebaseData.asm'
end if


; reserve section
if VERSION_OS = 'L'
  segment readable writeable
else if VERSION_OS = 'W'
  section '.bss' data readable writeable
end if
include 'x86/MainBss.asm'


; code section
if VERSION_OS = 'L'
  segment readable executable
else if VERSION_OS = 'W'
  section '.code' code readable executable
end if

if USE_SYZYGY
  include 'x86/TablebaseCore.asm'
  include 'x86/Tablebase.asm'
end if
include 'x86/Endgame.asm'
include 'x86/Evaluate.asm'
include 'x86/MainHash_Probe.asm'
include 'x86/Move_IsPseudoLegal.asm'
include 'x86/SetCheckInfo.asm'
include 'x86/Move_GivesCheck.asm'
include 'x86/Gen_Captures.asm'
include 'x86/Gen_Quiets.asm'
include 'x86/Gen_QuietChecks.asm'
include 'x86/Gen_Evasions.asm'
include 'x86/MovePick.asm'
include 'x86/Move_IsLegal.asm'
include 'x86/Move_Do.asm'
include 'x86/Move_Undo.asm'

	     calign   16
QSearch_NonPv_NoCheck:  QSearch   0, 0
	     calign   16
QSearch_NonPv_InCheck:  QSearch   0, 1
	     calign   16
QSearch_Pv_InCheck:     QSearch   1, 1
	     calign   16
QSearch_Pv_NoCheck:     QSearch   1, 0
	     calign   64
Search_NonPv:   search   0, 0

include 'x86/SeeTest.asm'
if DEBUG
  include 'x86/See.asm'
end if
include 'x86/Move_DoNull.asm'
include 'x86/CheckTime.asm'
include 'x86/Castling.asm'

	    calign   16
Search_Pv:      search   0, 1
	    calign   16
Search_Root:    search   1, 1

include 'x86/Gen_NonEvasions.asm'
include 'x86/Gen_Legal.asm'
include 'x86/Perft.asm'
include 'x86/AttackersTo.asm'
include 'x86/EasyMoveMng.asm'
include 'x86/Think.asm'
include 'x86/TimeMng.asm'
if USE_WEAKNESS
  include 'x86/Weakness.asm'
end if
include 'x86/Position.asm'
include 'x86/MainHash.asm'
include 'x86/RootMoves.asm'
include 'x86/Limits.asm'
include 'x86/Thread.asm'
include 'x86/ThreadPool.asm'
include 'x86/Uci.asm'
include 'x86/Search_Clear.asm'
include 'x86/PrintParse.asm'
include 'x86/Math.asm'
if VERSION_OS = 'L'
  include 'x86/OsLinux.asm'
else if VERSION_OS = 'W'
  include 'x86/OsWindows.asm'
end if
if USE_BOOK
  include 'Book.asm'
end if
include 'x86/Main.asm'          ; entry point in here
include 'x86/Search_Init.asm'
include 'x86/Position_Init.asm'
include 'x86/MoveGen_Init.asm'
include 'x86/BitBoard_Init.asm'
include 'x86/BitTable_Init.asm'
include 'x86/Evaluate_Init.asm'
include 'x86/Pawn_Init.asm'
include 'x86/Endgame_Init.asm'


if VERSION_OS = 'W'
  section '.idata' import data readable writeable

  dd 0, 0, 0, RVA _sz_kernel_name, RVA _kernel_table
  dd 0, 0, 0, 0, 0

_sz_kernel_name db 'KERNEL32.DLL',0

_kernel_table:
    __imp_CreateFileA dq RVA _sz_CreateFileA
    __imp_CreateMutexA dq RVA _sz_CreateMutexA
    __imp_CloseHandle dq RVA _sz_CloseHandle
    __imp_CreateEventA dq RVA _sz_CreateEventA
    __imp_CreateFileMappingA dq RVA _sz_CreateFileMappingA
    __imp_CreateThread dq RVA _sz_CreateThread
    __imp_DeleteCriticalSection dq RVA _sz_DeleteCriticalSection
    __imp_EnterCriticalSection dq RVA _sz_EnterCriticalSection
    __imp_ExitProcess dq RVA _sz_ExitProcess
    __imp_ExitThread dq RVA _sz_ExitThread
    __imp_FreeLibrary dq RVA _sz_FreeLibrary
    __imp_GetCommandLineA dq RVA _sz_GetCommandLineA
    __imp_GetCurrentProcess dq RVA _sz_GetCurrentProcess
    __imp_GetFileSize dq RVA _sz_GetFileSize
    __imp_GetLastError dq RVA _sz_GetLastError
    __imp_GetModuleHandleA dq RVA _sz_GetModuleHandleA
    __imp_GetProcAddress dq RVA _sz_GetProcAddress
    __imp_GetProcessAffinityMask dq RVA _sz_GetProcessAffinityMask
    __imp_GetStdHandle dq RVA _sz_GetStdHandle
    __imp_InitializeCriticalSection dq RVA _sz_InitializeCriticalSection
    __imp_LeaveCriticalSection dq RVA _sz_LeaveCriticalSection
    __imp_LoadLibraryA dq RVA _sz_LoadLibraryA
    __imp_MapViewOfFile dq RVA _sz_MapViewOfFile
    __imp_QueryPerformanceCounter dq RVA _sz_QueryPerformanceCounter
    __imp_QueryPerformanceFrequency dq RVA _sz_QueryPerformanceFrequency
    __imp_ReadFile dq RVA _sz_ReadFile
    __imp_ReleaseMutex dq RVA _sz_ReleaseMutex
    __imp_ResumeThread dq RVA _sz_ResumeThread
    __imp_SetEvent dq RVA _sz_SetEvent
    __imp_SetPriorityClass dq RVA _sz_SetPriorityClass
    __imp_SetThreadAffinityMask dq RVA _sz_SetThreadAffinityMask
    __imp_Sleep dq RVA _sz_Sleep
    __imp_UnmapViewOfFile dq RVA _sz_UnmapViewOfFile
    __imp_VirtualAlloc dq RVA _sz_VirtualAlloc
    __imp_VirtualFree dq RVA _sz_VirtualFree
    __imp_WaitForSingleObject dq RVA _sz_WaitForSingleObject
    __imp_WriteFile dq RVA _sz_WriteFile
    dq 0

_sz_CreateFileA db 0,0,'CreateFileA',0
_sz_CreateMutexA db 0,0,'CreateMutexA',0
_sz_CloseHandle db 0,0,'CloseHandle',0
_sz_CreateEventA db 0,0,'CreateEventA',0
_sz_CreateFileMappingA db 0,0,'CreateFileMappingA',0
_sz_CreateThread db 0,0,'CreateThread',0
_sz_DeleteCriticalSection db 0,0,'DeleteCriticalSection',0
_sz_EnterCriticalSection db 0,0,'EnterCriticalSection',0
_sz_ExitProcess db 0,0,'ExitProcess',0
_sz_ExitThread db 0,0,'ExitThread',0
_sz_FreeLibrary db 0,0,'FreeLibrary',0
_sz_GetCommandLineA db 0,0,'GetCommandLineA',0
_sz_GetCurrentProcess db 0,0,'GetCurrentProcess',0
_sz_GetFileSize db 0,0,'GetFileSize',0
_sz_GetLastError db 0,0,'GetLastError',0
_sz_GetModuleHandleA db 0,0,'GetModuleHandleA',0
_sz_GetProcAddress db 0,0,'GetProcAddress',0
_sz_GetProcessAffinityMask db 0,0,'GetProcessAffinityMask',0
_sz_GetStdHandle db 0,0,'GetStdHandle',0
_sz_InitializeCriticalSection db 0,0,'InitializeCriticalSection',0
_sz_LeaveCriticalSection db 0,0,'LeaveCriticalSection',0
_sz_LoadLibraryA db 0,0,'LoadLibraryA',0
_sz_MapViewOfFile db 0,0,'MapViewOfFile',0
_sz_QueryPerformanceCounter db 0,0,'QueryPerformanceCounter',0
_sz_QueryPerformanceFrequency db 0,0,'QueryPerformanceFrequency',0
_sz_ReadFile db 0,0,'ReadFile',0
_sz_ReleaseMutex db 0,0,'ReleaseMutex',0
_sz_ResumeThread db 0,0,'ResumeThread',0
_sz_SetEvent db 0,0,'SetEvent',0
_sz_SetPriorityClass db 0,0,'SetPriorityClass',0
_sz_SetThreadAffinityMask db 0,0,'SetThreadAffinityMask',0
_sz_Sleep db 0,0,'Sleep',0
_sz_UnmapViewOfFile db 0,0,'UnmapViewOfFile',0
_sz_VirtualAlloc db 0,0,'VirtualAlloc',0
_sz_VirtualFree db 0,0,'VirtualFree',0
_sz_WaitForSingleObject db 0,0,'WaitForSingleObject',0
_sz_WriteFile db 0,0,'WriteFile',0

end if
