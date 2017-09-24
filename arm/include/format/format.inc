
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
		include 'format/elfexe.inc'
		include 'aarch64.inc'
	else match =ELF64?, clause
		include 'format/elf64.inc'
		include 'aarch64.inc'
	else
		err 'invalid argument'
	end match
end macro
