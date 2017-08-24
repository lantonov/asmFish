now := $(shell /bin/date "+%Y-%m-%d")
all:
	export INCLUDE="arm/include/";./fasmg "armfish.arm" "arfish" -e 1000
full:
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishL_$(now)_popcnt"     -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishL_$(now)_bmi2"       -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'"   -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishW_$(now)_popcnt.exe" -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishW_$(now)_bmi2.exe"   -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'"   -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX_$(now)_popcnt"     -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'" -e 1000
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX_$(now)_bmi2"       -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'"   -e 1000
quick:
	export INCLUDE="x86/include/";./fasmg "x86fish.asm" "asmFishX"     -i "VERSION_OS='X'" -i "VERSION_POST = 'base'" -e 1000
test:
	aarch64-linux-gnu-as -c artest.arm -o artest.o
	aarch64-linux-gnu-ld -static -o artest artest.o
	aarch64-linux-gnu-strip artest

