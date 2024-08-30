.global main
main:
push {IP,LR}

@Prompt for string
ldr r0,=inputPrompt
bl printf
ldr r1,=inputString
ldr r0,=scanFormat
bl scanf

@Prompt for algorithm
ldr r0,=typePrompt
bl printf
ldr r1,=type
ldr r0,=scanNumber
bl scanf

@Prompt for encryption or decryption
ldr r0,=directionPrompt
bl printf
ldr r1,=direction
ldr r0,=scanNumber
bl scanf

@Check input
ldr r6,=type
ldr r7,[r6]
ldr r6,=direction
ldr r8,[r6]
@Jump to Caesar if type=1, otherwise continue and check if encryption substituion or decryption
cmp r7,#1
beq caesar
cmp r8,#1
beq encryptS
bne decryptS

caesar:
@Prompt for caesar offset
ldr r0,=seedPrompt
bl printf
ldr r1,=seed
ldr r0,=scanNumber
bl scanf
@check for encryption or decryption Caesar
cmp r8,#1
beq encryptC
bne decryptC

encryptS:
@initial counters
mov r10,#0
mov r11,#0
mov r9,#25

encryptSloop:
@load input and alphabet
ldr r1,=inputString
ldr r2,=alphabet
@load byte from input and alphabet, then compare
ldrb r4,[r1,r11]
ldrb r5,[r2,r10]
cmp r4,r5
@if the same, continue (we have the index)
beq encryptSIncrement
@otherwise, increment the counter and loop again
add r10,#1
b encryptSloop

encryptSIncrement:
@load the substitution string
ldr r3,=substitutions
@get the character at the correct index and output it
ldrb r0,[r3,r10]
bl putchar

@reset counter
mov r10,#0
@decrement counter
sub r9,#1
@increment counter
add r11,#1
@if r9 counter is 0, end. Otherwise, loop again.
cmp r9,#0
bne encryptSloop
b end

@Decryption substitution is the same as encryption besides the substitution string being search instead of the alphabet with the input
decryptS:
mov r10,#0
mov r11,#0
mov r9,#25

decryptSloop:
@substitutions is switched with alphabet
ldr r1,=inputString
ldr r2,=substitutions
ldrb r4,[r1,r11]
ldrb r5,[r2,r10]
cmp r4,r5
beq decryptSIncrement
add r10,#1
b decryptSloop

decryptSIncrement:
ldr r3,=alphabet
ldrb r0,[r3,r10]
bl putchar

mov r10,#0
sub r9,#1
add r11,#1
cmp r9,#0
bne decryptSloop
b end

encryptC:
@initial counters
mov r10,#0
mov r11,#0
mov r9,#25

encryptCloop:
@load input string and alphabet, then compare the current byte
ldr r1,=inputString
ldr r2,=alphabet
ldrb r4,[r1,r11]
ldrb r5,[r2,r10]
cmp r4,r5
@if the same, continue. Otherwise, increment r10 and, if the alphabet is looped through but no match is found, set it to -1 to ensure no extra characters are printed out.
beq encryptCIncrement
add r10,#1
cmp r10,#27
beq changeCEValue
b encryptCloop

changeCEValue:
mov r10,#-1
b encryptCIncrement

CEOverflow:
@subtract 27 from r10 until it's less than 27
sub r10,#27
cmp r10,#26
bgt CEOverflow
b skipCESeeding

encryptCIncrement:
cmp r10,#-1
beq skipCESeeding
@load the seed and add it to r10. If the result is greater than 26, we need to subtract 27 in CEOverflow
ldr r7,=seed
ldr r6,[r7]
add r10,r6
cmp r10,#26
bgt CEOverflow
skipCESeeding:
@output the encrypted character
ldr r0,[r2,r10]
bl putchar

@reset r10, increment r11, decrement r9
mov r10,#0
add r11,#1
sub r9,#1
@loop again if r9 has not reached 0
cmp r9,#0
bne encryptCloop
b end

@Decryption with the Caesar Cipher is the same as encryption besides the seed being subtracted instead of added and a new check for when the index is negative
decryptC:
@initial counters
mov r10,#0
mov r11,#0
mov r9,#25

decryptCloop:
ldr r1,=inputString
ldr r2,=alphabet
ldrb r4,[r1,r11]
ldrb r5,[r2,r10]
cmp r4,r5
beq decryptCIncrement
add r10,#1
cmp r10,#27
beq changeCDValue
b decryptCloop

changeCDValue:
mov r10,#-1
b decryptCIncrement

CDOverflow:
sub r10,#27
cmp r10,#26
bgt CDOverflow
b skipCDSeeding

CDUnderflow:
@add 27 to r10 until it's greater than -1
add r10,#27
cmp r10,#0
blt CDUnderflow
b skipCDSeeding

decryptCIncrement:
cmp r10,#-1
beq skipCDSeeding
@load the seed, subtract it from r10
ldr r7,=seed
ldr r6,[r7]
sub r10,r6
@If r10 is greater than 26, subtract 27 in CDOverflow
cmp r10,#26
bgt CDOverflow
@If r10 is less than 0, add 27 in CDUnderflow
cmp r10,#0
blt CDUnderflow
skipCDSeeding:
ldr r0,[r2,r10]
bl putchar

mov r10,#0
add r11,#1
sub r9,#1
cmp r9,#1
bne decryptCloop
b end

end:
@output newline and exit
ldr r6,=crlf
ldr r0,[r6]
bl putchar
pop {IP,PC}

.data
@format, prompts, and variables
scanFormat: .asciz "%[^\n]s\n"
scanNumber: .asciz "%d"
alphabet: .asciz "abcdefghijklmnopqrstuvwxyz "
substitutions: .asciz "ghfjdkslapqowieurytvbcnxmz "
seed: .word 0
type: .word 0
direction: .word 0
crlf: .asciz "\n"
inputPrompt: .asciz "Enter a string: "
typePrompt: .asciz "Which algorithm? Caesar (1) & Subsitution (2) "
directionPrompt: .asciz "Encrypt (1) or decrypt (2)? "
seedPrompt: .asciz "Enter the offset "

.bss
inputString: .asciz
