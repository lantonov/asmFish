
WARNIDX_MBIND = 1
WARNIDX_MADVISE = 2

;;;;;;;;;
; mutex ;
;;;;;;;;;


Os_MutexCreate:
    ; rcx: address of Mutex

Os_MutexDestroy:
    ; rcx: address of Mutex
            xor  eax, eax
            mov  qword[rcx], rax
            ret

Os_MutexLock:
    ; rcx: address of Mutex
           push  rbx rsi rdi
            mov  rdi, rcx
            mov  ecx, 100
    ; Spin a bit to try to get lock
.l1:
            mov  dl, 1
           xchg  dl, byte[rdi]
           test  dl, dl
             jz  .l4
        rep nop
            sub  ecx, 1
            jnz  .l1
    ; Set up syscall details
            mov  edx, 0x0101
            mov  esi, FUTEX_WAIT_PRIVATE
            xor  r10, r10
            jmp  .l3
    ; Wait loop
.l2:
            mov  eax, sys_futex
        syscall
.l3:
            mov  eax, edx
           xchg  eax, dword[rdi]
           test  eax, 1
            jnz  .l2
.l4:
            xor  eax, eax
            pop  rdi rsi rbx
            ret

Os_MutexUnlock:
    ; rcx: address of Mutex
           push  rbx rsi rdi
            mov  rdi, rcx
            cmp  dword[rdi], 1
            jne  .l1
            mov  eax, 1
            xor  ecx, ecx
   lock cmpxchg  dword[rdi], ecx
             jz  .l3
.l1:
    		mov  byte[rdi], 0
    ; Spin, and hope someone takes the lock
            mov  ecx, 200
.l2:
	       test  byte[rdi], 1
            jnz  .l3
        rep nop
            sub  ecx, 1
            jnz  .l2
    ; Wake up someone
            mov  byte[rdi+1], 0
            mov  esi, FUTEX_WAKE_PRIVATE
            mov  edx, 1
            mov  eax, sys_futex
        syscall
           test  eax, eax
             js  Failed_sys_futex
.l3:
            xor  eax, eax
            pop  rdi rsi rbx
            ret



;;;;;;;;;
; event ;
;;;;;;;;;


Os_EventCreate:
    ; rcx: address of ConditionalVariable
Os_EventDestroy:
    ; rcx: address of ConditionalVariable
            xor  eax, eax
            mov  qword[rcx], rax
            mov  qword[rcx + 8], rax
            ret

Os_EventSignal:
    ; rcx: address of ConditionalVariable
           push  rbx rsi rdi
            mov  rdi, rcx
       lock add  dword[rdi], 1
            mov  eax, sys_futex
            mov  esi, FUTEX_WAKE_PRIVATE
            mov  edx, 1
        syscall
           test  eax, eax
             js  Failed_sys_futex
            xor  eax, eax
            pop  rdi rsi rbx
            ret

Os_EventWait:
    ; rcx: address of ConditionalVariable
    ; rdx: address of Mutex
           push  rbx rsi rdi r14 r15
            mov  rdi, rcx
            mov  rsi, rdx
            cmp  rsi, qword[rdi + 8]
            jne  .l4
    ; save seq into r14d
.l1:
            mov  r14d, dword[rdi]
    ; save mutex into r15
            mov  r15, rsi
    ; Unlock
            mov  rbx, rdi
            mov  rcx, rsi
           call  Os_MutexUnlock
            mov  rdi, rbx
    ; Setup for wait on seq
            mov  edx, r14d
            xor  r10, r10
            mov  esi, FUTEX_WAIT_PRIVATE
            mov  eax, sys_futex
        syscall
    ; Set up for wait on mutex
            mov  rdi, r15
            mov  edx, 0x0101
            jmp  .l3
.WaitLoop:
            mov  eax, sys_futex
        syscall
.l3:
            mov  eax, edx
           xchg  eax, dword[rdi]
           test  eax, 1
            jnz  .WaitLoop
            xor  eax, eax
            pop  r15 r14 rdi rsi rbx
            ret

.l4:
            xor  rax, rax
   lock cmpxchg  qword[rdi + 8], rsi
             jz  .l1
            cmp  qword[rdi + 8], rsi
             je  .l1
.l5:
            jmp  Failed_EventWait



;;;;;;;;
; file ;
;;;;;;;;

Os_FileWrite:
    ; in: rcx handle from CreateFile (win), fd (linux)
    ;     rdx buffer
    ;     r8d size (32bits)
    ; out: eax !=0 success
           push  rsi rdi rbx
            mov  rdi, rcx	; fd
            mov  rsi, rdx	; buffer
            mov  edx, r8d	; count
            mov  eax, sys_write
        syscall
            sar  rax, 63
            add  eax, 1
            pop  rbx rdi rsi
            ret

Os_FileRead:
    ; in: rcx handle from CreateFile (win), fd (linux)
    ;     rdx buffer
    ;     r8d size (32bits)
    ; out: eax !=0 success
           push  rsi rdi rbx
            mov  rdi, rcx	; fd
            mov  rsi, rdx	; buffer
            mov  edx, r8d	; count
            mov  eax, sys_read
        syscall
            sar  rax, 63
            add  eax, 1
            pop  rbx rdi rsi
            ret


