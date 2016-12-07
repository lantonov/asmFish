
Pawn_Init:; Function begin
	push	r14					; 0C80 _ 41: 56
	push	r13					; 0C82 _ 41: 55
	push	r12					; 0C84 _ 41: 54
	push	rbp					; 0C86 _ 55
	push	rdi					; 0C87 _ 57
	push	rsi					; 0C88 _ 56
	push	rbx					; 0C89 _ 53
	xor	r14d, r14d				; 0C8A _ 45: 31. F6
	mov	r10d, 2 				; 0C8D _ 41: BA, 00000002
	mov	r9d, 4
	lea	rbp, [._2745]				; 0C99 _ 48: 8D. 2D, 00000764(rel)
	lea	r13, [Connected]			; 0CA0 _ 4C: 8D. 2D, 0042D780(rel)
._0056: lea	r12, [r14*4]				; 0CA7 _ 4E: 8D. 24 B5, 00000000
	mov	ecx, r14d				; 0CAF _ 44: 89. F7
	xor	esi, esi				; 0CB2 _ 31. F6
._0057: xor	ebx, ebx				; 0CB4 _ 31. DB
._0058: lea	r11, [r12+rbx]				; 0CB6 _ 4D: 8D. 1C 1C
	xor	r8d, r8d				; 0CBA _ 45: 31. C0
	shl	r11, 5					; 0CBD _ 49: C1. E3, 05
	add	r11, r13				; 0CC1 _ 4D: 01. EB
._0059: xor	eax, eax				; 0CC4 _ 31. C0
	test	esi, esi				; 0CC6 _ 85. F6
	mov	edi, dword[rbp+r8]			; 0CC8 _ 42: 8B. 4C 05, 00
	jz	._0060					; 0CCD _ 74, 11
	lea	rax, [._2746]				; 0CCF _ 48: 8D. 05, 00000768(rel)
	mov	eax, dword[rax+r8]			; 0CD6 _ 42: 8B. 04 00
	sub	eax, edi				; 0CDA _ 29. C8
	cdq						; 0CDC _ 99
	idiv	r10d					; 0CDD _ 41: F7. FA
._0060: add	edi, eax				; 0CE0 _ 01. C1
	xor	eax, eax				; 0CE2 _ 31. C0
	sar	edi, cl 				; 0CE7 _ C4 E2 42: F7. C9
	test	rbx, rbx				; 0CE4 _ 48: 85. DB
	jz	._0061					; 0CEC _ 74, 06
	mov	eax, edi				; 0CEE _ 89. C8
	cdq						; 0CF0 _ 99
	idiv	r10d					; 0CF1 _ 41: F7. FA
._0061: add	edi, eax				; 0CF4 _ 01. C1
	mov	eax, edi
	mov	edx, r8d
	shr	edx, 2
	sub	edx, 1
	mul	edx
	shl	edi, 16 				; 0CF9 _ C1. E1, 10
	cdq						; 0CFC _ 99
	idiv	r9d					; 0CFD _ 41: F7. F9
	add	eax, edi				; 0D00 _ 01. C8

     ;   cmp     dword[r11+r8+4], eax
     ;    je     @f
     ;      int3
     ;   @@:

	mov	dword[r11+r8+4], eax		       ; 0D02 _ 43: 89. 44 03, 04
	add	r8, 4					; 0D07 _ 49: 83. C0, 04
	cmp	r8, 24					; 0D0B _ 49: 83. F8, 18
	jnz	._0059					; 0D0F _ 75, B3
	sub	rbx, 1					; 0D11 _ 48: 83. EB, 01
	jz	._0062					; 0D15 _ 74, 07
	mov	ebx, 1					; 0D17 _ BB, 00000001
	jmp	._0058					; 0D1C _ EB, 98
; _ZN5Pawns4initEv End of function

._0062: ; Local function
	add	r12, 2					; 0D1E _ 49: 83. C4, 02
	sub	esi, 1					; 0D22 _ 83. EE, 01
	jz	._0063					; 0D25 _ 74, 07
	mov	esi, 1					; 0D27 _ BE, 00000001
	jmp	._0057					; 0D2C _ EB, 86

._0063: ; Local function
	sub	r14, 1					; 0D2E _ 49: 83. EE, 01
	jz	._0064					; 0D32 _ 74, 0B
	mov	r14d, 1 				; 0D34 _ 41: BE, 00000001
	jmp	._0056					; 0D3A _ E9, FFFFFF68

._0064: ; Local function
	pop	rbx					; 0D3F _ 5B
	pop	rsi					; 0D40 _ 5E
	pop	rdi					; 0D41 _ 5F
	pop	rbp					; 0D42 _ 5D
	pop	r12					; 0D43 _ 41: 5C
	pop	r13					; 0D45 _ 41: 5D
	pop	r14					; 0D47 _ 41: 5E
	ret



align 4
	db 00H, 00H, 00H, 00H				; 0760 _ ....

._2745: 						; byte
	db 08H, 00H, 00H, 00H				; 0764 _ ....

._2746: 						; byte
	db 13H, 00H, 00H, 00H, 0DH, 00H, 00H, 00H	; 0768 _ ........
	db 47H, 00H, 00H, 00H, 5EH, 00H, 00H, 00H	; 0770 _ G...^...
	db 0A9H, 00H, 00H, 00H, 44H, 01H, 00H, 00H	; 0778 _ ....D...
