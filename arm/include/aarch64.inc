
define aarch64


element aarch64.r32
element aarch64.r64

repeat 31, i:0
        element w#i? : aarch64.r32 + i
        element x#i? : aarch64.r64 + i
end repeat
element wzr : aarch64.r32 + 31
element xzr : aarch64.r64 + 31
element wsp : aarch64.r32 + 32
element sp  : aarch64.r64 + 32

define @op0
define @op1
define @op2
define @op3
define @ext
define @shf
define @imm
define @con
define @adr


@type_empty    = 00000000000001b
@type_wsp      = 00000000000010b
@type_wn       = 00000000000100b
@type_wzr      = 00000000001000b
@type_xsp      = 00000000010000b
@type_xn       = 00000000100000b
@type_xzr      = 00000001000000b
@type_immc     = 00000100000000b
@type_immr     = 00001000000000b
@type_xn_xsp  = @type_xn or @type_xsp
@type_xn_xzr  = @type_xn or @type_xzr
@type_wn_wsp  = @type_wn or @type_wsp
@type_wn_wzr  = @type_wn or @type_wzr
@type_wn_wzr_xn_xzr = @type_wn_wzr or @type_xn_xzr
@type_immr_immc = @type_immr or @type_immc

@atype_simple    = 00000000001b
@atype_register  = 00000000010b
@atype_preincr   = 00000000100b
@atype_postincr  = 00000001000b
@atype_literal   = 00000010000b

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

macro aarch64.parse_uimm32 @imm, x
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
        @imm.number = @imm.number xor 0xFFFFFFFFFFFFFFFF
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

macro aarch64.parse_operand ns, x
    ns.type = 0
    ns.op = +x
    ns.number = 0
    if elementsof ns.op = 1 & ns.op eq ns.op element 1
        if ns.op metadata 1 relativeto aarch64.r64
            ns.data = ns.op metadata 1 - aarch64.r64
            if ns.data < 31
                ns.type = @type_xn
            else if ns.data = 31
                ns.type = @type_xzr
            else
                ns.data = 31
                ns.type = @type_xsp
            end if
        else if ns.op metadata 1 relativeto aarch64.r32
            ns.data = ns.op metadata 1 - aarch64.r32
            if ns.data < 31
                ns.type = @type_wn
            else if ns.data = 31
                ns.type = @type_wzr
            else
                ns.data = 31
                ns.type = @type_wsp
            end if
        end if
    else if ns.op relativeto 0
        ns.type = @type_immc
        ns.data = ns.op
    else
        ns.type = @type_immr
        ns.data = ns.op
    end if
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
            if @adr.imm < -256 | 255 < @adr.imm
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 4'
        end if
    else match [a]=,b, x
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
            @adr.type = @atype_postincr
            @adr.n = @op0.data
            @adr.imm = @op1.data
            if @adr.imm < -256 | 255 < @adr.imm
                err 'immediate offset out of range'
            end if
        else
            err 'invalid address 5'
        end if
    else
        @adr.type = @atype_literal
        @adr.imm = +x
    end match
end macro


