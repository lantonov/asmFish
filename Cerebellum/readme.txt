The algorithm for making polyglot-compatible Cerebellum is the following (thanks to Dillon):

1. Download the entire https://github.com/lantonov/asmFish folder. 
2. Download the latest Cerebellum book from http://www.zipproth.de/#cerebellum_deutsch and unzip it in the directory with FASM.EXE
3. Open pedantFishW_popcnt.asm in a txt editor (ex. Notepad). 
4. On line (24) "USE_BOOK equ 0" change "USE_BOOK equ 1". This is the enabling. 
5. In a command prompt enter the following: fasm pedantFishW_popcnt.asm pedantFishW_popcnt.exe
6. Open the newly compiled pedantFishW_popcnt.exe with enabled book handling functions and then you are ready to execute generating.
7. Example: brain2polyglot depth 1024 in "Cerebellum_light.bin" out "polybook.bin" 


C:\Users\lanto\Documents\asmFish>pedantFishW_popcnt.exe
pedantFishW_2016-12-07_popcnt
brain2polyglot depth 1024 in "Cerebellum_light.bin" out "polybook.bin"
brain entries: 5028331
brain duplicates (HMM): 0
brain unsorted (OK): 0
starting search with maxDepth 100
0 of 5028331 entries found  searching NONE
65536 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
131072 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
196608 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
262144 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
327680 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
393216 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
458752 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
524288 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
589824 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
655360 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
720896 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
786432 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
851968 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
917504 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
983040 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1048576 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1114112 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1179648 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1245184 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1310720 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1376256 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1441792 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1507328 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1572864 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1638400 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1703936 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1769472 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1835008 of 5028331 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1900544 of 5028331 entries found  searching e2e4 e7e5 g1f3 c7c5 c2c3 d7d6
1966080 of 5028331 entries found  searching e2e4 e7e5 c2c4 d7d6 b1c3 g7g6
2031616 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2097152 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2162688 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2228224 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2293760 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2359296 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2424832 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2490368 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2555904 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 g7g6
2621440 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 f1b5 c8d7
2686976 of 5028331 entries found  searching e2e4 c7c5 g1f3 d7d6 c2c3 g8f6
2752512 of 5028331 entries found  searching e2e4 c7c5 g1f3 a7a6 d2d4 c5d4
2818048 of 5028331 entries found  searching e2e4 c7c5 g1f3 g7g6 f1b5 b8c6
2883584 of 5028331 entries found  searching e2e4 b7b6 d2d4 c8b7 f1d3 e7e6
2949120 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 b1c3 d5e4
3014656 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 b1c3 d5e4
3080192 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 b1c3 d8a5
3145728 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 c2c4 d5c4
3211264 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 c2c4 d5c4
3276800 of 5028331 entries found  searching e2e4 c7c6 d2d4 d7d5 e4d5 c6d5
3342336 of 5028331 entries found  searching e2e4 d7d5 e4d5 d8d5 b1c3 d5d8
3407872 of 5028331 entries found  searching e2e4 d7d5 b1c3 e7e6 d2d4 f8b4
3473408 of 5028331 entries found  searching e2e4 d7d6 d2d4 g8f6 e4e5 f6d5
3538944 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3604480 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3670016 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3735552 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3801088 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3866624 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3932160 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3997696 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4063232 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4128768 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4194304 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4259840 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 f6g8
4325376 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 f6g8
4390912 of 5028331 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 f6g8
4456448 of 5028331 entries found  searching d2d4 g8f6 c2c4 c7c5 b1c3 d7d5
4521984 of 5028331 entries found  searching d2d4 g8f6 c2c4 c7c6 c1f4 d7d5
4587520 of 5028331 entries found  searching d2d4 g8f6 c2c4 d7d5 c4d5 f6d5
4653056 of 5028331 entries found  searching d2d4 g8f6 g1f3 d7d5 b1a3 c7c6
4718592 of 5028331 entries found  searching d2d4 g8f6 g1f3 d7d5 b1a3 c8f5
4784128 of 5028331 entries found  searching d2d4 g8f6 g1f3 e7e6 c1e3 h8g8
4849664 of 5028331 entries found  searching g1f3 d7d5 b2b3 g8f6 c1b2 c8g4
4915200 of 5028331 entries found  searching g1f3 d7d5 d2d3 b8c6 g2g3 e7e5
4980736 of 5028331 entries found  searching g1f3 b8a6 c2c4 a6b8 f3g1 c7c5
BookSearch done
5017464 of 5028331 entries found
depth 100 line: e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 c2c3 e8g8 e1g1 d7d6 a2a4 a7a5 c1g5 h7h6 g5h4 c8e6 b1d2 d8e7 f1e1 g7g5 h4g3 f6e8 a1c1 c5a7 h2h3 e8g7 g3h2 a8e8 d1b3 e8b8 c4e6 f7e6 b3d1 g7h5 d2c4 e7g7 c4e3 h5f4 c1c2 f8f7 g1h1 b8f8 f3g1 g8h7 c2d2 g7g6 d1b3 f8b8 f2f3 g6f6 b3b5 h6h5 e3c4 g5g4 f3g4 h5g4 c4e3 f6g5 h2f4 f7f4 g2g3 f4f7 h3h4 g5g6 d2g2 a7c5 b5b3 f7f6 b3d1 b8g8 d1b3 b7b6 b3b5 c5e3 e1e3 g6e8 e3e1 c6b8 b5c4 g8g7 c4b3 b8d7 b3c2 h7g8 e1a1 g8f8 g2f2 g7f7 f2g2 f8e7 c2e2 e8g8 b2b4 f7f8 b4a5 b6a5 a1b1 f8b8
sorting polyglot keys
done sorting polyglot keys
polyglot entries: 5017465
polyglot duplicates (OK): 0
polyglot unsorted (BAD): 0
