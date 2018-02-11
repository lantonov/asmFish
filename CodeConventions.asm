The assembler works line by line, looking for the first token on the line
and handling the remaining tokens accordingly. The usual control flow constructs
like 'if' and 'then' along with macro definitions are left justified 
and indented according to their nesting depth. When a line is responsible for
outputting data, its head (usually the mnemonic) should be right justified at your
favorite center line; the arguments then should be left justified. On must do
one's best if the mnemonic doesn't fit to the left of the center line.
The anonymous labels @1, @2, and @3 should be included by default. If you think 
you need more than three anonymous labels, you don't.

Example:

                  your favorite center line
                           v
flow constructs-->         |
named labels-->            |
        anonymous labels   |
              <-- mnemonics| operands -->

		      align  16
.iteration_loop:
	       BoxFold_FMA3  ymm0, ymm1, ymm2, ymm8, ymm8, ymm8, ymm12, ymm13, ymm15
	       BoxFold_FMA3  ymm4, ymm5, ymm6, ymm8, ymm8, ymm8, ymm12, ymm13, ymm15
	    SphereFold_FMA3  ymm0, ymm1, ymm2, ymm8, ymm9, ymm10, ymm11, ymm14, ymm13
		   vcmpltpd  ymm8, ymm8, qqword[.bailr2]
		  vmovmskpd  r8d, ymm8
		vfmadd213pd  ymm0, ymm9, qqword[.C1x]
		vfmadd213pd  ymm1, ymm9, qqword[.C1y]
		vfmadd213pd  ymm2, ymm9, qqword[.C1z]
	       vfnmadd213pd  ymm3, ymm9, qqword[.C1w]   ; Abs[s] = -s
	    SphereFold_FMA3  ymm4, ymm5, ymm6, ymm8, ymm9, ymm10, ymm11, ymm14, ymm13
		   vcmpltpd  ymm8, ymm8, qqword[.bailr2]
		  vmovmskpd  r9d, ymm8
		vfmadd213pd  ymm4, ymm9, qqword[.C2x]
		vfmadd213pd  ymm5, ymm9, qqword[.C2y]
		vfmadd213pd  ymm6, ymm9, qqword[.C2z]
	       vfnmadd213pd  ymm7, ymm9, qqword[.C1w]   ; Abs[s] = -s
			 or  r8d, r9d
			 jz  @1f
			sub  eax, 1
			jnz  .iteration_loop
               @1:

     macro_with_really_big_long_tourtured_name  rax, rbx, rcx



