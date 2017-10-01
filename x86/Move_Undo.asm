
	     calign   16
Move_Undo:
	; in: rbp  address of Pos
	;     rbx  address of State
	;     ecx  move

	       push   rsi

Display 2, "Move_Undo(move=%m1)%n"

if DEBUG
		mov   dword[rbp+Pos.debugDWORD1], ecx
end if

		mov   esi, dword[rbp+Pos.sideToMove]
		xor   esi, 1

		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to
		shr   ecx, 12

	      movzx   r11d, byte[rbx+State.capturedPiece]      ; r11 = TO PIECE
	      movzx   r10d, byte[rbp+Pos.board+r9]	       ; r10 = FROM PIECE

		xor   edx, edx
		bts   rdx, r8
		bts   rdx, r9

		mov   eax, r10d
		and   eax, 7

		sub   rbx, sizeof.State
		mov   dword[rbp+Pos.sideToMove], esi
		mov   byte[rbp+Pos.board+r8], r10l
		mov   byte[rbp+Pos.board+r9], r11l
		xor   qword[rbp+Pos.typeBB+8*rax], rdx
		xor   qword[rbp+Pos.typeBB+8*rsi], rdx

		cmp   ecx, MOVE_TYPE_PROM
		jae   .Special

	      movzx   eax, byte[rbp+Pos.pieceIdx+r9]
		mov   byte[rbp+Pos.pieceList+rax], r8l
		mov   byte[rbp+Pos.pieceIdx+r8], al
		mov   eax, r11d 		; save a copy of captured piece

		and   r11d, 7
		jnz   .Captured

if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret


	     calign   8
.Captured:
		xor   esi, 1
		btr   rdx, r8
		 or   qword[rbp+Pos.typeBB+8*r11], rdx
		 or   qword[rbp+Pos.typeBB+8*rsi], rdx

	      movzx   ecx, byte[rbp+Pos.pieceEnd+rax]
		mov   byte[rbp+Pos.pieceIdx+r9], cl
		mov   byte[rbp+Pos.pieceList+rcx], r9l
		add   ecx, 1
		mov   byte[rbp+Pos.pieceEnd+rax], cl

if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret


	     calign   8
.Special:
		xor   edx, edx
		cmp   ecx, MOVE_TYPE_EPCAP
		 ja   .Castle

	      movzx   eax, byte[rbp+Pos.pieceIdx+r9]
		mov   byte[rbp+Pos.pieceList+rax], r8l
		mov   byte[rbp+Pos.pieceIdx+r8], al
		mov   eax, r11d 		; save a copy of captured piece

		 je   .EpCapture

.Prom:
	; change promoted piece back to pawn on r8d
		lea   eax, [8*rsi+Pawn]
		lea   ecx, [rcx-MOVE_TYPE_PROM+Knight]
		bts   rdx, r8
		 or   qword[rbp+Pos.typeBB+8*Pawn], rdx
		xor   qword[rbp+Pos.typeBB+8*rcx], rdx
		mov   byte[rbp+Pos.board+r8], al
		mov   byte[rbp+Pos.board+r9], r11l

	       push   rdi
		lea   ecx, [8*rsi+rcx]
	      movzx   edi, byte[rbp+Pos.pieceEnd+rcx]
		sub   edi, 1
	      movzx   edx, byte[rbp+Pos.pieceList+rdi]
	      movzx   eax, byte[rbp+Pos.pieceIdx+r8]
		mov   byte[rbp+Pos.pieceEnd+rcx], dil
		mov   byte[rbp+Pos.pieceIdx+rdx], al
		mov   byte[rbp+Pos.pieceList+rax], dl
		mov   byte[rbp+Pos.pieceList+rdi], 64

	      movzx   edx, byte[rbp+Pos.pieceEnd+8*rsi+Pawn]
		mov   byte[rbp+Pos.pieceIdx+r8], dl
		mov   byte[rbp+Pos.pieceList+rdx], r8l
		add   edx, 1
		mov   byte[rbp+Pos.pieceEnd+8*rsi+Pawn], dl
		mov   eax, r11d
		pop   rdi


		xor   edx, edx
		and   r11d, 7
		jnz   .PromCapture
if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret

.PromCapture:
		xor   esi, 1
		bts   rdx, r9
		 or   qword[rbp+Pos.typeBB+8*r11], rdx
		 or   qword[rbp+Pos.typeBB+8*rsi], rdx

	      movzx   ecx, byte[rbp+Pos.pieceEnd+rax]
		mov   byte[rbp+Pos.pieceIdx+r9], cl
		mov   byte[rbp+Pos.pieceList+rcx], r9l
		add   ecx, 1
		mov   byte[rbp+Pos.pieceEnd+rax], cl

if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret


	     calign   8
