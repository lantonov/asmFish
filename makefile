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
	aarch64-linux-gnu-as -o master.o -march=armv8-a+crc+crypto "arm/include/master.arm"
	aarch64-linux-gnu-ld -o master master.o
#	aarch64-linux-gnu-objcopy -O binary master.o master
	aarch64-linux-gnu-strip master
	aarch64-linux-gnu-objdump -D -maarch64 -b binary master > master.txt
	export INCLUDE="arm/include/";./fasmg "arm/include/slave.arm" "slave" -e 1000
	aarch64-linux-gnu-objdump -D -maarch64 -b binary slave > slave.txt
	diff -U9 slave.txt master.txt | less
