LOCK_CONTEND	= 0x0101

Os_MutexCreate:
/*
	; rcx: address of Mutex
	       push   rbx rsi rdi
		mov   rdi, rcx
		xor   eax, eax
		mov   dword[rdi], eax
		pop   rdi rsi rbx
		ret
*/
Os_MutexDestroy:
/*
	; rcx: address of Mutex
	       push   rbx rsi rdi
		mov   rdi, rcx
		xor   eax, eax
		pop   rdi rsi rbx
		ret
*/
        str  xzr, [x1]
        ret


Os_MutexLock:
/*
	       push   rbx rsi rdi
		mov   rdi, rcx
		mov   ecx, 100
.1:		mov   dl, 1
	       xchg   dl, byte[rdi]
	       test   dl, dl
		 jz   .4
	    rep nop
		sub   ecx, 1
		jnz   .1
		mov   edx, LOCK_CONTEND
		mov   esi, FUTEX_WAIT_PRIVATE
		xor   r10, r10
		jmp   .3
.2:		mov   eax, sys_futex
	    syscall
.3:		mov   eax, edx
	       xchg   eax, dword[rdi]
	       test   eax, 1
		jnz   .2
.4:		xor   eax, eax
		pop   rdi rsi rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x29, x1
        mov  x1, 100
Os_MutexLock.L1:
        mov  w2, 0x01
Os_MutexLock.L1_xchg:
     ldaxrb  w3, [x29]
     stlxrb  w4, w2, [x29]
       cbnz  w4, Os_MutexLock.L1_xchg
        cbz  w3, Os_MutexLock.L4
        sub  x1, x1, 1
       cbnz  x1, Os_MutexLock.L1
Os_MutexLock.L3:
        mov  w0, 0x0101
Os_MutexLock.L3_xchg:
      ldaxr  w3, [x29]
      stlxr  w4, w0, [x29]
       cbnz  w4, Os_MutexLock.L3_xchg        
       tbnz  w3, 0, Os_MutexLock.L2
Os_MutexLock.L4:
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret
Os_MutexLock.L2:
        mov  x0, x29
        mov  x1, FUTEX_WAIT_PRIVATE
        mov  x2, 0x0101
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
          b  Os_MutexLock.L3


Os_MutexUnlock:
/*
	; rcx: address of Mutex
	       push   rbx rsi rdi
		mov   rdi, rcx
		cmp   dword[rdi], 1
		jne   .1
		mov   eax, 1
		xor   ecx, ecx
       lock cmpxchg   dword[rdi], ecx
		 jz   .3
.1:		mov   byte[rdi], 0
	; Spin, and hope someone takes the lock
		mov   ecx, 200
.2:	       test   byte[rdi], 1
		jnz   .3
	    rep nop
		sub   ecx, 1
		jnz   .2
	; Wake up someone
		mov   byte[rdi+1], 0
		mov   esi, FUTEX_WAKE_PRIVATE
		mov   edx, 1
		mov   eax, sys_futex
	    syscall
	       test   eax, eax
		 js   Failed_sys_futex_MutexUnlock

.3:		xor   eax, eax
		pop   rdi rsi rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x29, x1
Os_MutexUnlock.L0:
        ldr  w0, [x29]
        cmp  w0, 1      // expected = 1
        bne  Os_MutexUnlock.L1
        mov  w1, 0      // desired = 0
      ldaxr  w2, [x29]  // w2 = obj
        cmp  w2, w0     // cmp obj, expected
        bne  Os_MutexUnlock.L1
       stxr  w4, w1, [x29]      // obj = desired
        cbz  w4, Os_MutexUnlock.L3
Os_MutexUnlock.L1:
       strb  wzr, [x29]
        mov  x1, 200
Os_MutexUnlock.L2:
       ldrb  w0, [x29]
       tbnz  w0, 0, Os_MutexUnlock.L3
        sub  x1, x1, 1
       cbnz  x1, Os_MutexUnlock.L2
       strb  wzr, [x29, 1]
        mov  x0, x29
        mov  x1, FUTEX_WAKE_PRIVATE
        mov  x2, 0x01
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
        tst  w0, w0
        bmi  Failed_sys_futex_MutexUnlock
Os_MutexUnlock.L3:
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_EventCreate:
/*
	; rcx: address of ConditionalVariable
*/
Os_EventDestroy:
/*
	; rcx: address of ConditionalVariable
		xor   eax, eax
		mov   qword[rcx], rax
		mov   qword[rcx+8], rax
		ret
*/
        stp  xzr, xzr, [x1]
        ret

