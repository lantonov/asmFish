; instruction and format macros
include 'format/format.inc'

format ELF64 executable 3
entry Start


; code section
segment readable executable
Start:
ret
