
Position_SetState:
	; in:  rbp  address of Pos
	; set information in state struct

	       push   rbx rsi rdi r12 r13 r14 r15
		sub   rsp, 64
		mov   rbx, qword[rbp+Pos.state]

		mov   rax, qword[Zobrist_side]
		mov   r15d, dword[rbp+Pos.sideToMove]
	      movzx   ecx, byte[rbx+State.epSquare]
	      movzx   edx, byte[rbx+State.castlingRights]
		neg   r15
		and   r15, qword[Zobrist_side]
		xor   r15, qword[Zobrist_Castling+8*rdx]
		cmp   ecx, 64
		jae   @f
		and   ecx, 7
		xor   r15, qword[Zobrist_Ep+8*rcx]
		@@:

		mov   r14, [Zobrist_noPawns]
		xor   r13, r13

	     _vpxor   xmm0, xmm0, xmm0	; npMaterial
	   _vmovdqa   dqword[rsp], xmm0

		xor   esi, esi
.NextSquare:
	      movzx   eax, byte[rbp+Pos.board+rsi]
		mov   edx, eax
		and   edx, 7	; edx = piece type
		 jz   .Empty

	       imul   ecx, eax, 64*8
	     _vmovq   xmm1, qword[Scores_Pieces+rcx+8*rsi]
	    _vpaddd   xmm0, xmm0, xmm1

		xor   r15, qword[Zobrist_Pieces+rcx+8*rsi]
		cmp   edx, Pawn
		jne   @f
		xor   r14, qword[Zobrist_Pieces+rcx+8*rsi]
	 @@:
	      movzx   edx, byte [rsp+rax]
		xor   r13, qword[Zobrist_Pieces+rcx+8*rdx]
		add   edx, 1
		mov   byte [rsp+rax], dl
.Empty:
		add   esi, 1
		cmp   esi, 64
		 jb   .NextSquare

		mov   qword[rbx+State.key], r15
		mov   qword[rbx+State.pawnKey], r14
		mov   qword[rbx+State.materialKey], r13
	     _vmovq   qword[rbx+State.psq], xmm0

		mov   ecx, dword [rbp+Pos.sideToMove]
		mov   rdx, qword [rbp+Pos.typeBB+8*King]
		and   rdx, qword [rbp+Pos.typeBB+8*rcx]
		bsf   rdx, rdx
	       call   AttackersTo_Side
		mov   qword[rbx+State.checkersBB], rax

	       call   SetCheckInfo

		add   rsp, 64
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

Position_SetPieceLists:
	; in: rbp Position
	; out: set index, pieceCount, pieceList members in some fixed order
	       push   rbx rsi rdi

	; fill indices with invalid index 0
		lea   rdi, [rbp+Pos.pieceIdx]
		xor   eax, eax
		mov   ecx, 64
	  rep stosb

	; fill piece counts with indices indicating no pieces on the board
iterate c, White, Black
		mov   byte[rbp+Pos.pieceEnd+(8*c+0)]	 , 0
		mov   byte[rbp+Pos.pieceEnd+(8*c+1)]	 , 0
		mov   byte[rbp+Pos.pieceEnd+(8*c+Pawn)]  , 16*(8*c+Pawn)
		mov   byte[rbp+Pos.pieceEnd+(8*c+Knight)], 16*(8*c+Knight)
		mov   byte[rbp+Pos.pieceEnd+(8*c+Bishop)], 16*(8*c+Bishop)
		mov   byte[rbp+Pos.pieceEnd+(8*c+Rook)]  , 16*(8*c+Rook)
		mov   byte[rbp+Pos.pieceEnd+(8*c+Queen)] , 16*(8*c+Queen)
		mov   byte[rbp+Pos.pieceEnd+(8*c+King)]  , 16*(8*c+King)
end iterate

	; fill piece lists with SQ_NONE
		lea   rdi, [rbp+Pos.pieceList]
		mov   eax, 64
		mov   ecx, 16*16
	  rep stosb

	; the order is A8 to H8, then A7 to H7, ect
		xor   esi, esi
.NextSquare:
		xor   esi, 56
	      movzx   eax, byte[rbp+Pos.board+rsi]
	       test   eax, eax
		 jz   .skip
	      movzx   ecx, byte[rbp+Pos.pieceEnd+rax]
		mov   byte[rbp+Pos.pieceIdx+rsi], cl
		mov   byte[rbp+Pos.pieceList+rcx], sil
		add   ecx, 1
		mov   byte[rbp+Pos.pieceEnd+rax], cl
.skip:
		xor   esi, 56
		add   esi, 1
		cmp   esi, 64
		 jb   .NextSquare
.Done:

		pop   rdi rsi rbx
		ret


if DEBUG
Position_VerifyState:
	; in:  rbp  address of Pos
	; out: eax =  0 if incrementally updated information is correct
	;      eax = -1 if not

	       push   rbx rsi rdi r12 r13 r14 r15
		sub   rsp, 64
		mov   rbx, qword[rbp+Pos.state]

		mov   rax, qword[Zobrist_side]
		mov   r15d, dword[rbp+Pos.sideToMove]
	      movzx   ecx, byte[rbx+State.epSquare]
	      movzx   edx, byte[rbx+State.castlingRights]
		neg   r15
		and   r15, qword[Zobrist_side]
		xor   r15, qword[Zobrist_Castling+8*rdx]
		cmp   ecx, 64
		jae   @f
		and   ecx, 7
		xor   r15, qword[Zobrist_Ep+8*rcx]
	@@:

		mov   r14, [Zobrist_noPawns]
		xor   r13, r13

	     _vpxor   xmm0, xmm0, xmm0	; npMaterial
	   _vmovdqu   dqword[rsp], xmm0

		xor   esi, esi
