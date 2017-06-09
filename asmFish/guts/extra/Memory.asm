BIT_END   = 1
BIT_USED  = 2
BIT_GHOST = 4
BLOCK_GRAN = 8	   ; must be 8
CHUNK_GRAN = 4096
HUGE_THRESHOLD = 0;100000



;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; memory functions:
;  - the speed on the Memory_Stress test is
;      ~10 million calls per second
;      with 82% of the reserved memory used
;  - code is only 600 bytes



Memory_Init:
		lea   rax, [memoryMng.firstChunk]
		lea   rdx, [memoryMng.lastChunk]
		mov   qword[rax+Chunk.prev], rax
		mov   qword[rax+Chunk.next], rdx
		mov   dword[rax+Chunk.size], 0
		mov   dword[rax+Chunk.max], 0
		mov   qword[rdx+Chunk.prev], rax
		mov   qword[rdx+Chunk.next], rdx
		mov   dword[rdx+Chunk.size], 0
		mov   dword[rdx+Chunk.max], 0
		mov   qword[memoryMng.rand], 100
		mov   qword[memoryMng.used], 0
		mov   qword[memoryMng.usedEver], 0
		mov   qword[memoryMng.reserved], 0

		lea   rax, [memoryMng.list]
		mov   qword[memoryMng.listEnd], rax
		ret




Memory_Free:
		lea   rax, [memoryMng.list]
		mov   rdx, qword[memoryMng.listEnd]
	       test   rcx, rcx
		 jz   _Memory_Free
	.check:
		cmp   rax, rdx
		jae   .failed
		cmp   rcx, qword[rax+0]
		lea   rax, [rax+16]
		jne   .check

		sub   rax, 16
		sub   rdx, 16
		mov   r8, qword[rdx+0]
		mov   r9, qword[rdx+8]
		mov   qword[rax+0], r8
		mov   qword[rax+8], r9
		mov   qword[memoryMng.listEnd], rdx
		jmp   _Memory_Free

.failed:
	     Assert   ne, eax, eax, 'freed memory not malloced'
	       int3


Memory_Alloc:
	       push   rcx
	       call   _Memory_Alloc
		pop   rcx
		add   rcx, rax
	; rax = start
	; rcx = end



		lea   r10, [memoryMng.list]
		mov   r11, qword[memoryMng.listEnd]
	.check:
		cmp   r10, r11
		jae   .done
		mov   r8, qword[r10+0]
		mov   r9, qword[r10+8]
		add   r10, 16
		cmp   rax, r9
		jae   .check
		cmp   r8, rcx
		jae   .check

	    Assert   ne, eax, eax, 'allocated memory overlap'
	       int3

	.done:
		mov   qword[r10+0], rax
		mov   qword[r10+8], rcx
		add   r10, 16
		mov   qword[memoryMng.listEnd], r10
		ret




_Memory_Free:
	 ProfileInc   MemoryFree
	       push   rbx rsi rdi
		lea   rax, [rcx-sizeof.Block]
		mov   edx, BIT_END or BIT_USED or BIT_GHOST
	       test   rax, rax
		 js   .Skip

		mov   ecx, dword[rax+Block.size]
		and   edx, ecx
		cmp   edx, BIT_END or BIT_USED or BIT_GHOST
		 je   .Huge
		and   ecx, not BIT_USED
		mov   dword[rax+Block.size], ecx
if DEBUG
		and   ecx, -BLOCK_GRAN
		sub   qword[memoryMng.used], rcx
		add   qword[memoryMng.used], sizeof.Block
		add   qword[memoryMng.freeCnt], 1
end if
	       call   .Block_FuseNext
		mov   ecx, dword[rax+Block.prev]
		neg   rcx
		 jz   .AtStart
		add   rax, rcx
	       call   .Block_FuseNext
		mov   ecx, dword[rax+Block.prev]
	       test   ecx, ecx
		 jz   .AtStart
