; The following macros assist with initilization and execution of the cuckoo tables in
; Position_Init.asm and Position.asm:

macro cuckoo_H1 rg1, rg2
    mov rg1, rg2
	and rg1, 0x1fff
end macro

macro cuckoo_H2 rg1, rg2
    mov rg1, rg2
	shr rg1, 16
	and rg1, 0x1fff
end macro

macro cuckoo_makeMove reg, fromSq, toSq
	mov reg, fromSq
	shl reg, 6 ; make room in register to pack in the toSquare
	or reg, toSq
end macro

macro cuckoo_moveFromSq reg, move
    mov reg, move
    shr reg, 6
    and reg, 0x03f
end macro

macro cuckoo_moveToSq reg, move
    mov reg, move
    and reg, 0x03f
end macro