.NextSquare:
	      movzx   eax, byte[rbp+Pos.board+rsi]
		mov   edx, eax
		and   edx, 7	; edx = piece type
		 jz   .Empty

	       imul   ecx, eax, 64*8
	     _vmovq   xmm1, qword[Scores_Pieces+rcx+8*rsi]
	    _vpaddd   xmm0, xmm0, xmm1

		xor   r15, qword[Zobrist_Pieces+rcx+8*rsi]
		cmp   edx, Pawn
		jne   @f
		xor   r14, qword[Zobrist_Pieces+rcx+8*rsi]
	 @@:
	      movzx   edx, byte [rsp+rax]
		xor   r13, qword[Zobrist_Pieces+rcx+8*rdx]
		add   edx, 1
		mov   byte[rsp+rax], dl
.Empty:
		add   esi, 1
		cmp   esi, 64
		 jb   .NextSquare

		cmp   qword[rbx+State.key], r15
		jne   .Failed
		cmp   qword[rbx+State.pawnKey], r14
		jne   .Failed
		cmp   qword[rbx+State.materialKey], r13
		jne   .Failed
	     _vmovq   rax, xmm0
		cmp   qword[rbx+State.psq], rax
		jne   .Failed

		mov   ecx, dword[rbp+Pos.sideToMove]
		mov   rdx, qword[rbp+Pos.typeBB+8*King]
		and   rdx, qword[rbp+Pos.typeBB+8*rcx]
		bsf   rdx, rdx
	       call   AttackersTo_Side
		cmp   qword[rbx+State.checkersBB], rax
		jne   .Failed

		 or   eax,-1
		add   rsp, 64
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

.Failed:
		xor   eax, eax
		add   rsp, 64
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

Position_VerifyPieceLists:
	; in:  rbp  address of Pos
	; out: eax =  0 if piece lists match bitboards, which are assumed to be correct
	;      eax = -1 if not
	       push   rbx rsi rdi
		 or   ebx, -1
.NextType:
		add   ebx, 1
		cmp   ebx, 16
		jae   .Done
	; ebx is the piece
		mov   esi, ebx
		mov   edi, ebx
		and   esi, 8
		and   edi, 7
		cmp   edi, Pawn
		 jb   .NextType

	; r15 is the bitboard we are trying to represent in the piece list
		mov   r8, qword[rbp+Pos.typeBB+rsi]
		and   r8, qword[rbp+Pos.typeBB+8*rdi]

	; esi is the index of the piece in the piece list
	       imul   esi, ebx, 16
    .NextPiece:
	; eax is the square of piece ebx
	      movzx   eax, byte[rbp+Pos.pieceList+rsi]
		cmp   eax, 64
		 je   .NextPieceDone
	; we shouldn't have more pieces in the list than on the board
		 bt   r8, rax
		jnc   .Failed
	; of course the piece should be on square eax
		cmp   bl, byte[rbp+Pos.board+rax]
		jne   .Failed
	; index should match
		cmp   sil, byte[rbp+Pos.pieceIdx+rax]
		jne   .Failed
	; mark the piece as checked
		btr   r8, rax
		add   esi, 1
		jmp   .NextPiece
    .NextPieceDone:
	; we shouldn't have more pieces on the board than in the list
	       test   r8, r8
		jnz   .Failed
	; the index of the terminator should match pieceEnd
		cmp   sil, byte[rbp+Pos.pieceEnd+rbx]
		jne   .Failed
		jmp   .NextType
.Done:
		 or   eax, -1
		pop   rdi rsi rbx
		ret

.Failed:
		xor   eax, eax
		pop   rdi rsi rbx
		ret

end if




Position_IsLegal:
	; in: rbp position
	; out: eax =  0 if position is legal more checks are performed with DEBUG
	;      eax = -1 if position is illegal
	;      rdx address of string

	       push   rbx rdi

	; pieces should not intersect
		mov   rax, qword[rbp+Pos.typeBB+8*White]
		mov   rcx, qword[rbp+Pos.typeBB+8*Black]
	       test   rax, rcx
		jnz   .Failed

	; at most 16 of each type
	    _popcnt   rax, rax, r8
		cmp   eax, 17
		jae   .Failed
	    _popcnt   rcx, rcx, r8
		cmp   ecx, 17
		jae   .Failed

	; at most 2 checkers
		mov   rbx, qword[rbp+Pos.state]
	    _popcnt   rax, qword[rbx+State.checkersBB], r8
		cmp   eax, 3
		jae   .Failed

.VerifyKings:
		mov   rax, qword[rbp+Pos.typeBB+8*White]
		and   rax, qword[rbp+Pos.typeBB+8*King]
	    _popcnt   rax, rax, r8
		cmp   eax, 1
		jne   .Failed
		mov   rax, qword[rbp+Pos.typeBB+8*Black]
		and   rax, qword[rbp+Pos.typeBB+8*King]
	    _popcnt   rax, rax, r8
		cmp   eax, 1
		jne   .Failed

.VerifyPawns:
		mov   rax, 0xFF000000000000FF
	       test   rax, qword[rbp+Pos.typeBB+8*Pawn]
		jnz   .Failed

.VerifyPieces:
		mov   rcx, qword[rbp+Pos.typeBB+8*White]
		mov   r9, rcx
		and   rcx, qword[rbp+Pos.typeBB+8*King]
	    _popcnt   rdx, r9, r8
iterate p, Pawn, Knight, Bishop, Rook, Queen
		mov   rax, qword[rbp+Pos.typeBB+8*p]
		and   rax, r9
		 or   rcx, rax
	    _popcnt   rax, rax, r8
		sub   edx, eax
