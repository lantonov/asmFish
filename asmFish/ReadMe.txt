file for each version
assembler from flatassembler.net is included

******** How to use the engine from the command line ********

You can feed in commands to the engine as (";" -> ":" on linux):
        "asmFishW_bmi2" setoption name hash value 256; go depth 5; wait
The engine quits after this if assemble flag USE_CMDLINEQUIT is set. You 
can also interact with the engine as follows.

Besides the usual uci commands there are the following:

show:   (VERBOSE>0) Prints out the internal rep of the position.
moves:  (VERBOSE>0) Makes the succeeding moves then does 'show'.
undo:   (VERBOSE>0) Undoes one or a certain number of moves
donull: (VERBOSE>0) Does a null move.
eval:   (VERBOSE>0) Displays evaluation.
perft:  Usual move generation verification. Use like 'perft 7'.
bench:  Usual bench command. Use like stockfish or the more readable form
        'bench hash 16 threads 1 depth 13 realtime 0'. These are the defaults.
wait:   Waits for the main search thread to finish. Use with caution
        (esp. on an infinite search). This is useful when feeding commands
        via the command line. The command 'wait' can be used after 'go'
        to ensure that engine doesn't quit before finishing.
profile: (PROFILE>0) Displays profile info and then clears it.
brain2polyglot: (BOOK>0) convert cerebellum library book to polyglto format.
        Use like 'brain2polyglot depth 50 in "Cerebellum_light.bin" out "polybook.bin"'


Besides the usual uci options there are the following:

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
Priority:       Try to set the prority of the process. The default is 'none',
                which runs the engine which whichever priority it was started.
TTFile:         Set the location of the file for TTSave and TTLoad.
TTSave:         Saves the current hash table to TTFile.
TTLoad:         Loads the current hash table while possibily changing the size.
SyzygyProbeDepth: Don't probe if plies from root is less than this.
SyzygyProbeLimit: Don't probe if number of board pieces is bigger than this.
Syzygy50MoveRule: Consider 50 move rule when probing.
SyzygyPath:     Path to syzygy tablebases. 
OwnBook:        Lookup position in book if possible.
BookFile:       Loads polyglot book into engine.
BestBookMove:   Use only the best moves from the book.
