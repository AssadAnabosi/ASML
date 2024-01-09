dosseg
.model small
.data
numbers db 2 dup(0)
op db ' '
welcome_msg db 10, 13, 'Enter your first number followed by a space before and after the operator', 10, 13, 'and lastly the second number, then press enter to calculate.', 10, 13, 'E.G: 5 + 5', 10, 13, '$'
invalid_input_msg db 10, 13, 'Invalid input', 10, 13, '$'
out_of_range_msg db 10, 13, 'Out of range', 10, 13, '$'
remainder_msg db 10, 13, 'Remainder: ', 10, 13, '$'
remainder db 0
.code
main:
mov ax, @data
mov ds, ax

mov dx, offset welcome_msg
mov ah, 9h
int 21h

mov si, offset numbers
read_input:
mov ah, 1h
int 21h
cmp al, 20h
je space_detected
cmp al, 13
je calculate
cmp al, '0'
jb invalid_input1
cmp al, '9'
ja invalid_input1
; storing multi digit numbers
mov ah, 0
sub al, '0'
mov bl, al
mov al, 10
mov dl, [si]
mul dl
cmp ah, 0
ja out_of_range1
add al, bl
jc out_of_range1
mov [si], al
jmp read_input

space_detected:
cmp op, ' '
je store_operator
inc si
jmp read_input
store_operator:
mov ah, 1h
int 21h
mov op, al
jmp read_input

invalid_input1:
jmp invalid_input

out_of_range1:
jmp out_of_range

calculate:
cmp op, '+'
je add_numbers
cmp op, '-'
je subtract_numbers
cmp op, '*'
je multiply_numbers
cmp op, '/'
je divide_numbers
jmp invalid_input

add_numbers:
mov dl, [si]
dec si
add dl, [si]
jc out_of_range1
jmp print

subtract_numbers:
mov dl, [si]
dec si
sub [si], dl
mov dl, [si]
jae print
neg dl
mov cl, dl
mov dl, '-'
mov ah, 2h
int 21h
mov dl, cl
jmp print

multiply_numbers:
mov ah, 0
mov al, [si]
dec si
mov cl, [si]
mul cl
cmp ah, 0
ja out_of_range1
mov dl, al
jmp print

divide_numbers:
mov ah, 0
mov cl, [si]
dec si
mov al, [si]
cmp cl, 0
je invalid_input
div cl
mov dl, al
mov remainder, ah
jmp print

print:
; the result is already in dl
mov dh, 0 ; reset dh
mov cx, 0 ; counter for number of digits
mov bx, 10 ; divisor
mov ax, dx ; quotient
divide:
mov dx, 0 ; reset dx
div bx ; divide ax by bx
push dx ; push remainder to stack
inc cx ; increment counter
cmp ax, 0 ; check if quotient is 0
jne divide ; if not, continue dividing
print_loop:
pop dx ; pop remainder from stack
add dl, '0' ; convert to ascii
mov ah, 2h ; print character
int 21h
loop print_loop ; loop until cx = 0
cmp remainder, 0 ; check if there is a remainder
je exit_app ; if not, exit
mov cl, remainder ; print remainder
mov remainder, 0 ; reset remainder
mov dx, offset remainder_msg
mov ah, 9h
int 21h
mov dl, cl
jmp print
jmp exit_app

; invalid input message
invalid_input:
mov dx, offset invalid_input_msg
mov ah, 9h
int 21h
jmp exit_app

; out of range message
out_of_range:
mov dx, offset out_of_range_msg
mov ah, 9h
int 21h
jmp exit_app

exit_app:
mov ah, 4ch
int 21h
end main
