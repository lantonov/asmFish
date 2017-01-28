;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; profiling
;   Its as simple as using the ProfileInc and ProfileCond macros
;   in the code. Example
; ...
; ProfileInc foo
; ProfileInc bar
; ProfileInc bar
; ProfileInc ooh
; ProfileInc ahh
;  ... some test ...
; ProfileCond e, oops
;  ... some test ...
; ProfileCond e, oops
; ProfileInc foo
;  ... some test ...
; ProfileCond nz, yup
; ....
;
; will create six symbols foo, bar, ooh, ahh, oops, yup
;   that can be viewed with 'profile' cmd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



hitprofilelist equ
condprofilelist equ

macro ProfileInc name {
  match =1, PROFILE \{
    hitprofilelist equ hitprofilelist, name
               inc   qword[hitprofiledata_#name]
  \}
}

macro ProfileCond cc, name {
  match =1, PROFILE \{
    condprofilelist equ condprofilelist, name
    local ..ConditionIsTrue
	       push   rax rcx
		lea   rcx, [condprofiledataTRUE_#name]
	       j#cc   ..ConditionIsTrue
		lea   rcx, [condprofiledataFALSE_#name]
..ConditionIsTrue:
		mov   rax, qword[rcx]
		lea   rax, [rax+1]
		mov   qword[rcx], rax
		pop   rcx rax
  \}
}



macro ifndef expr {
  local HERE
  if defined HERE | ~ defined expr
   HERE = 1
}

macro MakeProfileData {
  match =,the_list, hitprofilelist \{
    irp name, the_list \\{
      ifndef hitprofiledata_\\#name
        display 'profiling the hit '
        display \\`name
        display 10
        hitprofiledata_\\#name dq 0
      end if
    \\}
  \}
  match =,the_list, condprofilelist \{
    irp name, the_list \\{
      ifndef condprofiledataTRUE_\\#name
        display 'profiling the condition '
        display \\`name
        display 10
        condprofiledataTRUE_\\#name dq 0
        condprofiledataFALSE_\\#name dq 0
      end if
    \\}
  \}
}

macro PrintProfileData {

        ; first print the data on hits

                lea   rdi, [Output]
                mov   rax, 'profile '
              stosq
                mov   rax, 'hits:'
              stosq
                sub   rdi, 3
       PrintNewLine
               call   _WriteOut_Output

  match =,the_list, hitprofilelist \{
    irp name, the_list \\{
        \\local ..symbol, ..over, ..skip
                lea   rdi, [Output]
                mov   rax, qword[hitprofiledata_\\#name]
               test   rax, rax
                 jz   ..skip
               call   PrintUnsignedInteger
                lea   rcx, [Output+20]
                sub   rcx, rdi
                mov   eax, 1
                cmp   ecx, eax
              cmovb   ecx, eax
                mov   al, ' '
          rep stosb
               call   _WriteOut_Output
                jmp   ..over
..symbol:
                 db   \\`name
        NewLineData
..over:
                lea   rcx, [..symbol]
                lea   rdi, [..over]
               call   _WriteOut
                xor   eax, eax
                mov   qword[hitprofiledata_\\#name], rax
..skip:
    \\}
  \}

        ; then print the data on conditions

                lea   rdi, [Output]
                mov   rax, 'profile '
              stosq
                mov   rax, 'cond:'
              stosq
                sub   rdi, 3
       PrintNewLine
               call   _WriteOut_Output

  match =,the_list, condprofilelist \{
    irp name, the_list \\{
        \\local ..symbol, ..over, ..skip
                lea   rdi, [Output]
                mov   rax, qword[condprofiledataTRUE_\\#name]
                 or   rax, qword[condprofiledataFALSE_\\#name]
               test   rax, rax
                 jz   ..skip
                mov   rax, qword[condprofiledataTRUE_\\#name]
               call   PrintUnsignedInteger
                mov   ax, ', '
              stosw
                mov   rax, qword[condprofiledataFALSE_\\#name]
               call   PrintUnsignedInteger
                lea   rcx, [Output+20]
                sub   rcx, rdi
                mov   eax, 1
                cmp   ecx, eax
              cmovb   ecx, eax
                mov   al, ' '
          rep stosb
                jmp   ..over
..symbol:
                 db   \\`name
                 db   0
..over:
                lea   rcx, [..symbol]
               call   PrintString
                lea   rcx, [Output+50]
                sub   rcx, rdi
                mov   eax, 1
                cmp   ecx, eax
              cmovb   ecx, eax
                mov   al, ' '
          rep stosb
          vcvtsi2sd   xmm0, xmm0, qword[condprofiledataTRUE_\\#name]
          vcvtsi2sd   xmm1, xmm1, qword[condprofiledataFALSE_\\#name]
             vaddsd   xmm1, xmm1, xmm0
             vdivsd   xmm0, xmm0, xmm1
                mov   eax, 100
          vcvtsi2sd   xmm1, xmm1, eax
             vmulsd   xmm0, xmm0, xmm1
               call   PrintDouble
                mov   al, '%'
              stosb
       PrintNewLine
               call   _WriteOut_Output 
                xor   eax, eax
                mov   qword[condprofiledataTRUE_\\#name], rax
                mov   qword[condprofiledataFALSE_\\#name], rax
..skip:
    \\}
  \}


}




;;;;;;;;;;;;;;;;;;;;;;;;
; assert
;;;;;;;;;;;;;;;;;;;;;;;;



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


;;;;;;;;;;;;;;;;;;;;;;
; general printing
;;;;;;;;;;;;;;;;;;;;;

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
macro DisplayDouble buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
                lea   rdi, [buffer]
             vmovsd   xmm0, qword[r15+8*10]
               call   PrintDouble
		lea   rcx, [buffer]
	       call   _WriteOut
		mov   rsp, r15
		pop   r15 r11 r10 r9 r8 rdx rcx rax rsi rdi
}
macro DisplayFloat buffer {
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11 r15
		mov   r15, rsp
		and   rsp, -16
                lea   rdi, [buffer]
          vcvtss2sd   xmm0, xmm0, dword[r15+8*10]
               call   PrintDouble
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
		mov   eax, dword[r15+8*10]
		add   eax, 0x08000
		sar   eax, 16
	     movsxd   rax, eax
	       call   PrintSignedInteger
		mov   al, ','
	      stosb
	      movsx   rax, word[r15+8*10]
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

