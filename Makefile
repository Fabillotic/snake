files = snake.S

all: disk.img

out.bin: $(files)
	as --32 -mx86-used-note=no -o out.o $(files)
	ld -m elf_i386 -o out.bin out.o -Ttext 0x7C00 --oformat=binary

dump: out.bin
	objdump -D -b binary -m i8086 -M intel-mnemonic out.bin

disk.img: out.bin
	dd if=/dev/zero of=disk.img bs=256 count=5625
	dd if=out.bin of=disk.img conv=notrunc

run: disk.img
	qemu-system-x86_64 -drive file=disk.img,if=floppy,format=raw -boot order=a

run_dosbox: disk.img
	dosbox -c "BOOT disk.img -l a"

clean:
	rm -rf out.* disk.img

.PHONY: all, dump, run, run_dosbox, clean
