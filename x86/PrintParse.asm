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
                mov   edx, VALUE_MATE + 1
		cmp   ecx, VALUE_MATE - MAX_PLY
		jge   .pMate
                mov   edx, -VALUE_MATE
		cmp   ecx, -VALUE_MATE + MAX_PLY
		jle   .nMate

		mov   eax, 'cp '
	      stosd
		sub   rdi, 1

		mov   eax, ecx
		mov   ecx, 100
	       imul   eax, ecx
		mov   ecx, PawnValueEg
.divideNPrint:
		cdq
	       idiv   ecx
	        jmp   PrintInt32
.pMate:
.nMate:
		mov   rax, 'mate '
	      stosq
		sub   rdi, 3
                mov   eax, edx
                sub   eax, ecx
                mov   ecx, 2
		jmp   .divideNPrint




;;;;;;;;;;;;;;;;;;;;;;; strings ;;;;;;;;;;;;;;;;;;;;;;;;

PrintFancy:
        ; in: rcx address of format
        ;     rdx address of qword array
        ;     r8  address of dqword array
               push   rsi r12 r13 r14 r15
                mov   rsi, rcx
                mov   r15, rdx
                mov   r14, r8
                mov   r13, rdi
                xor   eax, eax
.Loop:
              lodsb
                cmp   al, '%'
                 je   .GotOne
                cmp   al, 0
                 je   .Done
              stosb
                jmp   .Loop
.Done:
                pop   r15 r14 r13 r12 rsi
.Return:
                ret
.GotOne:
              lodsb
                mov   r12d, eax
                cmp   al, 'a'
                 je   .Alignment
if VERBOSE > 0
                cmp   al, 'p'
                 je   .Position
end if
                cmp   al, 'n'
                 je   .NewLine
               call   ParseInteger
               test   r14, r14
                 jz   .l1
                lea   ecx, [2*rax]
           _vmovups   xmm0, [r14+8*rcx]
        .l1:    mov   rax, [r15+8*rax]
                mov   rcx, rax
                xor   edx, edx
                lea   r8, [.Return]  

if VERBOSE > 0
                cmp  r12l, 's'
                lea  r9, [.PrintScore]
              cmove  r8, r9
end if

                cmp  r12l, 'x'
                lea  r9, [PrintHex32]
              cmove  r8, r9
                cmp  r12l, 'X'
                lea  r9, [PrintHex]
              cmove  r8, r9

                cmp  r12l, 'i'
                lea  r9, [PrintInt32]
              cmove  r8, r9
                cmp  r12l, 'I'
                lea  r9, [PrintInt]
              cmove  r8, r9

                cmp  r12l, 'u'
                lea  r9, [PrintUInt32]
              cmove  r8, r9
                cmp  r12l, 'U'
                lea  r9, [PrintUInt]
              cmove  r8, r9
                
                cmp  r12l, 'm'
                lea  r9, [PrintUciMove]
              cmove  r8, r9

               call  r8
                jmp  .Loop
.NewLine:
       PrintNewLine
                mov  r13, rdi
                jmp  .Loop
.Alignment:
               call  ParseInteger
                lea  rcx, [r13+rax]
                mov  al, ' '
        .l2:    cmp  rdi, rcx
                jae  .Loop
              stosb
                jmp  .l2

if VERBOSE > 0
.Position:
                mov   qword[rbp+Pos.state], rbx
               call   Position_PrintFen
                jmp  .Loop
.PrintScore:
               push   rax
		add   eax, 0x08000
		sar   eax, 16
	       call   PrintInt32
		mov   al, ','
	      stosb
                pop   rax
	      movsx   rax, ax
	       call   PrintInt32
                jmp   .Loop
end if

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
		cmp   al, byte[rsi]
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
	@@:	
                add   rsi, 1
SkipSpaces:	cmp   byte[rsi], ' '
		 je   @b
		ret


	; write at most ecx characters of string at rsi to rdi
	@@:	
                add   rsi, 1
	      stosb
ParseToEndLine:
	      movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		cmp   eax, ' '
		jae   @b
	@@:	
                ret


	; write at most ecx characters of string at rsi to rdi
	@@:	
                add   rsi, 1
	      stosb
