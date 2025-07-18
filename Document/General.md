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
### INT 13,2 - Read Disk Sectors
[text](https://www.stanislavs.org/helppc/int_13-2.html)
AH = 02
AL = number of sectors to read	(1-128 dec.)
CH = track/cylinder number  (0-1023 dec., see below)
CL = sector number  (1-17 dec.)
DH = head number  (0-15 dec.)
DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
ES:BX = pointer to buffer

On return:
	AH = status
	AL = number of sectors read
	CF = 0 if successful
	   = 1 if error

- BIOS disk reads should be retried at least three times and the
 controller should be reset upon error detection
- be sure ES:BX does not cross a 64K segment boundary or a
 DMA boundary error will occur
- many programming references list only floppy disk register values
- only the disk number is checked for validity
- the parameters in CX change depending on the number of cylinders;
 the track/cylinder number is a 10 bit value taken from the 2 high
 order bits of CL and the 8 bits in CH (low order 8 bits of track):

 |F|E|D|C|B|A|9|8|7|6|5-0|  CX
  | | | | | | | | | |	`-----	sector number
  | | | | | | | | `---------  high order 2 bits of track/cylinder
  `------------------------  low order 8 bits of track/cyl number



# Disk layout
Disk is divived into multiple rings called Track/Cylinder
Each track is divided into pizza slices called Sector
Floppy Disk can store data in both side of platter
Each side of platter called a head
To read or write data, we need Sector number, Cylinder number, head number
-> This Address scheme is called cylinder head sector (CHS)
-> This scheme is useful for working with physical Data on disk only
To work with data, we only care about the beginning, the middle, the end of data
-> This Address scheme is called Logical Block Addressing
-> Instead of 3 params, we only need 1 param for addressing data
The BIOS only support CHS Address => Need to make a conversion ourselves
## LBA to CHS Coneversion
In CHS, the cylinder and head start form 0 but sector start from 1
- sector    = ( LBA % sector_per_track ) + 1
- head      = ( LBA / sector_per_track ) % head_per_cylinder
- cylinder  = ( LBA / sector_per_track ) / head_per_cylinder