macro ldr a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_postincr)
        dd 0xf8400400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_postincr)
        dd 0xb8400400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_preincr)
        dd 0xf8400c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_preincr)
        dd 0xb8400c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x07 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0xf9400000 + (((@adr.imm shr 3) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0xf8400000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'     
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x03 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0xb9400000 + (((@adr.imm shr 2) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0xb8400000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'
        end if
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_register)
        if @adr.shift = 3
            dd 0xf8605800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0xf8604800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_register)
        if @adr.shift = 2
            dd 0xb8605800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0xb8604800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else if (@op0.type and @type_xn_xzr) & (@adr.type and @atype_literal)
        if @adr.imm relativeto $
            @adr.imm = @adr.imm - $
            if (@adr.imm and 0x03 = 0) & (-1 shl 20 <= @adr.imm & @adr.imm < 1 shl 20)
                dd 0x58000000 + (((@adr.imm and 0x1FFFFF) shr 2) shl 5) + (@op0.data shl 0)
            else
                err 'literal out of range or unaligned'
            end if
        else
            err 'invalid literal'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_literal)
        if @adr.imm relativeto $
            @adr.imm = @adr.imm - $
            if (@adr.imm and 0x03 = 0) & (-1 shl 20 <= @adr.imm & @adr.imm < 1 shl 20)
                dd 0x18000000 + (((@adr.imm and 0x1FFFFF) shr 2) shl 5) + (@op0.data shl 0)
            else
                err 'literal out of range or unaligned'
            end if
        else
            'invalid literal'
        end if
    else
        err 'invalid argument'
    end if
end macro

macro ldrb a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_postincr)
        dd 0x38400400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_preincr)
        dd 0x38400c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x00 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0x39400000 + (((@adr.imm shr 0) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0x38400000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_register)
        if @adr.shift = 0
            dd 0x38605800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0x38604800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else
        err 'invalid argument'
    end if
end macro

macro ldrsb a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_postincr)
        dd 0x38c00400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_preincr)
        dd 0x38c00c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x00 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0x39c00000 + (((@adr.imm shr 0) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0x38c00000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_register)
        if @adr.shift = 0
            dd 0x38e05800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0x38e04800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else
        err 'invalid argument'
    end if
end macro


macro ldrh a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_postincr)
        dd 0x78400400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_preincr)
        dd 0x78400c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x01 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0x79400000 + (((@adr.imm shr 1) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0x78400000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_register)
        if @adr.shift = 1
            dd 0x78605800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0x78604800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else
        err 'invalid argument'
    end if
end macro

macro ldrsh a*, b&
    aarch64.parse_adr           b
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_postincr)
        dd 0x78c00400 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_preincr)
        dd 0x78c00c00 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_simple)
        if @adr.imm and 0x01 = 0 & 0 <= @adr.imm & @adr.imm < 1 shl 12
                dd 0x79c00000 + (((@adr.imm shr 1) and 0xFFF) shl 10) + (@adr.n shl 5) + (@op0.data shl 0)
        else if -1 shl 8 <= @adr.imm & @adr.imm < 1 shl 8
                dd 0x78c00000 + ((@adr.imm and 0x1FF) shl 12) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'immediate offset out of range'
        end if
    else if (@op0.type and @type_wn_wzr) & (@adr.type and @atype_register)
        if @adr.shift = 1
            dd 0x78e05800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else if @adr.shift = -1
            dd 0x78e04800 + (@adr.kind shl 13) + (@adr.m shl 16) + (@adr.n shl 5) + (@op0.data shl 0)
        else
            err 'invalid shift amount'
        end if
    else
        err 'invalid argument'
    end if
end macro



;;;;;;;;;;;;;;;;;;;;;;;
; the instruction set ;
;;;;;;;;;;;;;;;;;;;;;;;

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

macro b a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immr_immc)
        if @op0.data relativeto $
            @imm.number = @op0.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
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
                      bgt,0x5400000c, ble,0x5400000d, bal,0x5400000e, bnv,0x5400000f
	macro instr a*
        aarch64.parse_operand @op0, a
        if (@op0.type and @type_immr_immc)
            if @op0.data relativeto $
                @imm.number = @op0.data - $
                if @imm.number and 0x03 = 0
                    if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
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
            err 'invalid argument
        end if
	end macro
end iterate

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
                if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
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
                if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
                    dd 0x35000001 + (((@imm.number shr 2) and 0x7FFFF) shl 5)
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
                    dd 0xb5000001 + (((@imm.number shr 2) and 0x7FFFF) shl 5)
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

macro cbz a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immr_immc)
        if @op1.data relativeto $
            @imm.number = @op1.data - $
            if @imm.number and 0x03 = 0
                if -1 shl 28 <= @imm.number & @imm.number < 1 shl 28
                    dd 0x34000001 + (((@imm.number shr 2) and 0x7FFFF) shl 5)
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
                    dd 0xb4000001 + (((@imm.number shr 2) and 0x7FFFF) shl 5)
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

macro ccmn a*, b*, c*, d
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

macro ccmp a*, b*, c*, d
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


macro cinc a*, b*, c
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
        dd 0x71000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
    else if (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
        aarch64.parse_aimm @op2.data, 1
        dd 0xf1000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (31 shl 0)
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






macro mov a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if @op0.type = 'r32' & @op1.type = 'r32'
        err 'not implemented'
    else if @op0.type = 'r64' & @op1.type = 'r64'
        err 'not implemented'
    else if @op0.type = 'r32' & @op1.type = 'imm'
        err 'not implemented'
    else if (@op0.type and @type_xn_xsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm64 @op1.data
        if @imm.success
            dd 0x92800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm64 @src.number, 1
            dd 0xB2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (31 shl 5) + (@op0.data shl 0)
        end if
    else
        err 'invalid operands'
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



