; Thanks to locklessinc.com and HaHaAnonymous for most of these functions



;;;;;;;;;
; mutex ;
;;;;;;;;;


_MutexCreate:
	    ; rcx: address of Mutex
    	       int3
_MutexDestroy:
    	; rcx: address of Mutex
               int3
_MutexLock:
    	; rcx: address of Mutex
               int3
_MutexUnlock:
    	; rcx: address of Mutex
               int3


;;;;;;;;;
; event ;
;;;;;;;;;

_EventCreate:
    	; rcx: address of ConditionalVariable
               int3
_EventDestroy:
    	; rcx: address of ConditionalVariable
               int3
_EventSignal:
    	; rcx: address of ConditionalVariable
               int3
_EventWait:
    	; rcx: address of ConditionalVariable
    	; rdx: address of Mutex
               int3



;;;;;;;;
; file ;
;;;;;;;;

_FileWrite:
    	; in: rcx handle from CreateFile (win), fd (linux)
    	;     rdx buffer
    	;     r8d size (32bits)
	    ; out: eax !=0 success
    	       push   rsi rdi rbx
                mov   rdi, rcx	; fd
                mov   rsi, rdx	; buffer
                mov   edx, r8d	; count
                mov   eax, sys_write
            syscall
                sar   rax, 63
                add   eax, 1
                pop   rbx rdi rsi
                ret
                

_FileRead:
	    ; in: rcx handle from CreateFile (win), fd (linux)
    	;     rdx buffer
    	;     r8d size (32bits)
    	; out: eax !=0 success
               push   rsi rdi rbx
                mov   rdi, rcx	; fd
                mov   rsi, rdx	; buffer
                mov   edx, r8d	; count
                mov   eax, sys_read
            syscall
                sar   rax, 63
                add   eax, 1
                pop   rbx rdi rsi
                ret


_FileSize:
        ; in: rcx handle from CreateFile (win), fd (linux)
        ; out:  rax size
               push   rbx rsi rdi
                sub   rsp, 20*8
                mov   rdi, rcx
                mov   rsi, rsp 
                mov   eax, sys_fstat 
            syscall
               test   eax, eax
                jnz   Failed_sys_fstat
                mov   rax, qword[rsp+0x30] ; file size - probably wrong
                add   rsp, 20*8
                pop   rdi rsi rbx
                ret


_FileOpenWrite:
        ; in: rcx path string
        ; out: rax handle from CreateFile (win), fd (linux)
        ;      rax=-1 on error
               push   rbx rsi rdi
                mov   rdi, rcx
                mov   esi, O_WRONLY or O_CREAT
                mov   eax, sys_open
            syscall
               test   eax, eax
                jns   @f
                 or   rax, -1
        @@:	    pop   rdi rsi rbx
                ret


_FileOpenRead:
        ; in: rcx path string  
        ; out: rax handle from CreateFile (win), fd (linux)
        ;      rax=-1 on error
               push   rbx rsi rdi
                mov   rdi, rcx
                mov   esi, O_RDONLY
                mov   eax, sys_open
            syscall
               test   eax, eax
                jns   @f
                 or   rax, -1
        @@:     pop   rdi rsi rbx
                ret

_FileClose:
        ; in: rcx handle from CreateFile (win), fd (linux) 
               push   rbx rsi rdi 
                mov   rdi, rcx 
                mov   eax, sys_close 
            syscall 
                pop   rdi rsi rbx 
                ret

_FileMap:
        ; in: rcx handle (win), fd (linux) 
        ; out: rax base address 
        ;      rdx handle from CreateFileMapping (win), size (linux) 
        ; get file size 
                push   rbp rbx rsi rdi r15
                sub   rsp, 20*8
                mov   rbp, rcx
                mov   rdi, rcx
                mov   rsi, rsp 
                mov   eax, sys_fstat 
            syscall
               test   eax, eax
                jnz   Failed_sys_fstat
                mov   rbx, qword[rsp+0x30] ; file size - probably wrong
        ; map file
                xor   edi, edi		; addr
                mov   rsi, rbx		; length
                mov   edx, PROT_READ	; protection flags
                mov   ecx, MAP_PRIVATE	; mapping flags
                mov   r8, rbp		; fd
                xor   r9d, r9d		; offset
                mov   eax, sys_mmap
            syscall
               test   rax, rax
                 js   Failed_sys_mmap
        ; return size in rdx, base address in rax
                mov   rdx, rbx
                add   rsp, 20*8
                pop   r15 rdi rsi rbx rbp
                ret

_FileUnmap:
        ; in: rcx base address 
        ;     rdx handle from CreateFileMapping (win), size (linux) 
               push   rbx rsi rdi
               test   rcx, rcx
                 jz   @f
                mov   rdi, rcx	      ; addr 
                mov   rsi, rdx	      ; length 
                mov   eax, sys_munmap 
            syscall
               test   eax, eax
                jnz   Failed_sys_munmap_FileUnmap
        @@:     pop   rdi rsi rbx
                ret




