mov ax, 0x0001 ;Set video mode to Text, 40x25, 16 Colors
int 0x10

mov ah, 0x01 ;Remove cursor
mov cx, 0x0706 ;Cursor that starts after it ends lol
int 0x10

mov ah, 0x0f ;Set bh to the active page number
int 0x10

mov byte [page], bh

mov byte [snake], 0x00
mov byte [snake + 1], 0x01
mov byte [snake + 2], 0x11
mov byte [snake + 3], 0x21
mov byte [snake + 4], 0x31
mov byte [snakelen], 0x05

;Clear play area (fill it with white block characters)
mov al, 0xdb ;Block character
mov bl, 0x0f ;Color
mov cx, 16

mov dx, 0x0F00

clear:
mov ah, 0x09 ;Write character
int 0x10

mov ah, 0x02 ;Update cursor position
int 0x10
sub dh, 1
jns clear

ror ebx, 16
mov bx, [snakelen]
sub bl, 1

snek:
;Draw snake
mov ah, 0x02
mov dh, 0xF0
mov dl, [snake+bx]
and dh, dl
shr dh, 4
and dl, 0x0F

ror ebx, 16
int 0x10

mov bl, 0x0a
mov cx, 1
mov ah, 0x09
int 0x10

ror ebx, 16
sub bl, 1
jns snek

_a: jmp _a

times 510-($-$$) db 0 ;Fill the rest of the file with zeros
db 0x55, 0xaa ;Boot flag magic

;Variables
[absolute 0x00]
page resb 1
snake resb 16
snakelen resb 1
