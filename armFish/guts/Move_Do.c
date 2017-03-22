

Move_Do__UciParseMoves:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__UciParseMoves',0	   }
*/
Move_Do__PerftGen_Root:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__PerftGen_Root',0	   }
*/
Move_Do__PerftGen_Branch:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__PerftGen_Branch',0	     }
*/
Move_Do__ExtractPonderFromTT:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__ExtractPonderFromTT',0		 }
*/
Move_Do__Search:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__Search',0			 }
*/
Move_Do__QSearch:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__QSearch',0			 }
*/
Move_Do__EasyMoveMng:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__EasyMoveMng',0			 }
*/
Move_Do__RootMove_InsertPVInTT:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__RootMove_InsertPVInTT',0	 }
*/
Move_Do__ProbCut:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'DoMove__ProbCut',0	   }
*/
Move_Do__Tablebase_ProbeAB:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeAB',0	      }
*/
Move_Do__Tablebase_ProbeWDL:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeWDL',0	       }
*/
Move_Do__Tablebase_ProbeDTZNoEP:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeDTZNoEP',0	   }
*/
Move_Do__Tablebase_ProbeDTZNoEP_SuccessIsNeg_WdlIsPositive:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeDTZNoEP_SuccessIsNeg_WdlIsPositive',0	      }
*/
Move_Do__Tablebase_ProbeDTZNoEP_SuccessIsNeg_WdlIsNonpositive:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeDTZNoEP_SuccessIsNeg_WdlIsNonpositive',0	 }
*/
Move_Do__Tablebase_ProbeDTZ:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_ProbeDTZ',0	       }
*/
Move_Do__Tablebase_RootProbe:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_RootProbe',0 	}
*/
Move_Do__Tablebase_RootProbeWDL:
/*
match =1, DEBUG {
		lea   rax, [@f]
		mov   [rbp+Pos.debugQWORD1], rax
		jmp   Move_Do
@@: db 'Move_Do__Tablebase_RootProbeWDL',0	   }
*/



Move_Do:
/*
	; in: rbp  address of Pos
	;     rbx  address of State
	;     ecx  move
	;     edx  move is check

	       push   rsi rdi r12 r13 r14 r15
        ; stack is unaligned at this point
		mov   esi, dword[rbp+Pos.sideToMove]
	      vmovq   xmm15, qword[Zobrist_side]
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to
		shr   ecx, 12
	      movzx   r10d, byte[rbp+Pos.board+r8]     ; r10 = FROM PIECE
	      movzx   r11d, byte[rbp+Pos.board+r9]     ; r11 = TO PIECE
	      vmovq   xmm5, qword[rbx+State.key]
	      vmovq   xmm4, qword[rbx+State.pawnKey]
	      vmovq   xmm3, qword[rbx+State.materialKey]
	      vmovq   xmm6, qword[rbx+State.psq]       ; psq and npMaterial
	      vpxor   xmm5, xmm5, xmm15
		add   qword[rbp-Thread.rootPos+Thread.nodes], 1
	; update rule50 and pliesFromNull and capturedPiece
		mov   eax, dword[rbx+State.rule50]
		add   eax, 0x00010001
		mov   dword[rbx+sizeof.State+State.rule50], eax
		mov   byte[rbx+sizeof.State+State.capturedPiece], r11l
	; castling rights
	      movzx   edx, byte[rbx+State.castlingRights]
	      movzx   eax, byte[rbp-Thread.rootPos+Thread.castling_rightsMask+r8]
		 or   al, byte[rbp-Thread.rootPos+Thread.castling_rightsMask+r9]
		and   al, dl
		jnz   .Rights
*/

        ldr  w16, [x20, Pos.sideToMove]
        lea  x7, Zobrist_side
        ldr  d15, [x7]
       ubfx  x8, x1, 6, 6
        and  x9, x1, 63
        lsr  x1, x1, 12

        add  x6, x20, Pos.board
       ldrb  w10, [x6, x8]
       ldrb  w11, [x6, x9]
        ldr  d5, [x21, State.key]
        ldr  d4, [x21, State.pawnKey]
        ldr  d3, [x21, State.materialKey]
        ldr  d6, [x21, State.psq]
        eor  v5.8b, v5.8b, v15.8b

        ldr  x4, [x20, -Thread.rootPos + Thread.nodes]
        add  x4, x4, 1
        str  x4, [x20, -Thread.rootPos + Thread.nodes]

        mov  x4, 1
       movk  w4, 1, lsl 16
        ldr  w0, [x21, State.rule50]
        add  w0, w0, w4
       strb  w11, [x21, 1*sizeof.State + State.capturedPiece]
        str  w0, [x21, 1*sizeof.State + State.rule50]

        add  x7, x20, -Thread.rootPos + Thread.castling_rightsMask
       ldrb  w2, [x21, State.castlingRights]
       ldrb  w0, [x7, x8] 
       ldrb  w4, [x7, x9]
        orr  w0, w0, w4
       ands  w0, w0, w2
        bne  Move_Do.Rights