Os_EventSignal:
/*
	; rcx: address of ConditionalVariable
	       push   rbx rsi rdi
		mov   rdi, rcx
	   lock add   dword[rdi], 1
		mov   eax, sys_futex
		mov   esi, FUTEX_WAKE_PRIVATE
		mov   edx, 1
	    syscall
	       test   eax, eax
		 js   Failed_sys_futex_EventSignal
		xor   eax, eax
		pop   rdi rsi rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x29, x1
Os_EventSignal.incr:
      ldaxr  w0, [x29]
        add  w0, w0, 1
      stlxr  w4, w0, [x29]
       cbnz  w4, Os_EventSignal.incr
        mov  x0, x29
        mov  x1, FUTEX_WAKE_PRIVATE
        mov  x2, 0x01
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
        tst  w0, w0
        bmi  Failed_sys_futex_EventSignal
//Display "event signal futex returning %x29\n"
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_EventWait:
/*
	; rcx: address of ConditionalVariable
	; rdx: address of Mutex
	       push   rbx rsi rdi r14 r15
		mov   rdi, rcx
		mov   rsi, rdx
		cmp   rsi, qword[rdi+8]
		jne   .4
	; save seq into r14d
*/

/*		
                mov   r14d, dword[rdi]
	; save mutex into r15
		mov   r15, rsi
	; Unlock
		mov   rbx, rdi
		mov   rcx, rsi
	       call   _MutexUnlock
		mov   rdi, rbx
	; Setup for wait on seq
		mov   edx, r14d
		xor   r10, r10
		mov   esi, FUTEX_WAIT_PRIVATE
		mov   eax, sys_futex
	    syscall
	   ; this syscall can and should fail in some cases
	   ;    test   eax, eax
	   ;      js   Failed_sys_futex_EventWait
	; Set up for wait on mutex
		mov   rdi, r15
		mov   edx, LOCK_CONTEND
		jmp   .3
	; Wait loop
*/
/*
                mov   eax, edx
	       xchg   eax, dword[rdi]
	       test   eax, 1
		jnz   .2
		xor   eax, eax
		pop   r15 r14 rdi rsi rbx
		ret
*/
/*
                mov   eax, sys_futex
	    syscall
	   ; this syscall can and should fail in some cases
	   ;    test   eax, eax
	   ;      js   Failed_sys_futex_EventWait
*/

/*
                xor   rax, rax
       lock cmpxchg   qword[rdi+8], rsi
		 jz   .1
		cmp   qword[rdi+8], rsi
		 je   .1
*/

/*
		jmp   Failed_EventWait
*/
        stp  x24, x30, [sp, -16]!
        stp  x28, x29, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x28, x1    // x28 = cv
        mov  x29, x2    // x29 = mutex
        ldr  w24, [x28]
        ldr  x4, [x28, 8]
        cmp  x29, x4
        bne  Os_EventWait.L4

Os_EventWait.L1:
        mov  x1, x29
         bl  Os_MutexUnlock
        mov  x0, x28
        mov  x1, FUTEX_WAIT_PRIVATE
        mov  x2, x24
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
Os_EventWait.L3:
        mov  w0, 0x0101
Os_EventWait.L3_xchg:
      ldaxr  w3, [x29]
      stlxr  w4, w0, [x29]
       cbnz  w4, Os_EventWait.L3_xchg
       tbnz  w3, 0, Os_EventWait.L2
        ldp  x14, x15, [sp], 16
        ldp  x28, x29, [sp], 16
        ldp  x24, x30, [sp], 16
        ret

Os_EventWait.L2:
        mov  x0, x29
        mov  x1, FUTEX_WAIT_PRIVATE
        mov  x2, 0x0101
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
          b  Os_EventWait.L3

Os_EventWait.L4:
        add  x5, x28, 8
      ldaxr  x2, [x5]
       cbnz  x2, Os_EventWait.L4_ne
       stxr  w4, x29, [x5]
        cbz  w4, Os_EventWait.L1
        ldr  x2, [x5]
Os_EventWait.L4_ne:
        cmp  x2, x29    // we should have mutex x29 saved at x5
        beq  Os_EventWait.L1

