; printing and parsing stuff
; string functions

StringLength:
	; in rcx addres of string
	; out eax length of string
		 or   eax, -1
	@@:	inc   eax
		cmp   byte[rcx+rax], 0
		jne   @b
		ret

;;;;;;;;;;;;;;;;;; scores ;;;;;;;;;;;;;;;;;;;

PrintScore_Uci:
		cmp   ecx, +VALUE_NONE
		 je   .pNone
		 jg   .bad
		cmp   ecx, -VALUE_NONE
		 je   .nNone
		 jl   .bad
		cmp   ecx, +VALUE_INFINITE
		 je   .pInf
		cmp   ecx, -VALUE_INFINITE
		 je   .nInf
		cmp   ecx, +VALUE_MATE-MAX_PLY
		jge   .pMate
		cmp   ecx, -VALUE_MATE+MAX_PLY
		jle   .nMate

		mov   eax, 'cp '
	      stosd
		sub   rdi, 1

		mov   eax, ecx
		mov   ecx, 100
	       imul   eax, ecx
		cdq
		mov   ecx, PawnValueEg
	       idiv   ecx
	     movsxd   rax, eax
	       call   PrintSignedInteger
		ret
.pMate:
		mov   rax, 'mate '
	      stosq
		sub   rdi, 3
		mov   eax, VALUE_MATE+1
		sub   eax, ecx
		shr   eax, 1
	       call   PrintUnsignedInteger
		ret
.nMate:
		mov   rax, 'mate -'
	      stosq
		sub   rdi, 2
		mov   eax, VALUE_MATE
		add   eax, ecx
		shr   eax, 1
	       call   PrintUnsignedInteger
		ret
.nNone:
		mov   al,'-'
	      stosb
.pNone:
		mov   eax, 'NONE'
	      stosd
		ret
.nInf:
		mov   al,'-'
	      stosb
.pInf:
		mov   rax, 'INFINITE'
	      stosq
		ret

.bad:
		mov   eax, 'bad '
	      stosd
	     movsxd   rax, ecx
		jmp   PrintSignedInteger







;;;;;;;;;;;;;;;;;;;;;;; strings ;;;;;;;;;;;;;;;;;;;;;;;;


PrintString:
	      movzx   eax, byte[rcx]
		lea   rcx, [rcx+1]
		cmp   al, 0
		 je   .Done
	      stosb
		jmp   PrintString
.Done:		ret


CmpString:
	; if beginning of string at rsi matches null terminated string at rcx
	;    then advance rsi to end of match and return non zero,
	;    else return zero and do nothing
	       push   rsi
.Next:	      movzx   eax, byte[rcx]
		lea   rcx, [rcx+1]
	       test   al, al
		 jz   .Found
		cmp   al, byte [rsi]
		lea   rsi,[rsi+1]
		 je   .Next
.NoMatch:	pop   rsi
		xor   eax, eax
		ret
.Found: 	pop   rax
		 or   eax, -1
		ret


CmpStringCaseless:
	; if beginning of string at rsi matches null terminated string at rcx
	;    then advance rsi to end of match and return non zero,
	;    else return zero and do nothing
	;  string at rcx is expected to already be lower case
	       push   rsi
.Next:	      movzx   eax, byte[rsi]
	      movzx   edx, byte[rcx]
	    ToLower   eax
		lea   rcx, [rcx+1]
	       test   edx, edx
		 jz   .Found
		cmp   eax, edx
		lea   rsi, [rsi+1]
		 je   .Next
.NoMatch:	pop   rsi
		xor   eax, eax
		ret
.Found: 	pop   rax
		 or   eax, -1
		ret


	; skip spaces of string at rsi
	@@:	add   rsi, 1
SkipSpaces:	cmp   byte[rsi], ' '
		 je   @b
		ret


	; write at most ecx characters of string at rsi to rdi
	@@:	add   rsi, 1
	      stosb
ParseToEndLine:
	      movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		cmp   eax, ' '
		jae   @b
	@@:	ret


	; write at most ecx characters of string at rsi to rdi
	@@:	add   rsi, 1
	      stosb
