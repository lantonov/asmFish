1. about asmFish:
- it is a rewrite of stockfish into x86-64
- assemble aswFish_popcnt.asm, ect. with fasm (www.flatassembler.net)
  - fasm.exe is included in the asmFish directory

2. assembling:
- main source is asmFishW.asm for windows asmFishL.asm for linux
  - source is divided into many files because ordering of these files in asmFish.asm can affect performance
- asmFish is written for haswell with macros used to simulate instructions on lower cpu's
  - even without popcnt, performance only drops a few %
- CPU_HAS_... (most important) indicates available instructions
  - program does a runtime check to see if these really are avaiable
- DEBUG turns on some printing and asserts
- VERBOSE turns on lots of printing and should only be used when searching for bugs
- PEDANTIC turns on piece lists and other tiny differences so that bench matches official stockfish;
    makes asmFish identical to SF master in deterministic searches
- PROFILE turns on several counts of called functions and branches taken

3. extra commands:
- benchmarking
  - perft d	  usual perft to depth d
  - bench	  use like this: 'bench hash 16 threads 1 depth 13'. These are the default settings.
- debuging:
  - moves x..	  makes the moves x.. from the current pos. if illegal move appears in list, parsing stops there
  - show	  displays the current board
  - eval	  displays the output of Evaluate on current position

4. about the code so far:
- there are three kinds of threads
  - the gui thread reads from stdin and uses the th1 and th2 structs on its stack
  - the main search thread
  - n-1 worker threads
- the move generation and picking function have been rewritten
- Piece lists have a slighly more efficient implementation than in master
- the CheckInfo structure has been merged into the State structure
- the SearchStack structure has been merged into the State structure
- the sequence of states is stored as a vector as opposed to a linked list
  - the size of this container should expand and shrink automatically in the gui thread
  - the size of vector of states used in search threads is fixed on thread creation
    - we only need 100+MAX_PLY entries for a search thread
- Move_Do does no prefetching

5. asm notes:
- if you see popcnt with three operands, don't panic, its just a macro that needs a temp for non-popcnt cpu's BasicMacros.asm
- register conventions:
  - follows MS x64 calling convention for the most part
  - uses rdi/rsi for strings were appropriate, rdi for writing to, rsi for reading from
  - rbp is very much used to hold the Pos structure
    - above rbp is the position structure
    - below rbp is the thread struct
    - this register doesn't need to change while a thread is thinking
  - rbx is used to hold the current State structure
  - rsi is generally used in the search function to hold the Pick structure

6. os:
- syzygy uses an adhoc malloc and free
- windows uses only window kernel functions for now

7. notes about fasm:
- mov x, y	is a definition that actually executes in your program (zeroth)
- cmp x, y	is a condition that actually executes in your program (zeroth)
- x = y 	is a definition/condition that is handled by the assembler (first)
- x eq y	is a condition that is handled by the parser (second)
- match =x,y	is a condition that is handled by the preprocessor (third)
- x equ y	is a definition of x that is handled by the preprocessor (third)
- x fix y	is a definition of x that is handled by prepreprocessor (fourth)