Os_FileSize:
    ; in: rcx handle from CreateFile (win), fd (linux)
    ; out:  rax size
           push  rbx rsi rdi
            sub  rsp, (sizeof.stat + 15) and -16
            mov  rdi, rcx
            mov  rsi, rsp 
            mov  eax, sys_fstat 
        syscall
           test  eax, eax
            jnz  Failed_sys_fstat
            mov  rax, qword[rsp+stat.st_size] ; file size
            add  rsp, (sizeof.stat + 15) and -16
            pop  rdi rsi rbx
            ret


Os_FileOpenWrite:
    ; in: rcx path string
    ; out: rax handle from CreateFile (win), fd (linux)
    ;      rax=-1 on error
           push  rbx rsi rdi
            mov  rdi, rcx
            mov  esi, O_WRONLY or O_CREAT or O_TRUNC
            mov  edx, 0664o        ; set mode to 664 octal
            mov  eax, sys_open
        syscall
           test  eax, eax
            jns  @1f
             or  rax, -1
    @1:
            pop  rdi rsi rbx
            ret


Os_FileOpenRead:
    ; in: rcx path string  
    ; out: rax handle from CreateFile (win), fd (linux)
    ;      rax=-1 on error
           push  rbx rsi rdi
            mov  rdi, rcx
            mov  esi, O_RDONLY
            mov  eax, sys_open
        syscall
           test  eax, eax
            jns  @1f
             or  rax, -1
    @1:
            pop  rdi rsi rbx
            ret

Os_FileClose:
    ; in: rcx handle from CreateFile (win), fd (linux) 
           push  rbx rsi rdi 
            mov  rdi, rcx 
            mov  eax, sys_close 
        syscall 
            pop  rdi rsi rbx 
            ret

Os_FileMap:
    ; in: rcx handle (win), fd (linux) 
    ; out: rax base address 
    ;      rdx handle from CreateFileMapping (win), size (linux) 
    ; get file size 
           push  rbp rbx rsi rdi r15
            sub  rsp, (sizeof.stat + 15) and -16
            mov  rbp, rcx
            mov  rdi, rcx
            mov  rsi, rsp 
            mov  eax, sys_fstat 
        syscall
           test  eax, eax
            jnz  Failed_sys_fstat
            mov  rbx, qword[rsp+stat.st_size] ; file size
    ; map file
            xor  edi, edi		; addr
            mov  rsi, rbx		; length
            mov  edx, PROT_READ	; protection flags
            mov  r10, MAP_PRIVATE	; mapping flags
            mov  r8, rbp		; fd
            xor  r9d, r9d		; offset
            mov  eax, sys_mmap
        syscall
           test  rax, rax
             js  Failed_sys_mmap
    ; return size in rdx, base address in rax
            mov  rdx, rbx
            add  rsp, (sizeof.stat + 15) and -16
            pop  r15 rdi rsi rbx rbp
            ret

Os_FileUnmap:
    ; in: rcx base address 
    ;     rdx handle from CreateFileMapping (win), size (linux) 
           push  rbx rsi rdi
           test  rcx, rcx
             jz  @1f
            mov  rdi, rcx	      ; addr 
            mov  rsi, rdx	      ; length 
            mov  eax, sys_munmap 
        syscall
           test  eax, eax
            jnz  Failed_sys_munmap
    @1:
            pop  rdi rsi rbx
            ret
        



;;;;;;;;;;
; thread ;
;;;;;;;;;;

Os_ThreadCreate:
    ; in: rcx start address
    ;     rdx parameter to pass
    ;     r8  address of NumaNode struct
    ;     r9  address of ThreadHandle Struct
           push  rbx rsi rdi r12 r13 r14 r15
            mov  r12, r8
            mov  r13, r9
            mov  r14, rcx
            mov  r15, rdx
    ; allocate memory for the thread stack
            mov  ecx, THREAD_STACK_SIZE
            mov  edx, dword[r12 + NumaNode.nodeNumber]
           call  Os_VirtualAllocNuma
            mov  qword[r13 + ThreadHandle.stackAddress], rax
            mov  rsi, rax
    ; create child
            mov  edi, CLONE_VM or CLONE_FS or CLONE_FILES or CLONE_SIGHAND or CLONE_THREAD
            add  rsi, THREAD_STACK_SIZE
            xor  edx, edx
            xor  r10, r10
            xor  r8, r8
            mov  eax, stub_clone
        syscall
           test  eax, eax
             js  Failed_stub_clone
    ; redirect child to function
           test  eax, eax
             jz  .WeAreChild
            pop  r15 r14 r13 r12 rdi rsi rbx
            ret
.WeAreChild:
            xor  edi, edi
            mov  esi, MAX_LINUXCPUS/8
            lea  rdx, [r12 + NumaNode.cpuMask]
            xor  eax, eax
repeat MAX_LINUXCPUS/64
             or   rax, qword[rdx + 8*(% - 1)]
end repeat
             jz  .DontSetAffinity
            mov  eax, sys_sched_setaffinity
        syscall
           test  eax, eax
            jnz  Failed_sys_sched_setaffinity
.DontSetAffinity:
            mov  rcx, r15
           call  r14
    ; signal that we are done
            lea  rdi, [r13 + ThreadHandle.mutex]
            mov  esi, FUTEX_WAKE_PRIVATE
            mov  edx, 1
            mov  dword[rdi], edx
            mov  eax, sys_futex
        syscall
           test  eax, eax
             js  Failed_sys_futex
    ; exit
            xor  edi, edi
            mov  eax, sys_exit
        syscall
           int3