ParseToken:   movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		 bt   [TokenCharacters], eax
		 jc   @b
	@@:	ret


	; skip at most ecx characters of string at rsi
	@@:	add   rsi,1
SkipToken:    movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		 bt   [TokenCharacters], eax
		 jc   @b
	@@:	ret
align 4
TokenCharacters:dd 0
		dd 00000111111111111000000000000000b
		dd 00010111111111111111111111111110b
		dd 00000111111111111111111111111110b

;;;;;;;;;;;;;;;;;;;;;;;; moves ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintUciMove:
	       call   _PrintUciMove
		mov   qword[rdi], rax
		add   rdi, rdx
		ret

_PrintUciMove:
	; in:  ecx  move
	;      edx  is chess960
	; out: rax  move string
	;      edx  byte length of move string  4 or 5 for promotions
		mov   r8d, ecx
		shr   r8d, 6
		and   r8d, 63	; r8d = from
		mov   r9d, ecx
		and   r9d, 63	; r9d = to
		mov   eax, 'NONE'
	       test   ecx, ecx
		 jz   .Return
		mov   eax, 'NULL'
		cmp   ecx, MOVE_NULL
		 jz   .Return

	; castling requires special attention
		cmp   r9d, r8d
		sbb   eax, eax
		mov   r10d, r9d
		and   r10d, 56
		lea   r10d, [r10+4*rax+FILE_G]
		shr   ecx, 12
		lea   eax, [ecx-MOVE_TYPE_CASTLE]
		 or   eax, edx
	      cmovz   r9d, r10d

		mov   edx, r9d
		and   r9d, 7
		and   edx, 56
		shl   edx, 5
		lea   eax, [rdx+r9+'a1']

		shl   eax, 16

		mov   edx, r8d
		and   r8d, 7
		and   edx, 56
		shl   edx, 5
		add   edx, r8d
		lea   eax, [rax+rdx+'a1']

		sub   ecx, MOVE_TYPE_PROM
		cmp   ecx, 4
		 jb   .Promotion
.Return:
		mov   edx, 4
		ret
.Promotion:
		shl   ecx, 3
		mov   edx, 'nbrq'
		shr   edx, cl
		and   edx, 0x0FF
		shl   rdx, 32
		 or   rax, rdx
		mov   edx, 5
		ret


if DEBUG > 0 | VERBOSE > 0
PrintUciMoveLong:
	; in: ecx move
	; io: rdi string for move, the move type (upper 4 bits) are displayed after
	       push   rcx
	       call   PrintUciMove
		pop   rax
		shr   eax, 12
		lea   rcx, [.error]
		cmp   eax, 8
		jae   PrintString
		lea   rcx, [.normal+8*rax]
		jmp   PrintString
.normal:
 db '.NORML',0,0
 db '.PROM N',0
 db '.PROM B',0
 db '.PROM R',0
 db '.PROM Q',0
 db '.CASTL',0,0
 db '.EPCAP',0,0
.error:
 db '.?????',0,0
 db '.?????',0,0
end if




ParseUciMove:
	; if string at rsi is a legal move, it is return in eax and rsi is advanced,
	;   othersize MOVE_NONE (0) is return and rsi is unchanged

	       push   rbx rdi rsi
virtual at rsp
  .moveList    rb sizeof.ExtMove*MAX_MOVES
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize

		lea   rdi, [.moveList]
		mov   rbx, qword[rbp+Pos.state]
	       call   SetCheckInfo
	       call   Gen_Legal
		xor   eax, eax
	      stosd

		mov   ebx, dword[rsi]
	      movzx   eax, byte[rsi+4]
	    ToLower   eax
		mov   edx, ' '
		sub   edx, eax
		adc   rsi, 4
		sar   edx, 31
		and   eax, edx
		shl   rax, 32
		 or   rbx, rax
		lea   rdi, [.moveList-sizeof.ExtMove]
.CheckNext:
		add   rdi, sizeof.ExtMove
		mov   ecx, dword[rdi+ExtMove.move]
		xor   eax, eax
	       test   ecx, ecx
		 jz   .Failed
		mov   edx, dword[rbp+Pos.chess960]
	       call   _PrintUciMove	   ; string result is in rax
		cmp   rax, rbx
		jne   .CheckNext

		mov   eax, dword[rdi+ExtMove.move]
		add   rsp, .localsize
		pop   rdx rdi rbx	   ; move found - keep advanced value of rsi
		ret