end iterate
		sub   edx, 1
		jnz   .Failed
		cmp   rcx, r9
		jne   .Failed


		mov   rcx, qword[rbp+Pos.typeBB+8*Black]
		mov   r9, rcx
		and   rcx, qword[rbp+Pos.typeBB+8*King]
	    _popcnt   rdx, r9, r8
iterate p, Pawn, Knight, Bishop, Rook, Queen
		mov   rax, qword[rbp+Pos.typeBB+8*p]
		and   rax, r9
		 or   rcx, rax
	    _popcnt   rax, rax, r8
		sub   edx, eax
end iterate
		sub   edx, 1
		jnz   .Failed
		cmp   rcx, r9
		jne   .Failed


		xor   edx, edx
.VerifyBoard:
	      movzx   eax, byte[rbp+Pos.board+rdx]
	       test   eax, eax
		 jz   .empty
		cmp   eax, 16
		jae   .Failed
		mov   ecx, eax
		and   eax, 7
		 jz   .Failed
		cmp   eax, 1
		 je   .Failed
		and   ecx, 8
		mov   r8, qword[rbp+Pos.typeBB+8*rax]
		and   r8, qword[rbp+Pos.typeBB+rcx]
		 bt   r8, rdx
		jnc   .Failed
		jmp   .next
.empty:
		mov   r8, qword[rbp+Pos.typeBB+8*0]
		 or   r8, qword[rbp+Pos.typeBB+8*1]
		 or   r8, qword[rbp+Pos.typeBB+8*2]
		 or   r8, qword[rbp+Pos.typeBB+8*3]
		 or   r8, qword[rbp+Pos.typeBB+8*4]
		 or   r8, qword[rbp+Pos.typeBB+8*5]
		 or   r8, qword[rbp+Pos.typeBB+8*6]
		 or   r8, qword[rbp+Pos.typeBB+8*7]
		 bt   r8, rdx
		 jc   .Failed
.next:
		add   edx, 1
		cmp   edx, 64
		 jb   .VerifyBoard

.VerifyEp:
	      movzx   ecx, byte [rbx+State.epSquare]
		cmp   ecx, 64
		jae   .VerifyEpDone
		mov   rax, Rank3BB+Rank6BB
		 bt   rax, rcx
		jnc  .Failed
	; make sure square behind ep square is empty
	      movzx   eax, byte[rbp+Pos.sideToMove]
		xor   eax, 1
		mov   rdx, qword[rbp+Pos.typeBB+8*rax]
		shl   eax, 4
		lea   eax, [rax+rcx-8]
		 bt   qword[rbp+Pos.typeBB+8*Black], rax
		 jc   .Failed
		 bt   qword[rbp+Pos.typeBB+8*White], rax
		 jc   .Failed
	; and square in front is occupied by one of their pawns
	      movzx   eax, byte[rbp+Pos.sideToMove]
		and   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		shl   eax, 4
		lea   eax, [rax+rcx-8]
		 bt   rdx, rax
		jnc   .Failed
	; and opposing pawn can capture ep square
	      movzx   eax, byte[rbp+Pos.sideToMove]
		mov   rdx, qword[rbp+Pos.typeBB+8*rax]
		and   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		xor   eax, 1
		shl   eax, 6+3
	       test   rdx, qword[WhitePawnAttacks+rax+8*rcx]
		 jz   .Failed
.VerifyEpDone:


.VerifyKingCapture:
	; make sure we can't capture their king
	      movzx   ecx, byte[rbp+Pos.sideToMove]
		xor   ecx, 1
		mov   rdx, qword[rbp+Pos.typeBB+8*King]
		and   rdx, qword[rbp+Pos.typeBB+8*rcx]
		bsf   rdx, rdx
	       call   AttackersTo_Side
	       test   rax, rax
		jnz   .Failed

if DEBUG
	; make sure the state matches
	       call   Position_VerifyState
	       test   eax, eax
		jz   .Failed

	; make sure piece lists are ok
	       call   Position_VerifyPieceLists
	       test   eax, eax
		 jz   .Failed
end if

		xor   eax, eax
		pop   rdi rbx
		ret
.Failed:
		 or   eax, -1
		pop   rdi rbx
		ret




;;;;;;;;;;;;;; fen ;;;;;;;;;;;;;;;;;;

if VERBOSE>0
Position_Print:  ; in: rbp address of Pos
		 ; io: rdi string

	       push   rbx rsi r13 r14 r15
