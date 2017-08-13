now := $(shell /bin/date "+%Y-%m-%d")
all:
	aarch64-linux-gnu-as -c "armFish.arm" -o "armFishL_$(now)_v8.o"
	aarch64-linux-gnu-ld -static -o "armFishL_$(now)_v8" "armFishL_$(now)_v8.o"
	aarch64-linux-gnu-strip "armFishL_$(now)_v8"
quick:
	aarch64-linux-gnu-as -c "armFish.arm" -o "armFish.o"
	aarch64-linux-gnu-ld -static -o "armFish" "armFish.o"
	aarch64-linux-gnu-strip "armFish"