.Return:
		mov   rdi, rax
    .find_chunk:
		mov   edx, dword[rdi+Block.prev]
		sub   rdi, rdx
	       test   edx, edx
		jnz   .find_chunk
		sub   rdi, sizeof.Chunk
		jmp   Memory_Return
.AtStart:
		mov   ecx, dword[rax+Block.size]
		and   ecx, BIT_USED or BIT_END
		cmp   ecx, BIT_END
		jne   .Return

	 ProfileInc   FreeChunk
		lea   rcx, [rax-sizeof.Chunk]
		mov   rax, qword[rcx+Chunk.prev]
		mov   rdx, qword[rcx+Chunk.next]
		mov   qword[rax+Chunk.next], rdx
		mov   qword[rdx+Chunk.prev], rax
		mov   edx, dword[rcx+Chunk.size]
if DEBUG
		sub   qword[memoryMng.reserved], rdx
end if
	       call   _VirtualFree
.Skip:
		pop   rdi rsi rbx
		ret

.Block_FuseNext:
		mov   ecx, dword[rax+Block.size]
	       test   ecx, BIT_USED or BIT_END
		 jz   .we_good
		ret
    .we_good:
		mov   edx, dword[rax+rcx+Block.size]
	       test   edx, BIT_USED
		 jz   .next_good
		ret
    .next_good:
		 or   dword[rax+rcx+Block.size], BIT_GHOST
		add   ecx, edx
		mov   dword[rax+Block.size], ecx
	       test   ecx, BIT_END
		 jz   .set_prev
		ret
    .set_prev:
		mov   dword[rax+rcx+Block.prev], ecx
		ret
.Huge:
		lea   rcx, [rax+sizeof.Block-sizeof.Chunk]
		mov   rax, qword[rcx+Chunk.size]
		and   rax, -BLOCK_GRAN
		lea   rdx, [rax+CHUNK_GRAN-1]
		and   rdx, -CHUNK_GRAN
if DEBUG
		sub   qword[memoryMng.used], rax
		add   qword[memoryMng.used], sizeof.Chunk
		add   qword[memoryMng.freeCnt], 1
		sub   qword[memoryMng.reserved], rdx
end if
	       call   _VirtualFree
		pop   rdi rsi rbx
		ret






Memory_Return:
		mov   rsi, qword[rdi+Chunk.prev]
		mov   rbx, qword[rdi+Chunk.next]
		mov   qword[rsi+Chunk.next], rbx
		mov   qword[rbx+Chunk.prev], rsi
		lea   rsi, [memoryMng.firstChunk]
		mov   rbx, qword[rsi+Chunk.next]
		mov   qword[rsi+Chunk.next], rdi
		mov   qword[rbx+Chunk.prev], rdi
		mov   qword[rdi+Chunk.next], rbx
		mov   qword[rdi+Chunk.prev], rsi
		mov   qword[rdi+Chunk.recentBlock], rax
		add   rax, sizeof.Block
		pop   rdi rsi rbx
		ret




_Memory_Alloc:
	 ProfileInc   MemoryAlloc
	       push   rbx rsi rdi
		lea   rdi, [memoryMng.firstChunk]
		lea   esi, [rcx+BLOCK_GRAN-1+sizeof.Block]
		and   esi, -BLOCK_GRAN

		cmp   rcx, HUGE_THRESHOLD
		jae   .Huge
if DEBUG
		add   qword[memoryMng.usedEver], rsi
		sub   qword[memoryMng.usedEver], sizeof.Block
		add   qword[memoryMng.used], rsi
		sub   qword[memoryMng.used], sizeof.Block
		add   qword[memoryMng.allocCnt], 1
end if

    .next_chunk:
		mov   rdi, qword[rdi+Chunk.next]
		mov   eax, dword[rdi+Chunk.max]
	       test   eax, eax
		 jz   .MakeNewChunk
		cmp   esi, eax
		 ja   .next_chunk
	       call   .TryChunk
	       test   rax, rax
		 jz   .next_chunk
		jmp   Memory_Return