virtual at rsp
  .moveList    rb sizeof.ExtMove*MAX_MOVES
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		mov   rbx, [rbp+Pos.state]

		xor   ecx, ecx
	@@:
                xor   ecx, 56
	      movzx   eax, byte[rbp+Pos.board+rcx]
		mov   edx, '  ' + (10 shl 16)
		mov   dl, byte[PieceToChar+rax]
		mov   eax, '* ' + (10 shl 16)
		cmp   cl, byte[rbx+State.epSquare]
	     cmovne   eax, edx
	      stosd
		xor   ecx, 56
		lea   eax, [rcx+1]
		and   eax, 7
		neg   eax
		sbb   rdi, 1
		add   ecx, 1
		cmp   ecx, 64
		 jb   @b

	     szcall   PrintString, 'white:     '
		mov   rcx, qword[rbp+Pos.typeBB+8*0]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'black:     '
		mov   rcx, qword[rbp+Pos.typeBB+8*1]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'pawn:      '
		mov   rcx, qword[rbp+Pos.typeBB+8*2]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'knight:    '
		mov   rcx, qword[rbp+Pos.typeBB+8*3]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'bishop:    '
		mov   rcx, qword[rbp+Pos.typeBB+8*4]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'rook:      '
		mov   rcx, qword[rbp+Pos.typeBB+8*5]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'queen:     '
		mov   rcx, qword[rbp+Pos.typeBB+8*6]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'king:      '
		mov   rcx, qword[rbp+Pos.typeBB+8*7]
	       call   PrintBitboardCompact
       PrintNewLine

	     szcall   PrintString, 'pieceIdx:  '
		xor   esi, esi
       .l1:
               test   esi, 7
		jnz  @f
       PrintNewLine
		mov   eax, '    '
	      stosd
	@@:	xor   esi, 56
		lea   rax, [rdi+6]
	       push   rax
	      movzx   eax, byte[rbp+Pos.pieceIdx+rsi]
		shr   eax, 4
	       call   PrintUnsignedInteger
		mov   al, '.'
	       stosb
	      movzx   eax, byte[rbp+Pos.pieceIdx+rsi]
		and   eax, 15
	       call   PrintUnsignedInteger
		pop   rcx
		sub   rcx, rdi
		mov   al, ' '
	  rep stosb
		xor   esi, 56
		add   esi, 1
		cmp   esi, 64
		 jb   .l1
       PrintNewLine

	     szcall   PrintString, 'pieceEnd:  '
		xor   esi, esi
       .l2:
               test   esi, 7
		jnz   @f
       PrintNewLine
		mov   eax, '    '
	      stosd
	   @@:
                lea   rax, [rdi+6]
	       push   rax
	      movzx   eax, byte[rbp+Pos.pieceEnd+rsi]
		shr   eax, 4
	       call   PrintUnsignedInteger
		mov   al, '.'
	       stosb
	      movzx   eax, byte[rbp+Pos.pieceEnd+rsi]
		and   eax, 15
	       call   PrintUnsignedInteger
		pop   rcx
		sub   rcx, rdi
		mov   al, ' '
	  rep stosb
		add   esi, 1
		cmp   esi, 16
		 jb   .l2
       PrintNewLine

	     szcall   PrintString, 'pieceList: '
		xor   esi, esi
       .l3:    
              test   esi, 15
		jnz   @f
       PrintNewLine
		mov   eax, '    '
	      stosd
	   @@:	
                lea   rax, [rdi+3]
	       push   rax
	      movzx   ecx, byte[rbp+Pos.pieceList+rsi]
	       call   PrintSquare
		pop   rcx
		sub   rcx, rdi
		mov   al, ' '
	  rep stosb
		add   esi, 1
		cmp   esi, 16*16
		 jb   .l3
       PrintNewLine



	     szcall   PrintString, 'checkers:  '
		mov   rcx, qword[rbx+State.checkersBB]
	       call   PrintBitboardCompact
       PrintNewLine
	     szcall   PrintString, 'pinned:    '

		mov   rcx, qword[rbx+State.pinned]
	       call   PrintBitboardCompact
       PrintNewLine


	     szcall   PrintString, 'fen:            '
	       call   Position_PrintFen
       PrintNewLine

	     szcall   PrintString, 'isok:           '
	       call   Position_IsLegal
	       test   eax, eax
		mov   eax, 'yes' + (10 shl 24)
		mov   ecx, 'no ' + (10 shl 24)
	     cmovnz   eax, ecx
	      stosd

	     szcall   PrintString, 'sideToMove:     '
		mov   eax, dword[rbp+Pos.sideToMove]
		sub   eax, 1
		and   eax, 'w' - 'b'
		add   eax, 'b'
	      stosb
       PrintNewLine

	     szcall   PrintString, 'castlingRights: '
	      movzx   ecx, byte[rbx+State.castlingRights]
		mov   byte[rdi], '-'
		cmp   ecx, 1
		adc   rdi, 0
		mov   eax, 'KQkq'
		mov   edx, dword[rbp-Thread.rootPos+Thread.castling_rfrom]
		and   edx, 0x07070707
		add   edx, 'AAaa'
		cmp   byte[rbp+Pos.chess960], 0
	     cmovne   eax, edx
iterate i, 0, 1, 2, 3
		mov   byte[rdi], al
		shr   eax, 8
		 bt   ecx, i
		adc   rdi, 0
end iterate
       PrintNewLine

	     szcall   PrintString, 'epSquare:       '
	      movzx   ecx, byte[rbx+State.epSquare]
	       call   PrintSquare
       PrintNewLine

	     szcall   PrintString, 'rule50:         '
	      movzx   rax, word[rbx+State.rule50]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'pliesFromNull:  '
	      movzx   rax, word[rbx+State.pliesFromNull]
	       call   PrintUnsignedInteger
       PrintNewLine

	     szcall   PrintString, 'capturedPiece:  '
	      movzx   eax, byte[rbx+State.capturedPiece]
		mov   al, byte[PieceToChar+rax]
	      stosb
       PrintNewLine

	     szcall   PrintString, 'key:            '
		mov   rcx, qword[rbx+State.key]
	       call   PrintHex
       PrintNewLine

	     szcall   PrintString, 'pawnKey:        '
		mov   rcx, qword[rbx+State.pawnKey]
	       call   PrintHex
       PrintNewLine

	     szcall   PrintString, 'materialKey:    '
		mov   rcx, qword[rbx+State.materialKey]
	       call   PrintHex
       PrintNewLine

	     szcall   PrintString, 'psq:            '
		mov   eax, 'mg: '
	      stosd
		mov   eax, dword[rbx+State.psq]
		add   eax, 0x08000
		sar   eax, 16
	     movsxd   rax, eax
	       call   PrintSignedInteger
		mov   ax, '  '
	      stosw
		mov   eax, 'eg: '
	      stosd
	      movsx   rax, word[rbx+State.psq+2*0]
	       call   PrintSignedInteger
       PrintNewLine

	     szcall   PrintString, 'npMaterial:     '
		mov   eax,'w: '
	      stosd
		sub   rdi, 1
	      movsx   rax, word[rbx+State.npMaterial+2*0]
	       call   PrintSignedInteger
		mov   eax, ' b: '
	      stosb
	      stosd
	      movsx   rax, word[rbx+State.npMaterial+2*1]
	       call   PrintSignedInteger
       PrintNewLine


	     szcall   PrintString, 'Gen_Legal:      '
		mov   r15, rdi
		mov   rbx, qword[rbp+Pos.state]
		lea   rdi, [.moveList]
	       call   Gen_Legal
		xor   eax, eax
		mov   qword[rdi], rax
		mov   rdi, r15
		lea   rsi, [.moveList]
		xor   r14d, r14d
