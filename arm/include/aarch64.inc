
define aarch64


element aarch64.r32
element aarch64.r64
element aarch64.f32
element aarch64.f64
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
    element s#i : aarch64.f32 + i
    element d#i : aarch64.f64 + i
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


@type_empty     = 1 shl 0
@type_wsp       = 1 shl 1
@type_wn        = 1 shl 2
@type_wzr       = 1 shl 3
@type_xsp       = 1 shl 4
@type_xn        = 1 shl 5
@type_xzr       = 1 shl 6
@type_xn_xsp  = @type_xn or @type_xsp
@type_xn_xzr  = @type_xn or @type_xzr
@type_wn_wsp  = @type_wn or @type_wsp
@type_wn_wzr  = @type_wn or @type_wzr
@type_wn_wzr_xn_xzr = @type_wn_wzr or @type_xn_xzr

@type_dn        = 1 shl 7
@type_sn        = 1 shl 8

@type_vn_8b   = 1 shl 9
@type_vn_4h   = 1 shl 10
@type_vn_2s   = 1 shl 11
@type_vn_1d   = 1 shl 12
@type_vn_16b  = 1 shl 13
@type_vn_8h   = 1 shl 14
@type_vn_4s   = 1 shl 15
@type_vn_2d   = 1 shl 16
@type_vn_b   = 1 shl 17
@type_vn_h   = 1 shl 18
@type_vn_s   = 1 shl 19
@type_vn_d   = 1 shl 20

@type_vn_16b_etc = @type_vn_16b or @type_vn_8b or @type_vn_8h or @type_vn_4h or @type_vn_4s or @type_vn_2s or @type_vn_2d or @type_vn_1d
@type_vn_b_etc = @type_vn_b or @type_vn_h or @type_vn_s or @type_vn_d
@type_vn = @type_vn_16b_etc or @type_vn_b_etc

@type_immf           = 1 shl 22
@type_immc           = 1 shl 24
@type_immc_lo12      = 1 shl 26
@type_immc_gp_hi21   = 1 shl 28
@type_immc_abs_g2    = 1 shl 30
@type_immc_abs_g1_nc = 1 shl 32
@type_immc_abs_g0_nc = 1 shl 34
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

macro use64
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; immediate encodings ;
;;;;;;;;;;;;;;;;;;;;;;;

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
    else if ns.data = 1.0
        ns.data = 01110000b
    else if ns.data = -1.0
        ns.data = 11110000b
    else if ns.data = 0.25
        ns.data = 01010000b
    else if ns.data = 0.5
        ns.data = 01100000b
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
            else
                aarch64.parse_immediate ns

;                if ns.data relativeto 0
;                    ns.type = @type_immc
;                else
;                    ns.type = @type_immr
;                end if
            end if
        else
            aarch64.parse_immediate ns
;            if ns.data eqtype 0.0
;                aarch64.parse_foperand
;            elseif ns.data relativeto 0
;                ns.type = @type_immc
;            else
;                ns.type = @type_immr
;            end if
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

macro aarch64.parse_adr x&
    match [a=,b=,c], x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b        
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_wn_wzr_xn_xzr)
            @adr.type = @atype_register
            @adr.n = @op0.data
            @adr.m = @op1.data
            @adr.shift = -1
            match =lsl d, c
                @adr.kind = 1
                @adr.shift = +d
            else match =uxtw, c
                @adr.kind = 0
            else match =sxtw, c
                @adr.kind = 4
            else match =uxtw d, c
                @adr.kind = 0
                @adr.shift = +d
            else match =sxtw d, c
                @adr.kind = 4
                @adr.shift = +d
            else
                err 'invalid extension in address'
            end match
        else
            err 'invalid address 1'
        end if
    else match [a=,b], x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
            @adr.type = @atype_simple
            @adr.n = @op0.data
            @adr.imm = @op1.data
        else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xzr)
            @adr.type = @atype_register
            @adr.n = @op0.data
            @adr.m = @op1.data
            @adr.kind = 1
            @adr.shift = -1
        else
            err 'invalid address 2'
        end if
    else match [a], x
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_xn_xsp)
            @adr.type = @atype_simple
            @adr.n = @op0.data
            @adr.imm = 0
        else
            err 'invalid address 3'
        end if
    else match [a=,b]!, x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
            @adr.type = @atype_preincr
            @adr.n = @op0.data
            @adr.imm = @op1.data
        else
            err 'invalid address 41'
        end if
    else match [a]=,b, x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
            @adr.type = @atype_postincr
            @adr.n = @op0.data
            @adr.imm = @op1.data
        else
            err 'invalid address 5'
        end if
    else
        @adr.type = @atype_literal
        @adr.imm = +x
    end match
