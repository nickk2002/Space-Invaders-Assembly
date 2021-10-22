.file "src/game/player.s"

.global player_init, print_player_position

.section .game.text
	player_appearance: .asciz "/-^-\\"

.data
	player_size: .byte 1
	player_position_x: .byte 40
	player_position_y: .byte 24
	bullet_position_x: .byte 40
	bullet_position_y: .byte 23
	start_anim: .byte 0
	game_frame_x: .byte 80
	game_frame_y: .byte 25

# jumptable containing the addresses of the subroutines selected by the switch
	jumptable:
	    .quad player_move_left
	    .quad player_move_right
	    .quad player_shoot

player_init:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp
	
	movb 	$0, start_anim
	movq 	$player_appearance, %rdi
	call 	character_count
	movb 	%al, player_size


	# epilogue		
	movq    %rbp, %rsp
	popq 	%rbp

	ret

player_input:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp
	
	call	readKeyCode

	movq	$0, %rsi
    movq $0x1E, %rdi
    call isKeyDown
	cmpb 	$1, %al 		# A was pressed
	je 		switch

	incq	%rsi
    movq $0x20, %rdi
    call isKeyDown
	cmpb 	$1, %al 		# D was pressed
	je 		switch

	incq	%rsi
    movq $0x11, %rdi
    call isKeyUp
	cmpb 	$1, %al 		# W was pressed
	je 		switch

	epilogue_player_input:
		cmpb 	$0, start_anim
		jne  	dont_update_bullet_position
		movb 	player_position_x, %al 
		movb 	%al, bullet_position_x

		dont_update_bullet_position:
		call 	do_animation
		# epilogue		
		movq    %rbp, %rsp
		popq 	%rbp

		ret

    # switch case
    switch:
	    shlq 	$3, %rsi               # multiply %rax by 8
	    movq 	jumptable(%rsi), %rsi  # copy the address of the subroutine selected by switch to %rax
	    call 	*%rsi                  # call the subroutine stored at the address which is in %rax
	    jmp 	epilogue_player_input  # jump back to the body of the loop to finish the iteration


player_move_left:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

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
	movb $1, start_anim
    movq $2000, %rdi
    call playFrequency
    call unmuteSpeaker
    movq $500, %rdi
    call playFrequency
	
	# we call the animation either way because the animation checks the start_anim value
	// call do_animation

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
	movb    $24, bullet_position_y  # intialize y to the bottom of the screen again
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
