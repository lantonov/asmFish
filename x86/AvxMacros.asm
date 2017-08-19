
; these macro simulate the avx instructions with lower ones
; might be confusing


macro _vaddsd a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vaddsd  a,b,c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      addsd  a, c
    else if a eq c
	      addsd  a, b
    else
	     movaps  a, b
	      addsd  a, c
    end if
; \}
end macro


macro _vaddsd a,b,c
  if CPU_HAS_AVX1
             vaddsd   a, b, c
  else
    if a eq b
	      addsd   a, c
    else
        match size[addr], c
	     movaps   a, b
	      addsd   a, c
        else
            if a eq c
	      addsd   a, b
            else
	     movaps   a, b
	      addsd   a, c
            end if
        end match
    end if
  end if
end macro


macro _vsubsd a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vsubsd  a,b,c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      subsd  a, c
    else if a eq c
	   display 'arguments of vsubsd are strange for no avx1'
	   display 13,10
	   err
    else
	     movaps  a, b
	      subsd  a, c
    end if
; \}
end macro

macro _vsubpd a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vsubpd  a,b,c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      subpd  a, c
    else if a eq c
	   display 'arguments of vsubpd are strange for no avx1'
	   display 13,10
	   err
    else
	     movaps  a, b
	      subpd  a, c
    end if
; \}
end macro

macro _vmulsd a,b,c
  if CPU_HAS_AVX1
             vmulsd   a, b, c
  else
    if a eq b
	      mulsd   a, c
    else
        match size[addr], c
	     movaps   a, b
	      mulsd   a, c
        else
            if a eq c
	      mulsd   a, b
            else
	     movaps   a, b
	      mulsd   a, c
            end if
        end match
    end if
  end if
end macro


; a = b*c+d
macro _vfmaddsd a,b,c,d
; match =1, CPU_HAS_AVX2 \{
;	if a equ b
;	vfmadd213sd   a, c, d
;	else if a equ c
;	vfmadd213sd   a, b, d
;	else if a equ d
;	vfmadd231sd   a, b, c
;	else
;	    vmovaps   a, b
;	vfmadd213sd   a, c, d
;	end if
;
; \}
; match =0, CPU_HAS_AVX2 \{
	 if a eq d
	   err 'arguments of vfmaddpd are strange for no avx2'
	 end if
	    _vmulsd   a, b, c
	    _vaddsd   a, a, d
; \}
end macro


macro _vcvtsi2sd a,b,c
; match =1, CPU_HAS_AVX1 \{
;         vcvtsi2sd   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	   cvtsi2sd   a, c
    else
	     movaps   a, b
	   cvtsi2sd   a, c
    end if
; \}
end macro

macro _vcvttsd2si a,b
; match =1, CPU_HAS_AVX1 \{
;	 vcvttsd2si   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	  cvttsd2si   a, b
; \}
end macro


macro _vdivsd a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vdivsd   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      divsd   a, c
    else if a eq c
	   display 'arguments of vdivsd are strange for no avx1'
	   display 13,10
	   err
    else
	     movaps   a, b
	      divsd   a, c
    end if
; \}
end macro



macro _vcomisd a,b
; match =1, CPU_HAS_AVX1 \{
;	    vcomisd   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     comisd   a, b
; \}
end macro


macro _vmovaps a,b
; match =1, CPU_HAS_AVX1 \{
;	    vmovaps   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     movaps   a, b
; \}
end macro

macro _vmovups a,b
; match =1, CPU_HAS_AVX1 \{
;	    vmovups   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     movups   a, b
; \}
end macro

macro _vmovapd a,b
; match =1, CPU_HAS_AVX1 \{
;	    vmovapd   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     movapd   a, b
; \}
end macro

macro _vmovsd a, b, c
; match =1, CPU_HAS_AVX1 \{
;    if c eq
;	     vmovsd   a, b
;    else
;             vmovsd   a, b, c
;    end if
; \}
; match =0, CPU_HAS_AVX1 \{
    match , c
           SSE.movsd   a, b
    else
        if a eq b
	   SSE.movsd   a, c
        else
	     movaps   a, b
	   SSE.movsd   a, c
        end if
    end match
; \}
end macro

macro _vmovq a,b
; match =1, CPU_HAS_AVX1 \{
;	      vmovq   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	       movq   a, b
; \}
end macro

macro _vpand a,b,c
; match =1, CPU_HAS_AVX1 \{
;	      vpand   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	       pand   a, c
    else
	     movdqa   a, b
	       pand   a, c
    end if
; \}
end macro

macro _vpsrlq a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vpsrlq  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      psrlq  a, c
    else
	     movdqa  a, b
	      psrlq  a, c
    end if
; \}
end macro


macro _vpunpcklbw a,b,c
; match =1, CPU_HAS_AVX1 \{
;	 vpunpcklbw   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	  punpcklbw   a, c
    else
	     movdqa   a, b
	  punpcklbw   a, c
    end if
; \}
end macro


macro _vpaddb a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vpaddb  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      paddb  a, c
    else
	     movdqa  a, b
	      paddb  a, c
    end if
; \}
end macro

macro _vpcmpgtb a,b,c
; match =1, CPU_HAS_AVX1 \{
;	   vpcmpgtb   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	    pcmpgtb   a, c
    else
	     movdqa   a, b
	    pcmpgtb   a, c
    end if
; \}
end macro

macro _vmovdqa a,b
; match =1, CPU_HAS_AVX1 \{
;	    vmovdqa   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     movdqa   a, b
; \}
end macro

macro _vmovdqu a,b
; match =1, CPU_HAS_AVX1 \{
;	    vmovdqu   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	     movdqu   a, b
; \}
end macro

macro _vpxor a,b,c
; match =1, CPU_HAS_AVX1 \{
;	      vpxor  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	       pxor  a, c
    else
	     movdqa  a, b
	       pxor  a, c
    end if
; \}
end macro

macro _vmovd a,b
; match =1, CPU_HAS_AVX1 \{
;	      vmovd   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	       movd   a, b
; \}
end macro



macro _vpaddd a, b, c
; match =1, CPU_HAS_AVX1 \{
;	     vpaddd  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      paddd  a, c
    else
	     movdqa  a, b
	      paddd  a, c
    end if
; \}
end macro

macro _vminsd a, b, c
; match =1, CPU_HAS_AVX1 \{
;	     vminsd  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      minsd  a, c
    else
	     movaps  a, b
	      minsd  a, c
    end if
; \}
end macro

macro _vmaxsd a, b, c
; match =1, CPU_HAS_AVX1 \{
;	     vmaxsd  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      maxsd  a, c
    else
	     movaps  a, b
	      maxsd  a, c
    end if
; \}
end macro

macro _vxorps a, b, c
; match =1, CPU_HAS_AVX1 \{
;	     vxorps  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      xorps  a, c
    else
	     movaps  a, b
	      xorps  a, c
    end if
; \}
end macro

macro _vpsubd a, b, c
; match =1, CPU_HAS_AVX1 \{
;	     vpsubd  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      psubd  a, c
    else
	     movdqa  a, b
	      psubd  a, c
    end if
; \}
end macro


macro vpsrlq a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vpsrlq  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      psrlq  a, c
    else
	     movdqa  a, b
	      psrlq  a, c
    end if
; \}
end macro

macro vpsubw a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vpsubw   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      psubw   a, c
    else
	     movdqa   a, b
	      psubw   a, c
    end if
; \}
end macro

macro vpslldq a,b,c
; match =1, CPU_HAS_AVX1 \{
;	    vpslldq   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	     pslldq   a, c
    else
	     movdqa   a, b
	     pslldq   a, c
    end if
; \}
end macro

macro vpsrldq a,b,c
; match =1, CPU_HAS_AVX1 \{
;	    vpsrldq   a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	     psrldq   a, c
    else
	     movdqa   a, b
	     psrldq   a, c
    end if
; \}
end macro

macro _vmovhlps a,b,c
; match =1, CPU_HAS_AVX1 \{
;	   vmovhlps  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	    movhlps  a, c
    else
	     movaps  a, b
	    movhlps  a, c
    end if
; \}
end macro

macro _vsqrtsd a,b,c
; match =1, CPU_HAS_AVX1 \{
;	    vsqrtsd  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	     sqrtsd  a, c
    else
	     movaps  a, b
	     sqrtsd  a, c
    end if
; \}
end macro


macro _vcvtsd2si a, b
; match =1, CPU_HAS_AVX1 \{
;	  vcvtsd2si   a, b
; \}
; match =0, CPU_HAS_AVX1 \{
	   cvtsd2si   a, b
; \}
end macro



macro _vpaddw a,b,c
; match =1, CPU_HAS_AVX1 \{
;	     vpaddw  a, b, c
; \}
; match =0, CPU_HAS_AVX1 \{
    if a eq b
	      paddw  a, c
    else
	     movdqa  a, b
	      paddw  a, c
    end if
; \}
end macro

