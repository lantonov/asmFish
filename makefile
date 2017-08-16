now := $(shell /bin/date "+%Y-%m-%d")
all:
	export INCLUDE="x86/include/";\
	./fasmg "x86fish.asm" "asmFishL_$(now)_popcnt"
quick:
	export INCLUDE="x86/include/";\
	./fasmg "x86fish.asm" "afish"

