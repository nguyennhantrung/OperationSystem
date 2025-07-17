org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ; Carriage return and line feed

start:
    jmp main

;
; Prints a string  to the screen
; Params:
;   ds:si - pointer to the string
;
puts:
    ; save registers we will modify
    push si
    push ax

.loop:
    lodsb                   ; Load byte at ds:si into al and increment si
    or al, al               ; Check if al is zero (end of string) | verify if next character is null ?
    jz .done                ; If zero, jump to done

    mov ah, 0x0e            ; Function to write character to teletype (TTY)
    int 0x10                ; Call BIOS interrupt to print character in al
    jmp .loop               ; Repeat for next character

.done:
    pop ax                  ; Restore ax
    pop si                  ; Restore si
    ret                     ; Return from puts



main:
    ; setup data segments
    mov ax, 0               ; Can't write to ds/es directly, so we use ax
    mov ds, ax              ; Set data segment to 0
    mov es, ax              ; Set extra segment to 0
    
    ; setup stack
    mov ss, ax              ; Set stack segment to 0
    mov sp, 0x7C00          ; Set stack pointer to the top of the boot sector
                            ; stack grows downwards from where we are loaded in memory

    ; print message
    mov si, msg_hello       ; Load address of the message into si
    call puts               ; Call puts to print the message

    hlt                     ; Halt the CPU

.halt:
    jmp .halt               ; Infinite loop to keep the system running

msg_hello: db 'Hello World!', ENDL, 0 ; String to print, followed by CR and LF


; In floppy disk boot sector, the first 512 bytes are reserved for the boot code.
times 510-($-$$) db 0       ; Fill the rest of the boot sector with zeros
dw 0xAA55                   ; Boot sector signature
