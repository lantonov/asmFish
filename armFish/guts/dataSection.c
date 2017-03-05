sz_error_rook_page:
        .ascii "rook attack data is not page aligned"; .byte 0
sz_error_bishop_page:
        .ascii "bishop attack data is not page aligned"; .byte 0

sz_error_sys_mmap_VirtualAlloc:
        .ascii "sys_mmap in _VirtualAlloc failed"; .byte 0
sz_error_sys_unmap_VirtualFree:
        .ascii "sys_unmap in _VirtualFree failed"; .byte 0

sz_greeting:
        .ascii "greeting"; .byte 0
sz_error_unknown_command:
        .ascii "error: unknown command "; .byte 0
sz_quit:
        .ascii "quit"; .byte 0
sz_failed_x0:
        .ascii " x0: 0x"; .byte 0

