Deep_asmFish for quick analysis

Removed steps 6,8,9 (Razoring, Null move, Probcut) as in DeepFish MZ.
But not cut 7, 10 and 13 (Futility pruning, Internal iterative deepening, Pruning at shallow depth) steps.
Deep_asmFish search mate in #24 very quickly (20 sec on 1 core of i5-3570) in this position
5kB1/3p1P2/7K/2Pp1P1P/p6p/4P3/7P/8 w - - 0 1

Results of tournament 40/10s vs Stockfish development version 16120518:

Score of deepAsmFishW_071216_popcnt vs stockfish_16120518: 6 - 13 - 30 [0.429]
ELO difference: -49.98 +/- 60.75

50 of 50 games finished.

******** introduction ********
Welcome to the project of converting stockfish into x86-64!
The executables can be found in the Windows folder.
The source files can be found in the asmFish folder.
  - run fasm on asmFishW_base[_popcnt,_bmi2].asm to produce executables for windows
  - run fasm on asmFish_base[_popcnt,_bmi2].asm to produce executables for linux
For more information on this project see the asmFish/asmReadMe.txt.
Run make.bat to automatically assemble the windows/linux sources for the three capabilities
  - base: should run on any 64bit x86 cpu
  - popcnt: generate popcnt instruction
  - bmi2: use instructions introduced in haswell
Besides the three cpu capabilities, this project now comes in two flavours
  - asmFish: trim off the cruft in official stockfish and make a lean and mean chess engine
  - pedantFish: match bench signature of official stockfish to catch search/eval bugs more easily
More flavors are planned for the future, including mateFish and hybridFish.
  
If you observe a crash/misbehaviour in asmFish, please raise an issue here and give me the following information:
  - name of the executable that crashed/misbehaved
  - exception code and exception offset in the case of a crash
  - a log of the commands that were sent to asmFish by your gui before the crash
Simply stating that asmFish crashed in your gui is useless information by itself.
asmFish is known to have problems in the fritz15 gui, while it plays much better in the
fritz11 gui. Any help with this issue would be appreciated.


******** FAQ ********
Q: Why not just start with the compiler output and speed up the critical functions?
   or write critical functions in asm and include them in cpp code?
A: With this approach the critical functions would still need to conform to the standards
   set in place by the ABI. All of the critical functions in asmFish do not conform to these
   standards. Plus, asmFish would be dependent on a compiler in this case, which introduces
   many unnecessary compilcations. Both asmFish and its assembler are around 100KB; lets keep
   it simple. Note that compiler output was used in the case of Ronald de Man's syzygy
   probing code, as this is not speed critical but cumbersome to write by hand.

Q: Is asmFish the same as official stockfish?
A: It is 99.9% official stockfish as there are some inconsequential functional differences in 
   official that were deemed too silly to put into asmFish. Piece lists are the prime offender
   here. You can get 100% official stockfish in deterministic searches by setting
   PEDANTIC equ 1 compile option. The changes can be viewed at
   https://github.com/tthsqe12/asm/search?q=PEDANTIC


******** updates ********
2016-11-04: "stockfish 8"
  - summary of extra features in all versions by default
    - NodeAffinity:
      - "all"  pin threads to all nodes your machine in a uniform way
      - "none"  disable pinning threads to nodes
      - "0 1 2 3" only use nodes 0, 1, 2 and 3
      - "2" only use node 2
      - "0.1 2.3" use nodes 0, 1, 2 and 3
          but node 1 shares per-node memory with node 0
              node 3 shares per-node memory with node 2
      - "0.1.2.3" use nodes 0, 1, 2 and 3
          but nodes 1, 2 and 3 share per-node memory with node 0
      - if you want to see the detected cores in your machine
          run "setoption name NodeAffinity value all"
    - TTFile, TTSave, TTLoad  
      - these simply save and load the transposition table to and from a file
        - format is not compatible with the packing in official version
    - LargePages
      - tries to allocate main hash with large pages
        - hash (and thread) commands are processed after receiving "isready"
  - summary of extra features only in base version by default
    - OwnBook , BookFile    (USE_BOOK equ 1)
      - should work as expected for books in polyglot format
    - UCI_LimitStrength, UCI_Elo    (USE_WEAKNESS equ 1)
      - should aslo work as expected, although strength has not been finely tuned

