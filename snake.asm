mov ah, 0x00
int 0x1a
mov [seed], dl
mov byte [lrand], 0x00

mov ax, 0x0001 ;Set video mode to Text, 40x25, 16 Colors
int 0x10

mov ah, 0x01 ;Remove cursor
mov cx, 0x0706 ;Cursor that starts after it ends lol
int 0x10

mov byte [direction], 0x01
mov byte [color], 0x00

mov byte [snake], 0x00
mov byte [snakelen], 1

;Just a quick, intial value
mov dl, [seed]
mov byte [apple], dl
cmp dl, 0x00
jne goodinitial
mov byte [apple], 0xf8 ;Spawn the apple at a fixed place, if it's at player spawn

goodinitial:

;Spam white block characters
mov al, 0xdb
mov bl, 0x0f
mov cx, 0xffff

mov dx, 0x1000
mov ah, 0x02
int 0x10
mov ah, 0x09
int 0x10

gameloop:
mov ah, 0x0f ;Set bh to the active page number
int 0x10

ror ebx, 16 ;Stash away active page

;Clear play area
mov ax, 0x0700
mov bh, 0x00
mov cx, 0x0000
mov dx, 0x0F0F
int 0x10

;Draw snake
mov bx, [snakelen]
sub bl, 1

snek:
mov ah, 0x02
mov dh, 0xF0
mov dl, [snake+bx]
and dh, dl
shr dh, 4
and dl, 0x0F

ror ebx, 16 ;Get active page
int 0x10

mov al, 0xdb ;Block character
mov bl, 0x0a
mov cx, 1
mov ah, 0x09
int 0x10

ror ebx, 16 ;Stash away active page
sub bl, 1
jns snek

ror ebx, 16 ;Get active page

;Draw apple
mov ah, 0x02
mov dh, 0xF0
mov dl, [apple]
and dh, dl
shr dh, 4
and dl, 0x0F
int 0x10 ;Set cursor pos

mov al, 0xdb
mov bl, 0x0c
mov cx, 1
mov ah, 0x09
int 0x10

;Wait
mov byte [waitabit], 10
moarwait:
mov ah, 0x00
int 0x1a
mov bx, dx
_wait:
int 0x1a
sub dx, bx
add dx, 0xFFFF
jnz _wait
sub byte [waitabit], 1
jnz moarwait


;Keyboard input
mov bl, 0x00
readkeys:
mov ax, 0x0100 ;Get keyboard status
int 0x16
jz keyreaddone ;Jump if there aren't any keys
mov ah, 0x00
int 0x16
mov bl, al
jmp readkeys
keyreaddone:

cmp bl, 0x00
je keydone ;Jump if no key has been read

cmp bl, 0x77 ;w
jne keyn1
mov byte [direction], 0xF0

keyn1:
cmp bl, 0x73 ;s
jne keyn2
mov byte [direction], 0x10

keyn2:
cmp bl, 0x61 ;a
jne keyn3
mov byte [direction], 0x0F

keyn3:
cmp bl, 0x64 ;d
jne keydone
mov byte [direction], 0x01

keydone:

;Move the snake
xor bx, bx
mov byte bl, [snakelen]
mov byte dl, [snake+bx-1]

mov al, [direction]
and al, 0x0F
add dl, al
and dl, 0x0F

mov byte cl, [snake+bx-1]
and cl, 0xF0
mov al, [direction]
and al, 0xF0
add cl, al
add dl, cl
mov byte [snake+bx], dl

mov byte bx, [snakelen]
mov bl, [snake + bx]
sub bl, [apple]
jz skiprsnake

inc byte [snakelen] ;Update snakelen


;Reduce snake size again
mov bx, 0x01
mov cx, 0x00
_ksnek:
mov byte dl, [snake+bx]
and dl, 0xFF
mov byte [snake+bx-1], dl
inc cl
inc bx
cmp [snakelen], cl
jnz _ksnek

dec byte [snakelen]
jmp donemoveupdate

skiprsnake: ;On apple collision
inc byte [snakelen] ;Update snakelen
mov byte edx, [seed]
imul edx, 0x736e656b ;snek in hex
add byte edx, [lrand]
mov [lrand], dl
mov [apple], dl

donemoveupdate:
jmp gameloop

_a: jmp _a

times 510-($-$$) db 0 ;Fill the rest of the file with zeros
db 0x55, 0xaa ;Boot flag magic

;Variables
snake equ 0x8000
snakelen equ 0x8031
direction equ 0x8040
color equ 0x8042
waitabit equ 0x8044
apple equ 0x8046
seed equ 0x8048
lrand equ 0x8050