.EpCapture:
	; place 8*rsi+Pawn on square rcx

		lea   ecx, [2*rsi-1]
		lea   ecx, [r9+8*rcx]
		xor   esi, 1
		bts   rdx, rcx
		 or   qword[rbp+Pos.typeBB+8*Pawn], rdx
		 or   qword[rbp+Pos.typeBB+8*rsi], rdx
		mov   byte[rbp+Pos.board+r9], 0
		mov   byte[rbp+Pos.board+rcx], r11l

	      movzx   eax, byte[rbp+Pos.pieceEnd+r11]
		mov   byte[rbp+Pos.pieceIdx+rcx], al
		mov   byte[rbp+Pos.pieceList+rax], cl
		add   eax, 1
		mov   byte[rbp+Pos.pieceEnd+r11], al

if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret


	     calign   8
.Castle:
	; r8 = kfrom
	; r9 = rfrom
	; ecx = kto
	; edx = rto
	; r10 = ourking
	; r11 = our rook
		bts   rdx, r8
		bts   rdx, r9
		xor   qword[rbp+Pos.typeBB+8*rax], rdx
		xor   qword[rbp+Pos.typeBB+8*rsi], rdx

		lea   r10d, [8*rsi+King]
		lea   r11d, [8*rsi+Rook]
		mov   edx, r8d
		and   edx, 56
		cmp   r9d, r8d
		sbb   eax, eax
		lea   ecx, [rdx+4*rax+FILE_G]
		lea   edx, [rdx+2*rax+FILE_F]

		mov   byte[rbp+Pos.board+rcx], 0
		mov   byte[rbp+Pos.board+rdx], 0
		mov   byte[rbp+Pos.board+r8], r10l
		mov   byte[rbp+Pos.board+r9], r11l

	       push   rdi
	  ;    movzx   eax, byte[rbp+Pos.pieceIdx+rcx]
	  ;    movzx   edi, byte[rbp+Pos.pieceIdx+rdx]
	  ;      mov   byte[rbp+Pos.pieceList+rax], r8l
	  ;      mov   byte[rbp+Pos.pieceList+rdi], r9l
	  ;      mov   byte[rbp+Pos.pieceIdx+r8], al
	  ;      mov   byte[rbp+Pos.pieceIdx+r9], dil
	  ; no! above not enough instructions! official stockfish has
	  ;  castling rook moved to the back of the list
	  ;  of course this for absolutely no good reason

	      movzx   eax, byte[rbp+Pos.pieceIdx+rcx]
	      movzx   edi, byte[rbp+Pos.pieceIdx+rdx]
		mov   byte[rbp+Pos.pieceList+rax], r8l
		mov   byte[rbp+Pos.pieceList+rdi], r9l
		mov   byte[rbp+Pos.pieceIdx+r8], al
		mov   byte[rbp+Pos.pieceIdx+r9], dil
	; now move rook to the back of the list
	      movzx   eax, byte[rbp+Pos.pieceEnd+r11]
		sub   eax, 1
	      movzx   r10d, byte[rbp+Pos.pieceList+rax]
	       ;;xchg   byte[rbp+Pos.pieceList+rdi], byte[rbp+Pos.pieceList+rax]
	      movzx   r9d, byte[rbp+Pos.pieceList+rdi]
	      movzx   r11d, byte[rbp+Pos.pieceList+rax]
		mov   byte[rbp+Pos.pieceList+rdi], r11l
		mov   byte[rbp+Pos.pieceList+rax], r9l
	       ;;xchg   byte[rbp+Pos.pieceIdx+rdx], byte[rbp+Pos.pieceIdx+r12]
	      movzx   edi, byte[rbp+Pos.pieceIdx+r9]
	      movzx   r11d, byte[rbp+Pos.pieceIdx+r10]
		mov   byte[rbp+Pos.pieceIdx+r9], r11l
		mov   byte[rbp+Pos.pieceIdx+r10], dil
		pop   rdi

		mov   rax, qword[rbp+Pos.typeBB+8*rsi]
		mov   r10, qword[rbp+Pos.typeBB+8*King]
		mov   r11, qword[rbp+Pos.typeBB+8*Rook]
		btr   rax, rcx
		btr   rax, rdx
		bts   rax, r8
		bts   rax, r9
		btr   r10, rcx
		bts   r10, r8
		btr   r11, rdx
		bts   r11, r9
		mov   qword[rbp+Pos.typeBB+8*rsi], rax
		mov   qword[rbp+Pos.typeBB+8*King], r10
		mov   qword[rbp+Pos.typeBB+8*Rook], r11

if DEBUG
		jmp   Move_Undo_Check
end if
		pop   rsi
		ret




if DEBUG
Move_Undo_Check:
		mov   qword[rbp+Pos.state], rbx
	       call   Position_IsLegal
	       test   eax, eax
		jnz   @f
		pop   rsi
		ret
@@:
		lea   rdi,[DebugOutput]
		mov   rax, 'UndoMove'
	      stosq
       PrintNewLine
		mov   ecx, dword[rbp+Pos.debugDWORD1]
		xor   edx, edx
	       call   PrintUciMoveLong
       PrintNewLine
		lea   rdi, [DebugOutput]
	       call   Os_ErrorBox
               int3
end if
