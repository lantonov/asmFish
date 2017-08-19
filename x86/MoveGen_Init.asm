GoDirection:
	; in: ebx square
	;     cl  x coord
	;     ch  y coord
	; out: eax square ebx + (x,y) or 64 if rbx + (x,y) is off board

	       call   SquareToXY
		add   al, cl
		 js   .Fail
		cmp   al, 8
		jae   .Fail
		add   ah, ch
		 js   .Fail
		cmp   ah, 8
		jae   .Fail
		shl   al, 5
		shr   eax, 5
		ret
     .Fail:	mov   eax, 64
		ret

SquareToXY:
	; in: ebx square
	; out: al  x coord
	;      ah  y coord
		xor   eax, eax
		mov   al, bl
		and   al, 7
		mov   ah, bl
		shr   ah, 3
		ret


MoveDirection:
	; in: eax square
	;     cl  x coord
	;     ch  y coord
	; out: eax square ebx + (x,y) or 64 if rbx + (x,y) is off board
		shl   eax, 5
		shr   al, 5
		add   al, cl
		 js   .Fail
		cmp   al, 8
		jae   .Fail
		add   ah, ch
		 js   .Fail
		cmp   ah, 8
		jae   .Fail
		shl   al, 5
		shr   eax, 5
		ret
     .Fail:	mov   eax, 64
		ret

SlidingAttacks:
	; in: rsi address of directions null terminated
	;     ebx square  (preserved)
	;     rdx occupation (preserved)
	;     r8d step count (preserved)
	; out: rax bitboard
	       push   rdi
		xor   edi, edi
.NextDirection:
	      movzx   ecx, word[rsi]
		add   rsi, 2
		mov   eax, ebx
		xor   r9d, r9d
	       test   ecx, ecx
		 jz   .Done
 .NextSquare:
		add   r9d, 1
		cmp   r9d, r8d
		 ja   .NextDirection
	       call   MoveDirection
		cmp   eax, 64
		jae   .NextDirection
		bts   rdi, rax
		 bt   rdx, rax
		jnc   .NextSquare
		jmp   .NextDirection
.Done:
		mov   rax, rdi
		pop   rdi
		ret

Directions:
.KingAttacks:	   db +1,+1, +1, 0, +1,-1,  0,+1,  0,-1, -1,+1, -1, 0, -1,-1,  0,0
.KnightAttacks:    db +2,+1, +2,-1, -2,+1, -2,-1, +1,+2, -1,+2, +1,-2, -1,-2,  0,0
.RookAttacks:	   db +1, 0, -1, 0,  0,+1,  0,-1,  0,0
.BishopAttacks:    db +1,+1, -1,+1, +1,-1, -1,-1,  0,0
.WhitePawnAttacks: db +1,+1, -1,+1,  0,0
.BlackPawnAttacks: db +1,-1, -1,-1,  0,0


MoveGen_Init:

Init_FileBB:
		lea   rdi, [FileBB]
		xor   ecx, ecx
		mov   rax, FileABB
.Next:		add   ecx, 1
	      stosq
		shl   rax, 1
		cmp   ecx, 8
		 jb   .Next

Init_RankBB:
		lea   rdi, [RankBB]
		xor   ecx, ecx
		mov   eax, 0x0FF
.Next:		add   ecx, 1
	      stosq
		shl   rax, 8
		cmp   ecx, 8
		 jb   .Next


if CPU_HAS_BMI2
Init_Attacks:
		lea   r14, [SlidingAttacksBB+8*0]
		lea   r15, [SlidingAttacksBB+8*102400]

		xor   ebx, ebx
