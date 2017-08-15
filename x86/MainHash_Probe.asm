
	     calign   16
MainHash_Probe:
	; in:   rcx  key
	; out:  rax  address of entry
	;       rdx  edx == -1 if found
	;            edx == 0  if not found
	;       rcx  entry (8 bytes)

;ProfileInc MainHash_Probe

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
		mov   rcx, VALUE_NONE shl (8*MainHashEntry.value_)
		xor   edx, edx
		ret


	     calign   8
.FoundRefresh:
		mov   rcx, qword[rax]
		and   rcx, 0xFFFFFFFFFFFFFF03
		 or   rcx, r11
		mov   byte[rax+MainHashEntry.genBound], cl
		 or   edx, -1
		ret