Os_ThreadJoin:
    ; in: rcx address of ThreadHandle struct
           push   rbx rsi rdi
            mov   rbx, rcx
    ; wait for the thread to return
            lea   rdi, [rbx + ThreadHandle.mutex]
            mov   esi, FUTEX_WAIT_PRIVATE
            xor   edx, edx
            xor   r10d, r10d
            mov   eax, sys_futex
        syscall
	; free its stack
            mov   rcx, qword[rbx + ThreadHandle.stackAddress]
            mov   edx, THREAD_STACK_SIZE
           call   Os_VirtualFree
            pop   rdi rsi rbx
            ret

Os_ExitProcess:
    ; in: rcx exit code
           push   rdi
            mov   rdi, rcx
            mov   eax, sys_exit_group
        syscall

Os_ExitThread:
    ; rcx is exit code
    ; must not call Os_ExitThread on linux
    ;  thread should just return
           int3


;;;;;;;;;;
; timing ;
;;;;;;;;;;

         calign   16
Os_GetTime:
    ; out: rax + rdx/2^64 = time in ms
           push  rbx rsi rdi
            sub  rsp, (sizeof.timespec + 15) and -16
            mov  edi, CLOCK_MONOTONIC
            mov  rsi, rsp
           call  qword[__imp_clock_gettime]
            mov  eax, dword[rsp + 8*1]	; tv_nsec
            mov  rcx, 18446744073709;551616   2^64/10^6
            mul  rcx
           imul  rcx, qword[rsp + 8*0], 1000
            add  rdx, rcx
           xchg  rax, rdx
            add  rsp, (sizeof.timespec + 15) and -16
            pop  rdi rsi rbx
            ret
.SYS:
           push  rbx
            mov  eax, sys_clock_gettime
        syscall
            pop  rbx
            ret


Os_InitializeTimer:
    ; we need to set the address of the clock_gettime function
    ; if the lookup succeeds, then we use the vdso function
    ;               otherwise use a syscall
           push  rbx
            lea  rcx, [sz___vdso_clock_gettime]
           call  vdso_FindSymbol
            lea  rcx, [Os_GetTime.SYS]
           test  rax, rax
          cmovz  rax, rcx
            mov  qword[__imp_clock_gettime], rax
            pop  rbx
            ret

Os_Sleep:
    ; in: ecx  ms
           push  rbx rsi rdi
            sub  rsp, 8*2
            mov  eax, ecx
            xor  edx, edx
            mov  ecx, 1000
            div  ecx
           imul  edx, 1000000
            mov  qword[rsp+8*0], rax
            mov  qword[rsp+8*1], rdx
            mov  rdi, rsp
            xor  esi, esi
            mov  eax, sys_nanosleep
        syscall
            add  rsp, 8*2
            pop  rdi rsi rbx
            ret


;;;;;;;;;;
; memory ;
;;;;;;;;;;


Os_VirtualAllocNuma:
    ; rcx is size
    ; edx is numa node
            mov  r10d, MAP_PRIVATE or MAP_ANONYMOUS
.go:
            cmp  edx, -1
             je  Os_VirtualAlloc.go
           push  rbp rbx rsi rdi r15
            sub  rsp, 16
if DEBUG
            add  qword[DebugBalance], rcx
end if
            mov  ebx, edx
            mov  rbp, rcx
            xor  edi, edi
            mov  rsi, rcx
            mov  edx, PROT_READ or PROT_WRITE
             or  r8, -1
            xor  r9, r9
            mov  eax, sys_mmap
        syscall
            mov  r15, rax
           test  rax, rax
             js  Failed_sys_mmap

            mov  rdi, r15       ; addr
            mov  rsi, rbp       ; len
            mov  edx, MPOL_BIND ; mode
            xor  eax, eax
            bts  rax, rbx
            mov  qword[rsp], rax
            mov  r10, rsp   ; nodemask
            mov  r8d, 32    ; maxnode
            xor  r9, r9     ; flags
            mov  eax, sys_mbind
        syscall
           test  eax, eax
             jz  .Done
            lea  rcx, [.sz_mbind]
            mov  edx, WARNIDX_MBIND
           call  _Warn
.Done:
	        mov  rax, r15
	        add  rsp, 16
	        pop  r15 rdi rsi rbx rbp
	        ret

.sz_mbind: db 'sys_mbind',0


_Warn:
            bts  dword[WarnMask], edx
            jnc  @1f
            ret
    @1:
           push  rdi rsi rax
            lea  rdi, [Output]
            mov  rax, 'warning:'
          stosq
            mov  al, ' '
          stosb
           call  PrintString
            mov  rax, ' failed '
          stosq
            mov  eax, 'rax:'
          stosd
            mov  al, ' '
          stosb
            pop  rcx rsi
           call  PrintHex
        PrintNL
           call  WriteLine_Output
            pop  rdi
            ret


Os_VirtualAlloc:
    ; rcx is size
            mov  r10d, MAP_PRIVATE or MAP_ANONYMOUS
.go:
           push  rsi rdi rbx
if DEBUG
            add  qword[DebugBalance], rcx
end if
            xor  edi, edi
            mov  rsi, rcx
            mov  edx, PROT_READ or PROT_WRITE
             or  r8, -1
            xor  r9, r9
            mov  eax, sys_mmap
        syscall
           test  rax, rax
             js  Failed_sys_mmap
            pop  rbx rdi rsi
            ret


Os_VirtualFree:
    ; rcx is address
    ; rdx is size
           push  rsi rdi rbx
           test  rcx, rcx
             jz  .null
