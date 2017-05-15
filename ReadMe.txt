******** introduction ********
Welcome to the project of translating Stockfish in assembly language!
The newest executables can be found in the master branch while executables from older versions are in branch "executables".
The source files can be found in the asmFish folder on the master branch.
  - run fasm on asmFishW_base[_popcnt,_bmi2].asm to produce executables for windows
  - run fasm on asmFishL_base[_popcnt,_bmi2].asm to produce executables for linux
For more information on this project see the asmFish/asmReadMe.txt.
Run make.bat to automatically assemble the windows/linux sources for the three capabilities
  - base: should run on any 64bit x86 cpu
  - popcnt: generate popcnt instruction
  - bmi2: use instructions introduced in haswell
You can customize your assemble of asmFish by setting various flags in the file.
For example, USE_BOOK equ 1 will include several book features.


If you observe a crash/misbehaviour in asmFish, please raise an issue here and give me the following information:
  - name of the executable that crashed/misbehaved
  - exception code and exception offset in the case of a crash
  - a log of the commands that were sent to asmFish by your gui before the crash
Simply stating that asmFish crashed in your gui is useless information by itself.
asmFish is known to have problems in the fritz15 gui, while it plays much better in the fritz11 gui.
Any help with this issue would be appreciated.


******** FAQ ********
Q: Why not just start with the compiler output and speed up the critical functions?
   or write critical functions in asm and include them in cpp code?
A: With this approach the critical functions would still need to conform to the standards
   set in place by the ABI. All of the critical functions in asmFish do not conform to these
   standards. Plus, asmFish would be dependent on a compiler in this case, which introduces
   many unnecessary compilcations. Both asmFish and its assembler are around 100KB; lets keep
   it simple. Note that compiler output was used in the case of Ronald de Man's syzygy
   probing code, as this is not speed critical but cumbersome to write by hand.

Q: Is asmFish search the same as official stockfish?
A: It does now that PEDANTIC = 1 is the default! The changes previously thought to be
   inconsequential lose about 2 Elo in a head-to-head matchup.
   
Q: Where can I find the executable files of the old versions ?
A: All older versions of asmFish/pedantFish are in the branch https://github.com/lantonov/asmFish/tree/executables


******** updates ********
For a change log, see the Wiki https://github.com/lantonov/asmFish/wiki/Change-log
