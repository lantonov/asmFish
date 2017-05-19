/*
macro GetKeys r1, r2, wmat, bmat {

		xor   r1, r1
		xor   r2, r2

	ct#Pawn=0
	ct#Knight=0
	ct#Bishop=0
	ct#Rook=0
	ct#Queen=0
	ct#King=0
 irps p, wmat \{
		xor   r1, qword[Zobrist_Pieces+8*(64*(8*White+p)+ct\#p)]
		xor   r2, qword[Zobrist_Pieces+8*(64*(8*Black+p)+ct\#p)]
	ct\#p = ct\#p+1
 \}
	if ct#King <> 1
	  display 'bad wmat in get_keys'
	  display 13,10
	  err
	end if

	ct#Pawn=0
	ct#Knight=0
	ct#Bishop=0
	ct#Rook=0
	ct#Queen=0
	ct#King=0
 irps p, bmat \{
		xor   r1, qword[Zobrist_Pieces+8*(64*(8*Black+p)+ct\#p)]
		xor   r2, qword[Zobrist_Pieces+8*(64*(8*White+p)+ct\#p)]
	ct\#p = ct\#p+1
 \}
	if ct#King <> 1
	  display 'bad bmat in get_keys'
	  display 13,10
	  err
	end if


}
*/

.macro GetKeys Wp, Wn, Wb, Wr, Wq,  Bp, Bn, Bb, Br, Bq
        ldr  x0, [x28, 8*(64*King + 0)]
        ldr  x1, [x29, 8*(64*King + 0)]
        eor  x1, x1, x0
        mov  x2, x1
 picnt = 0
 .rept \Wp
        ldr  x0, [x28, 8*(64*Pawn + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x29, 8*(64*Pawn + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
 picnt = 0
 .rept \Bp
        ldr  x0, [x29, 8*(64*Pawn + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x28, 8*(64*Pawn + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr

 picnt = 0
 .rept \Wn
        ldr  x0, [x28, 8*(64*Knight + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x29, 8*(64*Knight + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
 picnt = 0
 .rept \Bn
        ldr  x0, [x29, 8*(64*Knight + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x28, 8*(64*Knight + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr

 picnt = 0
 .rept \Wb
        ldr  x0, [x28, 8*(64*Bishop + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x29, 8*(64*Bishop + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
 picnt = 0
 .rept \Bb
        ldr  x0, [x29, 8*(64*Bishop + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x28, 8*(64*Bishop + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr

 picnt = 0
 .rept \Wr
        ldr  x0, [x28, 8*(64*Rook + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x29, 8*(64*Rook + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
 picnt = 0
 .rept \Br
        ldr  x0, [x29, 8*(64*Rook + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x28, 8*(64*Rook + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr

 picnt = 0
 .rept \Wq
        ldr  x0, [x28, 8*(64*Queen + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x29, 8*(64*Queen + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
 picnt = 0
 .rept \Bq
        ldr  x0, [x29, 8*(64*Queen + picnt)]
        eor  x1, x1, x0
        ldr  x0, [x28, 8*(64*Queen + picnt)]
        eor  x2, x2, x0
  picnt = picnt + 1
 .endr
.endm


Endgame_Init:
// make sure all of our functions are registered with
//  EndgameEval_Map
//  EndgameScale_Map
//  EndgameEval_FxnTable
//  EndgameScale_FxnTable



/*
	       push   rbx rsi rdi

; eval
		lea   rbx, [EndgameEval_FxnTable]
		lea   rdi, [EndgameEval_Map]
*/
        stp  x29, x30, [sp, -16]!
        lea  x28, Zobrist_Pieces
        add  x29, x28, 8*64*8

        lea  x21, EndgameEval_FxnTable
        lea  x15, EndgameEval_Map

/*
	; these endgame fxns correspond to a specific material config
	;  and are added to the map
	    GetKeys   rcx, rdx, <King Pawn>, <King>
		lea   eax, [EndgameEval_KPK]
		mov   esi, EndgameEval_KPK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,0,0,0,0, 0,0,0,0,0
        adr  x0, EndgameEval_KPK
        mov  x14, EndgameEval_KPK_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Knight Knight>, <King>
		lea   eax, [EndgameEval_KNNK]
		mov   esi, EndgameEval_KNNK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,2,0,0,0, 0,0,0,0,0
        adr  x0, EndgameEval_KNNK
        mov  x14, EndgameEval_KNNK_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Bishop Knight>, <King>
		lea   eax, [EndgameEval_KBNK]
		mov   esi, EndgameEval_KBNK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,1,1,0,0, 0,0,0,0,0
        adr  x0, EndgameEval_KBNK
        mov  x14, EndgameEval_KBNK_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook>, <King Pawn>
		lea   eax, [EndgameEval_KRKP]
		mov   esi, EndgameEval_KRKP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,0,0,1,0, 1,0,0,0,0
        adr  x0, EndgameEval_KRKP
        mov  x14, EndgameEval_KRKP_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook>, <King Bishop>
		lea   eax, [EndgameEval_KRKB]
		mov   esi, EndgameEval_KRKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,0,0,1,0, 0,0,1,0,0
        adr  x0, EndgameEval_KRKB
        mov  x14, EndgameEval_KRKB_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook>, <King Knight>
		lea   eax, [EndgameEval_KRKN]
		mov   esi, EndgameEval_KRKN_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,0,0,1,0, 0,1,0,0,0
        adr  x0, EndgameEval_KRKN
        mov  x14, EndgameEval_KRKN_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Queen>, <King Pawn>
		lea   eax, [EndgameEval_KQKP]
		mov   esi, EndgameEval_KQKP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,0,0,0,1, 1,0,0,0,0
        adr  x0, EndgameEval_KQKP
        mov  x14, EndgameEval_KQKP_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Queen>, <King Rook>
		lea   eax, [EndgameEval_KQKR]
		mov   esi, EndgameEval_KQKR_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 0,0,0,0,1, 0,0,0,1,0
        adr  x0, EndgameEval_KQKR
        mov  x14, EndgameEval_KQKR_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert

/*
	     Assert   ne, byte[rdi+(ENDGAME_EVAL_MAP_SIZE-1)*sizeof.EndgameMapEntry+EndgameMapEntry.entri], 0, 'problem1 in Endgame_Init'


	; these endgame fxns correspond to many material config
	;  and are not added to the map
		lea   eax, [EndgameEval_KXK]
		mov   r8d, EndgameEval_KXK_index
		mov   dword[rbx+4*r8], eax
*/
        adr  x0, EndgameEval_KXK
        mov  x14, EndgameEval_KXK_index
        str  x0, [x21, x14, lsl 3]

/*
; scale
		lea   rbx, [EndgameScale_FxnTable]
		lea   rdi, [EndgameScale_Map]
*/
        lea  x21, EndgameScale_FxnTable
        lea  x15, EndgameScale_Map
/*
	; these endgame fxns correspond to a specific material config
	;  and are added to the map
	    GetKeys   rcx, rdx, <King Knight Pawn>, <King>
		lea   eax, [EndgameScale_KNPK]
		mov   esi, EndgameScale_KNPK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,1,0,0,0, 0,0,0,0,0
        adr  x0, EndgameScale_KNPK
        mov  x14, EndgameScale_KNPK_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Knight Pawn>, <King Bishop>
		lea   eax, [EndgameScale_KNPKB]
		mov   esi, EndgameScale_KNPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,1,0,0,0, 0,0,1,0,0
        adr  x0, EndgameScale_KNPKB
        mov  x14, EndgameScale_KNPKB_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook Pawn>, <King Rook>
		lea   eax, [EndgameScale_KRPKR]
		mov   esi, EndgameScale_KRPKR_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,0,0,1,0, 0,0,0,1,0
        adr  x0, EndgameScale_KRPKR
        mov  x14, EndgameScale_KRPKR_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook Pawn>, <King Bishop>
		lea   eax, [EndgameScale_KRPKB]
		mov   esi, EndgameScale_KRPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,0,0,1,0, 0,0,1,0,0
        adr  x0, EndgameScale_KRPKB
        mov  x14, EndgameScale_KRPKB_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Bishop Pawn>, <King Bishop>
		lea   eax, [EndgameScale_KBPKB]
		mov   esi, EndgameScale_KBPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,0,1,0,0, 0,0,1,0,0
        adr  x0, EndgameScale_KBPKB
        mov  x14, EndgameScale_KBPKB_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Bishop Pawn>, <King Knight>
		lea   eax, [EndgameScale_KBPKN]
		mov   esi, EndgameScale_KBPKN_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 1,0,1,0,0, 0,1,0,0,0
        adr  x0, EndgameScale_KBPKN
        mov  x14, EndgameScale_KBPKN_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Bishop Pawn Pawn>, <King Bishop>
		lea   eax, [EndgameScale_KBPPKB]
		mov   esi, EndgameScale_KBPPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 2,0,1,0,0, 0,0,1,0,0
        adr  x0, EndgameScale_KBPPKB
        mov  x14, EndgameScale_KBPPKB_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	    GetKeys   rcx, rdx, <King Rook Pawn Pawn>, <King Rook Pawn>
		lea   eax, [EndgameScale_KRPPKRP]
		mov   esi, EndgameScale_KRPPKRP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert
*/
        GetKeys 2,0,0,1,0, 1,0,0,1,0
        adr  x0, EndgameScale_KRPPKRP
        mov  x14, EndgameScale_KRPPKRP_index
        str  x0, [x21, x14, lsl 3]
         bl  Endgame_Init.Map_Insert
/*
	     Assert   ne, byte[rdi+(ENDGAME_SCALE_MAP_SIZE-1)*sizeof.EndgameMapEntry+EndgameMapEntry.entri], 0, 'problem2 in Endgame_Init'

	; these endgame fxns correspond to many material config   except KPKP
	;  and are not added to the map
		lea   eax, [EndgameScale_KBPsK]
		mov   r8d, EndgameScale_KBPsK_index
		mov   dword[rbx+4*r8], eax

		lea   eax, [EndgameScale_KQKRPs]
		mov   r8d, EndgameScale_KQKRPs_index
		mov   dword[rbx+4*r8], eax

		lea   eax, [EndgameScale_KPsK]
		mov   r8d, EndgameScale_KPsK_index
		mov   dword[rbx+4*r8], eax

		lea   eax, [EndgameScale_KPKP]
		mov   r8d, EndgameScale_KPKP_index
		mov   dword[rbx+4*r8], eax
*/
        adr  x0, EndgameScale_KBPsK
        mov  x14, EndgameScale_KBPsK_index
        str  x0, [x21, x14, lsl 3]
        adr  x0, EndgameScale_KQKRPs
        mov  x14, EndgameScale_KQKRPs_index
        str  x0, [x21, x14, lsl 3]
        adr  x0, EndgameScale_KPsK
        mov  x14, EndgameScale_KPsK_index
        str  x0, [x21, x14, lsl 3]
        adr  x0, EndgameScale_KPKP
        mov  x14, EndgameScale_KPKP_index
        str  x0, [x21, x14, lsl 3]
/*
		lea   rsi, [.PushToEdges]
		lea   rdi, [PushToEdges]
		mov   ecx, 64
	  rep movsb
		lea   rsi, [.PushToCorners]
		lea   rdi, [PushToCorners]
		mov   ecx, 64
	  rep movsb
		lea   rsi, [.PushClose]
		lea   rdi, [PushClose]
		mov   ecx, 8
	  rep movsb
		lea   rsi, [.PushAway]
		lea   rdi, [PushAway]
		mov   ecx, 8
	  rep movsb
;                lea   rsi, [.KRPPKRPScaleFactors]
;                lea   rdi, [KRPPKRPScaleFactors]
;                mov   ecx, 8
;          rep movsb

*/
        lea  x0, PushToEdges
        adr  x1, Endgame_Init.PushToEdges
        mov  x2, 64
         bl  MemoryCopy
        lea  x0, PushToCorners
        adr  x1, Endgame_Init.PushToCorners
        mov  x2, 64
         bl  MemoryCopy
        lea  x0, PushClose
        adr  x1, Endgame_Init.PushClose
        mov  x2, 8
         bl  MemoryCopy
        lea  x0, PushAway
        adr  x1, Endgame_Init.PushAway
        mov  x2, 8
         bl  MemoryCopy

/*
		pop   rdi rsi rbx
		ret
*/
        ldp  x29, x30, [sp], 16
        ret

Endgame_Init.PushToEdges:
.byte  100, 90, 80, 70, 70, 80, 90, 100
.byte   90, 70, 60, 50, 50, 60, 70,  90
.byte   80, 60, 40, 30, 30, 40, 60,  80
.byte   70, 50, 30, 20, 20, 30, 50,  70
.byte   70, 50, 30, 20, 20, 30, 50,  70
.byte   80, 60, 40, 30, 30, 40, 60,  80
.byte   90, 70, 60, 50, 50, 60, 70,  90
.byte  100, 90, 80, 70, 70, 80, 90, 100


Endgame_Init.PushToCorners:
.byte    200, 190, 180, 170, 160, 150, 140, 130
.byte    190, 180, 170, 160, 150, 140, 130, 140
.byte    180, 170, 155, 140, 140, 125, 140, 150
.byte    170, 160, 140, 120, 110, 140, 150, 160
.byte    160, 150, 140, 110, 120, 140, 160, 170
.byte    150, 140, 125, 140, 140, 155, 170, 180
.byte    140, 130, 140, 150, 160, 170, 180, 190
.byte    130, 140, 150, 160, 170, 180, 190, 200


Endgame_Init.PushClose: .byte  0, 0, 100, 80, 60, 40, 20, 10
Endgame_Init.PushAway:  .byte  0, 5, 20, 40, 60, 80, 90, 100
//.KRPPKRPScaleFactors: db 0, 9, 10, 14, 21, 44, 0, 0

/*
.Map_Insert:
	; in: rcx hash with strongside=0
	;     rdx hash with strongside=1 (material flipped)
	;     esi  index of fxn
	;     rdi  address EndgameEval_Map or EndgameScale_Map
	;
	; we simply insert the two entries rcx and rdx into the assumed sorted
	;  array of EndgameMapEntry structs, sorted by key
	       push   rdx
		add   esi, esi
	       push   rsi
	       call   .Insert
		pop   rsi
		add   esi, 1
		pop   rcx
.Insert:
	; in: rcx key to insert
	;     esi entry
	       push   rdi
		sub   rdi, sizeof.EndgameMapEntry
.Next:
		add   rdi, sizeof.EndgameMapEntry
		mov   rax, qword[rdi+EndgameMapEntry.key]
		mov   edx, dword[rdi+EndgameMapEntry.entri]
	       test   edx, edx
		 jz   .AtEnd
	     Assert   ne, rax, rcx , 'assertion rax!=rcx failed in Endgame_Init: duplicate material keys'
		cmp   rcx, rax
		 ja   .Next
.Found:
		mov   rax, qword[rdi+EndgameMapEntry.key]
		mov   edx, dword[rdi+EndgameMapEntry.entri]
	       test   edx, edx
.AtEnd:
		mov   qword[rdi+EndgameMapEntry.key], rcx
		mov   dword[rdi+EndgameMapEntry.entri], esi
		mov   rcx, rax
		mov   esi, edx
		lea   rdi, [rdi+sizeof.EndgameMapEntry]
		jnz   .Found
		pop   rdi
		ret
*/

Endgame_Init.Map_Insert:
// in: x1 hash with strongside=0
//     x2 hash with strongside=1 (material flipped)
//     x14  index of fxn
//     x15  address EndgameEval_Map or EndgameScale_Map
// we simply insert the two entries rcx and rdx into the assumed
// sorted array of EndgameMapEntry structs, sorted by key
        stp  x29, x30, [sp, -16]!
        add  x14, x14, x14
        stp  x2, x14, [sp, -16]!
         bl  Endgame_Init.Insert
        ldp  x1, x14, [sp], 16
        add  x14, x14, 1
         bl  Endgame_Init.Insert        
        ldp  x29, x30, [sp], 16
        ret
Endgame_Init.Insert:
// in: x1 key to insert
//     x14 entry
        sub  x4, x15, sizeof.EndgameMapEntry
Endgame_Init.Next:
        ldp  x0, x2, [x4, sizeof.EndgameMapEntry]!
        cbz  x2, Endgame_Init.AtEnd
        cmp  x1, x0
        bhi  Endgame_Init.Next
Endgame_Init.Found:
        ldp  x0, x2, [x4]
Endgame_Init.AtEnd:
        stp  x1, x14, [x4], sizeof.EndgameMapEntry
        mov  x1, x0
        mov  x14, x2
       cbnz  x2, Endgame_Init.Found
	ret

