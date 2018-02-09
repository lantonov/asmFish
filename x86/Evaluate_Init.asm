
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


 ; -    { { V( 97), V(17), V( 9), V(44), V( 84), V( 87), V( 99) }, // Not On King file
 ; -      { V(106), V( 6), V(33), V(86), V( 87), V(104), V(112) },
 ; -      { V(101), V( 2), V(65), V(98), V( 58), V( 89), V(115) },
 ; -      { V( 73), V( 7), V(54), V(73), V( 84), V( 83), V(111) } },
 ; -    { { V(104), V(20), V( 6), V(27), V( 86), V( 93), V( 82) }, // On King file
 ; -      { V(123), V( 9), V(34), V(96), V(112), V( 88), V( 75) },
 ; -      { V(120), V(25), V(65), V(91), V( 66), V( 78), V(117) },
 ; -      { V( 81), V( 2), V(47), V(63), V( 94), V( 93), V(104) } }


 ; +    { { V( 98), V(20), V(11), V(42), V( 83), V( 84), V(101) }, // Not On King file
 ; +      { V(103), V( 8), V(33), V(86), V( 87), V(105), V(113) },
 ; +      { V(100), V( 2), V(65), V(95), V( 59), V( 89), V(115) },
 ; +      { V( 72), V( 6), V(52), V(74), V( 83), V( 84), V(112) } },
 ; +    { { V(105), V(19), V( 3), V(27), V( 85), V( 93), V( 84) }, // On King file 
 ; +      { V(121), V( 7), V(33), V(95), V(112), V( 86), V( 72) },
 ; +      { V(121), V(26), V(65), V(90), V( 65), V( 76), V(117) },
 ; +      { V( 79), V( 0), V(45), V(65), V( 94), V( 92), V(105) } }

.ShelterWeakness:
.ShelterWeakness_No:
 dd  98,  20,  11,  42,  83,  84, 101, 0   
 dd 103,   8,  33,  86,  87, 104, 112, 0  
 dd 100,   2,  65,  95,  59,  89, 115, 0  
 dd  72,   6,  52,  74,  83,  84, 112, 0   
 dd  72,   6,  52,  74,  83,  84, 112, 0
 dd 100,   2,  65,  95,  59,  89, 115, 0
 dd 103,   8,  33,  86,  87, 104, 112, 0
 dd  98,  20,  11,  42,  83,  84, 101, 0

.ShelterWeakness_Yes:
 dd 105,  19,   3,  27,  85,  93,  84, 0
 dd 121,   7,  33,  95, 112,  86,  72, 0
 dd 121,  26,  65,  90,  65,  76, 117, 0
 dd  79,   0,  45,  65,  94,  92, 105, 0
 dd  79,   0,  45,  65,  94,  92, 105, 0
 dd 121,  26,  65,  90,  65,  76, 117, 0
 dd 121,   7,  33,  95, 112,  86,  72, 0
 dd 105,  19,   3,  27,  85,  93,  84, 0

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


; -    S(0, 0), S(0, 33), S(45, 43), S(46, 47), S(72, 107), S(48, 118)
; +    S(0, 0), S(0, 31), S(39, 42), S(57, 44), S(68, 112), S(47, 120) 
.Threat_Minor:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (31)
 dd (39 shl 16) + (42)
 dd (57 shl 16) + (44)
 dd (68 shl 16) + (112)
 dd (47 shl 16) + (120)
 dd (0 shl 16) + (0)

; -    S(0, 0), S(0, 25), S(40, 62), S(40, 59), S(0, 34), S(35, 48)
; +    S(0, 0), S(0, 24), S(38, 71), S(38, 61), S(0, 38), S(36, 38) 
.Threat_Rook:
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (0)
 dd (0 shl 16) + (24)
 dd (38 shl 16) + (71)
 dd (38 shl 16) + (61)
 dd (0 shl 16) + (38)
 dd (36 shl 16) + (38)
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


 ; -    { V(0), V(5), V( 5), V(31), V(73), V(166), V(252) },
 ; -    { V(0), V(7), V(14), V(38), V(73), V(166), V(252) }
 
 ; +    { V(0), V(5), V( 5), V(32), V(70), V(172), V(217) },
 ; +    { V(0), V(7), V(13), V(42), V(70), V(170), V(269) }
 .PassedRank:
 dd 0
 dd (5 shl 16) + (7)
 dd (5 shl 16) + (13)
 dd (32 shl 16) + (42)
 dd (70 shl 16) + (70)
 dd (172 shl 16) + (170)
 dd (217 shl 16) + (269)
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
