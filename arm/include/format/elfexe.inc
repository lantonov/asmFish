
ELFCLASSNONE = 0
ELFCLASS32   = 1
ELFCLASS64   = 2

ELFDATANONE = 0
ELFDATA2LSB = 1
ELFDATA2MSB = 2

ELFOSABI_NONE	  = 0
ELFOSABI_HPUX	  = 1
ELFOSABI_NETBSD   = 2
ELFOSABI_GNU	  = 3
ELFOSABI_LINUX	  = 3
ELFOSABI_SOLARIS  = 6
ELFOSABI_AIX	  = 7
ELFOSABI_IRIX	  = 8
ELFOSABI_FREEBSD  = 9
ELFOSABI_TRU64	  = 10
ELFOSABI_MODESTO  = 11
ELFOSABI_OPENBSD  = 12
ELFOSABI_OPENVMS  = 13
ELFOSABI_NSK	  = 14
ELFOSABI_AROS	  = 15
ELFOSABI_FENIXOS  = 16
ELFOSABI_CLOUDABI = 17
ELFOSABI_OPENVOS  = 18

ET_NONE   = 0
ET_REL	  = 1
ET_EXEC   = 2
ET_DYN	  = 3
ET_CORE   = 4
ET_LOPROC = 0xff00
ET_HIPROC = 0xffff

EM_NONE   = 0
EM_M32	  = 1
EM_SPARC  = 2
EM_386	  = 3
EM_68K	  = 4
EM_88K	  = 5
EM_860	  = 7
EM_MIPS   = 8
EM_X86_64 = 62
EM_AARCH64 = 183

EV_NONE    = 0
EV_CURRENT = 1

PT_NULL 	= 0
PT_LOAD 	= 1
PT_DYNAMIC	= 2
PT_INTERP	= 3
PT_NOTE 	= 4
PT_SHLIB	= 5
PT_PHDR 	= 6
PT_GNU_EH_FRAME = 0x6474e550
PT_GNU_STACK	= 0x6474e551
PT_LOPROC	= 0x70000000
PT_HIPROC	= 0x7fffffff

PF_X	    = 1
PF_W	    = 2
PF_R	    = 4
PF_MASKOS   = 0x0ff00000
PF_MASKPROC = 0xf0000000


macro Elf64_Sym name,value,size,bind,type,other,shndx
    dd name+0
    db (bind+0) shl 4 + (type+0)
    db other+0
    dw shndx+0
    dq value+0
    dq size+0
end macro
sizeof.Elf64_Sym = 24

macro Elf64_Rel offset,symbol,type
    dq offset+0
    dq (symbol+0) shl 32 + (type+0)
end macro
sizeof.Elf64_Rel = 16

macro Elf64_Rela offset,symbol,type,addend
    dq offset+0
    dq (symbol+0) shl 32 + (type+0)
    dq addend+0
end macro
sizeof.Elf64_Rela = 24

DT_NULL    = 0
DT_NEEDED  = 1
DT_HASH    = 4
DT_STRTAB  = 5
DT_SYMTAB  = 6
DT_RELA    = 7
DT_RELASZ  = 8
DT_RELAENT = 9
DT_STRSZ   = 10
DT_SYMENT  = 11
DT_REL	   = 17
DT_RELSZ   = 18
DT_RELENT  = 19

STB_LOCAL  = 0
STB_GLOBAL = 1
STB_WEAK   = 2

STT_NOTYPE  = 0
STT_OBJECT  = 1
STT_FUNC    = 2
STT_SECTION = 3
STT_FILE    = 4

R_AARCH64_NONE  = 0
R_AARCH64_ABS64 = 257


; instruction parsing macros reference this macro
; so be friendly to programmer and state the error
macro aarch64.store_reloc value, absolute, pcrel
    err 'instruction would need a relocation, but none are supported by elfexe'
end macro



macro align boundary,value:?
	db (boundary-1)-($+boundary-1) mod boundary dup value
end macro

ELF::