Os_EventWait.L5:
          b  Failed_EventWait



Os_ThreadCreate:
/*
	; in: rcx start address
	;     rdx parameter to pass
	;     r8  address of NumaNode struct
	;     r9  address of ThreadHandle Struct
	       push   rbx rsi rdi r12 r13 r14 r15
		mov   r12, r8
		mov   r13, r9
		mov   r14, rcx
		mov   r15, rdx
	; allocate memory for the thread stack
		mov   ecx, THREAD_STACK_SIZE
		mov   edx, dword[r12+NumaNode.nodeNumber]
	       call   _VirtualAllocNuma_GrowsDown
		mov   qword[r13+ThreadHandle.stackAddress], rax
		mov   rsi, rax
	; create child
		mov   edi, CLONE_VM or CLONE_FS or CLONE_FILES\
			or CLONE_SIGHAND or CLONE_THREAD	; flags
		add   rsi, THREAD_STACK_SIZE			; child_stack
		xor   edx, edx					; ptid
		xor   r10, r10					; ctid
		xor   r8, r8					; regs
		mov   eax, stub_clone
	    syscall
	       test   eax, eax
		 js   Failed_stub_clone
	; redirect child to function
	       test   eax, eax
		 jz   .WeAreChild
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret
*/
        stp  x21, x30, [sp, -16]!
        stp  x28, x29, [sp, -16]!
        stp  x22, x23, [sp, -16]!
        stp  x24, x25, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x22, x3    // address of NumaNode struct
        mov  x23, x4    // address of ThreadHandle struct
        mov  x24, x1    // start address
        mov  x25, x2    // parameter to pass
        mov  x1, THREAD_STACK_SIZE
        ldr  w2, [x22, NumaNode.nodeNumber]
         bl  Os_VirtualAllocNuma_GrowsDown
        str  x0, [x23, ThreadHandle.stackAddress]
        mov  x28, x0
        mov  x0, CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND
        orr  x0, x0, CLONE_THREAD
        add  x1, x28, THREAD_STACK_SIZE
        mov  x2, 0
        mov  x3, 0
        mov  x4, 0
        mov  x8, sys_clone
        svc  0
        tst  w0, w0
        bmi  Failed_sys_clone
        beq  Os_ThreadCreate.WeAreChild
        ldp  x14, x15, [sp], 16
        ldp  x24, x25, [sp], 16
        ldp  x22, x23, [sp], 16
        ldp  x28, x29, [sp], 16
        ldp  x21, x30, [sp], 16
        ret
        
Os_ThreadCreate.WeAreChild:
/*
		xor   edi, edi
		mov   esi, MAX_LINUXCPUS/8
		lea   rdx, [r12+NumaNode.cpuMask]
		xor   eax, eax
	repeat MAX_LINUXCPUS/64
		 or   rax, qword[rdx+8*(%-1)]
	end repeat
		 jz   .DontSetAffinity
		mov   eax, sys_sched_setaffinity
	    syscall
	       test   eax, eax
		jnz   Failed_sys_sched_setaffinity
*/
        mov  x0, 0
        mov  x1, MAX_LINUXCPUS/8
        add  x2, x22, NumaNode.cpuMask
        mov  x3, 0
        ldr  x4, [x2, 8*0]
        orr  x3, x3, x4
        ldr  x4, [x2, 8*1]
        orr  x3, x3, x4
        cbz  x3, Os_ThreadCreate.DontSetAffinity
        mov  x8, sys_sched_setaffinity
        svc  0
       cbnz  w0, Failed_sys_sched_setaffinity
Os_ThreadCreate.DontSetAffinity:
/*
		mov   rcx, r15
	       call   r14
	; signal that we are done
		lea   rdi, [r13+ThreadHandle.mutex]
		mov   esi, FUTEX_WAKE_PRIVATE
		mov   edx, 1
		mov   dword[rdi], edx
		mov   eax, sys_futex
	    syscall
	       test   eax, eax			      ; existed before
		 js   Failed_sys_futex_ThreadCreate   ;
	; exit
		xor   edi, edi
		mov   eax, sys_exit
	    syscall
	       int3
*/
        mov  x1, x25
        blr  x24
        add  x0, x23, ThreadHandle.mutex
        mov  x1, FUTEX_WAKE_PRIVATE
        mov  x2, 1
        str  w2, [x0]
        mov  x8, sys_futex
        svc  0
        mov  x0, 0
        mov  x8, sys_exit
        svc  0

        