.NextSquare:
		xor   edx, edx
		lea   r8d, [rdx+1]
		lea   rsi, [Directions.KnightAttacks]
	       call   SlidingAttacks
		mov   qword[KnightAttacks+8*rbx], rax

		lea   rsi, [Directions.KingAttacks]
	       call   SlidingAttacks
		mov   qword[KingAttacks+8*rbx], rax

		lea   rsi, [Directions.WhitePawnAttacks]
	       call   SlidingAttacks
		mov   qword[WhitePawnAttacks+8*rbx], rax

		lea   rsi, [Directions.BlackPawnAttacks]
	       call   SlidingAttacks
		mov   qword[BlackPawnAttacks+8*rbx], rax

		mov   eax, ebx
		and   eax, 7
		mov   r13, not (FileABB or FileHBB)
		 or   r13, qword[FileBB+8*rax]
		mov   eax, ebx
		shr   eax, 3
		mov   r12, not (Rank1BB or Rank8BB)
		 or   r12, qword[RankBB+8*rax]
		and   r13, r12

		 or   r8d, -1
		lea   rsi, [Directions.RookAttacks]
	       call   SlidingAttacks
		mov   qword[RookAttacksPDEP+8*rbx], rax
		and   rax, r13
		mov   qword[RookAttacksPEXT+8*rbx], rax

		lea   rsi, [Directions.BishopAttacks]
	       call   SlidingAttacks
		mov   qword[BishopAttacksPDEP+8*rbx], rax
		and   rax, r13
		mov   qword[BishopAttacksPEXT+8*rbx], rax

		mov   dword[RookAttacksMOFF+4*rbx], r14d
		xor   rdx, rdx
	.NextRookSubset:
		lea   rsi, [Directions.RookAttacks]
	       call   SlidingAttacks
	       pext   rcx, rdx, qword[RookAttacksPEXT+8*rbx]
		mov   r9d, dword[RookAttacksMOFF+4*rbx]
		mov   qword[r9+8*rcx], rax
		add   r14, 8
		sub   rdx, qword[RookAttacksPEXT+8*rbx]
		and   rdx, qword[RookAttacksPEXT+8*rbx]
		jnz   .NextRookSubset

		mov   dword[BishopAttacksMOFF+4*rbx], r15d
		xor   rdx, rdx
	.NextBishopSubset:
		lea   rsi, [Directions.BishopAttacks]
	       call   SlidingAttacks
	       pext   rcx, rdx, qword[BishopAttacksPEXT+8*rbx]
		mov   r9d, dword[BishopAttacksMOFF+4*rbx]
		mov   qword[r9+8*rcx], rax
		add   r15, 8
		sub   rdx, qword[BishopAttacksPEXT+8*rbx]
		and   rdx, qword[BishopAttacksPEXT+8*rbx]
		jnz   .NextBishopSubset

		add   ebx, 1
		cmp   ebx, 64
		 jb   .NextSquare

  if DEBUG
		lea   rax, [SlidingAttacksBB+8*102400]
	     Assert   e, r14, rax, 'error in calculating slinding attacks'
		lea   rax, [SlidingAttacksBB+8*107648]
	     Assert   e, r15, rax, 'error in calculating slinding attacks'
  end if

		ret

else

; Fixed shift magics found by Volker Annuss.
; From: http://talkchess.com/forum/viewtopic.php?p=670709#670709

Init_Attacks:
  if DEBUG
                lea   rdi, [SlidingAttacksBB]
                mov   ecx, 89524
                mov   rax, -1
          rep stosq
  end if
		xor   ebx, ebx
