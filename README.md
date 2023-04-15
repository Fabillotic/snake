# snake
Boot sector snake in 430 bytes!

![screenshot](screenshot.png)

## How to build
### Requirements:
Building:
binutils (as, ld)

Running:
qemu / dosbox

### Building
```make``` -> Make a floppy disk image (disk.img)

### Running
```make run``` -> Run using default runner (dosbox)

```make run_qemu``` -> Run using qemu

```make run_dosbox``` -> Run using dosbox

(The default runner can be changed with ```DEFAULT_RUN``` of the Makefile)

## How to play
Moving the snake: arrow keys

Basic snake movement

You can go through the one side of the play space and come out from the other.

When you die and F appears on the right of the screen, just press any key to start again.
