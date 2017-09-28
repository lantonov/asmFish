; TablebaseCore by Ronald de Man   this code+data weighs in at 20KB
; there are three functions and one dword that an engine needs
;   and they are used here in an engine-independent way
;
; global _ZN13TablebaseCore4initEPKc: function
; global _ZN13TablebaseCore15probe_wdl_tableER8PositionPi: function
; global _ZN13TablebaseCore15probe_dtz_tableER8PositioniPi: function
; global _ZN13TablebaseCore14MaxCardinalityE
;
; prototypes:
;namespace TablebaseCore {
;int MaxCardinality=0;
;void init(const char* path);
;int probe_wdl_table(Position& pos, int *success);
;int probe_dtz_table(Position& pos,int wdl, int *success);
;}



; we are also using the following definition of Rdm
; #define TB_PAWN 1
; #define TB_KNIGHT 2
; #define TB_BISHOP 3
; #define TB_ROOK 4
; #define TB_QUEEN 5
; #define TB_KING 6
; which off by one from the Pawn=2, Knight=3, as used by this engine


; these engine-specific functions are used by the core and need to be defined here
;   they should follow MS 64bit ABI

;extern _Z8calc_keyR8Positioni                           ; near
;extern _Z10pos_piecesR8Position5Color9PieceType         ; near
;extern _Z16pos_side_to_moveR8Position                   ; near
;extern _Z7prt_strR8PositionPci                          ; near
;extern _Z11pos_KvK_keyR8Position                        ; near
;extern _Z16pos_material_keyR8Position                   ; near
;extern _Z17calc_key_from_pcsPii                         ; near


_Z16pos_material_keyR8Position:
	; in: rcx address of position
	; out: rax material key
                xor   eax, eax
               push   rdi rsi rax rax
		xor   esi, esi
.NextSquare:
	      movzx   edi, byte[rcx+Pos.board+rsi]
                mov   r8d, edi
                shl   r8d, 9
	      movzx   edx, byte[rsp+rdi]
		xor   rax, qword[Zobrist_Pieces+r8+8*rdx]
		add   edx, 1
		mov   byte[rsp+rdi], dl
		add   esi, 1
		cmp   esi, 64
		 jb   .NextSquare
		pop   rcx rcx rsi rdi
		ret


_Z11pos_KvK_keyR8Position:
	; in: rcx address of position  (not used)
	; out: rax material key of KvK configuration
		mov   rax, qword[Zobrist_Pieces+8*(64*(8*White+King)+0)]
		xor   rax, qword[Zobrist_Pieces+8*(64*(8*Black+King)+0)]
		ret


_Z10pos_piecesR8Position5Color9PieceType:
	; in: rcx address of position
	;     edx color
	;     r8d piece type (1=pawn, 2=knight, ..., 6=king)
	; out: rax bitboard of pieces
		mov   rax, qword[rcx+Pos.typeBB+8*rdx]
		and   rax, qword[rcx+Pos.typeBB+8*(r8+1)]   ; we are shifted by one
		ret


_Z16pos_side_to_moveR8Position:
	; in: rcx address of position
	; out: eax side to move
		mov   eax, dword[rcx+Pos.sideToMove]
		ret



_Z17calc_key_from_pcsPii:
	; in: rcx address of pcs[16]
	;     edx mirror
	; out: rax material key
               push   rdi rsi
		xor   eax, eax
		neg   edx
		sbb   edx, edx
		and   edx, 8
                xor   esi, esi
.colorLoop:
                mov   edi, Pawn
.typeLoop:
                lea   r8, [8*rsi+rdi]
                shl   r8, 9
                lea   r9d, [rdx+rdi-1]
		mov   r9d, dword[rcx+4*r9]
		sub   r9d, 1
		 js   .Done
	.Next:
		xor   rax, qword[Zobrist_Pieces+r8+8*r9]
		sub   r9d, 1
		jns   .Next
	.Done:
                add   edi, 1
                cmp   edi, King
                jbe   .typeLoop
		xor   edx, 8
                add   esi, 1
                cmp   esi, 2
                 jb   .colorLoop
                pop   rsi rdi
		ret


_Z8calc_keyR8Positioni:
	; in: rcx address of position
	;     edx mirror
	; out: rax material key
               push   rsi rdi
		xor   eax, eax
		neg   edx
		sbb   edx, edx
		and   edx, 8
                xor   esi, esi
.colorLoop:
                mov   edi, Pawn
.typeLoop:
		mov   r9, qword[rcx+Pos.typeBB+8*rdi]
		and   r9, qword[rcx+Pos.typeBB+rdx]
	    _popcnt   r9, r9, r8
                lea   r8, [8*rsi+rdi]
                shl   r8, 9
		sub   r9d, 1
		 js   .Done
        .Next:
		xor   rax, qword[Zobrist_Pieces+r8+8*r9]
		sub   r9d, 1
		jns   .Next
        .Done:
                add   edi, 1
                cmp   edi, King
                jbe   .typeLoop
		xor   edx, 8
                add   esi, 1
                cmp   esi, 2
                 jb   .colorLoop
                pop   rdi rsi
		ret


_Z7prt_strR8PositionPci:
	; in: rcx address of position
	;     r8d mirror
	; out: rdx address to write string
	       push   rdi rbp
		mov   rbp, rcx
		mov   rdi, rdx
		mov   edx, r8d
		neg   edx
		sbb   edx, edx
		and   edx, 8
                mov   r10d, 1
.colorLoop:
                mov   r11d, King
.typeLoop:
		mov   r9, qword[rbp+Pos.typeBB+8*r11]
		and   r9, qword[rbp+Pos.typeBB+rdx]
	    _popcnt   rcx, r9, rax
                mov   eax, King
                sub   eax, r11d
		mov   al, byte[_ZL4pchr+rax]
	  rep stosb
                sub   r11d, 1
                cmp   r11d, Pawn
                jae   .typeLoop
		mov   al, 'v'
	      stosb
		xor   edx, 8
                sub   r10d, 1
                jns   .colorLoop
		mov   byte[rdi-1], 0
		pop   rbp rdi
		ret


; todo: malloc and free need a little work after profiling to see what sizes are common
;  for now, we just call _VirtualAlloc on size+16 and store the size in the first qword
;     of the returned page(s).

my_malloc: 	add   rcx, 16
	       push   rcx
	       call   Os_VirtualAlloc
		pop   rcx
		mov   qword[rax], rcx
		add   rax, 16
		ret

my_free:	sub   rcx, 16
		 js   @f
		mov   rdx, qword[rcx]
		jmp   Os_VirtualFree
	@@:	ret



my_exit:	jmp  Os_ExitProcess
my_printf: 	;  don't care about printf's arguments
my_puts:
           push  rdi
            lea  rdi, [Output]
           call  PrintString
        PrintNL
           call  WriteLine_Output
            pop  rdi
            ret
my_strcat:
            mov  al, byte[rcx]
            inc  rcx
           test  al, al
            jne  my_strcat
            dec  rcx
my_strcpy:
            mov  al, byte[rdx]
            inc  rdx
            mov  byte[rcx], al
            inc  rcx
           test  al, al
            jne  my_strcpy
            ret



_ZL12encode_pieceP13TBEntry_piecePhPiS2_:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	test	byte [r8], 04H				
	movzx	r10d, byte [rcx+19H]			
	jnz	L_002					
L_001:	test	byte [r8], 20H				
	jnz	L_005					
	jmp	L_004					

L_002:	xor	eax, eax				
L_003:	cmp	r10d, eax				
	jle	L_001					
	xor	dword [r8+rax*4], 07H			
	inc	rax					
	jmp	L_003					

L_004:	xor	r11d, r11d				
	jmp	L_008					

L_005:	xor	eax, eax				
L_006:	cmp	r10d, eax				
	jle	L_004					
	xor	dword [r8+rax*4], 38H			
	inc	rax					
	jmp	L_006					

L_007:	movsxd	rbx, dword [r8+r11*4]			
	lea	rsi, [ _ZL7offdiag]			
	inc	r11					
	cmp	byte [rsi+rbx], 0			
	jnz	L_009					
L_008:	cmp	r11d, r10d				
	movsxd	rax, r11d				
	jl	L_007					
L_009:	cmp	byte [rcx+1CH], 0			
	jz	L_011					
	cmp	eax, 1					
	jle	L_012					
L_010:	mov	al, byte [rcx+1CH]			
	test	al, al					
	jz	L_014					
	movsxd	rbx, dword [r8] 			
	dec	al					
	mov	ecx, dword [r8+4H]			
	lea	rbp, [ _ZL8triangle]		
	lea	rdi, [ _ZL6KK_idx]			
	je	L_022					
	jmp	L_024					

L_011:	cmp	eax, 2					
	jg	L_014					
L_012:	movsxd	r11, dword [r8+rax*4]			
	lea	rbx, [ _ZL7offdiag]			
	xor	eax, eax				
	cmp	byte [rbx+r11], 0			
	jle	L_010					
L_013:	cmp	r10d, eax				
	jle	L_010					
	movsxd	r11, dword [r8+rax*4]			
	lea	rbx, [ _ZL8flipdiag]		
	movzx	r11d, byte [rbx+r11]			
	mov	dword [r8+rax*4], r11d			
	inc	rax					
	jmp	L_013					

L_014:	movsxd	r11, dword [r8] 			
	lea	rbp, [ _ZL7offdiag]			
	xor	edi, edi				
	movsxd	rcx, dword [r8+4H]			
	movsxd	rax, dword [r8+8H]			
	cmp	ecx, r11d				
	setg	dil					
	xor	esi, esi				
	cmp	eax, r11d				
	setg	sil					
	xor	ebx, ebx				
	cmp	eax, ecx				
	setg	bl					
	add	ebx, esi				
	cmp	byte [rbp+r11], 0			
	jz	L_015					
	lea	rsi, [ _ZL8triangle]		
	sub	ecx, edi				
	movzx	r11d, byte [rsi+r11]			
	imul	ecx, ecx, 62				
	imul	r11d, r11d, 3906			
	add	ecx, r11d				
	jmp	L_020					

L_015:	cmp	byte [rbp+rcx], 0			
	lea	rsi, [ _ZL4diag]			
	jz	L_018					
	movzx	r11d, byte [rsi+r11]			
	lea	rsi, [ _ZL5lower]			
	movzx	ecx, byte [rsi+rcx]			
	imul	r11d, r11d, 1736			
	imul	ecx, ecx, 62				
	lea	ecx, [r11+rcx+5B8CH]			
	add	eax, ecx				
	sub	eax, ebx				
L_016:	cdqe						
L_017:	mov	ecx, 3					
	jmp	L_025					

L_018:	cmp	byte [rbp+rax], 0			
	movzx	r11d, byte [rsi+r11]			
	jz	L_019					
	movzx	ecx, byte [rsi+rcx]			
	imul	r11d, r11d, 196 			
	sub	ecx, edi				
	imul	ecx, ecx, 28				
	lea	ecx, [r11+rcx+76ACH]			
	lea	r11, [ _ZL5lower]			
	movzx	eax, byte [r11+rax]			
	jmp	L_021					

L_019:	movzx	ecx, byte [rsi+rcx]			
	imul	r11d, r11d, 42				
	movzx	eax, byte [rsi+rax]			
	sub	ecx, edi				
	imul	ecx, ecx, 6				
	lea	ecx, [r11+rcx+79BCH]			
L_020:	sub	eax, ebx				
L_021:	add	eax, ecx				
	jmp	L_016					

L_022:	mov	eax, dword [r8+8H]			
	xor	esi, esi				
	cmp	eax, ebx				
	setg	sil					
	xor	r11d, r11d				
	cmp	eax, ecx				
	setg	r11b					
	add	esi, r11d				
	movsxd	r11, ecx				
	movzx	ecx, byte [rbp+rbx]			
	shl	rcx, 6					
	add	rcx, r11				
	movsx	rcx, word [rdi+rcx*2]			
	cmp	rcx, 440				
	ja	L_023					
	sub	eax, esi				
	imul	eax, eax, 441				
	cdqe						
	add	rax, rcx				
	jmp	L_017					

L_023:	lea	rbx, [ _ZL7offdiag]			
	movsxd	r11, eax				
	lea	rax, [ _ZL5lower]			
	movzx	eax, byte [rax+r11]			
	imul	rax, rax, 21				
	cmp	byte [rbx+r11], 0			
	lea	rax, [rcx+rax+6915H]			
	mov	ecx, 3					
	jnz	L_025					
	imul	r11d, esi, 21				
	movsxd	r11, r11d				
	sub	rax, r11				
	jmp	L_025					

L_024:	movsxd	rax, ecx				
	movzx	ecx, byte [rbp+rbx]			
	shl	rcx, 6					
	add	rcx, rax				
	movsx	rax, word [rdi+rcx*2]			
	mov	ecx, 2					
L_025:	movsxd	r11, dword [r9] 			
	imul	rax, r11				
L_026:	cmp	ecx, r10d				
	jge	L_035					
	movsxd	r11, ecx				
	movzx	esi, byte [rdx+r11]			
	lea	rdi, [r11*4+4H] 			
	mov	r11d, ecx				
	lea	rbp, [r8+rdi]				
	add	esi, ecx				
L_027:	cmp	r11d, esi				
	jge	L_031					
	xor	ebx, ebx				
	inc	r11d					
L_028:	lea	r12d, [r11+rbx] 			
	cmp	r12d, esi				
	jge	L_030					
	mov	r12d, dword [rbp-4H]			
	mov	r13d, dword [rbp+rbx*4] 		
	cmp	r12d, r13d				
	jle	L_029					
	mov	dword [rbp-4H], r13d			
	mov	dword [rbp+rbx*4], r12d 		
L_029:	inc	rbx					
	jmp	L_028					

L_030:	add	rbp, 4					
	jmp	L_027					

