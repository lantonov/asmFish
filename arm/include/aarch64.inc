
define aarch64


element aarch64.r32
element aarch64.r64
element aarch64.f8
element aarch64.f16
element aarch64.f32
element aarch64.f64
element aarch64.f128
element aarch64.v128

repeat 31, i:0
    element w#i : aarch64.r32 + i
    element x#i : aarch64.r64 + i
end repeat
element wzr : aarch64.r32 + 31
element xzr : aarch64.r64 + 31
element wsp : aarch64.r32 + 32
element sp  : aarch64.r64 + 32

repeat 32, i:0
    element b#i : aarch64.f8 + i
    element h#i : aarch64.f16 + i
    element s#i : aarch64.f32 + i
    element d#i : aarch64.f64 + i
    element q#i : aarch64.f128 + i
    element v#i : aarch64.v128 + i
end repeat

define @op0
define @op1
define @op2
define @op3
define @opA
define @opB
define @ext
define @shf
define @imm
define @con
define @adr


@type_vn_8b   = 1 shl 0 ; must be 0
@type_vn_4h   = 1 shl 1
@type_vn_2s   = 1 shl 2
@type_vn_1d   = 1 shl 3
@type_vn_16b  = 1 shl 4
@type_vn_8h   = 1 shl 5
@type_vn_4s   = 1 shl 6
@type_vn_2d   = 1 shl 7
@type_vn_b   = 1 shl 8
@type_vn_h   = 1 shl 9
@type_vn_s   = 1 shl 10
@type_vn_d   = 1 shl 11
@type_vn_bi   = 1 shl 12
@type_vn_hi   = 1 shl 13
@type_vn_si   = 1 shl 14
@type_vn_di   = 1 shl 15
@type_vn_16b_etc = @type_vn_16b or @type_vn_8b or @type_vn_8h or @type_vn_4h or @type_vn_4s or @type_vn_2s or @type_vn_2d or @type_vn_1d
@type_vn_16b_etc_no_1d = @type_vn_16b or @type_vn_8b or @type_vn_8h or @type_vn_4h or @type_vn_4s or @type_vn_2s or @type_vn_2d
@type_vn_b_etc = @type_vn_b or @type_vn_h or @type_vn_s or @type_vn_d
@type_vn = @type_vn_16b_etc or @type_vn_b_etc


@type_empty     = 1 shl 16
@type_wsp       = 1 shl 17
@type_wn        = 1 shl 18
@type_wzr       = 1 shl 19
@type_xsp       = 1 shl 20
@type_xn        = 1 shl 21
@type_xzr       = 1 shl 22
@type_xn_xsp  = @type_xn or @type_xsp
@type_xn_xzr  = @type_xn or @type_xzr
@type_wn_wsp  = @type_wn or @type_wsp
@type_wn_wzr  = @type_wn or @type_wzr
@type_wn_wzr_xn_xzr = @type_wn_wzr or @type_xn_xzr

@type_bn        = 1 shl 23
@type_hn        = 1 shl 24
@type_sn        = 1 shl 25
@type_dn        = 1 shl 26
@type_qn        = 1 shl 27



@type_immf           = 1 shl 28
@type_immc           = 1 shl 29
@type_immc_lo12      = 1 shl 31
@type_immc_gp_hi21   = 1 shl 33
@type_immc_abs_g2    = 1 shl 35
@type_immc_abs_g1_nc = 1 shl 37
@type_immc_abs_g0_nc = 1 shl 39
@type_immr           = @type_immr shl 1
@type_immr_lo12      = @type_immr_lo12 shl 1
@type_immr_abs_g2    = @type_immr_abs_g2 shl 1
@type_immr_abs_g1_nc = @type_immr_abs_g1_nc shl 1
@type_immr_abs_g0_nc = @type_immr_abs_g0_nc shl 1
@type_immr_gp_hi21   = @type_immr_gp_hi21 shl 1
@type_immr_immc = @type_immr or @type_immc


@atype_simple    = 1 shl 0
@atype_register  = 1 shl 1
@atype_preincr   = 1 shl 2
@atype_postincr  = 1 shl 3
@atype_literal   = 1 shl 4
@atype_incr   = @atype_preincr or @atype_postincr

macro use64
end macro


macro aarch64.reloc_movk_g0
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g1
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g2
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g3
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ld_lo19
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_adr_lo21
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_adrp_pghi21
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_add_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst8_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst16_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst32_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst64_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst128_lo12
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_tstbr14
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_condbr19
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_jump26
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_call26
    err 'relocation macro not implemented'
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; immediate encodings ;
;;;;;;;;;;;;;;;;;;;;;;;

macro aarch64.restrict x, lower, upper, mask:0
    if ((x) and (mask)) <> 0 | (x) < (lower) | (x) > (upper)
        err 'value is out of range'
    end if
end macro

; determine if x can be encoded as a wide immediate
macro aarch64.parse_uimm64 x
    assert x relativeto 0
    @imm.number = x and 0xFFFFFFFFFFFFFFFF
    @imm.success = 1
    @imm.shift = 0
    @imm.inv = 0
    if @imm.number < 0x10000
        @imm.shift = 0
    else if (@imm.number and 0xFFFF) = 0 & (@imm.number shr 16) < 0x10000
        @imm.shift = 1
    else if (@imm.number and 0xFFFFFFFF) = 0 & (@imm.number shr 32) < 0x10000
        @imm.shift = 2
    else if (@imm.number and 0xFFFFFFFFFFFF) = 0 & (@imm.number shr 48) < 0x10000
        @imm.shift = 3
    else
        @imm.number = @imm.number xor 0xFFFFFFFFFFFFFFFF
        @imm.inv = 1
        if @imm.number < 0x10000
            @imm.shift = 0
        else if (@imm.number and 0xFFFF) = 0 & (@imm.number shr 16) < 0x10000
            @imm.shift = 1
        else if (@imm.number and 0xFFFFFFFF) = 0 & (@imm.number shr 32) < 0x10000
            @imm.shift = 2
        else if (@imm.number and 0xFFFFFFFFFFFF) = 0 & (@imm.number shr 48) < 0x10000
            @imm.shift = 3
        else
            @imm.success = 0
        end if
    end if
    if x > 0xFFFFFFFFFFFFFFFF
        @imm.success = 0
    else if x < -0x8000000000000000
        @imm.success = 0
    end if
    @imm.imm16 = @imm.number shr (16*@imm.shift)
