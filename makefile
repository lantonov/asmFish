now := $(shell /bin/date "+%Y-%m-%d")
all:
	./asmFish/fasm "asmFish/asmFishW_base.asm"      -m 50000 "Windows/asmFishW_$(now)_base.exe"
	./asmFish/fasm "asmFish/asmFishW_popcnt.asm"    -m 50000 "Windows/asmFishW_$(now)_popcnt.exe"
	./asmFish/fasm "asmFish/asmFishW_bmi2.asm"      -m 50000 "Windows/asmFishW_$(now)_bmi2.exe"
	./asmFish/fasm "asmFish/pedantFishW_base.asm"   -m 50000 "Windows/pedantFishW_$(now)_base.exe"
	./asmFish/fasm "asmFish/pedantFishW_popcnt.asm" -m 50000 "Windows/pedantFishW_$(now)_popcnt.exe"
	./asmFish/fasm "asmFish/pedantFishW_bmi2.asm"   -m 50000 "Windows/pedantFishW_$(now)_bmi2.exe"
	./asmFish/fasm "asmFish/asmFishL_base.asm"      -m 50000 "Linux/asmFishL_$(now)_base"
	./asmFish/fasm "asmFish/asmFishL_popcnt.asm"    -m 50000 "Linux/asmFishL_$(now)_popcnt"
	./asmFish/fasm "asmFish/asmFishL_bmi2.asm"      -m 50000 "Linux/asmFishL_$(now)_bmi2"
	./asmFish/fasm "asmFish/pedantFishL_base.asm"   -m 50000 "Linux/pedantFishL_$(now)_base"
	./asmFish/fasm "asmFish/pedantFishL_popcnt.asm" -m 50000 "Linux/pedantFishL_$(now)_popcnt"
	./asmFish/fasm "asmFish/pedantFishL_bmi2.asm"   -m 50000 "Linux/pedantFishL_$(now)_bmi2"