.MoveList:
		mov   eax, dword[rsi]
		add   rsi, sizeof.ExtMove
		mov   ecx, eax
		mov   edx, dword[rbp+Pos.chess960]
	       test   eax, eax
		 jz   .MoveListDone
	       call   PrintUciMove
		add   r14d, 1
		and   r14d, 7
		 jz   .MoveListNL
		mov   al, ' '
	      stosb
		jmp   .MoveList
.MoveListNL:
		mov   al, 10
	      stosb
		mov   rax,'        '
	      stosq
	      stosq
		jmp   .MoveList
.MoveListDone:

		mov   al, 10
	      stosb

		add   rsp, .localsize
		pop   r15 r14 r13 rsi rbx
		ret
end if




if DEBUG > 0
Position_PrintSmall:
	; in: rbp address of Pos
	; io: rdi string
           push  rbx rsi r13 r14 r15
            mov  rbx, qword[rbp+Pos.state]
            mov  rax, 'side:   '
          stosq
            mov  eax, dword[rbp+Pos.sideToMove]
           call  PrintUnsignedInteger
            mov  al, 10
          stosb
            xor  ecx, ecx
	@1:
            xor  ecx, 0111000b
          movzx  eax, byte[rbp+Pos.board+rcx]
            mov  edx, '  ' + (10 shl 16)
            mov  dl, byte[PieceToChar+rax]
            mov  eax, '* ' + (10 shl 16)
            cmp  cl, byte[rbx+State.epSquare]
         cmovne  eax, edx
          stosd
            xor  ecx, 0111000b
            lea  eax, [rcx+1]
            and  eax, 7
            neg  eax
            sbb  rdi, 1
            add  ecx, 1
            cmp  ecx, 64
             jb  @1b
            pop  r15 r14 r13 rsi rbx
            ret
end if


;;;;;;;;;;;;;;;
;  fen
;;;;;;;;;;;;;;;

Position_ParseFEN:
    ; in: rsi address of fen string
    ;     rbp address of Pos
    ;     ecx isChess960
    ; out: eax = 0 success
    ;      eax = -1 failure

           push   rbp rbx rdi r12 r13 r14 r15
            mov   r12d, ecx

            mov   rbx, qword[rbp+Pos.stateTable]
           test   rbx, rbx
             jz   .alloc
.alloc_ret:
            xor   eax, eax
            mov   ecx, Pos._copy_size/8
            mov   rdi, rbp
      rep stosq
            mov   dword[rbp+Pos.chess960], r12d

            xor   eax, eax
            mov   ecx, sizeof.State/8
            mov   rdi, rbx
      rep stosq

            xor   eax, eax
            mov   ecx, Thread.castling_end-Thread.castling_start
            lea   rdi, [rbp-Thread.rootPos+Thread.castling_start]
      rep stosb

            mov   qword[rbp+Pos.state], rbx

           call   SkipSpaces
            xor   eax,eax
            xor   ecx,ecx
            jmp   .ExpectPiece

.ExpectPieceOrSlash:
           test   ecx,7
            jnz   .ExpectPiece
          lodsb
            cmp   al, '/'
            jne   .Failed
.ExpectPiece:
           lodsb

		mov   edx, 8*White+Pawn
		cmp   al, 'P'
		 je   .FoundPiece
		mov   edx, 8*White+Knight
		cmp   al, 'N'
		 je   .FoundPiece
		mov   edx, 8*White+Bishop
		cmp   al, 'B'
		 je   .FoundPiece
		mov   edx, 8*White+Rook
		cmp   al, 'R'
		 je   .FoundPiece
		mov   edx, 8*White+Queen
		cmp   al, 'Q'
		 je   .FoundPiece
		mov   edx, 8*White+King
		cmp   al, 'K'
		 je   .FoundPiece

		mov   edx, 8*Black+Pawn
		cmp   al, 'p'
		 je   .FoundPiece
		mov   edx, 8*Black+Knight
		cmp   al, 'n'
		 je   .FoundPiece
		mov   edx, 8*Black+Bishop
		cmp   al, 'b'
		 je   .FoundPiece
		mov   edx, 8*Black+Rook
		cmp   al, 'r'
		 je   .FoundPiece
		mov   edx, 8*Black+Queen
		cmp   al, 'q'
		 je   .FoundPiece
		mov   edx, 8*Black+King
		cmp   al, 'k'
		 je   .FoundPiece

		sub   eax, '0'
		 js   .Failed
		cmp   eax, 8
		 ja   .Failed
.Spaces:
		add   ecx, eax
		jmp   .PieceDone

.FoundPiece:
		xor   ecx, 0111000b
		mov   edi, edx
		and   edi, 7
		bts   qword[rbp+Pos.typeBB+8*rdi], rcx
		mov   edi, edx
		shr   edi, 3
		bts   qword[rbp+Pos.typeBB+8*rdi], rcx
		mov   byte[rbp+Pos.board+rcx], dl
		xor   ecx, 0111000b
		add   ecx, 1
.PieceDone:
		cmp   ecx, 64
		 jb   .ExpectPieceOrSlash