Move_Do.RightsRet:	
/*
                mov   byte[rbx+sizeof.State+State.castlingRights], dl

	; ep square
	      movzx   eax, byte[rbx+State.epSquare]
		cmp   eax, 64
		 jb   .ResetEp
		mov   byte[rbx+sizeof.State+State.epSquare], al
*/
       strb  w2, [x21, 1*sizeof.State + State.castlingRights]
       ldrb  w0, [x21, State.epSquare]
        cmp  w0, 64
        blo  Move_Do.ResetEp
       strb  w0, [x21, 1*sizeof.State + State.epSquare]

Move_Do.ResetEpRet:
/*
	; capture
		mov   eax, r11d
		cmp   ecx, MOVE_TYPE_CASTLE
		 je   .Castling
		and   eax, 7
		jnz   .Capture
*/
        and  x0, x11, 7
        cmp  x1, MOVE_TYPE_CASTLE
        beq  Move_Do.Castling
       cbnz  x11, Move_Do.Capture

Move_Do.CaptureRet:
/*
	; move piece
		mov   r11d, r8d
		xor   r11d, r9d

		xor   edx, edx
		bts   rdx, r8
	      vmovq   xmm8, rdx
		bts   rdx, r9
	      vmovq   xmm9, rdx
		mov   eax, r10d
		and   eax, 7
		mov   byte[rbp+Pos.board+r8], 0
		mov   byte[rbp+Pos.board+r9], r10l
		xor   qword[rbp+Pos.typeBB+8*rax], rdx
		xor   qword[rbp+Pos.typeBB+8*rsi], rdx
	      movzx   eax, byte[rbp+Pos.pieceIdx+r8]
		mov   byte[rbp+Pos.pieceList+rax], r9l
		mov   byte[rbp+Pos.pieceIdx+r9], al
*/
        eor  x11, x8, x9
        mov  x2, 1
        lsl  x4, x2, x8
        lsl  x2, x2, x9
       fmov  d8, x4
       fmov  d9, x2
        orr  x2, x2, x4
        and  x0, x10, 7
        add  x7, x20, Pos.board
       strb  wzr, [x7, x8]
       strb  w10, [x7, x9]
        ldr  x4, [x20, x0, lsl 3]
        eor  x4, x4, x2
        str  x4, [x20, x0, lsl 3]
        ldr  x4, [x20, x16, lsl 3]
        eor  x4, x4, x2
        str  x4, [x20, x16, lsl 3]
        add  x7, x20, Pos.pieceIdx
       ldrb  w0, [x7, x8]
        add  x7, x20, Pos.pieceList
       strb  w9, [x7, x0]
        add  x7, x20, Pos.pieceIdx
       strb  w0, [x7, x9]
/*
	      movsx   rax, byte[IsPawnMasks+r10]
		and   r11d, eax
		shl   r10d, 6+3
		mov   rdx, qword[Zobrist_Pieces+r10+8*r8]
		xor   rdx, qword[Zobrist_Pieces+r10+8*r9]
	      vmovd   xmm1, dword[Scores_Pieces+r10+8*r8]
	      vmovd   xmm2, dword[Scores_Pieces+r10+8*r9]
	      vmovq   xmm7, rdx
	      vpxor   xmm5, xmm5, xmm7
		and   rdx, rax
	      vmovq   xmm7, rdx
	      vpxor   xmm4, xmm4, xmm7
	     vpsubd   xmm6, xmm6, xmm1
	     vpaddd   xmm6, xmm6, xmm2
		shr   r10d, 6+3

		not   eax
		and   word[rbx+sizeof.State+State.rule50], ax

	; special moves
		cmp   ecx, MOVE_TYPE_PROM
		jae   .Special
		cmp   r11d, 16
		 je   .DoublePawn
*/
        lea  x7, IsPawnMasks
      ldrsb  x0, [x7, x10]
        and  x11, x11, x0
        lea  x6, Zobrist_Pieces
        lea  x7, Scores_Pieces
        add  x6, x6, x10, lsl 9
        add  x7, x7, x10, lsl 9
        ldr  x2, [x6, x8, lsl 3]
        ldr  x4, [x6, x9, lsl 3]
        eor  x2, x2, x4
        ldr  d1, [x7, x8, lsl 3]
        ldr  d2, [x7, x9, lsl 3]
       fmov  d7, x2
        eor  v5.8b, v5.8b, v7.8b
        and  x2, x2, x0
       fmov  d7, x2
        eor  v4.8b, v4.8b, v7.8b
        sub  v6.2s, v6.2s, v1.2s
        add  v6.2s, v6.2s, v2.2s

        mvn  w0, w0
       ldrh  w4, [x21, 1*sizeof.State + State.rule50]
        and  w4, w4, w0
       //strh  w4, [x21, 1*sizeof.State + State.rule50]

        cmp  w1, MOVE_TYPE_PROM
        bhs  Move_Do.Special
        cmp  x11, 16
        beq  Move_Do.DoublePawn

