
Limits_Init:
	; in: rcx address of of LimitsType struct
	       push   rbx rsi rdi
		mov   rbx, rcx
	       call   Os_GetTime
		mov   rsi, rax
		mov   rdi, rbx
		mov   ecx, sizeof.Limits
		xor   eax, eax
	  rep stosb
		mov   qword[rbx+Limits.startTime], rsi
		mov   byte[rbx+Limits.useTimeMgmt], -1
		pop   rdi rsi rbx
		ret

Limits_Set:
        ; in: rcx address of of LimitsType struct
        ;      set useTimeMgmt member
              movzx   eax, byte[rcx+Limits.infinite]
                 or   eax, dword[rcx+Limits.mate]
                 or   eax, dword[rcx+Limits.movetime]
                 or   eax, dword[rcx+Limits.depth]
                 or   rax, qword[rcx+Limits.nodes]
               setz   al
                mov   byte[rcx+Limits.useTimeMgmt], al
                ret


Limits_Copy:
	; in: rcx address of destination
	;     rdx address of source
	       push   rsi rdi
		mov   rsi, rdx
		mov   rdi, rcx
		mov   ecx, sizeof.Limits
	  rep movsb
		pop   rdi rsi
		ret
