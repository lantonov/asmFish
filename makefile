now := $(shell /bin/date "+%Y-%m-%d")
all:
	export INCLUDE="arm/include/";./fasmg "arm/fish.arm" "armFishL_$(now)_v8"         -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishL_$(now)_popcnt"     -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishL_$(now)_bmi2"       -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishW_$(now)_popcnt.exe" -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishW_$(now)_bmi2.exe"   -e 1000 -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishX_$(now)_base"       -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'base'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishX_$(now)_popcnt"     -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'"
	export INCLUDE="x86/include/";./fasmg "x86/fish.asm" "asmFishX_$(now)_bmi2"       -e 1000 -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'"
quick:
	export INCLUDE="arm/include/";./fasmg "arm/fish.arm" "armfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'"
test:
	aarch64-linux-gnu-as -o artest.o -march=armv8-a+crc+crypto tartest.arm
	aarch64-linux-gnu-ld -o artest artest.o
#	aarch64-linux-gnu-objcopy -O binary artest.o artest
	aarch64-linux-gnu-strip artest
	aarch64-linux-gnu-objdump -D -maarch64 -b binary artest > artest.txt
	export INCLUDE="arm/include/";./fasmg "tarmfish.arm" "arfish" -e 1000
	aarch64-linux-gnu-objdump -D -maarch64 -b binary arfish > arfish.txt
	diff -U9 arfish.txt artest.txt | less
tfish:
	aarch64-linux-gnu-as -o artest.o artest.arm
	aarch64-linux-gnu-ld -o artest artest.o
#	aarch64-linux-gnu-objcopy -O binary artest.o artest
	aarch64-linux-gnu-strip artest
	aarch64-linux-gnu-objdump -D -maarch64 -b binary artest > artest.txt
	export INCLUDE="arm/include/";./fasmg "armfish.arm" "arfish" -e 1000
	aarch64-linux-gnu-objdump -D -maarch64 -b binary arfish > arfish.txt
	diff -U9 arfish.txt artest.txt | less
