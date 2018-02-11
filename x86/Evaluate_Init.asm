
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
		mov   ecx, 2*8*8
	  rep movsd
		lea   rsi, [.StormDanger]
		lea   rdi, [StormDanger]
		mov   ecx, 4*8*8
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
		mov   rax, (FileABB or FileBBB or FileCBB or FileDBB)
	      stosq
	      stosq
	      stosq
		shl   rax, 2
	      stosq
	      stosq
		shl   rax, 2
	      stosq
	      stosq
	      stosq


                lea   rsi, [.PawnsSet]
                lea   rdi, [PawnsSet]
                mov   ecx, 9
          rep movsd

                lea   rsi, [.QueenMinorsImbalance]
                lea   rdi, [QueenMinorsImbalance]
                mov   ecx, 16
          rep movsd

		pop   rdi rsi rbx
		ret


             calign   4

.MobilityBonus_Knight:
 dd (-75 shl 16) + (-76)
 dd (-57 shl 16) + (-54)
 dd (- 9 shl 16) + (-28)
 dd ( -2 shl 16) + (-10)
 dd (  6 shl 16) + (5)
 dd ( 14 shl 16) + (12)
 dd ( 22 shl 16) + (26)
 dd ( 29 shl 16) + (29)
 dd ( 36 shl 16) + (29)

.MobilityBonus_Bishop:
 dd (-48 shl 16) + (-59)
 dd (-20 shl 16) + (-23)
 dd (16 shl 16) + (-3)
 dd (26 shl 16) + (13)
 dd (38 shl 16) + (24)
 dd (51 shl 16) + (42)
 dd (55 shl 16) + (54)
 dd (63 shl 16) + (57)
 dd (63 shl 16) + (65)
 dd (68 shl 16) + (73)
 dd (81 shl 16) + (78)
 dd (81 shl 16) + (86)
 dd (91 shl 16) + (88)
 dd (98 shl 16) + (97)

.MobilityBonus_Rook:
 dd (-58 shl 16) + (-76)
 dd (-27 shl 16) + (-18)
 dd (-15 shl 16) + (28)
 dd (-10 shl 16) + (55)
 dd (-5 shl 16) + (69)
 dd (-2 shl 16) + (82)
 dd ( 9 shl 16) + (112)
 dd (16 shl 16) + (118)
 dd (30 shl 16) + (132)
 dd (29 shl 16) + (142)
 dd (32 shl 16) + (155)
 dd (38 shl 16) + (165)
 dd (46 shl 16) + (166)
 dd (48 shl 16) + (169)
 dd (58 shl 16) + (171)

.MobilityBonus_Queen:
 dd (-39 shl 16) + (-36)
 dd (-21 shl 16) + (-15)
 dd (3 shl 16) + (8)
 dd (3 shl 16) + (18)
 dd (14 shl 16) + (34)
 dd (22 shl 16) + (54)
 dd (28 shl 16) + (61)
 dd (41 shl 16) + (73)
 dd (43 shl 16) + (79)
 dd (48 shl 16) + (92)
 dd (56 shl 16) + (94)
 dd (60 shl 16) + (104)
 dd (60 shl 16) + (113)
 dd (66 shl 16) + (120)
 dd (67 shl 16) + (123)
 dd (70 shl 16) + (126)
 dd (71 shl 16) + (133)
 dd (73 shl 16) + (136)
 dd (79 shl 16) + (140)
 dd (88 shl 16) + (143)
 dd (88 shl 16) + (148)
 dd (99 shl 16) + (166)
 dd (102 shl 16) + (170)
 dd (102 shl 16) + (175)
 dd (106 shl 16) + (184)
 dd (109 shl 16) + (191)
 dd (113 shl 16) + (206)
 dd (116 shl 16) + (212)

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


; ShelterWeakness and StormDanger are twice as big
; to avoid an anoying min(f,FILE_H-f) in ShelterStorm
.ShelterWeakness:
.ShelterWeakness_No:
 dd  97,  17,   9,  44,  84,  87,  99, 0
 dd 106,   6,  33,  86,  87, 104, 112, 0
 dd 101,   2,  65,  98,  58,  89, 115, 0
 dd  73,   7,  54,  73,  84,  83, 111, 0
 dd  73,   7,  54,  73,  84,  83, 111, 0
 dd 101,   2,  65,  98,  58,  89, 115, 0
 dd 106,   6,  33,  86,  87, 104, 112, 0
 dd  97,  17,   9,  44,  84,  87,  99, 0

.ShelterWeakness_Yes:
 dd 104,  20,   6,  27,  86,  93,  82, 0
 dd 123,   9,  34,  96, 112,  88,  75, 0
 dd 120,  25,  65,  91,  66,  78, 117, 0
 dd  81,   2,  47,  63,  94,  93, 104, 0
 dd  81,   2,  47,  63,  94,  93, 104, 0
 dd 120,  25,  65,  91,  66,  78, 117, 0
 dd 123,   9,  34,  96, 112,  88,  75, 0
 dd 104,  20,   6,  27,  86,  93,  82, 0

.StormDanger:
 dd 4,	 73, 132, 46, 31 ,  0,0,0
 dd 1,	 64, 143, 26, 13 ,  0,0,0
 dd 1,	 47, 110, 44, 24 ,  0,0,0
 dd 0,	 72, 127, 50, 31 ,  0,0,0
 dd 0,	 72, 127, 50, 31 ,  0,0,0
 dd 1,	 47, 110, 44, 24 ,  0,0,0
 dd 1,	 64, 143, 26, 13 ,  0,0,0
 dd 4,	 73, 132, 46, 31 ,  0,0,0

 dd 22,  45,  104, 62,	6 , 0,0,0
 dd 31,  30,   99, 39, 19 , 0,0,0
 dd 23,  29,   96, 41, 15 , 0,0,0
 dd 21,  23,  116, 41, 15 , 0,0,0
 dd 21,  23,  116, 41, 15 , 0,0,0
 dd 23,  29,   96, 41, 15 , 0,0,0
 dd 31,  30,   99, 39, 19 , 0,0,0
 dd 22,  45,  104, 62,	6 , 0,0,0

 dd  0,  0,   79, 23,  1 , 0,0,0
 dd  0,  0,  148, 27,  2 , 0,0,0
 dd  0,  0,  161, 16,  1 , 0,0,0
 dd  0,  0,  171, 22, 15 , 0,0,0
 dd  0,  0,  171, 22, 15 , 0,0,0
 dd  0,  0,  161, 16,  1 , 0,0,0
 dd  0,  0,  148, 27,  2 , 0,0,0
 dd  0,  0,   79, 23,  1 , 0,0,0

 dd  0,  -290, -274, 57, 41 , 0,0,0
 dd  0,    60,	144, 39, 13 , 0,0,0
 dd  0,    65,	141, 41, 34 , 0,0,0
 dd  0,    53,	127, 56, 14 , 0,0,0
 dd  0,    53,	127, 56, 14 , 0,0,0
 dd  0,    65,	141, 41, 34 , 0,0,0
 dd  0,    60,	144, 39, 13 , 0,0,0
 dd  0,  -290, -274, 57, 41 , 0,0,0


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



.PawnsSet:
        dd 24, -32, 107, -51, 117, -9, -126, -21, 31

.QueenMinorsImbalance:
        dd 31, -8, -15, -25, -5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.QuadraticOurs:
	dd 0, 1667,    0,    0,    0,	 0,    0,    0
	dd 0,	40,    0,    0,    0,	 0,    0,    0
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