namespace ELF 

        if defined Settings.Class 
                CLASS := Settings.Class 
        else 
                CLASS := ELFCLASS32 
        end if 

        if defined Settings.Machine 
                MACHINE := Settings.Machine 
        else 
                MACHINE := EM_386 
        end if 

        if defined Settings.ABI 
                ABI := Settings.ABI 
        else 
                ABI := ELFOSABI_NONE 
        end if 

        if defined Settings.BaseAddress 
                BASE_ADDRESS := Settings.BaseAddress 
        else 
                BASE_ADDRESS := 8048000h 
        end if 

        if defined Settings.LoadHeaders 
                LOAD_HEADERS := Settings.LoadHeaders 
        else  
                LOAD_HEADERS := 0 
        end if  

        Header: 

        e_ident         db 0x7F,'ELF',CLASS,ELFDATA2LSB,EV_CURRENT,ABI,(16-$) dup 0 
        e_type          dw ET_EXEC 
        e_machine       dw MACHINE 
        e_version       dd EV_CURRENT 
        if CLASS <> ELFCLASS64 
         e_entry        dd start 
         e_phoff        dd ProgramHeader 
         e_shoff        dd 0 
         e_flags        dd 0 
         e_ehsize       dw ProgramHeader 
         e_phentsize    dw SEGMENT_HEADER_LENGTH 
         e_phnum        dw NUMBER_OF_SEGMENTS 
         e_shentsize    dw 28h 
         e_shnum        dw 0 
         e_shstrndx     dw 0 
        else 
         e_entry        dq start 
         e_phoff        dq ProgramHeader 
         e_shoff        dq 0 
         e_flags        dd 0 
         e_ehsize       dw ProgramHeader 
         e_phentsize    dw SEGMENT_HEADER_LENGTH 
         e_phnum        dw NUMBER_OF_SEGMENTS 
         e_shentsize    dw 40h 
         e_shnum        dw 0 
         e_shstrndx     dw 0 
        end if 

        ProgramHeader:  
        if CLASS <> ELFCLASS64  
         p_type         dd PT_LOAD  
         p_offset       dd 0  
         p_vaddr        dd BASE_ADDRESS  
         p_paddr        dd BASE_ADDRESS  
         p_filesz       dd 0  
         p_memsz        dd 0  
         p_flags        dd PF_R+PF_W+PF_X  
         p_align        dd 1000h  
        else  
         p_type         dd PT_LOAD  
         p_flags        dd PF_R+PF_W+PF_X  
         p_offset       dq 0  
         p_vaddr        dq BASE_ADDRESS  
         p_paddr        dq BASE_ADDRESS  
         p_filesz       dq 0  
         p_memsz        dq 0  
         p_align        dq 1000h  
        end if  

        SEGMENT_HEADER_LENGTH = $ - ProgramHeader 

        db (NUMBER_OF_SEGMENTS-1)*SEGMENT_HEADER_LENGTH dup 0 

        SEGMENT_INDEX = 0 
        NEXT_SEGMENT_INDEX = 0  
        SEGMENT_TYPE = PT_LOAD  
        if LOAD_HEADERS 
                FILE_OFFSET = 0 
                SEGMENT_BASE = BASE_ADDRESS 
                org SEGMENT_BASE + $% 
        else 
                FILE_OFFSET = $% 
                SEGMENT_BASE = BASE_ADDRESS + FILE_OFFSET and 0FFFh 
                org SEGMENT_BASE 
                store SEGMENT_BASE at ELF:p_vaddr 
                store SEGMENT_BASE at ELF:p_paddr 
                store FILE_OFFSET at ELF:p_offset 
        end if 
        start:  

end namespace 

macro segment?  
        namespace ELF  

                if NEXT_SEGMENT_INDEX = 0 & $ > start 
                        NEXT_SEGMENT_INDEX = 1 
                end if 

                if SEGMENT_TYPE = PT_LOAD  

                        RAW_DATA_SIZE = $%% - FILE_OFFSET  
                        SEGMENT_SIZE = $ - SEGMENT_BASE  
                        store RAW_DATA_SIZE at ELF:p_filesz+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        store SEGMENT_SIZE at ELF:p_memsz+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 

                        if NEXT_SEGMENT_INDEX > 0  
                                FILE_OFFSET = $%%  
                                align 1000h  
                                SEGMENT_BASE = $ + FILE_OFFSET and 0FFFh  
                                section SEGMENT_BASE  
                        end if  

                else  

                        FILE_OFFSET = $%  
                        SEGMENT_SIZE = $ - SEGMENT_BASE  
                        store SEGMENT_SIZE at ELF:p_filesz+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        store SEGMENT_SIZE at ELF:p_memsz+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 

                        SEGMENT_BASE = SEGMENT_BASE and not 0FFFh + FILE_OFFSET and 0FFFh 

                        if $% > $%%  
                                store 0:byte at $-1  
                        end if  
                        org SEGMENT_BASE  

                end if  

        end namespace 
