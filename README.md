# Introduction
Welcome to the project of translating Stockfish into assembly language. This project
now uses the new assembler engine fasmg from Tomasz Grysztar. The includes in
`arm/includes/` or `x86/include` contain instruction and formatting macros for
the four popular targets in the _Building_ section. The hello world examples in these
directories should provide enough to grasp the syntax.

# Building
All versions of the executables may be built using the fasmg executable. However,
fasmg is currently only available as an x86 executable. It is most important to
set the `include` environment variable before running fasmg on the sources. fasmg
is a generic assembler which relies on the particual flavor of the assembly language
to be supplied by macros. This slows down the processing of the source by a few
orders of magnitute. The `-e 100` switch tells fasmg to display the last 100 errors
when processing the source. The `-i` switch inserts lines at the beginning at the
source. The fish source expect that `VERSION_OS` and `VERSION_POST` are defined this way.
This allows multiple versions to be assembled from the same source. 
## x86-64 Linux
The x86-64 linux version links against nothing and should work with any 64 bit x86 linux kernel.

        export include="x86/include/"
        ./fasmg "x86/fish.asm" "asmfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'"
        chmod 755 ./asmfish

## x86-64 Windows
The x86-64 windows version links against only `kernel32.dll` and should work even on XP.

        set include="x86\include\"
        fasmg.exe "x86\fish.asm" "asmfish" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'"

## x86-64 Mac
The x86-64 macOS version links against `/usr/lib/libSystem.B.dylib`  and works on version 10.12.16.

        export include="x86/include/"
        ./fasmg "x86/fish.asm" "asmfish" -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'"
        chmod 755 ./asmfish

## aarch64 Linux
The aarch64 linux version links against nothing should work with any 64 bit arm linux
kernel. Of course it can currently only be built on x86 machines.

        export include="arm/include/"
        ./fasmg "arm/fish.arm" "armfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'"
        chmod 755 ./armfish

# Using the engine from the command line

You can feed in commands to the engine as (":" -> ";" on windows):

        ./asmfish setoption name hash value 256: go depth 5: wait

The engine quits after this if assemble flag `USE_CMDLINEQUIT=1` is set.
Besides the usual uci commands there are the following:

| | included by default
|---|---
|perft| Usual move generation verification. Use like `perft 7`.
|bench| Usual bench command. Use like stockfish or the more readable form `bench hash 16 threads 1 depth 13`. These are the defaults.
|wait|  Waits for the main search thread to finish. Use with caution (esp. on an infinite search). This is useful when feeding commands via the command line. The command `wait` can be used after `go` to ensure that engine doesn't quit before finishing.

| | `VERBOSE=1` assemble option
|---|---
|show|  Prints out the internal rep of the position.
|moves| Makes the succeeding moves then does 'show'.
|undo|  Undoes one or a certain number of moves
|donull| Does a null move.
|eval|   Displays evaluation.


# Engine options

| | included by default
|---|---
|Priority|       Try to set the priority of the process. The default is 'none', which runs the engine which whichever priority it was started.
|LogFile|        Location to write all communication. Useful for buggy gui's. This option should be currently broken on windows.
|TTFile|         Set the location of the file for TTSave and TTLoad.
|TTSave|         Saves the current hash table to TTFile.
|TTLoad|         Loads the current hash table while possibily changing the size.
|LargePages|     Try to use large pages when allocating the hash. Hash and threads are only allocated when receiving `isready` or `go`.
|NodeAffinity|   The default is "all". Here is the behavior:
```
"all"  pin threads to all nodes your machine in a uniform way
"none"  disable pinning threads to nodes
"0 1 2 3" only use nodes 0, 1, 2 and 3
"2" only use node 2
"0.1 2.3" use nodes 0, 1, 2 and 3
    but node 1 shares per-node memory with node 0
    node 3 shares per-node memory with node 2
"0.1.2.3" use nodes 0, 1, 2 and 3
    but nodes 1, 2 and 3 share per-node memory with node 0
if you want to see the detected cores/nodes in your machine
    run "setoption name NodeAffinity value all"
```

