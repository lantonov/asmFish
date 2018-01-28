
big_multiply:
        ; inputs
		;     ebx contains multiplicand 1
		;     bigOperand contains multiplicand 2
		; output
		;     bigResult receives the result
		
        push rcx
		push rdx
		
		mov eax, dword[bigOperand]	
		mul ebx                ;EDX:EAX <= EAX*EBX
		mov dword[bigResult], eax   ;save result, part 1
		mov ecx, edx           ;save carried part in ECX
		
		mov eax, dword[bigOperand+4]
		mul ebx
		add eax, ecx           ;add carried part from previous multiplication
		mov dword[bigResult+4], eax
				
		cmp edx, 0             ;finding anything in edx implies a result that was bigger then 64 bits
		jne bm_overflow
		
		pop rdx
		pop rcx
		ret

bm_overflow:
        ; what to do here? How to handle overflow?
		pop rdx
		pop rcx
		ret

