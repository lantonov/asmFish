Options_Init:
        lea  x1, options
        mov  w0, -1
       strb  w0, [x1, Options.displayInfoMove]
        mov  w0, 0
        str  w0, [x1, Options.contempt]
        mov  w0, 1
        str  w0, [x1, Options.threads]
        mov  w0, 16
        str  w0, [x1, Options.hash]
        mov  w0, 0
       strb  w0, [x1, Options.ponder]
        mov  w0, 1
	str  w0, [x1, Options.multiPV]
        mov  w0, 30
	str  w0, [x1, Options.moveOverhead]
        mov  w0, 20
	str  w0, [x1, Options.minThinkTime]
        mov  w0, 89
	str  w0, [x1, Options.slowMover]
        mov  w0, 0
       strb  w0, [x1, Options.chess960]
        mov  w0, 0
       strb  w0, [x1, Options.largePages]
        ret

Options_Destroy:
        ret


UciLoop:
/*
UciLoop.th1    = 0
UciLoop.th2    = sizeof.Thread + UciLoop.th1
UciLoop.states = sizeof.Thread + UciLoop.th2
UciLoop.limits = 2*sizeof.State + UciLoop.states
UciLoop.time   = sizeof.Limits + UciLoop.limits
UciLoop.nodes  = 8 + UciLoop.time
UciLoop.localsize = 8 + UciLoop.nodes
*/

UciLoop.localsize = 64

UciLoop.localsize = (UciLoop.localsize + 15) & (-16)

        stp  x29, x30, [sp,-16]!
        sub  sp, sp, UciLoop.localsize

          b  3f

1:
         bl  Os_WriteOut_Output
3:
         bl  GetLine


         bl  SkipSpaces

        lea  x1, sz_quit
         bl  CmpString
       cbnz  w0, 2f

        lea  x15, Output
        lea  x1, sz_error_unknown_command
         bl  PrintString

        mov  x1, 64
         bl  ParseToken
        PrintNewLine
          b  1b
2:

        add  sp, sp, UciLoop.localsize
        ldp  x29, x30, [sp],16
        ret
