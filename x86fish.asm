; VERSION_POST and VERSION_OS should be defined on cmd line

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

VERSION_PRE = 'asmFish'

CPU_HAS_POPCNT = 0
CPU_HAS_BMI1 = 0
CPU_HAS_BMI2 = 0
CPU_HAS_AVX1 = 0 ; not implemented
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
  include 'x86/macinc/macho.inc'
  entry Start
end if

; assembler macros
include 'x86/fasm1macros.asm'

; basic macros
if VERSION_OS = 'L'
  include 'x86/linux64.asm'
else if VERSION_OS = 'W'
  include 'x86/windows64.asm'
else if VERSION_OS = 'X'
  include 'x86/apple64.asm'
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
include 'x86/HashMacros.asm'
include 'x86/PosIsDrawMacro.asm'
include 'x86/Pawn.asm'
include 'x86/SliderBlockers.asm'
include 'x86/UpdateStats.asm'


; data and bss section
if VERSION_OS = 'L'
  segment readable writeable
  include 'x86/MainData.asm'
  segment readable writeable
  include 'x86/MainBss.asm'
else if VERSION_OS = 'W'
  section '.data' data readable writeable
  include 'x86/MainData.asm'
  section '.bss' data readable writeable
  include 'x86/MainBss.asm'
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
  include 'x86/TablebaseCore.asm'
  include 'x86/Tablebase.asm'
end if
include 'x86/Endgame.asm'
include 'x86/Evaluate.asm'
include 'x86/Hash_Probe.asm'
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
include 'x86/Hash.asm'
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
else if VERSION_OS = 'X'
  include 'x86/OsMac.asm'
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

; for mac, data and bss cannot come before first code section (?)
if VERSION_OS = 'X'
  segment '__DATA' readable writeable
  section '__data' align 16
  include 'x86/MainData.asm'
  section '__bss' align 4096
  include 'x86/MainBss.asm'
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