if DEBUG
            sub  qword[DebugBalance], rdx
end if
            mov  rdi, rcx
            mov  rsi, rdx
            mov  eax, sys_munmap
        syscall
           test  eax, eax
            jnz  Failed_sys_munmap
.null:
            pop  rbx rdi rsi
            ret



Os_VirtualAlloc_LargePages:
    ; rcx is size
    ;  if this fails, we want to return 0
    ;  so that Os_VirtualAlloc can be called
    ;
    ;  global var LargePageMinSize could be
    ;    <0 : tried to use large pages and failed
    ;    =0 : haven't tried to use larges yet
    ;    >0 : succesfully used large pages
    ;
    ; out:
    ;  rax address of base
    ;  rdx size allocated
    ;        should be multiple of qword[LargePageMinSize]

           push  rbx rsi rdi r14 r15
            mov  r14, rcx
            xor  edi, edi
            mov  rsi, rcx
            mov  edx, PROT_READ or PROT_WRITE
             or  r8, -1
            xor  r9, r9
            mov  r10d, MAP_PRIVATE or MAP_ANONYMOUS
            mov  eax, sys_mmap
        syscall
            mov  r15, rax
           test  rax, rax
             js  Failed_sys_mmap
if DEBUG
            add  qword[DebugBalance], r14
end if
            mov  rdi, r15
            mov  rsi, r14
            mov  edx, MADV_HUGEPAGE
            mov  eax, sys_madvise
        syscall
           test  eax, eax
             jz  .Over
            lea  rcx, [.sz_madvise]
            mov  edx, WARNIDX_MADVISE
           call  _Warn
.Over:
            mov  rax, r15
            mov  rdx, r14
            mov  qword[LargePageMinSize], 1

            pop  r15 r14 rdi rsi rbx
            ret

.sz_madvise: db 'sys_madvide',0






;;;;;;;;;;;;;;;;
; input/output ;
;;;;;;;;;;;;;;;;

Os_ParseCommandLine:
           push  rbp rbx rsi rdi r13 r14 r15
            mov  rbp, qword[rspEntry]

            xor  eax, eax
            mov  qword[ioBuffer.cmdLineStart], rax

            xor  ebx, ebx
            xor  edi, edi
.NextArg1:
            add  ebx, 1
            cmp  ebx, dword[rbp+8*0]
            jae  .ArgDone1
            mov  rcx, qword[rbp+8*1+8*rbx]
           call  StringLength
            add  edi, eax
            jmp  .NextArg1
.ArgDone1:

            lea  ecx, [rdi+4097]
            and  ecx, -4096
            mov  qword[ioBuffer.inputBufferSizeB], rcx
           call  Os_VirtualAlloc
            mov  qword[ioBuffer.inputBuffer], rax

           test  edi, edi
             jz  .Done

            mov  rdi, qword[ioBuffer.inputBuffer]
            mov  qword[ioBuffer.cmdLineStart], rdi

            xor  ebx, ebx
.NextArg2:
            add  ebx, 1
            cmp  ebx, dword[rbp+8*0]
            jae  .ArgDone2
            mov  rsi, qword[rbp+8*1+8*rbx]
            mov  dl, 10
.CopyString:
          lodsb
           test  al, al
             jz  .CopyDone
            cmp  al, SEP_CHAR
          cmove  eax, edx
          stosb
            jmp  .CopyString
.CopyDone:
            mov  al, ' '
          stosb
            jmp  .NextArg2
.ArgDone2:
            mov  byte[rdi], 0 ; replace space with null

.Done:
            pop  r15 r14 r13 rdi rsi rbx rbp
            ret

Os_SetStdHandles:
    ; no arguments
    ; these are always 0,1,2
            ret


Os_WriteOut_Output:
            lea   rcx, [Output]
Os_WriteOut:
    ; in: rcx  address of string start
    ;     rdi  address of string end
           push  rsi rdi rbx

            mov  rsi, rcx
            mov  rdx, rdi
            sub  rdx, rcx
            mov  edi, 1
.go:
            mov  eax, sys_write
        syscall
           test  rax, rax
             js  Failed_sys_write
            pop  rbx rdi rsi
            ret


Os_WriteError:
    ; in: rcx  address of string start
    ;     rdi  address of string end
           push  rsi rdi rbx
            mov  rsi, rcx
            mov  rdx, rdi
            sub  rdx, rcx
            mov  edi, 2
            jmp  Os_WriteOut.go



Os_ReadStdIn:
    ; in: rcx address to write
    ;     edx max size
    ; out: rax > 0 number of bytes written
    ;      rax = 0 nothing written; end of file
    ;      rax < 0 error
           push  rbx rsi rdi
            mov  edi, stdin
            mov  rsi, rcx
            mov  eax, sys_read 
        syscall
            pop  rdi rsi rbx
            ret



;;;;;;;;;;;;;;;;;;
; priority class ;
;;;;;;;;;;;;;;;;;;

Os_SetPriority_Realtime:
    ; must be root to set "higher" priority, normal user can only lower priority 
            mov  edx, -15		   ; priority
    @1:
           push  rsi rdi rbx
            mov  edi, PRIO_PROCESS    ; which 
            xor  esi, esi		   ; who
            mov  eax, sys_setpriority
        syscall
            pop  rbx rdi rsi 
            ret

Os_SetPriority_Normal:
            xor   edx, edx
            jmp   @1b

Os_SetPriority_Low:
            mov   edx, 10
            jmp   @1b