end macro

macro aarch64.parse_uimm32 x
    assert x relativeto 0
    @imm.number = +x and 0xFFFFFFFF
    @imm.success = 1
    @imm.shift = 0
    @imm.inv = 0
    if @imm.number < 0x10000
        @imm.shift = 0
    else if (@imm.number and 0xFFFF) = 0 & (@imm.number shr 16) < 0x10000
        @imm.shift = 1
    else
        @imm.number = @imm.number xor 0xFFFFFFFF
        @imm.inv = 1
        if @imm.number < 0x10000
            @imm.shift = 0
        else if (@imm.number and 0xFFFF) = 0 & (@imm.number shr 16) < 0x10000
            @imm.shift = 1
        else
            @imm.success = 0
        end if
    end if
    if x > 0xFFFFFFFF
        @imm.success = 0
    else if x < -0x80000000
        @imm.success = 0
    end if
    @imm.imm16 = @imm.number shr (16*@imm.shift)
end macro

; determine if x can be encoded as a logical immediate
macro aarch64.parse_bimm64 x, ec:0
    local value, negate, a, b, c, d, clz_a, clz_b, clz_c
    assert x relativeto 0
    value = x and 0xFFFFFFFFFFFFFFFF
    negate = 0
    @imm.success = 0
    if value and 1 = 1
        negate = 1
        value = value xor 0xFFFFFFFFFFFFFFFF
    end if
    a = value and -value
    b = (value + a) and -(value + a)
    c = (value + a - b) and -(value + a - b)
    if c <> 0 | a <> 0
        if a = 0
            clz_a = 64
        else 
            clz_a = 63 - bsr a    
        end if
        if c <> 0
            clz_c = 63 - bsr c
            d = clz_a - clz_c
            @imm.n = 0
        else
            d = 64
            @imm.n = 1
        end if
        mask = 1 shl d - 1
        mult = 0
        if d = 2
            mult = 0x5555555555555555
        else if d = 4
            mult = 0x1111111111111111
        else if d = 8
            mult = 0x0101010101010101
        else if d = 16
            mult = 0x0001000100010001
        else if d = 32
            mult = 0x0000000100000001
        else if d = 64
            mult = 0x0000000000000001
        end if
        if mult <> 0 
          if (b - a) and not mask = 0
            if value = (b - a)*mult
                if b = 0
                    clz_b = -1
                else
                    clz_b = 63 - bsr b
                end if
                @imm.s = clz_a - clz_b
                if negate
                    @imm.s = d - @imm.s
                    @imm.r = (clz_b + 1) and (d - 1)
                else
                    @imm.r = (clz_a + 1) and (d - 1)
                end if
                @imm.success = 1
                @imm.s = ((-d shl 1) or (@imm.s - 1)) and 0x3F
            end if
          end if
        end if
    end if
    if x > 0xFFFFFFFFFFFFFFFF
        @imm.success = 0
    else if x < -0x8000000000000000
        @imm.success = 0
    end if
    if ec & @imm.success = 0
        err 'logical immediate cannot be encoded'
    end if
end macro

macro aarch64.parse_bimm32 x, ec:
    aarch64.parse_bimm64 0x100000001*(x and 0xFFFFFFFF), ec
    if x > 0xFFFFFFFF
        @imm.success = 0
    else if x < -0x80000000
        @imm.success = 0
    end if
end macro


; err if x can be encoded as a arithmetic immediate
macro aarch64.parse_aimm x, ec:0
    @imm.number = +x
    @imm.success = 0
    @imm.shift = 0
    @imm.imm12 = 0
    assert @imm.number relativeto 0
    if @shf.empty
        if @imm.number >= 0
            @imm.inv = 0
            if @imm.number < 0x1000
                @imm.shift = 0
                @imm.imm12 = @imm.number
            else if (@imm.number and 0x0FFF) = 0 & (@imm.number shr 12) < 0x1000
                @imm.shift = 1
                @imm.imm12 = @imm.number shr 12
            else if ec
                err 'immediate out of range'
            else
                @imm.success = 0
            end if        
        else
            @imm.inv = 1
            @imm.number = -@imm.number
            if @imm.number < 0x1000
                @imm.shift = 0
                @imm.imm12 = @imm.number
            else if (@imm.number and 0x0FFF) = 0 & (@imm.number shr 12) < 0x1000
                @imm.shift = 1
                @imm.imm12 = @imm.number shr 12
            else if ec
                err 'immediate out of range'
            else
                @imm.success = 0
            end if
        end if
    else if @shf.kind = 0 & @shf.shift = 12
        if @imm.number >= 0
            @imm.inv = 0
            if @imm.number < 0x1000
                @imm.shift = 1
                @imm.imm12 = @imm.number
            else if ec
                err 'immediate out of range'
            else
                @imm.success = 0
            end if        
        else
            @imm.inv = 1
            @imm.number = -@imm.number
            if @imm.number < 0x1000
                @imm.shift = 1
                @imm.imm12 = @imm.number
            else if ec
                err 'immediate out of range'
            else
                @imm.success = 0
            end if
        end if
    else if ec
        err 'invalid immediate and shift'
    else
        @imm.success = 0
    end if