.MakeNewChunk:
		lea   rdi, [memoryMng.firstChunk]
		mov   rbx, qword[rdi+Chunk.next]

		mov   ecx, esi
		shr   ecx, 12
		sub   ecx, 4
		mov   eax, ecx
		sar   eax, 31
		xor   ecx, eax
		sub   ecx, eax
		neg   ecx
		xor   eax, eax
		add   ecx, 4
	      cmovs   ecx, eax
		shl   ecx, 12

		lea   ecx, [rcx+rsi+CHUNK_GRAN-1+sizeof.Chunk]
		and   ecx, -CHUNK_GRAN
	       push   rcx rcx
if DEBUG
		add   qword[memoryMng.reserved], rcx
end if
	       call   _VirtualAlloc
		pop   rcx rcx
		mov   qword[rdi+Chunk.next], rax
		mov   qword[rbx+Chunk.prev], rax
		mov   qword[rax+Chunk.next], rbx
		mov   qword[rax+Chunk.prev], rdi
		mov   dword[rax+Chunk.size], ecx
		mov   rdi, rax
		add   ecx, -sizeof.Chunk+BIT_END
		mov   dword[rax+sizeof.Chunk+Block.size], ecx
		sub   ecx, esi
		lea   edx, [esi+48]
		shr   ecx, 4
		cmp   ecx, esi
	      cmovb   ecx, edx
		mov   dword[rdi+Chunk.max], ecx
		lea   rax, [rdi+sizeof.Chunk]
	       call   .Block_Split
		jmp   Memory_Return

.TryChunk:
	 ProfileInc   TryChunk
		mov   rax, qword[rdi+Chunk.recentBlock]
		xor   edx, edx
    .we_ghost:
		sub   rax, rdx
		mov   ecx, dword[rax+Block.size]
		mov   edx, dword[rax+Block.prev]
	       test   ecx, BIT_GHOST
		jnz   .we_ghost
		mov   r8, rax
		mov   r9, rax
    .block_loop:
		mov   rax, r9
	       call   .Block_Split
	       test   rax, rax
		jnz   .block_loop_done
		mov   edx, dword[r9+Block.size]
		and   edx, not BIT_USED
		add   r9, rdx
	       test   edx, BIT_END
		jnz   .block_loop_done

		mov   edx, dword[r8+Block.prev]
		sub   r8, rdx
		mov   rax, r8
	       call   .Block_Split
	       test   rax, rax
		 jz   .block_loop
    .block_loop_done:
		ret

.Block_Split:
	 ProfileInc   TryBlockSplit
		mov   ecx, dword[rax+Block.size]
	       test   ecx, BIT_USED
		jnz   .we_bad

		mov   edx, ecx
		and   ecx, not BIT_END
		cmp   ecx, esi
		 ja   .we_big
		 je   .we_fit
    .we_bad:
		xor   eax, eax
		ret
    .we_fit:
		 or   edx, BIT_USED
		mov   dword[rax+Block.size], edx
		ret
    .we_big:
		mov   ecx, esi
		 or   ecx, BIT_USED
		sub   edx, esi
		mov   dword[rax+Block.size], ecx
		mov   dword[rax+rsi+Block.size], edx
		mov   dword[rax+rsi+Block.prev], esi
	       test   edx, BIT_END
		 jz   .set_prev
		ret
    .set_prev:
		lea   rcx, [rsi+rdx]
		mov   dword[rax+rcx+Block.prev], edx
		ret


.Huge:
		lea   rsi, [rcx+BLOCK_GRAN-1+sizeof.Chunk]
		and   rsi, -BLOCK_GRAN
		lea   rcx, [rsi+CHUNK_GRAN-1]
		and   rcx, -CHUNK_GRAN