L_031:	lea	r13, [r8+rdi-4H]			
	xor	r12d, r12d				
	xor	ebp, ebp				
L_032:	lea	r11d, [rcx+r12] 			
	cmp	r11d, esi				
	jge	L_034					
	mov	r11d, dword [r13+r12*4] 		
	xor	ebx, ebx				
	xor	r14d, r14d				
L_033:	xor	r15d, r15d				
	cmp	r11d, dword [r8+rbx*4]			
	setg	r15b					
	inc	rbx					
	add	r14d, r15d				
	cmp	ecx, ebx				
	jg	L_033					
	sub	r11d, r14d				
	movsxd	rbx, r11d				
	movsxd	r11, r12d				
	inc	r12					
	shl	r11, 6					
	add	r11, rbx				
	lea	rbx, [ _ZL8binomial]		
	add	ebp, dword [rbx+r11*4]			
	jmp	L_032					

L_034:	movsxd	r11, dword [r9+rdi-4H]			
	movsxd	rcx, ebp				
	imul	rcx, r11				
	add	rax, rcx				
	mov	ecx, esi				
	jmp	L_026					

L_035:	
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						

_ZL11encode_pawnP12TBEntry_pawnPhPiS2_:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	test	byte [r8], 04H				
	movzx	r12d, byte [rcx+19H]			
	jz	L_037					
	xor	eax, eax				
L_036:	cmp	r12d, eax				
	jle	L_037					
	xor	dword [r8+rax*4], 07H			
	inc	rax					
	jmp	L_036					

L_037:	
	lea	r11, [r8+8H]				
	mov	eax, 1					
L_038:	movzx	r10d, byte [rcx+1CH]			
	cmp	eax, r10d				
	mov	rbp, r10				
	jge	L_042					
	xor	r10d, r10d				
	inc	eax					
L_039:	movzx	ebx, byte [rcx+1CH]			
	lea	esi, [rax+r10]				
	cmp	esi, ebx				
	jge	L_041					
	movsxd	r13, dword [r11-4H]			
	lea	rdi, [ _ZL6ptwist]			
	movsxd	rbp, dword [r11+r10*4]			
	mov	r15b, byte [rdi+rbp]			
	cmp	byte [rdi+r13], r15b			
	jnc	L_040					
	mov	dword [r11-4H], ebp			
	mov	dword [r11+r10*4], r13d 		
L_040:	inc	r10					
	jmp	L_039					

L_041:	add	r11, 4					
	jmp	L_038					

L_042:	
	movsxd	rax, dword [r8] 			
	lea	rbx, [ _ZL4flap]			
	lea	r11d, [r10-1H]				
	movzx	eax, byte [rbx+rax]			
	movsxd	rbx, r11d				
	imul	rsi, rbx, 24				
	lea	r13, [r8+rbx*4] 			
	xor	ebx, ebx				
	add	rax, rsi				
	lea	rsi, [ _ZL7pawnidx]			
	movsxd	rax, dword [rsi+rax*4]			
L_043:	test	r11d, r11d				
	jle	L_044					
	imul	rsi, rbx, -4				
	dec	r11d					
	lea	rdi, [ _ZL6ptwist]			
	movsxd	rsi, dword [r13+rsi]			
	movzx	edi, byte [rdi+rsi]			
	movsxd	rsi, ebx				
	inc	rbx					
	shl	rsi, 6					
	add	rsi, rdi				
	lea	rdi, [ _ZL8binomial]		
	movsxd	rsi, dword [rdi+rsi*4]			
	add	rax, rsi				
	jmp	L_043					

L_044:	
	movzx	ebx, byte [rcx+1DH]			
	movsxd	r11, dword [r9] 			
	add	ebx, r10d				
	imul	rax, r11				
	cmp	ebx, r10d				
	jle	L_055					
	movsxd	rcx, r10d				
	lea	rdi, [rcx*4+4H] 			
	mov	ecx, r10d				
	lea	r11, [r8+rdi]				
L_045:	cmp	ecx, ebx				
	jz	L_049					
	xor	esi, esi				
	inc	ecx					
L_046:	lea	r13d, [rcx+rsi] 			
	cmp	r13d, ebx				
	jge	L_048					
	mov	r13d, dword [r11-4H]			
	mov	r14d, dword [r11+rsi*4] 		
	cmp	r13d, r14d				
	jle	L_047					
	mov	dword [r11-4H], r14d			
	mov	dword [r11+rsi*4], r13d 		
L_047:	inc	rsi					
	jmp	L_046					

L_048:	add	r11, 4					
	jmp	L_045					

L_049:	lea	r13, [r8+rdi-4H]			
	xor	esi, esi				
	xor	edi, edi				
L_050:	lea	ecx, [r10+rdi]				
	cmp	ecx, ebx				
	jge	L_053					
	mov	ecx, dword [r13+rdi*4]			
	xor	r11d, r11d				
	xor	r14d, r14d				
L_051:	cmp	r10d, r11d				
	jle	L_052					
	xor	r15d, r15d				
	cmp	ecx, dword [r8+r11*4]			
	setg	r15b					
	inc	r11					
	add	r14d, r15d				
	jmp	L_051					

L_052:	sub	ecx, r14d				
	sub	ecx, 8					
	movsxd	r11, ecx				
	movsxd	rcx, edi				
	inc	rdi					
	shl	rcx, 6					
	add	rcx, r11				
	lea	r11, [ _ZL8binomial]		
	add	esi, dword [r11+rcx*4]			
	jmp	L_050					

L_053:	movsxd	rcx, dword [r9+rbp*4]			
	movsxd	rsi, esi				
	imul	rsi, rcx				
	add	rax, rsi				
L_054:	mov	r10d, ebx				
L_055:	cmp	r10d, r12d				
	jge	L_065					
	movsxd	rcx, r10d				
	movzx	ebx, byte [rdx+rcx]			
	lea	rsi, [rcx*4+4H] 			
	mov	ecx, r10d				
	lea	r11, [r8+rsi]				
	add	ebx, r10d				
L_056:	cmp	ecx, ebx				
	jge	L_060					
	xor	edi, edi				
	inc	ecx					
L_057:	lea	ebp, [rcx+rdi]				
	cmp	ebp, ebx				
	jge	L_059					
	mov	ebp, dword [r11-4H]			
	mov	r13d, dword [r11+rdi*4] 		
	cmp	ebp, r13d				
	jle	L_058					
	mov	dword [r11-4H], r13d			
	mov	dword [r11+rdi*4], ebp			
L_058:	inc	rdi					
	jmp	L_057					

L_059:	add	r11, 4					
	jmp	L_056					

L_060:	lea	r13, [r8+rsi-4H]			
	xor	ebp, ebp				
	xor	edi, edi				
L_061:	lea	ecx, [r10+rbp]				
	cmp	ecx, ebx				
	jge	L_064					
	mov	ecx, dword [r13+rbp*4]			
	xor	r11d, r11d				
	xor	r14d, r14d				
L_062:	cmp	r10d, r11d				
	jle	L_063					
	xor	r15d, r15d				
	cmp	ecx, dword [r8+r11*4]			
	setg	r15b					
	inc	r11					
	add	r14d, r15d				
	jmp	L_062					

L_063:	sub	ecx, r14d				
	movsxd	r11, ecx				
	movsxd	rcx, ebp				
	inc	rbp					
	shl	rcx, 6					
	add	rcx, r11				
	lea	r11, [ _ZL8binomial]		
	add	edi, dword [r11+rcx*4]			
	jmp	L_061					

L_064:	movsxd	rcx, dword [r9+rsi-4H]			
	movsxd	rdi, edi				
	imul	rdi, rcx				
	add	rax, rdi				
	jmp	L_054					

L_065:	
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						

_ZL14set_norm_pieceP13TBEntry_piecePhS1_:
	push	rdi					
	push	rsi					
	push	rbx					
	xor	eax, eax				
L_066:	movzx	r9d, byte [rcx+19H]			
	cmp	r9d, eax				
	jle	L_067					
	mov	byte [rdx+rax], 0			
	inc	rax					
	jmp	L_066					

L_067:	
	mov	al, byte [rcx+1CH]			
	test	al, al					
	jz	L_068					
	cmp	al, 2					
	jnz	L_069					
	mov	byte [rdx], 2				
	jmp	L_070					

L_068:	mov	byte [rdx], 3				
	jmp	L_070					

L_069:	dec	eax					
	mov	byte [rdx], al				
L_070:	movzx	eax, byte [rdx] 			
L_071:	movzx	r9d, byte [rcx+19H]			
	cmp	eax, r9d				
	jge	L_074					
	movsxd	r10, eax				
	xor	r9d, r9d				
	lea	r11, [r8+r10]				
	lea	rbx, [rdx+r10]				
L_072:	movzx	esi, byte [rcx+19H]			
	lea	edi, [rax+r9]				
	cmp	edi, esi				
	jge	L_073					
	mov	sil, byte [r11+r9]			
	inc	r9					
	cmp	sil, byte [r11] 			
	jnz	L_073					
	inc	byte [rbx]				
	jmp	L_072					

L_073:	movzx	r9d, byte [rdx+r10]			
	add	eax, r9d				
	jmp	L_071					

L_074:	
	pop	rbx					
	pop	rsi					
	pop	rdi					
	ret						

_ZL13set_norm_pawnP12TBEntry_pawnPhS1_:
	push	rdi					
	push	rsi					
	push	rbx					
	xor	eax, eax				
L_075:	movzx	r9d, byte [rcx+19H]			
	cmp	r9d, eax				
	jle	L_076					
	mov	byte [rdx+rax], 0			
	inc	rax					
	jmp	L_075					

L_076:	
	mov	al, byte [rcx+1CH]			
	mov	byte [rdx], al				
	mov	al, byte [rcx+1DH]			
	test	al, al					
	jz	L_077					
	movzx	r9d, byte [rcx+1CH]			
	mov	byte [rdx+r9], al			
L_077:	movzx	r9d, byte [rcx+1CH]			
	movzx	eax, byte [rcx+1DH]			
L_078:	add	eax, r9d				
	movzx	r9d, byte [rcx+19H]			
	cmp	eax, r9d				
	jge	L_081					
	movsxd	r10, eax				
	xor	r9d, r9d				
	lea	r11, [r8+r10]				
	lea	rbx, [rdx+r10]				
L_079:	movzx	esi, byte [rcx+19H]			
	lea	edi, [rax+r9]				
	cmp	edi, esi				
	jge	L_080					
	mov	sil, byte [r11+r9]			
	inc	r9					
	cmp	sil, byte [r11] 			
	jnz	L_080					
	inc	byte [rbx]				
	jmp	L_079					

L_080:	movzx	r9d, byte [rdx+r10]			
	jmp	L_078					

L_081:	
	pop	rbx					
	pop	rsi					
	pop	rdi					
	ret						

_ZL11calc_symlenP9PairsDataiPc:
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 40 				
	lea	eax, [rdx+rdx*2]			
	mov	rbp, rcx				
	mov	rdi, r8 				
	cdqe						
	add	rax, qword [rcx+28H]			
	movsxd	rsi, edx				
	movzx	ebx, byte [rax+1H]			
	movzx	ecx, byte [rax+2H]			
	mov	r9d, ebx				
	sar	ebx, 4					
	shl	ecx, 4					
	or	ebx, ecx				
	cmp	ebx, 4095				
	jnz	L_082					
	mov	rax, qword [rbp+20H]			
	mov	byte [rax+rsi], 0			
	jmp	L_085					

L_082:	movzx	edx, byte [rax] 			
	and	r9d, 0FH				
	shl	r9d, 8					
	or	edx, r9d				
	movsxd	r12, edx				
	cmp	byte [r8+r12], 0			
	jnz	L_083					
	mov	rcx, rbp				
	call	_ZL11calc_symlenP9PairsDataiPc		
L_083:	movsxd	r13, ebx				
	cmp	byte [rdi+r13], 0			
	jnz	L_084					
	mov	r8, rdi 				
	mov	edx, ebx				
	mov	rcx, rbp				
	call	_ZL11calc_symlenP9PairsDataiPc		
L_084:	mov	rax, qword [rbp+20H]			
	mov	dl, byte [rax+r13]			
	mov	cl, byte [rax+r12]			
	lea	edx, [rdx+rcx+1H]			
	mov	byte [rax+rsi], dl			
L_085:	mov	byte [rdi+rsi], 1			
	add	rsp, 40 				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	ret						

_ZL11setup_pairsPhyPyPS_S_i:
	push	r15
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	_chkstk_ms rsp, 4184
	sub	rsp, 4184
	mov	rax, qword [rsp+10C0H]			
	mov	rbx, rcx				
	mov	cl, byte [rcx]				
	mov	r15, r9 				
	mov	byte [rax], cl				
	cmp	byte [rbx], 0				
	jns	L_088					
	mov	ecx, 72 				
	mov	qword [rsp+20H], r8			
	call	my_malloc
	cmp	dword [rsp+10C8H], 0			
	mov	dword [rax+34H], 0			
	mov	r8, qword [rsp+20H]			
	jz	L_086					
	movzx	edx, byte [rbx+1H]			
	mov	dword [rax+38H], edx			
	jmp	L_087					

L_086:	mov	dword [rax+38H], 0			
L_087:	add	rbx, 2					
	mov	qword [r15], rbx			
	mov	qword [r8+10H], 0			
	mov	qword [r8+8H], 0			
	mov	qword [r8], 0				
	jmp	L_098					

