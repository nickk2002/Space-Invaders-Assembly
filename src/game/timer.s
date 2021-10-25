.file "src/game/timer.s"

.section .game.data

	constant_value: .quad 1193182
	max_reload_value: .quad 0xFFFF # max reload value of the fast_loop

	current_timer:   .quad 0 # keeps track of the current timer of the main_loop
							 # can be in the range [0, main_loop_fps - 1]
	main_loop_fps:   .quad 120 # how fast does the main loop go

	game_loop_fps: 	.quad 30 # how fast does the game_loop go


	timer_attributes_byte: .byte 16 # byte -> size of the timer struct
	timer_array: .skip 1024    # array of timers
	timer_pointer:  .quad 0    # quad -> current pointer in the timer struct
	timer_count_byte: .byte 0 	   # byte storing number of timers 

	first_timer_byte: .byte 0       # byte(0|1) used to call timer_init


.section .game.text

.global timer_init


# creates a timer with the following arguments and adds it 
# to the list of timers
# rdi -> timer_fps
# rsi -> function to call
# stores a Timer(int64 precalculated_division, int*64 function_call)
# returns into %rax the pointer to the new timer created
add_timer:
	
	movq 	timer_pointer, %rcx # rcx holds the current pointer to the array

	movq	$0, %rdx 
	movq	main_loop_fps, %rax 
	divq	%rdi # divide main_loop / rdi(timer in the argument) 

	# the division result is stored into %rax
	# store this result in the first 8 bytes of the Timer struct
    movq 	%rax, (%rcx) 

    # store the function in the next 8 bytes of the Timer struct
	movq	%rsi, 8(%rcx) # store function pointer

	# store into rax the pointer to the new free position in the array
	movq	%rcx, %rax 
	
	incq	timer_count_byte # increase the number of timers

	# increase the timer_pointer with the size of the attributes
	movq	$0, %rdi
	movb	timer_attributes_byte, %dil 
	addq	%rdi, timer_pointer 

	ret 


# rdi-> index of the position
# rax -> gets the pointer to the value in the array
get_timer_at_pos:
	# timer_array + timer_attributes_byte * rdi
	xorq	%rax,%rax
	movb	timer_attributes_byte, %al 
	mulb	%dil 
	addq	$timer_array, %rax
	ret 

timer_init:
	# intialize the timer_pointer to point to the timer_array
	movq	$timer_array,%rax 
	movq	%rax,timer_pointer # timer_pointer = timer_array
	

	# reload value < 2 ^ 16 - 1
	#1193182 / reloadValue = main_loop_fps
	#1193182 / main_loop_fps = reload_value
	# set main counter according to main_loop_fps
	movq	$0,%rdx
	movq 	constant_value, %rax 
	divq	main_loop_fps
	movq	%rax, %rdi 
	call    setTimer # set the timer according to the main_loop_fps 

	# add the Timer for the gameLoop
	# $gameLoop -> address of the gameLoop label

	movq	game_loop_fps, %rdi 
	movq	$gameLoop, %rsi  
	call    add_timer

	// movq	$30, %rdi 
	// movq	$player_loop, %rsi  
	// call    add_timer


	ret 



handle_timer:
	pushq	%rbp 
	movq	%rsp, %rbp
	


	# check if the we entering the function for the first time
	cmpb 	$0,first_timer_byte
	jne		more_times  
	# we are entering the function for the first time
	movb 	$1, first_timer_byte
	call    timer_init
	
	more_times:


	incq	current_timer # increase the current timer

	movq	current_timer, %rax 
	cmpq 	%rax, main_loop_fps # check if we have reached the main loop fps
	jne 	dont_reset_timer  

	# we reset the timer the timer since current_timer = main_loop_fps
	movq    $0, current_timer

	dont_reset_timer:	

	movq 	$0,%rdi # arrays starts from 0
	movq	$timer_array, %rcx

	loop_timers:
		# save rdi and rcx because the call might change them
		pushq 	%rdi
		pushq	%rcx

		cmpb	%dil, timer_count_byte
		jle     end_loop_timers # if timer_count_byte <= dil we are out of bounds

	
		movq	current_timer,%rax 
		movq	$0, %rdx
		divq	(%rcx)  # timer division we have
		cmpq	$0, %rdx # compare the modulo

		jne		continue_loop_timers

		# we call the function
        call    *8(%rcx)
        # take rcx and rdi back from the stack
        popq	%rcx
		popq	%rdi 

		continue_loop_timers:
		addb    timer_attributes_byte, %cl
		incq	%rdi
		jmp  	loop_timers
	end_loop_timers:



	end_timer:

	leave
	ret







