The algorithm for making polyglot-compatible Cerebellum is the following (thanks to Dillon):

1. Download the entire https://github.com/lantonov/asmFish folder. 
2. Download the latest Cerebellum book from http://www.zipproth.de/#cerebellum_deutsch and unzip it in the directory with FASM.EXE
3. Open pedantFishW_popcnt.asm in a txt editor (ex. Notepad). 
4. On line (24) "USE_BOOK equ 0" change "USE_BOOK equ 1". This is the enabling. 
5. In a command prompt enter the following: fasm pedantFishW_popcnt.asm pedantFishW_popcnt.exe
6. Open the newly compiled pedantFishW_popcnt.exe with enabled book handling functions and then you are ready to execute generating.
7. Example: brain2polyglot depth 1024 in "Cerebellum_light.bin" out "polybook.bin"

This procedure is much shortened by the 2 engines included here: Cerebellum2polyglot_Linux and Cerebellum2polyglot_Windows.exe. Just download the latest Cerebellum book, put it in the same directory as the engine, fire the latter and use a command similar to brain2polyglot depth 1024 in "Cerebellum_light.bin" out "polybook.bin" to start translation. The engines have been tweaked so that the maximum number of moves searched are 512 (1024 plies), more than enough for most purposes. However, the more depth searched the slower the translation, so in practice 220-250 plies (110-125 moves) is enough to capture more than 99.9% of the positions in the original book. To speed up things, you can increase the threads with setoption name Threads value <whatever you have>.

Below is a translating session with the latest Cerebellum (2016-12-08). I cannot include the Cerebellum-polyglot book itself because its size is > 78 MB, and the maximal size that GitHub allows for upload is 25 MB.