.Turn:
	       call   SkipSpaces
	      lodsb
		xor   ecx, ecx
		cmp   al, 'b'
	       sete   cl
		mov   dword[rbp+Pos.sideToMove], ecx
      .Castling:
	       call   SkipSpaces
		xor   eax, eax
	      lodsb
		cmp   al, '-'
		 je   .EpSquare
.NextCastlingChar:
		mov   edx, 1
		mov   ecx, eax
		sub   eax, 'A'
		cmp   eax, 'Z'-'A' + 1
		jae   .Lower
		add   ecx, ('a'-'A')
		sub   edx, 1
	.Lower:
	       call   SetCastlingRights
	       test   eax, eax
		jnz   .Failed
		xor   eax, eax
	      lodsb
		cmp   al, ' '
		jne   .NextCastlingChar


 ;   4) En passant target square (in algebraic notation). If there's no en passant
 ;      target square, this is "-". If a pawn has just made a 2-square move, this
 ;      is the position "behind" the pawn. This is recorded only if there is a pawn
 ;      in position to make an en passant capture, and if there really is a pawn
 ;      that might have advanced two squares.
.EpSquare:
	       call   SkipSpaces
	       call   ParseSquare
		mov   byte[rbx+State.epSquare], al
		cmp   eax, 64
		 je   .FiftyMoves
		 ja   .Failed

		mov   edx, dword[rbp+Pos.sideToMove]
		mov   r9, qword[rbp+Pos.typeBB+8*rdx]	; r9 = our pieces
		xor   edx, 1

	; make sure ep square is on our 6th rank
		lea   ecx, [RANK_3+(RANK_6-RANK_3)*rdx]
		 bt   qword[RankBB+8*rcx], rax
		jnc   .EpSquareBad

	; make sure ep square and square above is empty
		mov   r8, qword[rbp+Pos.typeBB+8*rdx]
		mov   r10, r8				; r10 = their pieces
		 or   r8, r9
		 bt   r8, rax
		 jc   .EpSquareBad
		lea   ecx, [8*rdx-4]
		lea   rcx, [rax+2*rcx]
		 bt   r8, rcx
		 jc   .EpSquareBad

	; make sure our pawn is in position to attack ep square
		mov   ecx, edx
		shl   ecx, 6+3
		and   r9, qword[rbp+Pos.typeBB+8*Pawn]
	       test   r9, qword[PawnAttacks+rcx+8*rax]
		 jz   .EpSquareBad    

	; make sure square below has their pawn
		and   r10, qword[rbp+Pos.typeBB+8*Pawn]
		xor   edx, 1
		lea   ecx, [8*rdx-4]
		lea   rcx, [rax+2*rcx]
		 bt   r10, rcx
		jnc   .EpSquareBad

		jmp   .FiftyMoves
.EpSquareBad:
	; we can either fail here or set it to SQ_NONE
		mov   byte[rbx+State.epSquare], 64

.FiftyMoves:
           call   SkipSpaces
           call   ParseInteger
            mov   word[rbx+State.rule50], ax

.MoveNumber:
           call   SkipSpaces
           call   ParseInteger
            sub   eax, 1
            adc   eax, 0
            add   eax, eax
            add   eax, dword[rbp+Pos.sideToMove]
            mov   dword[rbp+Pos.gamePly], eax

           call   Position_SetState
           call   Position_SetPieceLists
           call   Position_IsLegal
           test   eax,eax
            jnz   .Failed

.done:
            pop   r15 r14 r13 r12 rdi rbx rbp
            ret

.Failed:
             or   eax, -1
            jmp   .done

.alloc:
            mov   ecx, 64*sizeof.State
            mov   r15d, ecx
           call   Os_VirtualAlloc
            mov   rbx, rax
            mov   qword[rbp+Pos.state], rax
            mov   qword[rbp+Pos.stateTable], rax
            add   rax, r15
            mov   qword[rbp+Pos.stateEnd], rax
            jmp   .alloc_ret





SetCastlingRights:
	; in: edx color
	;     ecx = 'q' for qeenside castling
	;           'k' for kingside castling
	;           'a' through 'h' for file of rook
	;     rbp position
	;     rbx state
	; out eax = 0 if success
	;         = -1 if failed

	       push   rdi rsi r12 r13 r14 rsi

		mov   rdi, qword[rbp+Pos.typeBB+8*King]
		and   rdi, qword[rbp+Pos.typeBB+8*rdx]
		bsf   rdi, rdi
		 jz   .failed
	       imul   esi, edx, 56
		lea   r8d, [8*rdx+Rook]
		add   esi, 7
		 or   r9d, -1
		cmp   cl, 'k'
		 je   .find_rook_sq
		sub   esi, 7
		neg   r9d
		cmp   cl, 'q'
		 je   .find_rook_sq
		sub   ecx, 'a'
		add   esi, ecx
		cmp   ecx, 7
		 ja   .failed

.have_rook_sq:
	; esi = rook from
	; edi = king from
		cmp   r8l, byte[rbp+Pos.board+rsi]
		jne   .failed

	; r14 = 0 if OO, 1 if OOO
		xor   r14, r14
		cmp   esi, edi
		adc   r14, r14

	; r15 = 2*color + r14
		lea   r15, [2*rdx+r14]

	; r8 = rook to
	; r9 = king to
	      movzx   r8d, byte[.rsquare_lookup+r15]
	      movzx   r9d, byte[.ksquare_lookup+r15]

	; set castling rights
	      movzx   eax, byte[rbx+State.castlingRights]
		bts   eax, r15d
		mov   byte[rbx+State.castlingRights], al

	; set masks
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rightsMask+rsi]
		bts   eax, r15d
		mov   byte[rbp-Thread.rootPos+Thread.castling_rightsMask+rsi], al
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rightsMask+rdi]
		bts   eax, r15d
		mov   byte[rbp-Thread.rootPos+Thread.castling_rightsMask+rdi], al

	; set rook from/to
		mov   byte[rbp-Thread.rootPos+Thread.castling_rfrom+r15], sil
		mov   byte[rbp-Thread.rootPos+Thread.castling_rto+r15], r8l

	; set castling path
		lea   r11, [rbp-Thread.rootPos+Thread.castling_ksqpath+8*r15]
		xor   eax, eax
		mov   qword[r11], rax
		mov   r12, rdi
		mov   r13, r9
		cmp   r12, r13
		 jb   @f
	       xchg   r12, r13
	@@:	
                sub   r12, 1
