SRC = snake.S
OBJ = out.o
BIN = out.bin
DISK = disk.img
DEFAULT_RUN = dosbox

all: $(DISK)

$(OBJ): $(SRC)
	as --32 -mx86-used-note=no -o $(OBJ) $(SRC)

$(BIN): $(OBJ)
	ld -m elf_i386 -o $(BIN) $(OBJ) -Ttext 0x7C00 --oformat=binary

dump: $(BIN)
	objdump -D -b binary -m i8086 -M att-mnemonic $(BIN)

$(DISK): $(BIN)
	dd if=/dev/zero of=$(DISK) bs=512 count=2880
	dd if=$(BIN) of=$(DISK) conv=notrunc bs=1

run: run_$(DEFAULT_RUN)

run_qemu: $(DISK)
	qemu-system-x86_64 -drive file=$(DISK),if=floppy,format=raw -boot order=a

run_dosbox: $(DISK)
	dosbox -c "BOOT $(DISK) -l a"

clean:
	rm -rf $(OBJ) $(BIN) $(DISK)

.PHONY: all, dump, run, run_qemu, run_dosbox, clean
