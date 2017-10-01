; these are all of the structs used


;;;;;;;;;;;;;;;;;;;;
; hash and table structures
;;;;;;;;;;;;;;;;;;;;


struct MainHash
 table	rq 1
 mask	rq 1
 lpSize rq 1	; 0 if large pages are not in use, otherwise the allocation size
 sizeMB rd 1
 date	rb 1
	rb 3
ends

struct MainHashEntry	; 8 bytes
 genBound  rb 1  ;
 depth	   rb 1  ;
 move	   rw 1  ;
 eval_	   rw 1  ;
 value_	   rw 1  ; this order is fixed
ends


struct MaterialEntry	; 16 bytes
 key		    rq 1
 scalingFunction    rb 2   ; these are 1 byte endgame structures
 evaluationFunction rb 1   ; they store the EndgameEntry.entry member
 gamePhase	    rb 1
 factor 	    rb 2
 value		    rw 1
ends


struct PawnEntry	; 80 bytes
 passedPawns	 rq 2
 pawnAttacks	 rq 2
 pawnAttacksSpan rq 2
 key		rq 1
 kingSafety	rd 2
 score		rd 1
 kingSquares	rb 2  ; [0,63] each
 semiopenFiles	rb 2
 pawnsOnSquares rb 4  ; [0,4] each
 asymmetry	rb 1  ; [0,8]
 openFiles	rb 1
 castlingRights rb 1
 weakUnopposed  rb 1
ends

struct HistoryStats
 rd 2*64*64
ends

struct MoveStats
 rd 16*64
ends

struct CounterMoveHistoryStats
 rd 16*64*16*64
ends


;;;;;;;;;;;;;;;;;;;;;;;;;
; evaluation structures
;;;;;;;;;;;;;;;;;;;;;;;;;

; this struct sits on the stack for the whole duration of evaluation
struct EvalInfo
 attackedBy   rq 16
 attackedBy2  rq 2
 pinnedPieces rq 2
 mobilityArea rq 2
 kingRing     rq 2
 kingAttackersCount  rd 2
 kingAttackersWeight rd 2
 kingAdjacentZoneAttacksCount rd 2
 score	   rd 1
	   rd 1
 me   rq 1
 pi   rq 1
ends

struct EndgameMapEntry
 key	rq 1
 entri	rb 1
	rb 7 ; assumed to be zeros
ends

;;;;;;;;;;;;;;;;;;;;
; move structures
;;;;;;;;;;;;;;;;;;;;

struct ExtMove	 ; holds moves for gen/pick
 move	rd 1
 value	rd 1
ends
;if sizeof.ExtMove <> 8
; err
;end if

struct RootMovesVec
 table	rq 1
 ender	rq 1
ends

struct RootMove
 prevScore rd 1 ; this order is used in PrintUciInfo
 score	   rd 1 ;
 pvSize    rd 1
 selDepth  rd 1
 pv	   rd MAX_PLY
ends


;;;;;;;;;;;;;;;;;;
; position structures
;;;;;;;;;;;;;;;;;;

struct Pos
 typeBB      rq 8
 board	     rb 64
                                ; absolute index means not relative to the type of piece in piece list
 pieceIdx    rb 64		; pieceIdx[Square s] gives the absolute index of the piece on square s in pieceList
 pieceEnd    rb 16		; pieceEnd[Piece p] gives the absolute index of the SQ_NONE terminator in pieceList for type p
 pieceList   rb 16*16		; pieceList[Piece p][16] is a SQ_NONE-terminated array of squares for piece p

 sideToMove  rd 1
	     rd 1
 gamePly     rd 1
 chess960    rd 1
 _copy_size rb 0
if DEBUG
 debugQWORD1	rq 1   ; some general purpose data
 debugDWORD1	rd 1   ; for asserting the asserts in debug
 debugDWORD2	rd 1   ;
end if
 state		rq 1 ; the current state struct
 stateTable	rq 1 ; the beginning of the vector of State structs
 stateEnd	rq 1 ; the end of
 counterMoveHistory  rq 1	 ; these structs hold addresses
 history 	rq 1		 ; of tables used by the search
 counterMoves	rq 1		 ;
 materialTable	rq 1		 ;
 pawnTable	rq 1		 ;
 rootMovesVec	RootMovesVec	 ;
 moveList	rq 1
ends



; Since the original State struct is used in a stack like fasion
;  with the Stack struct, these are combined into one struct
; Also, the CheckInfo struct can be harmlessly moved here too

struct State
; State struct
 key		rq 1
 pawnKey	rq 1
 materialKey	rq 1
 psq		rw 2
 npMaterial	rw 2
 rule50 	 rw 1  ; these should be together
 pliesFromNull	 rw 1  ;
 epSquare	 rb 1
 castlingRights  rb 1
 capturedPiece	 rb 1
