MainHash_Create:
    ; allocate some hash on startup
           push  rbp rbx rsi
            lea  rbp, [mainHash]
            mov  esi, 16
            mov  dword[rbp+MainHash.sizeMB], esi
            shl  rsi, 20
            mov  rcx, rsi
           call  Os_VirtualAlloc
            xor  edx, edx
            shr  rsi, 5	; cluster size is 32 bytes
            sub  rsi, 1
            mov  qword[rbp+MainHash.table], rax
            mov  qword[rbp+MainHash.mask], rsi
            mov  qword[rbp+MainHash.lpSize], rdx
            mov  byte[rbp+MainHash.date], dl
            pop  rsi rbx rbp
            ret


MainHash_ReadOptions:
           push  rbp rbx rsi rdi rax
            lea  rbp, [mainHash]
            mov  ecx, dword[options.hash]
            mov  edx, MAX_HASH_LOG2MB
            xor  eax, eax
            bsr  eax, ecx
            cmp  eax, edx
          cmova  eax, edx
            xor  esi, esi
            bts  esi, eax
    ; esi is requested size in MB
            mov  rdi, qword[rbp+MainHash.lpSize]
          movzx  ebx, byte[options.largePages]
    ; if requested matches current, then don't do anything
            cmp  esi, dword[rbp+MainHash.sizeMB]
            jne  @1f
            cmp  rdi, 1
            sbb  eax, eax
            xor  al, bl
            jnz  .Skip
    @1:
    ; free current
           call  MainHash_Free
            mov  dword[rbp+MainHash.sizeMB], esi
            shl  rsi, 20
    ; rsi = # of bytes in HashTable
           test  bl, bl
             jz  .NoLP
.LP:
            mov  rcx, rsi
           call  Os_VirtualAlloc_LargePages
           test  rax, rax
            jnz  .Done
.NoLP:
            mov  rcx, rsi
           call  Os_VirtualAlloc
            xor  edx, edx
.Done:
            shr  rsi, 5	; cluster size is 32 bytes
            sub  rsi, 1
            mov  qword[rbp+MainHash.table], rax
            mov  qword[rbp+MainHash.mask], rsi
            mov  qword[rbp+MainHash.lpSize], rdx
            mov  byte[rbp+MainHash.date], 0
           call  MainHash_DisplayInfo
.Skip:
            pop  rax rdi rsi rbx rbp
            ret



MainHash_DisplayInfo:
if VERBOSE < 2
           push  rbx rdi rax
            lea  rdi, [Output]

            lea  rcx, [sz_hashinfo1]
            mov  eax, dword[mainHash.sizeMB]
            mov  qword[rsp+8*0], rax
            mov  rdx, rsp
            xor  r8, r8
           call  PrintFancy

            lea  rcx, [sz_hashinfo2yes]
            lea  rax, [sz_hashinfo2no]
            cmp  qword[mainHash.lpSize], 0
          cmovz  rcx, rax
            xor  r8, r8
            mov  rax, qword[LargePageMinSize]
            shr  rax, 10
            mov  qword[rsp+8*0], rax
            mov  rdx, rsp
           call  PrintFancy
           call  WriteLine_Output

            pop  rax rdi rbx
end if
            ret

sz_hashinfo1    db 'info string hash set to %U0 MB ',0
sz_hashinfo2yes db 'page size %U0 KB%n',0
sz_hashinfo2no  db 'no large pages%n',0


if USE_HASHFULL
MainHash_HashFull:
    ; out: eax hash usage per thousand
    ;    dirty secret: its actually per 999
            xor  eax, eax
            mov  r8, qword[mainHash.table]
          movzx  edx, byte[mainHash.date]
            lea  r9, [r8 + 32*(1000/3)]	; three entires per cluster
.NextCluster:
iterate i, 0, 1, 2
          movzx  ecx, byte[r8 + 8*i + MainHashEntry.genBound]
            xor  ecx, edx
            and  ecx, 0xFFFFFFFC
            cmp  ecx, 1
            adc  eax, 0
end iterate
            add  r8, 32
            cmp  r8, r9
             jb  .NextCluster
            ret
end if


MainHash_Clear:
    ; hmmm, not sure if we want calling thread to touch each hash page
           push  rdi
            mov  rdi, qword[mainHash.table]
            mov  ecx, dword[mainHash.sizeMB]
            shl  rcx, 20-3    ; convert MB to qwords
            xor  eax, eax
      rep stosq
            pop  rdi
            ret


MainHash_Destroy:
MainHash_Free:
           push  rbp
            lea  rbp, [mainHash]
            mov  rcx, qword[rbp+MainHash.table]
            mov  rax, qword[rbp+MainHash.lpSize]
            mov  edx, dword[rbp+MainHash.sizeMB]
            shl  rdx, 20
           test  rax, rax
         cmovnz  rdx, rax
           call  Os_VirtualFree
            xor  eax, eax
            mov  qword[rbp+MainHash.table], rax
            mov  qword[rbp+MainHash.lpSize], rax
            mov  qword[rbp+MainHash.sizeMB], rax
            pop  rbp
            ret




