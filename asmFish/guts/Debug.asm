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
		db 13,10,0
..over:
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}

macro DebugDisplay m {
; lets not clobber any registers here
local ..message, ..over
 match =1, DEBUG \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		jmp   ..over
   ..message: db m
	      db 10,0
   ..over:
		lea   rdi,[..message]
	       call   _ErrorBox
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}

macro Display m {
; lets not clobber any registers here
local ..message, ..over
	       push   rdi rax rcx rdx r8 r9 r10 r11
		jmp   ..over
   ..message: db m
	      db 10,0
   ..over:
		lea   rdi,[..message]
	       call   _ErrorBox
		pop   r11 r10 r9 r8 rdx rcx rax rdi
}




macro Display_String m {
; lets not clobber any registers here
local ..message, ..over
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
	    db m
	    db 0
   ..over:
		lea   rdi, [Output]
	       call   PrintString
		lea   rcx, [Output]
		lea  rcx, [Output]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
}

macro Display_Int x {
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [Output]
	movsxd rax, dword[rsp+8*9]
	call PrintSignedInteger
	lea  rcx, [Output]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
}

macro Display_UInt x {
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [Output]
	movsxd rax, dword[rsp+8*9]
	call PrintUnsignedInteger
	lea  rcx, [Output]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
}

macro Display_Hex x {
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [Output]
	mov rcx, qword[rsp+8*9]
	call PrintHex
	lea  rcx, [Output]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
}

macro Display_Move x {
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [Output]
	mov ecx, dword[rsp+8*9]
	xor edx, edx
	call PrintUciMove
	lea  rcx, [Output]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
}


macro Display_NewLine {
; lets not clobber any registers here
local ..message, ..over
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
  match =1, OS_IS_WINDOWS \{
	    db 13
  \}
	    db 10
	    db 0
   ..over:
		lea   rdi, [Output]
	       call   PrintString
		lea   rcx, [Output]
		lea  rcx, [Output]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
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




macro GD_GetTime {
match =1, VERBOSE \{
call _GetTime
mov qword[VerboseTime1+8*0], rdx
mov qword[VerboseTime1+8*1], rax
\}
}


macro GD_ResponseTime m {
match =1, VERBOSE \{
lea rdi, [Output]
mov rax, 'response'
stosq
mov rax, ' time:  '
stosq
call _GetTime
sub rdx, qword[VerboseTime1+8*0]
sbb rax, qword[VerboseTime1+8*1]
mov r8, rdx
mov ecx, 1000
mul rcx
xchg rax, r8
mul rcx
lea rax, [r8+rdx]
call PrintUnsignedInteger
mov eax, ' us' + (10 shl 24)
stosd
call _WriteOut_Output
\}
}


macro GD_String m {
; lets not clobber any registers here
local ..message, ..over
 match =1, VERBOSE \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
	    db m
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}

macro GD_Int x {
 match =1, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	movsxd rax, dword[rsp+8*9]
	call PrintSignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}


macro GD_Hex x {
 match =1, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov rcx, qword[rsp+8*9]
	call PrintHex
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}



macro GD_NewLine {
; lets not clobber any registers here
local ..message, ..over
 match =1, VERBOSE \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
  match =1, OS_IS_WINDOWS \\{
	    db 13
  \\}
	    db 10
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea   rcx, [VerboseOutput]
	       call   _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}





macro SD_NewLine {
; lets not clobber any registers here
local ..message, ..over
 match =2, VERBOSE \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
  match =1, OS_IS_WINDOWS \\{
	    db 13
  \\}
	    db 10
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}

macro SD_String m {
; lets not clobber any registers here
local ..message, ..over
 match =2, VERBOSE \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
	    db m
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}

macro SD_Move x {
 match =2, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov ecx, dword[rsp+8*9]
	xor edx, edx
	call PrintUciMove
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}


macro SD_Hex x {
 match =2, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov rcx, qword[rsp+8*9]
	call PrintHex
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}

macro SD_Int x {
 match =2, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	movsxd rax, dword[rsp+8*9]
	call PrintSignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}


macro SD_UInt64 x {
 match =2, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov rax, qword[rsp+8*9]
	call PrintUnsignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}



macro SD_Bool8 x {
 match =2, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	movzx eax, byte[rsp+8*9]
	neg eax
	sbb eax, eax
	and eax, 1
	add eax, '0'
	stosb
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}





macro ED_String m {
; lets not clobber any registers here
local ..message, ..over
 match =4, VERBOSE \{
	       push   rdi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
	    db m
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rdi
 \}
}



macro ED_Int x {
 match =4, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	movsxd rax, dword[rsp+8*9]
	call PrintSignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
 \}
}



macro ED_Score x {
 match =4, VERBOSE \{
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov  eax, dword[rsp+8*9]
	add  eax, 0x08000
	sar  eax, 16
	movsxd rax, eax
	call PrintSignedInteger
	mov  al, ','
	stosb
	movsx  rax, word[rsp+8*9]
	call PrintSignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add rsp, 8
 \}
}



macro ED_NewLine {
local ..message, ..over
 match =4, VERBOSE \{
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
  match =1, OS_IS_WINDOWS \\{
	    db 13
  \\}
	    db 10
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rsi rdi
 \}
}






macro ND_String m {
; lets not clobber any registers here
local ..message, ..over
if VERBOSE>1
	       push   rdi rsi rax rcx rdx r8 r9 r10 r11
		lea   rcx, [..message]
		jmp   ..over
   ..message:
	    db m
	    db 0
   ..over:
		lea   rdi, [VerboseOutput]
	       call   PrintString
		lea   rcx, [VerboseOutput]
		lea  rcx, [VerboseOutput]
	       call _WriteOut
		pop   r11 r10 r9 r8 rdx rcx rax rsi rdi
end if
}


macro ND_Int x {
if VERBOSE>1
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	movsxd rax, dword[rsp+8*9]
	call PrintSignedInteger
	PrintNewLine
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
end if
}

macro ND_UInt64 x {
if VERBOSE>1
	push  x
	push  rdi rsi rax rcx rdx r8 r9 r10 r11
	lea  rdi, [VerboseOutput]
	mov rax, qword[rsp+8*9]
	call PrintUnsignedInteger
	lea  rcx, [VerboseOutput]
	call _WriteOut
	pop r11 r10 r9 r8 rdx rcx rax rsi rdi
	add  rsp, 8
end if
}
