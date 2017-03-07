
BitTable_Init:
/*
	       push   rbx rsi rdi r12 r13 r14 r15
*/
        stp  x29, x30, [sp, -16]!
        stp  x27, x28, [sp, -16]!
/*
		mov   ecx, 64*64*2*64
	       call   _VirtualAlloc
	       push   rax
*/
        mov  x1, 64*64*2*64
         bl  Os_VirtualAlloc
        mov  x29, x0

Init_KPKTable:

/*
tn    equ r15
wp    equ r14
wk    equ r13
bk    equ r12
un    equ r11
u     equ r10
to    equ r9
cnt   equ rsi
ocnt  equ rdi


macro KPKEndgameTableOffset res,TN,WP,WK,BK {
		mov   res, WP
		shl   res, 6
		add   res, WK
		shl   res, 6
		add   res, BK
		shl   res, 1
		add   res, TN
		add   res, qword[rsp]
}
*/

tnc .req x26
tn .req x25
wp .req x24
wpb .req x14
wk .req x23
wkb .req x13
bk .req x22
bkb .req x12
to .req x7
un .req x8
u .req x9
ncnt .req x10
ocnt .req x11

.macro KPKOffset Res, Tn, Wp, Wk, Bk
        add  Res, Wk, Wp, lsl 6
        add  Res, Bk, Res, lsl 6
        add  Res, Tn, Res, lsl 1
.endm

// KPKEndgameTable[WhitePawn-8][WhiteKing] is a qword
// bit 2*BlackKing+0 is set if win for white to move
// bit 2*BlackKing+1 is set if win for black to move

/*
                ; use hash table for uncompressed data
		mov   rdi, qword[rsp]
		mov   ecx, (64*64*2*64)/8
		xor   eax, eax
	  rep stosq
		; clear space for compressed data
		lea   rdi, [KPKEndgameTable]
		mov   ecx, 48*64
		xor   eax, eax
	  rep stosq
*/

        lea  x28, KPKEndgameTable
        lea  x16, WhitePawnAttacks
        lea  x17, KingAttacks

        mov  x0, x28
        mov  x1, 0
        mov  x2, 48*64*8
         bl  MemoryFill
        mov  x0, x29
        mov  x1, 0
        mov  x2, 64*64*2*64
         bl  MemoryFill

/*
		xor   cnt, cnt
		lea   ocnt, [cnt+1]
.Start:
		cmp   cnt, ocnt
		 je   .End
		mov   ocnt, cnt
		xor   cnt, cnt

		xor   tn, tn
.TurnLoop:
		xor   wp, wp
 .WhitePawnLoop:
		xor   wk, wk
  .WhiteKingLoop:
		xor   bk, bk
   .BlackKingLoop:
*/

        mov  ncnt, 0
        mov  ocnt, 1
Init_KPKTable.Start:

	cmp  ncnt, ocnt
        beq  Init_KPKTable.End
	mov  ocnt, ncnt
	mov  ncnt, 0

	mov  tn, 0
Init_KPKTable.TurnLoop:
        eor  tnc, tn, 1
	mov  wp, 0
        mov  wpb, 1
Init_KPKTable.WhitePawnLoop:
	mov  wk, 0
        mov  wkb, 1
Init_KPKTable.WhiteKingLoop:
	mov  bk, 0
        mov  bkb, 1
Init_KPKTable.BlackKingLoop:
/*
KPKEndgameTableOffset	rbx, tn, wp, wk, bk
		cmp   byte[rbx], 0
		jne   Init_KPKTable.Continue
*/
        KPKOffset x21, tn, wp, wk, bk
       ldrb  w0, [x29, x21]
       cbnz  w0, Init_KPKTable.Continue
/*
		add   cnt, 1
		cmp   wp, 8
		 jb   .Draw
		cmp   wp, 56
		jae   .Draw
		cmp   wp, wk
		 je   .Draw
		cmp   wk, bk
		 je   .Draw
		cmp   bk, wp
		 je   .Draw
*/
        add  ncnt, ncnt, 1
        cmp  wp, 8
        blo  Init_KPKTable.Draw
        cmp  wp, 56
        bhs  Init_KPKTable.Draw
        cmp  wp, wk
        beq  Init_KPKTable.Draw
        cmp  wk, bk
        beq  Init_KPKTable.Draw
        cmp  bk, wp
        beq  Init_KPKTable.Draw
