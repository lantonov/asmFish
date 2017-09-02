
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

@type_vn_1q   = 1 shl 62


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

@type_vn_2s_4s = @type_vn_2s or @type_vn_4s
@type_vn_4h_8h = @type_vn_4h or @type_vn_8h
@type_vn_2s_4s_2d = @type_vn_2s or @type_vn_4s or @type_vn_2d
@type_vn_si_di = @type_vn_si or @type_vn_di

@type_vn_hi_si = @type_vn_hi or @type_vn_si

@type_vn_4h_8h_2s_4s = @type_vn_4h or @type_vn_8h or @type_vn_2s or @type_vn_4s
@type_vn_8b_16b = @type_vn_8b or @type_vn_16b

@type_vn_8b_16b_4h_8h_2s_4s = @type_vn_8b or @type_vn_16b or @type_vn_4h or @type_vn_8h or @type_vn_2s or @type_vn_4s

@type_vn_b_etc = @type_vn_b or @type_vn_h or @type_vn_s or @type_vn_d
@type_vn_bi_etc = @type_vn_bi or @type_vn_hi or @type_vn_si or @type_vn_di

@type_vn = @type_vn_16b_etc or @type_vn_b_etc
@type_vn_all_b = @type_vn_16b or @type_vn_8b
@type_vn_all_h = @type_vn_8h or @type_vn_4h
@type_vn_all_s = @type_vn_4s or @type_vn_2s
@type_vn_all_bhs = @type_vn_all_b or @type_vn_all_h or @type_vn_all_s

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
@type_bn_hn_sn  = @type_bn or @type_hn or @type_sn

@type_bn_hn_sn_dn  = @type_bn or @type_hn or @type_sn or @type_dn



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


macro aarch64.reloc_movk_g0 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g1 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g2 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_movk_g3 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ld_lo19 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_adr_lo21 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_adrp_pghi21 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_add_lo12 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_ldst_lo12 size, x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_tstbr14 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_condbr19 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_jump26 x
    err 'relocation macro not implemented'
end macro

macro aarch64.reloc_call26 x
    err 'relocation macro not implemented'
end macro

macro aarch64.restrict x, lower, upper, mask:0
    if ((x) and (mask)) <> 0 | (x) < (lower) | (x) > (upper)
        err 'value is out of range'
    end if
end macro

include 'aarch64_parse.inc'
include 'aarch64_ld_st_tb.inc'
include 'aarch64_done.inc'
include 'aarch64_float.inc'



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
        aarch64.restrict @op0.data, 0, 0xFFFF
        dd 0xd4200000 + (@op0.data shl 5)
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
    else if (@op0.type and @type_vn_16b_etc) & (@op0.type = @op1.type)
        dd 0x0ea01c00 + ((@op0.vt and 4) shl 28) + (@op1.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
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
    else if (@op0.type and @type_vn_16b_etc_no_1d) & (@op0.type = @op1.type) & (@op0.type = @op1.type)
        dd 0x2e208400 + (@op2.data shl 16) + (((bsf @op0.type) and 4) shl 28) + (((bsf @op0.type) and 3) shl 22) + (@op1.data shl 5) + (@op0.data shl 0)
    else if (@op0.type = @type_dn) & (@op0.type = @op1.type) & (@op0.type = @op2.type) & (@ext.empty)
        dd 0x00000000 + (@op2.data shl 16) + (@op1.data shl 5) + (@op0.data shl 0)
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