ParseToken:   movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		 bt   [TokenCharacters], eax
		 jc   @b
	@@:	
                ret


	; skip at most ecx characters of string at rsi
	@@:	
                add   rsi,1
SkipToken:    movzx   eax, byte[rsi]
		sub   ecx, 1
		 js   @f
		 bt   [TokenCharacters], eax
		 jc   @b
	@@:	
                ret
calign 4
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
	;      rbp  position (for is chess960)
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
		 or   eax, dword[rbp+Pos.chess960]
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


ReadLine:
    ; out: eax =  0 if success
    ;      eax = -1 if failed (file end or error)
    ;      rsi address of string start 
    ;      rcx address of string end (including new line char(s))
    ; 
    ; uses global ioBuffer struct
    ; reads one line and then returns 
    ; a line is a string of characters where the last
    ;  and only the last character is below 0x20 (the space char)
           push  rbp rbx rdi r12 r13 r14 r15
            lea  rbp, [ioBuffer]
            xor  ebx, ebx				; ebx = length of return string
            mov  r12d, dword[rbp + IOBuffer.tmp_i]
            mov  r13d, dword[rbp + IOBuffer.tmp_j]
            mov  r14, qword[rbp + IOBuffer.inputBufferSizeB]
            mov  r15, qword[rbp + IOBuffer.inputBuffer]
.ReadLoop:
            cmp  rbx, r14
            jae  .ReAlloc
.ReAllocRet:
            cmp  r12d, r13d
            jae  .GetMoreData
.GetMoreDataRet:
            mov  al, byte[rbp + IOBuffer.tmpBuffer + r12]
            add  r12d, 1
            mov  byte[r15 + rbx], al
            add  ebx, 1
            cmp  al, ' '
            jae  .ReadLoop
            mov  byte[r15 + rbx - 1], 10
            xor  eax, eax
.Return:
            mov  dword[rbp + IOBuffer.tmp_i], r12d
            mov  dword[rbp + IOBuffer.tmp_j], r13d
            mov  qword[rbp + IOBuffer.inputBufferSizeB], r14
            mov  qword[rbp + IOBuffer.inputBuffer], r15
            cmp  qword[rbp + IOBuffer.log], 0
            jge  .logger
.loggerRet:
            mov  rsi, r15
            mov  ecx, ebx
            pop  r15 r14 r13 r12 rdi rbx rbp
            ret
.GetMoreData:
            xor  r12d, r12d
            lea  rcx, [rbp + IOBuffer.tmpBuffer]
            mov  edx, sizeof.IOBuffer.tmpBuffer
           call  Os_ReadStdIn
            mov  r13d, eax
            cmp  rax, 1
            jge  .GetMoreDataRet
.Failed:
             or  eax, -1
            xor  r13d, r13d
            jmp .Return
.ReAlloc:
    ; get new buffer
            lea  rcx, [r14 + 4096]
           call  Os_VirtualAlloc
            mov  r13, rax
            mov  rdi, rax
    ; copy data
            mov  rsi, r15
            mov  rcx, r14
      rep movsb
    ; free old buffer
            mov  rcx, r15
            mov  rdx, r14
           call  Os_VirtualFree
    ; set new data
            mov  r15, r13
            add  r14, 4096
            jmp  .ReAllocRet
.logger:
           push  rax rdi
            sub  rsp, 64
            mov  rdi, rsp
            mov  eax, '<<'
          stosw
           call  Os_GetTime
           call  PrintUInt
            mov  eax, ': '
          stosw
            mov  rcx, qword[rbp + IOBuffer.log]
            mov  rdx, rsp
            mov  r8, rdi
            sub  r8, rdx
           call  Os_FileWrite
            add  rsp, 64
            mov  rcx, qword[rbp + IOBuffer.log]
            mov  rdx, r15
            mov  r8, rbx
           call  Os_FileWrite
            pop  rdi rax
            jmp  .loggerRet


WriteLine_Output:
            lea  rcx, [Output]