;;;;;;;;;;
; thread ;
;;;;;;;;;;

_ThreadCreate:
        ; in: rcx start address
        ;     rdx parameter to pass
        ;     r8  address of NumaNode struct
        ;     r9  address of ThreadHandle Struct
                int3

_ThreadJoin:
        ; rcx:  address of ThreadHandle struct
                int3

_ExitProcess:
        ; rcx is exit code
                mov   edi, ecx
                mov   eax, sys_exit
            syscall
               int3

_ExitThread:
        ; rcx is exit code
        ; must not call _ExitThread on linux
        ;  thread should just return
               int3


;;;;;;;;;;
; timing ;
;;;;;;;;;;




              align   16
_GetTime:
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
                shr   rax, rdx, 32
                add   rax, r8
                mov   rcx, 18446744073709;551616   2^64/10^6
                mul   rcx
               imul   r9, 1000
                add   rdx, r9
               xchg   rax, rdx

Display 0, "comm page get time %0.%2%n"

                add   rsp, 8*2
                pop   rdi rsi rbx
                ret

.Failed:
                mov   rdi, rsp
                xor   esi, esi
                xor   edx, edx                  ; those **** changed the fxn
                mov   eax, sys_gettimeofday
            syscall
Display 0, "sys_gettimeofday rax %0  rdx %2%n"
               test   rax, rax
                 jz   @f                        ; those **** might return the result in rax:rdx
                mov   qword[rsp+8*0], rax
                mov   dword[rsp+8*1], edx
        @@:     mov   eax, dword[rsp+8*1]	; tv_usec
                mov   rcx, 18446744073709551;616   2^64/10^3
                mul   rcx
               imul   rcx, qword[rsp+8*0], 1000
                add   rdx, rcx
               xchg   rax, rdx

Display 0, "     sys  get time %0.%2%n"


                add   rsp, 8*2
                pop   rdi rsi rbx
                ret

_GetTime_SYS:
               push   rbx rsi rdi
                sub   rsp, 8*2
                jmp   _GetTime.Failed

_InitializeTimer:
                ret

_Sleep:
        ; ecx  ms
               int3


;;;;;;;;;;
; memory ;
;;;;;;;;;;


_VirtualAllocNuma:
        ; rcx is size
        ; edx is numa node

_VirtualAlloc:
        ; rcx is size
               push   rsi rdi rbx
                xor   edi, edi
                mov   rsi, rcx
                mov   edx, PROT_READ or PROT_WRITE
                mov   r10d, MAP_PRIVATE or MAP_ANONYMOUS
                 or   r8, -1
                xor   r9, r9
                mov   eax, sys_mmap
            syscall
;               test   rax, rax
;                 js   Failed_sys_mmap
                pop   rbx rdi rsi
                ret


_VirtualFree:
        ; rcx is address
        ; rdx is size
               push   rsi rdi rbx
               test   rcx, rcx
                 jz   .null
                mov   rdi, rcx
                mov   rsi, rdx
                mov   eax, sys_munmap
            syscall
;               test   eax, eax
;                jnz   Failed_sys_munmap_VirtualFree
.null:
                pop   rbx rdi rsi
                ret



_VirtualAlloc_LargePages:
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

               push   rbx rsi rdi r14 r15
                mov   r14, rcx
                xor   edi, edi
                mov   rsi, rcx
                mov   edx, PROT_READ or PROT_WRITE
                mov   ecx, MAP_PRIVATE or MAP_ANONYMOUS
                mov   r8, VM_FLAGS_SUPERPAGE_SIZE_2MB
                xor   r9, r9
                mov   eax, sys_mmap
            syscall
                 js   .failed

                mov   qword[LargePageMinSize], 2 shl 20
.done:
                pop   r15 r14 rdi rsi rbx
                ret
.failed:
                xor   eax, eax
                xor   edx, edx
                mov   qword[LargePageMinSize], -1
                jmp   .done






;;;;;;;;;;;;;;;;
; input/output ;
;;;;;;;;;;;;;;;;

_ParseCommandLine:
               push   rbp rbx rsi rdi r13 r14 r15

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
               call   _VirtualAlloc
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
                pop   r15 r14 r13 rdi rsi rbx rbp
                ret

_SetStdHandles:
        ; no arguments
        ; these are always 0,1,2
                ret


_WriteOut_Output:
                lea   rcx, [Output]
_WriteOut:
        ; in: rcx  address of string start
        ;     rdi  address of string end
               push   rsi rdi rbx
                mov   rsi, rcx
                mov   rdx, rdi
                sub   rdx, rcx
                mov   edi, 1
.go:
                mov   eax, sys_write
            syscall
               test   rax, rax
                 js   Failed_sys_write
                pop   rbx rdi rsi
                ret


