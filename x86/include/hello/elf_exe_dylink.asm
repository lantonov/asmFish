include 'format/format.inc'
format ELF64 executable 3
entry Start

segment interpreter readable 

    db '/lib64/ld-linux-x86-64.so.2',0 

segment dynamic readable 

    dq DT_NEEDED,  _libc-strtab 
    dq DT_STRTAB,  strtab 
    dq DT_STRSZ,   strsz 
    dq DT_SYMTAB,  symtab 
    dq DT_SYMENT,  sizeof.Elf64_Sym 
    dq DT_RELA,    rela 
    dq DT_RELASZ,  relasz 
    dq DT_RELAENT, sizeof.Elf64_Rela 
    dq DT_HASH,    hash 
    dq DT_NULL,    0 

segment readable writeable 

symtab: 
    Elf64_Sym 0,               0, 0, 0,          0,        0, 0
    Elf64_Sym _write - strtab, 0, 0, STB_GLOBAL, STT_FUNC, 0, 0
    Elf64_Sym _exit  - strtab, 0, 0, STB_GLOBAL, STT_FUNC, 0, 0

strtab: 
    _null   db 0 
    _libc   db 'libc.so.6',0 
    _write  db 'write',0 
    _exit   db 'exit',0 
strsz = $ - strtab 

rela: 
    Elf64_Rela write, 1, R_X86_64_64 
    Elf64_Rela exit,  2, R_X86_64_64 
relasz = $ - rela 

hash: 
    dd 1, 3     ; size of bucket and size of chain 
    dd 0        ; fake bucket, just one hash value 
    repeat 3
        dd %    ; chain for all symbol table entries 
    end repeat

segment readable executable 

Start: 
            and  rsp, -16

            mov  edi, 1
            lea  rsi, [Message]
            mov  edx, MessageEnd - Message
           call  qword[write] 

            xor  edi, edi
           call  qword[exit] 

segment readable writeable 

write:  dq 0
exit:   dq 0

Message:
    db 'Hello World!', 10
MessageEnd:
