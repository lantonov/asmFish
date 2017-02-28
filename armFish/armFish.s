/*
assemble and link with
$ aarch64-linux-gnu-as -c armFish.s -o armFish.o
$ aarch64-linux-gnu-ld -static -o armFish armFish.o

run with
$ qemu-aarch64 ./armFish
*/


// hacky structs defs
IOBuffer.inputBuffer       = 0
IOBuffer.inputBufferSizeB  = 8+IOBuffer.inputBuffer
IOBuffer.tmp_i             = 8+IOBuffer.inputBufferSizeB
IOBuffer.tmp_j             = 4+IOBuffer.tmp_i
IOBuffer.tmpBuffer         = 4+IOBuffer.tmp_j
sizeof.IOBuffer            = 512+IOBuffer.tmpBuffer

Options.hash                    = 0
Options.threads                 = 8 + Options.hash
Options.largePages              = 8 + Options.threads
Options.changed                 = 1 + Options.largePages
Options.multiPV                 = 3 + Options.changed
Options.chess960	        = 4 + Options.multiPV
Options.minThinkTime	        = 4 + Options.chess960
Options.slowMover	        = 4 + Options.minThinkTime
Options.moveOverhead	        = 4 + Options.slowMover
Options.contempt	        = 4 + Options.moveOverhead
Options.ponder 	                = 4 + Options.contempt
Options.displayInfoMove         = 1 + Options.ponder
sizeof.Options                  = 3 + Options.displayInfoMove
sizeof.Options = sizeof.Options & -16

.data
ioBuffer: .zero sizeof.IOBuffer

sz_error_sys_mmap_VirtualAlloc: .ascii "sys_mmap in _VirtualAlloc failed"
   .byte 0
sz_error_sys_unmap_VirtualFree: .ascii "sys_unmap in _VirtualFree failed"
   .byte 0


sz_greeting: .ascii "greeting"
.byte 0
sz_error_unknown_command: .ascii "error: unknown command "
.byte 0
sz_quit: .ascii "quit"
.byte 0
sz_failed_x0: .ascii " x0: 0x"
.byte 0


.byte 0
.lcomm options, sizeof.Options
.lcomm buffer, 512
.lcomm Output, 4096

.text
.globl _start
_start:

        // init the engine
                 bl  Options_Init

        // write engine name
                adr  x19, Output
                adr  x0, sz_greeting
                 bl  PrintString
                mov  w0, 10
               strb  w0, [x19], 1
                 bl  _WriteOut_Output

        // set up threads and hash

        // command line could contain commands
	// this function also initializes InputBuffer
	// which contains the commands we should process first
                 bl  _ParseCommandLine

        // enter the main loop
                 bl  UciLoop

        // clean up input buffer
                adr  x2, ioBuffer
                ldr  x0, [x2, IOBuffer.inputBuffer]
                ldr  x1, [x2, IOBuffer.inputBufferSizeB]
                 bl  _VirtualFree

                mov  w0, 0
                 bl  _ExitProcess



/* ********************************
 Uci.asm
***********************************/

Options_Init:
                adr  x1, options
                mov  w0, -1
               strb  w0, [x1,Options.displayInfoMove]
                mov  w0, 0
                str  w0, [x1,Options.contempt]
                mov  w0, 1
                str  w0, [x1,Options.threads]
                mov  w0, 16
                str  w0, [x1,Options.hash]
                mov  w0, 0
	       strb  w0, [x1,Options.ponder]
                mov  w0, 1
		str  w0, [x1,Options.multiPV]
                mov  w0, 30
		str  w0, [x1,Options.moveOverhead]
                mov  w0, 20
		str  w0, [x1,Options.minThinkTime]
                mov  w0, 89
		str  w0, [x1,Options.slowMover]
                mov  w0, 0
	       strb  w0, [x1,Options.chess960]
                mov  w0, 0
	       strb  w0, [x1,Options.largePages]
                ret

Options_Destroy:
                ret


UciLoop:
                stp  x29, x30, [sp,-64]!

                  b  3f

1:
                 bl  _WriteOut_Output
3:
                 bl  GetLine

                 bl  SkipSpaces

                adr  x0, sz_quit
                 bl  CmpString
               cbnz  w0, 2f

                adr  x19, Output
                adr  x0, sz_error_unknown_command
                 bl  PrintString

                mov  x0, 64
                 bl  ParseToken
                mov  w0, 10
               strb  w0, [x19], 1
                  b  1b
2:

                ldp  x29, x30, [sp], 64
                ret




/* ********************************
 OsLinux.asm
***********************************/



_ExitProcess:
        // in: x0 exit code

                mov  x8, 94
                svc  0



_GetTime:
        // out: x0, x1 such that x0+x1/2^64 = time in ms

                stp  x29, x30, [sp,-48]!
                mov  x0, 1
                add  x1, sp, 16
                mov  x8, 113
                svc  0
                ldr  x2, [sp,16]
                ldr  x3, [sp,24]
                ldr  x4, =18446744073709
                mov  x5, 1000
                mul  x1, x3, x4
              umulh  x0, x3, x4
               madd  x0, x2, x5, x0
                ldp  x29, x30, [sp], 48
                ret

_Sleep:
        // in: x0 ms to sleep

                stp  x29, x30, [sp,-48]!
                mov  x1, 1000
               udiv  x2, x0, x1
               msub  x3, x2, x1, x0
                mul  x1, x1, x1
                mul  x3, x3, x1
                str  x2, [sp,16]
                str  x3, [sp,24]
                add  x0, sp, 16
                mov  x1, 0            
                mov  x8, 101
                svc  0
                ldp  x29, x30, [sp], 48
                ret


_VirtualAlloc:
        // in: x0 size

                stp  x29, x30, [sp,-48]!
                mov  x5, 0
                mov  x4, -1
                mov  x3, 0x22
                mov  x2, 0x03
                mov  x1, 100
                mov  x0, 0
                mov  x8, 222
                svc  0
                tst  x0, x0
                bmi  Failed_sys_mmap_VirtualAlloc
                ldp  x29, x30, [sp], 48
                ret


_VirtualFree:
        // in: x0 address
        //     x1 size

                stp  x29, x30, [sp,-48]!
                cbz  x0, 1f
                mov  x8, 215
                svc  0
                cmp  w0, 0
                bne  Failed_sys_unmap_VirtualFree
1:
                ldp  x29, x30, [sp], 48
                ret




_WriteOut_Output:
                adr  x0, Output
_WriteOut:
        // in: x0 address of string start
        // in: x19 address of string end

                stp  x29, x30, [sp,-48]! 
                sub  x2, x19, x0
                mov  x1, x0
                mov  x0, 1
                mov  x8, 64
                svc  0
                ldp  x29, x30, [sp], 48
                ret

_ReadStdIn:
        // in: x0 address of buffer
        //     x1 max bytes to read

                stp  x29, x30, [sp,-48]!
                mov  x2, x1
                mov  x1, x0
                mov  x0, 0
                mov  x8, 63
                svc  0
                ldp  x29, x30, [sp], 48
                ret

_ParseCommandLine:
                
                stp  x29, x30, [sp,-64]!
                stp  x22, x23, [sp,16]
                stp  x24, x25, [sp,32]
                stp  x27, x28, [sp,48]

                adr  x29, ioBuffer

                mov  x0, 4096
                str  x0, [x29,IOBuffer.inputBufferSizeB]
                 bl  _VirtualAlloc
                str  x0, [x29,IOBuffer.inputBuffer]

                ldp  x24, x25, [sp,32]
                ldp  x22, x23, [sp,16]
                ldp  x27, x28, [sp,48]
                ldp  x28, x30, [sp], 64
                ret


Failed_sys_mmap_VirtualAlloc:
                adr  x19, sz_error_sys_mmap_VirtualAlloc
                  b  Failed
Failed_sys_unmap_VirtualFree:
                adr  x19, sz_error_sys_unmap_VirtualFree
                  b  Failed


Failed:
        // x19 address of null terminated string
                
                mov  x21, x0
                mov  x0, x19
                adr  x19, Output
                 bl  PrintString
                adr  x0, sz_failed_x0
                 bl  PrintString
                mov  x0, x21
                 bl  PrintHex
                mov  w0, 10
               strb  w0, [x19], 1
                adr  x19, Output
                 bl  _ErrorBox
                mov  x0, 1
                 bl  _ExitProcess


_ErrorBox:
        // x19 address of null terminated string

                stp  x29, x30, [sp,-48]!

                mov  x0, x19
                 bl  StringLength

                mov  x2, x0
                mov  x1, x19
                mov  x0, 1
                mov  x8, 64
                svc  0

                ldp  x28, x30, [sp], 64
                ret                







/* ********************************
 PrintParse.asm
***********************************/


StringLength:
        // in: x0 address of null terminates string
        //     x0 length

                sub  x1, x0, 1
1:
               ldrb  w2, [x1,1]!
               cbnz  w2, 1b
                sub  x0, x1, x0
                ret



1:
               strb  w1, [x19], 1
PrintString:
        // in: x0 address of source string
        // io: x19 string

               ldrb  w1, [x0], 1
               cbnz  w1, 1b
                ret



CmpString:
                mov  x3, x20
1:
               ldrb  w1, [x0], 1
                cbz  w1, 2f
               ldrb  w2, [x3], 1
                cmp  w1, w2
                beq  1b

                mov  w0, 0
                ret
2:
                mov  x20, x3
                mov  w0, -1
                ret

1:
                add  x20, x20, 1
SkipSpaces:
               ldrb  w0, [x20]
                cmp  w0, 32
                beq  1b
                ret

