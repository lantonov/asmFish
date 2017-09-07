
Math_Rand_i:
    ; in: rcx address of Prng
    ; out: rax  integer in (0,2^64)
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
             jz   @2f
    @1:
            sub   ecx, 1
            shl   rax, 1
            jnc   @1b
             or   rax, rcx
            ror   rax, 12
    @2:
         _vmovq   xmm0, rax
            ret


Math_Exp_d_d:
    ; xmm0 = Exp[xmm0]
           push   rbx
            sub   rsp, 32
        _vmovsd   qword[rsp+8H], xmm0
          fwait
         fnstcw   word[rsp+1CH]         ; save precision
          fwait
         fnstcw   word[rsp+1EH]
            and   word[rsp+1EH], 0xF3FF     ; round nearest
             or   word[rsp+1EH], 0x0300     ; 80 bit precision
          fldcw   word[rsp+1EH]
            fld   qword[rsp+8H]
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
           fstp   qword[rsp+8H]
          fldcw   word[rsp+1CH]         ; restore precision
        _vmovsd   xmm0, qword[rsp+8H]
            add   rsp, 32
            pop   rbx
            ret


Math_Log_d_d:
    ; xmm0 = Log[xmm0]
           push   rbx
            sub   rsp, 32
        _vmovsd   qword[rsp+8H], xmm0
          fwait
         fnstcw   word[rsp+1CH]     ; save precision
          fwait
         fnstcw   word[rsp+1EH]
            and   word[rsp+1EH], 0xF3FF     ; round nearest
             or   word[rsp+1EH], 0x0300     ; 80 bit precision
          fldcw   word[rsp+1EH]
            fld   qword[rsp+8H]
         fldln2
           fxch   st1
          fyl2x
           fstp   qword[rsp+8H]
          fldcw   word[rsp+1CH]     ; restore precision
        _vmovsd   xmm0, qword[rsp+8H]
            add   rsp, 32
            pop   rbx
            ret


if USE_WEAKNESS
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

       _vmovaps   b, dqword[current]
            add   current, 16
       _vcomisd   x, b
            jbe   .Return_by
    @1:
       _vmovaps   a, b
       _vmovaps   b, dqword[current]
            add   current, 16
       _vcomisd   x, b
            jbe   .Lerp
            cmp   current, ender
             jb   @1
.Return_by:
      _vmovhlps   x, x, b
            ret
.Lerp:
        _vsubpd   b, b, a
      _vmovhlps   t, t, b
        _vsubsd   x, x, a
        _vdivsd   t, t, b
        _vmulsd   x, x, t
      _vmovhlps   t, t, a
        _vaddsd   x, x, t
            ret

restore x
restore t
restore a
restore b
restore current
restore ender
end if


Math_Power_d_dd:
    ; xmm0 = Power[xmm0, xmm1]
           push   rsi
           push   rbx
            sub   rsp, 40            
          fwait
         fnstcw   word[rsp+0x1C]     ; save precision
          fwait
         fnstcw   word[rsp+0x1E]
            and   word[rsp+0x1E], 0xF3FF     ; round nearest
             or   word[rsp+0x1E], 0x0300     ; 80 bit precision
          fldcw   word[rsp+0x1E]
        _vmovsd   qword[rsp+8], xmm0
            fld   qword[rsp+8]
        _vmovsd   qword[rsp+8], xmm1
            fld   qword[rsp+8]
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
._036:
           fstp   qword[rsp+8]
          fldcw   word[rsp+0x1C]     ; restore precision
        _vmovsd   xmm0, qword[rsp+8]
            add   rsp, 40
            pop   rbx
            pop   rsi
            ret

