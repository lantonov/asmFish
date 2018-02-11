now := $(shell /bin/date "+%Y-%m-%d")
all:
	./fasmg "arm/fish.arm" "armFishL_$(now)_v8"         -i "VERSION_OS='L'"
	./fasmg "x86/fish.asm" "asmFishL_$(now)_base"       -i "VERSION_OS='L'"
	./fasmg "x86/fish.asm" "asmFishL_$(now)_popcnt"     -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'"
	./fasmg "x86/fish.asm" "asmFishL_$(now)_bmi2"       -i "VERSION_OS='L'" -i "VERSION_POST = 'bmi2'"
	./fasmg "x86/fish.asm" "asmFishW_$(now)_base.exe"   -i "VERSION_OS='W'"
	./fasmg "x86/fish.asm" "asmFishW_$(now)_popcnt.exe" -i "VERSION_OS='W'" -i "VERSION_POST = 'popcnt'"
	./fasmg "x86/fish.asm" "asmFishW_$(now)_bmi2.exe"   -i "VERSION_OS='W'" -i "VERSION_POST = 'bmi2'"
	./fasmg "x86/fish.asm" "asmFishX_$(now)_base"       -i "VERSION_OS='X'"
	./fasmg "x86/fish.asm" "asmFishX_$(now)_popcnt"     -i "VERSION_OS='X'" -i "VERSION_POST = 'popcnt'"
	./fasmg "x86/fish.asm" "asmFishX_$(now)_bmi2"       -i "VERSION_OS='X'" -i "VERSION_POST = 'bmi2'"
quick:
	./fasmg "arm/fish.arm" "armfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'";     chmod 755 ./armfish
	./fasmg "x86/fish.asm" "asmfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'"; chmod 755 ./asmfish
bincheck:
	./fasmg "arm/fish.arm" "NEWarmfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'v8'"
	./fasmg "x86/fish.asm" "NEWasmfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST = 'popcnt'"
	diff "NEWarmfish" "armfish"
	diff "NEWasmfish" "asmfish"
asmquick:
	./fasmg "x86/fish.asm" "asmfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST='popcnt'"; chmod 755 ./asmfish
armquick:
	./fasmg "arm/fish.arm" "armfish" -e 1000 -i "VERSION_OS='L'" -i "VERSION_POST='v8'"; chmod 755 ./armfish
test:
	aarch64-linux-gnu-as -o master.o -march=armv8-a+crc+crypto "arm/include/master.arm"
	aarch64-linux-gnu-ld -o master master.o
#	aarch64-linux-gnu-objcopy -O binary master.o master
	aarch64-linux-gnu-strip master
	aarch64-linux-gnu-objdump -D -maarch64 -b binary master > master.txt
	./fasmg "arm/include/slave.arm" "slave" -e 1000
	aarch64-linux-gnu-objdump -D -maarch64 -b binary slave > slave.txt
	diff -U9 slave.txt master.txt | less
hellome:
	./fasmg "arm/include/hello/elf_obj.arm" "hello.o"