end macro


macro aarch64.parse_adr_f1 size, x&
    @adr.mask = (1 shl size) - 1
    match [a=,b=,c], x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b        
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_wn_wzr_xn_xzr)
            ;@adr.type = @atype_register
            @adr.shift = -1
            match =lsl d, c
                @adr.kind = 1
                @adr.shift = +d
            else match =uxtw, c
                @adr.kind = 0
            else match =sxtw, c
                @adr.kind = 4
            else match =uxtw d, c
                @adr.kind = 0
                @adr.shift = +d
            else match =sxtw d, c
                @adr.kind = 4
                @adr.shift = +d
            else
                err 'invalid extension in address'
            end match
            if @adr.shift = size
                @adr.encode = 0x00205800 + (@adr.kind shl 13) + (@opB.data shl 16) + (@opA.data shl 5)
            else if @adr.shift = -1
                @adr.encode = 0x00204800 + (@adr.kind shl 13) + (@opB.data shl 16) + (@opA.data shl 5)
            else
                err 'invalid shift amount'
            end if
        else
            err 'invalid address'
        end if
    else match [a=,b], x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            ;@adr.type = @atype_simple
            if (@opB.data and @adr.mask) = 0 & (0 <= @opB.data) & ((@opB.data shr size) <= 0xFFF)
                @adr.encode = 0x01000000 + (((@opB.data shr size) and 0xFFF) shl 10) + (@opA.data shl 5)
            else if (-256 <= @opB.data) & (@opB.data < 256)
                @adr.encode = ((@opB.data and 0x1FF) shl 12) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'     
            end if
        else if (@opA.type and @type_xn_xsp) & (@opB.type and @type_xn_xzr)
            ;@adr.type = @atype_register
            @adr.encode = 0x00206800 + (@opB.data shl 16) + (@opA.data shl 5)
        else if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc_lo12)
            ;@adr.type = @atype_simple
            if (@opB.data and @adr.mask) = 0
                @adr.encode = 0x01000000 + (((@opB.data and 0xFFF) shr size) shl 10) + (@opA.data shl 5)
            else
                err 'immediate offset unaligned'     
            end if
        else
            err 'invalid address'
        end if
    else match [a], x
        aarch64.parse_operand @opA, a
        if (@opA.type and @type_xn_xsp)
            ;@adr.type = @atype_simple
            @adr.encode = 0x01000000 + (@opA.data shl 5)
        else
            err 'invalid address 3'
        end if
    else match [a=,b]!, x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            ;@adr.type = @atype_preincr
            if -256 <= @opB.data & @opB.data < 256
                @adr.encode = 0x00000c00 + ((@opB.data and 0x1FF) shl 12) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 42'
        end if
    else match [a]=,b, x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            if -256 <= @opB.data & @opB.data <= 255
                @adr.encode = 0x00000400 + ((@opB.data and 0x1FF) shl 12) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 5'
        end if
    else
        ;@adr.type = @atype_literal
        @adr.imm = +x
        if @adr.imm relativeto $
            @adr.imm = @adr.imm - $
            if (@adr.imm and 0x03 = 0) & (-1 shl 20 <= @adr.imm & @adr.imm < 1 shl 20)
                @adr.encode = -0xA0400000 + (((@adr.imm and 0x1FFFFF) shr 2) shl 5)
            else
                err 'literal out of range or unaligned'
            end if
        else
            err 'invalid literal'
        end if

    end match
end macro

