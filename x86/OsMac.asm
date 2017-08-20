
;;;;;;;;;
; mutex ;
;;;;;;;;;


Os_MutexCreate:
        ; rcx: address of Mutex
               push   rbx rsi rdi
                mov   rdi, rcx
                xor   esi, esi
               call   _pthread_mutex_init
               test   eax, eax
                jnz   Failed_pthread_mutex_init_MutexCreate
                pop   rdi rsi rbx
                ret
Os_MutexDestroy:
        ; rcx: address of Mutex
               push   rbx rsi rdi
                mov   rdi, rcx
               call   _pthread_mutex_destroy
               test   eax, eax
                jnz   Failed_pthread_mutex_destroy_MutexDestroy
                pop   rdi rsi rbx
                ret
Os_MutexLock:
        ; rcx: address of Mutex
               push   rbx rsi rdi
                mov   rdi, rcx
               call   _pthread_mutex_lock
               test   eax, eax
                jnz   Failed_pthread_mutex_lock_MutexLock
                pop   rdi rsi rbx
                ret
Os_MutexUnlock:
        ; rcx: address of Mutex
               push   rbx rsi rdi
                mov   rdi, rcx
               call   _pthread_mutex_unlock
               test   eax, eax
                jnz   Failed_pthread_mutex_unlock_MutexUnlock
                pop   rdi rsi rbx
                ret


;;;;;;;;;
; event ;
;;;;;;;;;

Os_EventCreate:
    	; rcx: address of ConditionalVariable
               push   rbx rsi rdi
                mov   rdi, rcx
                xor   esi, esi
               call   _pthread_cond_init
               test   eax, eax
                jnz   Failed_pthread_cond_init_EventCreate
                pop   rdi rsi rbx
                ret
Os_EventDestroy:
    	; rcx: address of ConditionalVariable
               push   rbx rsi rdi
                mov   rdi, rcx
               call   _pthread_cond_destroy
               test   eax, eax
                jnz   Failed_pthread_cond_destroy_EventDestroy
                pop   rdi rsi rbx
                ret
Os_EventSignal:
    	; rcx: address of ConditionalVariable
               push   rbx rsi rdi
                mov   rdi, rcx
               call   _pthread_cond_signal
               test   eax, eax
                jnz   Failed_pthread_cond_signal_EventSignal
                pop   rdi rsi rbx
                ret
Os_EventWait:
    	; rcx: address of ConditionalVariable
    	; rdx: address of Mutex
               push   rbx rsi rdi
                mov   rdi, rcx
                mov   rsi, rdx
               call   _pthread_cond_wait
               test   eax, eax
                jnz   Failed_pthread_cond_wait_EventWait
                pop   rdi rsi rbx
                ret



;;;;;;;;
; file ;
;;;;;;;;

Os_FileWrite:
	; in: rcx handle from CreateFile (win), fd (linux)
	;     rdx buffer
	;     r8d size (32bits)
	; out: eax !=0 success
	       push   rsi rdi rbx
		mov   rdi, rcx	; fd
		mov   rsi, rdx	; buffer
		mov   edx, r8d	; count
               call   _write
		sar   rax, 63
		add   eax, 1
		pop   rbx rdi rsi
		ret

Os_FileRead:
	; in: rcx handle from CreateFile (win), fd (linux)
	;     rdx buffer
	;     r8d size (32bits)
	; out: eax !=0 success
	       push   rsi rdi rbx
		mov   rdi, rcx	; fd
		mov   rsi, rdx	; buffer
		mov   edx, r8d	; count
               call   _read
		sar   rax, 63
		add   eax, 1
		pop   rbx rdi rsi
		ret


Os_FileSize:
	; in: rcx handle from CreateFile (win), fd (linux)
	; out:  rax size
	       push   rbx rsi rdi
		sub   rsp, (sizeof.stat + 15) and -16
		mov   rdi, rcx
		mov   rsi, rsp
               call   _fstat
	       test   eax, eax
		jnz   Failed_fstat_FileSize
		mov   rax, qword[rsp+stat.st_size]
		add   rsp, (sizeof.stat + 15) and -16
		pop   rdi rsi rbx
		ret