.king_loop:
		add   r12, 1
		cmp   r12, r13
		 ja   .king_loop_done
		cmp   r12, rdi
		 je   .king_loop
		add   byte[rbp-Thread.rootPos+Thread.castling_ksqpath+8*r15], 1
		add   r11, 1
		mov   byte[r11], r12l
		mov   rcx, qword[KnightAttacks+8*r12]
		 or   qword[rbp-Thread.rootPos+Thread.castling_knights+8*r15], rcx
		mov   rcx, qword[KingAttacks+8*r12]
		 or   qword[rbp-Thread.rootPos+Thread.castling_kingpawns+8*r15], rcx
		cmp   r12, rsi
		 je   .king_loop
		bts   rax, r12
		jmp   .king_loop
.king_loop_done:

		mov   r12, rsi
		mov   r13, r8
		cmp   r12, r13
		 jb   @f
	       xchg   r12, r13
	@@:	
                sub   r12, 1
.rook_loop:
		add   r12, 1
		cmp   r12, r13
		 ja   .rook_loop_done
		cmp   r12, rdi
		 je   .rook_loop
		cmp   r12, rsi
		 je   .rook_loop
		bts   rax, r12
		jmp   .rook_loop
.rook_loop_done:

		mov   qword[rbp-Thread.rootPos+Thread.castling_path+8*r15], rax

	; set castling move
		mov   eax, MOVE_TYPE_CASTLE
		shl   eax, 6
		add   eax, edi
		shl   eax, 6
		add   eax, esi
		mov   dword[rbp-Thread.rootPos+Thread.castling_movgen+4*r15], eax

		xor   eax, eax
.done:
		pop   r15 r14 r13 r12 rsi rdi
		ret
.failed:
		 or   eax, -1
		jmp   .done


.find_rook_sq:
		cmp   esi, 64
		jae   .failed
		cmp   r8l, byte[rbp+Pos.board+rsi]
		 je   .have_rook_sq
		add   esi, r9d
		jmp   .find_rook_sq


.rsquare_lookup:  db SQ_F1, SQ_D1, SQ_F8, SQ_D8
.ksquare_lookup:  db SQ_G1, SQ_C1, SQ_G8, SQ_C8



if VERBOSE > 0
Position_PrintFen:
	; in: rbp address of Pos
	; io: rdi string

	       push   rbx
		mov   rbx, qword[rbp+Pos.state]

		mov   r8d, 7
.loop1:
		xor   ecx, ecx

		xor   r9d, r9d
 .loop2:
		lea   r10d, [r9+8*r8]
	      movzx   edx, byte[rbp+Pos.board+r10]
	       test   edx, edx
		 jz   .space

		lea   eax, ['0'+rcx]
	       test   ecx,ecx
		 jz   @f
	      stosb
	@@:
	      movzx   eax, byte[PieceToChar+rdx]
	      stosb

		xor   ecx,ecx

		jmp   .cont
	.space:
		add   ecx,1
	.cont:
		add   r9d,1
		cmp   r9d,8
		 jb   .loop2

		lea   eax, ['0'+rcx]
	       test   ecx, ecx
		 jz   @f
	      stosb
	@@:
		mov   al, '/'
	      stosb

		sub   r8d, 1
		jns   .loop1

	; side to move
		mov   byte[rdi-1], ' '
		mov   eax, 'w '
		mov   ecx, 'b '
		cmp   byte[rbp+Pos.sideToMove], 0
	     cmovne   eax, ecx
	      stosw

	; castling
	      movzx   ecx, byte[rbx+State.castlingRights]
		mov   byte[rdi], '-'
		cmp   ecx, 1
		adc   rdi, 0
		mov   eax, 'KQkq'
		mov   edx, dword[rbp-Thread.rootPos+Thread.castling_rfrom]
		and   edx, 0x07070707
		add   edx, 'AAaa'
		cmp   byte[rbp+Pos.chess960], 0
	     cmovne   eax, edx
iterate i, 0 1 2 3
		mov   byte[rdi], al
		shr   eax, 8
		 bt   ecx, i
		adc   rdi, 0
end iterate

	; ep
		mov   eax, ' '
	      stosb
	      movzx   rcx, byte[rbx+State.epSquare]
	       call   PrintSquare

	; 50 moves
		mov   eax, ' '
	      stosb
	      movzx   eax, word[rbx+State.rule50]
	       call   PrintUnsignedInteger

	; ply
		mov   eax, ' '
	      stosb

		mov   eax, dword[rbp+Pos.gamePly]
		add   eax, 2
		shr   eax, 1
	       call   PrintUnsignedInteger

		pop   rbx
		ret
end if



;;;;;;;;;;;;;;;
;  copying
;;;;;;;;;;;;;;;

