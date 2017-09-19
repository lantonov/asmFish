include 'format/format.inc'
format ELF64 executable 3
entry Start

sys_write = 1
sys_exit  = 60

segment readable executable

Start:
            and  rsp, -16

            mov  edi, 1
            lea  rsi, [Message]
            mov  edx, MessageEnd - Message
            mov  eax, sys_write
	    syscall

            xor  edi, edi
            mov  eax, sys_exit
        syscall

segment readable writeable

Message:
        db 'Hello World!', 10
MessageEnd:
