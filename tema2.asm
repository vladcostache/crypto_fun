extern puts
extern printf
extern strlen

%define BAD_ARG_EXIT_CODE -1

section .data
filename: db "./input0.dat", 0
inputlen: dd 2263

fmtstr:            db "Key: %d",0xa, 0
usage:             db "Usage: %s <task-no> (task-no can be 1,2,3,4,5,6)", 10, 0
error_no_file:     db "Error: No input file %s", 10, 0
error_cannot_read: db "Error: Cannot read input file %s", 10, 0

section .text
global main

xor_strings:
        enter 0,0
        xor eax, eax
        xor ebx, ebx
        mov eax, [ebp+8]                ; move string address to eax
        mov ebx, [ebp+12]               ; move key address to ebx
        xor ecx, ecx                    ; counter
        xor edx, edx                
repet1:
        mov dl, byte[eax + ecx]         ; first byte in string
        mov dh, byte[ebx + ecx]         ; first byte in key
        cmp dl, 0                       ; verify stop condition
        je stop1
        xor dl, dh
        mov byte[eax + ecx], dl         ; update eax
        inc ecx
        jmp repet1
stop1:
        leave
        ret

rolling_xor:
        enter 0,0
        xor eax, eax
        xor ecx, ecx
        xor edx, edx
        xor ebx, ebx
        mov eax, [ebp+8]                ; move string address to eax
        mov bl, byte[eax]               ; move first byte to start recursion
repet2:       
        mov dl, bl                      ; current penultimate byte
        mov dh, byte[eax + ecx + 1]     ; current last byte
        cmp dh, 0                       ; verify stop condition
        je stop2
        mov bl, dh                      ; save last byte
        xor dh, dl                      
        mov byte[eax + ecx + 1], dh     ; update eax
        inc ecx
        jmp repet2
stop2:
        leave
        ret

convert_to_binary:      
        enter 0,0
        xor edx, edx
        xor esi, esi
        xor ecx, ecx
        xor eax, eax
        
        mov edx,[ebp + 8]               ; move Hex string address to edx 
        
convert_loop:
        mov al, byte[edx + ecx]         ; current byte in Hex string
        cmp al, 0                       ; verify stop condition
        je done

digit1:                                 ; digit: 0(0x30)-9(0x39)
        cmp al, 0x40                    ; verify if letter
        jg letter1
        sub al, 0x30                    ; convert
        jmp byte_conv_done1
letter1:
        sub al, 0x57                    ; convert

byte_conv_done1:
        shl eax, 4                      ; multiply by 16
        mov ebx, eax                    ; add current 4 bits converted
        mov al, byte[edx + ecx + 1]     ; next byte in Hex string
digit2:
        cmp al, 0x40
        jg letter2
        sub al, 0x30
        jmp byte_conv_done2
letter2:
        sub al, 0x57
        
byte_conv_done2:        
        add ebx, eax                    ; add next 4 bits converted
        mov byte[edx + esi], bl         ; update current byte in string 
        inc ecx
        inc ecx
        inc esi 
        jmp convert_loop
              
done:
        mov byte[edx + esi], 0          ; zero padding
        inc esi
        cmp ecx, esi
        jne done
        leave
        ret
        

xor_hex_strings:
	; TODO TASK 3

        enter 0,0
        xor eax, eax
        xor ebx, ebx
        
        mov eax, [ebp + 8]
        push eax
        call convert_to_binary
        
        
        mov ebx, [ebp + 12]
        push ebx
        call convert_to_binary
        pop ebx
        pop eax
        
        push ebx
        push eax
        call xor_strings
        
        leave 
        ret

base32decode:
	; TODO TASK 4
        ret

bruteforce_singlebyte_xor:
        enter 0,0
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx
        xor esi, esi
        mov ebx, [ebp + 8]              ; move encrypted string to ebx
        
find:
        inc ecx                         ; increment counter
        mov dl, byte[ebx + ecx]             
        cmp dl, 0                       ; verify stop condition
        je done_not_found                   
        xor dl, al                      ; xor bytes
        cmp dl, 'f'                     ; check sequence "force"
        jne find
        mov dl, byte[ebx + ecx + 1]
        cmp dl, 0
        je done_not_found
        xor dl, al
        cmp dl, 'o'
        jne find
        mov dl, byte[ebx + ecx + 2]
        cmp dl, 0
        je done_not_found
        xor dl, al
        cmp dl, 'r'
        jne find
        mov dl, byte[ebx + ecx + 3]
        cmp dl, 0
        je done_not_found
        xor dl, al
        cmp dl, 'c'
        jne find
        mov dl, byte[ebx + ecx + 4]
        cmp dl, 0
        je done_not_found
        xor dl, al
        cmp dl, 'e'
        jne find
        jmp found
        
        
done_not_found:
        inc al                          ; increment key
        xor ecx, ecx                    ; reset counter
        jmp find                        ; repeat find

found: 
        mov dh, byte[ebx + esi]         ; singlebyte xor
        cmp dh, 0
        je done_string
        xor dh, al
        mov byte[ebx + esi], dh
        inc esi
        jmp found
          
done_string:              
        leave
	ret

decode_vigenere:
	; TODO TASK 6
        enter 0,0
        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx
        xor esi, esi
        mov eax, [ebp + 8]              ; input string   
        mov ebx, [ebp + 12]             ; key string
        jmp each_byte

