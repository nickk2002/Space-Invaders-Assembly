.file "src/game/player.s"

.global player_init, player_movement

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

	movq	$0, %rdi
	cmpb 	$0x1E, %al 		# A was pressed
	je 		switch

	incq	%rdi
	cmpb 	$0x20, %al 		# D was pressed
	je 		switch

	incq	%rdi
	cmpb 	$0x11, %al 		# W was pressed
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
	    shlq 	$3, %rdi               # multiply %rax by 8
	    movq 	jumptable(%rdi), %rdi  # copy the address of the subroutine selected by switch to %rax
	    call 	*%rdi                  # call the subroutine stored at the address which is in %rax
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

	# print character 'A' at coords (x,y)
	movb 	bullet_position_x, 	%dil 
	addb 	$2, %dil 					# hard coded cannon position
	movb	bullet_position_y,	%sil
	movb 	$'A', %dl
	movb    $0x0f, %cl
	call    putChar

	# decrease y because we are going up 
	decb    bullet_position_y
	cmpb	$0, bullet_position_y
	jne     epilogue # if y is not 0 we still have an animation going

	# reached end of the animation
	movb    $24, bullet_position_y  # intialize y to the bottom of the screen again
	movb	$0, start_anim

epilogue:		
	movq    %rbp, %rsp
	popq 	%rbp

	ret
