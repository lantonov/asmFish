
macro format? clause
	match =ELF64? =executable? settings, clause:
		ELF.Settings.Class = ELFCLASS64
		ELF.Settings.Machine = EM_AARCH64
		ELF.Settings.BaseAddress = 400000h
        ELF.Settings.LoadHeaders = 1
		match brand =at? base:, settings
			ELF.Settings.ABI = brand
			ELF.Settings.BaseAddress = base
		else match =at? base:, settings
			ELF.Settings.BaseAddress = base
		else match brand:, settings
			ELF.Settings.ABI = brand
		end match
		include string 'targets/elfexe.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		include string 'instructions/aarch64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
	else match =ELF64?, clause
		include string 'targets/elf64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		include string 'instructions/aarch64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
	else
		err 'invalid argument'
	end match
end macro