end macro


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; parsing registers and immediates ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro aarch64.parse_float ns
    ns.type = @type_immf
    if ns.data = 0.0
        ns.data = 00000000b
    else if ns.data = -1.0
        ns.data = 11110000b
    else if ns.data = 0.25
        ns.data = 01010000b
    else if ns.data = 0.5
        ns.data = 01100000b
    else if ns.data = 1.0
        ns.data = 01110000b
    else if ns.data = 1.5
        ns.data = 01111000b
    else if ns.data = 2.0
        ns.data = 00000000b
    else if ns.data = 2.5
        ns.data = 00000100b
    else if ns.data = 3.0
        ns.data = 00001000b
    else if ns.data = 4.0
        ns.data = 00010000b
    else if ns.data = 5.0
        ns.data = 00010100b
    else if ns.data = 8.0
        ns.data = 00100000b
    else if ns.data = 8.5
        ns.data = 00100001b
    else
        err 'float cannot be encoded'
    end if
end macro

macro aarch64.parse_immediate ns
    if ns.data eqtype 0.0
        aarch64.parse_float ns
    else if ns.data relativeto 0
        ns.type = @type_immc
    else
        ns.type = @type_immr
    end if
end macro

; err if y is not one of v0,...v31
macro aarch64.parse_voperand ns, y
    ns.data = +y
    if elementsof ns.data = 1 & ns.data eq ns.data element 1
        if ns.data metadata 1 relativeto aarch64.v128
            ns.data = ns.data metadata 1 - aarch64.v128
        else
            err 'invalid vector name'
        end if
    else
        err 'invalid vector name'
    end if
end macro


macro aarch64.parse_operand ns, x
    ns.type = 0
    match :y:z, x
        ns.data = +z
        match =lo12, y
            ns.type = @type_immc_lo12
        else match =abs_g0_nc, y
            ns.type = @type_immc_abs_g0_nc
        else match =abs_g1_nc, y
            ns.type = @type_immc_abs_g1_nc
        else match =abs_g2, y
            ns.type = @type_immc_abs_g2
        else match =pg_hi21, y
            ns.type = @type_immc_pg_hi21
        end match
        if ~(ns.data relativeto 0)
            ns.type = ns.type shl 1
        end if
    else match y.=16b, x
        ns.type = @type_vn_16b
        aarch64.parse_voperand ns, y
    else match y.=8b, x
        ns.type = @type_vn_8b
        aarch64.parse_voperand ns, y
    else match y.=8h, x
        ns.type = @type_vn_8h
        aarch64.parse_voperand ns, y
    else match y.=4h, x
        ns.type = @type_vn_4h
        aarch64.parse_voperand ns, y
    else match y.=4s, x
        ns.type = @type_vn_4s
        aarch64.parse_voperand ns, y
    else match y.=2s, x
        ns.type = @type_vn_2s
        aarch64.parse_voperand ns, y
    else match y.=2d, x
        ns.type = @type_vn_2d
        aarch64.parse_voperand ns, y
    else match y.=1d, x
        ns.type = @type_vn_1d
        aarch64.parse_voperand ns, y
    else match y.=b, x
        ns.type = @type_vn_b
        aarch64.parse_voperand ns, y
    else match y.=h, x
        ns.type = @type_vn_h
        aarch64.parse_voperand ns, y
    else match y.=s, x
        ns.type = @type_vn_s
        aarch64.parse_voperand ns, y
    else match y.=d, x
        ns.type = @type_vn_d
        aarch64.parse_voperand ns, y
    else match y.=b[i], x
        ns.type = @type_vn_bi
        ns.idx = +i
        aarch64.parse_voperand ns, y
    else match y.=h[i], x
        ns.type = @type_vn_hi
        ns.idx = +i
        aarch64.parse_voperand ns, y
    else match y.=s[i], x
        ns.type = @type_vn_si
        ns.idx = +i
        aarch64.parse_voperand ns, y
    else match y.=d[i], x
        ns.type = @type_vn_di
        ns.idx = +i
        aarch64.parse_voperand ns, y
    else
        ns.data = +x
        ns.number = 0
        if elementsof ns.data = 1 & ns.data eq ns.data element 1
            if ns.data metadata 1 relativeto aarch64.r64
                ns.data = ns.data metadata 1 - aarch64.r64
                if ns.data < 31
                    ns.type = @type_xn
                else if ns.data = 31
                    ns.type = @type_xzr
                else
                    ns.data = 31
                    ns.type = @type_xsp
                end if
            else if ns.data metadata 1 relativeto aarch64.r32
                ns.data = ns.data metadata 1 - aarch64.r32
                if ns.data < 31
                    ns.type = @type_wn
                else if ns.data = 31
                    ns.type = @type_wzr
                else
                    ns.data = 31
                    ns.type = @type_wsp
                end if
            else if ns.data metadata 1 relativeto aarch64.f64
                ns.data = ns.data metadata 1 - aarch64.f64
                ns.type = @type_dn
            else if ns.data metadata 1 relativeto aarch64.f32
                ns.data = ns.data metadata 1 - aarch64.f32
                ns.type = @type_sn
            else if ns.data metadata 1 relativeto aarch64.f128
                ns.data = ns.data metadata 1 - aarch64.f128
                ns.type = @type_qn
            else if ns.data metadata 1 relativeto aarch64.f8
                ns.data = ns.data metadata 1 - aarch64.f8
                ns.type = @type_bn
            else if ns.data metadata 1 relativeto aarch64.f16
                ns.data = ns.data metadata 1 - aarch64.f16
                ns.type = @type_hn
            else
                aarch64.parse_immediate ns
            end if
        else
            aarch64.parse_immediate ns
        end if
    end match