Os_SetPriority_Idle:
            mov   edx, 19
            jmp   @1b



;;;;;;;;;;;;;;;;;;;;;;;
; system capabilities ;
;;;;;;;;;;;;;;;;;;;;;;;


Os_SetThreadPoolInfo:
    ; see ThreadPool.asm for what this is supposed to do

virtual at rsp
            rq 1
 .Affinity  rq 1
 .buffer    rb 512
 .fstat     rq 24
 .fstring   rb 96
 .lend      rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

           push  rbx rsi rdi r12 r13 r14 r15
     _chkstk_ms  rsp, .localsize
            sub  rsp, .localsize

            mov  qword[.Affinity], rcx
            xor  eax, eax
            mov  dword[threadPool.nodeCnt], eax
            mov  dword[threadPool.coreCnt], eax

    ; read node data
    ;  suppose that node0 has cpu0-cpu3 and cpu8-cpu11
    ;  then /sys/devices/system/node/node0/cpumap
    ;   contains "f0f\n"

            lea  rbx, [threadPool.nodeTable]
             or  r12d, -1
    ;  r12d = N

.TryNextNode:
            add  r12d, 1
            cmp  r12d, MAX_NUMANODES
            jae  .TryNodesDone

            mov  ecx, r12d
             or  edx, -1
            mov  r8, qword[.Affinity]
           call  QueryNodeAffinity
           test  eax, eax
             jz  .TryNextNode

    ; look at /sys/devices/system/node/nodeN/cpumap
            lea  rdi, [.fstring]
            lea  rcx, [sz_linux_cpumap]
            lea  rdx, [.buffer]
            mov  qword[rdx + 8*0], r12
            xor  r8, r8
           call  PrintFancy
            xor  eax, eax
          stosd

            lea  rcx, [.fstring]
           call  Os_FileOpenRead
            mov  r15, rax
            cmp  rax, -1
             je  .TryNextNode
            mov  rdi, r15
            lea  rsi, [.buffer]
            mov  edx, 50 + MAX_LINUXCPUS ; hacky
            mov  eax, sys_read 
        syscall
            mov  rsi, rax
            mov  rcx, r15
           call  Os_FileClose
            cmp  rsi, 1
             jb  .TryNextNode

	; at this point, N is a valid node number
            xor  edx, edx
            mov  dword[rbx+NumaNode.nodeNumber], r12d
            mov  dword[rbx+NumaNode.coreCnt], edx   ; will increment later
            mov  qword[rbx+NumaNode.cmhTable], rdx  ; initialize to NULL, will allocate as needed
            mov  qword[rbx+NumaNode.parent], rbx    ; initialize to self

repeat MAX_LINUXCPUS/64
            mov  qword[rbx+NumaNode.cpuMask + 8*(% - 1)], rdx
end repeat

.ReadNextB:
            cmp  edx, MAX_LINUXCPUS
            jae  .ReadDone
            sub  esi, 1
             js  .ReadDone
          movzx  ecx, byte[.buffer + rsi]
            sub  ecx, '0'
             js  .ReadNextB
            cmp  ecx, 10
             jb  .ReadOk
            sub  ecx, 'a'-'0'
             js  .ReadNextB
            cmp  ecx, 'f'+1
            jae  .ReadNextB
            add  ecx, 10
.ReadOk:
	; each ascii char 0-9, a-f encodes 4 bits

repeat 4
           test  ecx, 1 shl (% - 1)
             jz  @1f
            bts  [rbx+NumaNode.cpuMask], rdx
    @1:
            add  edx, 1
end repeat
            jmp  .ReadNextB
.ReadDone:
            add  rbx, sizeof.NumaNode
            add  dword[threadPool.nodeCnt], 1
            jmp  .TryNextNode
.TryNodesDone:

    ; if we didn't find any nodes, assume that numa is not present
            mov  ebx, dword[threadPool.nodeCnt]
           test  ebx, ebx
             jz  .Absent

    ; assign parents
            xor  r15d, r15d
.Outer:
           imul  esi, r15d, sizeof.NumaNode
            lea  rsi, [rsi+threadPool.nodeTable]
            xor  r14d, r14d
.Inner:
           imul  edi, r14d, sizeof.NumaNode
            lea  rdi, [rdi + threadPool.nodeTable]
            mov  ecx, dword[rsi + NumaNode.nodeNumber]
            mov  edx, dword[rdi + NumaNode.nodeNumber]
            mov  r8, qword[.Affinity]
           call  QueryNodeAffinity
           test  eax, eax
             jz  .InnerNext
            mov  qword[rsi + NumaNode.parent], rdi
            jmp  .OuterNext
.InnerNext:
            add  r14d, 1
            cmp  r14d, ebx
             jb  .Inner
.OuterNext:
            add  r15d, 1
            cmp  r15d, ebx
             jb  .Outer

    ; read core data
    ;  suppose that cpu0 and cpu4 share the same core
    ;  then both /sys/devices/system/cpu/cpu0/topology/thread_siblings
    ;        and /sys/devices/system/cpu/cpu4/topology/thread_siblings
    ;   contain "11\n"

             or  r12d, -1
    ;  r12d = N
