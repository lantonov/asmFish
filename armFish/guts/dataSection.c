        .balign 8
LargePageMinSize:
        .dword 0
sz_error_rook_page:
        .ascii "rook attack data is not page aligned\0"
sz_error_bishop_page:
        .ascii "bishop attack data is not page aligned\0"

sz_error_sys_mmap_VirtualAlloc:
        .ascii "sys_mmap in _VirtualAlloc failed\0"
sz_error_sys_unmap_VirtualFree:
        .ascii "sys_unmap in _VirtualFree failed\0"
sz_failed_x0:
        .ascii " x0: 0x\0"

sz_greeting:
        .ascii "greeting\0"
sz_error_unknown_command:
        .ascii "error: unknown command \0"
sz_quit:
        .ascii "quit\0"
sz_quit:
        .ascii "quit\0"
sz_sz_readyok:
        .ascii "readyok\0"

