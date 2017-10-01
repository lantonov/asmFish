;if VERBOSE > 0
;  align 16
;  VerboseOutput         rq 1024
;  VerboseTime           rq 2
;end if


;if DEBUG > 0
;  align 16
;  DebugBalance          rq 1
;  DebugOutput           rq 1024
;end if




             calign    16
constd:
._0p03	 dq 0.03
._0p505	 dq 0.505
._1p0	 dq 1.0
._628p0	 dq 628.0

if CPU_HAS_POPCNT = 0
 Mask55    dq 0x5555555555555555
 Mask33    dq 0x3333333333333333
 Mask0F    dq 0x0F0F0F0F0F0F0F0F
 Mask01    dq 0x0101010101010101
 Mask11    dq 0x1111111111111111
end if


szUciResponse:
    db 'id name '
szGreeting:
    db VERSION_PRE
    db VERSION_OS
    db '_'
    BuildTimeData
    db '_'
    db VERSION_POST
    NewLineData
szGreetingEnd:
    db 'id author TypingALot'
    NewLineData
    db 'option name Hash type spin default 16 min 1 max '
    IntegerStringData (1 shl MAX_HASH_LOG2MB)
    NewLineData
    db 'option name LargePages type check default false'
    NewLineData
    db 'option name Threads type spin default 1 min 1 max '
    IntegerStringData MAX_THREADS
    NewLineData
    db 'option name NodeAffinity type string default all'
    NewLineData
    db 'option name Priority type combo default none var none var normal var low var idle'
    NewLineData

	db 'option name LogFile type string default <empty>'
	NewLineData
    db 'option name TTFile type string default <empty>'
    NewLineData
    db 'option name TTSave type button'
    NewLineData
    db 'option name TTLoad type button'
    NewLineData

    db 'option name Clear Hash type button'
    NewLineData

    db 'option name Ponder type check default false'
    NewLineData
    db 'option name UCI_Chess960 type check default false'
    NewLineData

    db 'option name MultiPV type spin default 1 min 1 max 224'
    NewLineData
    db 'option name Contempt type spin default 0 min -100 max 100'
    NewLineData
    db 'option name MoveOverhead type spin default 50 min 0 max 5000'
    NewLineData

if USE_SYZYGY
    db 'option name SyzygyProbeDepth type spin default 1 min 1 max 100'
    NewLineData
    db 'option name SyzygyProbeLimit type spin default 6 min 0 max 6'
    NewLineData
    db 'option name Syzygy50MoveRule type check default true'
    NewLineData
    db 'option name SyzygyPath type string default <empty>'
    NewLineData
end if

if USE_WEAKNESS
    db 'option name UCI_LimitStrength type check default false'
    NewLineData
    db 'option name UCI_Elo type spin default 1000 min 0 max 3300'
    NewLineData
end if

if USE_VARIETY
    db 'option name Variety type spin default 0 min 0 max 40'
    NewLineData
end if

if USE_BOOK
    db 'option name OwnBook type check default false'
    NewLineData
    db 'option name BookFile type string default <empty>'
    NewLineData
    db 'option name BestBookMove type check default false'
    NewLineData
    db 'option name BookDepth type spin default 100 min -10 max 100'
    NewLineData
end if
	db 'uciok'
sz_NewLine:
	NewLineData
sz_NewLineEnd:
szUciResponseEnd:

szCPUError         db 'Error: processor does not support',0
   .POPCNT         db ' POPCNT',0
   .AVX1           db ' AVX1',0
   .AVX2           db ' AVX2',0
   .BMI1           db ' BMI1',0
   .BMI2           db ' BMI2',0
szStartFEN         db 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',0
PieceToChar        db '.?PNBRQK??pnbrqk'


sz_format_currmove:
        db 'info depth %u0 currmove %m1 currmovenumber %u2%n', 0
sz_format_thread:
        db 'info string node %i0 has threads', 0
sz_format_perft1:
        db '%m0 : %U1%n', 0
sz_format_bench1:
        db '*** bench hash %u0 threads %u1 depth %u2 ***%n', 0
sz_format_bench2:
        db '%U0: %a8nodes: %U1 %a32%U2 knps%n', 0
sz_format_perft2:
sz_format_bench3:
        db '===========================%n'
        db 'Total time (ms) : %U0%n'
        db 'Nodes searched  : %U1%n'
        db 'Nodes/second    : %U2%n', 0

sz_info_node_threads db 'info string node %i0 has threads',0
sz_tt_update         db 'info string finished %U0 MB of %U1 MB%n',0
sz_path_set          db 'info string path set to ', 0
sz_hash_cleared      db 'info string hash cleared', 0
sz_error_badttfile   db 'error: could not read ttfile ',0
sz_error_badttsize   db 'error: ttfile has funny size 0x%X0%n',0
sz_error_middlett    db 'error: could not process whole file',0

sz_error_priority  db 'error: unknown priority ',0
sz_error_depth     db 'error: bad depth ',0
sz_error_fen       db 'error: illegal fen',0
sz_error_moves     db 'error: illegal move ',0
sz_error_token     db 'error: unexpected token ',0
sz_error_unknown   db 'error: unknown command ',0
sz_error_think	   db 'error: setoption called while thinking',0
sz_error_value	   db 'error: setoption has no value',0
sz_error_name	   db 'error: setoption has no name',0
sz_error_option    db 'error: unknown option ',0
sz_error_hashsave  db 'error: could not save hash file ',0
sz_error_affinity1 db 'error: parsing affinity failed after "',0
sz_error_affinity2 db '"; proceeding as "all"',0
sz_empty           db '<empty>',0

