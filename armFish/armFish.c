/*
assemble and link with
$ aarch64-linux-gnu-as -c armFish.c -o armFish.o
$ aarch64-linux-gnu-ld -static -o armFish armFish.o

run with
$ qemu-aarch64 ./armFish
*/

.altmacro

.include "guts/def.c"
.include "guts/linux64.c"
.include "guts/macros.c"
.include "guts/AttackMacros.c"
.include "guts/SliderBlockers.c"
.include "guts/GenMacros.c"


.section .data
.include "guts/dataSection.c"


.section .bss
.include "guts/bssSection.c"


.text
.globl _start

_start:
.include "guts/main.c"

.include "guts/AttackersTo.c"
.include "guts/Endgame.c"
.include "guts/Think.c"
.include "guts/Gen_Legal.c"
.include "guts/Gen_Evasions.c"
.include "guts/Gen_NonEvasions.c"
.include "guts/Gen_QuietChecks.c"
.include "guts/Gen_Captures.c"
.include "guts/Gen_Quiets.c"

.include "guts/CheckTime.c"
.include "guts/RootMoves.c"
.include "guts/Move_GivesCheck.c"
.include "guts/Move_Undo.c"
.include "guts/Move_Do.c"
.include "guts/SetCheckInfo.c"
.include "guts/Search_Clear.c"
.include "guts/Perft.c"
.include "guts/Limits.c"
.include "guts/Thread.c"
.include "guts/ThreadPool.c"
.include "guts/Position.c"
.include "guts/Uci.c"
.include "guts/Math.c"
.include "guts/OsLinux.c"
.include "guts/PrintParse.c"
.include "guts/MainHash.c"

.include "guts/BitBoard_Init.c"
.include "guts/Gen_Init.c"
.include "guts/Position_Init.c"
.include "guts/BitTable_Init.c"
.include "guts/Search_Init.c"
.include "guts/Evaluate_Init.c"
.include "guts/Pawn_Init.c"
.include "guts/Endgame_Init.c"



