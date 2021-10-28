.section .game.text
	option1: .asciz "Press 1 to start a new game"
	option2: .asciz "Press 2 to see the tutorial"
	option3: .asciz "Press 3 to select the dificulty level"
	option4: .asciz "Press 4 to quit the game"
    tutorial: .asciz " _____     _             _       _ 
|_   _|   | |           (_)     | |
  | |_   _| |_ ___  _ __ _  __ _| |
  | | | | | __/ _ \\| '__| |/ _` | |
  | | |_| | || (_) | |  | | (_| | |
  \\_/\\__,_|\\__\\___/|_|  |_|\\__,_|_|\n\nYou have to press left right to control the space ship.
Good luck!\nEach ship that you destroy gives you points.Press W to shoot and have fun!"
    close_menu_prompt: .asciz "Press Q to return to the main menu!"
    difficulty_prompt: .asciz "Please select the dificulty level\n1. Easy\n2. Medium\n3. Hard"
    player_dead_message: .asciz "Press Q to return to the main menu\n _____                     _             _                        
|  ___|                   (_)           | |                       
| |__ _ __   ___ _ __ ___  _  ___  ___  | |__   __ ___   _____    
|  __| '_ \\ / _ \\ '_ ` _ \\| |/ _ \\/ __| | '_ \\ / _` \\ \\ / / _ \\   
| |__| | | |  __/ | | | | | |  __/\\__ \\ | | | | (_| |\\ V /  __/   
\\____/_| |_|\\___|_| |_| |_|_|\\___||___/ |_| |_|\\__,_| \\_/ \\___|   
                                                                  
                                                                  
 _                _                                   _           
| |              | |                                 | |          
| |__   ___  __ _| |_ ___ _ __    _   _  ___  _   _  | |__  _   _ 
| '_ \\ / _ \\/ _` | __/ _ \\ '_ \\  | | | |/ _ \\| | | | | '_ \\| | | |
| |_) |  __/ (_| | ||  __/ | | | | |_| | (_) | |_| | | |_) | |_| |
|_.__/ \\___|\\__,_|\\__\\___|_| |_|  \\__, |\\___/ \\__,_| |_.__/ \\__, |
                                   __/ |                     __/ |
                                  |___/                     |___/ 
          __           _                      __   _____          
         / _|         | |                    / _| / __  \\         
  __ _  | |_ __ _  ___| |_ ___  _ __    ___ | |_  `' / /'         
 / _` | |  _/ _` |/ __| __/ _ \\| '__|  / _ \\|  _|   / /           
| (_| | | || (_| | (__| || (_) | |    | (_) | |   ./ /___         
 \\__,_| |_| \\__,_|\\___|\\__\\___/|_|     \\___/|_|   \\_____/         
                                                                  
                                                                                                                                                                                          
"



.data
	current_option: .quad 5
	middle_x: .byte 25
	exiting_main_menu: .byte 0
    difficulty_level: .byte 1
	jumptable1:
		.quad handle_option1
		.quad handle_option2
		.quad handle_option3
		.quad handle_option4

.global main_menu_handle
.global is_game_started,player_dead_screen

is_game_started:
    cmpq $0, current_option
    jne game_is_not_started
    movq $1, %rax
    jmp is_game_started_return
game_is_not_started:
    movq $0, %rax
is_game_started_return:
    ret


player_dead_screen:

    movq    $10, %rdi 
    movq    $0, %rsi 
    movq    $player_dead_message, %rdx 
    movb    $0x0f, %cl 
    call    print_pattern


    call 	readKeyCode
    movb 	%al, %dil # Save the pressed key in DIL
    cmpb 	$0x10, %al # If Q is pressed

    jne     1f
    movq	$42, %rdi 
    call    log_numq
	movq 	$5, current_option

	movb 	$0, exiting_main_menu
	call    gameInit


    1:

    ret


handle_option1:
    # TODO: the game doesn't start if other options were used before
    # Game loop is going to detect this option and run the game
    # So nothing to print here
	ret 

handle_option2:
	# printing the tutorial
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq    $0, %rdi 
	movq    $0, %rsi 
	movq    $close_menu_prompt, %rdx
	movq    $0x0f, %rcx
	call    print_pattern

	movq    $0, %rdi
	movq    $2, %rsi
	movq    $tutorial, %rdx
	movq    $0x0f, %rcx
	call    print_pattern

	movq    %rbp, %rsp
	popq    %rbp
	ret

handle_option3:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdi # Save the scan code of pressed key from main_menu_handle call

	movq    $0, %rdi
	movq    $0, %rsi
	movq    $close_menu_prompt, %rdx
	movq    $0x0f, %rcx
	call    print_pattern

	movq    middle_x, %rdi
	movq    $2, %rsi
	movq    $difficulty_prompt, %rdx
	movq    $0x0f, %rcx
    call print_pattern

    # DIL already contains the key press from the main_menu_handle call
    popq %rdi
	movq $1, %rsi
	cmpb $0x02, %dil # compare if 1 is pressed
	je change_difficulty

	incq %rsi
    cmpb $0x03, %dil # compare if 2 is pressed
	je change_difficulty

	incq %rsi
	cmpb $0x04, %dil # compare if 3 is pressed
	je change_difficulty
    jmp difficulty_return

change_difficulty:
    movb 	%sil, difficulty_level

	movb	difficulty_level, %dil 
	call    log_numb

    movb    $0, exiting_main_menu

difficulty_return:
    movq %rbp, %rsp
    popq %rbp
	ret 

handle_option4:
    call    shutdown
    ret 

main_menu_handle:
	pushq   %rbp 
	movq 	%rsp, %rbp

	call 	display_difficulty

    call readKeyCode
    movb %al, %dil # Save the pressed key in DIL
    cmpb $0x10, %al # If Q is pressed

    je no_submenu_called # Then print the main menu again

	cmpb $0, exiting_main_menu
	jne print_sub_option
    movb $0xFF, %dil # No key hit signal to suboptions if we use up this key

	movq $0, %rsi
	cmpb $0x02, %al # compare if 1 is pressed 
	je change_menu

	incq %rsi
    cmpb $0x03, %al # compare if 2 is pressed
	je change_menu

	incq %rsi
	cmpb $0x04, %al # compare if 3 is pressed  
	je change_menu

	incq %rsi
	cmpb $0x05, %al # compare if 4 is pressed 
	je change_menu

    
no_submenu_called:
    movb $0, exiting_main_menu
	call print_menu_options
	jmp  end_switch


change_menu:
    movb $1, exiting_main_menu
    movq %rsi, current_option
print_sub_option:
    movq current_option, %rsi
    movq $0, %rax

    call *jumptable1(%rax, %rsi, 8)

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
	movq $0x04, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $12, %rsi 
	movq $option2, %rdx
	movq $0x04, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $14, %rsi 
	movq $option3, %rdx
	movq $0x04, %rcx
	call print_pattern

	cmpq $1, %rax 
	je error_menu 

	movq middle_x, %rdi 
	movq $16, %rsi 
	movq $option4, %rdx
	movq $0x04, %rcx
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