sz_go           db 'go',0
sz_all          db 'all',0
sz_low          db 'low',0
sz_uci          db 'uci',0
sz_fen          db 'fen',0
sz_wait         db 'wait',0
sz_quit         db 'quit',0
sz_none         db 'none',0
sz_winc         db 'winc',0
sz_binc         db 'binc',0
sz_mate         db 'mate',0
sz_name         db 'name',0
sz_idle         db 'idle',0
sz_hash         db 'hash',0
sz_stop         db 'stop',0
sz_value        db 'value',0
sz_depth        db 'depth',0
sz_nodes        db 'nodes',0
sz_wtime        db 'wtime',0
sz_btime        db 'btime',0
sz_moves        db 'moves',0
sz_perft        db 'perft',0
sz_bench        db 'bench',0
sz_ttfile       db 'ttfile',0
sz_ttsave       db 'ttsave',0
sz_ttload       db 'ttload',0
sz_ponder       db 'ponder',0
sz_normal       db 'normal',0
sz_threads      db 'threads',0
sz_isready      db 'isready',0
sz_multipv      db 'multipv',0
sz_logfile      db "logfile", 0
sz_startpos     db 'startpos',0
sz_infinite     db 'infinite',0
sz_movetime     db 'movetime',0
sz_contempt     db 'contempt',0
sz_weakness     db 'weakness',0
sz_priority     db 'priority',0
sz_position     db 'position',0
sz_movestogo        db 'movestogo',0
sz_setoption        db 'setoption',0
sz_ponderhit        db 'ponderhit',0
sz_ucinewgame       db 'ucinewgame',0
sz_clear_hash       db 'clear hash',0
sz_largepages       db 'largepages',0
sz_searchmoves      db 'searchmoves',0
sz_nodeaffinity     db 'nodeaffinity',0
sz_moveoverhead     db 'moveoverhead',0
sz_uci_chess960     db 'uci_chess960',0

if USE_SYZYGY
sz_syzygypath       db 'syzygypath',0
sz_syzygyprobedepth db 'syzygyprobedepth',0
sz_syzygy50moverule db 'syzygy50moverule',0
sz_syzygyprobelimit db 'syzygyprobelimit',0
end if

if USE_WEAKNESS
sz_uci_limitstrength    db 'uci_limitstrength',0
sz_uci_elo              db 'uci_elo',0
end if

if USE_VARIETY
sz_variety      db 'variety',0
end if

if USE_BOOK
sz_ownbook      db 'ownbook',0
sz_bookfile     db 'bookfile',0
sz_bookdepth    db 'bookdepth',0
sz_bestbookmove db 'bestbookmove',0
end if

BenchFens: ;fens must be separated by one or more space char
    db "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
    db "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 10 "
    db "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 11 "
    db "4rrk1/pp1n3p/3q2pQ/2p1pb2/2PP4/2P3N1/P2B2PP/4RRK1 b - - 7 19 "
    db "rq3rk1/ppp2ppp/1bnpb3/3N2B1/3NP3/7P/PPPQ1PP1/2KR3R w - - 7 14 moves d4e6 "
    db "r1bq1r1k/1pp1n1pp/1p1p4/4p2Q/4Pp2/1BNP4/PPP2PPP/3R1RK1 w - - 2 14 moves g2g4 "
    db "r3r1k1/2p2ppp/p1p1bn2/8/1q2P3/2NPQN2/PPP3PP/R4RK1 b - - 2 15 "
    db "r1bbk1nr/pp3p1p/2n5/1N4p1/2Np1B2/8/PPP2PPP/2KR1B1R w kq - 0 13 "
    db "r1bq1rk1/ppp1nppp/4n3/3p3Q/3P4/1BP1B3/PP1N2PP/R4RK1 w - - 1 16 "
    db "4r1k1/r1q2ppp/ppp2n2/4P3/5Rb1/1N1BQ3/PPP3PP/R5K1 w - - 1 17 "
    db "2rqkb1r/ppp2p2/2npb1p1/1N1Nn2p/2P1PP2/8/PP2B1PP/R1BQK2R b KQ - 0 11 "
    db "r1bq1r1k/b1p1npp1/p2p3p/1p6/3PP3/1B2NN2/PP3PPP/R2Q1RK1 w - - 1 16 "
    db "3r1rk1/p5pp/bpp1pp2/8/q1PP1P2/b3P3/P2NQRPP/1R2B1K1 b - - 6 22 "
    db "r1q2rk1/2p1bppp/2Pp4/p6b/Q1PNp3/4B3/PP1R1PPP/2K4R w - - 2 18 "
    db "4k2r/1pb2ppp/1p2p3/1R1p4/3P4/2r1PN2/P4PPP/1R4K1 b - - 3 22 "
    db "3q2k1/pb3p1p/4pbp1/2r5/PpN2N2/1P2P2P/5PP1/Q2R2K1 b - - 4 26 "
    db "6k1/6p1/6Pp/ppp5/3pn2P/1P3K2/1PP2P2/3N4 b - - 0 1 "
    db "3b4/5kp1/1p1p1p1p/pP1PpP1P/P1P1P3/3KN3/8/8 w - - 0 1 "
    db "2K5/p7/7P/5pR1/8/5k2/r7/8 w - - 0 1 moves g5g6 f3e3 g6g5 e3f3 "
    db "8/6pk/1p6/8/PP3p1p/5P2/4KP1q/3Q4 w - - 0 1 "
    db "7k/3p2pp/4q3/8/4Q3/5Kp1/P6b/8 w - - 0 1 "
    db "8/2p5/8/2kPKp1p/2p4P/2P5/3P4/8 w - - 0 1 "
    db "8/1p3pp1/7p/5P1P/2k3P1/8/2K2P2/8 w - - 0 1 "
    db "8/pp2r1k1/2p1p3/3pP2p/1P1P1P1P/P5KR/8/8 w - - 0 1 "
    db "8/3p4/p1bk3p/Pp6/1Kp1PpPp/2P2P1P/2P5/5B2 b - - 0 1 "
    db "5k2/7R/4P2p/5K2/p1r2P1p/8/8/8 b - - 0 1 "
    db "6k1/6p1/P6p/r1N5/5p2/7P/1b3PP1/4R1K1 w - - 0 1 "
    db "1r3k2/4q3/2Pp3b/3Bp3/2Q2p2/1p1P2P1/1P2KP2/3N4 w - - 0 1 "
    db "6k1/4pp1p/3p2p1/P1pPb3/R7/1r2P1PP/3B1P2/6K1 w - - 0 1 "
    db "8/3p3B/5p2/5P2/p7/PP5b/k7/6K1 w - - 0 1 "