.Failed:
		add   rsp, .localsize
		pop   rsi rdi rbx
		ret






;;;;;;;;;;;; bitboard ;;;;;;;;;;;;;;;;;;;

;PrintBitboard:   ; in: rcx bitboard
;                 ; io: rdi string
;                xor   edx, edx
;       .NextBit:
;                xor   edx, 0111000b  ; don't print upside down
;                 bt   rcx, rdx
;                sbb   eax, eax
;                xor   edx, 0111000b  ;
;                add   edx, 1
;                and   eax, 'X'-'.'
;                add   eax, '. ' + (10 shl 16)
;              stosd
;                mov   eax, edx
;                and   eax, 7
;                neg   eax
;                sbb   rdi, 1
;                cmp   edx, 64
;                 jb   .NextBit
;                ret

if VERBOSE > 0
PrintBitboardCompact:
	       push   rsi
		mov   rsi, rcx
	@@:    test   rsi, rsi
		 jz   @f
		bsf   rcx, rsi
	       blsr   rsi, rsi, rax
	       call   PrintSquare
		mov   al, ' '
	      stosb
		jmp   @b
	@@:	pop   rsi
		ret
end if

;;;;;;;;;;;;; square ;;;;;;;;;;;;;;;;

PrintSquare:
		mov   al,'-'
		cmp   ecx, 64
		jae   .none
		mov   eax, ecx
		and   eax, 7
		add   eax, 'a'
	      stosb
		mov   eax, ecx
		shr   eax, 3
		add   eax, '1'
.none:
	      stosb
		ret

ParseSquare:
	; if string at rsi is a square return it
	;    else return 65 and don't change rsi
		mov   rdx, rsi
		xor   eax, eax
	      lodsb
		mov   ecx, eax
		cmp   al, '-'
		 je   .none
		sub   ecx, 'a'
		 js   .error
		cmp   ecx, 8
		jae   .error
		xor   eax, eax
	      lodsb
		sub   eax, '1'
		 js   .error
		cmp   eax, 8
		jae   .error
		lea   eax, [rcx+8*rax]
		ret
.none:
		mov   eax, 64
		ret
.error:
		mov   rsi, rdx
		mov   eax, 65
		ret





ParseBoole:
	; io: rsi string
	;out: rax = -1 if string starts with true
	;         = 0  otherwise
	; rsi is advanced if true or false is read

		 or   rax, -1
		mov   ecx, dword[rsi]
		add   rsi, 4
		cmp   ecx, 'true'
		 je   .done
		sub   rsi, 4
		xor   eax, eax
		cmp   ecx, 'fals'
		jne   .done
		cmp   byte[rsi+4], 'e'
		jne   .done
		add   rsi, 5
	.done:
		ret






QueryNodeAffinity:
	; in: ecx node self
	;     edx node parent  can be -1
	;     r8 address of node affinity string NULL means 'all'
	; out: eax
	;   if edx != -1
	;       eax = -1 if self appears as child of parent
	;       eax = 0 otherwise
	;   if edx = -1
	;       eax = -1 if self appears at all
	;       eax = 0 otherwise

	       push   rbx rsi rdi r12 r13 r14 r15

.self	equ r12d
.parent equ r13d
.period equ r14d
.lastno equ r15d
		mov   .self, ecx
		mov   .parent, edx
		 or   .lastno, -1
		xor   .period, .period

		mov   rsi, r8
	       test   r8, r8
		 jz   .All

	; save string start in rbx in case of parsing error
	       call   SkipSpaces
		mov   rbx, rsi

		lea   rcx, [sz_all]
	       call   CmpString
	       test   eax, eax
		jnz   .All

		lea   rcx, [sz_none]
	       call   CmpString
	       test   eax, eax
		jnz   .No
