EmptyTTEntry = VALUE_NONE shl (8*MainHashEntry.value)


	      align   16
MainHash_Probe:
	; in:   rcx  key
	; out:  rax  address of entry
	;       rdx  edx == -1 if found
	;            edx == 0  if not found
	;       rcx  entry (8 bytes)

;SD_String 'tt probe key='
;SD_UInt64 rcx
;SD_String '|'

ProfileInc MainHash_Probe

		mov   rax, qword[mainHash.mask]
		and   rax, rcx
		shl   rax, 5
		mov   r8, rcx
		shr   rcx, 48
		add   rax, qword[mainHash.table]
	      movzx   r11d, byte[mainHash.date]

		mov   rdx, qword[rax+8*3]
	      movsx   r8d, word[rax]
	       test   dx, dx
		 jz   .Found
		cmp   dx, cx
		 je   .FoundRefresh
		shr   rdx, 16
		add   rax, 8
	      movsx   r9d, word[rax]
	       test   dx, dx
		 jz   .Found
		cmp   dx, cx
		 je   .FoundRefresh
		shr   rdx, 16
		add   rax, 8
	      movsx   r10d, word[rax]
	       test   dx, dx
		 jz   .Found
		cmp   dx, cx
		 je   .FoundRefresh

		add   r11d, 259
		sub   rax, 8*2

	      movzx   ecx, r8l
		sar   r8d, 8
		mov   edx, r11d
		sub   edx, ecx
		and   edx, 0x0FC
		add   edx, edx
		sub   r8d, edx
	      movzx   ecx, r9l
		sar   r9d, 8
		mov   edx, r11d
		sub   edx, ecx
		and   edx, 0x0FC
		add   edx, edx
		sub   r9d, edx
	      movzx   ecx, r10l
		sar   r10d, 8
		mov   edx, r11d
		sub   edx, ecx
		and   edx, 0x0FC
		add   edx, edx
		sub   r10d, edx

		lea   rcx, [rax+8*1]
		lea   rdx, [rax+8*2]
		cmp   r8d, r9d
	      cmovg   r8d, r9d
	      cmovg   rax, rcx
		cmp   r8d, r10d
	      cmovg   rax, rdx
.Found:


		mov   rcx, VALUE_NONE shl (8*MainHashEntry.value)
		xor   edx, edx
		ret


	      align   8
.FoundRefresh:
		mov   rcx, qword[rax]
		and   rcx, 0xFFFFFFFFFFFFFF03
		 or   rcx, r11
		mov   byte[rax+MainHashEntry.genBound], cl


match =2, VERBOSE {
push rax rcx rdx r8 r9 r10 r11 r15 r14 rdi
mov r15, rax
movzx  r14d, dx
lea rdi, [VerboseOutput]
szcall PrintString, 'tt hit key='
mov rax, r14
call PrintUnsignedInteger
szcall PrintString, ' move='
movzx ecx, word[r15+MainHashEntry.move]
xor edx, edx
call PrintUciMove
szcall PrintString, ' value='
movsx rax, word[r15+MainHashEntry.value]
call PrintSignedInteger
szcall PrintString, ' eval='
movsx rax, word[r15+MainHashEntry.eval]
call PrintSignedInteger
szcall PrintString, ' depth='
movsx rax, byte[r15+MainHashEntry.depth]
call PrintSignedInteger
szcall PrintString, ' bound='
movzx  eax, byte[r15+MainHashEntry.genBound]
and eax, 3
call PrintSignedInteger
mov al, '|'
stosb
lea rcx, [VerboseOutput]
call _WriteOut
pop rdi r14 r15 r11 r10 r9 r8 rdx rcx rax
}

		 or   edx, -1

		ret

