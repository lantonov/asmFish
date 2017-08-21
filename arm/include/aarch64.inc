
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
define @ext
define @shf
define @imm


@type_empty    = 00000000000001b
@type_wsp      = 00000000000010b
@type_wn       = 00000000000100b
@type_wzr      = 00000000001000b
@type_xsp      = 00000000010000b
@type_xn       = 00000000100000b
@type_xzr      = 00000001000000b
@type_immc     = 00000100000000b
;@type_shift  = 00010000000000b
;@type_extd   = 00100000000000b

@type_xn_or_xsp  = @type_xn or @type_xsp
@type_xn_or_xzr  = @type_xn or @type_xzr
@type_wn_or_wsp  = @type_wn or @type_wsp
@type_wn_or_wzr  = @type_wn or @type_wzr
@type_wn_or_wzr_xn_xzr = @type_wn_or_wzr or @type_xn_or_xzr

;@type_empty_or_shift  = @type_shift or @type_empty
@type_immr_or_immc = @type_immr or @type_immc

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
macro aarch64.parse_bimm64 x
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
        if c <> 0
            if a = 0
                clz_a = 64
            else 
                clz_a = 63 - bsr a    
            end if
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
end macro

macro aarch64.parse_bimm32 x
    aarch64.parse_bimm64 0x100000001*(x and 0xFFFFFFFF)
    if x > 0xFFFFFFFF
        @imm.success = 0
    else if x < -0x80000000
        @imm.success = 0
    end if
end macro


; err if x can be encoded as a arithmetic immediate
macro aarch64.parse_aimm x
    @imm.number = +x
    assert @imm.number relativeto 0
    if @imm.number >= 0
        @imm.inv = 0
        if @imm.number < 0x1000
            @imm.shift = 0
            @imm.imm12 = @imm.number
        else if (@imm.number and 0x0FFF) = 0 & (@imm.number shr 12) < 0x1000
            @imm.shift = 1
            @imm.imm12 = @imm.number shr 12
        end if        
    else if
        @imm.inv = 1
        @imm.number = -@imm.number
        if @imm.number < 0x1000
            @imm.shift = 0
            @imm.imm12 = @imm.number
        else if (@imm.number and 0x0FFF) = 0 & (@imm.number shr 12) < 0x1000
            @imm.shift = 1
            @imm.imm12 = @imm.number shr 12
        end if
    else
        err 'immediate out of range'
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
    else match =lsl a, x
        @ext.kind = 0
        @ext.shift = +a
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
    else
        @shf.success = 0
    end match
    if @shf.success & (~(@shf.shift relativeto 0) | @shf.shift < 0 | 64 <= @shf.shift)
        @shf.success = 0
    end if
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; the instruction set ;
;;;;;;;;;;;;;;;;;;;;;;;


macro adr a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if (@op0.type and @type_xn_or_xzr) & (@op1.type and @type_immr_or_immc)
        if @op1.data relativeto $
            if -1 shl 20 <= @op1.data-$ & @op1.data-$ < 1 shl 20
                dd 0x10000000 + ((@op1.data-$) and 0x3) shl 29 + ((((@op1.data-$) shr 2) and 0x7FFFF) shl 5) + (@op0.data shl 0)
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

macro mov a*, b*
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    if @op0.type = 'r32' & @op1.type = 'r32'
        err 'not implemented'
    else if @op0.type = 'r64' & @op1.type = 'r64'
        err 'not implemented'
    else if @op0.type = 'r32' & @op1.type = 'imm'
        err 'not implemented'
    else if (@op0.type and @type_xn_or_xsp) & (@op1.type and @type_immc)
        aarch64.parse_uimm64 @op1.data
        if @imm.success
            dd 0x92800000 + ((@imm.inv xor 1) shl 30) + (@imm.shift shl 21) + (@imm.imm16 shl 5) + (@op0.data shl 0)
        else
            aarch64.parse_bimm64 @src.number
            if @imm.success
                dd 0xB2000000 + (@imm.n shl 22) + (@imm.r shl 16) + (@imm.s shl 10) + (31 shl 5) + (@op0.data shl 0)
            else
                err 'immediate cannot be encoded'
            end if
        end if
    else
        err 'invalid operands'
    end if
end macro




macro add a*, b*, c*, d
    aarch64.parse_operand @op0, a
    aarch64.parse_operand @op1, b
    aarch64.parse_operand @op2, c
    aarch64.parse_ext           d
    aarch64.parse_shf           d
;ADD Wd|WSP, Wn|WSP, #aimm
    if (@op0.type and @type_wn_or_wsp) & (@op1.type and @type_wn_or_wsp) & (@op2.type and @type_immc) & (@ext.empty)
        aarch64.parse_aimm @op2.data
        dd 0x11000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
;ADD Xd|SP, Xn|SP, #aimm
    else if (@op0.type and @type_xn_or_xsp) & (@op1.type and @type_xn_or_xsp) & (@op2.type and @type_immc) & (@ext.empty)
        aarch64.parse_aimm @op2.data
        dd 0x91000000 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
;ADD Wd, Wn, Wm{, ashift #imm}
    else if (@op0.type and @type_wn_or_wzr) & (@op1.type and @type_wn_or_wzr) & (@op2.type and @type_wn_or_wzr) & (@shf.success)
        dd 0x0b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
;ADD Xd, Xn, Xm{, ashift #imm}
    else if (@op0.type and @type_xn_or_xzr) & (@op1.type and @type_xn_or_xzr) & (@op2.type and @type_xn_or_xzr) & (@shf.success)
        dd 0x8b000000 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
;ADD Wd|WSP, Wn|WSP, Wm, extend {#imm}
    else if (@op0.type and @type_wn_or_wsp) & (@op1.type and @type_wn_or_wsp) & (@op2.type and @type_wn_or_wzr) & (@ext.success)
        dd 0x0b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
;ADD Xd|SP, Xn|SP, Wm, extend {#imm}
;ADD Xd|SP, Xn|SP, Xm{, UXTX|LSL #imm}
    else if (@op0.type and @type_xn_or_xsp) & (@op1.type and @type_xn_or_xsp) & (@op2.type and @type_wn_or_wzr) & (@ext.empty)
        dd 0x8b200000 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type and @type_xn_or_xsp) & (@op1.type and @type_xn_or_xsp) & (@op2.type and @type_wn_or_wzr_xn_xzr) & (@ext.success)
        dd 0x8b200000 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
    else
        err 'invalid argument'
    end if
end macro

macro ret? a:x30
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_xn_or_xzr)
        dd 0xD65F0000 + 32*@op0.data
    else
        err 'invalid operand'
    end if
end macro

macro svc? a*
    aarch64.parse_operand @op0, a
    if (@op0.type and @type_immc)
        if 0 <= @op0.data & @op0.data < 0x10000
            dd 0xD4000001 + 32*@op0.data
        else
            err 'immediate out of range'
        end if
    else
        err 'invalid operand'
    end if
end macro



