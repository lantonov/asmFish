MainHash_Create:
	; allocate some hash on startup
	       push   rbx rsi rdi
		lea   rsi, [mainHash]
		mov   esi, 16
		mov   dword[mainHash.sizeMB], esi
		shl   rsi, 20
		mov   rcx, rsi
	       call   _VirtualAlloc
		xor   edx, edx
		shr   rsi, 5	; cluster size is 32 bytes
		sub   rsi, 1
		mov   qword[mainHash.table], rax
		mov   qword[mainHash.mask], rsi
		mov   qword[mainHash.lpSize], rdx
		mov   byte[mainHash.date], dl
		pop   rdi rsi rbx
		ret


MainHash_ReadOptions:
	       push   rbx rsi rdi
		lea   rsi, [mainHash]

		mov   ecx, dword[options.hash]
		mov   edx, MAX_HASH_LOG2MB
		xor   eax, eax
		bsr   eax, ecx
		cmp   eax, edx
	      cmova   eax, edx
		xor   esi, esi
		bts   esi, eax
	; esi is requested size in MB

		mov   rdi, qword[mainHash.lpSize]
	      movzx   ebx, byte[options.largePages]

	; if requested matches current, then don't do anything
		cmp   esi, dword[mainHash.sizeMB]
		jne   @f
		cmp   rdi, 1
		sbb   eax, eax
		xor   al, bl
		jnz   .Skip
	@@:

	; free current
	       call   MainHash_Free

		mov   dword[mainHash.sizeMB], esi
		shl   rsi, 20
	; rsi = # of bytes in HashTable

	       test   bl, bl
		 jz   .NoLP
.LP:
		mov   rcx, rsi
	       call   _VirtualAlloc_LargePages
	       test   rax, rax
		jnz   .Done
.NoLP:
		mov   rcx, rsi
	       call   _VirtualAlloc
		xor   edx, edx
.Done:
		shr   rsi, 5	; cluster size is 32 bytes
		sub   rsi, 1
		mov   qword[mainHash.table], rax
		mov   qword[mainHash.mask], rsi
		mov   qword[mainHash.lpSize], rdx
		mov   byte[mainHash.date], 0
	       call   MainHash_DisplayInfo
.Skip:
		pop   rdi rsi rbx
		ret



MainHash_DisplayInfo:

if VERBOSE < 2
	       push   rbx rsi rdi
		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing hash'
	      stosq
		mov   rax, ' set to '
	      stosq
		mov   eax, dword[mainHash.sizeMB]
	       call   PrintUnsignedInteger
		mov   eax, ' MB'
	      stosd
		sub   rdi, 1

		mov   rcx, qword[mainHash.lpSize]
	       test   rcx, rcx
		 jz   .NoLargePages
		mov   rax, ' page si'
	      stosq
		mov   eax, 'ze '
	      stosd
		sub   rdi, 1
		mov   rax, qword[LargePageMinSize]
		shr   rax, 10
	       call   PrintUnsignedInteger
		mov   eax, ' KB'
	      stosd
		jmp   .Done
.NoLargePages:
		mov   rax, ' no larg'
	      stosq
		mov   rax, 'e pages'
	      stosq
.Done:
		sub   rdi, 1
       PrintNewLine
	       call   _WriteOut_Output

		pop   rdi rsi rbx
end if

		ret



if USE_HASHFULL
MainHash_HashFull:
	; out: eax hash usage per thousand
	;    dirty secret: its actually per 999
		xor   eax, eax
		mov   r8, qword[mainHash.table]
	      movzx   edx, byte[mainHash.date]
		lea   r9, [r8+32*(1000/3)]	; three entires per cluster
.NextCluster:
	irps i, 0 1 2 {
	      movzx   ecx, byte[r8+8*i+MainHashEntry.genBound]
		xor   ecx, edx
		and   ecx, 0xFFFFFFFC
		cmp   ecx, 1
		adc   eax, 0
	}
		add   r8, 32
		cmp   r8, r9
		 jb   .NextCluster
		ret
end if


MainHash_Clear:
	; hmmm, not sure if we want calling thread to touch each hash page
	       push   rdi
		mov   rdi, qword[mainHash.table]
		mov   ecx, dword[mainHash.sizeMB]
		shl   rcx, 20-3    ; convert MB to qwords
		xor   eax, eax
	  rep stosq
		pop   rdi
		ret


MainHash_Destroy:
MainHash_Free:
	       push   rbp
		mov   rcx, qword[mainHash.table]
		mov   rax, qword[mainHash.lpSize]
		mov   edx, dword[mainHash.sizeMB]
		shl   rdx, 20
	       test   rax, rax
	     cmovnz   rdx, rax
	       call   _VirtualFree
		xor   eax, eax
		mov   qword[mainHash.table], rax
		mov   qword[mainHash.lpSize], rax
		mov   qword[mainHash.sizeMB], rax
		pop   rbp
		ret