; CheckInfo struct
 ksq		 rb 1
 checkersBB	rq 1   ; this is actually not part of checkinfo
 dcCandidates	rq 1
 pinned 	rq 1
 checkSq	 rq 8
 blockersForKing  rq 2
 pinnersForKing   rq 2
; Stack struct
_stack_start rb 0
 pv		rq 1
 counterMoves	rq 1
 currentMove	 rd 1
 excludedMove	 rd 1
 killers	 rd 2
 moveCount	  rd 1
 staticEval	  rd 1
 history	  rd 1
 ply		   rb 1
 skipEarlyPruning rb 1
		  rb 2
_stack_end rb 0
; move picker data
_movepick_start rb 0
 cur		 rq 1
 endMoves	 rq 1
 endBadCaptures  rq 1
 stage		 rq 1
 countermove	   rd 1
 givesCheck        rb 1
                   rb 3
 ttMove 	   rd 1
 depth		   rd 1
 threshold	   rd 1
 recaptureSquare   rd 1
 mpKillers         rd 2
_movepick_end rb 0
ends

;if (sizeof.State and 15)
; err
;end if


;;;;;;;;;;;;;;;;;;;;
; search structures
;;;;;;;;;;;;;;;;;;;;


struct Limits
 nodes	     rq 1
 startTime   rq 1
 time	      rd 2
 incr	      rd 2
 movestogo   rd 1
 depth	     rd 1
 movetime    rd 1
 mate	     rd 1
 multiPV      rd 1
	      rd 1
 infinite     rb 1	 ; bool 0 or -1
 ponder       rb 1	 ; bool 0 or -1
 useTimeMgmt  rb 1	 ; bool 0 or -1
	      rb 1
 moveVecSize  rd 1
 moveVec    rw MAX_MOVES
ends


struct Options
 hash	    rd 1
 threads    rd 1
 largePages rb 1     ; bool 0 or -1
 changed    rb 1     ; have hash or threads changed?
	    rb 2
 multiPV    rd 1
 chess960	rd 1
                rd 1
                rd 1
 moveOverhead	rd 1
 contempt	  rd 1
 ponder 	  rb 1
 displayInfoMove  rb 1	    ; should we display pv info and best move?
		  rb 1
 syzygy50MoveRule rb 1	    ; bool 0 or -1
 syzygyProbeDepth rd 1
 syzygyProbeLimit rd 1
if USE_VARIETY = 1
 varietyMod   rd 1
 varietyBound rd 1
              rq 1
end if
 hashPath	rq 1
 hashPathSizeB	rq 1
 hashPathBuffer rq 14
ends


struct Weakness
 targetLoss   rq 1
 prng	      rq 1
	      rq 1
 multiPV      rd 1
 enabled      rb 1
	      rb 3
ends


struct EasyMoveMng
 expectedPosKey rq 1
 pv		rd 4
 stableCnt	rd 1
		rd 3
ends


struct Signals
 stop		 rb 1
 stopOnPonderhit rb 1
		 rb 14
ends


struct Time
 startTime   rq 1
 optimumTime rq 1
 maximumTime rq 1
	     rq 1
ends




;;;;;;;;;;;;;;;;;;;;
; thread structures
;;;;;;;;;;;;;;;;;;;;

if VERSION_OS = 'L'

  struct ThreadHandle
   stackAddress rq 1
   mutex	rd 1
		rd 1
  ends

  struct Mutex
   rd 1
   rd 1  ; extra
   rq 1  ; extra
  ends

  struct ConditionalVariable
   rd 1
   rd 1  ; extra
   rq 1
  ends

else if VERSION_OS = 'W'

  struct ThreadHandle
   handle   rq 1
  ends

  struct Mutex
   rq 5
  ends

  struct ConditionalVariable
   handle rq 1
  ends

else if VERSION_OS = 'X'

  struct ThreadHandle
   rb sizeof.pthread_t
  ends

  struct Mutex
   rb sizeof.pthread_mutex_t
  ends

  struct ConditionalVariable
   rb sizeof.pthread_cond_t
  ends

end if



struct Thread
 mutex		 Mutex
 sleep1 	 ConditionalVariable
 sleep2 	 ConditionalVariable
 threadHandle	 ThreadHandle
 numaNode	 rq 1
 bestMoveChanges rq 1
 PVIdx		 rd 1
 previousScore	 rd 1
 completedDepth  rd 1
 callsCnt	 rd 1
 resetCnt	 rd 1
		 rd 1
 searching	  rb 1
 exit		  rb 1
 failedLow	  rb 1
 easyMovePlayed   rb 1
		  rb 1
		  rb 1
 selDepth         rb 1
		  rb 1
 nodes		rq 1
 tbHits 	rq 1