macro aarch64.parse_adr_f2 size, x&
    @adr.mask = (1 shl size) - 1
    match [a=,b], x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            if (-256 shl size) <= @opB.data & @opB.data <= (255 shl size)
                @adr.encode = 0x01000000 + (((@opB.data and 0x3FF) shr size) shl 15) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'     
            end if
        else
            err 'invalid address'
        end if
    else match [a], x
        aarch64.parse_operand @opA, a
        if (@opA.type and @type_xn_xsp)
            @adr.encode = 0x01000000 + (@opA.data shl 5)
        else
            err 'invalid address 3'
        end if
    else match [a=,b]!, x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            if (-256 shl size) <= @opB.data & @opB.data <= (255 shl size)
                @adr.encode = 0x01800000 + (((@opB.data and 0x3FF) shr size) shl 15) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 43'
        end if
    else match [a]=,b, x
        aarch64.parse_operand @opA, a
        aarch64.parse_operand @opB, b
        if (@opA.type and @type_xn_xsp) & (@opB.type and @type_immc)
            if (-256 shl size) <= @opB.data & @opB.data <= (255 shl size)
                @adr.encode = 0x00800000 + (((@opB.data and 0x3FF) shr size) shl 15) + (@opA.data shl 5)
            else
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 5'
        end if
    else
        err 'literal addressed not allowed'
    end match
end macro


macro aarch64.restrict x, lower, upper, mask:0
    if (x and mask) <> 0 | x < lower | x > upper
        err 'value is out of range'
    end if
end macro



;;;;;;;;;;;;;;;;;;;;;;;
; the instruction set ;
;;;;;;;;;;;;;;;;;;;;;;;


macro ldrb a*, b&
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr)
        aarch64.parse_adr_f1 0, b
        dd 0x38400000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


macro strb a*, b&
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr)
        aarch64.parse_adr_f1 0, b
        dd 0x38000000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro strh a*, b&
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr)
        aarch64.parse_adr_f1 1, b
        dd 0x78000000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


macro ldrsb a*, b&
    aarch64.parse_operand @op0, a
    aarch64.parse_adr_f1 0, b
    if (@op0.type and @type_wn_wzr)
        dd 0x38c00000 + @adr.encode + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr)
        dd 0x38800000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


macro ldrh a*, b&
    aarch64.parse_operand @op0, a
    aarch64.parse_adr_f1 1, b
    if (@op0.type and @type_wn_wzr)
        dd 0x78400000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro ldrsh a*, b&
    aarch64.parse_operand @op0, a
    aarch64.parse_adr_f1 1, b
    if (@op0.type and @type_wn_wzr)
        dd 0x78c00000 + @adr.encode + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr)
        dd 0x78800000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro ldrsw a*, b&
    aarch64.parse_operand @op0, a
    aarch64.parse_adr_f1 2, b
    if (@op0.type and @type_xn_xzr)
        dd 0xb8800000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro




macro adc a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1a000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9a000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro adcs a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x3a000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0xba000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

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
        dd 0x11000000 + (       0 shl 30) + (         0 shl 22) + ((@op2.data and 0xFFF) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc_lo12)
        dd 0x91000000 + (       0 shl 30) + (         0 shl 22) + ((@op2.data and 0xFFF) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro adds a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x31000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xb1000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x2b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xab000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x2b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0xab200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0xab200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument
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
            err 'invalid argument'
        end if
	end macro
end iterate


macro sbfx a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_wn_wzr) & (@op0.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@op3.type and @type_immc)
        dd 0x00000000 + ((@op2.data and 0x1F) shl 16) + (((@op2.data+@op3.data-1) and 0x1F) shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument
    end if
end macro


macro blr? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_xzr)
        dd 0xd63f0000 + 32*@op0.data
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
        err 'invalid argument'
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
        err 'invalid argument'
    end if
end macro

macro ccmn a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@con.success)
        dd 0x3a400000 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@con.success)
        dd 0xba400000 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
        if @op1.data and 0x1F = @op1.data
            dd 0x3a400800 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else
            'immediate out of range'
        end if
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
        if @op1.data and 0x1F = @op1.data
            dd 0xba400800 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else
            'immediate out of range'
        end if
    else
        err 'invalid argument'
    end if
end macro

macro ccmp a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_con           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@con.success)
        dd 0x7a400000 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@con.success)
        dd 0xfa400000 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
        if @op1.data and 0x1F = @op1.data
            dd 0x7a400800 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else
            'immediate out of range'
        end if
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
        if @op1.data and 0x1F = @op1.data
            dd 0xfa400800 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else
            'immediate out of range'
        end if
    else
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
    else
        err 'invalid argument'
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