Os_ThreadJoin:
/*
	; rcx:  address of ThreadHandle struct
	       push   rbx rsi rdi
		mov   rbx, rcx

	; wait for the thread to return
		lea   rdi, [rbx+ThreadHandle.mutex]
		mov   esi, FUTEX_WAIT_PRIVATE
		xor   edx, edx
		xor   r10d, r10d
		mov   eax, sys_futex
	    syscall
	   ; this syscall can and should fail in some cases
	   ;    test   eax, eax                        ; existed before
	   ;      js   Failed_sys_futex_ThreadJoin     ;

	; free its stack
                mov   rcx, qword[rbx+ThreadHandle.stackAddress]
                mov   edx, THREAD_STACK_SIZE
               call   _VirtualFree

		pop   rdi rsi rbx
		ret
*/
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        mov  x29, x1
        add  x0, x29, ThreadHandle.mutex
        mov  x1, FUTEX_WAIT_PRIVATE
        mov  x2, 0
        mov  x3, 0
        mov  x4, 0
        mov  x5, 0
        mov  x8, sys_futex
        svc  0
        ldr  x1, [x29, ThreadHandle.stackAddress]
        mov  x2, THREAD_STACK_SIZE
         bl  Os_VirtualFree
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_SetThreadPoolInfo:
/*
		mov   ecx, 1
		mov   dword[threadPool.nodeCnt], ecx
		mov   dword[threadPool.coreCnt], ecx

		xor   eax, eax

		lea   rdi, [threadPool.nodeTable]
		mov   dword[rdi+NumaNode.nodeNumber], -1
		mov   dword[rdi+NumaNode.coreCnt], ecx
		mov   qword[rdi+NumaNode.cmhTable], rax
		mov   qword[rdi+NumaNode.parent], rdi
	repeat MAX_LINUXCPUS/64
		mov   qword[rdi+NumaNode.cpuMask+8*(%-1)], rax
	end repeat
*/
        lea  x16, threadPool
        mov  x1, 1
        str  w1, [x16, ThreadPool.nodeCnt]
        str  w1, [x16, ThreadPool.coreCnt]

        mov  w0, -1
        add  x16, x16, ThreadPool.nodeTable
        str  w0, [x16, NumaNode.nodeNumber]
        str  w1, [x16, NumaNode.coreCnt]
        str  xzr, [x16, NumaNode.cmhTable]
        str  x16, [x16, NumaNode.parent]
        str  xzr, [x16, NumaNode.cpuMask+8*0]
        str  xzr, [x16, NumaNode.cpuMask+8*1]
        ret

Os_DisplayThreadPoolInfo:
Os_SetPriority_Realtime:
Os_SetPriority_Normal:
Os_SetPriority_Low:
Os_SetPriority_Idle:
        ret


Os_ExitProcess:
// in: x0 exit code
        mov  x8, sys_exit_group
        svc  0


Os_SetStdHandles:
        ret


Os_InitializeTimer:
        ret


Os_GetTime:
// out: x0, x2 such that x0+x2/2^64 = time in ms
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, 1
        add  x1, sp, 16
        mov  x8, 113
        svc  0
        ldr  x1, [sp, 16]
        ldr  x3, [sp, 24]
        mov  x4, 46573
       movk  x4, 0xf7a0, lsl 16
       movk  x4, 0x10c6, lsl 32
        mov  x5, 1000
        mul  x2, x3, x4
      umulh  x0, x3, x4
       madd  x0, x1, x5, x0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_Sleep:
// in: x1 ms to sleep
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, 1000
       udiv  x2, x1, x0
       msub  x3, x2, x0, x1
        mul  x0, x0, x0
        mul  x3, x3, x0
        str  x2, [sp, 16]
        str  x3, [sp, 24]
        add  x0, sp, 16
        mov  x1, 0            
        mov  x8, 101
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_VirtualAllocNuma_GrowsDown:
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x5, 0
        mov  x4, -1
        mov  x3, MAP_PRIVATE | MAP_ANONYMOUS | MAP_GROWSDOWN
        mov  x2, 0x03
        mov  x0, 0
        mov  x8, sys_mmap
        svc  0
        tst  x0, x0
        bmi  Failed_sys_mmap_VirtualAlloc
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