L_088:	movzx	eax, byte [rbx+5H]			
	mov	qword [rsp+48H], r8			
	movzx	r12d, byte [rbx+9H]			
	mov	qword [rsp+40H], rdx			
	movzx	ebp, byte [rbx+8H]			
	movzx	r11d, byte [rbx+1H]			
	shl	eax, 8					
	movzx	r9d, byte [rbx+2H]			
	mov	ecx, eax				
	movzx	eax, byte [rbx+6H]			
	sub	ebp, r12d				
	lea	edi, [rbp+rbp+0CH]			
	movsxd	r14, ebp				
	mov	dword [rsp+3CH], r11d			
	lea	r10, [r14*8+48H]			
	mov	dword [rsp+38H], r9d			
	shl	eax, 16 				
	mov	qword [rsp+30H], r10			
	or	eax, ecx				
	movzx	ecx, byte [rbx+4H]			
	or	eax, ecx				
	movzx	ecx, byte [rbx+7H]			
	shl	ecx, 24 				
	or	eax, ecx				
	mov	dword [rsp+20H], eax			
	movzx	eax, byte [rbx+3H]			
	add	eax, dword [rsp+20H]			
	mov	dword [rsp+2CH], eax			
	movsxd	rax, edi				
	add	rax, rbx				
	movzx	esi, byte [rax+1H]			
	movzx	eax, byte [rax] 			
	shl	esi, 8					
	or	esi, eax				
	movzx	ecx, si 				
	movzx	r13d, si

	and	esi, 01H				
	add	rcx, r10				
	call	my_malloc
	mov	r10, qword [rsp+30H]			
	lea	rcx, [rbx+0AH]				
	mov	qword [rax+18H], rcx			
	mov	r9d, dword [rsp+38H]			
	mov	rdx, qword [rsp+40H]			
	mov	dword [rax+38H], r12d			
	mov	r8, qword [rsp+48H]			
	add	r10, rax				
	mov	r11d, dword [rsp+3CH]			
	mov	qword [rax+20H], r10			
	lea	r10d, [rdi+2H]				
	movsxd	rdi, r10d				
	mov	dword [rax+34H], r9d			
	lea	rcx, [rbx+rdi]				
	mov	qword [rax+28H], rcx			
	lea	ecx, [r13+r13*2]			
	add	ecx, r10d				
	mov	r10d, 1 				
	mov	dword [rax+30H], r11d			
	add	ecx, esi				
	movsxd	rcx, ecx				
	add	rbx, rcx				
	mov	cl, r9b 				
	shl	r10, cl 				
	mov	qword [r15], rbx			
	lea	rdx, [rdx+r10-1H]			
	shr	rdx, cl 				
	mov	cl, r11b				
	imul	rdx, rdx, 6				
	mov	qword [r8], rdx 			
	movsxd	rdx, dword [rsp+2CH]			
	add	rdx, rdx				
	mov	qword [r8+8H], rdx			
	movsxd	rdx, dword [rsp+20H]			
	shl	rdx, cl 				
	mov	qword [r8+10H], rdx			
	xor	edx, edx				
L_089:	cmp	r13d, edx				
	jle	L_090					
	mov	byte [rsp+rdx+50H], 0			
	inc	rdx					
	jmp	L_089					

L_090:	lea	rsi, [rsp+50H]				
	xor	ebx, ebx				
L_091:	cmp	ebx, r13d				
	jge	L_093					
	cmp	byte [rbx+rsi], 0			
	jnz	L_092					
	mov	rcx, rax				
	mov	r8, rsi 				
	mov	edx, ebx				
	mov	qword [rsp+20H], rax			
	call	_ZL11calc_symlenP9PairsDataiPc		
	mov	rax, qword [rsp+20H]			
L_092:	inc	rbx					
	jmp	L_091					

L_093:	mov	qword [rax+r14*8+40H], 0		
	lea	r8d, [rbp-1H]				
	sub	rdi, 16 				
L_094:	test	r8d, r8d				
	js	L_095					
	mov	r9, qword [rax+18H]			
	lea	rcx, [r9+rdi]				
	movzx	edx, byte [rcx+1H]			
	lea	r9, [r9+rdi+2H] 			
	sub	rdi, 2					
	movzx	ecx, byte [rcx] 			
	shl	edx, 8					
	or	edx, ecx				
	lea	ecx, [r8+1H]				
	movzx	edx, dx 				
	movsxd	rcx, ecx				
	add	rdx, qword [rax+rcx*8+40H]		
	movzx	ecx, byte [r9+1H]			
	movzx	r9d, byte [r9]				
	shl	ecx, 8					
	or	ecx, r9d				
	movsxd	r9, r8d 				
	dec	r8d					
	movzx	ecx, cx 				
	sub	rdx, rcx				
	shr	rdx, 1					
	mov	qword [rax+r9*8+40H], rdx		
	jmp	L_094					

L_095:	mov	ecx, 64 				
	xor	edx, edx				
	sub	ecx, r12d				
L_096:	cmp	ebp, edx				
	jl	L_097					
	shl	qword [rax+rdx*8+40H], cl		
	inc	rdx					
	dec	ecx					
	jmp	L_096					

L_097:	movsxd	rdx, dword [rax+38H]			
	add	rdx, rdx				
	sub	qword [rax+18H], rdx			
L_098:	add	rsp, 4184				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						

_ZL7open_tbPKcS0_:
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 328				
	or	esi, -1
        add     dword[tb_total_cnt], 1
	lea	rbx, [rsp+40H]				
	mov	rdi, rcx				
	mov	rbp, rdx				
L_099:	
        add     esi, 1
        cmp	esi, dword[_ZL9num_paths]
	jae	L_100					
	mov	rax, qword [ _ZL5paths] 	
	mov	rcx, rbx				
	mov	rdx, qword [rax+rsi*8]			
	call	my_strcpy
	lea	rdx, [ L_338]			
	mov	rcx, rbx				
	call	my_strcat
	mov	rdx, rdi				
	mov	rcx, rbx				
	call	my_strcat
	mov	rdx, rbp				
	mov	rcx, rbx				
	call	my_strcat
	mov	rcx, rbx
	call	Os_FileOpenRead
	cmp	rax, -1 				
	jz	L_099
        mov	rcx, qword[_ZL5paths]
	mov	edx, dword[_ZL9num_paths]
	add	edx, esi
	add	dword[rcx+8*rdx+0], 1
	jmp	L_101
L_100:	or	rax, -1
L_101:	add	rsp, 328				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	ret						





_ZL8map_filePKcS0_Py:
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 72 				
	mov	rdi, rcx				
	mov	rbp, rdx				
	mov	rbx, r8 				
	call	_ZL7open_tbPKcS0_			
	cmp	rax, -1 				
	mov	rsi, rax				
	je	L_105

	mov	rcx, rsi
	call	Os_FileMap
	mov	qword[rbx], rdx
	mov	rbx, rax

	mov	rcx, rsi
	call	Os_FileClose
	mov	rax, rbx				
	jmp	L_106

L_105:	xor	eax, eax				
L_106:	add	rsp, 72 				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	ret



_Z16decompress_pairsILb1EEhP9PairsDatay:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	mov	eax, dword [rcx+34H]			
	test	eax, eax				
	mov	r9, rcx 				
	jnz	L_107					
	mov	al, byte [rcx+38H]			
	jmp	L_117					

L_107:	mov	r10d, 1 				
	mov	cl, al					
	mov	r8, r10 				
	shl	r8, cl					
	lea	ecx, [rax-1H]				
	dec	r8d					
	shl	r10, cl 				
	and	r8d, edx				
	mov	cl, al					
	shr	rdx, cl 				
	sub	r8d, r10d				
	mov	r10, qword [r9] 			
	imul	edx, edx, 6				
	mov	rcx, qword [r9+8H]			
	mov	eax, dword [r10+rdx]			
	movzx	edx, word [r10+rdx+4H]			
	add	r8d, edx				
	jns	L_109					
L_108:	lea	edx, [rax-1H]				
	mov	rax, rdx				
	movzx	edx, word [rcx+rdx*2]			
	lea	r8d, [r8+rdx+1H]			
	test	r8d, r8d				
	js	L_108					
	jmp	L_110					

L_109:	mov	edx, eax				
	movzx	edx, word [rcx+rdx*2]			
	cmp	r8d, edx				
	jle	L_110					
	inc	edx					
	inc	eax					
	sub	r8d, edx				
	jmp	L_109					

L_110:	mov	ecx, dword [r9+30H]			
	lea	rsi, [r9+40H]				
	xor	r11d, r11d				
	mov	r13d, 64				
	movsxd	rbp, dword [r9+38H]			
	mov	r12, qword [r9+18H]			
	mov	rbx, qword [r9+20H]			
	shl	eax, cl 				
	add	rax, qword [r9+10H]			
	mov	rdi, rbp				
	lea	rcx, [rbp*8]				
	sub	rsi, rcx				
	mov	r10, qword [rax]			
	lea	rdx, [rax+8H]				
	bswap	r10					
L_111:	mov	rax, rbp				
	mov	r14d, edi				
L_112:	lea	r15, [rax+1H]				
	mov	rcx, qword [rsi+r15*8-8H]		
	cmp	r10, rcx				
	jnc	L_113					
	inc	r14d					
	mov	rax, r15				
	jmp	L_112					

L_113:	movzx	r15d, word [r12+rax*2]			
	mov	rax, r10				
	sub	rax, rcx				
	mov	ecx, r13d				
	sub	ecx, r14d				
	shr	rax, cl 				
	add	eax, r15d				
	movsxd	rcx, eax				
	movzx	ecx, byte [rbx+rcx]			
	cmp	ecx, r8d				
	jge	L_114					
	not	ecx					
	add	r11d, r14d				
	add	r8d, ecx				
	mov	cl, r14b				
	shl	r10, cl 				
	cmp	r11d, 31				
	jle	L_111					
	mov	eax, dword [rdx]			
	sub	r11d, 32				
	add	rdx, 4					
	mov	cl, r11b				
	bswap	eax					
	mov	eax, eax				
	shl	rax, cl 				
	or	r10, rax				
	jmp	L_111					

L_114:	mov	r10, qword [r9+28H]			
L_115:	movsxd	rdx, eax				
	cmp	byte [rbx+rdx], 0			
	jz	L_116					
	lea	edx, [rax+rax*2]			
	movsxd	rdx, edx				
	add	rdx, r10				
	movzx	ecx, byte [rdx+1H]			
	movzx	r9d, byte [rdx] 			
	mov	eax, ecx				
	and	eax, 0FH				
	shl	eax, 8					
	or	eax, r9d				
	movsxd	r9, eax 				
	movzx	r9d, byte [rbx+r9]			
	cmp	r9d, r8d				
	jge	L_115					
	movzx	eax, byte [rdx+2H]			
	not	r9d					
	sar	ecx, 4					
	add	r8d, r9d				
	shl	eax, 4					
	or	eax, ecx				
	jmp	L_115					

L_116:	lea	eax, [rax+rax*2]			
	cdqe						
	mov	al, byte [r10+rax]			
L_117:	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						

_ZL9pawn_fileP12TBEntry_pawnPi.isra0:
	push	rbx					
	xor	r8d, r8d				
L_118:	movzx	eax, byte [rcx] 			
	lea	r9d, [r8+1H]				
	cmp	r9d, eax				
	mov	eax, dword [rdx]			
	jge	L_120					
	movsxd	rbx, dword [rdx+r8*4+4H]		
	lea	r11, [ _ZL4flap]			
	movsxd	r9, eax 				
	mov	r10, rbx				
	mov	bl, byte [r11+rbx]			
	cmp	byte [r11+r9], bl			
	jbe	L_119					
	mov	dword [rdx], r10d			
	mov	dword [rdx+r8*4+4H], eax		
L_119:	inc	r8					
	jmp	L_118					

L_120:	
	lea	rdx, [ _ZL12file_to_file]		
	and	eax, 07H				
	movzx	eax, byte [rdx+rax]			
	pop	rbx					
	ret						

_ZL11add_to_hashP7TBEntryy:

	push	rbx					
	sub	rsp, 32 				
	lea	rax, [ _ZL7TB_hash]			
	xor	r9d, r9d				
	mov	r10, rax				
	mov	r11, rdx				
	shr	r11, 54 				
	imul	rbx, r11, 80				
	add	rbx, rax				
L_121:	mov	rax, r9 				
	movsxd	r8, r9d 				
	shl	rax, 4					
	cmp	qword [rbx+rax+8H], 0			
	jz	L_122					
	inc	r9					
	cmp	r9, 5					
	jnz	L_121					
	lea	rcx, [ L_341]			
	call	my_puts
	mov	ecx, 1					
	call	my_exit
L_122:	lea	rax, [r11+r11*4]			
	add	rax, r8 				
	shl	rax, 4					
	add	rax, r10				
	mov	qword [rax], rdx			
	mov	qword [rax+8H], rcx			
	add	rsp, 32 				
	pop	rbx					
	ret						

_ZL7init_tbPc.constprop4:
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 104
	lea	rdx, [ L_342]			
	mov	rbx, rcx				
	call	_ZL7open_tbPKcS0_			
	cmp	rax, -1 				
	je	L_149
	lea	rdi, [rsp+20H]				
	mov	rcx, rax				
	call	Os_FileClose
	xor	eax, eax				
L_123:	mov	dword [rax+rdi], 0			
	add	rax, 4					
	cmp	rax, 64 				
	jnz	L_123					
	xor	al, al					
	mov	ecx, 8					
L_124:	mov	dl, byte [rbx]				
	test	dl, dl					
	jz	L_133					
	cmp	dl, 80					
	jz	L_126					
	jg	L_125					
	cmp	dl, 75					
	jz	L_130					
	cmp	dl, 78					
	jz	L_127					
	cmp	dl, 66					
	jnz	L_132					
	mov	edx, eax				
	or	edx, 03H				
	jmp	L_131					

L_125:	cmp	dl, 82					
	jz	L_128					
	jl	L_129					
	cmp	dl, 118 				
	cmove	eax, ecx				
	jmp	L_132					

L_126:	mov	edx, eax				
	or	edx, 01H				
	jmp	L_131					

