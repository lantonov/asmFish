; VERSION_POST and VERSION_OS should be defined on cmd line
if ~ defined VERSION_OS
  err 'VERSION_OS is not defined'
end if

if ~ defined VERSION_POST
  err 'VERSION_POST is not defined'
end if

VERSION_PRE = 'asmFish'

macro SetDefault val*, sym*
  if ~ defined sym
    restore sym
    sym = val
  end if
end macro

SetDefault 0, DEBUG
SetDefault 0, VERBOSE
SetDefault 0, PROFILE

SetDefault 1, USE_SYZYGY
SetDefault 1, USE_CURRMOVE
SetDefault 1, USE_HASHFULL
SetDefault 1, USE_CMDLINEQUIT
SetDefault 0, USE_SPAMFILTER
SetDefault 0, USE_WEAKNESS
SetDefault 0, USE_VARIETY
SetDefault 0, USE_BOOK
SetDefault 0, USE_MATEFINDER

SetDefault 0, PEDANTIC
SetDefault '<empty>', LOG_FILE  ; use something other than <empty> to hardcode a starting log file into the engine

CPU_HAS_POPCNT = 0
CPU_HAS_BMI1 = 0
CPU_HAS_BMI2 = 0
CPU_HAS_AVX1 = 0 ; not implemented yet
CPU_HAS_AVX2 = 0 ;
if VERSION_POST = 'popcnt'
  CPU_HAS_POPCNT = 1
else if VERSION_POST = 'bmi2'
  CPU_HAS_POPCNT = 1
  CPU_HAS_BMI1 = 1
  CPU_HAS_BMI2 = 1
end if


; instruction and format macros
if VERSION_OS = 'L'
  include 'format/format.inc'
  include 'bmi2.inc'
  include 'avx.inc'
  format ELF64 executable 3
  entry Start
else if VERSION_OS = 'W'
  include 'format/format.inc'
  include 'bmi2.inc'
  include 'avx.inc'
  format PE64 console
  stack THREAD_STACK_SIZE
  entry Start
else if VERSION_OS = 'X'
  include 'x64.inc'
  include 'bmi2.inc'
  include 'avx.inc'
  use64
  MachO.Settings.ProcessorType equ CPU_TYPE_X86_64
  MachO.Settings.BaseAddress = 0x00400000
  include 'macinc/macho.inc'
  entry Start
end if

; assembler macros
include 'fasm1macros.asm'

; os headers
if VERSION_OS = 'L'
  include 'linux64.asm'
else if VERSION_OS = 'W'
  include 'windows64.asm'
else if VERSION_OS = 'X'
  include 'apple64.asm'
end if

; basic macros
include 'Def.asm'
include 'Structs.asm'
include 'AvxMacros.asm'
include 'BasicMacros.asm'
include 'Debug.asm'

; engine macros
include 'AttackMacros.asm'
include 'GenMacros.asm'
include 'MovePickMacros.asm'
include 'SearchMacros.asm'
include 'QSearchMacros.asm'
include 'HashMacros.asm'
include 'PosIsDrawMacro.asm'
include 'SliderBlockers.asm'
include 'UpdateStats.asm'
include 'Pawn.asm'


; data and bss section
if VERSION_OS = 'L'
  segment readable writeable
  include 'MainData.asm'
  segment readable writeable
  include 'MainBss.asm'
else if VERSION_OS = 'W'
  section '.data' data readable writeable
  include 'MainData.asm'
  section '.bss' data readable writeable
  include 'MainBss.asm'
end if


; code section
if VERSION_OS = 'L'
  segment readable executable
else if VERSION_OS = 'W'
  section '.code' code readable executable
else if VERSION_OS = 'X'
  segment '__TEXT' readable executable
  section '__text' align 64
end if

if USE_SYZYGY
  include 'TablebaseCore.asm'
  include 'Tablebase.asm'
end if
include 'Endgame.asm'
include 'Evaluate.asm'
include 'Hash_Probe.asm'
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

include 'SeeTest.asm'
include 'Move_DoNull.asm'
include 'CheckTime.asm'
include 'Castling.asm'

	    calign   16
Search_Pv:      search   0, 1
	    calign   16
Search_Root:    search   1, 1

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
include 'Hash.asm'
include 'RootMoves.asm'
include 'Limits.asm'
include 'Thread.asm'
include 'ThreadPool.asm'
include 'Uci.asm'
include 'Search_Clear.asm'
include 'PrintParse.asm'
include 'Math.asm'
if VERSION_OS = 'L'
  include 'OsLinux.asm'
else if VERSION_OS = 'W'
  include 'OsWindows.asm'
else if VERSION_OS = 'X'
  include 'OsMac.asm'
end if
if USE_BOOK
  include 'Book.asm'
end if
include 'Main.asm'          ; entry point in here
include 'Search_Init.asm'
include 'Position_Init.asm'
include 'MoveGen_Init.asm'
include 'BitBoard_Init.asm'
include 'BitTable_Init.asm'
include 'Evaluate_Init.asm'
include 'Pawn_Init.asm'
include 'Endgame_Init.asm'

; for mac, data and bss cannot come before first code section (?)
if VERSION_OS = 'X'
  segment '__DATA' readable writeable
  section '__data' align 16
  include 'MainData.asm'
  section '__bss' align 4096
  include 'MainBss.asm'
end if


if VERSION_OS = 'W'

  section '.idata' import data readable writeable
  library kernel,'KERNEL32.DLL'
  import kernel,\
	__imp_CreateFileA,'CreateFileA',\
	__imp_CloseHandle,'CloseHandle',\
	__imp_CreateEventA,'CreateEventA',\
	__imp_CreateFileMappingA,'CreateFileMappingA',\
	__imp_CreateThread,'CreateThread',\
	__imp_DeleteCriticalSection,'DeleteCriticalSection',\
	__imp_EnterCriticalSection,'EnterCriticalSection',\
	__imp_ExitProcess,'ExitProcess',\
	__imp_ExitThread,'ExitThread',\
	__imp_GetCommandLineA,'GetCommandLineA',\
	__imp_GetCurrentProcess,'GetCurrentProcess',\
	__imp_GetFileSize,'GetFileSize',\
	__imp_GetModuleHandleA,'GetModuleHandleA',\
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

else if VERSION_OS = 'X'

 interpreter '/usr/lib/dyld'
 uses '/usr/lib/libSystem.B.dylib' (1.0.0, 1225.0.0)
   import _clock_gettime, '_clock_gettime'
   import _close, '_close'
   import _exit, '_exit'
   import _fstat, '_fstat'
   import _mmap, '_mmap'
   import _munmap, '_munmap'
   import _nanosleep, '_nanosleep'
   import _open, '_open'
   import _pthread_cond_destroy, '_pthread_cond_destroy'
   import _pthread_cond_init, '_pthread_cond_init'
   import _pthread_cond_signal, '_pthread_cond_signal'
   import _pthread_cond_wait, '_pthread_cond_wait'
   import _pthread_create, '_pthread_create'
   import _pthread_exit, '_pthread_exit'
   import _pthread_mutex_destroy, '_pthread_mutex_destroy'
   import _pthread_mutex_init, '_pthread_mutex_init'
   import _pthread_mutex_lock, '_pthread_mutex_lock'
   import _pthread_mutex_unlock, '_pthread_mutex_unlock'
   import _pthread_join, '_pthread_join'
   import _read, '_read'
   import _write, '_write'

end if
