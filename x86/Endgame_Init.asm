;the endgames.h and endgames.cpp are sloppy many different respects
; for a given material combination, say white has K+R+B verse black has K+N,
; we would like to see if we have a specialized evaluation function or scale function
;  and if so, fill it into the material entry
;
; the byte EndgameEntry.entry and its copies MaterialEntry.scalingFunction, MaterialEntry.evaluationFunction
;  holds the endgame entry
;  if this byte is 0, the entry is considered empty
;  if this byte is non zero
;   bit 0 is considered the strong side
;   bits 1-7 give an integer 1-127 used as an index into a fxn lookup table
;    this assumes that there are no more than 127 endgame types, which is reasonable
; when an endgame is called, this byte is put in ecx and then &ed with 1
;
; the same function would be used to handle KRBvKN as KNvKRB, so it is nec
; to use ecx to find out the strong side
;  ecx=0 for  KRBvKN,  ecx=1 for KNvKRB
;
; We build two global tables (not per-thread) of sorted material keys
;  one for evaluation functions and one for scale functions
; these are EndgameEval_Map and EndgameScale_Map
;
; There are also the global tables EndgameEval_FxnTable and EndgameScale_FxnTable
;  which hold the addresses of the functions
;  the index into this table is in bits 1-7 of EndgameEntry.entry
;  and the corresponding members of MaterialEntry


; we use the material key to identify the configuration
;  so it should be processed at run time

macro GetKeys r1, r2, wmat, bmat

		xor   r1, r1
		xor   r2, r2

	ct#Pawn=0
	ct#Knight=0
	ct#Bishop=0
	ct#Rook=0
	ct#Queen=0
	ct#King=0
 iterate p, wmat
		xor   r1, qword[Zobrist_Pieces+8*(64*(8*White+p)+ct#p)]
		xor   r2, qword[Zobrist_Pieces+8*(64*(8*Black+p)+ct#p)]
	ct#p = ct#p+1
 end iterate
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
 iterate p, bmat
		xor   r1, qword[Zobrist_Pieces+8*(64*(8*Black+p)+ct#p)]
		xor   r2, qword[Zobrist_Pieces+8*(64*(8*White+p)+ct#p)]
	ct#p = ct#p+1
 end iterate
	if ct#King <> 1
	  display 'bad bmat in get_keys'
	  display 13,10
	  err
	end if


end macro

Endgame_Init:
	; make sure all of our functions are registered with
	;   EndgameEval_Map
	;   EndgameScale_Map
	;   EndgameEval_FxnTable
	;   EndgameScale_FxnTable

	       push   rbx rsi rdi

; eval
		lea   rbx, [EndgameEval_FxnTable]
		lea   rdi, [EndgameEval_Map]

	; these endgame fxns correspond to a specific material config
	;  and are added to the map
	    GetKeys   rcx, rdx, <King, Pawn>, <King>
		lea   eax, [EndgameEval_KPK]
		mov   esi, EndgameEval_KPK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Knight, Knight>, <King>
		lea   eax, [EndgameEval_KNNK]
		mov   esi, EndgameEval_KNNK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Bishop, Knight>, <King>
		lea   eax, [EndgameEval_KBNK]
		mov   esi, EndgameEval_KBNK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook>, <King, Pawn>
		lea   eax, [EndgameEval_KRKP]
		mov   esi, EndgameEval_KRKP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook>, <King, Bishop>
		lea   eax, [EndgameEval_KRKB]
		mov   esi, EndgameEval_KRKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook>, <King, Knight>
		lea   eax, [EndgameEval_KRKN]
		mov   esi, EndgameEval_KRKN_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Queen>, <King, Pawn>
		lea   eax, [EndgameEval_KQKP]
		mov   esi, EndgameEval_KQKP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Queen>, <King, Rook>
		lea   eax, [EndgameEval_KQKR]
		mov   esi, EndgameEval_KQKR_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

;	     Assert   ne, byte[rdi+(ENDGAME_EVAL_MAP_SIZE-1)*sizeof.EndgameMapEntry+EndgameMapEntry.entri], 0, 'problem1 in Endgame_Init'


	; these endgame fxns correspond to many material config
	;  and are not added to the map
		lea   eax, [EndgameEval_KXK]
		mov   r8d, EndgameEval_KXK_index
		mov   dword[rbx+4*r8], eax



; scale
		lea   rbx, [EndgameScale_FxnTable]
		lea   rdi, [EndgameScale_Map]

	; these endgame fxns correspond to a specific material config
	;  and are added to the map
	    GetKeys   rcx, rdx, <King, Knight, Pawn>, <King>
		lea   eax, [EndgameScale_KNPK]
		mov   esi, EndgameScale_KNPK_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Knight, Pawn>, <King, Bishop>
		lea   eax, [EndgameScale_KNPKB]
		mov   esi, EndgameScale_KNPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook, Pawn>, <King, Rook>
		lea   eax, [EndgameScale_KRPKR]
		mov   esi, EndgameScale_KRPKR_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook, Pawn>, <King, Bishop>
		lea   eax, [EndgameScale_KRPKB]
		mov   esi, EndgameScale_KRPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Bishop, Pawn>, <King, Bishop>
		lea   eax, [EndgameScale_KBPKB]
		mov   esi, EndgameScale_KBPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Bishop, Pawn>, <King, Knight>
		lea   eax, [EndgameScale_KBPKN]
		mov   esi, EndgameScale_KBPKN_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Bishop, Pawn, Pawn>, <King, Bishop>
		lea   eax, [EndgameScale_KBPPKB]
		mov   esi, EndgameScale_KBPPKB_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

	    GetKeys   rcx, rdx, <King, Rook, Pawn, Pawn>, <King, Rook, Pawn>
		lea   eax, [EndgameScale_KRPPKRP]
		mov   esi, EndgameScale_KRPPKRP_index
		mov   dword[rbx+4*rsi], eax
	       call   .Map_Insert

;	     Assert   ne, byte[rdi+(ENDGAME_SCALE_MAP_SIZE-1)*sizeof.EndgameMapEntry+EndgameMapEntry.entri], 0, 'problem2 in Endgame_Init'


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

		pop   rdi rsi rbx
		ret

.PushToEdges:
db  100, 90, 80, 70, 70, 80, 90, 100
db   90, 70, 60, 50, 50, 60, 70,  90
db   80, 60, 40, 30, 30, 40, 60,  80
db   70, 50, 30, 20, 20, 30, 50,  70
db   70, 50, 30, 20, 20, 30, 50,  70
db   80, 60, 40, 30, 30, 40, 60,  80
db   90, 70, 60, 50, 50, 60, 70,  90
db  100, 90, 80, 70, 70, 80, 90, 100


.PushToCorners:
db    200, 190, 180, 170, 160, 150, 140, 130
db    190, 180, 170, 160, 150, 140, 130, 140
db    180, 170, 155, 140, 140, 125, 140, 150
db    170, 160, 140, 120, 110, 140, 150, 160
db    160, 150, 140, 110, 120, 140, 160, 170
db    150, 140, 125, 140, 140, 155, 170, 180
db    140, 130, 140, 150, 160, 170, 180, 190
db    130, 140, 150, 160, 170, 180, 190, 200


.PushClose: db	0, 0, 100, 80, 60, 40, 20, 10
.PushAway: db  0, 5, 20, 40, 60, 80, 90, 100
;.KRPPKRPScaleFactors: db 0, 9, 10, 14, 21, 44, 0, 0

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
;	     Assert   ne, rax, rcx , 'assertion rax!=rcx failed in Endgame_Init: duplicate material keys'
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
