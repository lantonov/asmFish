
Perft_Root:

virtual at rsp
 .time	   dq ?
 .movelist rb sizeof.ExtMove*MAX_MOVES
 .extra    rq 1
 .lend	   rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

           push  rbx rsi rdi r14 r15
     _chkstk_ms  rsp, .localsize
            sub  rsp, .localsize
            mov  rbx, qword[rbp + Pos.state]
            mov  r15d, ecx
            xor  r14, r14
           call  Os_GetTime
            mov  qword[.time], rax
           call  SetCheckInfo
            lea  rdi, [.movelist]
            mov  rsi, rdi
           call  Gen_Legal
            xor  eax, eax
            mov  dword[rdi], eax
.MoveLoop:
            mov  ecx, dword[rsi]
           test  ecx, ecx
             jz  .MoveLoopDone
            mov  ecx, dword[rsi]

           call  Move_GivesCheck
            mov  ecx, dword[rsi]
            mov  qword[.extra+8*0], rcx
            mov  byte[rbx+State.givesCheck], al
           call  Move_Do__PerftGen_Root
            mov  eax, 1
            lea  ecx, [r15-1]
            cmp  r15d, 1
            jbe  @1f
           call  Perft_Branch
	@1:
            add  r14, rax
            mov  qword[.extra+8*1], rax
            mov  ecx, dword[rsi]
           call  Move_Undo

    ; write out stats for this move
            lea  rdi, [Output]
            lea  rcx, [sz_format_perft1]
            lea  rdx, [.extra]
            xor  r8, r8
           call  PrintFancy
           call  WriteLine_Output

            add  rsi, sizeof.ExtMove
            jmp  .MoveLoop

.MoveLoopDone:
           call  Os_GetTime
            sub  rax, qword[.time]
            mov  rcx, rax

    ; write out stats for overall perft
            lea  rdi, [Output]
            mov  rax, r14
            mov  edx, 1000
            mov  qword[.extra+8*1], r14
            mul  rdx
            mov  qword[.extra+8*0], rcx
            cmp  rcx, 1
            adc  rcx, 0
            div  rcx
            mov  qword[.extra+8*2], rax
            lea  rcx, [sz_format_perft2]
            lea  rdx, [.extra]
            xor  r8, r8
           call  PrintFancy
           call  WriteLine_Output
.Done:
            mov  qword[rbp+Pos.state], rbx
            add  rsp, .localsize
            pop  r15 r14 rdi rsi rbx
            ret




	     calign  16
Perft_Branch:

virtual at rsp
.movelist  rb sizeof.ExtMove*MAX_MOVES
.lend	   rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

           push  rsi r14 r15
     _chkstk_ms  rsp, .localsize
            sub  rsp, .localsize

            lea  r15d, [rcx-1]
            xor  r14, r14
            lea  rdi, [.movelist]
            mov  rsi, rdi
            cmp  ecx, 1
             ja  .DepthN
.Depth1:
           call  Gen_Legal
            mov  rax, rdi
            sub  rax, rsi
            shr  eax, 3         ; assume sizeof.ExtMove = 8
            add  rsp, .localsize
            pop  r15 r14 rsi
            ret


         calign  8
.DepthN:
           call  Gen_Legal
            xor  eax, eax
            mov  dword[rdi], eax

            mov  ecx, dword[rsi]
           test  ecx, ecx
             jz  .DepthNDone
.DepthNLoop:
           call  Move_GivesCheck
            mov  ecx, dword[rsi]
            mov  byte[rbx + State.givesCheck], al
           call  Move_Do__PerftGen_Branch
            mov  ecx, r15d
           call  Perft_Branch
            add  r14, rax
            mov  ecx, dword[rsi]
            add  rsi, sizeof.ExtMove
           call  Move_Undo
            mov  ecx, dword[rsi]
           test  ecx, ecx
            jnz  .DepthNLoop
.DepthNDone:
            mov  rax, r14
            add  rsp, .localsize
            pop  r15 r14 rsi
            ret