Move_Do.SpecialRet:
/*

	; write remaining data to next state entry

              movzx   eax, byte[rbx+State.givesCheck]
              vmovq   r8, xmm8
              vmovq   r9, xmm9
	; r9 = to + from
	; r8 = from
	; r10 = from piece
	; rax = is check
	; ecx = move

		xor   esi, 1
		add   rbx, sizeof.State
		xor   r9, r8
		and   r10d, 7

		mov   dword[rbp+Pos.sideToMove], esi
		mov   qword[rbp+Pos.state], rbx

	      vmovq   qword[rbx+State.key], xmm5
	      vmovq   qword[rbx+State.pawnKey], xmm4
	      vmovq   qword[rbx+State.materialKey], xmm3
	      vmovq   qword[rbx+State.psq], xmm6

		mov   r15, qword[rbp+Pos.typeBB+8*rsi]
		xor   esi, 1
		mov   r14, qword[rbp+Pos.typeBB+8*rsi]
		shl   esi, 6+3
		mov   r13, r15		; r13 = our pieces
		mov   r12, r14		; r12 = their pieces
		mov   rdi, r15
		 or   rdi, r14		; rdi = all pieces
		and   r15, qword[rbp+Pos.typeBB+8*King]
		and   r14, qword[rbp+Pos.typeBB+8*King]
		bsf   r15, r15		; r15 = our king
		bsf   r14, r14		; r14 = their king

	       test   eax, eax
		jnz   .MoveIsCheck
*/
       ldrb  w0, [x21, State.givesCheck]
       fmov  x8, d8
       fmov  x9, d9
        eor  x16, x16, 1
        add  x21, x21, sizeof.State
        and  x10, x10, 7
        str  w16, [x20, Pos.sideToMove]
        str  x21, [x20, Pos.state]
        
        str  d5, [x21, State.key]
        str  d4, [x21, State.pawnKey]
        str  d3, [x21, State.materialKey]
        str  d6, [x21, State.psq]

        ldr  x4, [x20, 8*King]
        ldr  x13, [x20, x16, lsl 3]
        eor  x16, x16, 1
        ldr  x12, [x20, x16, lsl 3]
        and  x14, x12, x4
        and  x15, x13, x4
        orr  x17, x12, x13
       rbit  x14, x14
       rbit  x15, x15
        clz  x14, x14
        clz  x15, x15

       cbnz  w0, Move_Do.MoveIsCheck
        

Move_Do.CheckersDone:
/*
		mov   qword[rbx+State.checkersBB], rax
		jmp   SetCheckInfo.go
*/
        str  xzr, [x21, State.checkersBB]
          b  SetCheckInfo.go


Move_Do.Capture:
/*
		mov   r12d, r11d
		and   r12d, 8
	; remove piece r11(=r12+rax) on to square r9
		mov   rdi, qword[rbp+Pos.typeBB+r12]
		mov   rdx, qword[rbp+Pos.typeBB+8*rax]
		btr   rdi, r9
		btr   rdx, r9
		mov   qword[rbp+Pos.typeBB+r12], rdi
		mov   qword[rbp+Pos.typeBB+8*rax], rdx

	      movzx   edi, byte[rbp+Pos.pieceEnd+r11]
		and   edi, 15
*/
        and  x12, x11, 8
        ldr  x17, [x20, x12]
        ldr  x2, [x20, x0, lsl 3]
        mov  x4, 1
        lsl  x4, x4, x9
        bic  x17, x17, x4
        bic  x2, x2, x4
        str  x17, [x20, x12]
        str  x2, [x20, x0, lsl 3]

        add  x7, x20, Pos.pieceEnd
       ldrb  w17, [x7, x11]
        and  w17, w17, 15

/*
	      movsx   rax, byte[IsPawnMasks+r11]
		shl   r11d, 6+3
		mov   rdx, qword[Zobrist_Pieces+r11+8*r9]
	      vmovq   xmm7, rdx
	      vpxor   xmm5, xmm5, xmm7
		and   rdx, rax
	      vmovq   xmm7, rdx
	      vpxor   xmm4, xmm4, xmm7
	      vmovq   xmm7, qword[Zobrist_Pieces+r11+8*(rdi-1)]
	      vpxor   xmm3, xmm3, xmm7
	      vmovq   xmm1, qword[Scores_Pieces+r11+8*r9]
	     vpsubd   xmm6, xmm6, xmm1
		shr   r11d, 6+3
		mov   word[rbx+sizeof.State+State.rule50], 0
*/
        lea  x7, IsPawnMasks
      ldrsb  x0, [x7, x11]
        lea  x6, Zobrist_Pieces
        lea  x7, Scores_Pieces
        add  x6, x6, x11, lsl 9
        add  x7, x7, x11, lsl 9
        ldr  x2, [x6, x9, lsl 3]
       fmov  d7, x2
        eor  v5.8b, v5.8b, v7.8b
        and  x2, x2, x0
       fmov  d7, x2
        eor  v4.8b, v4.8b, v7.8b
        sub  x17, x17, 1
        ldr  d7, [x6, x17, lsl 3]
        eor  v3.8b, v3.8b, v7.8b
        ldr  d1, [x7, x9, lsl 3]
        sub  v6.2s, v6.2s, v1.2s
       strh  w0, [x21, sizeof.State + State.rule50]