1:
                add  x20, x20, 1
               strb  w1, [x19], 1
ParseToken:
               ldrb  w1, [x20]
               subs  x0, x0, 1
                blo  2f
                cmp  w1, 47
                blo  2f
                cmp  w1, 58
                blo  1b
                cmp  w1, 56
                blo  2f
                cmp  w1, 91
                blo  1b
                cmp  w1, 92
                beq  1b
                cmp  w1, 97
                blo  2f
                cmp  w1, 128
                blo  1b
2:
                ret





PrintSignedInteger:
        // in: x0 signed integer
        // io: x19 string

                tst  x0, x0
                mov  w1, 45
               strb  w1, [x19]
              csinc  x19, x19, x19, pl
              csneg  x0, x0, x0, pl

PrintUnsignedInteger:
        // in: x0 unsigned integer
        // io: x19 string

                sub  sp, sp, 64
                mov  x3, 0
                mov  x2, 10
1:
               udiv  x1, x0, x2
               msub  x0, x1, x2, x0
               strb  w0, [sp,x3]
                add  x3, x3, 1
                mov  x0, x1
               cbnz  x1, 1b
2:
               subs  x3, x3, 1
               ldrb  w0, [sp,x3]
                add  w0, w0, 48
               strb  w0, [x19], 1
                bhi  2b

                add  sp, sp, 64
                ret

ParseInteger:
        // io: x20 string
        // out: x0

               ldrb  w1, [x20]
                mov  x2, 0
                mov  x0, 0
                cmp  w1, 45
                beq  1f
                cmp  w1, 43
                beq  2f
                  b  3f
1:              mvn  x2, x2
2:              add  x20, x20, 1
3:
               ldrb  w1, [x20]
               subs  w1, w1, 48
                blo  4f
                cmp  w1, 9
                bhi  4f
                add  x20, x20, 1
                add  x0, x0, x0, lsl 2
                add  x0, x1, x0, lsl 1
                  b  3b
4:
                eor  x0, x0, x2
                sub  x0, x0, x2
                ret

PrintHex:
                mov  w4, 16                
1:              
                ror  x0, x0, 60
                and  x1, x0, 15
                cmp  w1, 10
                add  w2, w1, 48
                add  w3, w1, 65-10
               csel  w1, w2, w3, lo
               strb  w1, [x19], 1                
                sub  w4, w4, 1
               cbnz  w4, 1b
                ret





GetLine:
        // out: w0 = 0 if success, =-1 if failed
        //      w1 length of string
        //      x20 address of string

                stp  x29, x30, [sp,-64]!
                stp  x22, x23, [sp,16]
                stp  x24, x25, [sp,32]
                stp  x27, x28, [sp,48]

                adr  x29, ioBuffer

                ldr  w22, [x29,IOBuffer.tmp_i]
                ldr  w23, [x29,IOBuffer.tmp_j]
                ldr  x24, [x29,IOBuffer.inputBufferSizeB]
                ldr  x25, [x29,IOBuffer.inputBuffer]
                mov  x28, 0
1:
                cmp  x28, x24
                bhs  7f
2:
                cmp  x22, x23
                bhs  5f
3:
                add  x0, x29, IOBuffer.tmpBuffer
               ldrb  w0, [x0,x22]
                add  x22, x22, 1
               strb  w0, [x25,x28]
                add  x28, x28, 1
                cmp  w0, 32
                bhs  1b

                mov  w0, 0
4:
                str  w22, [x29,IOBuffer.tmp_i]
                str  w23, [x29,IOBuffer.tmp_j]
                str  x24, [x29,IOBuffer.inputBufferSizeB]
                str  x25, [x29,IOBuffer.inputBuffer]

                mov  x20, x25
                mov  x1, x28

                ldp  x24, x25, [sp,32]
                ldp  x22, x23, [sp,16]
                ldp  x27, x28, [sp,48]
                ldp  x28, x30, [sp], 64
                ret
5:
                mov  x22, 0
                add  x0, x29, IOBuffer.tmpBuffer
                mov  x1, 512
                 bl  _ReadStdIn
                mov  x23, x0
                cmp  x0, 1
                bge  3b
6:
                mov  w0, -1
                mov  x23, 0
                  b  4b
7:
        // get new buffer
                add  x0, x24, 4096
                 bl  _VirtualAlloc
                mov  x23, x0
                mov  x19, x0
        // copy data
                mov  x20, x25
                mov  x0, x24
                 bl  RepMovsb
        // free old buffer
                mov  x0, x25
                mov  x1, x24
                 bl  _VirtualFree
        // set new data
                mov  x25, x23
                add  x24, x24, 4096
                  b  2b


1:
                sub  x0, x0, 1
               ldrb  w1, [x20], 1
               strb  w1, [x19], 1
RepMovsb:
               cbnz  x0, 1b
                ret