if DEBUG
		add   qword[memoryMng.usedEver], rsi
		sub   qword[memoryMng.usedEver], sizeof.Chunk
		add   qword[memoryMng.used], rsi
		sub   qword[memoryMng.used], sizeof.Chunk
		add   qword[memoryMng.allocCnt], 1
		add   qword[memoryMng.reserved], rcx
end if
	       call   _VirtualAlloc
		 or   rsi, BIT_END or BIT_USED or BIT_GHOST
		mov   qword[rax+Chunk.size], rsi
		add   rax, sizeof.Chunk
		pop   rdi rsi rbx
		ret





if DEBUG

Memory_IsOk:
	       push   rbp rbx rsi rdi r13 r14 r15
		lea   r14, [memoryMng.firstChunk]
		lea   r15, [memoryMng.lastChunk]
		xor   esi, esi
		xor   edi, edi
		xor   ebp, ebp
.NextChunk:
		mov   r14, qword[r14+Chunk.next]
		cmp   r14, r15
		 je   .ChunksDone
		lea   r13, [r14+sizeof.Chunk]
		xor   ebp, ebp
.BlockLoop:
		mov   edx, dword[r13+Block.size]
		cmp   ebp, dword[r13+Block.prev]
		mov   ebp, dword[r13+Block.size]
		jne   .Bad
		and   ebp, -BLOCK_GRAN
	       test   edx, BIT_GHOST
		jnz   .Bad
		and   edx, not BIT_USED
		add   r13, rdx
	       test   edx, BIT_END
		 jz   .BlockLoop
		xor   r13, BIT_END
		sub   r13, r14
		cmp   r13d, dword[r14+Chunk.size]
		jne   .Bad
		jmp   .NextChunk
.ChunksDone:
		 or   eax, -1
.Return:
		pop   r15 r14 r13 rdi rsi rbx rbp
		ret
.Bad:
		xor   eax, eax
		jmp   .Return




Memory_Print:
	       push   rsi rdi r13 r14 r15
		lea   r14, [memoryMng.firstChunk]
		lea   r15, [memoryMng.lastChunk]



		xor   esi, esi
		xor   edi, edi

GD String, '******** memory *********'
GD NewLine

.NextChunk:
		mov   r14, qword[r14+Chunk.next]
		cmp   r14, r15
		 je   .ChunkDone
	       call   .PrintChunk
		jmp   .NextChunk
.ChunkDone:

GD String, 'memory used/res: '
GD UInt64, rsi
GD String, '/'
GD UInt64, rdi
test rdi, rdi
jz .noper
GD String, ' = '
vcvtsi2sd xmm0, xmm0, rsi
vcvtsi2sd xmm1, xmm1, rdi
vdivsd xmm0, xmm0, xmm1
mov eax, 100
vcvtsi2sd xmm1, xmm1, eax
vmulsd xmm0, xmm0, xmm1
vcvtsd2si rax, xmm0
GD UInt64, rax
GD String, '%'
.noper:
GD NewLine





AD String, 'info string memory state: '
call   Memory_IsOk
test eax, eax
jz .bad
AD String, 'ok'
jmp .over2
.bad:
AD String, 'NOT ok'
.over2:
AD NewLine




mov rsi, qword[memoryMng.usedEver]
mov rdi, qword[memoryMng.allocCnt]
test rdi, rdi
jz .over3
AD String, 'info string bytes/alloc: '
vcvtsi2sd xmm0, xmm0, rsi
vcvtsi2sd xmm1, xmm1, rdi
vdivsd xmm0, xmm0, xmm1
vcvtsd2si rax, xmm0
AD UInt64, rax
.over3:
AD NewLine



AD String, 'info string freeCnt: '
AD UInt64, qword[memoryMng.freeCnt]
AD String, ' allocCnt: '
AD UInt64, qword[memoryMng.allocCnt]
AD NewLine