2016-10-15: "Allow inCheck pruning"
  - official has undergone speed patches; smaller gap relative to ultimaiq builds:
        speedup % from bench 128 4 n on windows+haswell:
          n      16    17    18    19   
          bmi2   13.5  13.3  13.9  13.6 
          popcnt 14.9  14.6  15.1  15.4
      
2016-10-04: "Allow inCheck pruning"
  - Def.asm now contains easy switches for turning off some output
      USE_CURRMOVE creates lots of spam in the output
      USE_HASHFULL displays hashfull in info string
      USE_SELDEPTH displays the max ply of the search
      USE_SPAMFILTER prevents printing info before a certain time
  - recommended settings if you are running a tournament in arena
      USE_CURRMOVE   equ 0   
      USE_HASHFULL   equ 0  
      USE_SELDEPTH   equ 0   
      USE_SPAMFILTER equ 1  
      SPAMFILTER_DELAY equ 100

2016-09-14: "Use Movepick SEE value in search"
  - last update until stockfish 8
    - sf code is simply too volitile these days and I need a break
    - code is not optimized and is even behind latest see-aware pins
    - please see cfish project of syzygy1 from now on for faster compiles of stockfish
  - there is however a new NodeAffinity option which can have the following values
    - "all"  pin threads to all nodes your machine in a uniform way
    - "none"  disable pinning threads to nodes
    - "0 1 2 3" only use nodes 0, 1, 2 and 3
    - "2" only use node 2
    - "0.1 2.3" use nodes 0, 1, 2 and 3
        but node 1 shares per-node memory with node 0
            node 3 shares per-node memory with node 2
    - "0.1.2.3" use nodes 0, 1, 2 and 3
        but nodes 1, 2 and 3 share per-node memory with node 0
    - if you want to see the detected cores in your machine
        run "setoption name NodeAffinity value all"
    

2016-08-23: "Refutation penalty on captures"
  - some speed gain over last relative to ultimaiq builds
  	speedup % from bench 128 1 n:
          n      16    17    18    19    20    21    
          bmi2   16.8  17.1  17.0  17.2  16.9  17.3  
          popcnt 16.5  17.1  16.5  16.5  16.6  16.6
  - added support for large pages
    - gui's can send the 'LargePages', 'Hash', and 'Threads' options in whatever random order
      they like. Since the engine should take care with these options, the processing of
      these options has been delayed until the 'isready' command is received. They are also
      processed after the 'go' command so that cmd line interation is not too cumbersome
      - if you have working LP, the interation could go like this
	 < asmFishW_2016-08-24_bmi2
	 > setoption name Threads value 4
	 > setoption name LargePages value true
	 > setoption name Hash value 256
	 > isready
	 < info string hash set to 256 MiB page size 2048 KiB
	 < info string node 0 cores 4 group 0 mask 0x000000000000000f
	 < info string node 0 has threads 0 1 2 3
	 < readyok
      - if you don't have working LP, the same interation is
	 < asmFishW_2016-08-24_bmi2
	 > setoption name Threads value 4
	 > setoption name LargePages value true
	 > setoption name Hash value 256
	 > isready
	 < info string hash set to 256 MiB
	 < info string node 0 cores 4 group 0 mask 0x000000000000000f
	 < info string node 0 has threads 0 1 2 3
	 < readyok
    - the engine still starts 1 search thread and allocates 16MiB of non-LP hash at startup
    - The 'LargePages' option does nothing on Linux, which may change in the future

2016-08-20: "Simplify IID"
  - fixed bug in tt for pedantic version
  - fixed bug in KBPsK scale
  - added hash usage
  - testing pedantic against ultimaiq builds
      speedup % from bench 128 1 n:
	n      16    17    18	 19    20    21    
	bmi2   16.4  16.9  16.7  16.7  17.0  16.8  
	popcnt 16.3  16.1  15.5  15.9  16.0  16.1
      speedup % from bench 128 4 n:
	n      17    18    19	 20    21    22    
	bmi2   15.0  15.9  17.1  16.9  15.7  17.5  
	popcnt 15.4  15.9  16.2  14.7  16.2  15.7

2016-08-18: "Remove a stale assignment"
  - searching for bug in pedantic version
    - bench speedup % over abrok.eu builds with hash=128 and depth=15,...,20
    depth  |  15  |  16  |  17	|  18  |  19  |  20  |
    bmi2   | 23.6 | 24.3 | 24.3 | 24.5 | bench no longer matches
    popcnt | 25.3 | 25.3 | 25.4 | 25.8 | at depth 19
    