.Read:
	       call   SkipSpaces
		mov   al, byte[rsi]
		cmp   al, ' '
		 jb   .No
		cmp   al, '.'
		 je   .Period
		cmp   al, '0'
		 jb   .Error
		cmp   al, '9'
		 ja   .Error
.Number:
	       call   ParseInteger

		mov   edx, r15d
	; if no last read number, use self
		cmp   r15d, -1
	      cmove   edx, eax
	; if not preceded by period, use self
	       test   r14d, r14d
	      cmovz   edx, eax
	; if not preceded by period, update last read number
	      cmovz   r15d, eax
	; read a number so reset r14d
		xor   r14d, r14d

	; eax = read self
	; edx = read parent

	; skip if self doesn't match
		cmp   eax, .self
		jne   .Read
	; if parent is -1
		 or   eax, -1
		cmp   .parent, eax
		 je   .Return
		cmp   .parent, edx
		jne   .Read
.Return:
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret
.All:
		 or   eax, -1
		cmp   .parent, eax
		 je   .Return
		cmp   .self, .parent
		 je   .Return
.No:
		xor   eax, eax
		jmp   .Return
.Period:
		 or   r14d, -1
		add   rsi, 1
		cmp   r15d, r14d
		jne   .Read
.Error:
		lea   rdi, [Output]
		lea   rcx, [sz_error_affinity1]
	       call   PrintString
		mov   rcx, rsi
		sub   rcx, rbx
		mov   rsi, rbx
	  rep movsb
		lea   rcx, [sz_error_affinity2]
	       call   PrintString
       PrintNewLine
	       call   _WriteOut_Output
		jmp   .All





;;;;;;;;;;;;;;;; numbers ;;;;;;;;;;;;;;;;;;;;;;;;;;

ParseInteger:
	; io: rsi string
	;out: rax signed integer
	       push   rcx rdx
		xor   ecx, ecx
		xor   eax, eax
		xor   edx, edx
		cmp   byte [rsi],'-'
		 je   .neg
		cmp   byte [rsi],'+'
		 je   .pos
		jmp   .next
 .neg:		not   rdx
 .pos:		add   rsi,1
 .next: 	mov   cl, byte[rsi]
	       test   cl, cl
		 jz   .done
		sub   cl, '0'
		 js   .done
		cmp   cl, 9
		 ja   .done
		add   rsi, 1
		lea   rax, [5*rax]
		lea   rax, [2*rax+rcx]
		jmp   .next
.done:		xor   rax, rdx
		sub   rax, rdx
		pop   rdx rcx
		ret

PrintSignedInteger:
	; in: rax signed integer
	; io: rdi string
		mov   rcx, rax
		sar   rcx, 63
		mov   byte[rdi], '-'
		sub   rdi, rcx
		xor   rax, rcx
		sub   rax, rcx
PrintUnsignedInteger:
	; in: rax unsigned integer
	; io: rdi string
		mov   ecx, 10
		mov   r8, rsp
	.l1:	xor   edx, edx
		div   rcx
	       push   rdx
	       test   rax, rax
		jnz   .l1
	.l2:	pop   rax
		add   al, '0'
	      stosb
		cmp   rsp, r8
		 jb   .l2
		ret


PrintHex:
	      bswap   rcx
	      vmovq   xmm0, rcx
	      vpand   xmm1, xmm0, dqword[.Mask1]
	     vpsrlq   xmm0, xmm0, 4
	      vpand   xmm0, xmm0, dqword[.Mask1]
	 vpunpcklbw   xmm0, xmm0, xmm1
	     vpaddb   xmm1, xmm0, dqword[.Sum1]
	   vpcmpgtb   xmm0, xmm0, dqword[.Comp1]
	      vpand   xmm0, xmm0, dqword[.Num1]
	     vpaddb   xmm0, xmm0, xmm1
	    vmovdqu   dqword[rdi], xmm0
		add   rdi, 16
		ret
align 16
  .Sum1  dq 3030303030303030h, 3030303030303030h
  .Mask1 dq 0f0f0f0f0f0f0f0fh, 0f0f0f0f0f0f0f0fh
  .Comp1 dq 0909090909090909h, 0909090909090909h
  .Num1  dq 2727272727272727h, 2727272727272727h
