.code16
.org 0

.text

.set snake,     0x8000 /* 255 */
.set snakelen,  0x8100 /* 1 */
.set direction, 0x8101 /* 1 */
.set waitabit,  0x8102 /* 1 */
.set apple,     0x8103 /* 1 */
.set active,    0x8104 /* 1 */
.set temp,      0x8105 /* 2 */

.global _start
_start:

mov $0001, %ax /* Set video mode to Text, 40x25, 16 Colors */
int $0x10

mov $1, %ah /* Remove cursor */
mov $0x0706, %cx /* Cursor that starts after it ends lol */
int $0x10

game:

movb $1, direction

/* Spawn 3-wide snake at upper-left corner facing right */
movw $0x0100, (snake)
movb $2, (snake+2)
movb $3, snakelen

/* Set apple to lower part of lower-order clock */
mov $0x00, %ah
int $0x1a
mov %dl, apple

/* Spawn the apple at a fixed place, if it's at player spawn */
cmpb $0x03, apple
jnb goodinitial

movb $0xf8, apple

goodinitial:

/* Spam white block characters */
mov $0x0f, %bl
mov $0xffff, %cx

mov $0x1000, %dx
mov $0x02db, %ax
int $0x10
mov $0x09, %ah
int $0x10

gameloop:
mov $0x0f, %ah /* Set bh to the active page number */
int $0x10
mov %bh, active


/* Clear play area */
mov $0x0700, %ax
mov $0x00, %bh
mov $0x0000, %cx
mov $0x0F0F, %dx
int $0x10

/* Draw snake */
movb snakelen, %bl
sub $1, %bl

snek:
mov $0x02, %ah
mov $0xF0, %dh
mov snake(%bx), %dl
and %dl, %dh
shr $4, %dh
and $0x0F, %dl

mov %bx, temp
mov active, %bh
int $0x10

mov $0xdb, %al /* Block character */
mov $0x0a, %bl
mov $1, %cx
mov $0x09, %ah
int $0x10

mov temp, %bx
sub $1, %bl
jns snek

mov active, %bh

/* Draw apple */
mov $0x02, %ah
mov $0xF0, %dh
mov apple, %dl
and %dl, %dh
shr $4, %dh
and $0x0F, %dl
int $0x10 /* Set cursor pos */

mov $0x09db, %ax
mov $0x0c, %bl
mov $1, %cx
int $0x10

/* Wait to slow game loop */
movb $10, waitabit
moarwait:
mov $0x00, %ah
int $0x1a
mov %dx, %bx
_wait:
int $0x1a
sub %bx, %dx
add $0xFFFF, %dx
jnz _wait
subb $1, waitabit
jnz moarwait

/* Keyboard input */
mov $0x00, %bl
readkeys:
mov $0x0100, %ax /* Get keyboard status */
int $0x16
jz keyreaddone /* Jump if there aren't any keys */
mov $0x00, %ah
int $0x16
mov %ax, %bx
jmp readkeys
keyreaddone:

cmp $0x48, %bh /* up arrow */
jne keyn1
movb $0xF0, direction

keyn1:
cmp $0x50, %bh /* down arrow */
jne keyn2
movb $0x10, direction

keyn2:
cmp $0x4B, %bh /* left arrow */
jne keyn3
movb $0x0F, direction

keyn3:
cmp $0x4D, %bh /* right arrow */
jne keydone
movb $0x01, direction

keydone:

/* Grow the snake towards direction */
xor %bx, %bx
mov snakelen, %bl
movb (snake-1)(%bx), %dl

mov direction, %al
and $0x0F, %al
add %al, %dl
and $0x0F, %dl

movb (snake-1)(%bx), %cl
and $0xF0, %cl
mov direction, %al
and $0xF0, %al
add %al, %cl
add %cl, %dl
mov %dl, snake(%bx)

/* Check snake-snake intersection */
mov snakelen, %bl
mov snake(%bx), %dl
mov snakelen, %cl
sub $1, %cl
killsnek:
mov %cx, %bx
cmpb %dl, snake(%bx)
jz ded
loop killsnek

/* Check apple collision */
mov snakelen, %bl
mov snake(%bx), %bl
sub apple, %bl
jz skiprsnake

/* Shift the snake data to reduce its size again */
mov $0x01, %bx
mov $0x00, %cx
_ksnek:
mov snake(%bx), %dl
and $0xFF, %dl
mov %dl, (snake-1)(%bx)
inc %cl
inc %bx
cmp %cl, snakelen
jnz _ksnek

jmp donemoveupdate

skiprsnake: /* On apple collision */
incb snakelen /* Update snakelen */

/* RANDOM BULLSHIT GO! */
/* Modified XORshift 16-bit for 8 bits instead */
mov apple, %bl
mov apple, %bh

mov %bx, %dx
shr $7, %dx
xor %bx, %dx
mov %dx, %bx

shl $9, %dx
xor %bx, %dx
mov %dx, %bx

shr $13, %dx
xor %bx, %dx
mov %dx, %bx

xor %bl, %bh

mov %bl, apple

donemoveupdate:

jmp gameloop

ded: /* Death screen */
mov $0x0f, %ah
int $0x10
mov $0x02, %ah
mov $0x0010, %dx
int $0x10
mov $0x0f, %bl
mov $0x01, %cx
mov $0x0946, %ax /* Character "F", mode 09h */
int $0x10

/* Wait for keypress, then restart */
mov $0x00, %ah
int $0x16
jmp game

/* Boot flag magic */
.fill 510-(.-_start), 1, 0
.word 0xaa55
