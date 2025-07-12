# Overview

# Hardware purpose
- x86 system
- Legacy boot

# How the BIOS finds an OS
## Legacy system
- Bios load the first sector of each bootable device into memory (at location 0x7C00)
- Bios checks for 0xAA55 signature
- If found, it starts executing code
## EFI
- BIOS looks into special EFI partitions
- OS must be compiled as EFI program