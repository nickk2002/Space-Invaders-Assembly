.file "src/game/display_stats.s"

.section .game.text
	display_y_coord: .byte 2
	hp_message: .asciz "HP: "
	score_message: .asciz "Score: "
	highscore_message: .asciz "Highscore: "
	dificulty_message: .asciz "Difficulty: "
	easy_message: .asciz "easy"
	medium_message: .asciz "medium"
	hard_message: .asciz "hard"


.section .game.data


display_nr_lives:

	movq	$0, %rdi 
	movq	$0, %rsi 
	movq	$hp_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern


    subq 	$24, %rsp
    movb 	nr_lives, %dil
    movq 	%rsp, %rsi
    call 	itoa_b

	movq	$4, %rdi 
	movq	$0, %rsi 
	movq	%rax, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

    addq 	$24, %rsp

	ret 

display_score:
	movq	$10, %rdi
	movq	$0, %rsi 
	movq	$score_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern


    subq 	$24, %rsp
    movq 	player_points, %rdi
    movq 	%rsp, %rsi
    call 	itoa_q

	movq	$17, %rdi
	movq	$0, %rsi 
	movq	%rax, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

    addq $24, %rsp

	ret 

display_highscore:

	movq	$30, %rdi
	movq	$0, %rsi 
	movq	$highscore_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern


    subq 	$24, %rsp
    movq 	player_best_points, %rdi
    movq 	%rsp, %rsi
    call 	itoa_q

	movq	$41, %rdi
	movq	$0, %rsi 
	movq	%rax, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

    addq 	$24, %rsp

	ret

display_difficulty:



	cmpb    $1, difficulty_level 
	je      easy 
	jne     medium
	easy:
		movq	$60, %rdi
		movq	$0, %rsi 
		movq	$dificulty_message, %rdx
		movq	$0x0f,	%rcx 
		call    print_pattern

		movq	$72, %rdi
		movq	$0, %rsi 
		movq	$easy_message, %rdx
		movq	$0x0f,	%rcx 
		call    print_pattern
	medium:
	cmpb    $2, difficulty_level 

	jne     hard
	movq	$60, %rdi
	movq	$0, %rsi 
	movq	$dificulty_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

	movq	$72, %rdi
	movq	$0, %rsi 
	movq	$medium_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

	hard:
	cmpb    $3, difficulty_level 
	jne     end
	movq	$60, %rdi
	movq	$0, %rsi 
	movq	$dificulty_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

	movq	$72, %rdi
	movq	$0, %rsi 
	movq	$hard_message, %rdx
	movq	$0x0f,	%rcx 
	call    print_pattern

	end:

	ret 


display_information:
	
	call 	display_delimiter
	call    display_nr_lives
	call    display_score
	call    display_highscore
	call    display_difficulty
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