Position_CopyTo:
	; rbp address of source position
	; rcx address of destination position
	;  up to Pos._copy_size is copied
	;  and state array is copied

	       push   rbx rsi rdi r13 r14
		mov   r13, rcx

	; copy castling data
		mov   ecx, Thread.castling_end-Thread.castling_start
		lea   rsi, [rbp-Thread.rootPos+Thread.castling_start]
		lea   rdi, [r13-Thread.rootPos+Thread.castling_start]
	  rep movsb

	; copy basic position info
		lea   rsi, [rbp]
		lea   rdi, [r13]
		mov   ecx, Pos._copy_size/8
	  rep movsq

	; rsi = address of our state table
		mov   rsi, qword[rbp+Pos.stateTable]

	; r14 = size of states that need to be copied
		mov   r14, qword[rbp+Pos.state]
		sub   r14, rsi
		add   r14, sizeof.State

	; if destination has no table, we need to alloc
		mov   rdi, qword[r13+Pos.stateTable]
	       test   rdi, rdi
		 jz   .alloc

	; rdx = capacity of states in destination
		mov   rdx, qword[r13+Pos.stateEnd]
		sub   rdx, rdi

	; if rdx < r14, we need to realloc
		cmp   rdx, r14
		 jb   .realloc

.copy_states:
	; copy State elements
		mov   rcx, r14
		shr   ecx, 3
	  rep movsq

	; set pointer to destination state
		sub   rdi, sizeof.State
		mov   qword[r13+Pos.state], rdi

		pop   r14 r13 rdi rsi rbx
		ret

.realloc:
		mov   rcx, rdi
		; rdx already has the size
	       call   Os_VirtualFree
.alloc:
		lea   rcx, [2*r14]
	       call   Os_VirtualAlloc
		mov   rdi, rax
		mov   qword[r13+Pos.stateTable], rax
		lea   rax, [rax+2*r14]
		mov   qword[r13+Pos.stateEnd], rax
		jmp   .copy_states



Position_CopyToSearch:
    ; rbp address of source position
    ; rcx address of destination position
    ;  up to Pos._copy_size is copied
    ;  and state array is copied
    ; enough elements are copied for
    ;   draw by 50 move detection
    ;   referencing ss-5 and ss+2 in search

            push   rsi rdi r13
            mov   r13, rcx

            ; copy castling data
            mov   ecx, Thread.castling_end-Thread.castling_start
            lea   rsi, [rbp-Thread.rootPos+Thread.castling_start]
            lea   rdi, [r13-Thread.rootPos+Thread.castling_start]
            rep movsb

            ; copy basic position info
            lea   rsi, [rbp]
            lea   rdi, [r13]
            mov   ecx, Pos._copy_size/8
            rep movsq

            ; if destination has no table, we need to alloc
            mov   r9, qword[r13+Pos.stateTable]
            test   r9, r9
            jz   .alloc

            ; rcx = capacity of states in destination
            ; if rcx < MAX_PLY+102, we need to realloc
            mov   rdx, qword[r13+Pos.stateEnd]
            sub   rdx, r9
            cmp   rdx, sizeof.State*(100+MAX_PLY+2+MAX_SYZYGY_PLY)
            jb   .realloc
.copy_states:
            ; r9 = address of its state table
            ; r8 = address of our state table
            mov   r8, qword[rbp+Pos.stateTable]

            mov   r10, qword[rbp+Pos.state]
            lea   r11, [r9+100*sizeof.State]
            mov   qword[r13+Pos.state], r11
.looper:
            mov   rsi, r10
            mov   rdi, r11
            mov   ecx, sizeof.State/8
      rep movsq
    ; make sure that pliesFromNull never references a state past the beginning
    ;  we don't want to fall of the cliff when checking 50 move rule
            mov   edx, 100
            movzx   eax, word[r11+State.pliesFromNull]
            cmp   eax, edx
            cmova   eax, edx
            mov   word[r11+State.pliesFromNull], ax

            sub   r10, sizeof.State
            sub   r11, sizeof.State
            cmp   r11, r9
            jb   .done
            cmp   r10, r8
            jae   .looper
.done:
            pop   r13 rdi rsi
            ret

.realloc:
            mov   rcx, r9
            ; rdx already has the size
            call   Os_VirtualFree
.alloc:
            mov   ecx, sizeof.State*(100+MAX_PLY+2+MAX_SYZYGY_PLY)
            call   Os_VirtualAlloc
            mov   r9, rax
            mov   qword[r13+Pos.stateTable], rax
            add   rax, sizeof.State*(100+MAX_PLY+2+MAX_SYZYGY_PLY)
            mov   qword[r13+Pos.stateEnd], rax
            jmp   .copy_states




Position_SetExtraCapacity:
	; in: rbp postion
	; reserve space for at least ecx states past the current

               imul   ecx, sizeof.State
                add   rcx, qword[rbp+Pos.state]
                cmp   rcx, qword[rbp+Pos.stateEnd]
		jae   .realloc
		ret
.realloc:
	       push   rbx rsi rdi
		sub   rcx, qword[rbp+Pos.stateTable]
                mov   eax, ecx
                xor   edx, edx
                mov   ecx, sizeof.State
                div   ecx
                lea   ecx, [rax+8]
                shr   ecx, 2
                add   ecx, eax
               imul   ecx, sizeof.State
		mov   ebx, ecx
	       call   Os_VirtualAlloc
		mov   r8, rax
		lea   r10, [rax+rbx]
		mov   rsi, qword[rbp+Pos.stateTable]
		mov   rdi, r8
		mov   r9, qword[rbp+Pos.state]
		sub   r9, rsi
		add   r9, r8
		mov   rcx, qword[rbp+Pos.stateEnd]
		sub   rcx, rsi
		shr   ecx, 3
	  rep movsq
		mov   rcx, qword[rbp+Pos.stateTable]
		mov   rdx, qword[rbp+Pos.stateEnd]
		sub   rdx, rcx
		mov   rbx, r9
		mov   qword[rbp+Pos.state], r9
		mov   qword[rbp+Pos.stateTable], r8
		mov   qword[rbp+Pos.stateEnd], r10
	       call   Os_VirtualFree
		pop   rdi rsi rbx
		ret