L_127:	mov	edx, eax				
	or	edx, 02H				
	jmp	L_131					

L_128:	mov	edx, eax				
	or	edx, 04H				
	jmp	L_131					

L_129:	mov	edx, eax				
	or	edx, 05H				
	jmp	L_131					

L_130:	mov	edx, eax				
	or	edx, 06H				
L_131:	movsxd	rdx, edx				
	inc	dword [rsp+rdx*4+20H]			
L_132:	inc	rbx					
	jmp	L_124					

L_133:	xor	edx, edx				
	mov	rcx, rdi				
	call	_Z17calc_key_from_pcsPii		
	mov	rcx, rdi				
	mov	edx, 1					
	mov	rsi, rax				
	call	_Z17calc_key_from_pcsPii		
	mov	ecx, dword [rsp+24H]			
	mov	rbp, rax				
	mov	eax, dword [rsp+44H]			
	mov	r9d, ecx				
	add	r9d, eax				
	jnz	L_135					
	movsxd	rbx, dword [ _ZL11TBnum_piece]	
	cmp	ebx, 254				
	jnz	L_134					
	lea	rcx, [ L_343]			
	jmp	L_136					

L_134:	lea	edx, [rbx+1H]				
	mov	dword [ _ZL11TBnum_piece], edx	
	imul	rbx, rbx, 120				
	lea	rdx, [ _ZL8TB_piece]		
	jmp	L_138					

L_135:	movsxd	rbx, dword [ _ZL10TBnum_pawn]	
	cmp	ebx, 256				
	jnz	L_137					
	lea	rcx, [ L_344]			
L_136:	call	my_puts
	mov	ecx, 1					
	call	my_exit
L_137:	lea	edx, [rbx+1H]				
	imul	rbx, rbx, 384				
	mov	dword [ _ZL10TBnum_pawn], edx	
	lea	rdx, [ _ZL7TB_pawn]			
L_138:	add	rbx, rdx				
	xor	r8d, r8d				
	xor	edx, edx				
	mov	qword [rbx+8H], rsi			
	mov	byte [rbx+18H], 0			
L_139:	add	r8d, dword [rdi+rdx]			
	add	rdx, 4					
	cmp	rdx, 64 				
	jnz	L_139					
	cmp	rsi, rbp				
	mov	byte [rbx+19H], r8b			
	movzx	r8d, r8b				
	sete	byte [rbx+1AH]				
	test	r9d, r9d				
	setg	dl					
	cmp	r8d, dword [Tablebase_MaxCardinality]
	mov	byte [rbx+1BH], dl			
	jle	L_140					
	mov	dword [Tablebase_MaxCardinality], r8d
L_140:	test	dl, dl					
	jz	L_142					
	test	eax, eax				
	mov	byte [rbx+1CH], cl			
	mov	byte [rbx+1DH], al			
	jle	L_148					
	test	ecx, ecx				
	jz	L_141					
	cmp	eax, ecx				
	jge	L_148					
L_141:	mov	byte [rbx+1CH], al			
	mov	byte [rbx+1DH], cl			
	jmp	L_148					

L_142:	xor	eax, eax				
	xor	edx, edx				
L_143:	xor	ecx, ecx				
	cmp	dword [rdi+rax], 1			
	sete	cl					
	add	rax, 4					
	add	edx, ecx				
	cmp	rax, 64 				
	jnz	L_143					
	cmp	edx, 2					
	jle	L_144					
	mov	byte [rbx+1CH], 0			
	jmp	L_148					

L_144:	jnz	L_145					
	mov	byte [rbx+1CH], 2			
	jmp	L_148					

L_145:	xor	eax, eax				
	mov	edx, 16 				
L_146:	mov	ecx, dword [rdi+rax]			
	cmp	ecx, edx				
	jge	L_147					
	cmp	ecx, 1					
	cmovg	edx, ecx				
L_147:	add	rax, 4					
	lea	ecx, [rdx+1H]				
	cmp	rax, 64 				
	jnz	L_146					
	mov	byte [rbx+1CH], cl			
L_148:	mov	rdx, rsi				
	mov	rcx, rbx				
	call	_ZL11add_to_hashP7TBEntryy		
	cmp	rbp, rsi				
	jz	L_149					
	mov	rdx, rbp				
	mov	rcx, rbx				
	call	_ZL11add_to_hashP7TBEntryy		
	nop						
L_149:	add	rsp, 104				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	ret						

_ZL18calc_factors_piecePiiiPhh:
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	mov	ebx, 64 				
	mov	r11d, 1 				
	xor	edi, edi				
	movzx	esi, byte [r9]				
	movzx	r13d, byte [rsp+60H]			
	mov	r12d, edx				
	sub	ebx, esi				
L_150:	cmp	edi, r8d				
	jnz	L_153					
	lea	rax, [ _ZZL18calc_factors_piecePiiiPhhE6pivfac]
	mov	dword [rcx], r11d			
	movsxd	rax, dword [rax+r13*4]			
	imul	r11, rax				
	jmp	L_152					

L_151:	mov	eax, r10d				
	sub	ebx, ebp				
	add	esi, ebp				
	cdq						
	idiv	r14d					
	movsxd	r10, eax				
	imul	r11, r10				
L_152:	inc	edi					
	jmp	L_150					

L_153:	
	cmp	esi, r12d				
	jge	L_155					
	movsxd	rax, esi				
	mov	r10d, ebx				
	mov	r14d, 1 				
	mov	dword [rcx+rax*4], r11d 		
	movzx	ebp, byte [r9+rax]			
	mov	eax, 1					
L_154:	cmp	eax, ebp				
	jge	L_151					
	mov	edx, ebx				
	sub	edx, eax				
	inc	eax					
	imul	r10d, edx				
	imul	r14d, eax				
	jmp	L_154					

L_155:	
	mov	rax, r11				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	ret						

_ZL14free_dtz_entryP7TBEntry:
	push	rsi					
	push	rbx					
	sub	rsp, 40
	mov	rbx, rcx

	mov	rcx, qword[rbx]
	mov	rdx, qword[rbx+10H]
	call	Os_FileUnmap

	xor	esi, esi
	cmp	byte [rbx+1BH], 0			
	jnz	L_157					
	mov	rcx, qword [rbx+20H]			
	call	my_free
	jmp	L_158					

L_157:	mov	rcx, qword [rbx+rsi+20H]		
	add	rsi, 48 				
	call	my_free
	cmp	rsi, 192				
	jnz	L_157					
L_158:	mov	rcx, rbx				
	add	rsp, 40 				
	pop	rbx					
	pop	rsi					
	jmp	my_free

_ZL17calc_factors_pawnPiiiiPhi:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 24 				
	mov	rbx, qword [rsp+80H]			
	cmp	r9d, 14 				
	mov	r13d, edx				
	movzx	r11d, byte [rbx]			
	jg	L_159					
	movzx	eax, byte [rbx+r11]			
	add	r11d, eax				
L_159:	movsxd	r14, dword [rsp+88H]			
	mov	esi, 64 				
	mov	r10d, 1 				
	xor	edi, edi				
	sub	esi, r11d				
L_160:	cmp	edi, r8d				
	jnz	L_165					
	mov	dword [rcx], r10d			
	movzx	eax, byte [rbx] 			
	dec	eax					
	cdqe						
	lea	rdx, [r14+rax*4]			
	lea	rax, [ _ZL7pfactor]			
	movsxd	rax, dword [rax+rdx*4]			
	jmp	L_162					

L_161:	cdq						
	idiv	r12d					
	cdqe						
L_162:	imul	r10, rax				
	jmp	L_164					

L_163:	cdq						
	sub	esi, ebp				
	add	r11d, ebp				
	idiv	r12d					
	cdqe						
	imul	r10, rax				
L_164:	inc	edi					
	jmp	L_160					

L_165:	
	cmp	r11d, r13d				
	jge	L_170					
	cmp	edi, r9d				
	jnz	L_168					
L_166:	movzx	eax, byte [rbx] 			
	mov	r15d, 48				
	mov	r12d, 1 				
	mov	ebp, 1					
	mov	dword [rcx+rax*4], r10d 		
	movzx	edx, byte [rbx] 			
	movzx	eax, byte [rbx+rdx]			
	sub	r15d, edx				
	mov	dword [rsp+0CH], eax			
	mov	eax, r15d				
L_167:	cmp	ebp, dword [rsp+0CH]			
	jge	L_161					
	mov	edx, r15d				
	sub	edx, ebp				
	inc	ebp					
	imul	eax, edx				
	imul	r12d, ebp				
	jmp	L_167					

L_168:	movsxd	rax, r11d				
	mov	r12d, 1 				
	mov	edx, 1					
	mov	dword [rcx+rax*4], r10d 		
	movzx	ebp, byte [rbx+rax]			
	mov	eax, esi				
L_169:	cmp	edx, ebp				
	jge	L_163					
	mov	r15d, esi				
	sub	r15d, edx				
	inc	edx					
	imul	eax, r15d				
	imul	r12d, edx				
	jmp	L_169					

L_170:	
	cmp	edi, r9d				
	jz	L_166					
	mov	rax, r10				
	add	rsp, 24 				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						

_ZL14free_wdl_entryP7TBEntry:
	push	rsi					
	push	rbx					
	sub	rsp, 40 				
	mov	rbx, rcx

	mov	rcx, qword [rbx]
	mov	rdx, qword [rbx+10H]
	call	Os_FileUnmap

	xor	esi, esi
	cmp	byte [rbx+1BH], 0			
	jnz	L_173					
	mov	rcx, qword [rbx+20H]			
	call	my_free
	mov	rcx, qword [rbx+28H]			
	test	rcx, rcx				
	jz	L_174					
	add	rsp, 40 				
	pop	rbx					
	pop	rsi					
	jmp	my_free

L_172:	add	rsi, 88 				
	cmp	rsi, 352				
	jz	L_174					
L_173:	mov	rcx, qword [rbx+rsi+20H]		
	call	my_free
	mov	rcx, qword [rbx+rsi+28H]		
	test	rcx, rcx				
	jz	L_172					
	call	my_free
	jmp	L_172					

L_174:	
	add	rsp, 40 				
	pop	rbx					
	pop	rsi					
	ret						


Tablebase_Init:
        ; in: rcx address of path string
        ;         use 0 for behavior of <empty> 

	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 72
        mov     rbx, rcx                                
        cmp     byte [ _ZL11initialized], 0             
        jz      L_DoInit
L_InitDone:
        ; table core is initialized as this point
        mov     rax, qword[_ZL11path_string]
        test    rax, rax
        jz      L_NothingToFree
        lea     rcx, [_ZL8TB_mutex]
        call    Os_MutexDestroy
        mov     rcx, qword[_ZL11path_string]
        call    my_free
        mov     rcx, qword[_ZL5paths]
        call    my_free
L_NothingToFree:

        lea     rdi, [ _ZL8TB_piece]
        xor     esi, esi
L_176:  cmp     esi, dword [ _ZL11TBnum_piece]
        jge     L_177                                   
        mov     rcx, rdi                                
        inc     esi                                     
        call    _ZL14free_wdl_entryP7TBEntry
        mov     ecx, 120    ; need to zero out the entry
        xor     eax, eax    ; all pointers and data
        rep stosb           ; are invalid now
        jmp     L_176

L_177:  lea     rdi, [ _ZL7TB_pawn]                     
        xor     esi, esi                                
L_178:  cmp     esi, dword [ _ZL10TBnum_pawn]   
        jge     L_179                                   
        mov     rcx, rdi                                
        inc     esi                                     
        call    _ZL14free_wdl_entryP7TBEntry
        mov     ecx, 384    ; need to zero out the entry
        xor     eax, eax    ; all pointers and data
        rep stosb           ; are invalid now
        jmp     L_178
L_179:
        xor     esi, esi                                
L_180:
        mov     rcx, qword[L_334+rsi]
        test    rcx, rcx                                
        jz      L_181
        call    _ZL14free_dtz_entryP7TBEntry
        mov     qword[L_334+rsi], 0     ; this pointer was just freed
L_181:  add     rsi, 24                                 
        cmp     rsi, 24*64
        jb      L_180

        xor     eax, eax
        mov     qword[_ZL11path_string], rax
        mov     qword[_ZL5paths], rax
        mov     dword[tb_total_cnt], eax
        mov     dword[_ZL9num_paths], eax
        mov     dword[_ZL10TBnum_pawn], eax
        mov     dword[_ZL11TBnum_piece], eax
	mov	dword[Tablebase_MaxCardinality], eax

        jmp     L_CheckPath

L_DoInit:
        ; table core is not initialized as this point
        lea     r9, [ _ZL8binomial]                     
        xor     r10d, r10d                              
        mov     rcx, r9
L_182:
        ; initialization loop
        xor     r8d, r8d
L_183:	mov	eax, r8d				
	mov	r11d, 1 				
	mov	edx, 1					
L_184:	cmp	edx, r10d				
	jg	L_185					
	mov	esi, r8d				
	sub	esi, edx				
	inc	edx					
	imul	eax, esi				
	imul	r11d, edx				
	jmp	L_184					

L_185:	cdq						
	idiv	r11d					
	mov	dword [r9+r8*4], eax			
	inc	r8					
	cmp	r8, 64					
	jnz	L_183					
	inc	r10d					
	add	r9, 256 				
	cmp	r10d, 5 				
	jnz	L_182					
	lea	r9, [ _ZL7pfactor]			
	or	r8d, 0FFFFFFFFH 			
	xor	eax, eax				
	lea	r10, [ _ZL7pawnidx]			
L_186:	movsxd	rsi, r8d				
	xor	edx, edx				
	xor	r11d, r11d				
	shl	rsi, 6					