each_byte_inc:
        inc ecx
        
each_byte:
        mov dl, byte[eax + ecx]
        mov dh, byte[ebx + esi]
        cmp dl, 0
        je done_decode                  ; stop condition
        
        cmp dl, 0x61                    ; verify if letter
        jl each_byte_inc                ; if not, jump over
        cmp dl, 0x7A
        jg each_byte_inc
        
        cmp dh, 0                       ; if we reached the end of key
        je reset                        
        jmp ok
reset:                                  ; reset counter for key
        xor esi, esi
        mov dh, byte[ebx + esi]
ok:                                     
        sub dh, 0x61                    ; x
        push ecx
        xor ecx, ecx
        mov cl, dl                      ; initial letter
        sub dl, dh
        cmp dl, 0x60
        jg in_range
        sub cl, 0x61  ;h              
        mov dl, 0x7A
        sub dl, dh
        add dl, cl
        inc dl
in_range:
        pop ecx        
        mov byte[eax + ecx], dl
        
        inc ecx
        inc esi
        jmp each_byte

        
        
done_decode:
        
        
        
        
        leave
        ret

main:
	push ebp
	mov ebp, esp
	sub esp, 2300

	; test argc
	mov eax, [ebp + 8]
	cmp eax, 2
	jne exit_bad_arg

	; get task no
	mov ebx, [ebp + 12]
	mov eax, [ebx + 4]
	xor ebx, ebx
	mov bl, [eax]
	sub ebx, '0'
	push ebx

	; verify if task no is in range
	cmp ebx, 1
	jb exit_bad_arg
	cmp ebx, 6
	ja exit_bad_arg

	; create the filename
	lea ecx, [filename + 7]
	add bl, '0'
	mov byte [ecx], bl

	; fd = open("./input{i}.dat", O_RDONLY):
	mov eax, 5
	mov ebx, filename
	xor ecx, ecx
	xor edx, edx
	int 0x80
	cmp eax, 0
	jl exit_no_input

	; read(fd, ebp - 2300, inputlen):
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80
	cmp eax, 0
	jl exit_cannot_read

	; close(fd):
	mov eax, 6
	int 0x80

	; all input{i}.dat contents are now in ecx (address on stack)
	pop eax
	cmp eax, 1
	je task1
	cmp eax, 2
	je task2
	cmp eax, 3
	je task3
	cmp eax, 4
	je task4
	cmp eax, 5
	je task5
	cmp eax, 6
	je task6
	jmp task_done

task1:
	; TASK 1: Simple XOR between two byte streams
        push ecx
        xor eax, eax
        call strlen
        pop ecx
        
        add eax, ecx
        inc eax
        
        push eax
        push ecx                    ; ecx = address of input string 
        call xor_strings
        pop ecx
        add esp, 4
        
	; TODO TASK 1: find the address for the string and the key
	; TODO TASK 1: call the xor_strings function

	push ecx
	call puts                   ; print resulting string
	add esp, 4

	jmp task_done

task2:
	; TASK 2: Rolling XOR

	; TODO TASK 2: call the rolling_xor function

        push ecx
        call rolling_xor
        pop ecx

        push ecx
        call puts
        add esp, 4

        jmp task_done

task3:
	; TASK 3: XORing strings represented as hex strings

	; TODO TASK 1: find the addresses of both strings
	; TODO TASK 1: call the xor_hex_strings function
        push ecx
        xor eax, eax
        call strlen
        pop ecx
        
        add eax, ecx
        inc eax
        
        push eax
        push ecx                     ; ecx = address of input string 
        call xor_hex_strings
        pop ecx
        add esp, 4
	
        push ecx                     ; print resulting string
        call puts
        add esp, 4

        jmp task_done

task4:
	; TASK 4: decoding a base32-encoded string

	; TODO TASK 4: call the base32decode function
       

	push ecx
	call puts                    ; print resulting string
	pop ecx
	
	jmp task_done

task5:
	; TASK 5: Find the single-byte key used in a XOR encoding

	; TODO TASK 5: call the bruteforce_singlebyte_xor function
        xor eax, eax
        push ecx
        call bruteforce_singlebyte_xor
        pop ecx
        
        push eax
        push ecx                    ;print resulting string
        call puts
        pop ecx
        pop eax

	push eax                    ;eax = key value
	push fmtstr
	call printf                 ;print key value
	add esp, 8

	jmp task_done

task6:
	; TASK 6: decode Vignere cipher

	; TODO TASK 6: find the addresses for the input string and key
	; TODO TASK 6: call the decode_vigenere function

	push ecx
	call strlen
	pop ecx

	add eax, ecx
	inc eax
        
             
	push eax
	push ecx                   ;ecx = address of input string 
	call decode_vigenere
	pop ecx
	add esp, 4

	push ecx
	call puts
	add esp, 4

task_done:
	xor eax, eax
	jmp exit

exit_bad_arg:
	mov ebx, [ebp + 12]
	mov ecx , [ebx]
	push ecx
	push usage
	call printf
	add esp, 8
	jmp exit

exit_no_input:
	push filename
	push error_no_file
	call printf
	add esp, 8
	jmp exit

exit_cannot_read:
	push filename
	push error_cannot_read
	call printf
	add esp, 8
	jmp exit

exit:
	mov esp, ebp
	pop ebp
	ret