macro ldar a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x88dffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0xc8dffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro ldarb a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x08dffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro ldaxr a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x885ffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0xc85ffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro ldaxrb a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x085ffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro




macro umaddl a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_xn_xzr)
        dd 0x9ba00000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro
macro smaddl a*, b*, c*, d*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_operand @op3, d
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@op3.type and @type_xn_xzr)
        dd 0x9b200000 + (@op2.data shl 16) + (@op3.data shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


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
        err 'invalid argument'
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
        err 'invalid argument'
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
        dd 0x00000000 + (@op1.data shl 16) + (31 shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm32 @op1.data
        if @imm.success
            dd 0x12800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm32 @op1.data, 1
            dd 0x32000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (31 shl 5) + (@op0.data shl 0)
        end if
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm64 @op1.data
        if @imm.success
            dd 0x92800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm64 @op1.data, 1
            dd 0xB2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (31 shl 5) + (@op0.data shl 0)
        end if
    else
        err 'invalid operands'
    end if
end macro

macro movk a*, b*, c
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_shf           c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immc) & (@shf.success) & (@shf.kind = 0)
        if (0 <= @op1.data & @op1.data < 0x10000) & ((@shf.shift and 0x10) = @shf.shift)
            dd 0x72800000 + (@shf.shift shl 17) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'immedate out of range'
        end if

    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immc) & (@shf.success) & (@shf.kind = 0)
        if (0 <= @op1.data & @op1.data < 0x10000) & ((@shf.shift and 0x30) = @shf.shift)
            dd 0xf2800000 + (@shf.shift shl 17) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'immedate out of range'
        end if
    else
        err 'invalid parameter'
    end if
end macro


macro mul a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1b007c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9b007c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid parameter'
    end if
end macro


macro smull a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x9b207c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid parameter'
    end if
end macro



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
        err 'invalid argument'
    end if
end macro

macro orn a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wsp) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm32 @op2.data, 1
        dd 0x00000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc) & (@shf.empty)
        aarch64.parse_bimm64 @op2.data, 1
        dd 0x00000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x00000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0x00000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
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
        err 'invalid argument'
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


macro stlr a*, b&
    dd -1

end macro

macro stlrb a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x089ffc00 + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro stlxr a*, b*, c&
    aarch64.parse_adr           c
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x8800fc00 + (@op0.data shl 16) + (@adr.n shl 5) + (@op1.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_xn_xzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0xc800fc00 + (@op0.data shl 16) + (@adr.n shl 5) + (@op1.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro

macro stlxrb a*, b*, c&
    aarch64.parse_adr           c
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm = 0
            dd 0x0800fc00 + (@op0.data shl 16) + (@adr.n shl 5) + (@op1.data shl 0)
        else
            err 'immediate offset is not zero'
        end if
    else
        err 'invalid operand'
    end if
end macro




macro ldp a*, b*, c&
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        aarch64.parse_adr_f2 3, c
        dd 0xa8400000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        aarch64.parse_adr_f2 3, c
        dd 0x6c400000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        aarch64.parse_adr_f2 2, c
        dd 0x28400000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro ldpsw a*, b*, c&
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        aarch64.parse_adr_f2 3, c
        dd 0x68400000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro



macro stp a*, b*, c&
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        aarch64.parse_adr_f2 3, c
        dd 0xa8000000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        aarch64.parse_adr_f2 3, c
        dd 0x6c000000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        aarch64.parse_adr_f2 2, c
        dd 0x28000000 + @adr.encode + (@op1.data shl 10) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


macro ldr a*, b&
    aarch64.parse_operand @op0, a
    if @op0.type and @type_xn_xzr
        aarch64.parse_adr_f1 3, b
        dd 0xf8400000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_wn_wzr
        aarch64.parse_adr_f1 2, b
        dd 0xb8400000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_dn
        aarch64.parse_adr_f1 3, b
        dd 0xfc400000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_sn
        aarch64.parse_adr_f1 2, b
        dd 0x08400000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument
    end if
end macro

macro str a*, b&
    aarch64.parse_operand @op0, a
    if @op0.type and @type_xn_xzr
        aarch64.parse_adr_f1 3, b
        dd 0xf8000000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_wn_wzr
        aarch64.parse_adr_f1 2, b
        dd 0xb8000000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_dn
        aarch64.parse_adr_f1 3, b
        dd 0xfc000000 + @adr.encode + (@op0.data shl 0)
    else if @op0.type and @type_sn
        aarch64.parse_adr_f1 2, b
        dd 0x00000000 + @adr.encode + (@op0.data shl 0)
    else
        err 'invalid argument
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
        dd 0x51000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xd1000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
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
    else
        err 'invalid argument'
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
        err 'invalid argument'
    end if
end macro

macro rbit a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x5ac00000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xdac00000 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro rev a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr)
        dd 0x5ac00800 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr)
        dd 0xdac00c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro


