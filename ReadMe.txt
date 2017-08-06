******** introduction ********
Welcome to the project of translating Stockfish in assembly language!
The newest executables can be found in the master branch while executables from
older versions are in branch "executables".

The x86-64 source files can be found in the asmFish folder on the master branch.
Run make.bat to assemble the windows/linux sources for the three capabilities
  - base: should run on any 64bit x86 cpu
  - popcnt: generate popcnt instruction
  - bmi2: use instructions introduced in haswell

******** building ********
Building is only straightforward on linux and windows, where fasm runs natively.
You can customize your assemble of asmFish by setting various flags in the files.
For example, you may set USE_BOOK equ 1 in asmFish/asmFishW_popcnt.asm.

  - windows: run fasm on asmFishW_base[_popcnt,_bmi2].asm to produce executables.
    NOTE: windows version has no choice but to link with kernel32.dll.

  - linux: run fasm on asmFishL_base[_popcnt,_bmi2].asm to produce executables
    NOTE: linux version links with nothing.

  - mac os x: this is tricky because fasm doesn't support the mach-o format.
    Furthermore, fasm needs modification to run on apple boxes. The solution is
    to assemble asmFish to object format. Then, use Agner Fog's object converter
                http://www.agner.org/optimize/#objconv
    to convert from elf to mach-o. Finally, this mach-o object file can be linked
    on a real apple box using ld. To sumarize:
    On your windows or linux box:
      $ ./fasm asmFishX_popcnt.asm asmFishX_popcnt.o
      $ ./objconv -fmac asmFishX_popcnt.o asmFishX_popcnt_mac.o
      objconv will give an important warning message about 32 bit addresses.
      This cannot be avoided. 32 bit addresses are integral to the x86 version.
    On your apple box:
      $ gcc asmFishX_popcnt_mac.o -image_base 400000 -pagezero_size 1000 -lm -o asmFishX_popcnt
    You now have the asmFishX_popcnt executable.
    NOTE: mac os x version should be linking with libSystem.dylib. As apple's
          documentation of the system call interface for mac os x is poor at best,
          it will take some time to remove this linkage.
    NOTE: os x kernel is numa-unaware.

  - generic libc: you can run fasm on asmFishC_popcnt.asm to produce an elf object
    file for linking with POSIX libc implementations. Some assembly is required
    here since the definitions in asmFish/guts/libc64.asm need to match those
    of your system.
    NOTE: libc is numa-unaware of course.

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


******** misbehaviour ************
If you observe a crash/misbehaviour in asmFish, please raise an issue here
and give the following information:
  - name of the executable that crashed/misbehaved
  - exception code and exception offset in the case of a crash
  - a log of the commands that were sent to asmFish by your gui before the crash
Simply stating that asmFish crashed in your gui is useless information by itself.


asmFish is known to have problems in the fritz15 gui, while it plays much better
in the fritz11 gui.

Windows might through a "The system cannot execute the specified program." or
"Insufficient system resources exist to complete the requested service.". The
likely source of this problem is your virus software. Rest assured that the
sources here do not produce any behaviour that is even remotely virus-like
(unless you run analysis for a long time witn syzygy6 installed).


******** FAQ ********
Q: Why not just start with the compiler output and speed up the critical functions?
   or write critical functions in asm and include them in cpp code?
A: With this approach the critical functions would still need to conform to the
   standards set in place by the ABI. All of the critical functions in asmFish do
   not conform to these standards. Plus, asmFish would be dependent on a compiler
   in this case, which introduces many unnecessary compilcations. Both asmFish
   and its assembler are around 100KB; lets keep it simple. Note that compiler
   output was used in the case of Ronald de Man's syzygy probing code, as this
   is not speed critical but cumbersome to write by hand.

Q: Is asmFish search the same as official stockfish?
A: It does now that PEDANTIC = 1 is the default! The changes previously thought
   to be inconsequential lose about 2 Elo in a head-to-head matchup. The
   functionality when using syzygy is not 100% identical because asmFish uses
   Ronald's original alpha-beta search while official stockfish does not. This
   causes minor inconsequential differences due to the piece lists.
   
Q: Where can I find the executable files of the old versions ?
A: All older versions of asmFish/pedantFish are in the branch
   https://github.com/lantonov/asmFish/tree/executables


******** updates ********
For a change log, see the Wiki https://github.com/lantonov/asmFish/wiki/Change-log