L_187:	test	eax, eax				
	mov	dword [r10+rdx*4], r11d 		
	mov	edi, 1					
	jz	L_188					
	lea	rdi, [ _ZL7invflap]			
	movzx	edi, byte [rdi+rdx]			
	lea	rbp, [ _ZL6ptwist]			
	movzx	edi, byte [rbp+rdi]			
	add	rdi, rsi				
	mov	edi, dword [rcx+rdi*4]			
L_188:	inc	rdx					
	add	r11d, edi				
	cmp	rdx, 6					
	jnz	L_187					
	movsxd	rsi, r8d				
	mov	dword [r9], r11d			
	xor	dl, dl					
	xor	r11d, r11d				
	shl	rsi, 6					
L_189:	test	eax, eax				
	mov	dword [r10+rdx*4+18H], r11d		
	mov	edi, 1					
	jz	L_190					
	lea	rdi, [ L_350]			
	movzx	edi, byte [rdi+rdx]			
	lea	rbp, [ _ZL6ptwist]			
	movzx	edi, byte [rbp+rdi]			
	add	rdi, rsi				
	mov	edi, dword [rcx+rdi*4]			
L_190:	inc	rdx					
	add	r11d, edi				
	cmp	rdx, 6					
	jnz	L_189					
	movsxd	rsi, r8d				
	mov	dword [r9+4H], r11d			
	xor	dl, dl					
	xor	r11d, r11d				
	shl	rsi, 6					
L_191:	test	eax, eax				
	mov	dword [r10+rdx*4+30H], r11d		
	mov	edi, 1					
	jz	L_192					
	lea	rdi, [ L_351]			
	movzx	edi, byte [rdi+rdx]			
	lea	rbp, [ _ZL6ptwist]			
	movzx	edi, byte [rbp+rdi]			
	add	rdi, rsi				
	mov	edi, dword [rcx+rdi*4]			
L_192:	inc	rdx					
	add	r11d, edi				
	cmp	rdx, 6					
	jnz	L_191					
	movsxd	rsi, r8d				
	mov	dword [r9+8H], r11d			
	xor	dl, dl					
	xor	r11d, r11d				
	shl	rsi, 6					
L_193:	test	eax, eax				
	mov	dword [r10+rdx*4+48H], r11d		
	mov	edi, 1					
	jz	L_194					
	lea	rdi, [ L_352]			
	movzx	edi, byte [rdi+rdx]			
	lea	rbp, [ _ZL6ptwist]			
	movzx	edi, byte [rbp+rdi]			
	add	rdi, rsi				
	mov	edi, dword [rcx+rdi*4]			
L_194:	inc	rdx					
	add	r11d, edi				
	cmp	rdx, 6					
	jnz	L_193					
	inc	eax					
	mov	dword [r9+0CH], r11d			
	add	r10, 96 				
	add	r9, 16					
	inc	r8d					
	cmp	eax, 5					
	jne	L_186					
	mov	byte [ _ZL11initialized], 1

L_CheckPath:
        test    rbx, rbx
	jz      L_233
	xor	eax, eax				
	cmp	al, byte [rbx]
	je	L_233

        ; have path string at this point
	call	Tablebase_HandlePathStrings
	lea	rcx, [_ZL8TB_mutex]
	call	Os_MutexCreate

	lea	rdx, [ _ZL7TB_hash]
	;mov	dword [ _ZL10TBnum_pawn], 0		; already
	lea	rcx, [ _ZL7TB_pawn]
	;mov	dword [ _ZL11TBnum_piece], 0	        ; cleared
	;mov	dword [Tablebase_MaxCardinality], 0     ; these
L_205:	xor	eax, eax				
L_206:	mov	qword [rdx+rax], 0			
	mov	qword [rdx+rax+8H], 0			
	add	rax, 16 				
	cmp	rax, 80 				
	jnz	L_206					
	add	rdx, 80 				
	cmp	rdx, rcx				
	jnz	L_205					
	xor	eax, eax				
L_207:	lea	rdx, [ L_334]			
	mov	qword [rdx+rax], 0			
	add	rax, 24 				
	cmp	rax, 1536				
	jnz	L_207					
	lea	rsi, [ L_353]			
	xor	ebx, ebx				
	lea	rdi, [rsp+30H]				
L_208:	mov	al, byte [rbx+rsi]			
	mov	rcx, rdi				
	inc	rbx					
	mov	byte [rsp+30H], 75			
	mov	byte [rsp+32H], 118			
	lea	r13, [ L_353]			
	mov	byte [rsp+33H], 75			
	mov	byte [rsp+34H], 0			
	mov	byte [rsp+31H], al			
	call	_ZL7init_tbPc.constprop4		
	cmp	rbx, 5					
	jnz	L_208					
	lea	r14, [ _ZL4pchr]			
	xor	esi, esi				
L_209:	mov	r12b, byte [r13+rsi]			
	lea	ebp, [rsi+1H]				
L_210:	movsxd	rax, ebp				
	mov	rcx, rdi				
	inc	ebp					
	mov	byte [rsp+30H], 75			
	mov	al, byte [r14+rax]			
	mov	byte [rsp+31H], r12b			
	lea	rbx, [ _ZL4pchr]			
	mov	byte [rsp+32H], 118			
	mov	byte [rsp+33H], 75			
	mov	byte [rsp+35H], 0			
	mov	byte [rsp+34H], al			
	call	_ZL7init_tbPc.constprop4		
	cmp	ebp, 6					
	jnz	L_210					
	inc	rsi					
	cmp	rsi, 5					
	jnz	L_209					
	xor	esi, esi				
L_211:	mov	r12b, byte [r13+rsi]			
	lea	ebp, [rsi+1H]				
L_212:	movsxd	rax, ebp				
	mov	rcx, rdi				
	inc	ebp					
	mov	byte [rsp+30H], 75			
	mov	al, byte [rbx+rax]			
	mov	byte [rsp+31H], r12b			
	mov	byte [rsp+33H], 118			
	mov	byte [rsp+34H], 75			
	mov	byte [rsp+35H], 0			
	mov	byte [rsp+32H], al			
	call	_ZL7init_tbPc.constprop4		
	cmp	ebp, 6					
	jnz	L_212					
	inc	rsi					
	cmp	rsi, 5					
	jnz	L_211

	xor	esi, esi	      ; esi = i-1
L_213:	mov	r15b, byte [r13+rsi]			
	lea	ebp, [rsi+1H]				
L_214:	movsxd	rax, ebp				
	mov	r12d, 1       ; r12d = k
	mov	r14b, byte [rbx+rax]			
L_215:	mov	rcx, rdi				
	mov	byte [rsp+30H], 75			
	mov	byte [rsp+31H], r15b			
	mov	byte [rsp+32H], r14b			
	mov	byte [rsp+33H], 118			
	mov	byte [rsp+34H], 75
	mov	al, byte[_ZL4pchr+r12]
	mov	byte [rsp+35H], al
	mov	byte [rsp+36H], 0			
	call	_ZL7init_tbPc.constprop4		
	add	r12d, 1
	cmp	r12d, 6
	 jb	L_215
	inc	ebp					
	cmp	ebp, 6					
	jnz	L_214					
	inc	rsi					
	cmp	rsi, 5					
	jnz	L_213

	xor	esi, esi				
L_216:	mov	r14b, byte [r13+rsi]			
	lea	ebp, [rsi+1H]				
L_217:	movsxd	rax, ebp				
	mov	r12d, ebp				
	mov	r15b, byte [rbx+rax]			
L_218:	movsxd	rax, r12d				
	mov	rcx, rdi				
	inc	r12d					
	mov	byte [rsp+30H], 75			
	mov	al, byte [rbx+rax]			
	mov	byte [rsp+31H], r14b			
	mov	byte [rsp+32H], r15b			
	mov	byte [rsp+34H], 118			
	mov	byte [rsp+35H], 75			
	mov	byte [rsp+33H], al			
	mov	byte [rsp+36H], 0			
	call	_ZL7init_tbPc.constprop4		
	cmp	r12d, 6 				
	jnz	L_218					
	inc	ebp					
	cmp	ebp, 6					
	jnz	L_217					
	inc	rsi					
	cmp	rsi, 5					
	jnz	L_216					
	xor	r12d, r12d				
L_219:	lea	r15d, [r12+1H]				
	mov	esi, r15d				
L_220:	mov	ebp, r15d				
	mov	r14d, esi				
	movsxd	rax, esi				
L_221:	movsxd	rdx, ebp				
L_222:	cmp	r14d, 5 				
	jg	L_223					
	mov	cl, byte [r13+r12]			
	mov	qword [rsp+28H], rax			
	mov	qword [rsp+20H], rdx			
	mov	byte [rsp+30H], 75			
	mov	byte [rsp+33H], 118			
	mov	byte [rsp+31H], cl			
	mov	cl, byte [rbx+rax]			
	mov	byte [rsp+34H], 75			
	mov	byte [rsp+37H], 0			
	mov	byte [rsp+32H], cl			
	mov	cl, byte [rbx+rdx]			
	mov	byte [rsp+35H], cl			
	movsxd	rcx, r14d				
	inc	r14d					
	mov	cl, byte [rbx+rcx]			
	mov	byte [rsp+36H], cl			
	mov	rcx, rdi				
	call	_ZL7init_tbPc.constprop4		
	mov	rax, qword [rsp+28H]			
	mov	rdx, qword [rsp+20H]			
	jmp	L_222					

L_223:	inc	ebp					
	cmp	ebp, 6					
	jz	L_224					
	cmp	r15d, ebp				
	mov	r14d, ebp				
	cmove	r14d, esi				
	jmp	L_221					

L_224:	inc	esi					
	cmp	esi, 6					
	jne	L_220					
	inc	r12					
	cmp	r12, 5					
	jne	L_219					
	lea	r14, [ L_353]			
	xor	edi, edi				
	lea	r12, [rsp+30H]				
L_225:	lea	esi, [rdi+1H]				
L_226:	movsxd	rax, esi				
	mov	ebp, esi				
	mov	al, byte [rbx+rax]			
L_227:	xor	r13d, r13d				
	movsxd	rdx, ebp				
L_228:	mov	cl, byte [rdi+r14]			
	inc	r13					
	mov	byte [rsp+32H], al			
	mov	byte [rsp+28H], al			
	lea	r15, [ L_353]			
	mov	qword [rsp+20H], rdx			
	mov	byte [rsp+30H], 75			
	mov	byte [rsp+31H], cl			
	mov	cl, byte [rbx+rdx]			
	mov	byte [rsp+34H], 118			
	mov	byte [rsp+35H], 75			
	mov	byte [rsp+37H], 0			
	mov	byte [rsp+33H], cl			
	mov	cl, byte [r13+r14-1H]			
	mov	byte [rsp+36H], cl			
	mov	rcx, r12				
	call	_ZL7init_tbPc.constprop4		
	cmp	r13, 5					
	mov	rdx, qword [rsp+20H]			
	mov	al, byte [rsp+28H]			
	jnz	L_228					
	inc	ebp					
	cmp	ebp, 6					
	jnz	L_227					
	inc	esi					
	cmp	esi, 6					
	jnz	L_226					
	inc	rdi					
	cmp	rdi, 5					
	jne	L_225					
	lea	r13, [ _ZL4pchr]			
	xor	ebx, ebx				
L_229:	mov	r14b, byte [r15+rbx]			
	lea	esi, [rbx+1H]				
L_230:	movsxd	rax, esi				
	mov	edi, esi				
	mov	al, byte [r13+rax]			
L_231:	movsxd	rdx, edi				
	mov	ebp, edi				
	mov	dl, byte [r13+rdx]			
L_232:	movsxd	rcx, ebp				
	inc	ebp					
	mov	byte [rsp+32H], al			
	mov	cl, byte [r13+rcx]			
	mov	byte [rsp+28H], al			
	mov	byte [rsp+33H], dl			
	mov	byte [rsp+20H], dl			
	mov	byte [rsp+30H], 75			
	mov	byte [rsp+34H], cl			
	mov	rcx, r12				
	mov	byte [rsp+31H], r14b			
	mov	byte [rsp+35H], 118			
	mov	byte [rsp+36H], 75			
	mov	byte [rsp+37H], 0			
	call	_ZL7init_tbPc.constprop4		
	cmp	ebp, 6					
	mov	dl, byte [rsp+20H]			
	mov	al, byte [rsp+28H]			
	jnz	L_232					
	inc	edi					
	cmp	edi, 6					
	jnz	L_231					
	inc	esi					
	cmp	esi, 6					
	jnz	L_230					
	inc	rbx					
	cmp	rbx, 5					
	jnz	L_229

L_233:	add	rsp, 72 				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15					
	ret						


Tablebase_HandlePathStrings:
	; rbx is the address of the string
	push	rsi rdi rbp
	mov	rcx, rbx
	call	StringLength
	lea	ecx, [rax+1]
	call	my_malloc
	mov	qword[_ZL11path_string], rax
	mov	rdx, rbx
	mov	rcx, rax
	call	my_strcpy
	mov	rbp, rsp
	mov	rsi, qword[_ZL11path_string]
	xor	ebx, ebx	; ebx num_paths
.GetNewPath:
	call	SkipSpaces
        push    0               ; tbs found
	push	rsi		; start of path
	add	ebx, 1
.GetNextChar:
	lodsb
	cmp	al, ' '
	jb	.DoneGettingPaths
	cmp	al, SEP_CHAR
	jne	.GetNextChar
.GotSep:
	mov	byte[rsi-1], 0
	jmp	.GetNewPath
.DoneGettingPaths:
	mov	byte[rsi-1], 0
	mov	dword[_ZL9num_paths], ebx
	imul	ecx, ebx, 16
	call	my_malloc                  ; 16 byte aligned
	mov	qword[_ZL5paths], rax
	mov	edx, ebx
.PopPath:
	sub	edx, 1
	lea	ecx, [rdx+rbx]
	jl	.PopPathDone
	pop	qword[rax+8*rdx]        ; pathstring
	pop     qword[rax+8*rcx]        ; 0 (tbs found)
	jmp	.PopPath