end macro



macro aarch64.parse_ext x
    @ext.empty = 0
    @ext.success = 1
    @ext.kind = 3
    @ext.shift = 0
    match , x
        @ext.empty = 1
    else match =lsl a, x
        @ext.shift = +a
    else match =uxtb a, x
        @ext.kind = 0
        @ext.shift = +a
    else match =uxth a, x
        @ext.kind = 1
        @ext.shift = +a
    else match =uxtw a, x
        @ext.kind = 2
        @ext.shift = +a
    else match =uxtx a, x
        @ext.kind = 3
        @ext.shift = +a
    else match =sxtb a, x
        @ext.kind = 4
        @ext.shift = +a
    else match =sxth a, x
        @ext.kind = 5
        @ext.shift = +a
    else match =sxtw a, x
        @ext.kind = 6
        @ext.shift = +a
    else match =sxtx a, x
        @ext.kind = 7
        @ext.shift = +a
    else match =uxtb, x
        @ext.kind = 0
    else match =uxth, x
        @ext.kind = 1
    else match =uxtw, x
        @ext.kind = 2
    else match =uxtx, x
        @ext.kind = 3
    else match =sxtb, x
        @ext.kind = 4
    else match =sxth, x
        @ext.kind = 5
    else match =sxtw, x
        @ext.kind = 6
    else match =sxtx, x
        @ext.kind = 7
    else
        @ext.success = 0
    end match
    if @ext.success & (~(@ext.shift relativeto 0) | @ext.shift < 0 | 4 < @ext.shift)
        @ext.success = 0
    end if
end macro

macro aarch64.parse_shf x
    @shf.empty = 0
    @shf.success = 1
    @shf.kind = 0
    @shf.shift = 0
    match , x
        @shf.empty = 1
    else match =lsl a, x
        @shf.kind = 0
        @shf.shift = +a
    else match =lsr a, x
        @shf.kind = 1
        @shf.shift = +a
    else match =asr a, x
        @shf.kind = 2
        @shf.shift = +a
    else match =ror a, x
        @shf.kind = 3
        @shf.shift = +a
    else
        @shf.success = 0
    end match
    if @shf.success & (~(@shf.shift relativeto 0) | @shf.shift < 0 | 64 <= @shf.shift)
        @shf.success = 0
    end if
end macro

macro aarch64.parse_con x
    @con.success = 1
    @cond.kind = -1
    match , x
        @con.success = 0
    else match =eq?, x
        @con.kind = 0
    else match =ne?, x
        @con.kind = 1
    else match =hs?, x
        @con.kind = 2
    else match =cs?, x
        @con.kind = 2
    else match =lo?, x
        @con.kind = 3
    else match =cc?, x
        @con.kind = 3
    else match =mi?, x
        @con.kind = 4
    else match =pl?, x
        @con.kind = 5
    else match =vs?, x
        @con.kind = 6
    else match =vc?, x
        @con.kind = 7
    else match =hi?, x
        @con.kind = 8
    else match =ls?, x
        @con.kind = 9
    else match =ge?, x
        @con.kind = 10
    else match =lt?, x
        @con.kind = 11
    else match =gt?, x
        @con.kind = 12
    else match =le?, x
        @con.kind = 13
    else match =al?, x
        @con.kind = 14
    else match =nv?, x
        @con.kind = 15
    else
        @con.success = 0
    end match    
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; the instruction set ;
;;;;;;;;;;;;;;;;;;;;;;;

include 'aarch64_ld_st_tb.inc'
include 'aarch64_done.inc'




