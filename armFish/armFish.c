/*
assemble and link with
$ aarch64-linux-gnu-as -c armFish.c -o armFish.o
$ aarch64-linux-gnu-ld -static -o armFish armFish.o

run with
$ qemu-aarch64 ./armFish
*/

.altmacro

.include "guts/def.c"
.include "guts/macros.c"
.include "guts/AttackMacros.c"


.section .data
.include "guts/dataSection.c"


.section .bss
.include "guts/bssSection.c"


.text
.globl _start
_start:

// initialize the engine
         bl  Gen_Init
         bl  Options_Init

// write engine name
        Lea  x15, Output
        Lea  x0, sz_greeting
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
        Lea  x2, ioBuffer
        ldr  x0, [x2, IOBuffer.inputBuffer]
        ldr  x1, [x2, IOBuffer.inputBufferSizeB]
         bl  Os_VirtualFree

        mov  w0, 0
         bl  Os_ExitProcess


.include "guts/Uci.c"
.include "guts/OsLinux.c"
.include "guts/PrintParse.c"
.include "guts/Gen_Init.c"



