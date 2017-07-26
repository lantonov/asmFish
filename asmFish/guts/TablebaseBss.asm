align 64
;_ZN13TablebaseCore14MaxCardinalityE:
;	rd    16
Tablebase_MaxCardinality   rd 1
Tablebase_Cardinality      rd 1
Tablebase_ProbeDepth       rd 1
Tablebase_Score            rd 1
Tablebase_RootInTB         rb 1    ; boole 0 or -1
Tablebase_UseRule50        rb 1    ; boole 0 or -1
                           rb 2
                           rd 11

_ZL7pfactor:
	rb    128

_ZL7pawnidx:
	rb    512

_ZL8binomial:
	rb    1280

_ZL9DTZ_table:
	rq    1

?_333:	rq    1

?_334:	rq    184

?_335:
	rb    24

?_336:
	rb    16

?_337:	rq    1

_ZL7TB_hash:
	rb    81920

_ZL7TB_pawn:
	rb    98304

_ZL8TB_piece:
	rb    30480

_ZL10TBnum_pawn:
	rd    1

_ZL11TBnum_piece:
	rd    1

; let n = num_paths
; the paths are stored in paths[0],...,path[n-1]
; the counts of found tbs are stored in paths[n],...,paths[2n-1]
_ZL5paths:
	rq    1

_ZL11path_string:
	rq    1

_ZL9num_paths:
	rd    1


_ZL11initialized:
	rb    4

tb_total_cnt:
        rd 1

align 16
_ZL8TB_mutex:
	rq    6
