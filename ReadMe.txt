******** introduction ********
Welcome to the project of translating Stockfish in assembly language!
The newest executables can be found in the master branch while executables from
older versions are in branch "executables".

The x86-64 source files can be found in the asmFish folder on the master branch.
Run make.bat to automatically assemble the windows/linux sources for the three capabilities
  - base: should run on any 64bit x86 cpu
  - popcnt: generate popcnt instruction
  - bmi2: use instructions introduced in haswell

You can customize your assemble of asmFish by setting various flags in the file.
For example, USE_BOOK equ 1 will include several book features.
  - windows: run fasm on asmFishW_base[_popcnt,_bmi2].asm to produce executables
  - linux: run fasm on asmFishL_base[_popcnt,_bmi2].asm to produce executables
  - mac os x: this is tricky because fasm doesn't support the mach-o format.
    Furthermore, fasm needs modification to run on apple boxes. The solution is
    to assemble asmFish to object format. Then, use Agner Fog's object converter
    to convert from elf to mach-o. Finally, this mach-o object file can be linked
    on a real apple box using ld. To sumarize:
    On your windows or linux box:
      $ ./fasm asmFishX_popcnt.asm asmFishX_popcnt.o
      $ ./objconv -fmac asmFishX_popcnt.o asmFishX_popcnt_mac.o
    On your apple box:
        $ ld -o asmFishX_popcnt asmFishX_popcnt_mac.o

The arm-v8 source files can be found in the armFish folder and are written for gas.
These are currently configured to use a basic subset of the linux system calls,
which also happen to work on some android platforms. armFish currently does not
have as many features as asmFish but should be able to play.
  - On your linux box (with cross compilations tools installed):
      $ aarch64-linux-gnu-as -c armFish.arm -o armFish.o
      $ aarch64-linux-gnu-ld -static -o armFish armFish.o
      $ aarch64-linux-gnu-strip armFish
      $ qemu-aarch64 ./armFish


For more information on this project see the asmFish/asmReadMe.txt.

If you observe a crash/misbehaviour in asmFish, please raise an issue here and give the following information:
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
   inconsequential lose about 2 Elo in a head-to-head matchup. The functionality when using
   syzygy is not 100% identical because asmFish uses Ronald's original alpha-beta search while
   official stockfish does not. This causes minor differences due to the piece lists.
   
Q: Where can I find the executable files of the old versions ?
A: All older versions of asmFish/pedantFish are in the branch https://github.com/lantonov/asmFish/tree/executables


******** updates ********
For a change log, see the Wiki https://github.com/lantonov/asmFish/wiki/Change-log
