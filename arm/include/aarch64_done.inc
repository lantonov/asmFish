;these are completed mnemonics

iterate <instr, code1, code2>, adc, 0x1a000000, 0x9a000000,\
                               sbc, 0x5a000000, 0xda000000,\
                               sbcs, 0x7a000000, 0xfa000000,\
                               adcs, 0x3a000000, 0xba000000
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

iterate <instr, code1, code2, code3, code4>, ccmn, 0x3a400000, 0xba400000, 0x3a400800, 0xba400800,\
                                             ccmp, 0x7a400000, 0xfa400000, 0x7a400800, 0xfa400800
    macro instr a*, b*, c*, d*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        aarch64.parse_con           d
        if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_immc) & (@con.success)
            dd code1 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_immc) & (@con.success)
            dd code2 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
            aarch64.restrict @op1.data, 0, 31
            dd code3 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_immc) & (@op2.type and @type_immc) & (@con.success)
            aarch64.restrict @op1.data, 0, 31
            dd code4 + (@con.kind shl 12) + (@op1.data shl 16) + (@op0.data shl 5) + ((@op2.data and 0x0F) shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate

iterate <instr, c1, c2, c3, c4, c5, c6, c7>, adds, 0x31000000, 0xb1000000, 0x2b000000, 0xab000000, 0x2b200000, 0xab200000, 0xab200000,\
                                             subs, 0x71000000, 0xf1000000, 0x6b000000, 0xeb000000, 0x6b200000, 0xeb200000, 0xeb200000
    macro instr a*, b*, c*, d
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op1, b
        aarch64.parse_operand @op2, c
        aarch64.parse_ext           d
        aarch64.parse_shf           d
        if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_immc)
            aarch64.parse_aimm @op2.data, 1
            dd c1 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_immc)
            aarch64.parse_aimm @op2.data, 1
            dd c2 + (@imm.inv shl 30) + (@imm.shift shl 22) + (@imm.imm12 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr) & (@shf.success)
            dd c3 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr) & (@shf.success)
            dd c4 + (@shf.kind shl 22) + (@op2.data shl 16) + (@shf.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_wn_wzr) & (@op1.type and @type_wn_wsp) & (@op2.type and @type_wn_wzr) & (@ext.success)
            dd c5 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr) & (@ext.empty)
            dd c6 + (@op2.data shl 16) + (        2 shl 13) + (         0 shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op1.type and @type_xn_xsp) & (@op2.type and @type_wn_wzr_xn_xzr) & (@ext.success)
            dd c7 + (@op2.data shl 16) + (@ext.kind shl 13) + (@ext.shift shl 10) + (@op1.data shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate


iterate <instr, code1, code2>, mneg, 0x1b00fc00, 0x9b00fc00,\
                               sdiv, 0x1ac00c00, 0x9ac00c00,\
                               udiv, 0x1ac00800, 0x9ac00800
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

iterate <instr, code1, code2>, ngc,  0x5a000000, 0xda000000,\
                               ngcs, 0x7a000000, 0xfa000000
    macro instr a*, c*
        aarch64.parse_operand @op0, a
        aarch64.parse_operand @op2, c
        if (@op0.type and @type_wn_wzr) & (@op2.type and @type_wn_wzr)
            dd code1 + (@op2.data shl 16) + ( 31 shl 5) + (@op0.data shl 0)
        else if (@op0.type and @type_xn_xzr) & (@op2.type and @type_xn_xzr)
            dd code2 + (@op2.data shl 16) + ( 31 shl 5) + (@op0.data shl 0)
        else
            err 'invalid operand'
        end if
    end macro
end iterate