; 5-man positions
    db "8/8/8/8/5kp1/P7/8/1K1N4 w - - 0 1 "     ; Kc2 - mate
    db "8/8/8/5N2/8/p7/8/2NK3k w - - 0 1 "      ; Na2 - mate
    db "8/3k4/8/8/8/4B3/4KB2/2B5 w - - 0 1 "    ; draw
; 6-man positions
    db "8/8/1P6/5pr1/8/4R3/7k/2K5 w - - 0 1 "   ; Re5 - mate
    db "8/2p4P/8/kr6/6R1/8/8/1K6 w - - 0 1 "    ; Ka2 - mate
    db "8/8/3P3k/8/1p6/8/1P6/1K3n2 b - - 0 1 "  ; Nd2 - draw
; 7-man positions
    db "8/R7/2q5/8/6k1/8/1P5p/K6R w - - 0 124 "
; Mate and stalemate positions
    db "6k1/3b3r/1p1p4/p1n2p2/1PPNpP1q/P3Q1p1/1R1RB1P1/5K2 b - - 0 1 "
    db "r2r1n2/pp2bk2/2p1p2p/3q4/3PN1QP/2P3R1/P4PP1/5RK1 w - - 0 1 "
    db "8/8/8/8/8/6k1/6p1/6K1 w - - 0 1 "
    db "7k/7P/6K1/8/3B4/8/8/8 b - - 0 1 "
Bench960Fens:
    db "bbqnnrkr/pppppppp/8/8/8/8/PPPPPPPP/BBQNNRKR w KQkq - 0 1 moves g2g3 d7d5 d2d4 c8h3 c1g5 e8d6 g5e7 f7f6"
BenchFensEnd: db 0

if VERSION_OS = 'W'

   sz_kernel32                          db 'kernel32',0
   sz_Advapi32dll                       db 'Advapi32.dll',0
   sz_VirtualAllocExNuma                db 'VirtualAllocExNuma',0
   sz_SetThreadGroupAffinity            db 'SetThreadGroupAffinity',0
   sz_GetLogicalProcessorInformationEx  db 'GetLogicalProcessorInformationEx',0
  calign 8
   Frequency   dq ?
   Period      dq ?
   hProcess    dq ?
   hStdOut     dq ?
   hStdIn      dq ?
   hStdError   dq ?
   hAdvapi32   dq ?
   __imp_MessageBoxA                        dq ?
   __imp_VirtualAllocExNuma                 dq ?
   __imp_SetThreadGroupAffinity             dq ?
   __imp_GetLogicalProcessorInformationEx   dq ?

else if VERSION_OS = 'L'

  align 8
 rspEntry dq ?
 __imp_clock_gettime dq ?

else if VERSION_OS = 'X'

  align 8
 rspEntry dq ?

end if

align 8
 LargePageMinSize dq ?
 WarnMask         dd ?
                  dd ?
if DEBUG = 1
 DebugBalance dq 0
end if



if USE_SYZYGY

             calign   64

L_338:							; byte
	db 2FH, 00H					; 0000 _ /.

L_339:							; byte
	db 43H, 72H, 65H, 61H, 74H, 65H, 46H, 69H	; 0002 _ CreateFi
	db 6CH, 65H, 4DH, 61H, 70H, 70H, 69H, 6EH	; 000A _ leMappin
	db 67H, 28H, 29H, 20H, 66H, 61H, 69H, 6CH	; 0012 _ g() fail
	db 65H, 64H, 2EH, 00H				; 001A _ ed..

L_340:							; byte
	db 4DH, 61H, 70H, 56H, 69H, 65H, 77H, 4FH	; 001E _ MapViewO
	db 66H, 46H, 69H, 6CH, 65H, 28H, 29H, 20H	; 0026 _ fFile() 
	db 66H, 61H, 69H, 6CH, 65H, 64H, 2CH, 20H	; 002E _ failed, 
	db 6EH, 61H, 6DH, 65H, 20H, 3DH, 20H, 25H	; 0036 _ name = %
	db 73H, 25H, 73H, 2CH, 20H, 65H, 72H, 72H	; 003E _ s%s, err
	db 6FH, 72H, 20H, 3DH, 20H, 25H, 6CH, 75H	; 0046 _ or = %lu
	db 2EH, 0AH, 00H				; 004E _ ...

L_341:							; byte
	db 48H, 53H, 48H, 4DH, 41H, 58H, 20H, 74H	; 0051 _ HSHMAX t
	db 6FH, 6FH, 20H, 6CH, 6FH, 77H, 21H, 00H	; 0059 _ oo low!.