.PopPathDone:
	pop	rbp rdi rsi
	ret


Tablebase_DisplayInfo:
           push  rbx rsi rdi
            xor  esi, esi
.PrintNext:
            lea  rdi, [Output]
            cmp  esi, dword[_ZL9num_paths]
            jae  .PrintDone
            mov  rax, 'info str'
          stosq
            mov  rax, 'ing foun'
          stosq
            mov  eax, 'd '
          stosw
            mov  eax, esi
            add  eax, dword[_ZL9num_paths]
            mov  rcx, qword[_ZL5paths]
            mov  eax, dword[rcx+8*rax]
           call  PrintUnsignedInteger
            mov  rax, ' tableba'
          stosq
            mov  rax, 'ses in "'
          stosq
            mov  rcx, qword[_ZL5paths]
            mov  rcx, [rcx+8*rsi]
           call  PrintString
            mov  al, '"'
          stosb
        PrintNL
           call  WriteLine_Output
            add  esi, 1
            jmp  .PrintNext
.PrintDone:
            lea  rdi, [Output]
            mov  rax, 'info str'
          stosq
            mov  rax, 'ing foun'
          stosq
            mov  eax, 'd '
          stosw
            mov  eax, dword[_ZL10TBnum_pawn]
            add  eax, dword[_ZL11TBnum_piece]
           call  PrintUnsignedInteger
            mov  eax, ' of '
          stosd
            mov  eax, dword[tb_total_cnt]
           call  PrintUnsignedInteger
            mov  rax, ' tableba'
          stosq
            mov  eax, 'ses'
          stosd
            sub  rdi, 1
        PrintNL
           call  WriteLine_Output
            pop  rdi rsi rbx
            ret




_ZN13TablebaseCore15probe_wdl_tableER8PositionPi:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 392				
	xor	ebx, ebx				
	mov	rdi, rcx				
	mov	r13, rdx				
	call	_Z16pos_material_keyR8Position
	mov	rcx, rdi				
	mov	qword [rsp+38H], rax			
	call	_Z11pos_KvK_keyR8Position		
	cmp	qword [rsp+38H], rax			
	je	L_281					
	mov	rsi, qword [rsp+38H]			
	shr	rsi, 54 				
	imul	rax, rsi, 80				
	lea	rsi, [ _ZL7TB_hash]			
	add	rsi, rax				
	lea	rax, [rsi+50H]				
L_234:	mov	rbx, qword [rsp+38H]			
	cmp	qword [rsi], rbx			
	jz	L_235					
	add	rsi, 16 				
	cmp	rsi, rax				
	jnz	L_234					
	mov	dword [r13], 0				
	xor	ebx, ebx				
	jmp	L_281					

L_235:	mov	rbx, qword [rsi+8H]			
	cmp	byte [rbx+18H], 0			
	jne	L_268					
	or	edx, 0FFFFFFFFH 			
	lea	rcx, [ _ZL8TB_mutex]
	call	Os_MutexLock
	cmp	byte [rbx+18H], 0			
	jne	L_267					
	mov	rax, qword [rsp+38H]			
	lea	r12, [rsp+70H]				
	xor	r8d, r8d				
	mov	rcx, rdi				
	cmp	qword [rbx+8H], rax			
	mov	rdx, r12				
	setne	r8b					
	call	_Z7prt_strR8PositionPci 		
	lea	r8, [rbx+10H]				
	mov	rcx, r12				
	lea	rdx, [ L_342]			
	call	_ZL8map_filePKcS0_Py			
	test	rax, rax				
	mov	rbp, rax				
	mov	qword [rbx], rax			
	jnz	L_236					
	lea	rcx, [ L_347]			
	mov	rdx, r12				
	call	my_printf
	jmp	L_239					

L_236:	cmp	byte [rax], 113 			
	jnz	L_237					
	cmp	byte [rax+1H], -24			
	jnz	L_237					
	cmp	byte [rax+2H], 35			
	jnz	L_237					
	cmp	byte [rax+3H], 93			
	jz	L_240					
L_237:	lea	rcx, [ L_348]			
	call	my_puts

	mov	rcx, qword [rbx]
	mov	rdx, qword [rbx+10H]
	call	Os_FileUnmap

	mov	qword [rbx], 0
L_239:	mov	qword [rsi], 0				
	xor	ebx, ebx				
	mov	dword [r13], 0
	lea	rcx, [ _ZL8TB_mutex]
	call	Os_MutexUnlock
	jmp	L_281					

L_240:	mov	al, byte [rax+4H]			
	lea	rsi, [rbp+5H]				
	mov	r12b, al				
	and	eax, 02H				
	and	r12d, 01H				
	cmp	al, 1					
	sbb	eax, eax				
	mov	dword [rsp+30H], eax			
	and	dword [rsp+30H], 0FFFFFFFDH		
	add	dword [rsp+30H], 4			
	cmp	byte [rbx+1BH], 0			
	jne	L_249					
	movzx	ecx, byte [rbx+19H]			
	xor	eax, eax				
L_241:	cmp	ecx, eax				
	jle	L_242					
	mov	dl, byte [rbp+rax+6H]			
	and	edx, 0FH				
	mov	byte [rbx+rax+60H], dl			
	inc	rax					
	jmp	L_241					

L_242:	lea	r9, [rbx+6CH]				
	mov	r13b, byte [rbp+5H]			
	mov	rcx, rbx				
	lea	r8, [rbx+60H]				
	mov	rdx, r9 				
	mov	qword [rsp+30H], r9			
	call	_ZL14set_norm_pieceP13TBEntry_piecePhS1_
	movzx	eax, byte [rbx+1CH]			
	lea	rcx, [rbx+30H]				
	movzx	edx, byte [rbx+19H]			
	mov	r9, qword [rsp+30H]			
	and	r13d, 0FH				
	mov	r8d, r13d				
	mov	dword [rsp+20H], eax			
	call	_ZL18calc_factors_piecePiiiPhh		
	movzx	edx, byte [rbx+19H]			
	xor	ecx, ecx				
	mov	r13, rax				
	mov	qword [rsp+80H], rax			
L_243:	cmp	edx, ecx				
	jle	L_244					
	movzx	eax, byte [rbp+rcx+6H]			
	sar	eax, 4					
	mov	byte [rbx+rcx+66H], al			
	inc	rcx					
	jmp	L_243					

L_244:	lea	r9, [rbx+72H]				
	movzx	ebp, byte [rbp+5H]			
	mov	rcx, rbx				
	lea	r8, [rbx+66H]				
	mov	rdx, r9 				
	mov	qword [rsp+30H], r9			
	call	_ZL14set_norm_pieceP13TBEntry_piecePhS1_
	movzx	eax, byte [rbx+1CH]			
	lea	rcx, [rbx+48H]				
	movzx	edx, byte [rbx+19H]			
	lea	r14, [rsp+68H]				
	mov	r9, qword [rsp+30H]			
	lea	r15, [rsp+67H]				
	sar	ebp, 4					
	mov	r8d, ebp				
	mov	dword [rsp+20H], eax			
	call	_ZL18calc_factors_piecePiiiPhh		
	mov	r9, r14 				
	mov	rdx, r13				
	mov	qword [rsp+88H], rax			
	mov	rbp, rax				
	movzx	eax, byte [rbx+19H]			
	mov	dword [rsp+28H], 1			
	mov	qword [rsp+20H], r15			
	lea	rcx, [rsi+rax+1H]			
	lea	rsi, [rsp+0C0H] 			
	mov	rax, rcx				
	and	eax, 01H				
	mov	r8, rsi 				
	add	rcx, rax				
	call	_ZL11setup_pairsPhyPyPS_S_i		
	test	r12b, r12b				
	mov	rcx, qword [rsp+68H]			
	mov	qword [rbx+20H], rax			
	jz	L_245					
	mov	qword [rsp+20H], r15			
	lea	r8, [rsi+18H]				
	mov	r9, r14 				
	mov	rdx, rbp				
	mov	dword [rsp+28H], 1			
	call	_ZL11setup_pairsPhyPyPS_S_i		
	mov	rcx, qword [rsp+68H]			
	mov	qword [rbx+28H], rax			
	jmp	L_246					

L_245:	mov	qword [rbx+28H], 0			
L_246:	mov	rax, qword [rbx+20H]			
	mov	qword [rax], rcx			
	add	rcx, qword [rsp+0C0H]			
	test	r12b, r12b				
	jz	L_247					
	mov	rdx, qword [rbx+28H]			
	mov	qword [rdx], rcx			
	add	rcx, qword [rsp+0D8H]			
L_247:	mov	qword [rax+8H], rcx			
	add	rcx, qword [rsp+0C8H]			
	test	r12b, r12b				
	jz	L_248					
	mov	rdx, qword [rbx+28H]			
	mov	qword [rdx+8H], rcx			
	add	rcx, qword [rsp+0E0H]			
L_248:	add	rcx, 63 				
	and	rcx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [rax+10H], rcx			
	add	rcx, qword [rsp+0D0H]			
	test	r12b, r12b				
	je	L_266					
	mov	rax, qword [rbx+28H]			
	add	rcx, 63 				
	and	rcx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [rax+10H], rcx			
	jmp	L_266					

L_249:	cmp	byte [rbx+1DH], 1			
	lea	r13, [rsp+80H]				
	mov	rbp, rbx				
	mov	r11, r13				
	sbb	eax, eax				
	xor	r14d, r14d				
	mov	dword [rsp+58H], eax			
	add	dword [rsp+58H], 2			
L_250:	mov	al, byte [rbx+1DH]			
	mov	r9d, 15 				
	mov	r15b, byte [rsi]			
	cmp	al, 1					
	sbb	r10d, r10d				
	mov	edx, r15d				
	and	edx, 0FH				
	add	r10d, 2 				
	test	al, al					
	mov	dword [rsp+40H], edx			
	jz	L_251					
	mov	r9b, byte [rsi+1H]			
	and	r9d, 0FH				
L_251:	movzx	ecx, byte [rbx+19H]			
	movsxd	rdx, r10d				
	xor	eax, eax				
	add	rdx, rsi				
L_252:	cmp	ecx, eax				
	jle	L_253					
	mov	r8b, byte [rdx+rax]			
	and	r8d, 0FH				
	mov	byte [rbp+rax+60H], r8b 		
	inc	rax					
	jmp	L_252					

L_253:	lea	r15, [rbp+6CH]				
	mov	rcx, rbx				
	mov	qword [rsp+50H], r11			
	lea	r8, [rbp+60H]				
	mov	rdx, r15				
	mov	dword [rsp+48H], r10d			
	mov	dword [rsp+5CH], r9d			
	call	_ZL13set_norm_pawnP12TBEntry_pawnPhS1_	
	movzx	edx, byte [rbx+19H]			
	lea	rcx, [rbp+30H]				
	mov	qword [rsp+20H], r15			
	mov	r9d, dword [rsp+5CH]			
	mov	dword [rsp+28H], r14d			
	mov	r8d, dword [rsp+40H]			
	call	_ZL17calc_factors_pawnPiiiiPhi		
	movzx	r15d, byte [rsi]			
	mov	r9d, 15 				
	mov	r11, qword [rsp+50H]			
	movsxd	r10, dword [rsp+48H]			
	sar	r15d, 4 				
	cmp	byte [rbx+1DH], 0			
	mov	qword [r11], rax			
	mov	dword [rsp+40H], r15d			
	jz	L_254					
	movzx	r9d, byte [rsi+1H]			
	sar	r9d, 4					
L_254:	movzx	edx, byte [rbx+19H]			
	xor	eax, eax				
	add	r10, rsi				
L_255:	cmp	edx, eax				
	jle	L_256					
	movzx	ecx, byte [r10+rax]			
	sar	ecx, 4					
	mov	byte [rbp+rax+66H], cl			
	inc	rax					
	jmp	L_255					

L_256:	lea	r15, [rbp+72H]				
	mov	rcx, rbx				
	mov	qword [rsp+48H], r11			
	lea	r8, [rbp+66H]				
	mov	rdx, r15				
	mov	dword [rsp+50H], r9d			
	call	_ZL13set_norm_pawnP12TBEntry_pawnPhS1_	
	movzx	edx, byte [rbx+19H]			
	lea	rcx, [rbp+48H]				
	mov	dword [rsp+28H], r14d			
	mov	r9d, dword [rsp+50H]			
	mov	qword [rsp+20H], r15			
	inc	r14d					
	add	rbp, 88 				
	mov	r8d, dword [rsp+40H]			
	call	_ZL17calc_factors_pawnPiiiiPhi		
	mov	r11, qword [rsp+48H]			
	mov	qword [r11+8H], rax			
	movzx	eax, byte [rbx+19H]			
	add	r11, 16 				
	add	eax, dword [rsp+58H]			
	cdqe						
	add	rsi, rax				
	cmp	r14d, 4 				
	jne	L_250					
	lea	rax, [rsp+68H]				
	mov	rcx, rsi				
	mov	dword [rsp+58H], 0			
	lea	r15, [rsp+0C0H] 			
	and	ecx, 01H				
	mov	qword [rsp+40H], rax			
	lea	r14, [rbx+28H]				
	add	rcx, rsi				
	mov	rbp, r15				
	lea	rsi, [rsp+67H]				
L_257:	mov	dword [rsp+28H], 1			
	mov	r9, qword [rsp+40H]			
	mov	r8, rbp 				
	mov	qword [rsp+20H], rsi			
	mov	rdx, qword [r13]			
	call	_ZL11setup_pairsPhyPyPS_S_i		
	test	r12b, r12b				
	mov	qword [r14-8H], rax			
	mov	rcx, qword [rsp+68H]			
	jz	L_258					
	mov	rdx, qword [r13+8H]			
	lea	r8, [rbp+18H]				
	mov	qword [rsp+20H], rsi			
	mov	r9, qword [rsp+40H]			
	mov	dword [rsp+28H], 1			
	call	_ZL11setup_pairsPhyPyPS_S_i		
	mov	qword [r14], rax			
	mov	rcx, qword [rsp+68H]			
	jmp	L_259					

