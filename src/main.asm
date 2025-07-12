org 0x7C00
bits 16
; Boot sector code to print "Hello, World!" on the screen

main:
    hlt                     ; Halt the CPU

.halt:
    jmp .halt               ; Infinite loop to keep the system running

; In floppy disk boot sector, the first 512 bytes are reserved for the boot code.
times 510-($-$$) db 0        ; Fill the rest of the boot sector with zeros
dw 0xAA55                   ; Boot sector signature
