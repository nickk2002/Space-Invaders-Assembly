.section .game.text
	option1: .asciz "Press 1 to start a new game"
	option2: .asciz "Press 2 to see the tutorial"
	option3: .asciz "Press 3 to select the dificulty level"
	option4: .asciz "Press 4 to quit the game"
	tutorial: .asciz "You have to press left right to control the space ship and that's it!. Good luck!"                                

	dummy_option1: .asciz "in Option 1"

.data
	current_option: .quad 0
	middle_x: .byte 30
	exiting_main_menu: .byte -1
	jumptable1:
		.quad handle_option1
		.quad handle_option2
		.quad handle_option3
		.quad handle_option4

.global main_menu_handle


handle_option1:
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq    $10, %rdi 
	movq    $0, %rsi 
	movq    $tutorial, %rdx
	movq  	$0x0f, %rcx
	call 	print_pattern

	movq    %rbp, %rsp
	popq    %rbp 
	ret 

handle_option2:
	# printing the tutorial
	pushq   %rbp 
	movq 	%rsp, %rbp

	call clear_screen

	movq    $0, %rdi 
	movq    $0, %rsi 
	movq    $tutorial, %rdx 
	movq    $0x0f, %rcx 
	call    print_pattern

	movq    %rbp, %rsp
	popq    %rbp 
	ret 
handle_option3:
	ret 
handle_option4:
	ret 

main_menu_handle:
	pushq   %rbp 
	movq 	%rsp, %rbp


	cmpb $-1, exiting_main_menu
	jne switch1

	call readKeyCode 
	movq $0, current_option 
	cmpb $0x02, %al # compare if 1 is pressed 
	je switch1

	incq current_option 
	cmpb $0x03, %al # compare if 2 is pressed 
	je switch1

	incq current_option 
	cmpb $0x04, %al # compare if 3 is pressed  
	je switch1

	incq current_option 
	cmpb $0x05, %al # compare if 4 is pressed 
	je switch1

	call print_menu_options
	jmp  end_switch

	switch1:
		movb $1, exiting_main_menu
		shlq $3, current_option  # rdi * 8
		movq current_option, %rax
		movq jumptable1(%rax), %rax 
		shrq $3, current_option
		call *%rax  

	end_switch:

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
print_menu_options:
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq middle_x, %rdi 
	movq $10, %rsi 
	movq $option1, %rdx
	movq $0x01, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $12, %rsi 
	movq $option2, %rdx
	movq $0x01, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $14, %rsi 
	movq $option3, %rdx
	movq $0x01, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $16, %rsi 
	movq $option4, %rdx
	movq $0x01, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	jmp end_menu
error_menu:
	movq $40, %rdi 
	movq $14, %rsi 
	movq $'X', %rdx
	movq $0x02, %rcx
	call putChar


end_menu:

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret