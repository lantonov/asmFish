.macro RookAttacks X, Sq, Occ, T, S
       adrp  S, RookAttacksSTUFF
        add  S, S, :lo12:RookAttacksSTUFF
        add  S, S, Sq, lsl 3
        ldr  T, [S, RookAttacksPEXT - RookAttacksSTUFF]
        and  T, T, Occ
        ldr  X, [S, RookAttacksMOFF - RookAttacksSTUFF]
        ldr  S, [S, RookAttacksIMUL - RookAttacksSTUFF]
        mul  T, T, S
        lsr  T, T, 64-12
        ldr  X, [X, T, lsl 3]
.endm

.macro BishopAttacks X, Sq, Occ, T, S
       adrp  S, BishopAttacksSTUFF
        add  S, S, :lo12:BishopAttacksSTUFF
        add  S, S, Sq, lsl 3
        ldr  T, [S, BishopAttacksPEXT - BishopAttacksSTUFF]
        and  T, T, Occ
        ldr  X, [S, BishopAttacksMOFF - BishopAttacksSTUFF]
        ldr  S, [S, BishopAttacksIMUL - BishopAttacksSTUFF]
        mul  T, T, S
        lsr  T, T, 64-9
        ldr  X, [X, T, lsl 3]
.endm

