
eq = 0
ne = 1
hs = 2
lo = 3
mi = 4
pl = 5
vs = 6
vc = 7

// some bitboards
  DarkSquares  = 0xAA55AA55AA55AA55
  LightSquares = 0x55AA55AA55AA55AA
  FileABB   = 0x0101010101010101
  FileBBB   = 0x0202020202020202
  FileCBB   = 0x0404040404040404
  FileDBB   = 0x0808080808080808
  FileEBB   = 0x1010101010101010
  FileFBB   = 0x2020202020202020
  FileGBB   = 0x4040404040404040
  FileHBB   = 0x8080808080808080
  Rank8BB   = 0xFF00000000000000
  Rank7BB   = 0x00FF000000000000
  Rank6BB   = 0x0000FF0000000000
  Rank5BB   = 0x000000FF00000000
  Rank4BB   = 0x00000000FF000000
  Rank3BB   = 0x0000000000FF0000
  Rank2BB   = 0x000000000000FF00
  Rank1BB   = 0x00000000000000FF
  CornersBB = 0b0111111011111111111111111111111111111111111111111111111101111110


White  = 0
Black  = 1
Pawn   = 2
Knight = 3
Bishop = 4
Rook   = 5
Queen  = 6
King   = 7



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
