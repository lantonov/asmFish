Evaluate_Init:

	       push  rbx rsi rdi


		lea   rsi, [.MobilityBonus_Knight]
		lea   rdi, [MobilityBonus_Knight]
		mov   ecx, 9
	  rep movsd
		lea   rsi, [.MobilityBonus_Bishop]
		lea   rdi, [MobilityBonus_Bishop]
		mov   ecx, 14
	  rep movsd
		lea   rsi, [.MobilityBonus_Rook]
		lea   rdi, [MobilityBonus_Rook]
		mov   ecx, 15
	  rep movsd
		lea   rsi, [.MobilityBonus_Queen]
		lea   rdi, [MobilityBonus_Queen]
		mov   ecx, 28
	  rep movsd

		lea   rsi, [.Lever]
		lea   rdi, [Lever]
		mov   ecx, 8
	  rep movsd

		lea   rsi, [.ShelterWeakness]
		lea   rdi, [ShelterWeakness]
		mov   ecx, 4*8
	  rep movsd
		lea   rsi, [.StormDanger]
		lea   rdi, [StormDanger]
		mov   ecx, 4*4*8
	  rep movsd


		lea   rdi, [ThreatBySafePawn]
		lea   rsi, [.ThreatBySafePawn]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.ThreatBySafePawn]
		mov   ecx, 8
	  rep movsd
		lea   rdi, [Threat_Minor]
		lea   rsi, [.Threat_Minor]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.Threat_Minor]
		mov   ecx, 8
	  rep movsd
		lea   rdi, [Threat_Rook]
		lea   rsi, [.Threat_Rook]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.Threat_Rook]
		mov   ecx, 8
	  rep movsd

		lea   rsi, [.PassedRank]
		lea   rdi, [PassedRank]
		mov   ecx, 8
	  rep movsd
		lea   rsi, [.PassedFile]
		lea   rdi, [PassedFile]
		mov   ecx, 8
	  rep movsd

		lea   rsi, [.QuadraticOurs]
		lea   rdi, [DoMaterialEval_Data]
		mov   ecx, 8*(6+6)
	  rep movsd


		lea   rdi, [KingFlank]
		mov   rax, (Rank4BB or Rank5BB or Rank6BB or Rank7BB or Rank8BB) \
			   and (FileABB or FileBBB or FileCBB or FileDBB)
	      stosq
	      stosq
	      stosq
		mov   rax, (Rank4BB or Rank5BB or Rank6BB or Rank7BB or Rank8BB) \
			   and (FileCBB or FileDBB or FileEBB or FileFBB)
	      stosq
	      stosq
		mov   rax, (Rank4BB or Rank5BB or Rank6BB or Rank7BB or Rank8BB) \
			   and (FileEBB or FileFBB or FileGBB or FileHBB)
	      stosq
	      stosq
	      stosq
		mov   rax, (Rank5BB or Rank4BB or Rank3BB or Rank2BB or Rank1BB) \
			   and (FileABB or FileBBB or FileCBB or FileDBB)
	      stosq
	      stosq
	      stosq
		mov   rax, (Rank5BB or Rank4BB or Rank3BB or Rank2BB or Rank1BB) \
			   and (FileCBB or FileDBB or FileEBB or FileFBB)
	      stosq
	      stosq
		mov   rax, (Rank5BB or Rank4BB or Rank3BB or Rank2BB or Rank1BB) \
			   and (FileEBB or FileFBB or FileGBB or FileHBB)
	      stosq
	      stosq
	      stosq

		pop   rdi rsi rbx
		ret


align 4

.MobilityBonus_Knight:
 dd (-75 shl 16) + (-76)
 dd (-56 shl 16) + (-54)
 dd (- 9 shl 16) + (-26)
 dd ( -2 shl 16) + (-10)
 dd (  6 shl 16) + (5)
 dd ( 15 shl 16) + (11)
 dd ( 22 shl 16) + (26)
 dd ( 30 shl 16) + (28)
 dd ( 36 shl 16) + (29)

.MobilityBonus_Bishop:
 dd (-48 shl 16) + (-58)
 dd (-21 shl 16) + (-19)
 dd (16 shl 16) + (-2)
 dd (26 shl 16) + (12)
 dd (37 shl 16) + (22)
 dd (51 shl 16) + (42)
 dd (54 shl 16) + (54)
 dd (63 shl 16) + (58)
 dd (65 shl 16) + (63)
 dd (71 shl 16) + (70)
 dd (79 shl 16) + (74)
 dd (81 shl 16) + (86)
 dd (92 shl 16) + (90)
 dd (97 shl 16) + (94)

.MobilityBonus_Rook:
 dd (-56 shl 16) + (-78)
 dd (-25 shl 16) + (-18)
 dd (-11 shl 16) + (26)
 dd (-5 shl 16) + (55)
 dd (-4 shl 16) + (70)
 dd (-1 shl 16) + (81)
 dd (8 shl 16) + (109)
 dd (14 shl 16) + (120)
 dd (21 shl 16) + (128)
 dd (23 shl 16) + (143)
 dd (31 shl 16) + (154)
 dd (32 shl 16) + (160)
 dd (43 shl 16) + (165)
 dd (49 shl 16) + (168)
 dd (59 shl 16) + (169)

