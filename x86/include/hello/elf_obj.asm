include 'format/format.inc'
format ELF64

public main
extrn write
extrn exit

section '.code' executable align 64

main:
            mov  edi, 1
            lea  rsi, [Message]
            mov  edx, MessageEnd - Message
           call  write

            xor  edi, edi
           call  exit

section '.data' writeable align 64
db '12345'
Message:
    db 'Hello World!', 10
MessageEnd:
