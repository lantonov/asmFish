macro ProfileInc fxn {
 match =1, PROFILE \{
	   lock inc   qword[profile.#fxn]
 \}
}


macro ProfileJmp cc, index {
local ..TakingJump
; do a profile on the conditional jmp j#cc
;  increment  qword[profile.cjmpcounts+16*index+0] if the jump is not taken
;  incrememnt qword[profile.cjmpcounts+16*index+8] if the jump is taken
; use like this:
;    call foo
;    test eax, eax
;    ProfileJmp nz, 0
;    jnz eaxNotZero
;     ...
;
; The counts can be read after the "index:" label in the profile command

 match =1, PROFILE \{
	       push   rax rcx
		lea   rcx, [profile.cjmpcounts+16*(index)+8]
	       j#cc   ..TakingJump
		lea   rcx, [profile.cjmpcounts+16*(index)+0]
..TakingJump:
		mov   rax, qword[rcx]
		lea   rax, [rax+1]
		mov   qword[rcx], rax
		pop   rcx rax

 \}
}


macro Assert cc,a,b,m {
; if the assertion succeeds, only the eflags are clobbered
local ..skip, ..errorbox, ..message
 match =1, DEBUG \{
		cmp   a, b
	       j#cc   ..skip
		jmp   ..errorbox

   ..message: db m
	      db 0
   ..errorbox:
		lea   rdi,[..message]
	       call   _ErrorBox
		xor   ecx, ecx
		jmp   _ExitProcess
   ..skip:
 \}
}

macro AssertStackAligned m {
local ..skip, ..errorbox, ..message
 match =1, DEBUG \{
	       test   rsp, 15
		 jz   ..skip
		jmp   ..errorbox

   ..message: db 'stack pointer not divisible by 16 in '
	      db m
	      db 0
   ..errorbox:
		lea   rdi,[..message]
	       call   _ErrorBox
		xor   ecx, ecx
		jmp   _ExitProcess
   ..skip:
 \}
}


macro DebugStackUse m {
local ..message, ..over
 match =1, DEBUG \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rdi,[DebugOutput]
		mov   rax, qword[rbp-Thread.rootPos+Thread.stackBase]
		sub   rax, rsp
		cmp   rax, qword[rbp-Thread.rootPos+Thread.stackRecord]
		jbe   ..over
		mov   qword[rbp-Thread.rootPos+Thread.stackRecord], rax
	       call   PrintUnsignedInteger
		lea   rcx, [..message]
	       call   PrintString
		lea   rcx, [DebugOutput]
	       call   _WriteOut
		jmp   ..over
..message:
		db  ' new stack use record in '
		db m
        NewLineData
		db 0
..over:
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}


; For these macros
;  the display function fxn is called on args
;  if the VERBOSE setting is in the list <...>.

; currently we have
; AD which always activated
; GD which is activated when VERBOSE=1
; SD which is activated when VERBOSE=2

macro AD fxn, [arg] {
  forward
    local ..message, ..over
        if arg eqtype 'somestring'      ; make space for immediate strings
               push   rax
		lea   rax, [..message]
		jmp   ..over
           ..message:
                 db   arg
                 db   0
           ..over:
               xchg   rax, qword[rsp]
        else if arg eq                  ; empty arg just push something
               push   rax
        else
               push   arg
        end if
  common
        Display#fxn   Output
  reverse
                add   rsp, 8            ; pop whatever was pushed
}

macro GD fxn, [arg] {
 match =1, VERBOSE \{
  forward
    local ..message, ..over
        if arg eqtype 'somestring'
               push   rax
		lea   rax, [..message]
		jmp   ..over
           ..message:
                 db   arg
                 db   0
           ..over:
               xchg   rax, qword[rsp]
        else if arg eq
               push   rax
        else
               push   arg
        end if
  common
        Display#fxn   VerboseOutput
  reverse
                add   rsp, 8
 \}
}

macro SD fxn, [arg] {
 match =2, VERBOSE \{
  forward
    local ..message, ..over
        if arg eqtype 'somestring'
               push   rax
		lea   rax, [..message]
		jmp   ..over
           ..message:
                 db   arg
                 db   0
           ..over:
               xchg   rax, qword[rsp]
        else if arg eq
               push   rax
        else
               push   arg
        end if
  common
        Display#fxn   VerboseOutput
  reverse
                add   rsp, 8
 \}
}



; These are supposed to display stuff without clobbering registers
; the arguments are supposed to be on the stack
; macro is best used from the macros above
; the macro argument 'buffer' is what we use to print the string

macro DisplayString buffer {
local ..nextchar
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		mov   rcx, qword[r15+8*10]
                lea   rdi, [rcx-1]
..nextchar:
                add   rdi, 1
                cmp   byte[rdi], ' '
                jae   ..nextchar
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayNewLine buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
       PrintNewLine
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayInt32 buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
	     movsxd   rax, dword[r15+8*10]
	       call   PrintSignedInteger
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayUInt32 buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   eax, dword[r15+8*10]
	       call   PrintUnsignedInteger
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayInt64 buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   rax, qword[r15+8*10]
	       call   PrintSignedInteger
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayUInt64 buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   rax, qword[r15+8*10]
	       call   PrintUnsignedInteger
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayDouble buffer {            ; this is not robust
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
                lea   rdi, [buffer]
local digits, power
        digits = 2
        power = 1
        repeat digits
          power = 10*power
        end repeat
                mov   rax, power
          vcvtsi2sd   xmm0, xmm0, rax
             vmulsd   xmm0, xmm0, qword[r15+8*10]
         vcvttsd2si   rax, xmm0
                cqo
                mov   ecx, power
               idiv   rcx
                mov   rsi, rdx
	       call   PrintSignedInteger
                mov   al, '.'
              stosb
                mov   rax, rsi
                cqo
                xor   rax, rdx
                sub   rax, rdx
        repeat digits
           power = power/10
                xor   edx, edx
                mov   ecx, power
                div   rcx
                add   eax, '0'
              stosb
                mov   rax, rdx
        end repeat
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayFloat buffer {            ; this is not robust
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
                lea   rdi, [buffer]
local digits, power
        digits = 2
        power = 1
        repeat digits
          power = 10*power
        end repeat
                mov   rax, power
          vcvtsi2sd   xmm0, xmm0, rax
          vcvtss2sd   xmm1, xmm1, dword[r15+8*10]
             vmulsd   xmm0, xmm0, xmm1
         vcvttsd2si   rax, xmm0
                cqo
                mov   ecx, power
               idiv   rcx
                mov   rsi, rdx
	       call   PrintSignedInteger
                mov   al, '.'
              stosb
                mov   rax, rsi
                cqo
                xor   rax, rdx
                sub   rax, rdx
        repeat digits
           power = power/10
                xor   edx, edx
                mov   ecx, power
                div   rcx
                add   eax, '0'
              stosb
                mov   rax, rdx
        end repeat
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayHex buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   rcx, qword[r15+8*10]
	       call   PrintHex
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayMove buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   ecx, dword[r15+8*10]
		xor   edx, edx			; assume chess960=false
	       call   PrintUciMove
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayScore buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   eax, dword[rsp+8*10]
		add   eax, 0x08000
		sar   eax, 16
	     movsxd   rax, eax
	       call   PrintSignedInteger
		mov   al, ','
	      stosb
	      movsx   rax, word[rsp+8*10]
	       call   PrintSignedInteger
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayBool buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		cmp   byte[r15+8*10], 0
	      setnz   al
		add   al, '0'
	      stosb
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayGetTime buffer { ; haha, this doesn't actually display anything
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
	       call   _GetTime
		mov   qword[VerboseTime+8*0], rdx
		mov   qword[VerboseTime+8*1], rax
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayResponseTime buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
		lea   rdi, [buffer]
		mov   rax, 'response'
	      stosq
		mov   rax, ' time:  '
	      stosq
	       call   _GetTime
		sub   rdx, qword[VerboseTime+8*0]
		sbb   rax, qword[VerboseTime+8*1]
		mov   r8, rdx
		mov   ecx, 1000
		mul   rcx
	       xchg   rax, r8
		mul   rcx
		lea   rax, [r8+rdx]
	       call   PrintUnsignedInteger
		mov   eax, ' us'
	      stosd
		sub   rdi, 1
       PrintNewLine
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}