2016-08-17: "Use predicted depth for history pruning"
  - fixed some silly bugs in Linux version. futexes are trickey

2016-08-12: "Simplify space formula"
  - removed colon from info strings
  - added PEDANTIC compile option, which makes asmFish match official stockfish in deterministic searches.
    
2016-08-08: "Use Color-From-To history stats to help sort moves"
  - the 07-25 version changed the default value of SlowMover from 80 to 89
    which probably accounts for some of the larger-than-expect Elo gain on http://spcc.beepworld.de/

2016-07-25: "Allow null pruning at depth 1"
  - several structures have been modified to accomodate the linux port
  - on start, asmfish now displays node information on numa systems

2016-07-18: "Gradually relax the NMP staticEval check"
  - fixed broken ponder in 07-17
  - added gui spam with current move info when not using time management for gui's that do that
  - added parsing of 'searchmoves' token, which should fix 'nextbest move' if your gui does that

2016-07-17: "Gradually relax the NMP staticEval check"
  - linux version is in the works
  - fixed bug in KRPPKRP endgames: case was mis-evaluated
  - fixed bug in easy move
  - remove dependancy on msvcrt.dll
    - resulting malloc/free in TablebaseCore.asm is a hack and will be updated in future
  - +1% implementation speed from better register useage and code arrangement in Evaluate function
  - added current move info in infinite search

2016-07-04: "Use staticEval in null prune condition"
  - fixed bug in 2016-07-02 where castling data was not copied: pointed out by Lyudmil Antonov
  - specified 1000000 byte stack reserve size in the exe
    - previous default of 64K was rounded up to 1M on >=win7 but was only rounded up to 64K on winXP
    - each recusive call to search requires 2800 bytes, so 64K is only enough for a few plies
    - threads are created with 100000 byte stack commited size which is enough for ~30 plies
  - added command line parsing
    - after the exe on the command line, put uci commands separated by ';' character
      - this doesn't work well with multiple sygyzy paths; not sure what other character is acceptable
    - behaviour is not one-shot, so put quit at the end if you want to quit
    - the following all work in Build Tester 1.4.6.0
      - bench; quit
      - bench depth 16 hash 64 threads 2; quit
      - perft 7; quit
      - position startpos moves e2e4; perft 7; quit
    - be aware that commands other than perft and bench do not wait for threads to finish
  - it seems that movegen/movedo lost a little bit of speed in single-threaded perft from numa awareness

2016-07-02:
  - add numa awareness
    - each numa node gets its own cmh table
    - see function ThreadIdxToNode in Thread.asm for thread to node allocation
    - code should also work on older windows systems with out the numa functions
    - this code is currently untested on numa systems
  - fixed bug in wdl tablebase filtering: pointed out by ma laoshi
  - added debug compile 
  - added hard exits when a critical OS function fails
  - created threads get 0.5 MB of commited stack space to combat a strange bug in XP

2016-06-25:
  - attempt to make asmFish functionally identical to c++ masterFish without piecelists
    - castling is now encoded as kingXrook
    - double pawn moves now do not have a special encoding, which affects IsPseudoLegal function
    - if piece lists were always sorted from low to high in master, then we have asmFish
    - there are three other places with VERY minor functional changes, only affecting evaluation
  - syzygy path now has no length limit
  - fix crash when thinking about a position that is mate
  - fix numerous bugs in tablebase probing code
  - fix bug in Move_Do: condition for faster update of checkersBB is working now
  - fix bugs in KNPKB and KRPKR endgames: some cases were mis-evaluated
  - fix bug in pliesFromNull: this was previously allocated only one byte of storage, which is not enough
  - fix bug in draw by 50 moves rule
  - fix bug in see: castling moves now return 0
  - prefetch main hash entry in Move_DoNull
    - according to my testing on 16, 64, and 256 MB hash sizes, prefetching has little speed effect
    - of course, pawn and material entries are still NOT prefetched
  - drop support for xboard protocol
  - tested (+6,-2,=42) against June 21 chess.ultimaiq.net/stockfish.html master
    - conditions: (tc=1min+1sec,hash=128mb,tb=5men,ponder=on,threads=1) in Arena 3.5.1

2016-06-16:
  - first stable release
