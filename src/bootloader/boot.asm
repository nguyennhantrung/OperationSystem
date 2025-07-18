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
    push si                 ; si will store the string data
    push ax                 ; will be used to in the .loop
                            ; al (8 lower bit of ax) store the character of string data (si)
                            ; ah (8 higher bit of ax) store the graphic code (TTY)

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

    ; read something from floppy disk
    ; BIOS should set DL to drive number
    mov [ebr_drive_number], dl

    mov ax, 1               ; LBA=1, second sector from disk
    mov cl, 1               ; 1 sector to read
    mov bx, 0x7E00          ; data should be after the bootloader
    call disk_read
    
    ; print message
    mov si, msg_hello       ; Load address of the message into si
    call puts               ; Call puts to print the message

    cli                     ; disable interrupts, this way CPU can't get out of 'halt' state
    hlt                     ; Halt the CPU

floppy_error:
    mov si, msg_read_failed
    call puts
    jmp wait_key_and_reboot

wait_key_and_reboot:
    mov ah, 0
    int 16h                   ; wait for the key press  
    jmp 0FFFFh:0              ; jump to the beginning of BIOS, should reboot

.halt:
    ; jmp .halt               ; Infinite loop to keep the system running
    cli                       ; disable interrupts, this way CPU can't get out of 'halt' state
    hlt                         


; Disk routines


; 
; Converse LBA Scheme to CHS Scheme
; Parameters:
;   - ax: LBA address
; Returns:
;   - cx [bit 0-5]: sector number
;   - cx [bit 6-15]: cylinder
;   - dh: head

lba_to_chs:
    push ax
    push dx

    xor dx, dx                          ; dx = 0
    div word [bdb_sectors_per_track]    ; ax = LBA / SectorsPerTrack
                                        ; dx = LBA % SectorsPerTrack

    inc dx                              ; dx = ( LBA % SectorsPerTrack ) + 1 = sector
    mov cx, dx                          ; cx = sector

    xor dx, dx                          ; dx = 0
    div word [bdb_heads]                ; ax = ( LBA / SectorsPerTrack ) / Heads = Cylinder
                                        ; dx = ( LBA / SectorsPerTrack ) % Heads = head
    mov dh, dl                          ; dh = head
    mov ch, al                          ; ch = cylinder (lower 8 bits)
    shl ah, 6
    or cl, ah                           ; put upper 2 bits of cylinder in CL

    pop ax
    mov dl, al                          ; restore dl
    pop ax
    ret

;
; Reads Sectors from a disk
; Parameters:
;   - ax: LBA address
;   - cl: number of sector to read (up to 128)
;   - dl: drive number
;   - es:dx: memory address where to store read data
;
disk_read:
    push ax                             ; save registers we will modify
    push bx
    push cx
    push dx
    push di

    push cx                             ; temporarily save CL (number of sectors to read)
    call lba_to_chs                     ; compute CHS
    pop ax                              ; AL = number of sector to read

    mov ah, 02h                         ; set Interrupt read disk sector
    mov di, 3                           ; retry count

.retry:
    pusha                               ; save all registers, we don't know what bios modifies
    stc                                 ; set carry flag, some BIOS'es don't set it
    int 13h                             ; carry flag cleared = success
    jnc .done                           ; jump if carry flag not set

    ; read failed
    popa
    call disk_reset

    dec di
    test di, di
    jnz .retry

.fail:
    ; all attempts are exhausted
    jmp floppy_error

.done:
    popa

    pop di
    pop dx
    pop cx
    pop bx
    pop ax                             ; retore registers we modified
    ret

disk_reset:
    pusha
    mov ah, 0                           ; reset disk controller
    stc                                 ; set carry flag
    int 13h                             ; interrupt of Disk IO
    jc floppy_error                     ; if carry flag is set, jump error
    popa
    ret

msg_hello:          db 'Hello World!', ENDL, 0 ; String to print, followed by CR and LF

msg_read_failed:    db 'Read from disk failed!', ENDL, 0 

; In floppy disk boot sector, the first 512 bytes are reserved for the boot code.
times 510-($-$$) db 0       ; Fill the rest of the boot sector with zeros
dw 0xAA55                   ; Boot sector signature