.TryNextCore:
            add  r12d, 1
            cmp  r12d, MAX_LINUXCPUS
            jae  .TryCoresDone

    ; look at /sys/devices/system/cpu/cpu0/topology/thread_siblings
            lea  rdi, [.fstring]
            lea  rcx, [sz_linux_siblings]
            lea  rdx, [.buffer]
            mov  qword[rdx + 8*0], r12
            xor  r8, r8
           call  PrintFancy
            xor  eax, eax
          stosd

            lea  rcx, [.fstring]
           call  Os_FileOpenRead
            mov  r15, rax
            cmp  rax, -1
             je  .TryNextCore
            mov  rdi, r15
            lea  rsi, [.buffer]
            mov  edx, 50+MAX_LINUXCPUS  ; hacky
            mov  eax, sys_read 
        syscall
            mov  rsi, rax
            mov  rcx, r15
           call  Os_FileClose
            cmp  rsi, 1
             jb  .TryNextCore

            xor  edx, edx
    ; get the lsb of bit set
.ReadNextB2:
            cmp  edx, MAX_LINUXCPUS
            jae  .TryNextCore
            sub  esi, 1
             js  .TryNextCore
          movzx  ecx, byte[.buffer + rsi]
            sub  ecx, '0'
             js  .ReadNextB2
            cmp  ecx, 10
             jb  .ReadOk2
            sub  ecx, 'a'-'0'
             js  .ReadNextB2
            cmp  ecx, 'f'+1
            jae  .ReadNextB2
            add  ecx, 10
.ReadOk2:
           test  ecx, ecx
            jnz  .found
            add  edx, 4
            jmp  .ReadNextB2
.found:
            bsf  ecx, ecx
            add  edx, ecx
            cmp  edx, r12d
            jne  .TryNextCore

    ; edx is now lsb of this thread_siblings
    ; loop through nodes and add up cores
            lea  rsi, [threadPool.nodeTable]
           imul  ebx, dword[threadPool.nodeCnt], sizeof.NumaNode
            add  rbx, rsi
.CoreCountNextNode:
            xor  eax, eax
             bt  [rsi + NumaNode.cpuMask], rdx
            adc  eax, eax
            add  dword[rsi + NumaNode.coreCnt], eax
            add  dword[threadPool.coreCnt], eax
            add  rsi, sizeof.NumaNode
            cmp  rsi, rbx
             jb  .CoreCountNextNode

            jmp  .TryNextCore
.TryCoresDone:
    ; if coreCnt=0, go to numa unaware state
            mov  eax, dword[threadPool.coreCnt]
           test  eax, eax
             jz  .Absent
.Return:
            add  rsp, .localsize
            pop  r15 r14 r13 r12 rdi rsi rbx
            ret

.Absent:
            mov  ecx, 1
            mov  dword[threadPool.nodeCnt], ecx
            mov  dword[threadPool.coreCnt], ecx
            xor  eax, eax
            lea  rdi, [threadPool.nodeTable]
            mov  dword[rdi + NumaNode.nodeNumber], -1
            mov  dword[rdi + NumaNode.coreCnt], ecx
            mov  qword[rdi + NumaNode.cmhTable], rax
            mov  qword[rdi + NumaNode.parent], rdi
repeat MAX_LINUXCPUS/64
            mov  qword[rdi + NumaNode.cpuMask+8*(%-1)], rax
end repeat
            jmp  .Return


sz_linux_cpumap    db '/sys/devices/system/node/node%U0/cpumap',0
sz_linux_siblings  db '/sys/devices/system/cpu/cpu%U0/topology/thread_siblings',0
sz_linux_nodeinfo  db 'info string node %i0 parent %i1 cores %u2 mask 0x',0


Os_DisplayThreadPoolInfo:
           push  rbx rsi rdi r14 r15
            sub  rsp, 8*4
            lea  rsi, [threadPool.nodeTable]
           imul  ebx, dword[threadPool.nodeCnt], sizeof.NumaNode
            add  rbx, rsi
.PrintNextNode:
            lea  rdi, [Output]

            lea  rcx, [sz_linux_nodeinfo]
            mov  rdx, rsp
            xor  r8, r8
            mov  eax, dword[rsi+NumaNode.nodeNumber]
            mov  dword[rsp+8*0], eax
            mov  rax, qword[rsi+NumaNode.parent]
            mov  eax, dword[rax+NumaNode.nodeNumber]
            mov  dword[rsp+8*1], eax
            mov  eax, dword[rsi+NumaNode.coreCnt]
            mov  dword[rsp+8*2], eax
           call  PrintFancy

            mov  r15d, (MAX_LINUXCPUS/64)-1
    @1:
            mov  rcx, qword[rsi+NumaNode.cpuMask+8*r15]
           test  rcx, rcx
            jnz  .PrintMaskLoop
            sub  r15d, 1
            jnz  @1b
.PrintMaskLoop:
            mov  rcx, qword[rsi+NumaNode.cpuMask+8*r15]
           call  PrintHex
           test  r15d, r15d
             jz  @1f
            mov  al, '_'
          stosb
	@1:	
            sub  r15d, 1
            jns  .PrintMaskLoop
        PrintNL
           call  WriteLine_Output
            add  rsi, sizeof.NumaNode
            cmp  rsi, rbx
             jb  .PrintNextNode
.Return:
            add  rsp, 8*4
            pop  r15 r14 rdi rsi rbx
            ret




Os_CheckCPU:
           push   rbp rbx r15

if CPU_HAS_POPCNT 
            lea  r15, [szCPUError.POPCNT]
            mov  eax, 1
            xor  ecx, ecx
          cpuid
            and  ecx, (1 shl 23)
            cmp  ecx, (1 shl 23)
            jne  .Failed
end if