if USE_VARIETY = 1
 randSeed     rq 1
              rq 1
end if
 idx		rd 1
 rootDepth	rd 1

 castling_start rb 0
 castling_rfrom      rb 4
 castling_rto	     rb 4
 castling_path	     rq 4
 castling_ksqpath    rb 4*8
 castling_knights    rq 4
 castling_kingpawns  rq 4
 castling_movgen     rd 4       ; these are the four castling moves
 castling_rightsMask rb 64
 castling_end rb 0

 rootPos	 Pos
ends

if Thread.rootPos and 15
 err
end if




if VERSION_OS = 'L'
; on linux, cpu data is held in a large bit mask

  struct NumaNode
   nodeNumber	rd 1
   coreCnt	rd 1
   cmhTable	rq 1
   parent 	rq 1
  		rq 1
   cpuMask	rq MAX_LINUXCPUS/64
  ends

else if VERSION_OS = 'W'
; windows uses the concept of processor groups
;  each node is in one group and has a cpu mask associated with it
; the WinNumaNode struct is used by GetLogicalProcessorInformationEx
; the GROUP_AFFINITY struct is used by SetThreadGroupAffinity

  struct GROUP_AFFINITY
    Mask	dq ?
    Group       dw ?
                dw ?,?,?
  ends
  
  struct WinNumaNode
   Relationship	rd 1
   Size		rd 1
   NodeNumber	rd 1
  		rd 5
   GroupMask	GROUP_AFFINITY
  ends
  
  struct NumaNode
   nodeNumber	rd 1
   coreCnt	rd 1
   cmhTable	rq 1
   parent 	rq 1
  		rq 1
   groupMask	GROUP_AFFINITY
  ends

else if VERSION_OS = 'X'
; mac os x is numa-unaware

  struct NumaNode
   nodeNumber	rd 1
   coreCnt	rd 1
   cmhTable	rq 1
   parent 	rq 1
  		rq 1
   cpuMask	rq 0
  ends

end if


; structure for managing all search threads
struct ThreadPool
 threadCnt rd 1
 nodeCnt   rd 1
 coreCnt   rd 1
	   rd 1
 threadTable rq MAX_THREADS
 nodeTable   rb MAX_NUMANODES*sizeof.NumaNode
ends


; structure for buffer input and output (input only for now)
struct IOBuffer
 cmdLineStart	  rq 1	; address of string from cmd line to parse
 inputBuffer	  rq 1	; address of string from stdin to parse
 inputBufferSizeB rq 1	; byte capacity of inputBuffer
 log              rq 1
 tmp_i		rd 1
 tmp_j		rd 1
            rq 1
 tmpBuffer	    rb 512
 tmpBufferEnd	rb 0
ends
sizeof.IOBuffer.tmpBuffer = 512

; structures for books

struct Book
 buffer        rq 1
 seed          rq 1
 entryCount   rd 1
 failCount    rd 1
 bookDepth    rd 1
 ownBook      rb 1
 bestBookMove rb 1
              rb 2
 move   rd 1
 weight rd 1
 ponder rd 1
        rd 1
ends

struct Brain
 startOrg   rq 1
 enderOrg   rq 1
 currentOrg  rq 1
 start	     rq 1
 ender	    rq 1
 file_	    rq 1
 path	      rq 1
 entriesCount rd 1
 visitedCount rd 1
 depthRecordBuffer rq 1
		   rq 1

 depthRecord   rd 1
	       rd 1
 maxDepth      rd 1
 timer	       rb 1
	       rb 3

ends

struct BrainEntry
 brainKey   rq 1  ; bits 0-47 contain bits 16-63 of sf key
	    rb 1
 brainMove0 rb 1
 brainMove1 rb 1
	    rb 1
 visitedDepth rd 1
 polyglotKey	rq 1
 polyglotMove0	rw 1
 polyglotMove1	rw 1
		rd 1
ends
if sizeof.BrainEntry <> 32
 err
end if

struct PolyglotEntry
 key	rq 1
 move	rw 1
 weight rw 1
 learn	rd 1
ends
if sizeof.PolyglotEntry <> 16
 err
end if

; after a book is loaded, its entries are stored in BookEntry struct
struct BookEntry
 key    rq 1
 move   rw 1
 weight rw 1
ends

; moves found in a book are stored in ExtBookMove struct
struct ExtBookMove
 move   rd 1
 weight rd 1
 total  rd 1
ends