end macro  

macro segment? attributes*  
        namespace ELF  
                match }, attributes  
                        segment  
                        restore SEGMENT_TYPE,SEGMENT_FLAGS,SEGMENT_INDEX,SEGMENT_BASE,FILE_OFFSET 
                        org SEGMENT_BASE + $% - FILE_OFFSET  
                else  

                        local seq,list  
                        match { _attributes, attributes  
                                define seq _attributes 
                                SEGMENT_TYPE =: PT_NULL 
                                SEGMENT_FLAGS =: 0  
                                SEGMENT_INDEX =: SEGMENT_INDEX  
                                SEGMENT_BASE =: $ 
                                FILE_OFFSET =: $% 
                                CLOSE_PREVIOUS_SEGMENT = 0 
                        else 
                                segment 
                                define seq attributes 
                                SEGMENT_TYPE = PT_LOAD  
                                SEGMENT_FLAGS = 0 
                                CLOSE_PREVIOUS_SEGMENT = 1 
                        end match 
                        while 1 
                                match car cdr, seq  
                                        define list car  
                                        define seq cdr  
                                else  
                                        match any, seq  
                                                define list any  
                                        end match  
                                        break  
                                end match  
                        end while  
                        irpv attribute, list  
                                match =readable?, attribute  
                                        SEGMENT_FLAGS = SEGMENT_FLAGS or PF_R  
                                else match =writeable?, attribute  
                                        SEGMENT_FLAGS = SEGMENT_FLAGS or PF_W  
                                else match =executable?, attribute  
                                        SEGMENT_FLAGS = SEGMENT_FLAGS or PF_X  
                                else match =interpreter?, attribute  
                                        SEGMENT_TYPE = PT_INTERP  
                                else match =dynamic?, attribute  
                                        SEGMENT_TYPE = PT_DYNAMIC  
                                else match =note?, attribute  
                                        SEGMENT_TYPE = PT_NOTE  
                                else match =gnustack?, attribute  
                                        SEGMENT_TYPE = PT_GNU_STACK  
                                else match =gnuehframe?, attribute  
                                        SEGMENT_TYPE = PT_GNU_EH_FRAME  
                                else  
                                        err 'invalid argument'  
                                end match  
                        end irpv  

                        if NEXT_SEGMENT_INDEX = 0 & ( LOAD_HEADERS & SEGMENT_TYPE <> PT_LOAD )
                                NEXT_SEGMENT_INDEX = 1 
                                FILE_OFFSET = $%% 
                                align 1000h  
                                SEGMENT_BASE = $ + FILE_OFFSET and 0FFFh  
                                section SEGMENT_BASE 
                        end if 
                        SEGMENT_INDEX = NEXT_SEGMENT_INDEX 
                        NEXT_SEGMENT_INDEX = NEXT_SEGMENT_INDEX + 1  

                        store SEGMENT_BASE at ELF:p_vaddr+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        store SEGMENT_BASE at ELF:p_paddr+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        store FILE_OFFSET at ELF:p_offset+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH
                        store SEGMENT_TYPE at ELF:p_type+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        store SEGMENT_FLAGS at ELF:p_flags+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 

                        if SEGMENT_TYPE = PT_LOAD  
                                store 1000h at ELF:p_align+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        else  
                                store 1 at ELF:p_align+SEGMENT_INDEX*SEGMENT_HEADER_LENGTH 
                        end if  
                end match  
        end namespace  
end macro  

macro entry? address*  
        namespace ELF  
                store address at ELF:e_entry  
        end namespace  
end macro  

postpone  
        purge segment?  
        segment  
        namespace ELF  
                NUMBER_OF_SEGMENTS := NEXT_SEGMENT_INDEX  
        end namespace  
end postpone