macro add a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x11000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x91000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x0b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0x8b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x0b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0x8b200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0x8b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc_lo12)
        dd 0x11000000 + (        0 shl 30) + (         0 shl 22) + ((@op2.data and 0xFFF) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc_lo12)
        dd 0x91000000 + (        0 shl 30) + (         0 shl 22) + ((@op2.data and 0xFFF) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_16b_etc_no_1d) & (@op1.type and @type_vn_16b_etc_no_1d) & (@op2.type and @type_vn_16b_etc_no_1d) & (@op0.type = @op1.type) & (@op0.type = @op1.type) & (@ext.empty)
        dd 0x0e208400 + (@op2.data shl 16) + (((bsf @op0.type) and 4) shl 28) + (((bsf @op0.type) and 3) shl 22) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn) & (@ext.empty)
        dd 0x0e208400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immr_lo12)
        aarch64.reloc_add_lo12_nc @op2.data
        dd 0x91000000 + (        0 shl 30) + (         0 shl 22) + ((@op2.data and 0xFFF) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro



macro adrp a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = ((@op1.data-$$) shr 12) - (($-$$) shr 12)   ; assume $$ is divisible by 4096
            if -1 shl 20 <= @imm.number & @imm.number < 1 shl 20
                dd 0x90000000 + (@imm.number and 0x3) shl 29 + (((@imm.number and 0x1FFFFC) shr 2) shl 5) + (@op0.data shl 0)
            else
                err 'target is out of range'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro adr a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if -1 shl 20 <= @imm.number & @imm.number < 1 shl 20
                dd 0x10000000 + (@imm.number and 0x3) shl 29 + (((@imm.number shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
            else
                err 'target is out of range'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro and a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x12000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0x92000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x0a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0x8a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro ands a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x72000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0xf2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xea000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro asr a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc)
        if 0 <= @op2.data & @op2.data < 32
            dd 0x13007c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err, 'invalid shift amount'
        end if
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc)
        if 0 <= @op2.data & @op2.data < 64
            dd 0x9340fc00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err, 'invalid shift amount'
        end if
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro asrv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro lsl a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 31
        dd 0x53000000 + ((31 and -@op2.data) shl 16) + ((31 - @op2.data) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 63
        dd 0xd3400000 + ((63 and -@op2.data) shl 16) + ((63 - @op2.data) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro lslv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro lsr a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 31
        dd 0x53007c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 63
        dd 0xd340fc00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro lsrv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02400 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro ror a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 31
        dd 0x13800000 + (@op1.data shl 16) + (@op2.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc)
        aarch64.restrict @op2.data, 0, 63
        dd 0x93c00000 + (@op1.data shl 16) + (@op2.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro rorv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac02c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac02c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro b a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immr_immc)
        if @op0.data relativeto $
            @imm.number = @op0.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 27 <= @imm.number & @imm.number < 1 shl 27
                    dd 0x14000000 + (((@imm.number shr 2) and 0x3FFFFFF) shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand
    end if
end macro

iterate <instr,code>, beq,0x54000000, bne,0x54000001, bhs,0x54000002, blo,0x54000003,\
                      bmi,0x54000004, bpl,0x54000005, bvs,0x54000006, bvc,0x54000007,\
                      bhi,0x54000008, bls,0x54000009, bge,0x5400000a, blt,0x5400000b,\
                      bgt,0x5400000c, ble,0x5400000d, bal,0x5400000e, bnv,0x5400000f,\
                      bcs,0x54000002, bcc,0x54000003
	macro instr a*
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_immr_immc)
            if @op0.data relativeto $
                @imm.number = @op0.data - $
                if @imm.number and 0x03 = 0
                    if -1 shl 20 <= @imm.number & @imm.number < 1 shl 20
                        dd code + (((@imm.number shr 2) and 0x7FFFF) shl 5)
                    else
                        err 'target is out of range'
                    end if
                else
                    err 'target is misaligned'
                end if
            else
                err 'invalid target'
            end if
        else
            err 'invalid operand'
        end if
	end macro
end iterate


macro sbfx a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x13000000 + ((@op2.data and 0x1F) shl 16) + (((@op2.data+@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x93400000 + ((@op2.data and 0x3F) shl 16) + (((@op2.data+@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro


macro ubfx a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x53000000 + ((@op2.data and 0x1F) shl 16) + (((@op2.data+@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xd3400000 + ((@op2.data and 0x3F) shl 16) + (((@op2.data+@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro


macro bfi a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x33000000 + (((32-@op2.data) and 0x1F) shl 16) + (((@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xb3400000 + (((64-@op2.data) and 0x3F) shl 16) + (((@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro sbfiz a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x13000000 + (((32-@op2.data) and 0x1F) shl 16) + (((@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x93400000 + (((64-@op2.data) and 0x3F) shl 16) + (((@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro ubfiz a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x53000000 + (((32-@op2.data) and 0x1F) shl 16) + (((@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xd3400000 + (((64-@op2.data) and 0x3F) shl 16) + (((@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro bfm a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x33000000 + ((@op2.data and 0x1F) shl 16) + ((@op3.data and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xb3400000 + ((@op2.data and 0x3F) shl 16) + ((@op3.data and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro ubfm a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x53000000 + ((@op2.data and 0x1F) shl 16) + ((@op3.data and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xd3400000 + ((@op2.data and 0x3F) shl 16) + ((@op3.data and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro sbfm a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x13000000 + ((@op2.data and 0x1F) shl 16) + ((@op3.data and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x93400000 + ((@op2.data and 0x3F) shl 16) + ((@op3.data and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro bfxil a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x33000000 + ((@op2.data and 0x1F) shl 16) + (((@op2.data+@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0xb3400000 + ((@op2.data and 0x3F) shl 16) + (((@op2.data+@op3.data-1) and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro

macro bic a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x0a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0x8a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro bics a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xea200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro bl a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immr_immc)
        if @op0.data relativeto $
            @imm.number = @op0.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 27 <= @imm.number & @imm.number < 1 shl 27
                    dd 0x94000000 + (((@imm.number shr 2) and 0x3FFFFFF) shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand
    end if
end macro


macro blr? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_xzr)
        dd 0xd63f0000 + (@op0.data shl 5)
    else
        err 'invalid operand'
    end if
end macro

macro br? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_xzr)
        dd 0xd61f0000 + (@op0.data shl 5)
    else
        err 'invalid operand'
    end if
end macro

macro brk? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        if 0 <= @op0.data & @op0.data < 0x10000
            dd 0xd4200000 + (@op0.data shl 5)
        else
            err 'immediate out of range'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro cbnz a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 22 <= @imm.number & @imm.number < 1 shl 22
                    dd 0x35000000 + (((@imm.number shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
                    dd 0xb5000000 + (((@imm.number shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro cbz a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 20 <= @imm.number & @imm.number < 1 shl 20
                    dd 0x34000000 + (((@imm.number shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 20 <= @imm.number & @imm.number < 1 shl 20
                    dd 0xb4000000 + (((@imm.number shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand'
    end if
end macro




macro cinc a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_con           c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@con.success)
        dd 0x1a800400 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@con.success)
        dd 0x9a800400 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cls a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x5ac01400 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xdac01400 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro clz a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x5ac01000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xdac01000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cmn b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x31000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xb1000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x2b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xab000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x2b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0xab200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0xab200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cmp b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x31000000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xb1000000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xeb000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x6b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0xeb200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0xeb200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cneg a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_con           c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@con.success)
        dd 0x5a800400 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@con.success)
        dd 0xda800400 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro csel a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@con.success)
        dd 0x1a800000 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@con.success)
        dd 0x9a800000 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cset a*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@con.success)
        dd 0x1a800400 + ((@con.kind xor 1) shl 12) + (31 shl 16) + (31 shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@con.success)
        dd 0x9a800400 + ((@con.kind xor 1) shl 12) + (31 shl 16) + (31 shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro csetm a*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@con.success)
        dd 0x5a800000 + ((@con.kind xor 1) shl 12) + (31 shl 16) + (31 shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@con.success)
        dd 0xda800000 + ((@con.kind xor 1) shl 12) + (31 shl 16) + (31 shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro csinc a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@con.success)
        dd 0x1a800400 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@con.success)
        dd 0x9a800400 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro csinv a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@con.success)
        dd 0x5a800000 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@con.success)
        dd 0xda800000 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro cinv a*, b*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@con.success)
        dd 0x5a800000 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@con.success)
        dd 0xda800000 + ((@con.kind xor 1) shl 12) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro csneg a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@con.success)
        dd 0x5a800400 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@con.success)
        dd 0xda800400 + ((@con.kind) shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro eon a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x4a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xca200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro eor a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x52000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0xd2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x4a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xca000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_16b_etc) & (@op1.type and @type_vn_16b_etc) & (@op2.type and @type_vn_16b_etc) & (@op0.type = @op1.type) & (@op0.type = @op1.type)
        dd 0x2e201c00 + (@op2.data shl 16) + (((bsf @op0.type) and 4) shl 28) + (@op1.data shl 5) + (@op0.data shl 0)        
    else
        err 'invalid operand'
    end if
end macro

macro extr a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_immc)
        dd 0x13800000 + (@op2.data shl 16) + ((@op3.data and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op0.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@op3.type and @type_immc)
        dd 0x93c00000 + (@op2.data shl 16) + ((@op3.data and 0x3F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro




iterate <instr, code>, umsubl, 0x9ba08000,\
                       smsubl, 0x9b208000,\
                       smaddl, 0x9b200000,\
                       umaddl, 0x9ba00000
    macro instr a*, b*, c*, d*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        aarch64.parse_operand @op3, d
        if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_xn_xzr)
            dd code + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate



macro madd a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@op3.type and @type_xn_xzr)
        dd 0x9b000000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_wn_wzr)
        dd 0x1b000000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro msub a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@op3.type and @type_xn_xzr)
        dd 0x9b008000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_wn_wzr)
        dd 0x1b008000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro mov a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xaa000000 + (@op1.data shl 16) + (31 shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp)
        dd 0x91000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x2a000000 + (@op1.data shl 16) + (31 shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp)
        dd 0x11000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm32 @op1.data
        if (@imm.success) & (@op0.type and @type_wn)
            dd 0x12800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm32 @op1.data, 1
            dd 0x320003e0 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op0.data shl 0)
        end if
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm64 @op1.data
        if (@imm.success) & (@op0.type and @type_xn)
            dd 0x92800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm64 @op1.data, 1
            dd 0xb20003e0 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op0.data shl 0)
        end if
    else
        err 'invalid operand'
    end if
end macro

iterate <instr, code1, code2>, movk, 0x72800000, 0xf2800000,\
                               movn, 0x12800000, 0x92800000,\
                               movz, 0x52800000, 0xd2800000
    macro instr a*, b*, c
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_shf           c
        if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immc) & (@shf.success) & (@shf.kind = 0) & ((@shf.shift and 0x10) = @shf.shift)
            aarch64.restrict @op1.data, 0, 0xFFFF
            dd code1 + (@shf.shift shl 17) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immc) & (@shf.success) & (@shf.kind = 0) & ((@shf.shift and 0x30) = @shf.shift)
            aarch64.restrict @op1.data, 0, 0xFFFF
            dd code2 + (@shf.shift shl 17) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate

iterate <instr, code1, code2>, mul,  0x1b007c00, 0x9b007c00
    macro instr a*, b*, c*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
            dd code1 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
            dd code2 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate


iterate <instr, code>, smnegl, 0x9b20fc00,\
                       smull,  0x9b207c00,\
                       umull,  0x9ba07c00,\
                       umnegl, 0x9ba0fc00
    macro instr a*, b*, c*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
            dd code + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate




macro orr a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x32000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0xb2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x2a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xaa000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro orn a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x2a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xaa200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro mvn b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x2a200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xaa200000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro ret? a:x30
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_xzr)
        dd 0xD65F0000 + 32*@op0.data
    else
        err 'invalid operand'
    end if
end macro



macro sub a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x51000000 - (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xd1000000 - (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x4b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xcb000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x4b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0xcb200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0xcb200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_16b_etc_no_1d) & (@op1.type and @type_vn_16b_etc_no_1d) & (@op2.type and @type_vn_16b_etc_no_1d) & (@op0.type = @op1.type) & (@op0.type = @op1.type)
        dd 0x2e208400 + (@op2.data shl 16) + (((bsf @op0.type) and 4) shl 28) + (((bsf @op0.type) and 3) shl 22) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro neg b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x4b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xcb000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro negs b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xeb000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (31 shl 5) + (@op1.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

iterate <instr, code1, code2>, rbit,  0x5ac00000, 0xdac00000,\
                               rev,   0x5ac00800, 0xdac00c00,\
                               rev16, 0x5ac00400, 0xdac00400
    macro instr a*, b*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
            dd code1 + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
            dd code2 + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate

macro rev32 a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xdac00800 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro






macro svc? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        aarch64.restrict @op0.data, 0, 0xFFFF
        dd 0xD4000001 + (@op0.data shl 5)
    else
        err 'invalid operand'
    end if
end macro


macro tbnz a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr_xn_xzr) & (@op1.type and @type_immc) & (@op2.type and @type_immr_immc)
        if @op2.data relativeto $
            @imm.number = @op2.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 15 <= @imm.number & @imm.number < 1 shl 15
                    dd 0x37000000 + ((@op1.data and 0x20) shl 26) + ((@op1.data and 0x1F) shl 19) + (((@imm.number shr 2) and 0x3FFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand
    end if
end macro

macro tbz a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr_xn_xzr) & (@op1.type and @type_immc) & (@op2.type and @type_immr_immc)
        if @op2.data relativeto $
            @imm.number = @op2.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 15 <= @imm.number & @imm.number < 1 shl 15
                    dd 0x36000000 + ((@op1.data and 0x20) shl 26) + ((@op1.data and 0x1F) shl 19) + (((@imm.number shr 2) and 0x3FFF) shl 5) + (@op0.data shl 0)
                else
                    err 'target is out of range'
                end if
            else
                err 'target is misaligned'
            end if
        else
            err 'invalid target'
        end if
    else
        err 'invalid operand
    end if
end macro


macro tst b*, c*, d
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x72000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0xf2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6a000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xea000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (31 shl 0)
    else
        err 'invalid operand'
    end if
end macro


iterate <instr, code>, smulh, 0x9b407c00,\
                       umulh, 0x9bc07c00
    macro instr a*, b*, c*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
            dd code + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate






macro sxtw a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x93407c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro sxth a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x93403c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x13003c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro sxtb a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x93401c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x13001c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro uxtw a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x2a0003e0 + (@op1.data shl 16) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro




macro uxtb a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x53001c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro uxth a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x53003c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro fdiv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1e601800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fmul a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1e600800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x1e200800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fadd a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1e602800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fsub a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1e603800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fmadd a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1f400000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op2.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fmsub a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1f408000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op2.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fnmsub a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn)
        dd 0x1f608000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn) & (@op2.type and @type_sn)
        dd 0x00000000 + (@op2.data shl 16) + (@op2.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fcvtzs a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_dn)
        dd 0x1e780000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_dn)
        dd 0x9e780000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro fcvtzu a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_dn)
        dd 0x1e790000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_dn)
        dd 0x9e790000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro fcvtas a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_dn)
        dd 0x1e640000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_dn)
        dd 0x9e640000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro scvtf a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_xn_xzr)
        dd 0x9e620000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_wn_wzr)
        dd 0x1e620000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro ucvtf a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_xn_xzr)
        dd 0x9e630000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_wn_wzr)
        dd 0x1e630000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro


macro fmov a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_sn) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e604000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_wn_wzr)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_dn)
        dd 0x9e660000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_xn_xzr)
        dd 0x9e670000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_vn_di) & (@op1.idx = 1)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_di) & (@op0.idx = 1) & (@op1.type and @type_xn_xzr)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_immf)
        dd 0x1e601000 + (@op1.data shl 13) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_immf)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_2s) & (@op1.type and @type_immf)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_4s) & (@op1.type and @type_immf)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else if (@op0.type and @type_vn_2d) & (@op1.type and @type_immf)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro


macro fcmp a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x00000000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_immf)
        dd 0x1e602008 + (@op1.data shl 13) + (@op0.data shl 0)
    else
        err 'invalid operands'
    end if
end macro


macro fcmpe a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e602010 + (@op1.data shl 16) + (@op0.data shl 5)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else     
        err 'invalid operands'
    end if
end macro

macro fneg a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e614000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else     
        err 'invalid operands'
    end if
end macro

macro fabs a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e60c000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else     
        err 'invalid operands'
    end if
end macro

macro fsqrt a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e61c000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_sn) & (@op1.type and @type_sn)
        dd 0x00000000 + (@op1.data shl 13) + (@op0.data shl 0)
    else     
        err 'invalid operands'
    end if
end macro

macro fcsel a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_dn) & (@op1.type and @type_dn) & (@op2.type and @type_dn) & (@con.success)
        dd 0x1e600c00 + (@con.kind shl 12) + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid operand'
    end if
end macro

macro nop
    dd 0xd503201f
end macro

macro wfe a&
    dd 0xd503205f
end macro

macro wfi a&
    dd 0xd503207f
end macro

macro yield a&
    dd 0xd503203f
end macro

macro tlbi a*, b:xzr
    aarch64.parse_operand @op0, b
    match =alle1?, a
        dd 0xd50c8780 + (@op0.data shl 0)
    else match =aside1?, a
        dd 0xd5088740 + (@op0.data shl 0)
    else
        err 'invalid operand'
    end match
end macro

macro sev
    dd 0xd503209f
end macro

macro sevl
    dd 0xd50320bf
end macro

macro mrs a*, b*
    aarch64.parse_operand @op0, a
    match =actlr_el1?, b
        dd 0xd5381020 + (@op0.data shl 0)
    else match =vttbr_el2?, b
        dd 0xd53c2100 + (@op0.data shl 0)
    else match =spsel?, b
        dd 0xd5384200 + (@op0.data shl 0)
    else match =s3_2_c3_c4_5?, b
        dd 0xd53a34a0 + (@op0.data shl 0)
    else
        err 'invalid operand'
    end match
end macro

macro msr a*, b*
    aarch64.parse_operand @op0, b
    match =actlr_el1?, a
        dd 0xd5181020 + (@op0.data shl 0)
    else match =vttbr_el2?, a
        dd 0xd51c2100 + (@op0.data shl 0)
    else match =spsel?, a
        dd 0xd5184200 + (@op0.data shl 0)
    else match =s3_2_c3_c4_5?, a
        dd 0xd51a34a0 + (@op0.data shl 0)
    else
        err 'invalid operand'
    end match
end macro




macro hint a&
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        aarch64.restrict @op0.data, 0, 127
        dd 0xd503201f + (@op0.data shl 5)
    else
        err 'invalid operand'
    end if
end macro

macro eret
    dd 0xd69f03e0
end macro


;macro at a*, b*
;    aarch64.parse_operand @op0, b
;    if (@op0.type and @type_xn_xzr)
;        match =s12e0r?, a
;            dd 0xd50c78c0 + @op0.data
;        else match =s12e0w?, a
;            dd 0xd50c78e0 + @op0.data
;        else match =s12e1r?, a
;            dd 0xd50c7880 + @op0.data
;        else match =s12e1w?, a
;            dd 0xd50c78a0 + @op0.data
;        else match =s1e0r?, a
;            dd 0xd5087840 + @op0.data
;        else match =s1e0w?, a
;            dd 0xd5087860 + @op0.data
;        else match =s1e1r?, a
;            dd 0xd5087800 + @op0.data
;        else match =s1e1w?, a
;            dd 0xd5087820 + @op0.data
;        else match =s1e2r?, a
;            dd 0xd50c7800 + @op0.data
;        else match =s1e2w?, a
;            dd 0xd50c7820 + @op0.data
;        else match =s1e3r?, a
;            dd 0xd50e7800 + @op0.data
;        else match =s1e3w?, a
;            dd 0xd50e7820 + @op0.data
;        else
;            err 'invalid operand'
;        end match
;    else
;        err 'invalid operand'
;    end if
;end macro

macro dc a, b
    aarch64.parse_operand @op0, b
    if (@op0.type and @type_xn_xzr)
        match =cisw?, a
            dd 0xd5087e40 + @op0.data
        else match =civac?, a
            dd 0xd50b7e20 + @op0.data
        else match =csw?, a
            dd 0xd5087a40 + @op0.data
        else match =cvac?, a
            dd 0xd50b7a20 + @op0.data
        else match =cvau?, a
            dd 0xd50b7b20 + @op0.data
        else match =isw?, a
            dd 0xd5087640 + @op0.data
        else match =ivac?, a
            dd 0xd5087620 + @op0.data
        else match =zva?, a
            dd 0xd50b7420 + @op0.data
        else
            err 'invalid operand'
        end match
    else
        err 'invalid operand'
    end if
end macro

macro ic a, b:xzr
    aarch64.parse_operand @op0, b
    if (@op0.type and @type_xn_xzr)
        match =iallu?, a
            dd 0xd5087500 + @op0.data
        else match =ialluis?, a
            dd 0xd5087100 + @op0.data
        else match =ivau?, a
            dd 0xd50b7520 + @op0.data
        else
            err 'invalid operand'
        end match
    else
        err 'invalid operand'
    end if
end macro

macro isb a&
    dd 0xd5033fdf
end macro

macro dmb a&
    match =ish?, a
        dd 0xd5033bbf
    else match =ishld?, a
        dd 0xd50339bf
    else match =ishst?, a
        dd 0xd5033abf
    else match =ld?, a
        dd 0xd5033dbf
    else match =nsh?, a
        dd 0xd50337bf
    else match =nshld?, a
        dd 0xd50335bf
    else match =nshst?, a
        dd 0xd50336bf
    else match =osh?, a
        dd 0xd50333bf
    else match =oshld?, a
        dd 0xd50331bf
    else match =oshst?, a
        dd 0xd50332bf
    else match =st?, a
        dd 0xd5033ebf
    else match =sy?, a
        dd 0xd5033fbf
    else
        err 'invalid operand'
    end match
end macro

macro drps
    dd 0xd6bf03e0
end macro

macro dsb a&
    match =ish?, a
        dd 0xd5033b9f
    else match =ishld?, a
        dd 0xd503399f
    else match =ishst?, a
        dd 0xd5033a9f
    else match =ld?, a
        dd 0xd5033d9f
    else match =nsh?, a
        dd 0xd503379f
    else match =nshld?, a
        dd 0xd503359f
    else match =nshst?, a
        dd 0xd503369f
    else match =osh?, a
        dd 0xd503339f
    else match =oshld?, a
        dd 0xd503319f
    else match =oshst?, a
        dd 0xd503329f
    else match =st?, a
        dd 0xd5033e9f
    else match =sy?, a
        dd 0xd5033f9f
    else
        err 'invalid operand'
    end match
end macro

iterate <instr, code>, dcps1, 0xd4a00001, dcps2, 0xd4a00002, dcps3, 0xd4a00003,\
                       hlt, 0xd4400000, hvc, 0xd4000002, smc, 0xd4000003
    macro instr a:0
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_immc)
            aarch64.restrict @op0.data, 0, 0xFFFF
            dd code + (@op0.data shl 5)
        else
            err 'invalid operand'
        end if
    end macro
end iterate

macro clrex a:15
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        aarch64.restrict @op0.data, 0, 0xF
        dd 0xd503305f + (@op0.data shl 8)
    else
        err 'invalid operand'
    end if
end macro












; Vd, Vn  - 2S or 4S
iterate <instr, code1, code2>, ursqrte, 0x00000000, 0x00000000,\
                               urecpe,  0x00000000, 0x00000000
    macro instr a*, b*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_vn_2s) & (@op1.type and @type_vn_2s)
            dd code1 + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_vn_4s) & (@op1.type and @type_vn_4s)
            dd code2 + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if        
    end macro
end iterate