_WriteError:
        ; in: rcx  address of string start
        ;     rdi  address of string end
               push   rsi rdi rbx
                mov   rsi, rcx
                mov   rdx, rdi
                sub   rdx, rcx
                mov   edi, 2
                jmp   _WriteOut.go



_ReadStdIn:
        ; in: rcx address to write
        ;     edx max size
        ; out: rax > 0 number of bytes written
        ;      rax = 0 nothing written; end of file
        ;      rax < 0 error

               push   rbx rsi rdi
                mov   edi, stdin
                mov   rsi, rcx
                mov   eax, sys_read 
            syscall
                pop   rdi rsi rbx
                ret


;;;;;;;;;;;;;;;;;;
; priority class ;
;;;;;;;;;;;;;;;;;;

_SetPriority_Realtime:
               int3

_SetPriority_Normal:
               int3

_SetPriority_Low:
               int3

_SetPriority_Idle:
               int3




;;;;;;;;;;;;;;;;;;;;;;;
; system capabilities ;
;;;;;;;;;;;;;;;;;;;;;;;


_SetThreadPoolInfo:
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





_DisplayThreadPoolInfo:
                ret




_CheckCPU:
               push   rbp rbx r15

match =1, CPU_HAS_POPCNT {
                lea   r15, [szCPUError.POPCNT]
                mov   eax, 1
                xor   ecx, ecx
              cpuid
                and   ecx, (1 shl 23)
                cmp   ecx, (1 shl 23)
                jne   .Failed
}

match =1, CPU_HAS_AVX1 {
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
}

match =1, CPU_HAS_AVX2 {
                lea   r15, [szCPUError.AVX2]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 5)
                cmp   ebx, (1 shl 5)
                jne   .Failed
}

match =1, CPU_HAS_BMI1 {
                lea   r15, [szCPUError.BMI1]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 3)
                cmp   ebx, (1 shl 3)
                jne   .Failed
}

match =1, CPU_HAS_BMI2 {
                lea   r15, [szCPUError.BMI2]
                mov   eax, 7
                xor   ecx, ecx
              cpuid
                and   ebx, (1 shl 8)
                cmp   ebx, (1 shl 8)
                jne   .Failed
}

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
int3
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
               call   _ErrorBox
                mov   ecx, 1
               call   _ExitProcess

int3

Failed_HashmaxTooLow:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'HSHMAX too low!',0
Failed_sys_write:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_write failed',0
Failed_sys_mmap:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_mmap failed',0
Failed_sys_fstat:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_fstat failed',0



Failed_sys_munmap_VirtualFree:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_munmap in _VirtualFree failed',0
;Failed_sys_munmap_ThreadJoin:
;               lea   rdi, [@f]
;               jmp   Failed
;               @@: db 'sys_munmap in _ThreadJoin failed',0
Failed_sys_munmap_FileUnmap:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_munmap in _FileUnmap failed',0


Failed_sys_munmap:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_munmap failed',0
Failed_stub_clone:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'stub_clone failed',0

Failed_sys_futex:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_futex failed',0
Failed_sys_futex_MutexUnlock:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_futex in _MutexUnlock failed',0
Failed_sys_futex_EventSignal:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_futex in _EventSignal failed',0
;Failed_sys_futex_EventWait:
;                lea   rdi, [@f]
;                jmp   Failed
;                @@: db 'sys_futex in _EventWait failed',0
Failed_sys_futex_ThreadCreate:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_futex in _ThreadCreate failed',0
;Failed_sys_futex_ThreadJoin:
;                lea   rdi, [@f]
;                jmp   Failed
;                @@: db 'sys_futex in _ThreadJoin failed',0
;Failed_sys_futex_MutexLock:
;                lea   rdi, [@f]
;                jmp   Failed
;                @@: db 'sys_futex in _MutexLock failed',0


Failed_sys_sched_setaffinity:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_sched_setaffinity failed',0
Failed_sys_mbind:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'sys_mbind failed',0
Failed_EventWait:
                lea   rdi, [@f]
                jmp   Failed
        @@: db '_EventWait failed',0
Failed_MatchingCore:
                lea   rdi, [@f]
                jmp   Failed
        @@: db 'matching core to node failed',0





_ErrorBox:
        ; rdi points to null terminated string to write to message box 
        ; this may be called from a leaf with no stack allignment 
        ; one purpose is a hard exit on failure
                mov   rcx, rdi
               call   StringLength
               push   rdi rsi rbx 
                mov   rsi, rdi 
                mov   edi, stderr 
                mov   rdx, rax 
                mov   eax, sys_write 
            syscall
                lea   rsi, [sz_NewLine]
                mov   edi, stderr 
                mov   rdx, 1
                mov   eax, sys_write 
            syscall
                pop   rbx rsi rdi 
                ret
