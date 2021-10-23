.file "src/game/timer.s"

.section .game.data

	constant_value: .quad 1193182
	max_reload_value: .quad 0xFFFF

	current_timer:   .quad 0

	main_loop_fps:   .quad 120

	game_loop_fps: 	.quad 30 

	timer_attributes: .byte 16
	timer_array: .skip 1024
	timer_pointer:  .quad 0# current pointer in the array
	timer_count: .byte 0 # number of timers

	first_timer: .byte 0


.section .game.text

.global do_timer,handle_timer, timer_init


# creates a timer with the following arguments and adds it 
# to the list of timers
# rdi -> timer_fps
# rsi -> function to call
# we store -> division + rsi
# returns into %rax the pointer to the new timer created
add_timer:
	
	movq 	timer_pointer, %rcx # pointer to the array

	movq	$0, %rdx 
	movq	main_loop_fps, %rax 
	divq	%rdi # divide main_loop / rdi(timer in the argument) 

	# the division result is stored into %rax
	movq	%rax, (%rcx) 

	movq	%rsi, 8(%rcx) # we store function

	movq	%rcx, %rax # store into rax the pointer to the new timer
	incq	timer_count # increase the number of timers

	movq	$0, %rdi
	movb	timer_attributes, %dil 
	addq	%rdi, timer_pointer # increase the pointer by the 
	# atribute count

	ret 


# rdi-> index of the position
# rax -> gets the pointer to the value in the array
get_timer_at_pos:
	# timer_array + timer_attributes * rdi
	xorq	%rax,%rax
	movb	timer_attributes, %al 
	mulb	%dil 
	addq	timer_array, %rax
	ret 



timer_init:
	# timer_pointer point to the array
	movq	timer_array,%rax 
	movq	%rax,timer_pointer # timer_pointer = timer_array
	

	# reload value < 2 ^ 16 - 1
	#1193182 / reloadValue = main_loop_fps
	#1193182 / main_loop_fps = reload_value
	# set main counter according to main_loop_fps
	movq	$0,%rdx
	movq 	constant_value, %rax 
	divq	game_loop_fps
	movq	%rax, %rdi 
	call    setTimer # set the timer according to the main_loop_fps 


	movq	game_loop_fps, %rdi 
	movq	gameLoop, %rsi  
	call    add_timer

	# game division = main_loop/game_loop
	ret 


handle_timer:
	pushq	%rbp 
	movq	%rsp, %rbp
	
	cmpb 	$0,first_timer
	jne		more_times  
	# we are first timer = 0
	movb 	$1, first_timer
	call 	timer_init

	more_times:

	incq	current_timer

	movq	current_timer, %rax 
	cmpq 	%rax,main_loop_fps # check if we have reached the main loop fps
	jne 	dont_reset_timer  
	# we reset the timer the timder since current_timer is main_loop_fps
	movq    $0, current_timer
	dont_reset_timer:	


	movq 	$0,%rdi # arrays starts from 0

	# loop normally
	loop_timers:
		cmpb	 %dil, timer_count
		jle      end_loop_timers
	// call 	gameLoop

		// // # we have the pointer to the array
		call    get_timer_at_pos

		movq	timer_array,%rcx  # store address into rcx
		
		movq	current_timer,%rax 
		movq	$0, %rdx
		divq	(%rcx)  # timer division we have
		cmpq	$0, %rdx # compare the modulo
		call    gameLoop

		pushq	%rdi 
		movq	$10, %rdi 
		movq	$10, %rsi 
		movb	(%rcx), %dl 
		addb	$0x30,	%dl
		movq	$0x0f,  %rcx
		call 	putChar

		jne		continue_loop_timers

		popq	%rdi 
		# we call the function
		// call    *8(%rcx)

		continue_loop_timers:
		incq	%rdi
		jmp  	loop_timers
	end_loop_timers:



	end_timer:

	leave
	ret