WriteLine:
    ; in: rcx address of string start
    ;     rdi address of string end (supposed to include new line char(s))
            mov  rdx, qword[ioBuffer + IOBuffer.log]
           test  rdx, rdx
            jns  .logger
            jmp  Os_WriteOut
.logger:
           push  rbx rcx rdi
            sub  rsp, 64
            mov  rbx, rdx
            mov  rdi, rsp
            mov  eax, '>>'
          stosw
           call  Os_GetTime
           call  PrintUInt
            mov  eax, ': '
          stosw
            mov  rcx, rbx
            mov  rdx, rsp
            mov  r8, rdi
            sub  r8, rdx
           call  Os_FileWrite
            add  rsp, 64
            mov  rdx, qword[rsp + 8*1]
            mov  r8, qword[rsp + 8*0]
            mov  rcx, rbx
            sub  r8, rdx
           call  Os_FileWrite
            pop  rdi rcx rbx
            jmp  Os_WriteOut


Log_Init:            
    ; in: rcx address of file string
    ;     0 for no string
           push  rbx rsi rdi
            lea  rbx, [ioBuffer]
            mov  rsi, rcx
            mov  rcx, qword[rbx + IOBuffer.log]
           test  rcx, rcx
             js  .no_close
           call  Os_FileClose
.no_close:
            mov  rax, -1
            mov  rcx, rsi
           test  rsi, rsi
             jz  .no_new
           call  Os_FileOpenWrite
.no_new:
            mov  qword[rbx + IOBuffer.log], rax            
            pop  rdi rsi rbx
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
       PrintNL
	       call   WriteLine_Output
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

PrintUInt32:
                mov   eax, eax
                jmp   PrintUInt
PrintInt32:
             movsxd   rax, eax
PrintInt:
PrintSignedInteger:
	; in: rax signed integer
	; io: rdi string
		mov   rcx, rax
		sar   rcx, 63
		mov   byte[rdi], '-'
		sub   rdi, rcx
		xor   rax, rcx
		sub   rax, rcx
PrintUInt:
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

PrintHex32:
                shl   rcx, 32
               call   PrintHex
                sub   rdi, 8
                ret
PrintHex:
	      bswap   rcx
	     _vmovq   xmm0, rcx
	     _vpand   xmm1, xmm0, dqword[PrintHex.Mask1]
	    _vpsrlq   xmm0, xmm0, 4
	     _vpand   xmm0, xmm0, dqword[.Mask1]
	_vpunpcklbw   xmm0, xmm0, xmm1
	    _vpaddb   xmm1, xmm0, dqword[.Sum1]
	  _vpcmpgtb   xmm0, xmm0, dqword[.Comp1]
	     _vpand   xmm0, xmm0, dqword[.Num1]
	    _vpaddb   xmm0, xmm0, xmm1
	   _vmovdqu   dqword[rdi], xmm0
		add   rdi, 16
		ret
calign 16
  .Sum1  dq 3030303030303030h, 3030303030303030h
  .Mask1 dq 0f0f0f0f0f0f0f0fh, 0f0f0f0f0f0f0f0fh
  .Comp1 dq 0909090909090909h, 0909090909090909h
  .Num1  dq 2727272727272727h, 2727272727272727h



if VERBOSE>0 | DEBUG>0 | PROFILE>0

PrintDouble:
        ; in xmm0
        ; lower double is printed
        ; this function is not robust
               push   rsi

    digits = 2
    power = 1
    repeat digits
        power = 10*power
    end repeat
                mov   rax, power
         _vcvtsi2sd   xmm1, xmm1, rax
            _vmulsd   xmm0, xmm0, xmm1
        _vcvttsd2si   rax, xmm0
                cqo
                mov   ecx, power
               idiv   rcx
                mov   rsi, rdx
	       call   PrintSignedInteger
                mov   al, '.'
              stosb
                mov   rax, rsi
                cqo
                xor   rax, rdx
                sub   rax, rdx
    repeat digits
        power = power/10
                xor   edx, edx
                mov   ecx, power
                div   rcx
                add   eax, '0'
              stosb
                mov   rax, rdx
    end repeat
                pop   rsi
                ret

end if
