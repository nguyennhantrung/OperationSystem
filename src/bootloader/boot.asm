org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A ; Carriage return and line feed


; FAT12 Header
jmp short start
nop

bdb_oem:								db 'MSWIN4.1'			; 8 bytes
bdb_bytes_per_sector: 					dw 512
bdb_sectors_per_cluster:				db 1
bdb_reserved_sectors:					dw 1
bdb_fat_count:							db 2
bdb_dir_entries_count:					dw 0E0h
bdb_total_sectors:						dw 2880					; 2880 * 512 = 1474560 (Bytes) ~ 1.44 MB
bdb_media_description_type:				db 0F0h					; F0 = 3.5" floppy disk
bdb_sectors_per_fat:					dw 9
bdb_sectors_per_track:					dw 18
bdb_heads:								dw 2
bdb_hiden_sectors:						dd 0
bdb_large_sector_count:					dd 0

; extend boot record
ebr_drive_number:						db 0					; 0x00 floppy disk, 0x80 hard disk
										db 0					; reserved
ebr_signature:							db 29h					; must be 0x28 or 0x29 
ebr_volume_id:							db 12h, 34h, 56h, 78h	; serial number. The value doesn't matter
ebr_volume_label:						db 'NNTRUNG_OS '		; 11 Bytes, padded with space
ebr_system_id:							db 'FAT12   '			; 8 Bytes


; Code start here
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
