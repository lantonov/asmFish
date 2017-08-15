MoveHorizon = 50
MaxRatio    = 7.09
StealRatio  = 0.35
XScale      = 7.64
XShift      = 58.4
mSkew       = -0.183

TimeMng_Init:
	; in: ecx color us
	;     edx ply

virtual at rsp
  .ply   rd 1
  .lend  rb 0
end virtual
.localsize = ((.lend-rsp+15) and (-16))

	       push   rbx rsi rdi r12 r13 r14 r15
	 _chkstk_ms   rsp, .localsize
		sub   rsp, .localsize
; AssertStackAligned   'TimeMng_Init'

		mov   esi, ecx
		mov   dword[.ply], edx
Display 1, 'ply: %i2 '

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
Display 1, 'movestogo: %i0 '
		mov   ecx, MoveHorizon
	       test   eax, eax
	      cmovz   eax, ecx
		cmp   eax, ecx
	      cmova   eax, ecx
		mov   r14d, eax
	; r14d = MaxMTG

		xor   edi, edi
.looper:
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
Display 1, 'time: %i1 '
		sub   rcx, rax
		mov   eax, dword[limits.incr+4*rsi]
Display 1, 'incr: %i0%n'
		lea   edx, [rdi-1]
		mul   rdx
		xor   edx, edx
		add   rcx, rax
	      cmovs   rcx, rdx
		mov   rbx, rcx

		mov   edx, edi
		mov   r8d, dword[.ply]
	    _vmovsd   xmm4, qword[constd._1p0]
	    _vxorps   xmm5, xmm5, xmm5
	       call   .remaining
		mov   edx, dword[options.minThinkTime]
		add   rax, rdx
		cmp   r12, rax
	      cmova   r12, rax

		mov   rcx, rbx
		mov   edx, edi
		mov   r8d, dword[.ply]
	    _vmovsd   xmm4, qword[.MaxRatio]
	    _vmovsd   xmm5, qword[.StealRatio]
	       call   .remaining
		mov   edx, dword[options.minThinkTime]
		add   rax, rdx
		cmp   r13, rax
	      cmova   r13, rax

		jmp   .looper
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

Display 1, 'optimumTime: %I12 maximumTime: %I13%n'

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

	    _vxorps   xmm2, xmm2, xmm2
	 _vcvtsi2sd   xmm3, xmm3, rcx
	; xmm3 = myTime

               call   .move_importance
	 _vcvtsi2sd   xmm1, xmm1, dword[options.slowMover]
	    _vmulsd   xmm6, xmm0, xmm1
	    _vdivsd   xmm6, xmm6, qword[._100p0]
	; xmm6 = moveImportance
	    _vxorps   xmm2, xmm2, xmm2
		lea   ecx, [r8+2*rdx]
 .otherLoop:
		add   r8d, 2
		cmp   r8d, ecx
		jae   .otherDone
               call   .move_importance
	    _vaddsd   xmm2, xmm2, xmm0
		jmp   .otherLoop
 .otherDone:
	; xmm2 = otherMovesImportance
	    _vmulsd   xmm4, xmm4, xmm6
	    _vmulsd   xmm5, xmm5, xmm2
	    _vaddsd   xmm0, xmm4, xmm2
	    _vdivsd   xmm4, xmm4, xmm0
	    _vaddsd   xmm5, xmm5, xmm6
	    _vaddsd   xmm0, xmm6, xmm2
	    _vdivsd   xmm5, xmm5, xmm0
	    _vminsd   xmm4, xmm4, xmm5
	    _vmulsd   xmm3, xmm3, xmm4
	_vcvttsd2si   rax, xmm3
		ret

.move_importance:
        ; in: r8d ply
        ; out: xmm0
	 _vcvtsi2sd   xmm0, xmm0, r8d
	    _vsubsd   xmm0, xmm0, qword[.XShift]
	    _vdivsd   xmm0, xmm0, qword[.XScale]
	       call   Math_Exp_d_d
	    _vaddsd   xmm0, xmm0, qword[constd._1p0]
	    _vmovsd   xmm1, qword[.mSkew]
	       call   Math_Power_d_dd
	    _vaddsd   xmm0, xmm0, qword[.mind]
                ret


             calign 8

.XShift:    dq XShift
.XScale:    dq XScale
.mSkew:     dq mSkew
.MaxRatio   dq MaxRatio
.StealRatio dq StealRatio
.mind:      dq 0x0010000000000000
._100p0:    dq 100.0

restore MoveHorizon
restore MaxRatio
restore StealRatio
restore XScale
restore XShift
restore mSkew
