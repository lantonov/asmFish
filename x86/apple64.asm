
stdin  = 0
stdout = 1
stderr = 2

stat.st_size = 72       ; why?
sizeof.stat = 160       ; guess

CLOCK_MONOTONIC = 1

sizeof.pthread_t = 16           ; only 8, but 16 for alignment
sizeof.pthread_mutex_t = 64     ; guess
sizeof.pthread_cond_t = 64      ; another guess

_COMM_PAGE64_BASE_ADDRESS = 0x00007fffffe00000
_COMM_PAGE_START_ADDRESS  = 0x00007fffffe00000

_COMM_PAGE_TIME_DATA_START      = _COMM_PAGE_START_ADDRESS+0x050 ; base of offsets below (_NT_SCALE etc)
_COMM_PAGE_NT_TSC_BASE          = _COMM_PAGE_START_ADDRESS+0x050 ; used by nanotime()
_COMM_PAGE_NT_SCALE             = _COMM_PAGE_START_ADDRESS+0x058 ; used by nanotime()
_COMM_PAGE_NT_SHIFT             = _COMM_PAGE_START_ADDRESS+0x05c ; used by nanotime()
_COMM_PAGE_NT_NS_BASE           = _COMM_PAGE_START_ADDRESS+0x060 ; used by nanotime()
_COMM_PAGE_NT_GENERATION        = _COMM_PAGE_START_ADDRESS+0x068 ; used by nanotime()
_COMM_PAGE_GTOD_GENERATION      = _COMM_PAGE_START_ADDRESS+0x06c ; used by gettimeofday()
_COMM_PAGE_GTOD_NS_BASE         = _COMM_PAGE_START_ADDRESS+0x070 ; used by gettimeofday()
_COMM_PAGE_GTOD_SEC_BASE        = _COMM_PAGE_START_ADDRESS+0x078 ; used by gettimeofday()
_COMM_PAGE_END                  = _COMM_PAGE_START_ADDRESS+0xfff ; end of common page

_NT_TSC_BASE            = 0
_NT_SCALE               = 8
_NT_SHIFT               = 12
_NT_NS_BASE             = 16
_NT_GENERATION          = 24
_GTOD_GENERATION        = 28
_GTOD_NS_BASE           = 32
_GTOD_SEC_BASE          = 40

sys_exit          =   1 + (2 shl 24)
sys_fork          =   2 + (2 shl 24)
sys_read          =   3 + (2 shl 24)
sys_write         =   4 + (2 shl 24)
sys_open          =   5 + (2 shl 24)
sys_close         =   6 + (2 shl 24)
sys_munmap        =  73 + (2 shl 24)
sys_select        =  93 + (2 shl 24)
sys_gettimeofday  = 116 + (2 shl 24)
sys_fstat         = 189 + (2 shl 24)
sys_mmap          = 197 + (2 shl 24)
sys_poll          = 230 + (2 shl 24)

VM_FLAGS_SUPERPAGE_SIZE_2MB = 1 shl 16

;https://opensource.apple.com/source/xnu/xnu-124.8/bsd/sys/fcntl.h
O_RDONLY = 0x0000
O_WRONLY = 0x0001
O_RDWR   = 0x0002
O_CREAT  = 0x0200
O_TRUNC  = 0x0400

;https://opensource.apple.com/source/xnu/xnu-344/bsd/sys/mman.h
PROT_NONE       = 0x00
PROT_READ       = 0x01
PROT_WRITE      = 0x02
PROT_EXEC       = 0x04
MAP_SHARED      = 0x0001 
MAP_PRIVATE     = 0x0002
MAP_FILE        = 0x0000 
MAP_FIXED       = 0x0010
MAP_ANON        = 0x1000

