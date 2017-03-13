        .balign 8
LargePageMinSize:
        .dword 0

DisplayLock: .zero sizeof.Mutex

szUciResponse:
	.ascii "id name "
szGreeting:
	.ascii "armFish"
	.ascii "\n"
szGreetingEnd:
	.ascii "id author TypingALot"
	.ascii "\n"
	.ascii "option name Hash type spin default 16 min 1 max "
	.ascii "65536"
	.ascii "\n"
	.ascii "option name LargePages type check default false"
	.ascii "\n"
	.ascii "option name Threads type spin default 1 min 1 max "
	.ascii "256"
	.ascii "\n"
	.ascii "option name NodeAffinity type string default all"
	.ascii "\n"
	.ascii "option name Priority type combo default none var none var normal var low var idle"
	.ascii "\n"

	.ascii "option name Clear Hash type button"
	.ascii "\n"

	.ascii "option name Ponder type check default false"
	.ascii "\n"
	.ascii "option name UCI_Chess960 type check default false"
	.ascii "\n"

	.ascii "option name MultiPV type spin default 1 min 1 max 224"
	.ascii "\n"
	.ascii "option name Contempt type spin default 0 min -100 max 100"
	.ascii "\n"
	.ascii "option name MoveOverhead type spin default 30 min 0 max 5000"
	.ascii "\n"
	.ascii "option name MinThinkTime type spin default 20 min 0 max 5000"
	.ascii "\n"
	.ascii "option name SlowMover type spin default 89 min 10 max 1000"
	.ascii "\n"

	.ascii "uciok"
sz_NewLine:
	.ascii "\n"
sz_NewLineEnd:
szUciResponseEnd:





sz_thread_format:
        .ascii "info string node %s0 has threads\0"
sz_bench_format1:
        .ascii "*** bench hash %u0 threads %u1 depth %u2 realtime %u3 ***\n\0"
sz_bench_format2:
        .ascii "%u0:  nodes: %u2, %u3 knps\n\0"
sz_bench_format3:
        .ascii "Total time (ms) : %u0\n"
        .ascii "Nodes searched  : %u1\n"
        .ascii "Nodes/second    : %u2\n\0"
sz_hash_cleared:
        .ascii "info string hash cleared\0"


sz_error_rook_page:
        .ascii "rook attack data is not page aligned\0"
sz_error_bishop_page:
        .ascii "bishop attack data is not page aligned\0"


sz_error_sys_futex_EventSignal:
        .ascii "sys_futex in Os_EventSignal failed\0"
sz_error_EventWait:
        .ascii "Os_EventWait failed\0"
sz_error_sys_futex_MutexUnlock:
        .ascii "sys_futex in Os_MutexUnlock failed\0"
sz_error_sys_clone:
        .ascii "sys_clone failed\0"
sz_error_sys_sched_setaffinity:
        .ascii "sys_sched_setaffinity failed\0"
sz_error_sys_mmap_VirtualAlloc:
        .ascii "sys_mmap in Os_VirtualAlloc failed\0"
sz_error_sys_unmap_VirtualFree:
        .ascii "sys_unmap in Os_VirtualFree failed\0"
sz_failed_x0:
        .ascii " x0: 0x\0"



szStartFEN:         .ascii "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1\0"
PieceToChar:        .ascii ".?PNBRQK??pnbrqk"

sz_error_priority:  .ascii "error: unknown priority \0"
sz_error_depth:     .ascii "error: bad depth \0"
sz_error_fen:       .ascii "error: illegal fen\0"
sz_error_moves:     .ascii "error: illegal move \0"
sz_error_token:     .ascii "error: unexpected token \0"
sz_error_unknown:   .ascii "error: unknown command \0"
sz_error_think:	    .ascii "error: setoption called while thinking\0"
sz_error_value:	    .ascii "error: setoption has no value\0"
sz_error_name:	    .ascii "error: setoption has no name\0"
sz_error_option:    .ascii "error: unknown option \0"
sz_error_affinity1: .ascii "error: parsing affinity failed after \0"
sz_error_affinity2: .ascii "; proceeding as all\0"