L_342:							; byte
	db 2EH, 72H, 74H, 62H, 77H, 00H 		; 0061 _ .rtbw.

L_343:							; byte
	db 54H, 42H, 4DH, 41H, 58H, 5FH, 50H, 49H	; 0067 _ TBMAX_PI
	db 45H, 43H, 45H, 20H, 6CH, 69H, 6DH, 69H	; 006F _ ECE limi
	db 74H, 20H, 74H, 6FH, 6FH, 20H, 6CH, 6FH	; 0077 _ t too lo
	db 77H, 21H, 00H				; 007F _ w!.

L_344:							; byte
	db 54H, 42H, 4DH, 41H, 58H, 5FH, 50H, 41H	; 0082 _ TBMAX_PA
	db 57H, 4EH, 20H, 6CH, 69H, 6DH, 69H, 74H	; 008A _ WN limit
	db 20H, 74H, 6FH, 6FH, 20H, 6CH, 6FH, 77H	; 0092 _  too low
	db 21H, 00H					; 009A _ !.

sz_emptyfile:
	db 3CH, 65H, 6DH, 70H, 74H, 79H, 3EH, 00H	; 009C _ <empty>.

L_346:							; byte
	db 69H, 6EH, 66H, 6FH, 20H, 73H, 74H, 72H	; 00A4 _ info str
	db 69H, 6EH, 67H, 20H, 46H, 6FH, 75H, 6EH	; 00AC _ ing Foun
	db 64H, 20H, 25H, 64H, 20H, 74H, 61H, 62H	; 00B4 _ d %d tab
	db 6CH, 65H, 62H, 61H, 73H, 65H, 73H, 2EH	; 00BC _ lebases.
	db 0AH, 00H					; 00C4 _ ..

L_347:							; byte
	db 43H, 6FH, 75H, 6CH, 64H, 20H, 6EH, 6FH	; 00C6 _ Could no
	db 74H, 20H, 66H, 69H, 6EH, 64H, 20H, 25H	; 00CE _ t find %
	db 73H, 2EH, 72H, 74H, 62H, 77H, 00H		; 00D6 _ s.rtbw.

L_348:							; byte
	db 43H, 6FH, 72H, 72H, 75H, 70H, 74H, 65H	; 00DD _ Corrupte
	db 64H, 20H, 74H, 61H, 62H, 6CH, 65H, 2EH	; 00E5 _ d table.
	db 00H						; 00ED _ .

L_349:							; byte
	db 2EH, 72H, 74H, 62H, 7AH, 00H, 00H, 00H	; 00EE _ .rtbz...
	db 00H, 00H					; 00F6 _ ..

_ZZL18calc_factors_piecePiiiPhhE6pivfac:		; byte
	db 64H, 7AH, 00H, 00H, 98H, 6DH, 00H, 00H	; 00F8 _ dz...m..
	db 0CEH, 01H, 00H, 00H, 00H, 00H, 00H, 00H	; 0100 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0108 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0110 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0118 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0120 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0128 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0130 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0138 _ ........