Os_VirtualAlloc_LargePages:
// in: x1 size
        mov  x0, 0
        mov  x2, 0
        ret

Os_VirtualAllocNuma:
Os_VirtualAlloc:
// in: x1 size
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x5, 0
        mov  x4, -1
        mov  x3, MAP_PRIVATE | MAP_ANONYMOUS
        mov  x2, 0x03
        mov  x0, 0
        mov  x8, sys_mmap
        svc  0
        tst  x0, x0
        bmi  Failed_sys_mmap_VirtualAlloc
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_VirtualFree:
// in: x1 address
//     x2 size
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        cbz  x1, Os_VirtualFree.Null
        mov  x1, x2
        mov  x0, x1
        mov  x8, sys_unmap
        svc  0
        cmp  w0, 0
        bne  Failed_sys_unmap_VirtualFree
Os_VirtualFree.Null:
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_WriteOut_Output:
       adrp  x1, Output
        add  x1, x1, :lo12:Output
Os_WriteOut:
// in: x1 address of string start
// in: x15 address of string end
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        sub  x2, x15, x1
        mov  x0, 1
        mov  x8, 64
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_ReadStdIn:
// in: x1 address of buffer
//     x2 max bytes to read
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, 0
        mov  x8, 63
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret


Os_ParseCommandLine:
// initializes ioBuffer struct  
        stp  x29, x30, [sp, -64]!
        stp  x22, x23, [sp, 16]
        stp  x24, x25, [sp, 32]
        stp  x27, x28, [sp, 48]
       adrp  x29, ioBuffer
        add  x29, x29, :lo12:ioBuffer
        mov  x1, 4096
        str  x1, [x29,IOBuffer.inputBufferSizeB]
         bl  Os_VirtualAlloc
        str  x0, [x29,IOBuffer.inputBuffer]
        ldp  x24, x25, [sp, 32]
        ldp  x22, x23, [sp, 16]
        ldp  x27, x28, [sp, 48]
        ldp  x28, x30, [sp], 64
        ret


Failed_sys_futex_EventSignal:
	lea  x15, sz_error_sys_futex_EventSignal
          b  Failed
Failed_EventWait:
        lea  x15, sz_error_EventWait
          b  Failed
Failed_sys_futex_MutexUnlock:
        lea  x15, sz_error_sys_futex_MutexUnlock
          b  Failed
Failed_sys_clone:
        lea  x15, sz_error_sys_clone
          b  Failed
Failed_sys_sched_setaffinity:
	lea  x15, sz_error_sys_sched_setaffinity
          b  Failed
Failed_sys_mmap_VirtualAlloc:
        lea  x15, sz_error_sys_mmap_VirtualAlloc
          b  Failed
Failed_sys_unmap_VirtualFree:
        lea  x15, sz_error_sys_unmap_VirtualFree
          b  Failed
Failed:
// x15 address of null terminated string
        mov  x21, x0
        mov  x0, x15
        lea  x15, Output
         bl  PrintString
        lea  x0, sz_failed_x0
         bl  PrintString
        mov  x0, x21
         bl  PrintHex
        mov  w0, 10
       strb  w0, [x15], 1
        lea  x15, Output
         bl  Os_ErrorBox
        mov  x0, 1
         bl  Os_ExitProcess


Os_ErrorBox:
// x15 address of null terminated string
        stp  x29, x30, [sp, -16]!
        stp  x14, x15, [sp, -16]!
        sub  sp, sp, 64
        mov  x0, x15
         bl  StringLength
        mov  x2, x0
        mov  x1, x15
        mov  x0, 1
        mov  x8, 64
        svc  0
        add  sp, sp, 64
        ldp  x14, x15, [sp], 16
        ldp  x29, x30, [sp], 16
        ret     


Os_CheckCPU:
        mov  x0, 0
// make sure that rook attacks are page aligned
        lea  x15, sz_error_rook_page
        add  x0, x0, :lo12:RookAttacksSTUFF
       cbnz  x0, Failed
// make sure that bishop attacks are page aligned        
        lea  x15, sz_error_bishop_page
        add  x0, x0, :lo12:BishopAttacksSTUFF
       cbnz  x0, Failed
        ret



