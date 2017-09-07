         calign   16
CheckTime:
    ; we must:
    ;   set signals stop if the search is to be aborted (soon)
    ;   and determine a good resetCnt to send to all threads
    ;     lower values of resetCnt lead to to better resolution but increased polling
    ;     conversely for higher values of resetCnt
           push   rbx rsi rdi
	; if MAX_RESETCNT is exactly calls to search per second
	; then this value of resetCnt should put us back here in 1 second
	; this is obviously too much when using time mgmt
	; so .Reset4Time reduces this
            mov   esi, MAX_RESETCNT		; fall through count
    ; Of course, setting MAX_RESETCNT = number of calls to search per second
    ; is impossible to measure and also dangerous. So really we have
    ;   MAX_RESETCNT ~= (number of calls to search per second) * X
    ; where X is a number between 0 and 1.
    ; We then expect to be back here in X seconds.
            xor   eax, eax
            cmp   al, byte[limits.ponder]
            jne   .Return
            cmp   al, byte[limits.useTimeMgmt]
             je   .DontUseTimeMgmt
            mov   rdi, qword[time.maximumTime]
.Reset4Time:
    ; rdi is target time
           call   Os_GetTime
            sub   rax, qword[time.startTime]
            add   rax, 1
    ; rax is elapsed time
            sub   rdi, rax
             js   .Stop
    ; If rdi ms are remaining, attemp to put us back here in X*rdi/2 ms.
    ; The values of rdi at this point are in geometric progression.
    ; On tested machine, this ends a 'go movetime 10000' in 10000 ms
    ; with approx 130 calls to CheckTime.
Display 1, 'ms remaining: %I7%n'
            mov   eax, MAX_RESETCNT/2000
            mul   rdi
            add   rax, MIN_RESETCNT ; resetCnt should be at least 50
            adc   rdx, 0            ; if mul overflows, there is lots of
            jnz   .Return           ; time and use fall through count
            cmp   rsi, rax
          cmova   esi, eax
.Return:
Display 1, ' resetCnt: %i6%n'
	; set resetCnt for all threads to esi
            mov   ecx, dword[threadPool.threadCnt]
.ResetNextThread:
            sub   ecx, 1
            mov   rax, qword[threadPool.threadTable+8*rcx]
            mov   dword[rax+Thread.resetCnt], esi
            jnz   .ResetNextThread
            pop   rdi rsi rbx
            ret
.Stop:
            mov   byte[signals.stop], -1
            pop   rdi rsi rbx
            ret
.DontUseTimeMgmt:
            mov   edi, dword[limits.movetime]
           test   edi, edi
            jnz   .Reset4Time
            mov   rdi, qword[limits.nodes]
           test   rdi, rdi
             jz   .Return           ; use fall through count
           call   ThreadPool_NodesSearched_TbHits
            add   rax, 1
.Reset4Nodes:
    ; rdi is target nodes
    ; rax is elapsed nodes
            sub   rdi, rax
             jb   .Stop
    ; if rdi nodes are remaining, attemp to put us back here rdi/3 nodes later
    ; the division is by 6 because half of the nodes are from qsearch
    ; the values of rdi at this point are in geometric progression
    ; this ends 'go nodes 1000000' with 1000053 nodes
    ; with 22 calls to CheckTime
Display 1, 'nodes remaining: %I7%n'
            mov   rax, (1 shl 63)/3
            mul   rdi               ; rdx = rdi/6
            add   rdx, MIN_RESETCNT
            cmp   rsi, rdx
          cmova   esi, edx
            jmp   .Return

