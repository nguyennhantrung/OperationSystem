# Overview

# Hardware purpose
- x86 system
- Legacy boot

# Build and Run
## Build
cd $(project_dir)
make
## Run
cd $(project_dir)
qemu-system-i386 -fda build/main_floppy.img 

# How the BIOS finds an OS
## Legacy system
- Bios load the first sector of each bootable device into memory (at location 0x7C00)
- Bios checks for 0xAA55 signature
- If found, it starts executing code
## EFI
- BIOS looks into special EFI partitions
- OS must be compiled as EFI program

# RAM
- 8086 CPU has 20-bit address bus
## Memory segment
0x1234  :   0x5678
segment :   offset
- segment (16-bit): contain 64 kilobytes of memory. Each byte can be accessed using offset value
- segment overlap every 16 bytes
- Convert a segment offset address to absolute address by shifting the segment four bitsto the left or multiflying it by 16 and then adding the offset
=> real_address = segment * 16 + offset
segment :   offset      => real address
0xx0000 :   0X7C00      => 0X7C00
0xx0001 :   0X7BF0      => 0X7C00
0xx0010 :   0X7B00      => 0X7C00
0xx00C0 :   0X7000      => 0X7C00
0xx07C0 :   0X0000      => 0X7C00
### These registers are used to specific currently active segments:
CS - curretnly running code segment
ds - data segment
ss - stack segment
es,fs,gs - extra (data) segments
### Referencing a memory location
segment:[base + index * scale + displacement]
All fields are optional
- segment: CS, DS, ES, FS, GS, SS (if unspecified, SS when base register is BP; DS is otherwise)
- base: (16 bits) BP/BX, (32/64 bits) any general purpose register
- index: (16 bits) SI/DI, (32/64 bits) any general purpose register
- scale: (32/64 bits only) 1, 2, 4, 8
- displacement: a (signed) constant value
### The stack
- memory accessed in a FIFO (first in first out) manner using push and pop
- used to save the return address when calling functions

# Interrupts
A signal which makkes the processor stop what it's doing, in order  to handle that signal.
Can be triggered by:
  1. An eception (e.g. dividing by zero, segmentation fault, page fault)
  2. Hardware (e.g. keyboard key pressed or released, timer tick, disk controller finished an operation)
  3. Software (through the INT instruction)
## Examples of BIOS interrupts
INT 10h -- Video
    AH = 00h -- Set Video Mode
    AH = 01h -- Set Cursor Sharp
    AH = 02h -- Set Cursor Position
    AH = 03h -- Get Cursor Position and Shape
    ...
    AH = 0Eh -- Write Character in TTY mode
    ...
INT 11h -- Equipment Check
INT 12h -- Memory Size 
INT 13h -- Disk I/O
INT 14h -- Serial communications
INT 15h -- Cassette
INT 16h -- Keyboard I/O
### BIOS INT 10h, AH = 0Eh
Prints a character to the screen in TTY mode

AH = 0E
AL = ASCII character to write
BH = page number (text modes)
BL = foreground piel color (graphics mode)

returns nothing

- cursor advances after write
- characters BEL (7), BS (8), LF (A), CR (D) are treated as control codes