macro subs a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0x71000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xf1000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
        dd 0x6b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
        dd 0xeb000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
        dd 0x00000000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
        dd 0x00000000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
        dd 0x00000000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro



macro svc? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        if 0 <= @op0.data & @op0.data < 0x10000
            dd 0xD4000001 + (@op0.data shl 5)
        else
            err 'immediate out of range'
        end if
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
        err 'invalid argument
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
        err 'invalid argument
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
        err 'invalid argument'
    end if
end macro



macro smulh a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9b407c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro umulh a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9bc07c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro udiv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac00800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac00800 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro sdiv a*, b*, c*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
        dd 0x9ac00c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
        dd 0x1ac00c00 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro




macro aarch64.parse_vstr3 x&
    match =[a=], x
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_xn_xsp)
            @adr.encode = @adr.encode + (@op0.data shl 5)
        else
            err 'invalid address A'
        end if
    else match =[a=]=,b , x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_xn)
            @adr.encode = 0x00800000 + @adr.encode + (@op1.data shl 16) + (@op0.data shl 5)
        else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
            @adr.encode = 0x00800000 + @adr.encode + (       31 shl 16) + (@op0.data shl 5)
        else
            err 'invalid address C'
        end if
    else
        err 'invalid address B'
    end match
end macro

macro aarch64.parse_vstr2 e&
    @adr.encode = @adr.encode + (@op0.data shl 0)
    if @adr.expectindex
        match =[i=]=,a , e
            @adr.number = +i
            if @adr.type and @type_vn_b
                @adr.encode = @adr.encode + 0x00000000
            else if @adr.type and @type_vn_h
                @adr.encode = @adr.encode + 0x00004000
                @adr.number = @adr.number shl 1
            else if @adr.type and @type_vn_s
                @adr.encode = @adr.encode + 0x00008000
                @adr.number = @adr.number shl 2
            else if @adr.type and @type_vn_d
                @adr.encode = @adr.encode + 0x00008400
                @adr.number = @adr.number shl 3
            else
                err 'internal error'
            end if
            @adr.encode = @adr.encode + ((@adr.number and 8) shl 27) + ((@adr.number and 7) shl 10)
            aarch64.parse_vstr3 a
        else
            err 'no index found'
        end match
    else
        @adr.number = (bsf @adr.type) - (bsf @type_vn_8b)
        @adr.encode = @adr.encode + ((@adr.number and 4) shl 28) + ((@adr.number and 3) shl 10)
        match =,a , e
            aarch64.parse_vstr3 a
        else
            err 'no index found'
        end match
    end if
end macro

