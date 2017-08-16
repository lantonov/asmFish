VERSION_PRE = 'asmFish'
VERSION_OS = 'L'
VERSION_POST = 'popcnt'

CPU_HAS_POPCNT = 1
CPU_HAS_BMI1 = 0
CPU_HAS_BMI2 = 0
CPU_HAS_AVX1 = 0
CPU_HAS_AVX2 = 0

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
include 'avx.inc'

format ELF64 executable 3
entry Start

; assembler macros
include 'x86/fasm1macros.asm'

; basic macros
include 'x86/linux64.asm'
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
segment readable writeable

include 'x86/MainData.asm'
if USE_SYZYGY
  include 'x86/TablebaseData.asm'
end if

; reserve section
segment readable writeable

include 'x86/MainBss.asm'
if USE_SYZYGY
  include 'x86/TablebaseBss.asm'
end if

; code section
segment readable executable

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
include 'x86/OsLinux.asm'
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

