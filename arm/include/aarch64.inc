
define aarch64


element aarch64.r32
element aarch64.r64
element sp

repeat 31, i:0
        element w#i? : aarch64.r32 + i
        element x#i? : aarch64.r64 + i
end repeat
element wzr : aarch64.r32 + 31
element xzr : aarch64.r64 + 31

define @des
define @src
define @aux

macro use64
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; immediate encodings ;
;;;;;;;;;;;;;;;;;;;;;;;

define @imm

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; parsing registers and immediates ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro aarch64.parse_operand ns, oper
    ns.type = 'udef'
    ns.op = +oper
    ns.number = 0
    if elementsof ns.op = 1 & ns.op eq ns.op element 1
        if ns.op metadata 1 relativeto aarch64.r64
            ns.type = 'r64'
            ns.number = ns.op metadata 1 - aarch64.r64
        else if ns.op metadata 1 relativeto aarch64.r32
            ns.type = 'r32'
            ns.number = ns.op metadata 1 - aarch64.r32
        else if ns.op relativeto sp & ns.op = sp
            ns.type = 'sp'        
            ns.number = 31
        end if
    else if ns.op relativeto 0
        ns.type = 'imm'
        ns.number = ns.op
    else
        err 'invalid operand in parse'
    end if
end macro


;;;;;;;;;;;;;;;;;;;;;;;
; the instruction set ;
;;;;;;;;;;;;;;;;;;;;;;;

macro mov des*, src*
	aarch64.parse_operand @des, des
	aarch64.parse_operand @src, src
    if @des.type = 'r32' & @src.type = 'r32'
        err 'not implemented'
    else if @des.type = 'r64' & @src.type = 'r64'
        err 'not implemented'
    else if @des.type = 'r32' & @src.type = 'imm'
        err 'not implemented'
    else if (@des.type = 'r64' | @des.type = 'sp') & @src.type = 'imm'
        aarch64.parse_uimm64 @src.number
        if @imm.success
            dd 0x92800000 + (@imm.inv xor 1) shl 30 + @imm.shift shl 21 + @imm.imm16 shl 5 + @des.number
        else
            aarch64.parse_bimm64 @src.number
            if @imm.success
                dd 0xB2000000 + @imm.n shl 22 + @imm.r shl 16 + @imm.s shl 10 + 31 shl 5 + @des.number
            else
                err 'immediate cannot be encoded'
            end if
        end if
    else
        err 'invalid operands'
    end if
end macro

macro ret? src:x30
	aarch64.parse_operand @src, src
    if @src.type = 'r64'
        dd 0xD65F0000 + 32*@src.number
    else
        err 'invalid operand'
    end if
end macro

macro svc? src
	aarch64.parse_operand @src, src
    if @src.type = 'imm'
        if 0 <= @src.number & @src.number < 0x10000
            dd 0xD4000001 + 32*@src.number
        else
            err 'immediate out of range'
        end if
    else
        err 'invalid operand'
    end if
end macro



