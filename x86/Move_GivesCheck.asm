
	     calign   64
Move_GivesCheck:
	; in:  rbp  address of Pos
	;      rbx  address of State - check info must be filled in
	;      ecx  move assumed to be psuedo legal
	; out: eax =  0 if does not give check
	;      eax = -1 if does give check

;ProfileInc Move_GivesCheck

		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to
		mov   r11, qword[rbx+State.dcCandidates]
	      movzx   r10d, byte[rbp+Pos.board+r8]     ; r10 = FROM PIECE
		and   r10d, 7

		 or   eax, -1

		mov   rdx, qword[rbx+State.checkSq+8*r10]
		 bt   rdx, r9
		 jc   .Ret

		 bt   r11, r8
		 jc   .DiscoveredCheck

		xor   eax, eax
		cmp   ecx, MOVE_TYPE_PROM shl 12
		jae   .Special
.Ret:
		ret

	     calign   8
.Special:
	       push   rsi rdi
.Special.AfterPrologue:
		shr   ecx, 12	; ecx = move type
		mov   esi, dword[rbp+Pos.sideToMove]
	      movzx   edi, byte[rbx+State.ksq]
		mov   rdx, qword[rbp+Pos.typeBB+8*White]
		 or   rdx, qword[rbp+Pos.typeBB+8*Black]
		btr   rdx, r8
		bts   rdx, r9

		mov   eax, dword[.JmpTable+4*(rcx-MOVE_TYPE_PROM)]
		jmp   rax


	     calign   8
.JmpTable:   dd .PromKnight,.PromBishop,.PromRook,.PromQueen
	     dd .EpCapture,0,0,0
	     dd .Castling,0,0,0


	     calign   8
.Castling:
 ;  esi starts as
 ;  esi=0 if we are white
 ;  esi=1 if we are black
 ;  we are supposed to get into esi the following number
 ;  esi=0 if white and O-O
 ;  esi=1 if white and O-O-O
 ;  esi=2 if black and O-O
 ;  esi=3 if black and O-O-O
 ;  r9d contains to square   (square of rook)
 ;  r8d contains from square (square of king)
 ;
 ;  since we assume that only one of the four possible castling moves have been passed in,
 ;  this can be corrected by comparing the rook square to the king square
		cmp   r9d, r8d
		adc   esi, esi

	      movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rfrom+rsi]
	      movzx   r11d, byte[rbp-Thread.rootPos+Thread.castling_rto+rsi]
		btr   rdx, rax
		bts   rdx, r11
		bts   rdx, r9  ; set king again if nec
	RookAttacks   rax, r11, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.PromQueen:
      BishopAttacks   r8, r9, rdx, r10
	RookAttacks   rax, r9, rdx, r10
		 or   rax, r8
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.EpCapture:
		lea   ecx, [2*rsi-1]
		lea   ecx, [r9+8*rcx]
		mov   r8, qword[rbp+Pos.typeBB+8*Bishop]
		mov   r9, qword[rbp+Pos.typeBB+8*Rook]
		btr   rdx, rcx
      BishopAttacks   rax, rdi, rdx, r10
	RookAttacks   r11, rdi, rdx, r10
		mov   r10, qword[rbp+Pos.typeBB+8*Queen]
		 or   r8, r10
		 or   r9, r10
		and   rax, r8
		and   r11, r9
		 or   rax, r11
		and   rax, qword[rbp+Pos.typeBB+8*rsi]
		neg   rax
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.PromBishop:
      BishopAttacks   rax, r9, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.PromRook:
	RookAttacks   rax, r9, rdx, r10
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.PromKnight:
		mov   rax, qword[KnightAttacks+8*r9]
		 bt   rax, rdi
		sbb   eax, eax
		pop   rdi rsi
		ret

	     calign   8
.DiscoveredCheck:
	       push   rsi rdi
	      movzx   edi, byte[rbx+State.ksq]
		mov   eax, ecx
		and   eax, 64*64-1
		mov   rax, qword[LineBB+8*rax]
		 bt   rax, rdi
		 jc  .DiscoveredCheckRet
		 or   eax, -1
		pop   rdi rsi
		ret
.DiscoveredCheckRet:
		xor   eax, eax
		cmp   ecx, MOVE_TYPE_PROM shl 12
		jae   .Special.AfterPrologue
		pop   rdi rsi
		ret