Os_FileOpenWrite:
	; in: rcx path string
	; out: rax handle from CreateFile (win), fd (linux)
	;      rax=-1 on error
	       push   rbx rsi rdi
		mov   rdi, rcx
		mov   esi, O_WRONLY or O_CREAT or O_TRUNC
                mov   edx, 0664o        ; set mode to 664 octal
               call   _open
	       test   eax, eax
		jns   @f
		 or   rax, -1
	@@:
                pop   rdi rsi rbx
		ret


Os_FileOpenRead:
	; in: rcx path string
	; out: rax handle from CreateFile (win), fd (linux)
	;      rax=-1 on error
	       push   rbx rsi rdi
		mov   rdi, rcx
		mov   esi, O_RDONLY
               call   _open
	       test   eax, eax
		jns   @f
		 or   rax, -1
	@@:
                pop   rdi rsi rbx
		ret

Os_FileClose:
	; in: rcx handle from CreateFile (win), fd (linux) 
	       push   rbx rsi rdi
		mov   rdi, rcx
               call   _close
		pop   rdi rsi rbx
		ret

Os_FileMap:
	; in: rcx handle (win), fd (linux)
	; out: rax base address
	;      rdx handle from CreateFileMapping (win), size (linux)
	; get file size
	       push   rbp rbx rsi rdi r15
		sub   rsp, (sizeof.stat + 15) and -16
		mov   rbp, rcx
		mov   rdi, rcx
		mov   rsi, rsp
               call   _fstat
	       test   eax, eax
		jnz   Failed_fstat_FileMap
		mov   rbx, qword[rsp+stat.st_size]
	; map file
		xor   edi, edi		; addr
		mov   rsi, rbx		; length
		mov   edx, PROT_READ	; protection flags
		mov   ecx, MAP_PRIVATE	; mapping flags
		mov   r8, rbp		; fd
		xor   r9d, r9d		; offset
               call   _mmap
	       test   rax, rax
		 js   Failed_mmap_FileMap
	; return size in rdx, base address in rax
		mov   rdx, rbx
		add   rsp, (sizeof.stat + 15) and -16
		pop   r15 rdi rsi rbx rbp
		ret

Os_FileUnmap:
	; in: rcx base address
	;     rdx handle from CreateFileMapping (win), size (linux)
	       push   rbx rsi rdi
	       test   rcx, rcx
		 jz   @f
		mov   rdi, rcx	      ; addr
		mov   rsi, rdx	      ; length
               call   _munmap
	       test   eax, eax
		jnz   Failed_munmap_FileUnmap
	@@:
                pop   rdi rsi rbx
		ret



;;;;;;;;;;
; thread ;
;;;;;;;;;;

Os_ThreadCreate:
        ; in: rcx start address
        ;     rdx parameter to pass
        ;     r8  address of NumaNode struct
        ;     r9  address of ThreadHandle Struct
               push   rbx rsi rdi
                mov   rdi, r9
                xor   esi, esi
               xchg   rcx, rdx
               call   _pthread_create
                pop   rdi rsi rbx
                ret

Os_ThreadJoin:
        ; rcx:  address of ThreadHandle struct
               push   rbx rsi rdi
                mov   rdi, qword[rcx]
                xor   esi, esi
               call   _pthread_join
                pop   rdi rsi rbx
                ret

Os_ExitProcess:
        ; rcx is exit code
                mov   edi, ecx
                jmp   _exit

Os_ExitThread:
        ; rcx is exit code
                mov   edi, ecx
                jmp   _pthread_exit



;;;;;;;;;;
; timing ;
;;;;;;;;;;

              align   16
Os_GetTime:                                       ; those ***** didn't implement clock_gettime
        ; out rax + rdx/2^64 = time in ms
               push   rbx rsi rdi
                sub   rsp, 8*2
                mov   rbx, _COMM_PAGE_TIME_DATA_START