L_258:	mov	qword [r14], 0				
L_259:	inc	dword [rsp+58H] 			
	add	r13, 16 				
	add	rbp, 48 				
	add	r14, 88 				
	mov	eax, dword [rsp+58H]			
	cmp	eax, dword [rsp+30H]			
	jnz	L_257					
	lea	rax, [rbx+20H]				
	mov	rdx, r15				
	xor	r9d, r9d				
	mov	r8, rax 				
L_260:	mov	r11, qword [r8] 			
	mov	qword [r11], rcx			
	add	rcx, qword [rdx]			
	test	r12b, r12b				
	jz	L_261					
	mov	r11, qword [r8+8H]			
	mov	qword [r11], rcx			
	add	rcx, qword [rdx+18H]			
L_261:	inc	r9d					
	add	r8, 88					
	add	rdx, 48 				
	cmp	r9d, dword [rsp+30H]			
	jnz	L_260					
	mov	rdx, r15				
	mov	r8, rax 				
	xor	r9d, r9d				
L_262:	mov	r11, qword [r8] 			
	mov	qword [r11+8H], rcx			
	add	rcx, qword [rdx+8H]			
	test	r12b, r12b				
	jz	L_263					
	mov	r11, qword [r8+8H]			
	mov	qword [r11+8H], rcx			
	add	rcx, qword [rdx+20H]			
L_263:	inc	r9d					
	add	r8, 88					
	add	rdx, 48 				
	cmp	r9d, dword [rsp+30H]			
	jnz	L_262					
	xor	edx, edx				
L_264:	mov	r8, qword [rax] 			
	add	rcx, 63 				
	and	rcx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [r8+10H], rcx			
	add	rcx, qword [r15+10H]			
	test	r12b, r12b				
	jz	L_265					
	mov	r8, qword [rax+8H]			
	add	rcx, 63 				
	and	rcx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [r8+10H], rcx			
	add	rcx, qword [r15+28H]			
L_265:	inc	edx					
	add	rax, 88 				
	add	r15, 48 				
	cmp	edx, dword [rsp+30H]			
	jnz	L_264					
L_266:	mov	byte [rbx+18H], 1			
L_267:	lea	rcx, [_ZL8TB_mutex]
	call	Os_MutexUnlock
L_268:	cmp	byte [rbx+1AH], 0			
	jnz	L_270					
	mov	rax, qword [rsp+38H]			
	mov	rcx, rdi				
	cmp	rax, qword [rbx+8H]			
	jz	L_269					
	call	_Z16pos_side_to_moveR8Position		
	xor	esi, esi				
	mov	ebp, 8					
	mov	r12d, 56				
	test	eax, eax				
	sete	sil					
	jmp	L_271					

L_269:	call	_Z16pos_side_to_moveR8Position		
	xor	esi, esi				
	test	eax, eax				
	setne	sil					
	xor	ebp, ebp				
	xor	r12d, r12d				
	jmp	L_271					

L_270:	mov	rcx, rdi				
	call	_Z16pos_side_to_moveR8Position		
	mov	rcx, rdi				
	cmp	eax, 1					
	sbb	ebp, ebp				
	call	_Z16pos_side_to_moveR8Position		
	not	ebp					
	and	ebp, 08H				
	cmp	eax, 1					
	sbb	r12d, r12d				
	xor	esi, esi				
	not	r12d					
	and	r12d, 38H				
L_271:	cmp	byte [rbx+1BH], 0			
	jnz	L_275					
	imul	rax, rsi, 6
	xor	r12d, r12d				
	lea	r13, [rbx+rax+60H]			
L_272:	movzx	eax, byte [rbx+19H]			
	cmp	r12d, eax				
	jge	L_274					
	movsxd	rax, r12d				
	mov	rcx, rdi				
	movzx	edx, byte [r13+rax]			
	mov	r8d, edx				
	xor	edx, ebp				
	sar	edx, 3					
	and	r8d, 07H				
	call	_Z10pos_piecesR8Position5Color9PieceType
L_273:	lea	rdx, [rax-1H]				
	movsxd	rcx, r12d				
	inc	r12d					
	bsf	r8, rax 				
	and	rax, rdx				
	mov	dword [rsp+rcx*4+0C0H], r8d		
	jnz	L_273					
	jmp	L_272					

L_274:	imul	rax, rsi, 24				
	mov	rcx, rbx				
	imul	rdx, rsi, 6				
	add	rsi, 4					
	lea	r8, [rsp+0C0H]				
	lea	r9, [rbx+rax+30H]			
	lea	rdx, [rbx+rdx+6CH]			
	call	_ZL12encode_pieceP13TBEntry_piecePhPiS2_
	mov	rcx, qword [rbx+rsi*8]			
	jmp	L_280					

L_275:
	movzx	r8d, byte [rbx+60H]
	lea	r14, [rsp+0C0H] 			
	mov	rcx, rdi				
	xor	r8d, ebp				
	mov	edx, r8d				
	and	r8d, 07H				
	sar	edx, 3					
	call	_Z10pos_piecesR8Position5Color9PieceType
	xor	edx, edx
L_276:	bsf	rcx, rax				
	lea	r8, [rax-1H]				
	xor	ecx, r12d				
	lea	r9d, [rdx+1H]				
	mov	dword [r14+rdx*4], ecx			
	inc	rdx					
	and	rax, r8 				
	jnz	L_276					
	lea	rcx, [rbx+1CH]				
	mov	rdx, r14				
	mov	r13d, r9d				
	call	_ZL9pawn_fileP12TBEntry_pawnPi.isra0	
	imul	rdx, rsi, 6				
	cdqe						
	mov	qword [rsp+30H], rax			
	imul	rax, rax, 88				
	lea	r15, [rdx+rax+60H]			
	add	r15, rbx				
L_277:	movzx	eax, byte [rbx+19H]			
	cmp	r13d, eax				
	jge	L_279					
	movsxd	rax, r13d				
	mov	rcx, rdi				
	movzx	edx, byte [r15+rax]			
	mov	r8d, edx				
	xor	edx, ebp				
	sar	edx, 3					
	and	r8d, 07H				
	call	_Z10pos_piecesR8Position5Color9PieceType
L_278:	lea	rcx, [rax-1H]
	movsxd	r8, r13d				
	inc	r13d					
	bsf	rdx, rax				
	xor	edx, r12d				
	and	rax, rcx				
	mov	dword [rsp+r8*4+0C0H], edx		
	jnz	L_278					
	jmp	L_277					

L_279:	imul	rax, qword [rsp+30H], 88		
	mov	r8, r14 				
	imul	rdx, rsi, 24				
	lea	rcx, [rdx+rax+30H]			
	imul	rdx, rsi, 6				
	lea	r9, [rbx+rcx]				
	mov	rcx, rbx				
	lea	rax, [rax+rdx+60H]			
	lea	rdx, [rbx+rax+0CH]			
	call	_ZL11encode_pawnP12TBEntry_pawnPhPiS2_
	imul	r13, qword [rsp+30H], 11
	lea	rdx, [rsi+r13+4H]			
	mov	rcx, qword [rbx+rdx*8]			
L_280:	mov	rdx, rax				
	call	_Z16decompress_pairsILb1EEhP9PairsDatay
	movzx	eax, al




	lea	ebx, [rax-2H]				
L_281:	mov	eax, ebx				
	add	rsp, 392				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15
	ret

_ZN13TablebaseCore15probe_dtz_tableER8PositioniPi:
	push	r15					
	push	r14					
	push	r13					
	push	r12					
	push	rbp					
	push	rdi					
	push	rsi					
	push	rbx					
	sub	rsp, 248				
	mov	rbx, rcx				
	mov	dword [rsp+148H], edx			
	mov	qword [rsp+150H], r8			
	call	_Z16pos_material_keyR8Position		
	cmp	qword [ _ZL9DTZ_table], rax		
	mov	rbp, rax				
	je	L_286					
	cmp	qword [ L_333], rax			
	je	L_286					
	lea	rdx, [ _ZL9DTZ_table]		
	mov	eax, 1					
	mov	r8, rdx 				
L_282:	cmp	qword [rdx+18H], rbp			
	jz	L_284					
	inc	eax					
	add	rdx, 24 				
	cmp	eax, 64 				
	jnz	L_282					
	lea	r13, [ _ZL7TB_hash]			
	mov	rax, rbp				
	shr	rax, 54 				
	imul	rax, rax, 80				
	add	rax, r13				
	lea	rdx, [rax+50H]				
L_283:	cmp	qword [rax], rbp			
	je	L_305					
	add	rax, 16 				
	cmp	rax, rdx				
	jnz	L_283					
	jmp	L_304					

L_284:	movsxd	rdx, eax				
	imul	rdx, rdx, 24				
	add	rdx, r8 				
	mov	r12, qword [rdx]			
	mov	r11, qword [rdx+8H]			
	mov	r10, qword [rdx+10H]			
	mov	edx, 6					
L_285:	lea	r9d, [rax-1H]				
	cdqe						
	mov	rcx, rdx				
	imul	rax, rax, 24				
	movsxd	rsi, r9d				
	imul	rsi, rsi, 24				
	add	rax, r8 				
	add	rsi, r8 				
	test	r9d, r9d				
	mov	rdi, rax				
	rep movsd					
	mov	eax, r9d				
	jnz	L_285					
	mov	qword [ _ZL9DTZ_table], r12		
	mov	qword [ L_333], r11			
	mov	qword [ L_334], r10			
L_286:	mov	rsi, qword [ L_334]			
	test	rsi, rsi				
	je	L_304					
	cmp	byte [rsi+1AH], 0			
	mov	rcx, rbx				
	jnz	L_288					
	cmp	rbp, qword [rsi+8H]			
	jz	L_287					
	call	_Z16pos_side_to_moveR8Position		
	xor	r15d, r15d				
	mov	edi, 8					
	mov	ebp, 56 				
	test	eax, eax				
	sete	r15b					
	jmp	L_289					

L_287:	call	_Z16pos_side_to_moveR8Position		
	xor	r15d, r15d				
	test	eax, eax				
	setne	r15b					
	xor	edi, edi				
	xor	ebp, ebp				
	jmp	L_289					

L_288:	call	_Z16pos_side_to_moveR8Position		
	mov	rcx, rbx				
	cmp	eax, 1					
	sbb	edi, edi				
	call	_Z16pos_side_to_moveR8Position		
	not	edi					
	and	edi, 08H				
	cmp	eax, 1					
	sbb	ebp, ebp				
	xor	r15d, r15d				
	not	ebp					
	and	ebp, 38H				
L_289:	cmp	byte [rsi+1BH], 0			
	jne	L_296					
	mov	al, byte [rsi+4CH]			
	and	eax, 01H				
	cmp	eax, r15d				
	jz	L_292					
	cmp	byte [rsi+1AH], 0			
	jnz	L_292					
L_290:	mov	rax, qword [rsp+150H]			
	mov	dword [rax], -1 			
L_291:	xor	eax, eax				
	jmp	L_332					

L_292:	lea	r12, [rsi+40H]				
	xor	ebp, ebp				
L_293:	movzx	eax, byte [rsi+19H]			
	cmp	ebp, eax				
	jge	L_295					
	movsxd	rax, ebp				
	mov	rcx, rbx				
	movzx	edx, byte [r12+rax]			
	mov	r8d, edx				
	xor	edx, edi				
	sar	edx, 3					
	and	r8d, 07H				
	call	_Z10pos_piecesR8Position5Color9PieceType
L_294:	lea	rdx, [rax-1H]				
	movsxd	rcx, ebp				
	inc	ebp					
	bsf	r8, rax 				
	and	rax, rdx				
	mov	dword [rsp+rcx*4+90H], r8d		
	jnz	L_294					
	jmp	L_293					

L_295:	lea	r8, [rsp+90H]				
	mov	rcx, rsi				
	lea	rdx, [rsi+46H]				
	lea	r9, [rsi+28H]				
	call	_ZL12encode_pieceP13TBEntry_piecePhPiS2_
	mov	rcx, qword [rsi+20H]			
	mov	rdx, rax				
	call	_Z16decompress_pairsILb1EEhP9PairsDatay 
	mov	r8b, byte [rsi+4CH]			
	movzx	edx, al 				
	mov	eax, dword [rsp+148H]			
	test	r8b, 02H				
	lea	ecx, [rax+2H]				
	je	L_302					
	lea	r9, [ _ZL10wdl_to_map]		
	movsxd	rax, ecx				
	movsxd	rax, dword [r9+rax*4]			
	movzx	eax, word [rsi+rax*2+4EH]		
	add	edx, eax				
	mov	rax, qword [rsi+58H]			
	movsxd	rdx, edx				
	jmp	L_301					

L_296:	movzx	r8d, byte [rsi+40H]			
	lea	r13, [rsp+90H]				
	mov	rcx, rbx				
	xor	r8d, edi				
	mov	edx, r8d				
	and	r8d, 07H				
	sar	edx, 3					
	call	_Z10pos_piecesR8Position5Color9PieceType
	xor	edx, edx				
L_297:	bsf	rcx, rax				
	lea	r8, [rax-1H]				
	xor	ecx, ebp				
	lea	r14d, [rdx+1H]				
	mov	dword [r13+rdx*4], ecx			
	inc	rdx					
	and	rax, r8 				
	jnz	L_297					
	lea	rcx, [rsi+1CH]				
	mov	rdx, r13				
	call	_ZL9pawn_fileP12TBEntry_pawnPi.isra0
	movsxd	r12, eax				
	mov	al, byte [rsi+r12+0E0H] 		
	and	eax, 01H				
	cmp	eax, r15d				
	jne	L_290					
	imul	rax, r12, 48				
	lea	r15, [rsi+rax+40H]			