| | `USE_SYZYGY=1` default assemble option
|---|---
|SyzygyProbeDepth| Don't probe if plies from root is less than this.
|SyzygyProbeLimit| Don't probe if number of board pieces is bigger than this.
|Syzygy50MoveRule| Consider 50 move rule when probing.
|SyzygyPath|     Path to syzygy tablebases.


| |`USE_WEAKNESS=1` assembly option
|---|---
|UCI_LimitStrength| make the engine play at certain level
|UCI_Elo|        level at which to play


| | `USE_BOOK=1` assemble option
|---|---
|OwnBook|        Lookup position in book if possible. Ponder moves are also selected from the book when possible
|BookFile|       Loads polyglot book into engine.
|BestBookMove|  Use only the best moves from the book (highest weight)
|bookprobe|     Display book entries from current pos. Use like 'bookprobe 3'.
|BookDepth|     Tricky setting works as follows:
```
BookDepth <= 0:
suppose the lines the book from the current position are
T0:     h2h3(30) c5d4(10) e3d4(14) g4h5(10) g2g4(11) 
        h2h3(30) g4h5(5) 
        d4c5(17) d6c5(17) b1c3(7) 
the moves g2g4(11), g4h5(5) and b1c3(7) are leaves and don't lead
to a position in the book. Triming off these leaves three times,
T1:     h2h3(30) c5d4(10) e3d4(14) g4h5(10)
        d4c5(17) d6c5(17)
T2:     h2h3(30) c5d4(10) e3d4(14)
        d4c5(17)
T3:     h2h3(30) c5d4(10)
If BookDepth = 0, probe as if it were in T0 (unchanged)
If BookDepth =-1, probe as if it were in T1 (leaves off)
If BookDepth =-2, probe as if it were in T2 (trim twice)
If BookDepth =-3, probe as if it were in T3 (trim trice)
So with BookDepth <= -3, the move d4c5 is not considered.
With BookDepth <= -5, the move h2h3 is also not considered.

BookDepth >= 1:
Book is not probed if gameply >= BookDepth
```

# Misbehaviour
If you observe a crash/misbehaviour in asmfish, please raise an issue here
and give the following information:
  - name of the executable that crashed/misbehaved
  - exception code and exception offset in the case of a crash
  - a log of the commands that were sent to asmFish by your gui before the crash
Simply stating that asmFish crashed in your gui is useless information by itself.


asmfish is known to have problems in the fritz15 gui, while it plays much better
in the fritz11 gui.

Windows might throw a "The system cannot execute the specified program." or
"Insufficient system resources exist to complete the requested service.". The
likely source of this problem is your virus software. Rest assured that the
sources here do not produce any behaviour that is even remotely virus-like
(unless you run analysis for a long time with syzygy6 installed).


# FAQ
Q: Why not just start with the compiler output and speed up the critical functions?
   or write critical functions in asm and include them in cpp code?
A: With this approach the critical functions would still need to conform to the
   standards set in place by the ABI. All of the critical functions in asmFish do
   not conform to these standards. Plus, asmFish would be dependent on a compiler
   in this case, which introduces many unnecessary compilcations. Both asmFish
   and its assembler are around 100KB; lets keep it simple. Note that compiler
   output was used in the case of Ronald de Man's syzygy probing code, as this
   is not speed critical but cumbersome to write by hand.

Q: Is asmFish search the same as official stockfish?
A: It does now that PEDANTIC = 1 is the default! The changes previously thought
   to be inconsequential lose about 2 Elo in a head-to-head matchup. The
   functionality when using syzygy is not 100% identical because asmFish uses
   Ronald's original alpha-beta search while official stockfish does not. This
   causes minor inconsequential differences due to the piece lists.
   
Q: Where can I find the executable files of the old versions ?
A: All older versions of asmFish/pedantFish are in the branch
   https://github.com/lantonov/asmFish/tree/executables


# updates
For a change log, see the Wiki https://github.com/lantonov/asmFish/wiki/Change-log