/*
	      movzx   edi, byte[rbp+Pos.pieceEnd+r11]
		sub   edi, 1
	      movzx   edx, byte[rbp+Pos.pieceList+rdi]
	      movzx   eax, byte[rbp+Pos.pieceIdx+r9]
		mov   byte[rbp+Pos.pieceEnd+r11], dil
		mov   byte[rbp+Pos.pieceIdx+rdx], al
		mov   byte[rbp+Pos.pieceList+rax], dl
		mov   byte[rbp+Pos.pieceList+rdi], 64
		jmp   .CaptureRet
*/
        add  x7, x20, Pos.pieceEnd
       ldrb  w17, [x7, x11]
        sub  w17, w17, 1
        add  x7, x20, Pos.pieceList
       ldrb  w2, [x7, x17]
        add  x7, x20, Pos.pieceIdx
       ldrb  w0, [x7, x9]
        add  x7, x20, Pos.pieceEnd
       strb  w17, [x7, x11]
        add  x7, x20, Pos.pieceIdx
       strb  w0, [x7, x2]
        add  x7, x20, Pos.pieceList
       strb  w2, [x7, x0]
        mov  w4, 64
       strb  w4, [x7, x17]
          b  Move_Do.CaptureRet

Move_Do.MoveIsCheck:
/*
		mov   rdx, qword[rbx+State.dcCandidates-sizeof.State]
		mov   rax, qword[rbx+State.checkSq-sizeof.State+8*r10]
	       test   ecx, ecx
		jnz   .DoFull
		and   rax, r9
	       test   rdx, r8
		jnz   .DoFull
		mov   qword[rbx+State.checkersBB], rax
		jmp   SetCheckInfo.go
*/
        ldr  x2, [x21, -1*sizeof.State + State.dcCandidates]
        add  x7, x21, -1*sizeof.State + State.checkSq
        ldr  x0, [x7, x10, lsl 3]
       cbnz  w1, Move_Do.DoFull
        and  x0, x0, x9
        tst  x2, x8
        bne  Move_Do.DoFull
        str  x0, [x21, State.checkersBB]
          b  SetCheckInfo.go

Move_Do.DoFull:
/*
		mov   ecx, esi
		xor   ecx, 1 shl (6+3)
		mov   rax, qword[KingAttacks+8*r15]
		and   rax, qword[rbp+Pos.typeBB+8*King]
		mov   r8, qword[KnightAttacks+8*r15]
		and   r8, qword[rbp+Pos.typeBB+8*Knight]
		 or   rax, r8
		mov   r8, qword[WhitePawnAttacks+rcx+8*r15]
		and   r8, qword[rbp+Pos.typeBB+8*Pawn]
		 or   rax, r8
	RookAttacks   r8, r15, rdi, r9
		mov   r9, qword[rbp+Pos.typeBB+8*Rook]
		 or   r9, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8
      BishopAttacks   r8, r15, rdi, r9
		mov   r9, qword[rbp+Pos.typeBB+8*Bishop]
		 or   r9, qword[rbp+Pos.typeBB+8*Queen]
		and   r8, r9
		 or   rax, r8
		and   rax, r12
		mov   qword[rbx+State.checkersBB], rax
		jmp   SetCheckInfo.go
*/
        eor  x1, x16, 1
        lea  x7, PawnAttacks
        add  x7, x7, x15, lsl 3
        ldr  x0, [x7, KingAttacks-PawnAttacks]
        ldr  x4, [x20, 8*King]
        and  x0, x0, x4
        ldr  x8, [x7, KnightAttacks-PawnAttacks]
        ldr  x4, [x20, 8*Knight]
        and  x8, x8, x4
        orr  x0, x0, x8
        add  x7, x7, x1, lsl 6+3
        ldr  x8, [x7]
        ldr  x4, [x20, 8*Pawn]
        and  x8, x8, x4
        orr  x0, x0, x8
        ldr  x5, [x20, 8*Queen]
        RookAttacks x8, x15, x17, x9, x1
        ldr  x9, [x20, 8*Rook]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8
        BishopAttacks x8, x15, x17, x9, x1
        ldr  x9, [x20, 8*Bishop]
        orr  x9, x9, x5
        and  x8, x8, x9
        orr  x0, x0, x8
        and  x0, x0, x12
        str  x0, [x21, State.checkersBB]
          b  SetCheckInfo.go

        