.TryAgain:
                mov   esi, dword[rbx+_GTOD_GENERATION]
               test   esi, esi
                 jz   .Failed
                mov   edi, dword[rbx+_NT_GENERATION]
               test   edi, edi
                 jz   .TryAgain
             lfence
              rdtsc
             lfence
                shl   rdx, 32
                add   rax, rdx
                sub   rax, qword[rbx+_NT_TSC_BASE]
                mov   ecx, dword[rbx+_NT_SCALE]
                mov   r8, qword[rbx+_NT_NS_BASE]
                cmp   edi, dword[rbx+_NT_GENERATION]
                jne   .TryAgain
                sub   r8, qword[rbx+_GTOD_NS_BASE]
                mov   r9, qword[rbx+_GTOD_SEC_BASE]
                cmp   esi, dword[rbx+_GTOD_GENERATION]
                jne   .TryAgain
                mul   rcx
               shrd   rax, rdx, 32
                add   rax, r8
                mov   rcx, 18446744073709;551616   2^64/10^6
                mul   rcx
               imul   r9, 1000
                add   rdx, r9
               xchg   rax, rdx
                add   rsp, 8*2
                pop   rdi rsi rbx
                ret

.Failed:
                mov   rdi, rsp
                xor   esi, esi
                xor   edx, edx                  ; those ***** changed sys_gettimeofday
                mov   eax, sys_gettimeofday
            syscall
               test   rax, rax
                 jz   @f                        ; those ***** might return the result in rax:rdx
                mov   qword[rsp+8*0], rax
                mov   dword[rsp+8*1], edx
        @@:
                mov   eax, dword[rsp+8*1]	; tv_usec
                mov   rcx, 18446744073709551;616   2^64/10^3
                mul   rcx
               imul   rcx, qword[rsp+8*0], 1000
                add   rdx, rcx
               xchg   rax, rdx
                add   rsp, 8*2
                pop   rdi rsi rbx
Os_InitializeTimer:
                ret

Os_GetTime_SYS:        ; call this to ensure a system call
               push   rbx rsi rdi
                sub   rsp, 8*2
                jmp   Os_GetTime.Failed


Os_Sleep:
        ; ecx  ms
               push   rbx rsi rdi
                sub   rsp, 8*2
                mov   eax, ecx
                xor   edx, edx
                mov   ecx, 1000
                div   ecx
               imul   edx, 1000000
                mov   qword[rsp+8*0], rax
                mov   qword[rsp+8*1], rdx
                mov   rdi, rsp
                xor   esi, esi
               call   _nanosleep
                add   rsp, 8*2
                pop   rdi rsi rbx
                ret


;;;;;;;;;;
; memory ;
;;;;;;;;;;


Os_VirtualAllocNuma:
        ; rcx is size
        ; edx is numa node

Os_VirtualAlloc:
        ; rcx is size
;                mov   rdi, rcx
;                jmp   malloc
	       push   rsi rdi rbx
		xor   edi, edi
		mov   rsi, rcx
		mov   edx, PROT_READ or PROT_WRITE
		mov   ecx, MAP_PRIVATE or MAP_ANON
		 or   r8, -1
		xor   r9, r9
               call   _mmap
               test   rax, rax
                 js   Failed_mmap
		pop   rbx rdi rsi
		ret

Os_VirtualFree:
        ; rcx is address
        ; rdx is size
;                mov   rdi, rcx
;                jmp   free
               push   rsi rdi rbx
               test   rcx, rcx
                 jz   .null
                mov   rdi, rcx
                mov   rsi, rdx
               call   _munmap
               test   eax, eax
                jnz   Failed_mmap
.null:
                pop   rbx rdi rsi
                ret

Os_VirtualAlloc_LargePages:
        ; rcx is size
        ;  if this fails, we want to return 0
        ;  so that _VirtualAlloc can be called
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

                xor   eax, eax
                xor   edx, edx
                ret





