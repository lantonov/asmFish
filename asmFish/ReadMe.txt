file for each version
assembler from flatassembler.net is included

******** How to use the engine from the command line ********

You can feed in commands to the engine as (";" -> ":" on linux):
        "asmFishW_bmi2" setoption name hash value 256; go depth 5; wait
The engine quits after this if assemble flag USE_CMDLINEQUIT is set. You 
can also interact with the engine as follows.

Besides the usual uci commands there are the following:

        *** included by default ***
perft:          Usual move generation verification. Use like 'perft 7'.
bench:          Usual bench command. Use like stockfish or the more readable form
                'bench hash 16 threads 1 depth 13 realtime 0'. These are the defaults.
wait:           Waits for the main search thread to finish. Use with caution
                (esp. on an infinite search). This is useful when feeding commands
                via the command line. The command 'wait' can be used after 'go'
                to ensure that engine doesn't quit before finishing.

        *** VERBOSE assemble option ***
show:           Prints out the internal rep of the position.
moves:          Makes the succeeding moves then does 'show'.
undo:           Undoes one or a certain number of moves
donull:         Does a null move.
eval:           Displays evaluation.

        *** PROFILE assemble option ***
profile:        Displays profile info and then clears it.

        *** USE_BOOK assemble option ***
bookprobe:      Display book entries from current pos. Use like 'bookprobe 3'.
brain2polyglot: convert cerebellum library book to polyglot format.
                Use like 'brain2polyglot depth 50 in "Cerebellum_light.bin" out "polybook.bin"'


Besides the usual uci options there are the following:

        *** included by default ***
LargePages:     Try to use large pages when allocating the hash. Hash and
                threads are only allocated when receiving 'isready' or 'go'.
NodeAffinity:   The default is "all". Here is the behavior:
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
Priority:       Try to set the priority of the process. The default is 'none',
                which runs the engine which whichever priority it was started.
TTFile:         Set the location of the file for TTSave and TTLoad.
TTSave:         Saves the current hash table to TTFile.
TTLoad:         Loads the current hash table while possibily changing the size.

        *** USE_WEAKNESS assemble option ***
UCI_LimitStrength: make the engine play at certain level
UCI_Elo:        level at which to play

        *** USE_SYZYGY assemble option ***
SyzygyProbeDepth: Don't probe if plies from root is less than this.
SyzygyProbeLimit: Don't probe if number of board pieces is bigger than this.
Syzygy50MoveRule: Consider 50 move rule when probing.
SyzygyPath:     Path to syzygy tablebases.

        *** USE_BOOK assemble option ***
OwnBook:        Lookup position in book if possible. Ponder moves are also selected
                from the book when possible
BookFile:       Loads polyglot book into engine.
BestBookMove:   Use only the best moves from the book (highest weight)
BookDepth:
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
                If BookDepth = 0 the book is probed as if it were in T0 (unchanged)
                If BookDepth =-1 the book is probed as if it were in T1 (leaves off)
                If BookDepth =-2 the book is probed as if it were in T2 (trim twice)
                If BookDepth =-3 the book is probed as if it were in T3 (trim trice)
                So with BookDepth <= -3, the move d4c5 is not considered.
                With BookDepth <= -5, the move h2h3 is also not considered.

                BookDepth >= 1:
                Book is not probed if gameply >= BookDepth
                
                


