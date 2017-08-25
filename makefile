now := $(shell /bin/date "+%Y-%m-%d")
all:
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishL_$(now)_popcnt"     -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishL_$(now)_bmi2"       -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'"   -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishW_$(now)_popcnt.exe" -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishW_$(now)_bmi2.exe"   -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'"   -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX_$(now)_base"       -i "VERSION_OS='X'" -i "VERSION_POST = 'base'"   -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX_$(now)_popcnt"     -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX_$(now)_bmi2"       -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'"   -e 1000
quick:
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "afish" -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -e 1000
test:
	aarch64-linux-gnu-as -o artest.o artest.arm
	aarch64-linux-gnu-ld -o artest artest.o
#	aarch64-linux-gnu-objcopy -O binary artest.o artest
	aarch64-linux-gnu-strip artest
	aarch64-linux-gnu-objdump -D -maarch64 -b binary artest > artest.txt
	export INCLUDE="arm/include/";./fasmg "armfish.arm" "arfish" -e 1000
	aarch64-linux-gnu-objdump -D -maarch64 -b binary arfish > arfish.txt
	diff -U16 arfish.txt artest.txt | less
