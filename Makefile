files = snake.asm

out: $(files)
	nasm -O0 -o out $(files)

dump: out
	objdump -D -b binary -m i8086 -M intel-mnemonic out

disk.img: out
	dd if=/dev/zero of=disk.img bs=256 count=5625
	dd if=out of=disk.img conv=notrunc

run: disk.img
	qemu-system-x86_64 -drive file=disk.img,if=floppy,format=raw -boot order=a

clean:
	rm -rf out disk.img
