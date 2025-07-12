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
- Stads for "define byte(s)". Write given bytes to the assembled binary file.
# dw word1, word2, word3...
- Directive
- Stads for "define byte(s)". Write given words (2 bytes value, encoded in little endian) to the assembled binary file.
# time number instuction/data 
- Directive
- Repeats given instruction or piece of data a number of times.
# $
- Specail symbol which is equal to the memory offset of the current line.
# $$
- Specail symbol which is equal to the memory offset of the beginning of the current section (in our case, program).
# ($-$$)
- Given the size of our program so far (in bytes). 












