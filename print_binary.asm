global _start

section .text

;; (character) -> void
putc: ; Print the character on the stack
	lea rsi, [rsp + 8] ; pointer to string
	mov rdx, 1 ; msg length

	mov rax, 1 ; sys_write()
	mov rdi, 1 ; file descriptor
	syscall

	ret

;; (pointer, length) -> void
puts:
	mov rsi, [rsp + 8] ; pointer to string
	mov rdx, [rsp + 16] ; length

	mov rax, 1 ; sys_write()
	mov rdi, 1 ; stdout
	syscall

	ret


;; (number) -> void
print_binary:

	; enter stack frame
	push rbp
	mov rbp, rsp

	sub rsp, 9 ; reserve space on stack

	; [rsp] -> isLeadingFlag (don't print leading zeroes)
	; [rsp+1] -> bufferNumber
	mov BYTE [rsp], 0
	
	; Copy number argument to buffer variable
	mov rax, QWORD [rbp + 16]
	mov QWORD [rsp + 1], rax


	; Print "0b"
	sub rsp, 1
	mov BYTE [rsp], '0'
	call putc
	mov BYTE [rsp], 'b'
	call putc

	add rsp, 1 ; clean up used byte

	mov rcx, 64
	.loop:
		
		mov rax, QWORD [rsp + 1] ; get argument into rax

		rol rax, 1 ; move left most bit to the right
		and rax, 1 ; isolate it

		cmp rax, 0
		je .isLeadingComp ; if it's a zero, check if we had a one before

		; if it's a one, set isLeading to one and go print it
		mov BYTE [rsp], 1
		jmp .printNum
		

		.isLeadingComp:
		cmp BYTE [rsp], 0
		je .isLeading
		

		.printNum:
			add rax, 0x30 ; add offset to ASCII '0'

			push rcx ; save rcx value

			; print it
			push rax
			call putc
			add rsp, 8 ; clean up

			pop rcx

		.isLeading:

		shl QWORD [rsp + 1], 1 ; move temp value to the left

		dec rcx
		cmp rcx, 0
		jnz .loop
	
	add rsp, 9 ; clean up stack

	; leave stack frame
	mov rsp, rbp
	pop rbp

	ret

;; (number) -> void
print_hex:

	; enter stack frame
	push rbp
	mov rbp, rsp

	sub rsp, 9 ; reserve space on stack

	; [rsp] -> isLeadingFlag (don't print leading zeroes)
	; [rsp+1] -> bufferNumber
	mov BYTE [rsp], 0
	
	; Copy number argument to buffer variable
	mov rax, QWORD [rbp + 16]
	mov QWORD [rsp + 1], rax


	; Print "0b"
	sub rsp, 1
	mov BYTE [rsp], '0'
	call putc
	mov BYTE [rsp], 'x'
	call putc

	add rsp, 1 ; clean up used byte

	mov rcx, 16 ; iterate 16 times over 4 bits -> 64 bits
	.loop:
		
		mov rax, QWORD [rsp + 1] ; get argument into rax

		rol rax, 4 ; move the four left most bits to the right
		and rax, 0xF ; isolate them

		cmp rax, 0
		je .isLeadingComp ; if it's a zero, check if we had a one before

		; if it's a one, set isLeading to one and go print it
		mov BYTE [rsp], 1
		jmp .printNum
		

		.isLeadingComp:
		cmp BYTE [rsp], 0
		je .isLeading
		

		.printNum:
			; if rax is between 0 and 9, ASCII ranges from 0x30 to 0x39
			; if rax is between 10 and 15, ASCII ranges from 0x41 to 0x46

			add rax, 0x30 ; add offset to ASCII '0'

			cmp rax, 0x39 
			jle .endIfIsHex

			; if more the 0x30 + 9 (eg: in the A..F range)
			add rax, 0x7

			.endIfIsHex:

			push rcx ; save rcx value

			; print it
			push rax
			call putc
			add rsp, 8 ; clean up

			pop rcx

		.isLeading:

		shl QWORD [rsp + 1], 4 ; move temp value to the left

		dec rcx
		cmp rcx, 0
		jnz .loop
	
	add rsp, 9 ; clean up stack

	; leave stack frame
	mov rsp, rbp
	pop rbp

	ret

;; (number) -> void
print_dec:
	
	push rbp
	mov rbp, rsp

	; [rsp] -> number
	; [rsp + 8] -> loop_index
	sub rsp, 16

	%define s_number QWORD [rsp]
	%define s_loop_index QWORD [rsp + 8]
	
	mov rax, QWORD [rbp + 16] ; Extract argument to 
	mov number, rax ; Move it into stack variable

	.loop:
		

		cmp rax, 0
		jnz .loop
		

	mov rsp, rbp
	pop rbp

	ret
	%undef s_loop_index
	%undef s_number

_start:
	
	push 0x453FA2
	call print_hex

	mov rax, 60
	xor rdi, rdi
	syscall
