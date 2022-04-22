.code16
.org 0

.text

.global _start
_start:
mov $0x0e, %ah
mov $'F', %al
int $0x10

.fill 510-(.-_start), 1, 0
.word 0xaa55
