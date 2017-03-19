
RootMovesVec_Create:
/*
	; in: rcx address of RootMovesVec struct
	;     edx numa node
	       push   rbx
		mov   rbx, rcx
		mov   ecx, sizeof.RootMove*MAX_MOVES
	       call   _VirtualAllocNuma
		mov   qword[rbx+RootMovesVec.table], rax
		mov   qword[rbx+RootMovesVec.ender], rax
		pop   rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        mov  x29, x1
        mov  x1, ((sizeof.RootMove*MAX_MOVES)>> 0) & 0x0FFF
       movk  x1, ((sizeof.RootMove*MAX_MOVES)>>16) & 0x0FFF, lsl 16
         bl  Os_VirtualAllocNuma
        str  x0, [x21, RootMovesVec.table]
        str  x0, [x21, RootMovesVec.ender]  
        ldp  x29, x30, [sp], 16
        ret

RootMovesVec_Destroy:
/*
	; in: rcx address of RootMovesVec struct
	       push   rbx
		mov   rbx, rcx
		mov   rcx, qword[rbx+RootMovesVec.table]
		xor   eax, eax
		mov   qword[rbx+RootMovesVec.table], rax
		mov   qword[rbx+RootMovesVec.ender], rax
		mov   edx, sizeof.RootMove*MAX_MOVES
	       call   _VirtualFree
		pop   rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        mov  x29, x1
        ldr  x1, [x21, RootMovesVec.table]
        mov  x2, ((sizeof.RootMove*MAX_MOVES)>> 0) & 0x0FFF
       movk  x2, ((sizeof.RootMove*MAX_MOVES)>>16) & 0x0FFF, lsl 16
         bl  Os_VirtualFree
        str  xzr, [x21, RootMovesVec.table]
        str  xzr, [x21, RootMovesVec.ender]  
        ldp  x29, x30, [sp], 16
        ret




RootMovesVec_Clear:
/*
	; in: rcx address of RootMovesVec struct
		mov   rax, qword[rcx+RootMovesVec.table]
		mov   qword[rcx+RootMovesVec.ender], rax
		ret
*/
        ldr  x0, [x1, RootMovesVec.table]
        str  x0, [x1, RootMovesVec.ender]
        ret

RootMovesVec_Empty:
/*
	; in: rcx address of RootMovesVec struct
	; out: eax=0 if empty
	;      eax=-1 if not
		mov   rax, qword[rcx+RootMovesVec.ender]
		sub   rax, qword[rcx+RootMovesVec.table]
		cmp   rax, 1
		sbb   eax, eax
		ret
*/
        ldr  x0, [x1, RootMovesVec.table]
        ldr  x1, [x1, RootMovesVec.ender]
        sub  x0, x0, x1
        ret

RootMovesVec_Size:
/*
	; in: rcx address of RootMovesVec struct
	; out: eax size
		mov   rax, qword[rcx+RootMovesVec.ender]
		sub   rax, qword[rcx+RootMovesVec.table]
		mov   ecx, sizeof.RootMove
		xor   edx, edx
		div   ecx
	     Assert   e, edx, 0, 'bad div in RootMovesVec_Size'
	     Assert   b, eax, MAX_MOVES, 'too many moves in RootMovesVec_Size'
		ret
*/
        ldr  x0, [x1, RootMovesVec.table]
        ldr  x1, [x1, RootMovesVec.ender]
        sub  x0, x0, x1
        mov  x1, sizeof.RootMove
       udiv  x0, x0, x1
        ret

RootMovesVec_PushBackMove:
/*
	; in: rcx address of RootMovesVec struct
	;     edx move
		mov   rax, qword[rcx+RootMovesVec.ender]
		mov   dword[rax+RootMove.score], -VALUE_INFINITE
		mov   dword[rax+RootMove.prevScore], -VALUE_INFINITE
		mov   dword[rax+RootMove.pvSize], 1
		mov   dword[rax+RootMove.pv], edx
		add   rax, sizeof.RootMove
		mov   qword[rcx+RootMovesVec.ender], rax
		ret
*/
        ldr  x0, [x1, RootMovesVec.ender]
        mov  w3, -VALUE_INFINITE
        str  w3, [x0, RootMove.score]
        str  w3, [x0, RootMove.prevScore]
        mov  x3, 1
        str  w3, [x0, RootMove.pvSize]
        str  w2, [x0, RootMove.pv]
        add  x0, x0, sizeof.RootMove
        str  x0, [x1, RootMovesVec.ender]
        ret

RootMovesVec_Copy:
/*
	; in: rcx address of destination RootMovesVec struct
	;     rdx address of source      RootMovesVec struct
	       push   rsi rdi
		mov   rdi, qword[rcx+RootMovesVec.table]
		mov   rsi, qword[rdx+RootMovesVec.table]
		mov   r8, rcx
		mov   rcx, qword[rdx+RootMovesVec.ender]
		sub   rcx, rsi
	  rep movsb
		mov   qword[r8+RootMovesVec.ender], rdi
		pop   rdi rsi
		ret
*/
        mov  x8, x1
        ldr  x0, [x1, RootMovesVec.table]
        mov  x1, x2
        ldr  x3, [x2, RootMovesVec.table]
        ldr  x4, [x2, RootMovesVec.ender]
        sub  x2, x4, x3
         bl  MemoryCopy
        str  x0, [x8, RootMovesVec.ender]
        ret

RootMovesVec_StableSort:
Display "RootMovesVec_StableSort called\n"
        brk  0
/*
	; in: rcx start RootMove
	;     rdx end RootMove
	       push   rsi rdi r12 r13 r14 r15
		sub   rsp, sizeof.RootMove
		mov   r14, rcx
		mov   r15, rdx
		mov   r13, r14
.l1:		add   r13, sizeof.RootMove
		cmp   r13, r15
		jae   .l1d
		mov   rdi, rsp
		mov   rsi, r13
		mov   ecx, sizeof.RootMove/4
	  rep movsd
		mov   r12, r13
.l2:		cmp   r12, r14
		jbe   .l2d
		mov   eax, dword[r12-1*sizeof.RootMove+RootMove.score]
		cmp   eax, dword[rsp+RootMove.score]
		jge   .l2d
		mov   rdi, r12
		sub   r12, sizeof.RootMove
		mov   rsi, r12
		mov   ecx, sizeof.RootMove/4
	  rep movsd
		jmp   .l2
.l2d:		mov   rdi, r12
		mov   rsi, rsp
		mov   ecx, sizeof.RootMove/4
	  rep movsd
		jmp   .l1
.l1d:		add   rsp, sizeof.RootMove
		pop   r15 r14 r13 r12 rdi rsi
		ret
*/