;;;;;;;;;;;;;;;;
; input/output ;
;;;;;;;;;;;;;;;;


Os_ParseCommandLine:
	       push   rbp rbx rsi rdi r15

		mov   rbp, qword[rspEntry]

		xor   eax, eax
		mov   qword[ioBuffer.cmdLineStart], rax

		xor   ebx, ebx
		xor   edi, edi
    .NextArg1:
		add   ebx, 1
		cmp   ebx, dword[rbp+8*0]
		jae   .ArgDone1
		mov   rcx, qword[rbp+8*1+8*rbx]
	       call   StringLength
		add   edi, eax
		jmp   .NextArg1
    .ArgDone1:

		lea   ecx, [rdi+4097]
		and   ecx, -4096
		mov   qword[ioBuffer.inputBufferSizeB], rcx
	       call   Os_VirtualAlloc
		mov   qword[ioBuffer.inputBuffer], rax

	       test   edi, edi
		 jz   .Done

		mov   rdi, qword[ioBuffer.inputBuffer]
		mov   qword[ioBuffer.cmdLineStart], rdi

		xor   ebx, ebx
    .NextArg2:
		add   ebx, 1
		cmp   ebx, dword[rbp+8*0]
		jae   .ArgDone2
		mov   rsi, qword[rbp+8*1+8*rbx]
		mov   dl, 10
     .CopyString:
	      lodsb
	       test   al, al
		 jz   .CopyDone
		cmp   al, SEP_CHAR
	      cmove   eax, edx
	      stosb
		jmp   .CopyString
     .CopyDone:
		mov   al, ' '
	      stosb
		jmp   .NextArg2
    .ArgDone2:
		mov   byte[rdi], 0 ; replace space with null

.Done:
		pop   r15 rdi rsi rbx rbp
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
               push   rsi rdi rbx
                mov   rsi, rcx
                mov   rdx, rdi
                sub   rdx, rcx
                mov   edi, stdout
.go:
               call   _write
                pop   rbx rdi rsi
                ret


Os_WriteError:
        ; in: rcx  address of string start
        ;     rdi  address of string end
               push   rsi rdi rbx
                mov   rsi, rcx
                mov   rdx, rdi
                sub   rdx, rcx
                mov   edi, stderr
                jmp   Os_WriteOut.go



Os_ReadStdIn:
; UNTESTED
        ; in: rcx address to write
        ;     edx max size
        ; out: rax > 0 number of bytes written
        ;      rax = 0 nothing written; end of file
        ;      rax < 0 error

               push   rbx rsi rdi
                mov   edi, stdin
                mov   rsi, rcx
               call   _read
                pop   rdi rsi rbx
                ret


;;;;;;;;;;;;;;;;;;
; priority class ;
;;;;;;;;;;;;;;;;;;

Os_SetPriority_Realtime:
Os_SetPriority_Normal:
Os_SetPriority_Low:
Os_SetPriority_Idle:
                ret




;;;;;;;;;;;;;;;;;;;;;;;
; system capabilities ;
;;;;;;;;;;;;;;;;;;;;;;;


Os_SetThreadPoolInfo:
        ; see ThreadPool.asm for what this is supposed to do

               push   rbx rsi rdi

                mov   ecx, 1
                mov   dword[threadPool.nodeCnt], ecx
                mov   dword[threadPool.coreCnt], ecx

                xor   eax, eax
                lea   rdi, [threadPool.nodeTable]
                mov   dword[rdi+NumaNode.nodeNumber], -1
                mov   dword[rdi+NumaNode.coreCnt], ecx
                mov   qword[rdi+NumaNode.cmhTable], rax
                mov   qword[rdi+NumaNode.parent], rdi

                pop   rdi rsi rbx
                ret





Os_DisplayThreadPoolInfo:
                ret




Os_CheckCPU:
               push   rbp rbx r15

