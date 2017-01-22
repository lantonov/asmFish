MoveHorizon equ 50
MaxRatio    equ 7.09
StealRatio  equ 0.35
XScale      equ 7.64
XShift      equ 58.4
mSkew       equ -0.183

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

Display_String 'ply: '
Display_Int qword[.ply]
GD_String ' inc: '
GD_Int qword[limits.incr+4*rsi]
GD_String ' time: '
GD_Int qword[limits.time+4*rsi]
GD_String ' movestogo: '
GD_Int qword[limits.movestogo]
GD_NewLine

		mov   rax, qword[limits.startTime]
		mov   qword[time.startTime], rax

		mov   eax, dword[limits.time+4*rsi]
		mov   ecx, dword[options.minThinkTime]
		cmp   eax, ecx
	      cmovb   eax, ecx
		mov   r12d, eax
		mov   r13d, eax
	; r12d = optimumTime
	; r13d = maximumTime

		mov   eax, dword[limits.movestogo]
		mov   ecx, MoveHorizon
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
GD_String 'optimumTime: '
GD_Int r12
GD_String ' maximumTime: '
GD_Int r13
GD_NewLine
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

               call   .move_importance
	  vcvtsi2sd   xmm1, xmm1, dword[options.slowMover]
	     vmulsd   xmm6, xmm0, xmm1
	     vdivsd   xmm6, xmm6, qword[.100p0]
	; xmm6 = moveImportance
	     vxorps   xmm2, xmm2, xmm2
		lea   ecx, [r8+2*rdx]
 .otherLoop:
		add   r8d, 2
		cmp   r8d, ecx
		jae   .otherDone
               call   .move_importance
	     vaddsd   xmm2, xmm2, xmm0
		jmp   .otherLoop
 .otherDone:
	; xmm2 = otherMovesImportance
	     vmulsd   xmm4, xmm4, xmm6
	     vmulsd   xmm5, xmm5, xmm2
	     vaddsd   xmm0, xmm4, xmm2
	     vdivsd   xmm4, xmm4, xmm0
	     vaddsd   xmm5, xmm5, xmm6
	     vaddsd   xmm0, xmm6, xmm2
	     vdivsd   xmm5, xmm5, xmm0
	     vminsd   xmm4, xmm4, xmm5
	     vmulsd   xmm3, xmm3, xmm4
	 vcvttsd2si   rax, xmm3
		ret

.move_importance:
        ; in: r8d ply
        ; out: xmm0
	  vcvtsi2sd   xmm0, xmm0, r8d
	     vsubsd   xmm0, xmm0, qword[.XShift]
	     vdivsd   xmm0, xmm0, qword[.XScale]
	       call   Math_Exp_d_d
	     vaddsd   xmm0, xmm0, qword[constd.1p0]
	     vmovsd   xmm1, qword[.mSkew]
	       call   Math_Power_d_dd
	     vaddsd   xmm0, xmm0, qword[.mind]
                ret


align 8
.XShift:    dq XShift
.XScale:    dq XScale
.mSkew:     dq mSkew
.MaxRatio   dq MaxRatio
.StealRatio dq StealRatio
.mind:	 dq 0x0010000000000000
.100p0:  dq 100.0

restore MoveHorizon
restore MaxRatio
restore StealRatio
restore XScale
restore XShift
restore mSkew
