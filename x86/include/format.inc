
macro format? clause
	match =MZ?, clause
		include 'p6.inc'
		include 'format/mz.inc'
	else match =PE? settings, clause:
		PE.Settings.Characteristics = IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED
		PE.Settings.DllCharacteristics = 0
		local seq
		define seq settings
		while 1
			match :, seq
				break
			else match =DLL? more, seq
				PE.Settings.Characteristics = PE.Settings.Characteristics or IMAGE_FILE_DLL
				redefine seq more
			else match =large? more, seq
				PE.Settings.Characteristics = PE.Settings.Characteristics or IMAGE_FILE_LARGE_ADDRESS_AWARE
				redefine seq more
			else match =WDM? more, seq
				PE.Settings.DllCharacteristics = PE.Settings.DllCharacteristics or IMAGE_DLLCHARACTERISTICS_WDM_DRIVER
				redefine seq more
			else match =NX? more, seq
				PE.Settings.DllCharacteristics = PE.Settings.DllCharacteristics or IMAGE_DLLCHARACTERISTICS_NX_COMPAT
				redefine seq more
			else match =at? base =on? stub :, seq
				PE.Settings.ImageBase = base
				PE.Settings.Stub = stub
				break
			else match =at? base :, seq
				PE.Settings.ImageBase = base
				break
			else match =on? stub :, seq
				PE.Settings.Stub = stub
				break
			else
				match =GUI? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_WINDOWS_GUI
					redefine seq more
				else match =console? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI
					redefine seq more
				else match =native? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_NATIVE
					PE.Settings.SectionAlignment = 32
					PE.Settings.FileAlignment = 32
					redefine seq more
				else match =EFI? more, seq
					PE.Settings.Magic = 0x20B
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_APPLICATION
					redefine seq more
				else match =EFIboot? more, seq
					PE.Settings.Magic = 0x20B
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER
					redefine seq more
				else match =EFIruntime? more, seq
					PE.Settings.Magic = 0x20B
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER
					redefine seq more
				else
					err 'invalid argument'
					break
				end match
				match V.v more, seq
					PE.Settings.MajorSubsystemVersion = V
					PE.Settings.MinorSubsystemVersion = v
					redefine seq more
				end match
			end match
		end while
		include 'format/pe.inc'
		include 'p6.inc'
		use32
	else match =PE64? settings, clause:
		PE.Settings.Magic = 0x20B
		PE.Settings.Machine = IMAGE_FILE_MACHINE_AMD64
		PE.Settings.Characteristics = IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_LARGE_ADDRESS_AWARE or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED
		PE.Settings.DllCharacteristics = 0
		PE.Settings.MajorSubsystemVersion = 5
		PE.Settings.MinorSubsystemVersion = 0
		local seq
		define seq settings
		while 1
			match :, seq
				break
			else match =DLL? more, seq
				PE.Settings.Characteristics = PE.Settings.Characteristics or IMAGE_FILE_DLL
				redefine seq more
			else match =large? more, seq
				PE.Settings.Characteristics = PE.Settings.Characteristics or IMAGE_FILE_LARGE_ADDRESS_AWARE
				redefine seq more
			else match =WDM? more, seq
				PE.Settings.DllCharacteristics = PE.Settings.DllCharacteristics or IMAGE_DLLCHARACTERISTICS_WDM_DRIVER
				redefine seq more
			else match =NX? more, seq
				PE.Settings.DllCharacteristics = PE.Settings.DllCharacteristics or IMAGE_DLLCHARACTERISTICS_NX_COMPAT
				redefine seq more
			else match =at? base =on? stub :, seq
				PE.Settings.ImageBase = base
				PE.Settings.Stub = stub
				break
			else match =at? base :, seq
				PE.Settings.ImageBase = base
				break
			else match =on? stub :, seq
				PE.Settings.Stub = stub
				break
			else
				match =GUI? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_WINDOWS_GUI
					redefine seq more
				else match =console? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_WINDOWS_CUI
					redefine seq more
				else match =native? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_NATIVE
					PE.Settings.SectionAlignment = 32
					PE.Settings.FileAlignment = 32
					redefine seq more
				else match =EFI? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_APPLICATION
					redefine seq more
				else match =EFIboot? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER
					redefine seq more
				else match =EFIruntime? more, seq
					PE.Settings.Subsystem = IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER
					redefine seq more
				else
					err 'invalid argument'
					break
				end match
				match V.v more, seq
					PE.Settings.MajorSubsystemVersion = V
					PE.Settings.MinorSubsystemVersion = v
					redefine seq more
				end match
			end match
		end while
		include string 'targets/pe.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		include string 'instructions/x64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		use64
	else match =ELF? =executable? settings, clause:
		match brand =at? base:, settings
			ELF.Settings.ABI = brand
			ELF.Settings.BaseAddress = base
		else match =at? base:, settings
			ELF.Settings.BaseAddress = base
		else match brand:, settings
			ELF.Settings.ABI = brand
		end match
		include 'format/elfexe.inc'
		include 'p6.inc'
		use32
	else match =ELF64? =executable? settings, clause:
		ELF.Settings.Class = ELFCLASS64
		ELF.Settings.Machine = EM_X86_64
		ELF.Settings.BaseAddress = 400000h
		match brand =at? base:, settings
			ELF.Settings.ABI = brand
			ELF.Settings.BaseAddress = base
		else match =at? base:, settings
			ELF.Settings.BaseAddress = base
		else match brand:, settings
			ELF.Settings.ABI = brand
		end match
		include string 'targets/elfexe.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		include string 'instructions/x64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		use64
	else match =ELF?, clause
		include 'format/elf32.inc'
		include 'p6.inc'
		use32
	else match =ELF64?, clause
		include 'format/elf64.inc'
		include 'x64.inc'
		use64
	else match =COFF?, clause
		include 'format/coff.inc'
		include 'p6.inc'
		use32
	else match =MS? =COFF?, clause
		COFF.Settings.Characteristics = IMAGE_FILE_32BIT_MACHINE or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_BYTES_REVERSED_LO
		include 'format/coffms.inc'
		include 'p6.inc'
		use32
	else match =MS64? =COFF?, clause
		COFF.Settings.Machine = IMAGE_FILE_MACHINE_AMD64
		COFF.Settings.Characteristics = IMAGE_FILE_32BIT_MACHINE or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_BYTES_REVERSED_LO
		include 'format/coffms.inc'
		include 'x64.inc'
		use64
    else match =MACHO64?, clause
        MachO.Settings.ProcessorType equ CPU_TYPE_X86_64
        MachO.Settings.BaseAddress = 0x00400000
		include string 'targets/macho.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		include string 'instructions/x64.inc' shl (8*lengthof FASMG_INC) + FASMG_INC
		use64
	else
		err 'invalid argument'
	end match
end macro