Move_Do.ResetEp:
/*
		and   eax, 7
	      vmovq   xmm7, qword[Zobrist_Ep+8*rax]
	      vpxor   xmm5, xmm5, xmm7
		mov   byte[rbx+sizeof.State+State.epSquare], 64
		jmp   .ResetEpRet
*/
        lea  x7, Zobrist_Ep
        and  w0, w0, 7
        ldr  d7, [x7, x0, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        mov  w4, 64
       strb  w4, [x21, 1*sizeof.State + State.epSquare]
          b  Move_Do.ResetEpRet

Move_Do.Rights:
/*
		xor   edx, eax
	      vmovq   xmm7, qword[Zobrist_Castling+8*rax]
	      vpxor   xmm5, xmm5, xmm7
		jmp   .RightsRet
*/
        lea  x7, Zobrist_Castling
        eor  w2, w2, w0
        ldr  d7, [x7, x0, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
          b  Move_Do.RightsRet

Move_Do.DoublePawn:
/*
		mov   edx, esi
		shl   edx, 6+3
		add   r8d, r9d
		shr   r8d, 1
		mov   rax, qword[WhitePawnAttacks+rdx+8*r8]
		mov   edx, esi
		xor   edx, 1
		and   rax, qword[rbp+Pos.typeBB+8*Pawn]
	       test   rax, qword[rbp+Pos.typeBB+8*rdx]
		 jz   .SpecialRet
		mov   byte[rbx+State.epSquare+sizeof.State], r8l
		and   r8d, 7
	      vmovq   xmm7, qword[Zobrist_Ep+8*r8]
	      vpxor   xmm5, xmm5, xmm7
		jmp   .SpecialRet
*/
        lea  x7, WhitePawnAttacks
        add  x7, x7, x16, lsl 9
        add  x8, x8, x9
        lsr  x8, x8, 1
        ldr  x0, [x7, x8, lsl 3]

        eor  x2, x16, 1
        ldr  x4, [x20, 8*Pawn]
        and  x0, x0, x4
        ldr  x4, [x20, x2, lsl 3]
        and  x0, x0, x4
        cbz  x0, Move_Do.SpecialRet
       strb  w8, [x21, 1*sizeof.State + State.epSquare]
        and  x8, x8, 7        
        lea  x7, Zobrist_Ep
        ldr  d7, [x7, x8, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
          b  Move_Do.SpecialRet

Move_Do.Special:
/*
		xor   edx, edx
		cmp   ecx, MOVE_TYPE_EPCAP
		 je   .EpCapture
*/
        cmp  x1, MOVE_TYPE_EPCAP
        beq  Move_Do.EpCapture

Move_Do.Promotion:
/*
		lea   r14d, [rcx-MOVE_TYPE_PROM+8*rsi+Knight]

	      movzx   edi, byte[rbp+Pos.pieceEnd+r10]
		sub   edi, 1
	      movzx   edx, byte[rbp+Pos.pieceList+rdi]
	      movzx   eax, byte[rbp+Pos.pieceIdx+r9]
		mov   byte[rbp+Pos.pieceEnd+r10], dil
		mov   byte[rbp+Pos.pieceIdx+rdx], al
		mov   byte[rbp+Pos.pieceList+rax], dl
		mov   byte[rbp+Pos.pieceList+rdi], 64

	      movzx   edx, byte[rbp+Pos.pieceEnd+r14]
		mov   byte[rbp+Pos.pieceIdx+r9], dl
		mov   byte[rbp+Pos.pieceList+rdx], r9l
		add   edx, 1
		mov   byte[rbp+Pos.pieceEnd+r14], dl
*/
        add  x14, x1, -MOVE_TYPE_PROM + Knight
        add  x14, x14, x16, lsl 3
        
        add  x7, x20, Pos.pieceEnd
       ldrb  w17, [x7, x10]
        sub  w17, w17, 1
        add  x7, x20, Pos.pieceList
       ldrb  w2, [x7, x17]
        add  x7, x20, Pos.pieceIdx
       ldrb  w0, [x7, x9]
        add  x7, x20, Pos.pieceEnd
       strb  w17, [x7, x10]
        add  x7, x20, Pos.pieceIdx
       strb  w0, [x7, x2]
        add  x7, x20, Pos.pieceList
       strb  w2, [x7, x0]
        mov  w4, 64
       strb  w4, [x7, x7]

        add  x7, x20, Pos.pieceEnd
       ldrb  w2, [x7, x14]
        add  x7, x20, Pos.pieceIdx
       strb  w2, [x7, x9]
        add  x7, x20, Pos.pieceList
       strb  w9, [x7, x2]
        add  x2, x2, 1
        add  x7, x20, Pos.pieceEnd
       strb  w2, [x7, x14]
        
        
/*
	; remove pawn r10 on square r9
		mov   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		btr   rdx, r9
		mov   qword[rbp+Pos.typeBB+8*Pawn], rdx
		and   rdx, qword[rbp+Pos.typeBB+8*rsi]
	     popcnt   rax, rdx, r8
		shl   r10d, 6+3
	      vmovq   xmm7, qword[Zobrist_Pieces+r10+8*r9]
	      vpxor   xmm5, xmm5, xmm7
	      vpxor   xmm4, xmm4, xmm7
	      vmovq   xmm7, qword[Zobrist_Pieces+r10+8*rax]
	      vpxor   xmm3, xmm3, xmm7
	      vmovq   xmm1, qword[Scores_Pieces+r10+8*r9]
	     vpsubd   xmm6, xmm6, xmm1
                shr   r10d, 6+3
*/
        ldr  x2, [x20, 8*Pawn]
        mov  x4, 1
        lsl  x4, x4, x9
        bic  x2, x2, x4
        str  x2, [x20, 8*Pawn]
        ldr  x4, [x20, x16, lsl 3]
        and  x2, x2, x4
        Popcnt  x0, x2, x8
        lea  x6, Zobrist_Pieces
        lea  x7, Scores_Pieces
        add  x6, x6, x10, lsl 9
        add  x7, x7, x10, lsl 9
        ldr  d7, [x6, x9, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        eor  v4.8b, v4.8b, v7.8b
        ldr  d7, [x6, x0, lsl 3]
        eor  v3.8b, v3.8b, v7.8b
        ldr  d1, [x7, x9, lsl 3]
        sub  v6.2s, v6.2s, v1.2s
/*
	; place piece r14 on square r9
		mov   eax, r14d
		and   eax, 7
		mov   rdx, qword[rbp+Pos.typeBB+8*rax]
		bts   rdx, r9
		mov   qword[rbp+Pos.typeBB+8*rax], rdx
		mov   byte[rbp+Pos.board+r9], r14l
		and   rdx, qword[rbp+Pos.typeBB+8*rsi]
	     popcnt   rax, rdx, r8
		shl   r14d, 6+3
	      vmovq   xmm7, qword[Zobrist_Pieces+r14+8*r9]
	      vpxor   xmm5, xmm5, xmm7
	      vmovq   xmm7, qword[Zobrist_Pieces+r14+8*(rax-1)]
	      vpxor   xmm3, xmm3, xmm7
	      vmovq   xmm1, qword[Scores_Pieces+r14+8*r9]
	     vpaddd   xmm6, xmm6, xmm1
		jmp   .SpecialRet
*/
        and  x0, x14, 7
        ldr  x2, [x20, x0, lsl 3]
        mov  x4, 1
        lsl  x4, x4, x9
        orr  x2, x2, x4
        str  x2, [x20, x0, lsl 3]
        add  x7, x20, Pos.board
       strb  w14, [x7, x9]
        ldr  x4, [x20, x16, lsl 3]
        and  x0, x0, x4
        Popcnt  x0, x2, x8
        sub  x0, x0, 1
        lea  x6, Zobrist_Pieces
        lea  x7, Scores_Pieces
        add  x6, x6, x14, lsl 9
        add  x7, x7, x14, lsl 9
        ldr  d7, [x6, x9, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        ldr  d7, [x6, x0, lsl 3]
        eor  v3.8b, v3.8b, v7.8b
        ldr  d1, [x7, x9, lsl 3]
        add  v6.8b, v6.8b, v1.8b
          b  Move_Do.SpecialRet


Move_Do.EpCapture:
/*
	; remove pawn r10^8 on square r14=r9+8*(2*esi-1)
		lea   r14d, [2*rsi-1]
		lea   r14d, [r9+8*r14]
		xor   r10, 8
		xor   esi, 1
		mov   rdx, qword[rbp+Pos.typeBB+8*Pawn]
		mov   rdi, qword[rbp+Pos.typeBB+8*rsi]
		btr   rdx, r14
		btr   rdi, r14
		mov   qword[rbp+Pos.typeBB+8*Pawn], rdx
		mov   qword[rbp+Pos.typeBB+8*rsi], rdi
		mov   byte[rbp+Pos.board+r14], 0
		and   rdi, rdx
	     popcnt   rdi, rdi, rdx
		shl   r10d, 6+3
	      vmovq   xmm7, qword[Zobrist_Pieces+r10+8*r14]
	      vpxor   xmm5, xmm5, xmm7
	      vpxor   xmm4, xmm4, xmm7
	      vmovq   xmm7, qword[Zobrist_Pieces+r10+8*rdi]
	      vpxor   xmm3, xmm3, xmm7
	      vmovq   xmm1, qword[Scores_Pieces+r10+8*r14]
	     vpsubd   xmm6, xmm6, xmm1
                shr   r10d, 6+3
*/
        lsl  x14, x16, 1
        sub  x14, x14, 1
        add  x14, x9, x14, lsl 3
        eor  x10, x10, 8
        eor  x16, x16, 1
        ldr  x2, [x20, 8*Pawn]
        ldr  x17, [x20, x16, lsl 3]
        mov  x4, 1
        lsl  x4, x4, x14
        bic  x2, x2, x4
        bic  x17, x17, x4
        str  x2, [x20, 8*Pawn]
        str  x17, [x20, x16, lsl 3]
        add  x7, x20, Pos.board
       strb  wzr, [x7, x14]
        and  x17, x17, x2
        Popcnt  x17, x17, x2
        lea  x6, Zobrist_Pieces
        lea  x7, Scores_Pieces
        add  x6, x6, x10, lsl 9
        add  x7, x7, x10, lsl 9
        ldr  d7, [x6, x14, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        eor  v4.8b, v4.8b, v7.8b
        ldr  d7, [x6, x17, lsl 3]
        eor  v3.8b, v3.8b, v7.8b
        ldr  d1, [x7, x14, lsl 3]
        sub  v6.2s, v6.2s, v1.2s
/*
                ;xor   r10d, 8  ; not needed only care about lower 3 bits
		lea   eax, [8*rsi+Pawn]
		mov   word[rbx+sizeof.State+State.rule50], 0
		mov   byte[rbx+sizeof.State+State.capturedPiece], al
	      movzx   edi, byte[rbp+Pos.pieceEnd+8*rsi+Pawn]
		sub   edi, 1
	      movzx   edx, byte[rbp+Pos.pieceList+rdi]
	      movzx   eax, byte[rbp+Pos.pieceIdx+r14]
		mov   byte[rbp+Pos.pieceEnd+8*rsi+Pawn], dil
		mov   byte[rbp+Pos.pieceIdx+rdx], al
		mov   byte[rbp+Pos.pieceList+rax], dl
		mov   byte[rbp+Pos.pieceList+rdi], 64
		xor   esi, 1
		jmp   .SpecialRet
*/
        mov  x0, Pawn
        add  x0, x0, x16, lsl 3
       strh  wzr, [x21, 1*sizeof.State + State.rule50]
       strb  w0, [x21, 1*sizeof.State + State.capturedPiece]
        add  x6, x20, x16, lsl 3
       ldrb  w17, [x6, Pos.pieceEnd + Pawn]
        sub  w17, w17, 1
        add  x6, x20, Pos.pieceList
       ldrb  w2, [x6, x17]
        add  x6, x20, Pos.pieceIdx
       ldrb  w0, [x6, x14]
        add  x6, x20, x16, lsl 3
       strb  w17, [x6, Pos.pieceEnd + Pawn]
        add  x6, x20, Pos.pieceIdx
       strb  w0, [x6, x2]
        add  x6, x20, Pos.pieceList
       strb  w2, [x6, x0]
        mov  w0, 64
       strb  w0, [x6, x17]
        eor  x16, x16, 1
        
          b  Move_Do.SpecialRet

Move_Do.Castling:
/*
	; r8 = kfrom
	; r9 = rfrom
	; ecx = kto
	; edx = rto
	; r10 = ourking
	; r11 = our rook
	; fix things caused by kingXrook encoding
		mov   byte[rbx+sizeof.State+State.capturedPiece], 0

	; move the pieces
		mov   edx, r8d
		and   edx, 56
		cmp   r9d, r8d
		sbb   eax, eax
		lea   r14d, [rdx+4*rax+FILE_G]
		lea   edx, [rdx+2*rax+FILE_F]
		lea   r11d, [r10-King+Rook]

		mov   byte[rbp+Pos.board+r8], 0
		mov   byte[rbp+Pos.board+r9], 0
		mov   byte[rbp+Pos.board+r14], r10l
		mov   byte[rbp+Pos.board+rdx], r11l

	      movzx   eax, byte[rbp+Pos.pieceIdx+r8]
	      movzx   edi, byte[rbp+Pos.pieceIdx+r9]
		mov   byte[rbp+Pos.pieceList+rax], r14l
		mov   byte[rbp+Pos.pieceList+rdi], dl
		mov   byte[rbp+Pos.pieceIdx+r14], al
		mov   byte[rbp+Pos.pieceIdx+rdx], dil
*/
       strb  wzr, [x21, 1*sizeof.State + State.capturedPiece]
        and  x2, x8, 56
        cmp  x9, x8
       cset  x0, hi
        add  x14, x2, x0, lsl 2
        add  x2, x2, x0, lsl 1
        add  x14, x14, FILE_C
        add  x2, x2, FILE_D
        add  x11, x10, -King + Rook

        add  x7, x20, Pos.board
       strb  wzr, [x7, x8]
       strb  wzr, [x7, x9]
       strb  w10, [x7, x14]
       strb  w11, [x7, x2]

        add  x7, x20, Pos.pieceIdx
       ldrb  w0, [x7, x8]
       ldrb  w17, [x7, x9]
        add  x7, x20, Pos.pieceList
       strb  w14, [x7, x0]
       strb  w2, [x7, x17]
        add  x7, x20, Pos.pieceIdx
       strb  w0, [x7, x14]
       strb  w17, [x7, x2]
/*
	; now move rook to the back of the list
	      movzx   eax, byte[rbp+Pos.pieceEnd+r11]
		sub   eax, 1
	      movzx   r12d, byte[rbp+Pos.pieceList+rax]
	       ;;xchg   byte[rbp+Pos.pieceList+rdi], byte[rbp+Pos.pieceList+rax]
	      movzx   edx, byte[rbp+Pos.pieceList+rdi]
	      movzx   r13d, byte[rbp+Pos.pieceList+rax]
		mov   byte[rbp+Pos.pieceList+rdi], r13l
		mov   byte[rbp+Pos.pieceList+rax], dl
	       ;;xchg   byte[rbp+Pos.pieceIdx+rdx], byte[rbp+Pos.pieceIdx+r12]
	      movzx   edi, byte[rbp+Pos.pieceIdx+rdx]
	      movzx   r13d, byte[rbp+Pos.pieceIdx+r12]
		mov   byte[rbp+Pos.pieceIdx+rdx], r13l
		mov   byte[rbp+Pos.pieceIdx+r12], dil
*/
        add  x7, x20, Pos.pieceEnd
       ldrb  w0, [x7, x11]
        sub  w0, w0, 1
        add  x7, x20, Pos.pieceList
       ldrb  w12, [x7, x0]
       ldrb  w2, [x7, x17]
       ldrb  w13, [x7, x0]
       strb  w13, [x7, x17]
       strb  w2, [x7, x0]
        add  x7, x20, Pos.pieceIdx
       ldrb  w17, [x7, x2]
       ldrb  w13, [x7, x12]
       strb  w13, [x7, x2]
       strb  w17, [x7, x12]
/*
		shl   r10d, 6+3
		shl   r11d, 6+3

		mov   rax, qword[Zobrist_Pieces+r10+8*r8]
		xor   rax, qword[Zobrist_Pieces+r11+8*r9]
		xor   rax, qword[Zobrist_Pieces+r10+8*r14]
		xor   rax, qword[Zobrist_Pieces+r11+8*rdx]
	      vmovq   xmm7, rax
	      vpxor   xmm5, xmm5, xmm7

	      vmovd   xmm1, dword[Scores_Pieces+r10+8*r8]
	      vmovd   xmm2, dword[Scores_Pieces+r11+8*r9]
	     vpsubd   xmm6, xmm6, xmm1
	     vpsubd   xmm6, xmm6, xmm2
	      vmovd   xmm1, dword[Scores_Pieces+r10+8*r14]
	      vmovd   xmm2, dword[Scores_Pieces+r11+8*rdx]
	     vpaddd   xmm6, xmm6, xmm1
	     vpaddd   xmm6, xmm6, xmm2
                shr   r10d, 6+3
*/
        lea  x7, Zobrist_Pieces
        add  x6, x7, x10, lsl 6+3
        add  x7, x7, x11, lsl 6+3
        ldr  d7, [x6, x8, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        ldr  d7, [x7, x9, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        ldr  d7, [x6, x14, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        ldr  d7, [x7, x2, lsl 3]
        eor  v5.8b, v5.8b, v7.8b
        add  x6, x6, Scores_Pieces - Zobrist_Pieces
        add  x7, x7, Scores_Pieces - Zobrist_Pieces
        ldr  d1, [x6, x8, lsl 3]
        ldr  d2, [x7, x9, lsl 3]
        sub  v6.2s, v6.2s, v1.2s
        sub  v6.2s, v6.2s, v2.2s
        ldr  d1, [x6, x14, lsl 3]
        ldr  d2, [x7, x2, lsl 3]
        add  v6.2s, v6.2s, v1.2s
        add  v6.2s, v6.2s, v2.2s
/*
		mov   rax, qword[rbp+Pos.typeBB+8*rsi]
		mov   r13, qword[rbp+Pos.typeBB+8*King]
		mov   r11, qword[rbp+Pos.typeBB+8*Rook]
*/
        ldr  x0, [x20, x16, lsl 3]
        ldr  x13, [x20, 8*King]
        ldr  x11, [x20, 8*Rook]
//		btr   rax, r8
        mov  x4, 1
        lsl  x4, x4, x8
        bic  x0, x0, x4
//		btr   rax, r9
        mov  x4, 1
        lsl  x4, x4, x9
        bic  x0, x0, x4
//		bts   rax, r14
        mov  x4, 1
        lsl  x4, x4, x14
        orr  x0, x0, x4
//		bts   rax, rdx
        mov  x4, 1
        lsl  x4, x4, x2
        orr  x0, x0, x4
//		btr   r13, r8
        mov  x4, 1
        lsl  x4, x4, x8
        bic  x13, x13, x4
//		bts   r13, r14
        mov  x4, 1
        lsl  x4, x4, x14
        orr  x13, x13, x4
//		btr   r11, r9
        mov  x4, 1
        lsl  x4, x4, x9
        bic  x11, x11, x4
//		bts   r11, rdx
        mov  x4, 1
        lsl  x4, x4, x2
        orr  x11, x11, x4
/*
		mov   qword[rbp+Pos.typeBB+8*rsi], rax
		mov   qword[rbp+Pos.typeBB+8*King], r13
		mov   qword[rbp+Pos.typeBB+8*Rook], r11
		jmp   .SpecialRet
*/
        str  x0, [x20, x16, lsl 3]
        str  x13, [x20, 8*King]
        str  x11, [x20, 8*Rook]
          b  Move_Do.SpecialRet