C:\Users\lanto\Documents\asmFish>Cerebellum2polyglot_Windows.exe
pedantFishW_2016-12-08_popcnt
setoption name Threads value 3
brain2polyglot depth 200 in "Cerebellum_light.bin" out "polybook.bin"
brain entries: 5039000
brain duplicates (HMM): 0
brain unsorted (OK): 0
starting search with maxDepth 200
0 of 5039000 entries found  searching NONE
65536 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
131072 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
196608 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
262144 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
327680 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
393216 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
458752 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
524288 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
589824 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
655360 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
720896 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
786432 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
851968 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
917504 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
983040 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1048576 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1114112 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1179648 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1245184 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1310720 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1376256 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1441792 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1507328 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1572864 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1638400 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1703936 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1769472 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1835008 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1900544 of 5039000 entries found  searching e2e4 e7e5 g1f3 b8c6 f1c4 g8f6
1966080 of 5039000 entries found  searching e2e4 e7e5 g1f3 g8f6 f3e5 f6e4
2031616 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2097152 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2162688 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2228224 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2293760 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2359296 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2424832 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2490368 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2555904 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 e7e6
2621440 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 f1b5 c8d7
2686976 of 5039000 entries found  searching e2e4 c7c5 g1f3 d7d6 f1b5 b8c6
2752512 of 5039000 entries found  searching e2e4 c7c5 g1f3 a7a6 b1c3 e7e6
2818048 of 5039000 entries found  searching e2e4 c7c5 g1f3 g7g6 b1c3 b8c6
2883584 of 5039000 entries found  searching e2e4 c7c5 c2c4 d7d6 b1c3 g7g6
2949120 of 5039000 entries found  searching e2e4 a7a6 d2d4 d7d6 b1c3 g7g6
3014656 of 5039000 entries found  searching e2e4 c7c6 d2d4 d7d5 b1c3 d5e4
3080192 of 5039000 entries found  searching e2e4 c7c6 d2d4 d7d5 b1c3 d8a5
3145728 of 5039000 entries found  searching e2e4 c7c6 d2d4 d7d5 c2c4 d5c4
3211264 of 5039000 entries found  searching e2e4 c7c6 d2d4 d7d5 c2c4 d5c4
3276800 of 5039000 entries found  searching e2e4 c7c6 d2d4 d7d5 c2c4 d5c4
3342336 of 5039000 entries found  searching e2e4 d7d5 e4d5 d8d5 b1c3 d5f5
3407872 of 5039000 entries found  searching e2e4 d7d5 b1c3 e7e6 d2d4 g8f6
3473408 of 5039000 entries found  searching e2e4 d7d6 d2d4 g8f6 b1c3 f6g8
3538944 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3604480 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3670016 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3735552 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3801088 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3866624 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3932160 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
3997696 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4063232 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4128768 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4194304 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4259840 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 d7d5
4325376 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 f6g8
4390912 of 5039000 entries found  searching d2d4 g8f6 c2c4 e7e6 g1f3 f6g8
4456448 of 5039000 entries found  searching d2d4 g8f6 c2c4 a7a6 g1f3 c7c6
4521984 of 5039000 entries found  searching d2d4 g8f6 c2c4 c7c6 g1f3 d7d5
4587520 of 5039000 entries found  searching d2d4 g8f6 c2c4 c7c6 g1f3 d7d5
4653056 of 5039000 entries found  searching d2d4 g8f6 g1f3 d7d5 b1a3 c7c6
4718592 of 5039000 entries found  searching d2d4 g8f6 g1f3 d7d5 b1a3 c8f5
4784128 of 5039000 entries found  searching d2d4 g8f6 g1f3 b7b6 c1f4 c8a6
4849664 of 5039000 entries found  searching g1f3 d7d5 b1c3 g8f6 d2d3 d5d4
4915200 of 5039000 entries found  searching g1f3 d7d5 c2c4 e7e6 b1c3 g8f6
4980736 of 5039000 entries found  searching g1f3 e7e5 c2c4 b8c6 b1c3 g8f6
BookSearch done
5038617 of 5039000 entries found
depth 200 line: e2e4 e7e5 g1f3 b8c6 f1c4 g8f6 d2d3 f8c5 a2a4 e8g8 c1g5 h7h6 g5h4 g7g5 h4g3 d7d6 e1g1 a7a6 c2c3 c5a7 b1d2 a6a5 f1e1 c8e6 a1c1 a8b8 c1c2 d8e7 c4b5 f8d8 c2c1 d8f8 d2c4 b8d8 c4d2 g8h8 c1a1 c6b8 b5c4 b8c6 a1c1 h8g7 c1c2 g7h7 c2c1 h7g8 c1b1 d8b8 b1c1 b8a8 c4b5 a8d8 b5c4 a7c5 c1c2 g8h8 c2c1 c5b6 c4b3 b6a7 e1f1 h8g8 b3c4 a7c5 f1e1 d8a8 e1f1 c5a7 c4b3 a8e8 b3c4 a7c5 c4b5 e8b8 b5c4 b8a8 c1b1 c5a7 f1e1 a8d8 b1a1 d8b8 a1b1 e7d8 b1c1 d8e7 c1a1 a7c5 c4b3 b8e8 b3c4 e8a8 c4b5 c5a7 b5c4 e6d7 e1f1 d7c8 f1e1 c8e6 c4b5 e7d8 b5c4 e6c8 c4b3 c8e6 e1f1 d8e7 f1e1 a7c5 e1f1 c5b6 f1e1 a8e8 d2c4 b6a7 c4d2 e6d7 e1f1 a7c5 a1c1 d7e6 f1e1 c5a7 e1f1 e8b8 f1e1 f6d7 h2h3 e7f6 b3c2 g8h8 d2f1 f8g8 f1e3 h6h5 h3h4 a7e3 e1e3 g5g4 f3d2 d7f8 d3d4 c6e7 d1e1 f8g6 f2f3 g6f4 d2f1 g8g7 f3g4 g7g4 c2d1 g4g7 c1c2 b8g8 e1f2 f6h6 e3f3 e7g6 d4e5 d6e5 g1h2 f4g2 f3f6 g2f4 f2c5 g8d8 g3f4 e5f4 c2d2 g7g8 d2d8 g8d8 d1h5 d8g8 f1d2 b7b6 c5g5 h6g5 h4g5 g6e5 f6f4 g8g5 h5e2 h8g7 f4f2 e5g4 e2g4 g5g4 f2f3 g4g6 f3g3 g7f6 b2b4 b6b5 a4b5 a5a4 g3d3 g6g8
sorting polyglot keys
done sorting polyglot keys
polyglot entries: 5038618
polyglot duplicates (OK): 0
polyglot unsorted (BAD): 0
