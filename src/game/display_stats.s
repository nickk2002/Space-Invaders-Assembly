.file "src/game/display_stats.s"

.section .game.text
	display_y_coord: .byte 2
	hp_message: .asciz "HP: "
	score_message: .asciz "Score: "


.section .game.data


display_nr_lives:

	
	movq	$0, %rdi 
	movq	$0, %rsi 
	movq	$hp_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern


	movq	$4, %rdi 
	movq	$0, %rsi 
	movq	nr_lives, %rdx
	addq 	$0x30, %rdx
	movq	$0x0f,	%rcx 
	call    putChar

	ret 

display_score:
	movq	$6, %rdi 
	movq	$0, %rsi 
	movq	$score_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern


	movq	$13, %rdi 
	movq	$0, %rsi 
	movq	player_points, %rdx
	addq 	$0x30, %rdx
	movq	$0x0f,	%rcx 
	call    putChar

	ret 


display_information:
	
	call 	display_delimiter
	call    display_nr_lives
	call    display_score
	ret 

display_delimiter:
	
	pushq	%r15
	movq	$0, %r15
	print_delimiter_loop:
		cmpq	$80, %r15
		je  	end_printing

		movq	%r15, %rdi 
		movb	display_y_coord, %sil 
		movq 	$'_', %rdx 
		movb	$15, %cl

		call 	putChar
		incq	%r15 
		jmp     print_delimiter_loop
	end_printing:

	popq	%r15
	ret 
	