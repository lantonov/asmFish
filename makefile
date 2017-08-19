now := $(shell /bin/date "+%Y-%m-%d")
all:
	export INCLUDE="arm/include/";\
	./fasmg "armfish.arm" "arfish"
test:
	aarch64-linux-gnu-as -c artest.arm -o artest.o
	aarch64-linux-gnu-ld -static -o artest artest.o
	aarch64-linux-gnu-strip artest
intel:
	export INCLUDE="x86/include/";\
	./fasmg "intest.asm" "intest"
asm:
	export INCLUDE="x86/include/";\
	./fasmg "x86fish.asm" "afish" -e 1000
arm:
	export INCLUDE="arm/include/";\
	./fasmg "armfish.arm" "arfish"