_ZL6KK_idx:						; byte
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 00H, 00H ; 0140 _ ........
	db 01H, 00H, 02H, 00H, 03H, 00H, 04H, 00H	; 0148 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 05H, 00H ; 0150 _ ........
	db 06H, 00H, 07H, 00H, 08H, 00H, 09H, 00H	; 0158 _ ........
	db 0AH, 00H, 0BH, 00H, 0CH, 00H, 0DH, 00H	; 0160 _ ........
	db 0EH, 00H, 0FH, 00H, 10H, 00H, 11H, 00H	; 0168 _ ........
	db 12H, 00H, 13H, 00H, 14H, 00H, 15H, 00H	; 0170 _ ........
	db 16H, 00H, 17H, 00H, 18H, 00H, 19H, 00H	; 0178 _ ........
	db 1AH, 00H, 1BH, 00H, 1CH, 00H, 1DH, 00H	; 0180 _ ........
	db 1EH, 00H, 1FH, 00H, 20H, 00H, 21H, 00H	; 0188 _ .... .!.
	db 22H, 00H, 23H, 00H, 24H, 00H, 25H, 00H	; 0190 _ ".#.$.%.
	db 26H, 00H, 27H, 00H, 28H, 00H, 29H, 00H	; 0198 _ &.'.(.).
	db 2AH, 00H, 2BH, 00H, 2CH, 00H, 2DH, 00H	; 01A0 _ *.+.,.-.
	db 2EH, 00H, 2FH, 00H, 30H, 00H, 31H, 00H	; 01A8 _ ../.0.1.
	db 32H, 00H, 33H, 00H, 34H, 00H, 35H, 00H	; 01B0 _ 2.3.4.5.
	db 36H, 00H, 37H, 00H, 38H, 00H, 39H, 00H	; 01B8 _ 6.7.8.9.
	db 3AH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 01C0 _ :.......
	db 3BH, 00H, 3CH, 00H, 3DH, 00H, 3EH, 00H	; 01C8 _ ;.<.=.>.
	db 3FH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 01D0 _ ?.......
	db 40H, 00H, 41H, 00H, 42H, 00H, 43H, 00H	; 01D8 _ @.A.B.C.
	db 44H, 00H, 45H, 00H, 46H, 00H, 47H, 00H	; 01E0 _ D.E.F.G.
	db 48H, 00H, 49H, 00H, 4AH, 00H, 4BH, 00H	; 01E8 _ H.I.J.K.
	db 4CH, 00H, 4DH, 00H, 4EH, 00H, 4FH, 00H	; 01F0 _ L.M.N.O.
	db 50H, 00H, 51H, 00H, 52H, 00H, 53H, 00H	; 01F8 _ P.Q.R.S.
	db 54H, 00H, 55H, 00H, 56H, 00H, 57H, 00H	; 0200 _ T.U.V.W.
	db 58H, 00H, 59H, 00H, 5AH, 00H, 5BH, 00H	; 0208 _ X.Y.Z.[.
	db 5CH, 00H, 5DH, 00H, 5EH, 00H, 5FH, 00H	; 0210 _ \.].^._.
	db 60H, 00H, 61H, 00H, 62H, 00H, 63H, 00H	; 0218 _ `.a.b.c.
	db 64H, 00H, 65H, 00H, 66H, 00H, 67H, 00H	; 0220 _ d.e.f.g.
	db 68H, 00H, 69H, 00H, 6AH, 00H, 6BH, 00H	; 0228 _ h.i.j.k.
	db 6CH, 00H, 6DH, 00H, 6EH, 00H, 6FH, 00H	; 0230 _ l.m.n.o.
	db 70H, 00H, 71H, 00H, 72H, 00H, 73H, 00H	; 0238 _ p.q.r.s.
	db 74H, 00H, 75H, 00H, 0FFH, 0FFH, 0FFH, 0FFH	; 0240 _ t.u.....
	db 0FFH, 0FFH, 76H, 00H, 77H, 00H, 78H, 00H	; 0248 _ ..v.w.x.
	db 79H, 00H, 7AH, 00H, 0FFH, 0FFH, 0FFH, 0FFH	; 0250 _ y.z.....
	db 0FFH, 0FFH, 7BH, 00H, 7CH, 00H, 7DH, 00H	; 0258 _ ..{.|.}.
	db 7EH, 00H, 7FH, 00H, 80H, 00H, 81H, 00H	; 0260 _ ~.......
	db 82H, 00H, 83H, 00H, 84H, 00H, 85H, 00H	; 0268 _ ........
	db 86H, 00H, 87H, 00H, 88H, 00H, 89H, 00H	; 0270 _ ........
	db 8AH, 00H, 8BH, 00H, 8CH, 00H, 8DH, 00H	; 0278 _ ........
	db 8EH, 00H, 8FH, 00H, 90H, 00H, 91H, 00H	; 0280 _ ........
	db 92H, 00H, 93H, 00H, 94H, 00H, 95H, 00H	; 0288 _ ........
	db 96H, 00H, 97H, 00H, 98H, 00H, 99H, 00H	; 0290 _ ........
	db 9AH, 00H, 9BH, 00H, 9CH, 00H, 9DH, 00H	; 0298 _ ........
	db 9EH, 00H, 9FH, 00H, 0A0H, 00H, 0A1H, 00H	; 02A0 _ ........
	db 0A2H, 00H, 0A3H, 00H, 0A4H, 00H, 0A5H, 00H	; 02A8 _ ........
	db 0A6H, 00H, 0A7H, 00H, 0A8H, 00H, 0A9H, 00H	; 02B0 _ ........
	db 0AAH, 00H, 0ABH, 00H, 0ACH, 00H, 0ADH, 00H	; 02B8 _ ........
	db 0AEH, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 02C0 _ ........
	db 0AFH, 00H, 0B0H, 00H, 0B1H, 00H, 0B2H, 00H	; 02C8 _ ........
	db 0B3H, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 02D0 _ ........
	db 0B4H, 00H, 0B5H, 00H, 0B6H, 00H, 0B7H, 00H	; 02D8 _ ........
	db 0B8H, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 02E0 _ ........
	db 0B9H, 00H, 0BAH, 00H, 0BBH, 00H, 0BCH, 00H	; 02E8 _ ........
	db 0BDH, 00H, 0BEH, 00H, 0BFH, 00H, 0C0H, 00H	; 02F0 _ ........
	db 0C1H, 00H, 0C2H, 00H, 0C3H, 00H, 0C4H, 00H	; 02F8 _ ........
	db 0C5H, 00H, 0C6H, 00H, 0C7H, 00H, 0C8H, 00H	; 0300 _ ........
	db 0C9H, 00H, 0CAH, 00H, 0CBH, 00H, 0CCH, 00H	; 0308 _ ........
	db 0CDH, 00H, 0CEH, 00H, 0CFH, 00H, 0D0H, 00H	; 0310 _ ........
	db 0D1H, 00H, 0D2H, 00H, 0D3H, 00H, 0D4H, 00H	; 0318 _ ........
	db 0D5H, 00H, 0D6H, 00H, 0D7H, 00H, 0D8H, 00H	; 0320 _ ........
	db 0D9H, 00H, 0DAH, 00H, 0DBH, 00H, 0DCH, 00H	; 0328 _ ........
	db 0DDH, 00H, 0DEH, 00H, 0DFH, 00H, 0E0H, 00H	; 0330 _ ........
	db 0E1H, 00H, 0E2H, 00H, 0E3H, 00H, 0E4H, 00H	; 0338 _ ........
	db 0E5H, 00H, 0E6H, 00H, 0FFH, 0FFH, 0FFH, 0FFH ; 0340 _ ........
	db 0FFH, 0FFH, 0E7H, 00H, 0E8H, 00H, 0E9H, 00H	; 0348 _ ........
	db 0EAH, 00H, 0EBH, 00H, 0FFH, 0FFH, 0FFH, 0FFH ; 0350 _ ........
	db 0FFH, 0FFH, 0ECH, 00H, 0EDH, 00H, 0EEH, 00H	; 0358 _ ........
	db 0EFH, 00H, 0F0H, 00H, 0FFH, 0FFH, 0FFH, 0FFH ; 0360 _ ........
	db 0FFH, 0FFH, 0F1H, 00H, 0F2H, 00H, 0F3H, 00H	; 0368 _ ........
	db 0F4H, 00H, 0F5H, 00H, 0F6H, 00H, 0F7H, 00H	; 0370 _ ........
	db 0F8H, 00H, 0F9H, 00H, 0FAH, 00H, 0FBH, 00H	; 0378 _ ........
	db 0FCH, 00H, 0FDH, 00H, 0FEH, 00H, 0FFH, 00H	; 0380 _ ........
	db 00H, 01H, 01H, 01H, 02H, 01H, 03H, 01H	; 0388 _ ........
	db 04H, 01H, 05H, 01H, 06H, 01H, 07H, 01H	; 0390 _ ........
	db 08H, 01H, 09H, 01H, 0AH, 01H, 0BH, 01H	; 0398 _ ........
	db 0CH, 01H, 0DH, 01H, 0EH, 01H, 0FH, 01H	; 03A0 _ ........
	db 10H, 01H, 11H, 01H, 12H, 01H, 13H, 01H	; 03A8 _ ........
	db 14H, 01H, 15H, 01H, 16H, 01H, 17H, 01H	; 03B0 _ ........
	db 18H, 01H, 19H, 01H, 1AH, 01H, 1BH, 01H	; 03B8 _ ........
	db 1CH, 01H, 1DH, 01H, 1EH, 01H, 1FH, 01H	; 03C0 _ ........
	db 20H, 01H, 21H, 01H, 22H, 01H, 23H, 01H	; 03C8 _  .!.".#.
	db 24H, 01H, 25H, 01H, 0FFH, 0FFH, 0FFH, 0FFH	; 03D0 _ $.%.....
	db 0FFH, 0FFH, 26H, 01H, 27H, 01H, 28H, 01H	; 03D8 _ ..&.'.(.
	db 29H, 01H, 2AH, 01H, 0FFH, 0FFH, 0FFH, 0FFH	; 03E0 _ ).*.....
	db 0FFH, 0FFH, 2BH, 01H, 2CH, 01H, 2DH, 01H	; 03E8 _ ..+.,.-.
	db 2EH, 01H, 2FH, 01H, 0FFH, 0FFH, 0FFH, 0FFH	; 03F0 _ ../.....
	db 0FFH, 0FFH, 30H, 01H, 31H, 01H, 32H, 01H	; 03F8 _ ..0.1.2.
	db 33H, 01H, 34H, 01H, 35H, 01H, 36H, 01H	; 0400 _ 3.4.5.6.
	db 37H, 01H, 38H, 01H, 39H, 01H, 3AH, 01H	; 0408 _ 7.8.9.:.
	db 3BH, 01H, 3CH, 01H, 3DH, 01H, 3EH, 01H	; 0410 _ ;.<.=.>.
	db 3FH, 01H, 40H, 01H, 41H, 01H, 42H, 01H	; 0418 _ ?.@.A.B.
	db 43H, 01H, 44H, 01H, 45H, 01H, 46H, 01H	; 0420 _ C.D.E.F.
	db 47H, 01H, 48H, 01H, 49H, 01H, 4AH, 01H	; 0428 _ G.H.I.J.
	db 4BH, 01H, 4CH, 01H, 4DH, 01H, 4EH, 01H	; 0430 _ K.L.M.N.
	db 4FH, 01H, 50H, 01H, 51H, 01H, 52H, 01H	; 0438 _ O.P.Q.R.
	db 0FFH, 0FFH, 0FFH, 0FFH, 53H, 01H, 54H, 01H	; 0440 _ ....S.T.
	db 55H, 01H, 56H, 01H, 57H, 01H, 58H, 01H	; 0448 _ U.V.W.X.
	db 0FFH, 0FFH, 0FFH, 0FFH, 59H, 01H, 5AH, 01H	; 0450 _ ....Y.Z.
	db 5BH, 01H, 5CH, 01H, 5DH, 01H, 5EH, 01H	; 0458 _ [.\.].^.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0B9H, 01H, 5FH, 01H	; 0460 _ ......_.
	db 60H, 01H, 61H, 01H, 62H, 01H, 63H, 01H	; 0468 _ `.a.b.c.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0BAH, 01H; 0470 _ ........
	db 64H, 01H, 65H, 01H, 66H, 01H, 67H, 01H	; 0478 _ d.e.f.g.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0480 _ ........
	db 0BBH, 01H, 68H, 01H, 69H, 01H, 6AH, 01H	; 0488 _ ..h.i.j.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0490 _ ........
	db 0FFH, 0FFH, 0BCH, 01H, 6BH, 01H, 6CH, 01H	; 0498 _ ....k.l.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 04A0 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0BDH, 01H, 6DH, 01H	; 04A8 _ ......m.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 04B0 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0BEH, 01H; 04B8 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 6EH, 01H ; 04C0 _ ......n.
	db 6FH, 01H, 70H, 01H, 71H, 01H, 72H, 01H	; 04C8 _ o.p.q.r.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 73H, 01H ; 04D0 _ ......s.
	db 74H, 01H, 75H, 01H, 76H, 01H, 77H, 01H	; 04D8 _ t.u.v.w.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 78H, 01H ; 04E0 _ ......x.
	db 79H, 01H, 7AH, 01H, 7BH, 01H, 7CH, 01H	; 04E8 _ y.z.{.|.
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0BFH, 01H; 04F0 _ ........
	db 7DH, 01H, 7EH, 01H, 7FH, 01H, 80H, 01H	; 04F8 _ }.~.....
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0500 _ ........
	db 0C0H, 01H, 81H, 01H, 82H, 01H, 83H, 01H	; 0508 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0510 _ ........
	db 0FFH, 0FFH, 0C1H, 01H, 84H, 01H, 85H, 01H	; 0518 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0520 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0C2H, 01H, 86H, 01H	; 0528 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0530 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0C3H, 01H; 0538 _ ........
	db 0C4H, 01H, 87H, 01H, 88H, 01H, 89H, 01H	; 0540 _ ........
	db 8AH, 01H, 8BH, 01H, 8CH, 01H, 8DH, 01H	; 0548 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0550 _ ........
	db 8EH, 01H, 8FH, 01H, 90H, 01H, 91H, 01H	; 0558 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0560 _ ........
	db 92H, 01H, 93H, 01H, 94H, 01H, 95H, 01H	; 0568 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0570 _ ........
	db 96H, 01H, 97H, 01H, 98H, 01H, 99H, 01H	; 0578 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0580 _ ........
	db 0C5H, 01H, 9AH, 01H, 9BH, 01H, 9CH, 01H	; 0588 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0590 _ ........
	db 0FFH, 0FFH, 0C6H, 01H, 9DH, 01H, 9EH, 01H	; 0598 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 05A0 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0C7H, 01H, 9FH, 01H	; 05A8 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 05B0 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0C8H, 01H; 05B8 _ ........
	db 0C9H, 01H, 0A0H, 01H, 0A1H, 01H, 0A2H, 01H	; 05C0 _ ........
	db 0A3H, 01H, 0A4H, 01H, 0A5H, 01H, 0A6H, 01H	; 05C8 _ ........
	db 0FFH, 0FFH, 0CAH, 01H, 0A7H, 01H, 0A8H, 01H	; 05D0 _ ........
	db 0A9H, 01H, 0AAH, 01H, 0ABH, 01H, 0ACH, 01H	; 05D8 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 05E0 _ ........
	db 0FFH, 0FFH, 0ADH, 01H, 0AEH, 01H, 0AFH, 01H	; 05E8 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 05F0 _ ........
	db 0FFH, 0FFH, 0B0H, 01H, 0B1H, 01H, 0B2H, 01H	; 05F8 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0600 _ ........
	db 0FFH, 0FFH, 0B3H, 01H, 0B4H, 01H, 0B5H, 01H	; 0608 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0610 _ ........
	db 0FFH, 0FFH, 0CBH, 01H, 0B6H, 01H, 0B7H, 01H	; 0618 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0620 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0CCH, 01H, 0B8H, 01H ; 0628 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0630 _ ........
	db 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0CDH, 01H; 0638 _ ........

