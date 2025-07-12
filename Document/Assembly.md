This is NASM

# org
- Directive 
- Tell assembler where we expect our code to be loaded. The assembler use this info to calculate lable address
# bits
- Directive
- Tells assembler to emit 16/32/64-bit code
# jmp location 
- jumps to given location, uncodinationally (equivalent to goto in c)
# db byte1, byte2, byte3...
- Directive
- Stands for "define byte(s)". Write given bytes to the assembled binary file.
# dw word1, word2, word3...
- Directive
- Stands for "define byte(s)". Write given words (2 bytes value, encoded in little endian) to the assembled binary file.
# time number instuction/data 
- Directive
- Repeats given instruction or piece of data a number of times.
# $
- Specail symbol which is equal to the memory offset of the current line.
# $$
- Specail symbol which is equal to the memory offset of the beginning of the current section (in our case, program).
# ($-$$)
- Given the size of our program so far (in bytes). 
# mov destination, source
- Copy data from source (register, emmory reference, constant) to destination (register or memory reference)
var: dw 100
    mov ax, var         ; copy offset to ax
    mov ax, [var]       ; copy memory contents
array: dw 100, 200, 300
    mov bx, array       ; copy offset to ax
    mov si, 2*2         ; array[2], words are 2 bytes wide
    mov ax, [bx + si]   ; copy memory contents

# loadsb, lodsw, lodsd 
- These instructions load a byt/word/double-word from DS:SI into AL/AX/EAX, then increase SI by the number of bytes loaded.
# or destination, source
- Performs bitwise OR between source and destination, stores result in destination
- also modifies some flags in the flags register, such as the Zero Flag if the result is zero.