/*
	; is white pawn attacking black king ?
		mov   rax, qword[WhitePawnAttacks+8*wp]
		 bt   rax, bk
		jnc   .CheckTurn
	; is it white's turn ?
		cmp   tn,0
		 je   .Draw
	; it is blacks turn - can black king leagally capture pawn ?
		mov   rax, qword[KingAttacks+8*wk]
		 bt   rax, wp
		jnc   .Draw
*/
        ldr  x0, [x16, wp, lsl 3]
        ldr  x1, [x17, wk, lsl 3]
        tst  x0, bkb
        beq  Init_KPKTable.CheckTurn
        cbz  tn, Init_KPKTable.Draw
        tst  x1, wpb
        beq  Init_KPKTable.Draw        

Init_KPKTable.CheckTurn:
/*
		xor   un, un
		cmp   tn, 0
		 je   .WhiteToMove
*/
        mov  un, 0
        cbz  tn, Init_KPKTable.WhiteToMove

Init_KPKTable.BlackToMove:
/*
		mov   rax, qword[KingAttacks+8*bk]
		mov   u, qword[KingAttacks+8*wk]
		 or   u, qword[WhitePawnAttacks+8*wp]
	       andn   u, u, rax
	       test   u, u
		 jz   Init_KPKTable.Draw
*/
        ldr  x0, [x17, bk, lsl 3]
        ldr  u, [x17, wk, lsl 3]
        ldr  x4, [x16, wp, lsl 3]
        orr  u, u, x4
        bic  u, x0, u
        cbz  u, Init_KPKTable.Draw

Init_KPKTable.BlackMoveLoop:
/*
		bsf   to, u

		xor   tn, 1
KPKEndgameTableOffset	rcx, tn, wp, wk, to
		xor   tn, 1

		cmp   byte[rcx], 1
		 je   Init_KPKTable.Draw
		adc   un, 0
	       blsr   u, u, r8
		jnz   Init_KPKTable.BlackMoveLoop

	       test   un, un
		 jz   Init_KPKTable.Win
		jmp   Init_KPKTable.Continue
*/
       rbit  to, u
        clz  to, to
        KPKOffset x1, tnc, wp, wk, to
       ldrb  w4, [x29, x1]
        cmp  x4, 1
        beq  Init_KPKTable.Draw
       cinc  un, un, lo
        sub  x4, u, 1
        and  u, u, x4
       cbnz  u, Init_KPKTable.BlackMoveLoop
        cbz  un, Init_KPKTable.Win
          b  Init_KPKTable.Continue

Init_KPKTable.WhiteToMove:
/*
		mov   rax, qword[KingAttacks+8*wk]
		mov   u, qword[KingAttacks+8*bk]
		bts   u, wp
	       andn   u, u, rax
	       test   u,u
		 jz   .WhiteMoveLoopDone
*/
        ldr  x0, [x17, wk, lsl 3]
        ldr  u, [x17, bk, lsl 3]
        orr  u, u, wpb
       bics  u, x0, u
        beq  Init_KPKTable.WhiteMoveLoopDone
        
Init_KPKTable.WhiteMoveLoop:
/*
		bsf   to, u
		xor   tn, 1
KPKEndgameTableOffset	rcx, tn, wp, to, bk
		xor   tn, 1
		cmp   byte[rcx], 1
		 ja   .Win
		adc   un, 0
	       blsr   u, u, r8
		jnz   .WhiteMoveLoop
*/
       rbit  to, u
        clz  to, to
        KPKOffset x1, tnc, wp, to, bk
       ldrb  w4, [x29, x1]
        cmp  x4, 1
        bhi  Init_KPKTable.Win
       cinc  un, un, lo
        sub  x4, u, 1
        and  u, u, x4
       cbnz  u, Init_KPKTable.WhiteMoveLoop

Init_KPKTable.WhiteMoveLoopDone:
/*
		lea   to, [wp+8]
		cmp   to, wk
		 je   .WhiteMoveDone
		cmp   to, bk
		 je   .WhiteMoveDone
		cmp   to, 56
		jae   .PromCheck
		xor   tn, 1
  KPKEndgameTableOffset   rcx,tn,to,wk,bk
		xor   tn, 1
		cmp   byte[rcx], 1
		 ja   .Win
		adc   un, 0
		cmp   to, 24
		jae   .WhiteMoveDone
*/
        add  to, wp, 8
        cmp  to, wk
        beq  Init_KPKTable.WhiteMoveDone
        cmp  to, bk
        beq  Init_KPKTable.WhiteMoveDone
        cmp  to, 56
        bhs  Init_KPKTable.PromCheck
        KPKOffset x1, tnc, to, wk, bk
       ldrb  w4, [x29, x1]
        cmp  x4, 1
        bhi  Init_KPKTable.Win
       cinc  un, un, lo
        cmp  to, 24
        bhs  Init_KPKTable.WhiteMoveDone
        
