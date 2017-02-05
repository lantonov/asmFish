MOVE_HORIZON = 50

TimeMng_Init:
	; in: ecx color us
	;     edx ply

virtual at rsp
  .ply	   rd 1
  .lend rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	       push   rbx rsi rdi r12 r13 r14 r15
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
 AssertStackAligned   'TimeMng_Init'

		mov   esi, ecx
		mov   dword[.ply], edx

		mov   rax, qword[limits.startTime]
		mov   qword[time.startTime], rax

		mov   eax, dword[limits.time+4*rsi]
		mov   ecx, dword[options.minThinkTime]
		cmp   eax, ecx
	      cmovb   eax, ecx
		mov   r12d, eax
		mov   r13d, eax
	; r12d = optimumTime]
	; r13d = time.maximumTime


		mov   eax, dword[limits.movestogo]
		mov   ecx, MOVE_HORIZON
	       test   eax, eax
	      cmovz   eax, ecx
		cmp   eax, ecx
	      cmova   eax, ecx
		mov   r14d, eax
	; r14d = MaxMTG

		xor   edi, edi
.loop:
		add   edi, 1
		cmp   edi, r14d
		 ja   .loopdone

		mov   eax, 40
		cmp   eax, edi
	      cmova   eax, edi
		add   eax, 2
		mov   edx, dword[options.moveOverhead]
		mul   rdx
		mov   ecx, dword[limits.time+4*rsi]
		sub   rcx, rax
		mov   eax, dword[limits.incr+4*rsi]
		lea   edx, [rdi-1]
		mul   rdx
		xor   edx, edx
		add   rcx, rax
	      cmovs   rcx, rdx
		mov   rbx, rcx

		mov   edx, edi
		mov   r8d, dword[.ply]
	     vmovsd   xmm4, qword[constd.1p0]
	     vxorps   xmm5, xmm5, xmm5
	       call   .remaining
		mov   edx, dword[options.minThinkTime]
		add   rax, rdx
		cmp   r12, rax
	      cmova   r12, rax

		mov   rcx, rbx
		mov   edx, edi
		mov   r8d, dword[.ply]
	     vmovsd   xmm4, qword[.MaxRatio]
	     vmovsd   xmm5, qword[.StealRatio]
	       call   .remaining
		mov   edx, dword[options.minThinkTime]
		add   rax, rdx
		cmp   r13, rax
	      cmova   r13, rax

		jmp   .loop
.loopdone:
		mov   al, byte[options.ponder]
	       test   al, al
		 jz   .noponder
		mov   rcx, r12
		shr   rcx, 2
		add   r12, rcx
.noponder:

		mov   qword[time.optimumTime], r12
		mov   qword[time.maximumTime], r13

		add   rsp, .localsize
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret

.remaining:
	; in: ecx myTime
	;     edx movesToGo >= 1
	;     r8d ply
	;     xmm4 TMaxRatio
	;     xmm5 TStealRatio
	;     edx = movestogo
	     vxorps   xmm2, xmm2, xmm2
	  vcvtsi2sd   xmm3, xmm3, rcx
	; xmm3 = myTime
		lea   ecx, [rdx-1]
		jmp   .rcomp
.rloop:      vaddsd   xmm2, xmm2, xmm0
.rcomp: 	lea   eax, [r8+2*rcx]
	  vcvtsi2sd   xmm0, xmm0, eax
	     vsubsd   xmm0, xmm0, qword[.XShift]
	     vdivsd   xmm0, xmm0, qword[.XScale]
	       call   Math_Exp_d_d
	     vaddsd   xmm0, xmm0, qword[constd.1p0]
	     vmovsd   xmm1, qword[.Skew]
	       call   Math_Power_d_dd
	     vaddsd   xmm0, xmm0, qword[.mind]
		sub   ecx, 1
		jns   .rloop
	; xmm2 = otherMovesImportance
	  vcvtsi2sd   xmm1, xmm1, dword[options.slowMover]
	     vmulsd   xmm1, xmm1, qword[constd.0p01]
	     vmulsd   xmm1, xmm1, xmm0
	; xmm1 = moveImportance
	     vmulsd   xmm4, xmm4, xmm1
	     vmulsd   xmm5, xmm5, xmm2
	     vaddsd   xmm0, xmm4, xmm2
	     vdivsd   xmm4, xmm4, xmm0
	     vaddsd   xmm5, xmm5, xmm1
	     vaddsd   xmm1, xmm1, xmm2
	     vdivsd   xmm5, xmm5, xmm1
	     vminsd   xmm4, xmm4, xmm5
	     vmulsd   xmm3, xmm3, xmm4
	  vcvtsd2si   rax, xmm3
		ret



align 8
.XShift: dq 58.4
.XScale: dq 7.64
.Skew:	 dq -0.183
.mind:	 dq 2.2250738585072014e-308
.MaxRatio   dq 7.09
.StealRatio dq 0.35