.NextSquare:
		xor   edx, edx
		lea   r8d, [rdx+1]
		lea   rsi, [Directions.KnightAttacks]
	       call   SlidingAttacks
		mov   qword[KnightAttacks+8*rbx], rax

		lea   rsi, [Directions.KingAttacks]
	       call   SlidingAttacks
		mov   qword[KingAttacks+8*rbx], rax

		lea   rsi, [Directions.WhitePawnAttacks]
	       call   SlidingAttacks
		mov   qword[WhitePawnAttacks+8*rbx], rax

		lea   rsi, [Directions.BlackPawnAttacks]
	       call   SlidingAttacks
		mov   qword[BlackPawnAttacks+8*rbx], rax

		mov   eax, ebx
		and   eax, 7
		mov   r13, not (FileABB or FileHBB)
		 or   r13, qword[FileBB+8*rax]
		mov   eax, ebx
		shr   eax, 3
		mov   r12, not (Rank1BB or Rank8BB)
		 or   r12, qword[RankBB+8*rax]
		and   r13, r12

		 or   r8d, -1
		lea   rsi, [Directions.RookAttacks]
	       call   SlidingAttacks
		mov   qword[RookAttacksPDEP+8*rbx], rax
		and   rax, r13
		mov   qword[RookAttacksPEXT+8*rbx], rax

		lea   rsi, [Directions.BishopAttacks]
	       call   SlidingAttacks
		mov   qword[BishopAttacksPDEP+8*rbx], rax
		and   rax, r13
		mov   qword[BishopAttacksPEXT+8*rbx], rax

		shl   ebx, 4
		mov   rax, qword[.RookData+rbx+0]
		mov   ecx, dword[.RookData+rbx+8]
		lea   rcx, [SlidingAttacksBB+8*rcx]
		mov   rdx, qword[.BishopData+rbx+0]
		mov   r9d, dword[.BishopData+rbx+8]
		lea   r9, [SlidingAttacksBB+8*r9]
		shr   ebx, 4
		mov   qword[RookAttacksIMUL+8*rbx], rax
		mov   dword[RookAttacksMOFF+4*rbx], ecx
		mov   qword[BishopAttacksIMUL+8*rbx], rdx
		mov   dword[BishopAttacksMOFF+4*rbx], r9d

		xor   rdx, rdx
	.NextRookSubset:
		lea   rsi, [Directions.RookAttacks]
	       call   SlidingAttacks
		mov   rcx, qword[RookAttacksPEXT+8*rbx]
		and   rcx, rdx
	       imul   rcx, qword[RookAttacksIMUL+8*rbx]
		shr   rcx, 64-12
		mov   r9d, dword[RookAttacksMOFF+4*rbx]
  if DEBUG
                cmp   qword[r9+8*rcx], -1
                 je   @f
             Assert   e, rax, qword[r9+8*rcx], 'bad rook magic'
        @@:
  end if
		mov   qword[r9+8*rcx], rax
		sub   rdx, qword[RookAttacksPEXT+8*rbx]
		and   rdx, qword[RookAttacksPEXT+8*rbx]
		jnz   .NextRookSubset

		xor   rdx, rdx
	.NextBishopSubset:
		lea   rsi, [Directions.BishopAttacks]
	       call   SlidingAttacks
		mov   rcx, qword[BishopAttacksPEXT+8*rbx]
		and   rcx, rdx
	       imul   rcx, qword[BishopAttacksIMUL+8*rbx]
		shr   rcx, 64-9
		mov   r9d, dword[BishopAttacksMOFF+4*rbx]
  if DEBUG
                cmp   qword[r9+8*rcx], -1
                 je   @f
             Assert   e, rax, qword[r9+8*rcx], 'bad bishop magic'
        @@:
  end if
		mov   qword[r9+8*rcx], rax
		sub   rdx, qword[BishopAttacksPEXT+8*rbx]
		and   rdx, qword[BishopAttacksPEXT+8*rbx]
		jnz   .NextBishopSubset

		add   ebx, 1
		cmp   ebx, 64
		 jb   .NextSquare

		ret

.RookData:
   dq 0x00280077ffebfffe,  41305
   dq 0x2004010201097fff,  14326
   dq 0x0010020010053fff,  24477
   dq 0x0030002ff71ffffa,   8223
   dq 0x7fd00441ffffd003,  49795
   dq 0x004001d9e03ffff7,  60546
   dq 0x004000888847ffff,  28543
   dq 0x006800fbff75fffd,  79282
   dq 0x000028010113ffff,   6457
   dq 0x0020040201fcffff,   4125
   dq 0x007fe80042ffffe8,  81021
   dq 0x00001800217fffe8,  42341
   dq 0x00001800073fffe8,  14139
   dq 0x007fe8009effffe8,  19465
   dq 0x00001800602fffe8,   9514
   dq 0x000030002fffffa0,  71090
   dq 0x00300018010bffff,  75419
   dq 0x0003000c0085fffb,  33476
   dq 0x0004000802010008,  27117
   dq 0x0002002004002002,  85964
   dq 0x0002002020010002,  54915
   dq 0x0001002020008001,  36544
   dq 0x0000004040008001,  71854
   dq 0x0000802000200040,  37996
   dq 0x0040200010080010,  30398
   dq 0x0000080010040010,  55939
   dq 0x0004010008020008,  53891
   dq 0x0000040020200200,  56963
   dq 0x0000010020020020,  77451
   dq 0x0000010020200080,  12319
   dq 0x0000008020200040,  88500
   dq 0x0000200020004081,  51405
   dq 0x00fffd1800300030,  72878
   dq 0x007fff7fbfd40020,    676
   dq 0x003fffbd00180018,  83122
   dq 0x001fffde80180018,  22206
   dq 0x000fffe0bfe80018,  75186
   dq 0x0001000080202001,    681
   dq 0x0003fffbff980180,  36453
   dq 0x0001fffdff9000e0,  20369
   dq 0x00fffeebfeffd800,   1981
   dq 0x007ffff7ffc01400,  13343
   dq 0x0000408104200204,  10650
   dq 0x001ffff01fc03000,  57987
   dq 0x000fffe7f8bfe800,  26302
   dq 0x0000008001002020,  58357
   dq 0x0003fff85fffa804,  40546
   dq 0x0001fffd75ffa802,      0
   dq 0x00ffffec00280028,  14967
   dq 0x007fff75ff7fbfd8,  80361
   dq 0x003fff863fbf7fd8,  40905
   dq 0x001fffbfdfd7ffd8,  58347
   dq 0x000ffff810280028,  20381
   dq 0x0007ffd7f7feffd8,  81868
   dq 0x0003fffc0c480048,  59381
   dq 0x0001ffffafd7ffd8,  84404
   dq 0x00ffffe4ffdfa3ba,  45811
   dq 0x007fffef7ff3d3da,  62898
   dq 0x003fffbfdfeff7fa,  45796
   dq 0x001fffeff7fbfc22,  66994
   dq 0x0000020408001001,  67204
   dq 0x0007fffeffff77fd,  32448
   dq 0x0003ffffbf7dfeec,  62946
   dq 0x0001ffff9dffa333,  17005