.MobilityBonus_Queen:
 dd (-40 shl 16) + (-35)
 dd (-25 shl 16) + (-12)
 dd (2 shl 16) + (7)
 dd (4 shl 16) + (19)
 dd (14 shl 16) + (37)
 dd (24 shl 16) + (55)
 dd (25 shl 16) + (62)
 dd (40 shl 16) + (76)
 dd (43 shl 16) + (79)
 dd (47 shl 16) + (87)
 dd (54 shl 16) + (94)
 dd (56 shl 16) + (102)
 dd (60 shl 16) + (111)
 dd (70 shl 16) + (116)
 dd (72 shl 16) + (118)
 dd (73 shl 16) + (122)
 dd (75 shl 16) + (128)
 dd (77 shl 16) + (130)
 dd (85 shl 16) + (133)
 dd (94 shl 16) + (136)
 dd (99 shl 16) + (140)
 dd (108 shl 16) + (157)
 dd (112 shl 16) + (158)
 dd (113 shl 16) + (161)
 dd (118 shl 16) + (174)
 dd (119 shl 16) + (177)
 dd (123 shl 16) + (191)
 dd (128 shl 16) + (199)

.Lever:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (17 shl 16) + (16)
 dd (33 shl 16) + (32)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)


.Doubled:
 dd (0 shl 16) + (0)
 dd (18 shl 16) + (38)
 dd (9 shl 16) + (19)
 dd (6 shl 16) + (12)
 dd (4 shl 16) + (9)
 dd (3 shl 16) + (7)
 dd (3 shl 16) + (6)
 dd (2 shl 16) + (5)


.ShelterWeakness:
 dd  97, 21, 26, 51, 87,  89,  99, 0
 dd 120,  0, 28, 76, 88, 103, 104, 0
 dd 101,  7, 54, 78, 77,  92, 101, 0
 dd  80, 11, 44, 68, 87,  90, 119, 0

.StormDanger:
 dd 0,	 67, 134, 38, 32 ,  0,0,0
 dd 0,	 57, 139, 37, 22 ,  0,0,0
 dd 0,	 43, 115, 43, 27 ,  0,0,0
 dd 0,	 68, 124, 57, 32 ,  0,0,0

 dd 20,  43,  100, 56, 20 , 0,0,0
 dd 23,  20,   98, 40, 15 , 0,0,0
 dd 23,  39,  103, 36, 18 , 0,0,0
 dd 28,  19,  108, 42, 26 , 0,0,0

 dd  0,  0,   75, 14,  2 , 0,0,0
 dd  0,  0,  150, 30,  4 , 0,0,0
 dd  0,  0,  160, 22,  5 , 0,0,0
 dd  0,  0,  166, 24, 13 , 0,0,0

 dd  0,  -283, -281, 57, 31 , 0,0,0
 dd  0,    58,	141, 39, 18 , 0,0,0
 dd  0,    65,	142, 48, 32 , 0,0,0
 dd  0,    60,	126, 51, 19 , 0,0,0



.ThreatBySafePawn:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (176 shl 16) + (139)
 dd (131 shl 16) + (127)
 dd (217 shl 16) + (218)
 dd (203 shl 16) + (215)
 dd (0 shl 16) + (0)

.Threat_Minor:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (33)
 dd (45 shl 16) + (43)
 dd (46 shl 16) + (47)
 dd (72 shl 16) + (107)
 dd (48 shl 16) + (118)
 dd (0 shl 16) + (0)

.Threat_Rook:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (25)
 dd (40 shl 16) + (62)
 dd (40 shl 16) + (59)
 dd (0 shl 16) + (34)
 dd (35 shl 16) + (48)
 dd (0 shl 16) + (0)



.PassedFile:
 dd (9 shl 16) + (10)
 dd (2 shl 16) + (10)
 dd (1 shl 16) + (-8)
 dd (-20 shl 16) + (-12)
 dd (-20 shl 16) + (-12)
 dd (1 shl 16) + (-8)
 dd (2 shl 16) + (10)
 dd (9 shl 16) + (10)


.PassedRank:
 dd 0
 dd (5 shl 16) + (7)
 dd (5 shl 16) + (14)
 dd (31 shl 16) + (38)
 dd (73 shl 16) + (73)
 dd (166 shl 16) + (166)
 dd (252 shl 16) + (252)
 dd 0



;.Linear:
;        dd 0, 1667, -168,-1027, -166,  238, -138,    0
.QuadraticOurs:
	dd 0, 1667,    0,    0,    0,	 0,    0,    0
	dd 0,	40,    2,    0,    0,	 0,    0,    0
	dd 0,	32,  255,   -3,    0,	 0,    0,    0
	dd 0,	 0,  104,    4,    0,	 0,    0,    0
	dd 0,  -26,   -2,   47,  105, -149,    0,    0
	dd 0, -185,   24,  122,  137, -134,    0,    0
.QuadraticTheirs:
	dd 0,	 0,    0,    0,    0,	 0,    0,    0
	dd 0,	36,    0,    0,    0,	 0,    0,    0
	dd 0,	 9,   63,    0,    0,	 0,    0,    0
	dd 0,	59,   65,   42,    0,	 0,    0,    0
	dd 0,	46,   39,   24,  -24,	 0,    0,    0
	dd 0,  101,  100,  -37,  141,  268,    0,    0













