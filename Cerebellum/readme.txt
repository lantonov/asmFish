The algorithm for making polyglot-compatible Cerebellum book is the following:

1. Download the latest Cerebellum book from http://www.zipproth.de/#cerebellum_deutsch and unzip it in some directory
2. Download Cerebellum2polyglot_Linux if you are on Linux or Cerebellum2polyglot_Windows.exe if you are on Windows in the same directory as the Cerebellum book. 
3. Start the respective engine 
4. Enter a command similar to 'brain2polyglot depth 50 in "Cerebellum_light.bin" out "polybook.bin"' to start translation

The engines have been tweaked so that the maximum number of moves searched are 512 (1024 plies), more than enough for most purposes. However, the more depth searched the slower the translation, so in practice 40-50 plies (20-25 moves) is enough to capture more than 75% of the positions in the original book. To speed up things, you can increase the threads with setoption name Threads value <whatever you have>.

Below is a translating session with the latest Cerebellum (2016-12-08). I cannot include the Cerebellum-polyglot book itself because its size is > 80 MB, and the maximal size that GitHub allows for upload is 25 MB.

pedantFishW_2016-12-08_popcnt
brain2polyglot depth 50 in "Cerebellum_light.bin" out "polybook.bin"
brain entries: 6044228
brain duplicates (HMM): 0
brain unsorted (OK): 0
starting search with maxDepth 50
0 of 6044228 entries found  searching NONE
65536 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
131072 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
196608 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
262144 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
327680 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
393216 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
458752 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
524288 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
589824 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
655360 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
720896 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
786432 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
851968 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
917504 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
983040 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1048576 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1114112 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1179648 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1245184 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1310720 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1376256 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 g8f6
1441792 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 f1b5 c6a5
1507328 of 6044228 entries found  searching e2e4 e7e5 g1f3 b8c6 b1c3 g8f6
1572864 of 6044228 entries found  searching e2e4 e7e5 g1f3 g8f6 f3e5 d7d6
1638400 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 d7d5
1703936 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 b7b5
1769472 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 c7c5
1835008 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 c7c5
1900544 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 c7c5
1966080 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 c7c5
2031616 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 f1d3 c7c5
2097152 of 6044228 entries found  searching e2e4 a7a6 d2d4 e7e6 g1f3 c7c5
2162688 of 6044228 entries found  searching e2e4 a7a6 d2d4 c7c5 b1c3 c5d4
2228224 of 6044228 entries found  searching e2e4 a7a6 d2d4 c7c5 g1f3 c5d4
2293760 of 6044228 entries found  searching e2e4 b7b6 d2d4 c8b7 f1d3 e7e6
2359296 of 6044228 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2424832 of 6044228 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 c5d4
2490368 of 6044228 entries found  searching e2e4 c7c5 g1f3 d7d6 d2d4 e7e6
2555904 of 6044228 entries found  searching e2e4 c7c5 g1f3 d7d6 b1c3 g8f6
2621440 of 6044228 entries found  searching e2e4 c7c5 g1f3 d7d6 f1b5 c8d7
2686976 of 6044228 entries found  searching e2e4 c7c5 g1f3 g7g6 c2c4 f8g7
2752512 of 6044228 entries found  searching e2e4 c7c6 b1c3 d7d5 g1f3 g8f6
2818048 of 6044228 entries found  searching e2e4 c7c6 b1c3 d7d5 g1f3 g8f6
2883584 of 6044228 entries found  searching e2e4 c7c6 b1c3 d7d6 d2d4 g7g6
2949120 of 6044228 entries found  searching e2e4 c7c6 g1f3 e7e6 c2c4 d7d5
3014656 of 6044228 entries found  searching e2e4 c7c6 g1f3 g7g6 d2d3 f8g7
3080192 of 6044228 entries found  searching e2e4 d7d5 b1c3 e7e6 d2d4 g8f6
3145728 of 6044228 entries found  searching e2e4 d7d5 c2c4 e7e6 b1c3 g8f6
3211264 of 6044228 entries found  searching e2e4 d7d6 c2c4 g7g6 b1c3 g8f6
3276800 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3342336 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3407872 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3473408 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3538944 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3604480 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3670016 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3735552 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3801088 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3866624 of 6044228 entries found  searching d2d4 d7d5 c2c4 e7e6 g1f3 g8f6
3932160 of 6044228 entries found  searching d2d4 d7d5 c2c4 a7a6 g1f3 c7c6
3997696 of 6044228 entries found  searching d2d4 d7d5 c2c4 c7c6 g1f3 g8f6
4063232 of 6044228 entries found  searching d2d4 d7d5 c2c4 b8c6 c4d5 d8d5
4128768 of 6044228 entries found  searching d2d4 d7d5 g1f3 g8f6 b1a3 c8f5
4194304 of 6044228 entries found  searching d2d4 d7d5 c2c3 e7e5 h2h3 b8c6
4259840 of 6044228 entries found  searching d2d4 b7b6 c1g5 c8b7 g1f3 g8f6
4325376 of 6044228 entries found  searching d2d4 c7c5 d4d5 g8f6 c2c4 b7b5
4390912 of 6044228 entries found  searching d2d4 c7c6 c2c4 d7d6 b1c3 g7g6
4456448 of 6044228 entries found  searching d2d4 e7e6 c2c4 f7f5 b1c3 f8b4
4521984 of 6044228 entries found  searching g1f3 d7d5 b2b3 g8f6 c1b2 b8c6
4587520 of 6044228 entries found  searching g1f3 d7d5 c2c4 g8f6 c4d5 f6d5
4653056 of 6044228 entries found  searching g1f3 e7e5 c2c4 b8c6 b1c3 g8f6
BookSearch done
4709538 of 6044228 entries found
depth 50 line: e2e4 e7e5 g1f3 b8c6 f1b5 g8f6 d2d3 f8c5 c2c3 e8g8 e1g1 d7d6 h2h3 c5b6 b1d2 c6e7 d2c4 e7g6 b5a4 c7c6 c4b6 a7b6 a4c2 f8e8 f1e1 c8e6 a2a3 h7h6 d3d4 d8c8 f3h2 b6b5 c1e3 c8c7 h2f3 e6d7 f3d2 d7e6 d1f3 g6h4 f3e2 h4g6 a1d1 c7e7 d1c1 e8d8 c1d1 e7c7 d1b1 c7e7
sorting polyglot keys
done sorting polyglot keys
polyglot entries: 4709539
polyglot duplicates (OK): 0
polyglot unsorted (BAD): 0