Init_KPKTable.DoubleCheck:
/*
		add   to, 8
		cmp   to, wk
		 je   .WhiteMoveDone
		cmp   to, bk
		 je   .WhiteMoveDone
		xor   tn, 1
KPKEndgameTableOffset	rcx, tn, to, wk, bk
		xor   tn, 1
		cmp   byte[rcx], 1
		 ja   .Win
		adc   un, 0
		jmp   .WhiteMoveDone
*/
        add  to, to, 8
        cmp  to, wk
        beq  Init_KPKTable.WhiteMoveDone
        cmp  to, bk
        beq  Init_KPKTable.WhiteMoveDone
        KPKOffset x1, tnc, to, wk, bk 
       ldrb  w4, [x29, x1]
        cmp  x4, 1
        bhi  Init_KPKTable.Win
       cinc  un, un, lo
          b  Init_KPKTable.WhiteMoveDone

Init_KPKTable.PromCheck:
/*
		mov   rax, qword[KingAttacks+8*to]
		 bt   rax, bk
		jnc   .Win
		 bt   rax, wk
		 jc   .Win
*/
        ldr  x0, [x17, to, lsl 3]
        tst  x0, bkb
        beq  Init_KPKTable.Win
        tst  x0, wkb
        bne  Init_KPKTable.Win

Init_KPKTable.WhiteMoveDone:
/*
	       test   un, un
		jnz   .Continue
*/
       cbnz  un, Init_KPKTable.Continue 

Init_KPKTable.Draw:
/*
		mov   byte[rbx], 1
		jmp   .Continue
*/
        mov  x4, 1
       strb  w4, [x29, x21]
          b  Init_KPKTable.Continue

Init_KPKTable.Win:
/*
	; record the win in uncompressed table
		mov   byte[rbx], 2
	; record the win in compressed table
		cmp   wp, 8
		 jb   .Continue
		cmp   wp, 56
		jae   .Continue

		mov   rcx, bk
		 bt   ecx, 2
		 jc   .Continue

		mov   rcx, tn
		xor   ecx, 1
		lea   ecx, [bk+4*rcx]

		lea   rdx, [wp-8]
		shl   rdx, 6
		add   rdx, wk
		mov   rax, qword[KPKEndgameTable+8*rdx]
		bts   rax, rcx
		mov   qword[KPKEndgameTable+8*rdx], rax
*/

        mov  x4, 2
       strb  w4, [x29, x21]
        cmp  wp, 8
        blo  Init_KPKTable.Continue
        cmp  wp, 56
        bhs  Init_KPKTable.Continue
        tst  bk, 4
        bne  Init_KPKTable.Continue
        mov  x3, 1
        eor  x1, tn, 1
        add  x1, bk, x1, lsl 2
        lsl  x3, x3, x1
        sub  x2, wp, 8
        add  x2, wk, x2, lsl 6
        ldr  x0, [x28, x2, lsl 3]
        orr  x0, x0, x3
        str  x0, [x28, x2, lsl 3]


        

Init_KPKTable.Continue:
/*
		add   bk, 1
		cmp   bk, 64
		 jb   .BlackKingLoop
		add   wk, 1
		cmp   wk, 64
		 jb   .WhiteKingLoop
		add   wp, 1
		cmp   wp, 64
		 jb   .WhitePawnLoop
		add   tn, 1
		cmp   tn, 2
		 jb   .TurnLoop
	       test   cnt,cnt
		jnz   .Start
*/
        add  bk, bk, 1
        lsl  bkb, bkb, 1
        tbz  bk, 6, Init_KPKTable.BlackKingLoop
        add  wk, wk, 1
        lsl  wkb, wkb, 1
        tbz  wk, 6, Init_KPKTable.WhiteKingLoop
        add  wp, wp, 1
        lsl  wpb, wpb, 1
        tbz  wp, 6, Init_KPKTable.WhitePawnLoop
        add  tn, tn, 1
        tbz  tn, 1, Init_KPKTable.TurnLoop
       cbnz  ncnt, Init_KPKTable.Start

Init_KPKTable.End:
/*
		pop   rcx
		mov   edx, 64*64*2*64
	       call   _VirtualFree
		pop   r15 r14 r13 r12 rdi rsi rbx
		ret
*/
        mov  x1, x29
        mov  x2, 64*64*2*64
         bl  Os_VirtualFree
        ldp  x27, x28, [sp], 16
        ldp  x29, x30, [sp], 16
        ret

.unreq tnc
.unreq tn
.unreq wp
.unreq wpb
.unreq wk
.unreq wkb
.unreq bk
.unreq bkb
.unreq un
.unreq u
.unreq ncnt
.unreq ocnt