_ZL12file_to_file:					; byte
	db 00H, 01H, 02H, 03H, 03H, 02H, 01H, 00H	; 0640 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0648 _ ........

_ZL7invflap:						; byte
	db 08H, 10H, 18H, 20H, 28H, 30H 		; 0650 _ ... (0

L_350:							; byte
	db 09H, 11H, 19H, 21H, 29H, 31H 		; 0656 _ ...!)1

L_351:							; byte
	db 0AH, 12H, 1AH, 22H, 2AH, 32H 		; 065C _ ..."*2

L_352:							; byte
	db 0BH, 13H, 1BH, 23H, 2BH, 33H, 00H, 00H	; 0662 _ ...#+3..
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 066A _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0672 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H 		; 067A _ ......

_ZL6ptwist:						; byte
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0680 _ ........
	db 2FH, 23H, 17H, 0BH, 0AH, 16H, 22H, 2EH	; 0688 _ /#....".
	db 2DH, 21H, 15H, 09H, 08H, 14H, 20H, 2CH	; 0690 _ -!.... ,
	db 2BH, 1FH, 13H, 07H, 06H, 12H, 1EH, 2AH	; 0698 _ +......*
	db 29H, 1DH, 11H, 05H, 04H, 10H, 1CH, 28H	; 06A0 _ )......(
	db 27H, 1BH, 0FH, 03H, 02H, 0EH, 1AH, 26H	; 06A8 _ '......&
	db 25H, 19H, 0DH, 01H, 00H, 0CH, 18H, 24H	; 06B0 _ %......$
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 06B8 _ ........

_ZL4flap:						; byte
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 06C0 _ ........
	db 00H, 06H, 0CH, 12H, 12H, 0CH, 06H, 00H	; 06C8 _ ........
	db 01H, 07H, 0DH, 13H, 13H, 0DH, 07H, 01H	; 06D0 _ ........
	db 02H, 08H, 0EH, 14H, 14H, 0EH, 08H, 02H	; 06D8 _ ........
	db 03H, 09H, 0FH, 15H, 15H, 0FH, 09H, 03H	; 06E0 _ ........
	db 04H, 0AH, 10H, 16H, 16H, 10H, 0AH, 04H	; 06E8 _ ........
	db 05H, 0BH, 11H, 17H, 17H, 11H, 0BH, 05H	; 06F0 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 06F8 _ ........

_ZL4diag:						; byte
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 08H	; 0700 _ ........
	db 00H, 01H, 00H, 00H, 00H, 00H, 09H, 00H	; 0708 _ ........
	db 00H, 00H, 02H, 00H, 00H, 0AH, 00H, 00H	; 0710 _ ........
	db 00H, 00H, 00H, 03H, 0BH, 00H, 00H, 00H	; 0718 _ ........
	db 00H, 00H, 00H, 0CH, 04H, 00H, 00H, 00H	; 0720 _ ........
	db 00H, 00H, 0DH, 00H, 00H, 05H, 00H, 00H	; 0728 _ ........
	db 00H, 0EH, 00H, 00H, 00H, 00H, 06H, 00H	; 0730 _ ........
	db 0FH, 00H, 00H, 00H, 00H, 00H, 00H, 07H	; 0738 _ ........

_ZL5lower:						; byte
	db 1CH, 00H, 01H, 02H, 03H, 04H, 05H, 06H	; 0740 _ ........
	db 00H, 1DH, 07H, 08H, 09H, 0AH, 0BH, 0CH	; 0748 _ ........
	db 01H, 07H, 1EH, 0DH, 0EH, 0FH, 10H, 11H	; 0750 _ ........
	db 02H, 08H, 0DH, 1FH, 12H, 13H, 14H, 15H	; 0758 _ ........
	db 03H, 09H, 0EH, 12H, 20H, 16H, 17H, 18H	; 0760 _ .... ...
	db 04H, 0AH, 0FH, 13H, 16H, 21H, 19H, 1AH	; 0768 _ .....!..
	db 05H, 0BH, 10H, 14H, 17H, 19H, 22H, 1BH	; 0770 _ ......".
	db 06H, 0CH, 11H, 15H, 18H, 1AH, 1BH, 23H	; 0778 _ .......#

_ZL8flipdiag:						; byte
	db 00H, 08H, 10H, 18H, 20H, 28H, 30H, 38H	; 0780 _ .... (08
	db 01H, 09H, 11H, 19H, 21H, 29H, 31H, 39H	; 0788 _ ....!)19
	db 02H, 0AH, 12H, 1AH, 22H, 2AH, 32H, 3AH	; 0790 _ ...."*2:
	db 03H, 0BH, 13H, 1BH, 23H, 2BH, 33H, 3BH	; 0798 _ ....#+3;
	db 04H, 0CH, 14H, 1CH, 24H, 2CH, 34H, 3CH	; 07A0 _ ....$,4<
	db 05H, 0DH, 15H, 1DH, 25H, 2DH, 35H, 3DH	; 07A8 _ ....%-5=
	db 06H, 0EH, 16H, 1EH, 26H, 2EH, 36H, 3EH	; 07B0 _ ....&.6>
	db 07H, 0FH, 17H, 1FH, 27H, 2FH, 37H, 3FH	; 07B8 _ ....'/7?

_ZL8triangle:						; byte
	db 06H, 00H, 01H, 02H, 02H, 01H, 00H, 06H	; 07C0 _ ........
	db 00H, 07H, 03H, 04H, 04H, 03H, 07H, 00H	; 07C8 _ ........
	db 01H, 03H, 08H, 05H, 05H, 08H, 03H, 01H	; 07D0 _ ........
	db 02H, 04H, 05H, 09H, 09H, 05H, 04H, 02H	; 07D8 _ ........
	db 02H, 04H, 05H, 09H, 09H, 05H, 04H, 02H	; 07E0 _ ........
	db 01H, 03H, 08H, 05H, 05H, 08H, 03H, 01H	; 07E8 _ ........
	db 00H, 07H, 03H, 04H, 04H, 03H, 07H, 00H	; 07F0 _ ........
	db 06H, 00H, 01H, 02H, 02H, 01H, 00H, 06H	; 07F8 _ ........

_ZL7offdiag:						; byte
	db 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH; 0800 _ ........
	db 01H, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH ; 0808 _ ........
	db 01H, 01H, 00H, 0FFH, 0FFH, 0FFH, 0FFH, 0FFH	; 0810 _ ........
	db 01H, 01H, 01H, 00H, 0FFH, 0FFH, 0FFH, 0FFH	; 0818 _ ........
	db 01H, 01H, 01H, 01H, 00H, 0FFH, 0FFH, 0FFH	; 0820 _ ........
	db 01H, 01H, 01H, 01H, 01H, 00H, 0FFH, 0FFH	; 0828 _ ........
	db 01H, 01H, 01H, 01H, 01H, 01H, 00H, 0FFH	; 0830 _ ........
	db 01H, 01H, 01H, 01H, 01H, 01H, 01H, 00H	; 0838 _ ........

_ZL8pa_flags:						; byte
	db 08H, 00H, 00H, 00H, 04H, 00H, 00H, 00H	; 0840 _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0848 _ ........

_ZL10wdl_to_map:					; byte
	db 01H, 00H, 00H, 00H, 03H, 00H, 00H, 00H	; 0850 _ ........
	db 00H, 00H, 00H, 00H, 02H, 00H, 00H, 00H	; 0858 _ ........
	db 00H, 00H, 00H, 00H				; 0860 _ ....

_ZL4pchr:						; byte
	db 4BH						; 0864 _ K

L_353:							; byte
	db 51H, 52H, 42H, 4EH, 50H, 00H, 00H, 00H	; 0865 _ QRBNP...
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 086D _ ........
	db 00H, 00H, 00H, 00H, 00H, 00H, 00H, 00H	; 0875 _ ........
	db 00H, 00H, 00H				; 087D _ ...



align 16
wdl_to_Value5:
  dd  -VALUE_MATE + MAX_PLY + 1
  dd VALUE_DRAW - 2
  dd VALUE_DRAW
  dd VALUE_DRAW + 2
  dd VALUE_MATE - MAX_PLY - 1

WDLtoDTZ db -1,-101,0,101,1

end if