if CPU_HAS_POPCNT
                lea   r15, [szCPUError.POPCNT]
                mov   eax, 1
                xor   ecx, ecx
              cpuid
                and   ecx, (1 shl 23)
                cmp   ecx, (1 shl 23)
                jne   .Failed
end if

if CPU_HAS_AVX1
                lea   r15, [szCPUError.AVX1]
                mov   eax, 1
                xor   ecx, ecx
              cpuid
                and   ecx, (1 shl 27) + (1 shl 28)
                cmp   ecx, (1 shl 27) + (1 shl 28)
                jne   .Failed
                mov   ecx, 0
             xgetbv
                and   eax, (1 shl 1) + (1 shl 2)
                cmp   eax, (1 shl 1) + (1 shl 2)
                jne   .Failed
end if

if CPU_HAS_AVX2
                lea   r15, [szCPUError.AVX2]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 5)
                cmp   ebx, (1 shl 5)
                jne   .Failed
end if

if CPU_HAS_BMI1
                lea   r15, [szCPUError.BMI1]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 3)
                cmp   ebx, (1 shl 3)
                jne   .Failed
end if

if CPU_HAS_BMI2
                lea   r15, [szCPUError.BMI2]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 8)
                cmp   ebx, (1 shl 8)
                jne   .Failed
end if

                pop  r15 rbx rbp
                ret

.Failed:
                lea   rdi, [Output]
                lea   rcx, [szCPUError]
               call   PrintString
                mov   rcx, r15
               call   PrintString
                xor   eax, eax
              stosd
                lea   rdi, [Output]
                jmp   Failed


;;;;;;;;;
; fails ;
;;;;;;;;;

Failed:
        ; rdi : null terminated string
               push   rax
                mov   rcx, rdi
                lea   rdi, [Output]
               call   PrintString
                mov   rax, ' rax: 0x'
              stosq
                pop   rcx
               call   PrintHex
                xor   eax, eax
              stosb
                lea   rdi, [Output]
               call   Os_ErrorBox
                mov   ecx, 1
               call   Os_ExitProcess


Failed_HashmaxTooLow:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'HSHMAX too low!',0
Failed_fstat_FileSize:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'fstat failed in _FileSize',0
Failed_fstat_FileMap:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'fstat failed in _FileMap',0
Failed_mmap_FileMap:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'mmap failed in _FileMap',0
Failed_munmap_FileUnmap:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'munmap failed in _FileUnmap',0
Failed_pthread_mutex_init_MutexCreate:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_mutex_init failed in _MutexCreate',0
Failed_pthread_mutex_destroy_MutexDestroy:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_mutex_destroy failed in _MutexDestroy',0
Failed_pthread_mutex_lock_MutexLock:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_mutex_lock failed in _MutexLock',0
Failed_pthread_mutex_unlock_MutexUnlock:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_mutex_unlock failed in _MutexUnlock',0
Failed_pthread_cond_init_EventCreate:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_cond_init failed in _EventCreate',0
Failed_pthread_cond_destroy_EventDestroy:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_cond_init failed in _EventDestroy',0
Failed_pthread_cond_signal_EventSignal:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_cond_signal failed in _EventSignal',0
Failed_pthread_cond_wait_EventWait:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'pthread_cond_wait failed in _EventWait',0
Failed_mmap:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'mmap failed',0
Failed_munmap:
                lea   rdi, [@f]
                jmp   Failed
        @@:
                db 'munmap failed',0


Os_ErrorBox:
        ; rdi points to null terminated string to write to message box 
        ; this may be called from a leaf with no stack allignment 
        ; one purpose is a hard exit on failure
                mov   rcx, rdi
               call   StringLength
               push   rdi rsi rbx 
                mov   rsi, rdi 
                mov   edi, stderr 
                mov   rdx, rax 
               call   _write
                lea   rsi, [sz_NewLine]
                mov   edi, stderr 
                mov   rdx, 1
               call   _write
                pop   rbx rsi rdi 
                ret
