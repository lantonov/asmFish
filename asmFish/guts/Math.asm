

Math_Rand_i:
	; in: rcx address of Prng
	; out: rax  integer in [0,2^64)
		mov   rax, qword[rcx]
		mov   rdx, rax
		shr   rdx, 12
		xor   rax, rdx
		mov   rdx, rax
		shl   rdx, 25
		xor   rax, rdx
		mov   rdx, rax
		shr   rdx, 27
		xor   rax, rdx
		mov   rdx, 2685821657736338717
		mov   qword[rcx], rax
	       imul   rax, rdx
		ret

Math_Rand_d:
	; in: rcx address of Prng
	; out: xmm0  scalar double in [0,1)   *should* be uniformly distr
	       call   Math_Rand_i
		mov   ecx, 1023 ; 10 exponen bits
		shl   rax, 11	; 53 mantissa bits
		 jz   .Return
.Shift:
		sub   ecx, 1
		shl   rax, 1
		jnc   .Shift
		 or   rax, rcx
		ror   rax, 12
.Return:
	      vmovq   xmm0, rax
		ret


Math_Exp_d_d:
	; xmm0 = Exp[xmm0]
	       push   rbx
		sub   rsp, 32
	      movsd   qword[rsp+8H], xmm0
		fld   qword[rsp+8H]
	      fwait
	     fnstcw   word[rsp+1CH]
	      fwait
	     fnstcw   word[rsp+1EH]
		 or   word[rsp+1EH], 0C00H
	      fldcw   word[rsp+1EH]
	     fldl2e
	      fmulp   st1, st0
		fld   st0
	    frndint
	       fxch   st1
	       fsub   st0, st1
	      f2xm1
	       fld1
	      faddp   st1, st0
	       fxch   st1
	       fld1
	     fscale
	       fstp   st1
	      fmulp   st1, st0
	      fldcw   word[rsp+1CH]
	       fstp   qword[rsp+8H]
	      movsd   xmm0, qword[rsp+8H]
		add   rsp, 32
		pop   rbx
		ret

Math_Log_d_d:
	; xmm0 = Log[xmm0]
	       push   rbx
		sub   rsp, 32
	     vmovsd   qword[rsp+8H], xmm0
		fld   qword[rsp+8H]
	      fwait
	     fnstcw   word[rsp+1CH]
	      fwait
	     fnstcw   word[rsp+1EH]
		 or   word[rsp+1EH], 0C00H
	      fldcw   word[rsp+1EH]
	     fldln2
	       fxch   st1
	      fyl2x
	      fldcw   word[rsp+1CH]
	       fstp   qword[rsp+8H]
	     vmovsd   xmm0, qword[rsp+8H]
		add   rsp, 32
		pop   rbx
		ret


Math_Lerp:
	; in: rcx address of table start
	;     rdx address of table end
	;     xmm0 value to convert
	; out: xmm0 converted value
	;
	; first coordinates in table are assumed sorted and distinct

x equ xmm0 ; input and output
t equ xmm1 ; (ax,ay)
a equ xmm2 ; (ax,ay)
b equ xmm3 ; (bx,by)
current equ rcx
ender	equ rdx

	    vmovaps   b, dqword[current]
		add   current, 16
	    vcomisd   x, b
		jbe   .Return_by
.Loop:
	    vmovaps   a, b
	    vmovaps   b, dqword[current]
		add   current, 16
	    vcomisd   x, b
		jbe   .Lerp
		cmp   current, ender
		 jb   .Loop
.Return_by:
	   vmovhlps   x, x, b
		ret
.Lerp:
	     vsubpd   b, b, a
	   vmovhlps   t, t, b
	     vsubsd   x, x, a
	     vdivsd   t, t, b
	     vmulsd   x, x, t
	   vmovhlps   t, t, a
	     vaddsd   x, x, t
		ret


restore x
restore t
restore a
restore b
restore current
restore ender




Math_Power_d_dd:
	; xmm0 = Power[xmm0, xmm1]
	       push   rsi
	       push   rbx
		sub   rsp, 40
	      movsd   qword[rsp+8H], xmm0
		fld   qword[rsp+8H]
	      movsd   qword[rsp+8H], xmm1
		fld   qword[rsp+8H]
	       fxch   st1
	       ftst
	      fwait
	     fnstsw   ax
		and   ah, 040H
		 jz   ._035
	       fstp   st0
	       ftst
	      fwait
	     fnstsw   ax
	       fstp   st0
		and   ah, 040H
		jnz   ._034
	       fldz
		jmp   ._036
._034:
	       fld1
		jmp   ._036
._035:
	      fwait
	     fnstcw   word[rsp+1CH]
	      fwait
	     fnstcw   word[rsp+1EH]
		 or   word[rsp+1EH], 0C00H
	      fldcw   word[rsp+1EH]
	       fld1
	       fxch   st1
	      fyl2x
	      fmulp   st1, st0
		fld   st0
	    frndint
	       fxch   st1
	       fsub   st0, st1
	      f2xm1
	       fld1
	      faddp   st1, st0
	       fxch   st1
	       fld1
	     fscale
	       fstp   st1
	      fmulp   st1, st0
	      fldcw   word[rsp+1CH]
._036:
	       fstp   qword[rsp+8H]
	      movsd   xmm0, qword[rsp+8H]
		add   rsp, 40
		pop   rbx
		pop   rsi
		ret











