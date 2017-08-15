;;;;;;;;;;;;;;;;;;;;;;;;
; assert
;;;;;;;;;;;;;;;;;;;;;;;;

macro Assert cc, a, b, mes

end macro



;;;;;;;;;;;;;;;;;;;;;;
; general printing
;;;;;;;;;;;;;;;;;;;;;
macro PushAll
                sub   rsp, 16*16
            vmovups   dqword[rsp+16*0], xmm0
            vmovups   dqword[rsp+16*1], xmm1
            vmovups   dqword[rsp+16*2], xmm2
            vmovups   dqword[rsp+16*3], xmm3
            vmovups   dqword[rsp+16*4], xmm4
            vmovups   dqword[rsp+16*5], xmm5
            vmovups   dqword[rsp+16*6], xmm6
            vmovups   dqword[rsp+16*7], xmm7
            vmovups   dqword[rsp+16*8], xmm8
            vmovups   dqword[rsp+16*9], xmm9
            vmovups   dqword[rsp+16*10], xmm10
            vmovups   dqword[rsp+16*11], xmm11
            vmovups   dqword[rsp+16*12], xmm12
            vmovups   dqword[rsp+16*13], xmm13
            vmovups   dqword[rsp+16*14], xmm14
            vmovups   dqword[rsp+16*15], xmm15
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
            vmovups   xmm0, dqword[rsp+16*0]
            vmovups   xmm1, dqword[rsp+16*1]
            vmovups   xmm2, dqword[rsp+16*2]
            vmovups   xmm3, dqword[rsp+16*3]
            vmovups   xmm4, dqword[rsp+16*4]
            vmovups   xmm5, dqword[rsp+16*5]
            vmovups   xmm6, dqword[rsp+16*6]
            vmovups   xmm7, dqword[rsp+16*7]
            vmovups   xmm8, dqword[rsp+16*8]
            vmovups   xmm9, dqword[rsp+16*9]
            vmovups   xmm10, dqword[rsp+16*10]
            vmovups   xmm11, dqword[rsp+16*11]
            vmovups   xmm12, dqword[rsp+16*12]
            vmovups   xmm13, dqword[rsp+16*13]
            vmovups   xmm14, dqword[rsp+16*14]
            vmovups   xmm15, dqword[rsp+16*15]
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
               call  _WriteOut_Output
             PopAll
  end if
end macro
