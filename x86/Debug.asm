;;;;;;;;;;;;;;;;;;;;;;;;
; assert
;;;;;;;;;;;;;;;;;;;;;;;;

macro Assert cc, a, b, mes
  if DEBUG = 1
    local skip, errorbox, message
            cmp  a, b
           j#cc  skip
            jmp  errorbox
message:
            db mes
            db 0
errorbox:
            lea  rdi, [message]
           call  Os_ErrorBox
            mov  ecx, 1
            jmp  Os_ExitProcess
skip:
  end if
end macro



;;;;;;;;;;;;;;;;;;;;;;
; general printing
;;;;;;;;;;;;;;;;;;;;;
macro PushAll
                sub   rsp, 16*16
           _vmovups   dqword[rsp+16*0], xmm0
           _vmovups   dqword[rsp+16*1], xmm1
           _vmovups   dqword[rsp+16*2], xmm2
           _vmovups   dqword[rsp+16*3], xmm3
           _vmovups   dqword[rsp+16*4], xmm4
           _vmovups   dqword[rsp+16*5], xmm5
           _vmovups   dqword[rsp+16*6], xmm6
           _vmovups   dqword[rsp+16*7], xmm7
           _vmovups   dqword[rsp+16*8], xmm8
           _vmovups   dqword[rsp+16*9], xmm9
           _vmovups   dqword[rsp+16*10], xmm10
           _vmovups   dqword[rsp+16*11], xmm11
           _vmovups   dqword[rsp+16*12], xmm12
           _vmovups   dqword[rsp+16*13], xmm13
           _vmovups   dqword[rsp+16*14], xmm14
           _vmovups   dqword[rsp+16*15], xmm15
                sub   rsp, 8*16
                mov   qword[rsp+8*0], rax
                mov   qword[rsp+8*1], rcx
                mov   qword[rsp+8*2], rdx
                mov   qword[rsp+8*3], rbx
                mov   qword[rsp+8*4], rsp
                add   qword[rsp+8*4], 8*16+16*16
                mov   qword[rsp+8*5], rbp
                mov   qword[rsp+8*6], rsi
                mov   qword[rsp+8*7], rdi
                mov   qword[rsp+8*8], r8
                mov   qword[rsp+8*9], r9
                mov   qword[rsp+8*10], r10
                mov   qword[rsp+8*11], r11
                mov   qword[rsp+8*12], r12
                mov   qword[rsp+8*13], r13
                mov   qword[rsp+8*14], r14
                mov   qword[rsp+8*15], r15
end macro

macro PopAll
                mov   rax, qword[rsp+8*0]
                mov   rcx, qword[rsp+8*1]
                mov   rdx, qword[rsp+8*2]
                mov   rbx, qword[rsp+8*3]
                mov   rbp, qword[rsp+8*5]
                mov   rsi, qword[rsp+8*6]
                mov   rdi, qword[rsp+8*7]
                mov   r8, qword[rsp+8*8]
                mov   r9, qword[rsp+8*9]
                mov   r10, qword[rsp+8*10]
                mov   r11, qword[rsp+8*11]
                mov   r12, qword[rsp+8*12]
                mov   r13, qword[rsp+8*13]
                mov   r14, qword[rsp+8*14]
                mov   r15, qword[rsp+8*15]
                add   rsp, 8*16
           _vmovups   xmm0, dqword[rsp+16*0]
           _vmovups   xmm1, dqword[rsp+16*1]
           _vmovups   xmm2, dqword[rsp+16*2]
           _vmovups   xmm3, dqword[rsp+16*3]
           _vmovups   xmm4, dqword[rsp+16*4]
           _vmovups   xmm5, dqword[rsp+16*5]
           _vmovups   xmm6, dqword[rsp+16*6]
           _vmovups   xmm7, dqword[rsp+16*7]
           _vmovups   xmm8, dqword[rsp+16*8]
           _vmovups   xmm9, dqword[rsp+16*9]
           _vmovups   xmm10, dqword[rsp+16*10]
           _vmovups   xmm11, dqword[rsp+16*11]
           _vmovups   xmm12, dqword[rsp+16*12]
           _vmovups   xmm13, dqword[rsp+16*13]
           _vmovups   xmm14, dqword[rsp+16*14]
           _vmovups   xmm15, dqword[rsp+16*15]
                add   rsp, 16*16
end macro


macro Display vLevel, Mes
  local message, over
  if vLevel = VERBOSE
            PushAll
                lea  rcx, [message]
                jmp  over
    message:
        db Mes
	db 0
    over:
                lea  rdi, [Output]
                mov  rdx, rsp
                lea  r8, [rsp + 16*8]
               call  PrintFancy
               call  Os_WriteOut_Output
             PopAll
  end if
end macro