.BishopData:
   dq 0x0000404040404040,  33104
   dq 0x0000a060401007fc,   4094
   dq 0x0000401020200000,  24764
   dq 0x0000806004000000,  13882
   dq 0x0000440200000000,  23090
   dq 0x0000080100800000,  32640
   dq 0x0000104104004000,  11558
   dq 0x0000020020820080,  32912
   dq 0x0000040100202004,  13674
   dq 0x0000020080200802,   6109
   dq 0x0000010040080200,  26494
   dq 0x0000008060040000,  17919
   dq 0x0000004402000000,  25757
   dq 0x00000021c100b200,  17338
   dq 0x0000000400410080,  16983
   dq 0x000003f7f05fffc0,  16659
   dq 0x0004228040808010,  13610
   dq 0x0000200040404040,   2224
   dq 0x0000400080808080,  60405
   dq 0x0000200200801000,   7983
   dq 0x0000240080840000,     17
   dq 0x000018000c03fff8,  34321
   dq 0x00000a5840208020,  33216
   dq 0x0000058408404010,  17127
   dq 0x0002022000408020,   6397
   dq 0x0000402000408080,  22169
   dq 0x0000804000810100,  42727
   dq 0x000100403c0403ff,    155
   dq 0x00078402a8802000,   8601
   dq 0x0000101000804400,  21101
   dq 0x0000080800104100,  29885
   dq 0x0000400480101008,  29340
   dq 0x0001010102004040,  19785
   dq 0x0000808090402020,  12258
   dq 0x0007fefe08810010,  50451
   dq 0x0003ff0f833fc080,   1712
   dq 0x007fe08019003042,  78475
   dq 0x0000202040008040,   7855
   dq 0x0001004008381008,  13642
   dq 0x0000802003700808,   8156
   dq 0x0000208200400080,   4348
   dq 0x0000104100200040,  28794
   dq 0x0003ffdf7f833fc0,  22578
   dq 0x0000008840450020,  50315
   dq 0x0000020040100100,  85452
   dq 0x007fffdd80140028,  32816
   dq 0x0000202020200040,  13930
   dq 0x0001004010039004,  17967
   dq 0x0000040041008000,  33200
   dq 0x0003ffefe0c02200,  32456
   dq 0x0000001010806000,   7762
   dq 0x0000000008403000,   7794
   dq 0x0000000100202000,  22761
   dq 0x0000040100200800,  14918
   dq 0x0000404040404000,  11620
   dq 0x00006020601803f4,  15925
   dq 0x0003ffdfdfc28048,  32528
   dq 0x0000000820820020,  12196
   dq 0x0000000010108060,  32720
   dq 0x0000000000084030,  26781
   dq 0x0000000001002020,  19817
   dq 0x0000000040408020,  24732
   dq 0x0000004040404040,  25468
   dq 0x0000404040404040,  10186
end if