if CPU_HAS_AVX1
            lea  r15, [szCPUError.AVX1]
            mov  eax, 1
            xor  ecx, ecx
          cpuid
            and  ecx, (1 shl 27) + (1 shl 28)
            cmp  ecx, (1 shl 27) + (1 shl 28)
            jne  .Failed
            mov  ecx, 0
         xgetbv
            and  eax, (1 shl 1) + (1 shl 2)
            cmp  eax, (1 shl 1) + (1 shl 2)
            jne  .Failed
end if

if CPU_HAS_AVX2
            lea  r15, [szCPUError.AVX2]
            mov  eax, 7
            xor  ecx, ecx
          cpuid
            and  ebx, (1 shl 5)
            cmp  ebx, (1 shl 5)
            jne  .Failed
end if

if CPU_HAS_BMI1
            lea  r15, [szCPUError.BMI1]
            mov  eax, 7
            xor  ecx, ecx
          cpuid
            and  ebx, (1 shl 3)
            cmp  ebx, (1 shl 3)
            jne  .Failed
end if

if CPU_HAS_BMI2
            lea  r15, [szCPUError.BMI2]
            mov  eax, 7
            xor  ecx, ecx
          cpuid
            and  ebx, (1 shl 8)
            cmp  ebx, (1 shl 8)
            jne  .Failed
end if

            pop  r15 rbx rbp
            ret

.Failed:
            lea  rdi, [Output]
            lea  rcx, [szCPUError]
           call  PrintString
            mov  rcx, r15
           call  PrintString
            xor  eax, eax
          stosd
            lea  rdi, [Output]
            jmp  Failed


;;;;;;;;;
; fails ;
;;;;;;;;;

Failed:
    ; rdi : null terminated string
           push  rax
            mov  rcx, rdi
            lea  rdi, [Output]
           call  PrintString
            mov  rax, ' failed '
          stosq
            mov  rax, ' rax: 0x'
          stosq
            pop  rcx
           call  PrintHex
            xor  eax, eax
          stosb
            lea  rdi, [Output]
           call  Os_ErrorBox
            mov  ecx, 1
           call  Os_ExitProcess


Failed_HashmaxTooLow:
		lea   rdi, [.l1]
		jmp   Failed
	.l1:db 'HSHMAX too low!',0
Failed_sys_write:
		lea   rdi, [.l1]
		jmp   Failed
	.l1: db 'sys_write',0
Failed_sys_mmap:
		lea   rdi, [.l1]
		jmp   Failed
	.l1: db 'sys_mmap',0
Failed_sys_fstat:
		lea   rdi, [.l1]
		jmp   Failed
	.l1: db 'sys_fstat',0


Failed_sys_munmap:
		lea   rdi, [.l1]
		jmp   Failed
	.l1: db 'sys_munmap',0

Failed_stub_clone:
		lea   rdi, [.l1]
		jmp   Failed
        .l1: db 'stub_clone',0

Failed_sys_futex:
		lea   rdi, [.l1]
		jmp   Failed
        .l1: db 'sys_futex',0

Failed_sys_sched_setaffinity:
		lea   rdi, [.l1]
		jmp   Failed
        .l1: db 'sys_sched_setaffinity',0

Failed_EventWait:
		lea   rdi, [.l1]
		jmp   Failed
        .l1: db '_EventWait',0


Os_ErrorBox:
    ; rdi points to null terminated string to write to message box 
    ; this may be called from a leaf with no stack allignment 
    ; one purpose is a hard exit on failure
            mov  rcx, rdi
           call  StringLength
           push  rdi rsi rbx 
            mov  rsi, rdi 
            mov  edi, stderr 
            mov  rdx, rax 
            mov  eax, sys_write 
        syscall
            lea  rsi, [sz_NewLine]
            mov  edi, stderr 
            mov  rdx, 1
            mov  eax, sys_write 
        syscall
            pop  rbx rsi rdi 
            ret


	; Thanks to
	;
	; HeavyThing x86_64 assembly language library and showcase programs
	; Copyright 2015, 2016 2 Ton Digital 
	; Homepage: https://2ton.com.au/
	; Author: Jeff Marrison <jeff@2ton.com.au>
	;
	; for the meat of this function

sz___vdso_clock_gettime	db '__vdso_clock_gettime',0
sz_procselfauxv		db '/proc/self/auxv',0

vdso_FindSymbol:
    ; vdso.inc: we parse /proc/self/auxv (and die if we can't)
    ; to get our kernel-exposed functions we are interested in
    ;
    ; in: rcx address of symbol string
    ; out: rax address of function
    ;          0 if failed
virtual at rsp
 .space     rb 1024 ; read it directly onto our stack
 .symbol    rq 1
            rq 1
 .lend	    rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))
           push  rbx r12 r13 r14 r15
            sub  rsp, .localsize
            mov  qword[.symbol], rcx

            mov  eax, sys_open
            lea  rdi, [sz_procselfauxv]
            xor  esi, esi		      ; O_RDONLY
        syscall
           test  eax, eax
             js  .failed

            mov  ebx, eax
            mov  edi, eax
            lea  rsi, [.space]
            mov  edx, 1024
            mov  eax, sys_read
        syscall
           test  eax, eax
             js  .failed

            mov  edi, ebx
            mov  ebx, eax
            mov  eax, sys_close
        syscall
            shr  ebx, 4		; each entry is 8 byte type, 8 byte value
           test  ebx, ebx
             jz  .failed

            lea  r12, [.space]