MainHash_LoadFile:
	       push   rbx rsi rdi r12 r15
                sub   rsp, 8*4
		lea   rdi, [Output]

		mov   rcx, qword[options.hashPath]
		mov   rax, '<empty>'
		cmp   rax, qword[rcx]
		 je   MainHash_Common.FailedBadFile
	       call   Os_FileOpenRead
		mov   r15, rax
		cmp   rax, -1
		 je   MainHash_Common.FailedBadFile
	; r15 is file handle

		mov   rcx, r15
	       call   Os_FileSize
	       test   eax, (1 shl 20) - 1
		jnz   MainHash_Common.FailedBadSize    ; not a multiple of 1MB
		shr   rax, 20
		 jz   MainHash_Common.FailedBadSize

		bsr   rax, rax
		xor   esi, esi
		bts   esi, eax
		mov   dword[options.hash], esi
	       call   MainHash_ReadOptions
	; rsi is rounded file size in MB

		shl   rsi, 20
	; rsi rounded size in bytes
		xor   r12, r12
	; r12 is number of bytes written
		mov   ebx, 1 shl 20
	; read in chink sizes ranging from 1MB to 256MB
    repeat 8
	       test   rbx, rsi
		jnz   .ReadLoop
		shl   ebx, 1
    end repeat
	; ebx is chuck size to read

.ReadLoop:
		lea   rdi, [Output]

		mov   rcx, r15
		mov   rdx, qword[mainHash.table]
		add   rdx, r12
		mov   r8d, ebx
	       call   Os_FileRead
	       test   eax, eax
		 jz   MainHash_Common.FailedMiddle
		add   r12, rbx

                lea   rcx, [sz_tt_update]
		mov   rax, r12
		shr   rax, 20
                mov   qword[rsp+8*0], rax
		mov   rax, rsi
		shr   rax, 20
                mov   qword[rsp+8*1], rax
                mov   rdx, rsp
                xor   r8, r8
               call   PrintFancy
	       call   WriteLine_Output

		cmp   r12, rsi
		 jb   .ReadLoop


MainHash_Common:
.Close:
		mov   rcx, r15
	       call   Os_FileClose
.Return:
                add   rsp, 8*4
		pop   r15 r12 rdi rsi rbx
		ret

.FailedBadFile:
		lea   rcx, [sz_error_badttfile]
	       call   PrintString
                mov   rcx, qword[options.hashPath]
               call   PrintString
       PrintNL
	       call   WriteLine_Output
		jmp   .Return
.FailedBadSize:
		lea   rcx, [sz_error_badttsize]
                mov   rdx, rsp
                xor   r8, r8
                mov   qword[rsp+8*0], rax
	       call   PrintFancy
	       call   WriteLine_Output
		jmp   .Close
.FailedMiddle:
                lea   rcx, [sz_error_middlett]
               call   PrintString
	       call   WriteLine_Output
		jmp   .Close





MainHash_SaveFile:
	       push   rbx rsi rdi r12 r15
                sub   rsp, 8*4
		lea   rdi, [Output]

		mov   rcx, qword[options.hashPath]
		mov   rax, '<empty>'
		cmp   rax, qword[rcx]
		 je   MainHash_Common.FailedBadFile
	       call   Os_FileOpenWrite
		mov   r15, rax
		cmp   rax, -1
		 je   MainHash_Common.FailedBadFile
	; r15 is file handle

		mov   esi, dword[mainHash.sizeMB]
		shl   rsi, 20
	; rsi rounded size in bytes
		xor   r12, r12
	; r12 is number of bytes written
		mov   ebx, 1 shl 20
	; read in chink sizes ranging from 1MB to 256MB
    repeat 8
	       test   rbx, rsi
		jnz   .WriteLoop
		shl   ebx, 1
    end repeat
	; ebx is chuck size to read

.WriteLoop:
		lea   rdi, [Output]

		mov   rcx, r15
		mov   rdx, qword[mainHash.table]
		add   rdx, r12
		mov   r8d, ebx
	       call   Os_FileWrite
	       test   eax, eax
		 jz   MainHash_Common.FailedMiddle
		add   r12, rbx

                lea   rcx, [sz_tt_update]
		mov   rax, r12
		shr   rax, 20
                mov   qword[rsp+8*0], rax
		mov   rax, rsi
		shr   rax, 20
                mov   qword[rsp+8*1], rax
                mov   rdx, rsp
                xor   r8, r8
               call   PrintFancy
	       call   WriteLine_Output

		cmp   r12, rsi
		 jb   .WriteLoop

		jmp   MainHash_Common