MainHash_LoadFile:
	       push   rbx rsi rdi r12 r15

		mov   rcx, qword[options.hashPath]
		mov   rax, '<empty>'
		cmp   rax, qword[rcx]
		 je   .Failed
	       call   _FileOpenRead
		mov   r15, rax
		cmp   rax, -1
		 je   .Failed
	; r15 is file handle

		mov   rcx, r15
	       call   _FileSize
	       test   rax, (1 shl 20) - 1
		jnz   .Failed			; not a multiple of 1MB
		shr   rax, 20
		 jz   .Failed

	; rsi is rounded file size in MB
		bsr   rax, rax
		xor   esi, esi
		bts   esi, eax
		mov   dword[options.hash], esi
	       call   MainHash_ReadOptions

	; rsi rounded size in bytes
		shl   rsi, 20
	; edi is number of bytes written
		xor   r12, r12
	; ebx is chuck size to read
	; read in chink sizes ranging from 1MB to 256MB
		mov   ebx, 1 shl 20
repeat 8
	       test   rbx, rsi
		jnz   .ReadLoop
		shl   ebx, 1
end repeat

.ReadLoop:
		mov   rcx, r15
		mov   rdx, qword[mainHash.table]
		add   rdx, rdi
		mov   r8d, ebx
	       call   _FileRead
	       test   eax, eax
		 jz   .Failed
		add   r12, rbx

		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing read'
	      stosq
		mov   al, ' '
	      stosb
		mov   rax, r12
		shr   rax, 20
	       call   PrintUnsignedInteger
		mov   rax, ' MB of '
	      stosq
		sub   rdi, 1
		mov   rax, rsi
		shr   rax, 20
	       call   PrintUnsignedInteger
		mov   rax, ' MB'
	      stosd
		sub   rdi, 1
       PrintNewLine
	       call   _WriteOut_Output


		cmp   r12, rsi
		 jb   .ReadLoop

		mov   rcx, r15
	       call   _FileClose
.Return:
		pop   r15 r12 rdi rsi rbx
		ret

.Failed:
		lea   rdi, [Output]
		lea   rcx, [sz_error_hashread]
	       call   PrintString
       PrintNewLine
	       call   _WriteOut_Output
		mov   rcx, r15
		cmp   rcx, -1
		 je   .Return
	       call   _FileClose
		jmp   .Return







MainHash_SaveFile:
	       push   rbx rsi rdi r12 r15

		mov   rcx, qword[options.hashPath]
		mov   rax, '<empty>'
		cmp   rax, qword[rcx]
		 je   .Failed
	       call   _FileOpenWrite
		mov   r15, rax
		cmp   rax, -1
		 je   .Failed
	; r15 is file handle

		mov   esi, dword[mainHash.sizeMB]

	; rsi rounded size in bytes
		shl   rsi, 20
	; r12 is number of bytes written
		xor   r12, r12
	; ebx is chuck size to read
	; read in chink sizes ranging from 1MB to 256MB
		mov   ebx, 1 shl 20
repeat 8
	       test   rbx, rsi
		jnz   .WriteLoop
		shl   ebx, 1
end repeat

.WriteLoop:
		mov   rcx, r15
		mov   rdx, qword[mainHash.table]
		add   rdx, rdi
		mov   r8d, ebx
	       call   _FileWrite
	       test   eax, eax
		 jz   .Failed
		add   r12, rbx
		lea   rdi, [Output]
		mov   rax, 'info str'
	      stosq
		mov   rax, 'ing save'
	      stosq
		mov   eax, 'd '
	      stosw
		mov   rax, r12
		shr   rax, 20
	       call   PrintUnsignedInteger
		mov   rax, ' MB of '
	      stosq
		sub   rdi, 1
		mov   rax, rsi
		shr   rax, 20
	       call   PrintUnsignedInteger
		mov   rax, ' MB'
	      stosd
		sub   rdi, 1
       PrintNewLine
	       call   _WriteOut_Output
		cmp   r12, rsi
		 jb   .WriteLoop

		mov   rcx, r15
	       call   _FileClose
.Return:
		pop   r15 r12 rdi rsi rbx
		ret


.Failed:
		lea   rdi, [Output]
		lea   rcx, [sz_error_hashread]
	       call   PrintString
       PrintNewLine
	       call   _WriteOut_Output
		mov   rcx, r15
		cmp   rcx, -1
		 je   .Return
	       call   _FileClose
		jmp   .Return