.ehdr_search:
            cmp  qword[r12], 0x21	; AT_SYSINFO_EHDR
             je  .ehdr_found
            add  r12, 16
            sub  ebx, 1
            jnz  .ehdr_search
            jmp  .failed
.ehdr_found:
            mov  rbx, qword[r12+8] ; base address of our VDSO
           test  rbx, rbx
             jz  .failed
    ; we aren't really interested in validating it, if we got it from the kernel
    ; it is most-likely a-okay
    ; so all we are really after is the relocation table
          movzx  r12d, word[rbx+0x38]   ; Elf64_Ehdr.e_phnum
            mov  r15, [rbx+0x20]        ; Elf64_Ehdr.e_phoff
            add  r15, rbx
           test  r12d, r12d
             jz  .failed
            xor  r13d, r13d
            xor  r14d, r14d
            mov  qword[rsp+992], rbx    ; save our Ehdr
            mov  qword[rsp+1008], -1    ; we'll use this as link base pointer
            mov  qword[rsp+1016], 0     ; we'll use this as our dynamic program header
.phdr_scan:
            mov  eax, 0x38
            xor  edx, edx
            mul  r13d
            lea  rdi, [r15+rax] ; Elf64_Phdr[r13d]
            mov  ecx, [rdi]     ; Elf64_Phdr.p_type
            mov  rax, [rdi+16]  ; Elf64_Phdr.p_vaddr
            cmp  ecx, 1         ; PT_LOAD
             je  .phdr_scan_ptload
            cmp  ecx, 2
             je  .phdr_scan_ptdynamic
.phdr_scan_next:
            add  r13d, 1
            sub  r12d, 1
            jnz  .phdr_scan
            cmp  qword[rsp+1008], -1
             je  .failed
            cmp  qword[rsp+1016], 0
             je  .failed
    ; so now we can get our dynamic entries out
            mov  rsi, [rsp+1008]
            mov  rdi, [rsp+1016]
            mov  rcx, rbx
            mov  rax, [rdi+16]     ; Elf64_Phdr.p_vaddr

            sub  rcx, rsi          ; relocation
            add  rax, rcx          ; Dyn

            mov  r14, rcx
            mov  r15, rax

            xor  ebx, ebx          ; our symtab
            xor  r12d, r12d        ; our strtab

            mov  qword[rsp+1000], 0	; our symbol count (what will be anyway)
    ; all we are really interested in here is finding the symbol table
    ; and the string table (so we can do name lookups in it for what we are after)
    ; well, and the DT_HASH entry so we can figure out how many symbols we have

.findstrsymtab:
    ; so we need r15.d_un.d_val + relocation _if_ r15.d_tag == DT_SYMTAB
    ; d_tag is the first signed 64 bits of r15, d_un is our union next 64 bits
            cmp  qword[r15], 0
             je  .dyndone
            cmp  qword[r15], 4     ; DT_HASH
             je  .foundhash
            cmp  qword[r15], 5     ; DT_STRTAB
             je  .foundstrtab
            cmp  qword[r15], 6     ; DT_SYMTAB
             je  .foundsymtab
            add  r15, 16
            jmp  .findstrsymtab
.foundhash:
            mov  rcx, [r15+8]
            lea  rsi, [r14+rcx]
            mov  eax, [rsi+4]      ; DT_HASH, second word
    ; symbol count is in eax
            mov  dword[rsp+1000], eax
            add  r15, 16
            jmp  .findstrsymtab
.foundstrtab:
    ; d_un.val + our relocation goods is what we want
            mov  rcx, [r15+8]
            lea  r12, [r14+rcx]    ; strtab
            add  r15, 16
            jmp  .findstrsymtab
.foundsymtab:
    ; d_un.val + our relocation goods is what we want
            mov  rcx, [r15+8]
            lea  rbx, [r14+rcx]    ; symtab
            add  r15, 16
            jmp  .findstrsymtab
.dyndone:
           test  rbx, rbx              ; symtab
             jz  .failed
           test  r12, r12              ; strtab
             jz  .failed
            cmp  dword[rsp+1000], 0    ; count
             je  .failed
	; if we made it to here, everything looks okay, walk our symbols
.symwalk:
    ; strtab + [rbx] == st_name of this symbol
            mov  r13d, dword [rbx]
            add  r13, r12
    ; r13 = address of symbol string
            mov  rsi, r13
            mov  rcx, qword[.symbol]
           call  CmpString
           test  eax, eax
             jz  .symwalk_next
            cmp  byte[rsi], 0	; make sure we are at the end
             jz  .foundit		;  of the symbol
.symwalk_next:
            add  rbx, 0x18
            sub  dword[rsp+1000], 1
            jnz  .symwalk
    ; if we made it to here, we didn't find what we were looking for
.failed:
            xor  eax, eax
.return:
            add  rsp, .localsize
            pop  r15 r14 r13 r12 rbx
            ret
.foundit:
            mov  rax, qword[rbx+8]
            add  rax, qword[rsp+992]
            sub  rax, qword[rsp+1008]	; the address of our symbol
            jmp  .return

.phdr_scan_ptload:
    ; make sure it already isn't set
            cmp  qword[rsp+1008], -1
            jne  .phdr_scan_next
            mov  [rsp+1008], rax		; link base pointer == Elf64_Phdr[r13d].p_vaddr
            jmp  .phdr_scan_next
.phdr_scan_ptdynamic:
            mov  [rsp+1016], rdi
            jmp  .phdr_scan_next
