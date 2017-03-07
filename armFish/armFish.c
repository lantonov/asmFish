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


.section .data
.include "guts/dataSection.c"


.section .bss
.include "guts/bssSection.c"


.text
.globl _start
_start:

         bl  Os_SetStdHandles
         bl  Os_InitializeTimer
         bl  Os_CheckCPU

// initialize the engine
         bl  Options_Init
         bl  Gen_Init
         bl  BitBoard_Init
         bl  Position_Init
         bl  BitTable_Init


// check some computations
lea x16, Scores_Pieces
mov x0, 200
ldr x0, [x16, x0, lsl 3]
mov x1, 300
ldr x1, [x16, x1, lsl 3]
mov x2, 400
ldr x2, [x16, x2, lsl 3]
Display "test: %x0 %x1 %x2\n"
fmov d16, 2.0e0
fmov d17, 2.5e0
fmov d0, d16
fmov d1, d17
bl Math_pow_d_dd
Display "test: pow(%d16, %d17) = %d0\n"
fneg d17, d17
fmov d0, d16
fmov d1, d17
bl Math_pow_d_dd
Display "test: pow(%d16, %d17) = %d0\n"
fmov d16, 3.0e1
fmov d0, d16
bl Math_log_d_d
Display "test: log(%d16) = %d0\n"
fmov d16, 3.0e0
fmov d0, d16
bl Math_exp_d_d
Display "test: exp(%d16) = %d0\n"
fmov d16, 3.5e0
mov x17, -2
fmov d0, d16
mov w0, w17
bl Math_scalbn_d_di
Display "test: scalbn(%d16, %i17) = %d0\n"


// write engine name
        lea  x15, Output
        lea  x0, sz_greeting
         bl  PrintString
        PrintNewLine
         bl  Os_WriteOut_Output

// set up threads and hash

// command line could contain commands
// this function also initializes InputBuffer
// which contains the commands we should process first
         bl  Os_ParseCommandLine

// enter the main loop
         bl  UciLoop

// clean up input buffer
        lea  x2, ioBuffer
        ldr  x0, [x2, IOBuffer.inputBuffer]
        ldr  x1, [x2, IOBuffer.inputBufferSizeB]
         bl  Os_VirtualFree

        mov  w0, 0
         bl  Os_ExitProcess


.include "guts/Uci.c"
.include "guts/Math.c"
.include "guts/OsLinux.c"
.include "guts/PrintParse.c"
.include "guts/BitBoard_Init.c"
.include "guts/Gen_Init.c"
.include "guts/Position_Init.c"
.include "guts/BitTable_Init.c"