sz_go:                  .ascii "go\0"
sz_all:			.ascii "all\0"
sz_low:			.ascii "low\0"
sz_uci:			.ascii "uci\0"
sz_fen:			.ascii "fen\0"
sz_wait: 		.ascii "wait\0"
sz_quit: 		.ascii "quit\0"
sz_none: 		.ascii "none\0"
sz_winc: 		.ascii "winc\0"
sz_binc: 		.ascii "binc\0"
sz_mate: 		.ascii "mate\0"
sz_name: 		.ascii "name\0"
sz_true: 		.ascii "true\0"
sz_idle: 		.ascii "idle\0"
sz_hash: 		.ascii "hash\0"
sz_stop: 		.ascii "stop\0"
sz_false:		.ascii "false\0"
sz_value:		.ascii "value\0"
sz_depth:		.ascii "depth\0"
sz_nodes:		.ascii "nodes\0"
sz_wtime:		.ascii "wtime\0"
sz_btime:		.ascii "btime\0"
sz_moves:		.ascii "moves\0"
sz_perft:		.ascii "perft\0"
sz_bench:		.ascii "bench\0"
sz_ttfile:		.ascii "ttfile\0"
sz_ttsave:		.ascii "ttsave\0"
sz_ttload:		.ascii "ttload\0"
sz_ponder:		.ascii "ponder\0"
sz_normal:		.ascii "normal\0"
sz_threads:		.ascii "threads\0"
sz_isready:		.ascii "isready\0"
sz_readyok:             .ascii "readyok\0"
sz_multipv:		.ascii "multipv\0"
sz_realtime:		.ascii "realtime\0"
sz_startpos:		.ascii "startpos\0"
sz_infinite:		.ascii "infinite\0"
sz_movetime:		.ascii "movetime\0"
sz_contempt:		.ascii "contempt\0"
sz_weakness:		.ascii "weakness\0"
sz_priority:		.ascii "priority\0"
sz_position:		.ascii "position\0"
sz_movestogo:		.ascii "movestogo\0"
sz_setoption:		.ascii "setoption\0"
sz_slowmover:		.ascii "slowmover\0"
sz_ponderhit:		.ascii "ponderhit\0"
sz_ucinewgame:		.ascii "ucinewgame\0"
sz_clear_hash:		.ascii "clear hash\0"
sz_largepages:		.ascii "largepages\0"
sz_searchmoves:		.ascii "searchmoves\0"
sz_nodeaffinity: 	.ascii "nodeaffinity\0"
sz_moveoverhead: 	.ascii "moveoverhead\0"
sz_minthinktime: 	.ascii "minthinktime\0"
sz_uci_chess960: 	.ascii "uci_chess960\0"

sz_show: .ascii "show\0"