L_298:	movzx	eax, byte [rsi+19H]			
	cmp	r14d, eax				
	jge	L_300					
	movsxd	rax, r14d				
	mov	rcx, rbx				
	movzx	edx, byte [r15+rax]			
	mov	r8d, edx				
	xor	edx, edi				
	sar	edx, 3					
	and	r8d, 07H				
	call	_Z10pos_piecesR8Position5Color9PieceType
L_299:	lea	rcx, [rax-1H]				
	movsxd	r8, r14d				
	inc	r14d					
	bsf	rdx, rax				
	xor	edx, ebp				
	and	rax, rcx				
	mov	dword [rsp+r8*4+90H], edx		
	jnz	L_299					
	jmp	L_298					

L_300:	imul	rbx, r12, 48				
	mov	r8, r13 				
	mov	rcx, rsi				
	lea	rdx, [rsi+rbx+46H]			
	lea	r9, [rsi+rbx+28H]			
	call	_ZL11encode_pawnP12TBEntry_pawnPhPiS2_	
	mov	rcx, qword [rsi+rbx+20H]		
	mov	rdx, rax				
	call	_Z16decompress_pairsILb1EEhP9PairsDatay 
	mov	r8b, byte [rsi+r12+0E0H]		
	movzx	edx, al 				
	mov	eax, dword [rsp+148H]			
	test	r8b, 02H				
	lea	ecx, [rax+2H]				
	jz	L_302					
	lea	r9, [ _ZL10wdl_to_map]		
	movsxd	rax, ecx				
	movsxd	rax, dword [r9+rax*4]			
	lea	rax, [rax+r12*4+70H]			
	movzx	eax, word [rsi+rax*2+4H]		
	add	edx, eax				
	mov	rax, qword [rsi+108H]			
	movsxd	rdx, edx				
L_301:	movzx	edx, byte [rax+rdx]			
L_302:	lea	rax, [ _ZL8pa_flags]		
	movsxd	rcx, ecx				
	test	byte [rax+rcx], r8b			
	jz	L_303					
	test	byte [rsp+148H], 01H			
	mov	eax, edx				
	je	L_332					
L_303:	lea	eax, [rdx+rdx]				
	jmp	L_332					

L_304:	mov	rax, qword [rsp+150H]			
	mov	dword [rax], 0				
	jmp	L_291					

L_305:	mov	rax, qword [rax+8H]			
	lea	r14, [rsp+60H]				
	mov	rcx, rbx				
	mov	rdx, r14				
	cmp	qword [rax+8H], rbp			
	setne	r12b					
	movzx	r15d, r12b				
	mov	r8d, r15d				
	call	_Z7prt_strR8PositionPci 		
	mov	rcx, qword [ L_337]			
	test	rcx, rcx				
	jz	L_306					
	call	_ZL14free_dtz_entryP7TBEntry		
L_306:	lea	r9, [ L_336]			
	xor	eax, eax				
	mov	edx, 6					
	lea	r8, [ L_335]			
L_307:	lea	rdi, [r9+rax]				
	mov	rcx, rdx				
	lea	rsi, [r8+rax]				
	sub	rax, 24 				
	rep movsd					
	cmp	rax, -1512				
	jnz	L_307					
	xor	r12d, 01H				
	mov	rcx, rbx				
	movzx	edx, r12b				
	call	_Z8calc_keyR8Positioni			
	mov	edx, r15d				
	mov	rcx, rbx				
	mov	rsi, rax				
	call	_Z8calc_keyR8Positioni			
	mov	qword [ L_333], rsi			
	mov	rdx, rax				
	mov	rcx, rax				
	mov	qword [ _ZL9DTZ_table], rax		
	mov	qword [ L_334], 0			
	shr	rdx, 54 				
	imul	rdx, rdx, 80				
	add	r13, rdx				
	lea	rax, [r13+50H]				
L_308:	cmp	qword [r13], rcx			
	jz	L_309					
	add	r13, 16 				
	cmp	r13, rax				
	jnz	L_308					
	jmp	L_286					

L_309:	mov	rsi, qword [r13+8H]			
	cmp	byte [rsi+1BH], 1			
	sbb	rcx, rcx				
	and	cl, 50H 				
	add	rcx, 272				
	call	my_malloc
	lea	rdx, [ L_349]			
	mov	rcx, r14				
	lea	r8, [rax+10H]				
	mov	r12, rax				
	call	_ZL8map_filePKcS0_Py			
	mov	rdx, qword [rsi+8H]			
	mov	qword [r12], rax			
	mov	qword [r12+8H], rdx			
	mov	dl, byte [rsi+19H]			
	mov	byte [r12+19H], dl			
	mov	dl, byte [rsi+1AH]			
	mov	byte [r12+1AH], dl			
	mov	dl, byte [rsi+1BH]			
	test	dl, dl					
	mov	byte [r12+1BH], dl			
	jz	L_310					
	mov	dl, byte [rsi+1CH]			
	mov	byte [r12+1CH], dl			
	mov	dl, byte [rsi+1DH]			
	mov	byte [r12+1DH], dl			
	jmp	L_311					

L_310:	mov	dl, byte [rsi+1CH]			
	mov	byte [r12+1CH], dl			
L_311:	test	rax, rax				
	je	L_330					
	cmp	byte [rax], -41 			
	jnz	L_312					
	cmp	byte [rax+1H], 102			
	jnz	L_312					
	cmp	byte [rax+2H], 12			
	jnz	L_312					
	cmp	byte [rax+3H], -91			
	jz	L_313					
L_312:	lea	rcx, [ L_348]			
	call	my_puts
	jmp	L_330					

L_313:	mov	dl, byte [rax+4H]			
	lea	rsi, [rax+5H]				
	and	edx, 02H				
	cmp	dl, 1					
	sbb	r13d, r13d				
	and	r13d, 0FFFFFFFDH			
	add	r13d, 4 				
	cmp	byte [r12+1BH], 0			
	jne	L_318					
	movzx	r8d, byte [r12+19H]			
	xor	edx, edx				
L_314:	cmp	r8d, edx				
	jle	L_315					
	mov	cl, byte [rax+rdx+6H]			
	and	ecx, 0FH				
	mov	byte [r12+rdx+40H], cl			
	inc	rdx					
	jmp	L_314					

L_315:	lea	r9, [r12+46H]				
	mov	dil, byte [rax+5H]			
	mov	rcx, r12				
	lea	r8, [r12+40H]				
	mov	rdx, r9 				
	mov	qword [rsp+38H], r9			
	call	_ZL14set_norm_pieceP13TBEntry_piecePhS1_
	movzx	eax, byte [r12+1CH]			
	lea	rcx, [r12+28H]				
	movzx	edx, byte [r12+19H]			
	mov	r9, qword [rsp+38H]			
	and	edi, 0FH				
	mov	r8d, edi				
	mov	dword [rsp+20H], eax			
	call	_ZL18calc_factors_piecePiiiPhh		
	movzx	edx, byte [r12+19H]			
	lea	r9, [rsp+58H]				
	mov	dword [rsp+28H], 0			
	lea	r8, [rsi+rdx+1H]			
	lea	rdx, [r12+4CH]				
	mov	rcx, r8 				
	and	ecx, 01H				
	mov	qword [rsp+20H], rdx			
	mov	rdx, rax				
	add	rcx, r8 				
	lea	r8, [rsp+90H]				
	call	_ZL11setup_pairsPhyPyPS_S_i		
	mov	rdx, qword [rsp+58H]			
	test	byte [r12+4CH], 02H			
	mov	qword [r12+20H], rax			
	mov	qword [r12+58H], rdx			
	jz	L_317					
	mov	rcx, rdx				
	xor	r8d, r8d				
L_316:	lea	r9, [rcx+1H]				
	sub	r9, rdx 				
	mov	word [r12+r8+4EH], r9w			
	movzx	r9d, byte [rcx] 			
	add	r8, 2					
	cmp	r8, 8					
	lea	rcx, [rcx+r9+1H]			
	jnz	L_316					
	mov	rdx, rcx				
	and	edx, 01H				
	add	rdx, rcx				
L_317:	mov	qword [rax], rdx			
	add	rdx, qword [rsp+90H]			
	mov	qword [rax+8H], rdx			
	add	rdx, qword [rsp+98H]			
	add	rdx, 63 				
	and	rdx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [rax+10H], rdx			
	jmp	L_331					

L_318:	cmp	byte [r12+1DH], 1			
	lea	rdi, [r12+46H]				
	lea	r10, [rsp+70H]				
	sbb	r11d, r11d				
	xor	r14d, r14d				
	add	r11d, 2 				
L_319:	mov	cl, byte [r12+1DH]			
	mov	dword [rsp+38H], r14d			
	mov	r9d, 15 				
	mov	r15b, byte [rsi]			
	cmp	cl, 1					
	sbb	edx, edx				
	and	r15d, 0FH				
	add	edx, 2					
	test	cl, cl					
	jz	L_320					
	mov	r9b, byte [rsi+1H]			
	and	r9d, 0FH				
L_320:	movzx	eax, byte [r12+19H]			
	movsxd	rdx, edx				
	xor	ecx, ecx				
	add	rdx, rsi				
L_321:	cmp	eax, ecx				
	jle	L_322					
	mov	r8b, byte [rdx+rcx]			
	inc	rcx					
	and	r8d, 0FH				
	mov	byte [rcx+rdi-7H], r8b			
	jmp	L_321					

L_322:	lea	r8, [rdi-6H]				
	mov	rdx, rdi				
	mov	rcx, r12				
	mov	qword [rsp+48H], r10			
	mov	dword [rsp+40H], r11d			
	mov	dword [rsp+44H], r9d			
	call	_ZL13set_norm_pawnP12TBEntry_pawnPhS1_	
	mov	eax, dword [rsp+38H]			
	lea	rcx, [rdi-1EH]				
	mov	r8d, r15d				
	movzx	edx, byte [r12+19H]			
	mov	qword [rsp+20H], rdi			
	add	rdi, 48 				
	mov	r9d, dword [rsp+44H]			
	mov	dword [rsp+28H], eax			
	call	_ZL17calc_factors_pawnPiiiiPhi		
	mov	r10, qword [rsp+48H]			
	mov	r11d, dword [rsp+40H]			
	mov	qword [r10+r14*8], rax			
	movzx	eax, byte [r12+19H]			
	inc	r14					
	add	eax, r11d				
	cdqe						
	add	rsi, rax				
	cmp	r14, 4					
	jne	L_319					
	lea	rdi, [rsp+90H]				
	mov	rcx, rsi				
	lea	r15, [rsp+58H]				
	and	ecx, 01H				
	mov	r14, rdi				
	add	rcx, rsi				
	xor	esi, esi				
L_323:	mov	rdx, qword [r10+rsi*8]			
	mov	r8, rdi 				
	mov	r9, r15 				
	mov	qword [rsp+38H], r10			
	lea	rax, [r12+rsi+0E0H]			
	mov	dword [rsp+28H], 0			
	add	rdi, 24 				
	mov	qword [rsp+20H], rax			
	call	_ZL11setup_pairsPhyPyPS_S_i		
	imul	rdx, rsi, 48				
	inc	rsi					
	mov	rcx, qword [rsp+58H]			
	cmp	r13d, esi				
	mov	r10, qword [rsp+38H]			
	mov	qword [r12+rdx+20H], rax		
	jg	L_323					
	mov	r10, rcx				
	mov	qword [r12+108H], rcx			
	mov	r8, r12 				
	xor	eax, eax				
L_324:	test	byte [r12+rax+0E0H], 02H		
	jz	L_326					
	xor	edx, edx				
L_325:	lea	r9, [rcx+1H]				
	sub	r9, r10 				
	mov	word [r8+rdx+0E4H], r9w 		
	movzx	r9d, byte [rcx] 			
	add	rdx, 2					
	cmp	rdx, 8					
	lea	rcx, [rcx+r9+1H]			
	jnz	L_325					
L_326:	inc	rax					
	add	r8, 8					
	cmp	r13d, eax				
	jg	L_324					
	mov	rsi, rcx				
	xor	eax, eax				
	xor	edx, edx				
	and	esi, 01H				
	add	rcx, rsi				
L_327:	mov	r8, qword [r12+rax*2+20H]		
	inc	edx					
	mov	qword [r8], rcx 			
	add	rcx, qword [r14+rax]			
	add	rax, 24 				
	cmp	edx, r13d				
	jnz	L_327					
	lea	r8, [r14+8H]				
	xor	eax, eax				
	xor	edx, edx				
L_328:	mov	r9, qword [r12+rax*2+20H]		
	inc	edx					
	mov	qword [r9+8H], rcx			
	add	rcx, qword [r8+rax]			
	add	rax, 24 				
	cmp	edx, r13d				
	jnz	L_328					
	xor	eax, eax				
	xor	edx, edx				
	add	r14, 16 				
L_329:	mov	r8, qword [r12+rax*2+20H]		
	add	rcx, 63 				
	inc	edx					
	and	rcx, 0FFFFFFFFFFFFFFC0H 		
	mov	qword [r8+10H], rcx			
	add	rcx, qword [r14+rax]			
	add	rax, 24 				
	cmp	edx, r13d				
	jnz	L_329					
	jmp	L_331					

L_330:	mov	rcx, r12				
	call	my_free
	jmp	L_286

L_331:	mov	qword [ L_334], r12			
	jmp	L_286

L_332:	
	add	rsp, 248				
	pop	rbx					
	pop	rsi					
	pop	rdi					
	pop	rbp					
	pop	r12					
	pop	r13					
	pop	r14					
	pop	r15
	ret						