macro aarch64.parse_vstr x&
    match ={a=,b=,c=,d=}e , x
        @adr.length = 4
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        aarch64.parse_operand @op3, d
        if @op0.type <> @op1.type | @op0.type <> @op2.type | @op0.type <> @op3.type
            err 'vector type mismatch'
        else if (@op0.type and @type_vn_16b_etc)
            @adr.expectindex = 0
            @adr.encode = @adr.encode4
        else if (@op0.type and @type_vn_b_etc)
            @adr.expectindex = 1
            @adr.encode = @adr.encode4i
        else
            err 'arguments are not vectors'
        end if
        @adr.type = @op0.type
        if (((@op1.data-@op0.data) and 31) <> 1) | (((@op2.data-@op0.data) and 31) <> 2) | (((@op3.data-@op0.data) and 31) <> 3)
            err 'arguments are not consecutive'
        end if
        aarch64.parse_vstr2 e
    else match ={a=,b=,c=}e , x
        @adr.length = 3
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        if @op0.type <> @op1.type | @op0.type <> @op2.type
            err 'vector type mismatch'
        else if (@op0.type and @type_vn_16b_etc)
            @adr.expectindex = 0
            @adr.encode = @adr.encode3
        else if (@op0.type and @type_vn_b_etc)
            @adr.expectindex = 1
            @adr.encode = @adr.encode3i
        else
            err 'arguments are not vectors'
        end if
        @adr.type = @op0.type
        if (((@op1.data-@op0.data) and 31) <> 1) | (((@op2.data-@op0.data) and 31) <> 2)
            err 'arguments are not consecutive'
        end if
        aarch64.parse_vstr2 e
    else match ={a=,b=}e , x
        @adr.length = 2
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if @op0.type <> @op1.type
            err 'vector type mismatch'
        else if (@op0.type and @type_vn_16b_etc)
            @adr.expectindex = 0
            @adr.encode = @adr.encode2
        else if (@op0.type and @type_vn_b_etc)
            @adr.expectindex = 1
            @adr.encode = @adr.encode2i
        else
            err 'arguments are not vectors'
        end if
        if (((@op1.data-@op0.data) and 31) <> 1)
            err 'arguments are not consecutive'
        end if
        @adr.type = @op0.type
        aarch64.parse_vstr2 e
    else match ={a=}e , x
        @adr.length = 1
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_vn_16b_etc)
            @adr.expectindex = 0
            @adr.encode = @adr.encode1
        else if (@op0.type and @type_vn_b_etc)
            @adr.expectindex = 1
            @adr.encode = @adr.encode1i
        else
            err 'arguments are not vectors'
        end if
        @adr.type = @op0.type
        aarch64.parse_vstr2 e
    else
        err 'invalid structure'
    end match        

end macro

macro st1 a&
    @adr.encode1  = 0x0c007000
    @adr.encode2  = 0x0c00a000
    @adr.encode3  = 0x0c006000
    @adr.encode4  = 0x0c002000
    @adr.encode1i = 0x0d000000
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro st2 a&
    @adr.encode1  = -1
    @adr.encode2  = 0x0c008000
    @adr.encode3  = -1
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = 0x0d200000
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro st3 a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = 0x0c004000
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = 0x0d002000
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro st4 a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = -1
    @adr.encode4  = 0x0c000000
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = 0x0d202000
    aarch64.parse_vstr a
    dd @adr.encode
end macro


macro ld1 a&
    @adr.encode1  = 0x0c407000
    @adr.encode2  = 0x0c40a000
    @adr.encode3  = 0x0c406000
    @adr.encode4  = 0x0c402000
    @adr.encode1i = 0x0d400000
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld2 a&
    @adr.encode1  = -1
    @adr.encode2  = 0x0c408000
    @adr.encode3  = -1
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = 0x0d600000
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld3 a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = 0x0c404000
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = 0x0d402000
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld4 a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = -1
    @adr.encode4  = 0x0c400000
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = 0x0d602000
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld1r a&
    @adr.encode1  = 0x0d40c000
    @adr.encode2  = -1
    @adr.encode3  = -1
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld2r a&
    @adr.encode1  = -1
    @adr.encode2  = 0x0d60c000
    @adr.encode3  = -1
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld3r a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = 0x0d40e000
    @adr.encode4  = -1
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro

macro ld4r a&
    @adr.encode1  = -1
    @adr.encode2  = -1
    @adr.encode3  = -1
    @adr.encode4  = 0x0d60e000
    @adr.encode1i = -1
    @adr.encode2i = -1
    @adr.encode3i = -1
    @adr.encode4i = -1
    aarch64.parse_vstr a
    dd @adr.encode
end macro



macro sxtw a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x93407c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro uxtw a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x2a0003e0 + (@op1.data shl 16) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro uxtb a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr_xn_xzr) & (@op1.type and @type_wn_wzr)
        dd 0x53001c00 + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
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
        err 'invalid argument'
    end if
end macro


macro fmov a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_dn) & (@op1.type and @type_dn)
        dd 0x1e604000 + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_immf)
        dd 0x1e601000 + (@op1.data shl 13) + (@op0.data shl 0)
    else if (@op0.type and @type_dn) & (@op1.type and @type_xn_xzr)
        dd 0x9e670000 + (@op1.data shl 5) + (@op0.data shl 0)
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
        err 'invalid argument'
    end if
end macro