BenchFens: //fens must be separated by one or more space char
.ascii "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 "
.ascii "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 10 "
.ascii "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 11 "
.ascii "4rrk1/pp1n3p/3q2pQ/2p1pb2/2PP4/2P3N1/P2B2PP/4RRK1 b - - 7 19 "
.ascii "rq3rk1/ppp2ppp/1bnpb3/3N2B1/3NP3/7P/PPPQ1PP1/2KR3R w - - 7 14 "
.ascii "r1bq1r1k/1pp1n1pp/1p1p4/4p2Q/4Pp2/1BNP4/PPP2PPP/3R1RK1 w - - 2 14 "
.ascii "r3r1k1/2p2ppp/p1p1bn2/8/1q2P3/2NPQN2/PPP3PP/R4RK1 b - - 2 15 "
.ascii "r1bbk1nr/pp3p1p/2n5/1N4p1/2Np1B2/8/PPP2PPP/2KR1B1R w kq - 0 13 "
.ascii "r1bq1rk1/ppp1nppp/4n3/3p3Q/3P4/1BP1B3/PP1N2PP/R4RK1 w - - 1 16 "
.ascii "4r1k1/r1q2ppp/ppp2n2/4P3/5Rb1/1N1BQ3/PPP3PP/R5K1 w - - 1 17 "
.ascii "2rqkb1r/ppp2p2/2npb1p1/1N1Nn2p/2P1PP2/8/PP2B1PP/R1BQK2R b KQ - 0 11 "
.ascii "r1bq1r1k/b1p1npp1/p2p3p/1p6/3PP3/1B2NN2/PP3PPP/R2Q1RK1 w - - 1 16 "
.ascii "3r1rk1/p5pp/bpp1pp2/8/q1PP1P2/b3P3/P2NQRPP/1R2B1K1 b - - 6 22 "
.ascii "r1q2rk1/2p1bppp/2Pp4/p6b/Q1PNp3/4B3/PP1R1PPP/2K4R w - - 2 18 "
.ascii "4k2r/1pb2ppp/1p2p3/1R1p4/3P4/2r1PN2/P4PPP/1R4K1 b - - 3 22 "
.ascii "3q2k1/pb3p1p/4pbp1/2r5/PpN2N2/1P2P2P/5PP1/Q2R2K1 b - - 4 26 "
.ascii "6k1/6p1/6Pp/ppp5/3pn2P/1P3K2/1PP2P2/3N4 b - - 0 1 "
.ascii "3b4/5kp1/1p1p1p1p/pP1PpP1P/P1P1P3/3KN3/8/8 w - - 0 1 "
.ascii "2K5/p7/7P/5pR1/8/5k2/r7/8 w - - 0 1 "
.ascii "8/6pk/1p6/8/PP3p1p/5P2/4KP1q/3Q4 w - - 0 1 "
.ascii "7k/3p2pp/4q3/8/4Q3/5Kp1/P6b/8 w - - 0 1 "
.ascii "8/2p5/8/2kPKp1p/2p4P/2P5/3P4/8 w - - 0 1 "
.ascii "8/1p3pp1/7p/5P1P/2k3P1/8/2K2P2/8 w - - 0 1 "
.ascii "8/pp2r1k1/2p1p3/3pP2p/1P1P1P1P/P5KR/8/8 w - - 0 1 "
.ascii "8/3p4/p1bk3p/Pp6/1Kp1PpPp/2P2P1P/2P5/5B2 b - - 0 1 "
.ascii "5k2/7R/4P2p/5K2/p1r2P1p/8/8/8 b - - 0 1 "
.ascii "6k1/6p1/P6p/r1N5/5p2/7P/1b3PP1/4R1K1 w - - 0 1 "
.ascii "1r3k2/4q3/2Pp3b/3Bp3/2Q2p2/1p1P2P1/1P2KP2/3N4 w - - 0 1 "
.ascii "6k1/4pp1p/3p2p1/P1pPb3/R7/1r2P1PP/3B1P2/6K1 w - - 0 1 "
.ascii "8/3p3B/5p2/5P2/p7/PP5b/k7/6K1 w - - 0 1 "
.ascii "8/8/8/8/5kp1/P7/8/1K1N4 w - - 0 1 "
.ascii "8/8/8/5N2/8/p7/8/2NK3k w - - 0 1 "
.ascii "8/3k4/8/8/8/4B3/4KB2/2B5 w - - 0 1 "
.ascii "8/8/1P6/5pr1/8/4R3/7k/2K5 w - - 0 1 "
.ascii "8/2p4P/8/kr6/6R1/8/8/1K6 w - - 0 1 "
.ascii "8/8/3P3k/8/1p6/8/1P6/1K3n2 b - - 0 1 "
.ascii "8/R7/2q5/8/6k1/8/1P5p/K6R w - - 0 124"
BenchFensEnd: .byte 0