mov rsi, qword[memoryMng.used]
mov rdi, qword[memoryMng.reserved]
AD String, 'info string used/res: '
AD UInt64, rsi
AD String, '/'
AD UInt64, rdi
test rdi, rdi
jz .over1
AD String, ' = '
vcvtsi2sd xmm0, xmm0, rsi
vcvtsi2sd xmm1, xmm1, rdi
vdivsd xmm0, xmm0, xmm1
mov eax, 100
vcvtsi2sd xmm1, xmm1, eax
vmulsd xmm0, xmm0, xmm1
vcvtsd2si rax, xmm0
AD UInt64, rax
AD String, '%'
.over1:
AD NewLine

		pop   r15 r14 r13 rdi rsi
		ret


.PrintChunk:

GD String, 'chunk  0x'
GD Hex, r14
GD String, '  recent 0x'
GD Hex, qword[r14+Chunk.recentBlock]
GD String, '  end 0x'
mov eax, dword[r14+Chunk.size]
add rdi, rax
add rax, r14
GD Hex, rax
GD NewLine

		lea   r13, [r14+sizeof.Chunk]
.PrintBlock:

GD String, ' block 0x'
GD Hex, r13
mov edx, dword[r13+Block.size]
mov eax, edx
and eax, -8
test edx, BIT_USED
jnz .used
GD String, '       '
jmp .over
.used:
lea rsi, [rsi+rax-sizeof.Block]
GD String, '  used '
.over:
GD UInt64, rax
GD NewLine
		add   r13, rax
	       test   edx, BIT_END
		 jz   .PrintBlock
		ret




Memory_Stress:
	       push   rbx rsi rdi r12 r13 r14 r15

		mov   ecx, 2048*8
	       call   _VirtualAlloc
		mov   r15, rax

	       call   _GetTime
		mov   rbx, rax

		xor   r13d, r13d
.allocloop:
		lea   rcx, [memoryMng.rand]
	       call   Math_Rand_i
		mov   ecx, 2048
		xor   edx, edx
		div   rcx
		mov   r12d, edx ; index

		mov   rcx, qword[r15+8*r12]
	       test   rcx, rcx
		 jz   .alloc

	       call   Memory_Free

		mov   qword[r15+8*r12], 0
		jmp   .skip

	.alloc:
		lea   rcx, [memoryMng.rand]
	       call   Math_Rand_i
		mov   ecx, 10000
		xor   edx, edx
		div   rcx
		mov   ecx, edx
		add   ecx, 5
	       call   Memory_Alloc

		mov   qword[r15+8*r12], rax

	.skip:
		add   r13d, 1
		cmp   r13d, 1000000
		 jb   .allocloop


		xor   r12d, r12d
.fillloop:
		mov   rcx, qword[r15+8*r12]
	       test   rcx, rcx
		jnz   @f
		lea   rcx, [memoryMng.rand]
	       call   Math_Rand_i
		mov   ecx, 10000
		xor   edx, edx
		div   rcx
		mov   ecx, edx
		add   ecx, 5
	       call   Memory_Alloc
		mov   qword[r15+8*r12], rax
	@@:

		add   r12d, 1
		cmp   r12d, 2048
		 jb   .fillloop


	       call   _GetTime
		sub   rbx, rax

	       call   Memory_Print

		lea   rdi, [Output]
		mov   rcx, rbx
		neg   rcx
		cmp   rcx, 1
		adc   rcx, 0
		mov   rax, r13
		xor   edx, edx
		div   rcx
	       call   PrintUnsignedInteger
		mov   rax," kops   "
	      stosq
	    PrintNewLine
	    PrintNewLine
	       call   _WriteOut_Output



		xor   r12d, r12d
.freeloop:
		mov   rcx, qword[r15+8*r12]
	       test   rcx, rcx
		 jz   @f
	       call   Memory_Free
	@@:
		mov   qword[r15+8*r12], 0
		add   r12d, 1
		cmp   r12d, 2048
		 jb   .freeloop


		mov   rcx, r15
		mov   edx, 2048*8
	       call   _VirtualFree

	       call   Memory_Print

		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

end if









