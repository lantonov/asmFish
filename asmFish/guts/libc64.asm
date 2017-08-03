
; reading and writing
extrn read
extrn write
extrn fstat
extrn open
extrn close
stdin  = 0 
stdout = 1 
stderr = 2
sizeof.stat  = 196
stat.st_size = 48

; timing
extrn clock_gettime
extrn nanosleep
CLOCK_MONOTONIC = 1

; memory
extrn malloc
extrn free
extrn mmap
extrn munmap

; threads
extrn exit
extrn pthread_create
extrn pthread_join
extrn pthread_exit
extrn pthread_mutex_init
extrn pthread_mutex_lock
extrn pthread_mutex_unlock
extrn pthread_mutex_destroy
extrn pthread_cond_init
extrn pthread_cond_signal
extrn pthread_cond_wait
extrn pthread_cond_destroy
sizeof.pthread_t = 16
sizeof.pthread_mutex_t = 48
sizeof.pthread_cond_t = 48



; PROT_ flags 
PROT_READ		= $01 
PROT_WRITE		= $02 
PROT_EXEC		= $04 
PROT_SEM		= $08 
PROT_NONE		= $00 
PROT_GROWSDOWN		= $01000000 
PROT_GROWSUP		= $02000000

; MAP_ flags 
MAP_SHARED		= $01 
MAP_PRIVATE		= $02 
MAP_TYPE		= $0F 
MAP_FIXED		= $10 
MAP_ANONYMOUS		= $20 
MAP_ANON		= MAP_ANONYMOUS 
MAP_FILE		= 0 
MAP_HUGE_SHIFT		= 26 
MAP_HUGE_MASK		= $3F 
MAP_32BIT		= $40 
MAP_GROWSUP		= $00200 
MAP_GROWSDOWN		= $00100 
MAP_DENYWRITE		= $00800 
MAP_EXECUTABLE		= $01000 
MAP_LOCKED		= $02000 
MAP_NORESERVE		= $04000 
MAP_POPULATE		= $08000 
MAP_NONBLOCK		= $10000 
MAP_STACK		= $20000 
MAP_HUGETLB		= $40000

; O_ flags 
O_ACCMODE		= 00000003o 
O_RDONLY		= 00000000o 
O_WRONLY		= 00000001o 
O_RDWR			= 00000002o 
O_CREAT 		= 00000100o 
O_EXCL			= 00000200o 
O_NOCTTY		= 00000400o 
O_TRUNC 		= 00001000o 
O_APPEND		= 00002000o 
O_NONBLOCK		= 00004000o 
O_NDELAY		= O_NONBLOCK 
O_SYNC			= 04010000o 
O_FSYNC 		= O_SYNC 
O_ASYNC 		= 00020000o 
O_DIRECTORY		= 00200000o 
O_NOFOLLOW		= 00400000o 
O_CLOEXEC		= 02000000o 
O_DIRECT		= 00040000o 
O_NOATIME		= 01000000o 
O_PATH			= 10000000o 
O_DSYNC 		= 00010000o 
O_RSYNC 		= O_SYNC 
O_LARGEFILE		= 00100000o

