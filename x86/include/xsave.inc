
if ~ defined XSAVE

	restore XSAVE	; this ensures that symbol cannot be forward-referenced
	define XSAVE 1

	iterate <instr,postbyte>, xsave,4, xrstor,5

		macro instr? src*
			x86.parse_operand @src,src
			if @src.type = 'mem'
				x86.store_instruction <0Fh,0AEh>,@src,postbyte
			else
				err 'invalid operand'
			end if
		end macro

	end iterate

	macro xgetbv?
		db 0Fh,1,0D0h
	end macro

	macro xsetbv?
		db 0Fh,1,0D1h
	end macro

end if
