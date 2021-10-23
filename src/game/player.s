.file "src/game/player.s"

.global player_init, print_player_position,player_loop

.section .game.text
	player_appearance: .asciz "/-^-\\"

.data
	player_size: .byte 1

	bullet_initial_y_pos: .byte 23 

	player_position_x: .byte 40
	player_position_y: .byte 24
	bullet_position_x: .byte 40
	bullet_position_y: .byte 23
	start_anim: .byte 0
	game_frame_x: .byte 80
	game_frame_y: .byte 25
	a_pressed: .byte 0 
	d_pressed: .byte 0

# jumptable containing the addresses of the subroutines selected by the switch
	jumptable:
	    .quad player_shoot
	    .quad player_move_left
	    .quad player_move_right

player_init:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp
	
	movb 	$0, start_anim
	movb    $0, a_pressed
	movq 	$player_appearance, %rdi
	call 	character_count
	movb 	%al, player_size


	# epilogue		
	movq    %rbp, %rsp
	popq 	%rbp

	ret


player_loop:
	
	call    player_move_left
	call    player_move_right
	call 	print_player_position
	call 	player_input
	call 	do_animation

	ret 
player_input:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp
	
	call	readKeyCode

    movq 	$0x11, %rdi
    call 	isKeyUp
	cmpb 	$1, %al 		# W was released
	jne     did_not_press_w
	call    player_shoot

	did_not_press_w:

	##### HANDLE A PRESS #####
    movq 	$0x1E, %rdi
    call 	isKeyDown
	cmpb 	$1, %al 		# A was pressed down
	
	jne     did_not_press_down_a
	movq	$1,a_pressed	# a was pressed

	did_not_press_down_a:
	movq 	$0x1E, %rdi
    call 	isKeyUp
	cmpb 	$1, %al 		# A was was released
	
	jne     did_not_release_a
	movq	$0,a_pressed	# a was released so 'a' is not pressed anymore

	did_not_release_a:

	##### HANDLE D PRESS #####
	movq 	$0x20, %rdi
    call 	isKeyDown
	cmpb 	$1, %al 		# D was pressed down
	
	jne     did_not_press_down_d
	movq	$1,d_pressed	# d was pressed

	did_not_press_down_d:
	movq 	$0x20, %rdi
    call 	isKeyUp
	cmpb 	$1, %al 		# D was was released
	
	jne     did_not_release_d
	movq	$0,d_pressed	# d was released so d is not pressed anymore

	did_not_release_d:



	epilogue_player_input:
		# update the bullet position
		cmpb	$1, start_anim
		je      dont_update_bullet_pos
		movb 	player_position_x, %al 
		movb 	%al, bullet_position_x
		dont_update_bullet_pos:


		# epilogue		
		movq    %rbp, %rsp
		popq 	%rbp

		ret

player_move_left:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	cmpb	$0,	a_pressed
	je      epilogue_move_left

	decb	player_position_x
	cmpb 	$0, player_position_x
    jge 	bullet_update_left
    movb 	$0, player_position_x

    bullet_update_left:
	cmpb	$1, start_anim
	je  	epilogue_move_left

	movb 	player_position_x, %al
	movb 	%al, bullet_position_x

	epilogue_move_left:
		# epilogue		
		movq    %rbp, %rsp
		popq 	%rbp
		ret

player_move_right:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	cmpb	$0,	d_pressed
	je      epilogue_move_right


	incb	player_position_x
	movb 	game_frame_x, %al
	sub 	player_size, %al
	incb  	%al
	cmpb 	%al, player_position_x
    jl 		bullet_update_right
    decb 	%al
    movb 	%al, player_position_x

    bullet_update_right:
	cmpb	$1, start_anim
	je  	epilogue_move_right

	movb 	player_position_x, %al
	movb 	%al, bullet_position_x

	epilogue_move_right:
		# epilogue		
		movq    %rbp, %rsp
		popq 	%rbp
		ret

print_player_position:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movb 	player_position_x, %dil
	movb	player_position_y, %sil
	movq 	$player_appearance, %rdx
	movb	$0x0f, %cl
	call 	print_pattern

	// movb 	player_position_x, %dil
	// movb	player_position_y, %sil
	// movb	$0x0f, %cl
	// movb	$'M', %dl
	// call	putChar

	# epilogue		
	movq    %rbp, %rsp
	popq 	%rbp
	ret

player_shoot:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# we did press Z
	# we mark start_anim true
	movb 	$1, start_anim
    movq 	$2000, %rdi
    call 	playFrequency
    call 	unmuteSpeaker
    movq 	$500, %rdi
    call 	playFrequency
	

	# epilogue		
	movq    %rbp, %rsp
	popq 	%rbp
	ret


# this function simulates the "shooting" when you press Z in mainLoop
do_animation:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# check if start_anim is 0
	cmpb    $0, start_anim
	je      epilogue # if it is 0 jump to epilogue

	# check if there is a collision
	call  	detectCollision

	# print character 'A' at coords (x,y)
	movb 	bullet_position_x, 	%dil 
	addb 	$2, %dil 					# hard coded cannon position
	movb	bullet_position_y,	%sil
	movb 	$'A', %dl
	movb    $0x0f, %cl
	call    putChar

	# decrease y because we are going up 
	decb    bullet_position_y
	cmpb	$-1, bullet_position_y
	jne     epilogue # if y is not -1 we still have an animation going

	# reached end of the animation
	movb    bullet_initial_y_pos, %al
	movb    %al, bullet_position_y  # intialize y to the bottom of the screen again
	movb	$0, start_anim

epilogue:		
	movq    %rbp, %rsp
	popq 	%rbp

	ret

# getter for information about player's ship position

# rax - index of the ship that was hit; if there was no ship hit returns -1
detectCollision:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r14
	pushq 	%r15

	movq 	number_of_ships, %r15
	collision_loop:
		cmpq 	$1, %rax
		je 		collision_epilogue

		cmpq 	$-1, %r15
		je 		collision_epilogue

		movq	%r15, %rdi
		call 	get_ship_at_position

		movq 	(%rax), %rcx
		movb 	%cl, %dl 		# x coordinate ship
		decb 	%dl
		decb 	%dl
		shr 	$8, %rcx
		movb 	%cl, %r8b 		# y coordinate ship
		shr 	$8, %rcx
		movb 	%cl, %r9b 		# width of the ship
		decb 	%r9b
		shr 	$8, %rcx
		movb 	%cl, %r14b 		# height of the ship
		decb 	%r14b

		cmpb 	bullet_position_x, %dl
		jg 		collision_no
		addb 	%dl, %r9b
		cmpb 	bullet_position_x, %r9b
		jl  	collision_no
		addb 	%r14b, %r8b
		cmpb	bullet_position_y, %r8b
		jl 		collision_no

		collision_yes:
			addb 	$5, (%rax)
			movq 	%r15, %rax
			jmp 	finish_collision_loop

		collision_no:
			movq 	$-1, %rax

		finish_collision_loop:
			decq 	%r15
			jmp 	collision_loop	

	collision_epilogue:
		popq 	%r15
		popq 	%r14

		# epilogue	
		movq    %rbp, %rsp
		popq 	%rbp

		ret
