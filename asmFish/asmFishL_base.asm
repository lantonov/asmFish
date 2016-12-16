VERSION_OS	 fix 'L'
VERSION_PRE	 fix 'Deep_asmFish'
VERSION_POST	 fix 'base'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cpu options 0 or 1
CPU_HAS_POPCNT	 equ 0	;  popcnt                       very nice function
CPU_HAS_BMI1	 equ 0	;  andn                         why not use it if we can
CPU_HAS_BMI2	 equ 0	;  pext + pdep                  nice for move generation, but not much faster than magics
CPU_HAS_AVX1	 equ 0	;  256 bit floating point       probably only used for memory copy if used at all
CPU_HAS_AVX2	 equ 0	;  256 bit integer + fmadd      probably not used
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; compile options 0 or 1
PEDANTIC	 equ 0	;  follow official stockfish exactly so that bench signature matches
DEBUG		 equ 0	;  turns on the asserts    detecting critical bugs: should be no functional change
VERBOSE 	 equ 0	;  LOTS of print           find subtle bugs:  0=off, 1=general debug, 2=search debug, 3=eval debug
PROFILE 	 equ 0	;  counts in the code      view these with profile command after running bench
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; optional features 0 or 1
USE_CURRMOVE	 equ 1	; printing feature, spamlike
USE_HASHFULL	 equ 1	; printing feature
USE_SELDEPTH	 equ 1	; printing feature
USE_SPAMFILTER	 equ 0	; arena gui can't read at a rate > 1 line / 15ms
USE_SYZYGY	 equ 1	; include tablebase probing code
USE_BOOK	 equ 0	; include some book functions
USE_WEAKNESS	 equ 0	; include uci_limitstrength and uci_elo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
include 'guts/asmFish.asm'