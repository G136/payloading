N = $$(( 0x67000 ))

all: clean build test

clean:
	rm -f *.bin
	rm -f *.img

build: clean
	nasm -f bin boot.asm -o boot.bin -dN=$N
	dd if=/dev/random of=payload bs=1 count=$N

	dd if=/dev/zero   of=boot.img bs=1024 count=1440
	dd if=boot.bin    of=boot.img conv=notrunc
	dd if=payload     of=boot.img conv=notrunc seek=1

test: build
	qemu-system-i386 -cpu pentium2 -m 1g -fda boot.img -device VGA

debug: build
	qemu-system-i386 -cpu pentium2 -m 1g -fda boot.img -monitor stdio -device VGA -s -S &
	gdb

.PHONY: all clean build test debug
