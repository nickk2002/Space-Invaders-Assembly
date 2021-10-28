.file "src/game/game_engine.s"


.section .game.text
.global clear_screen
.global print_pattern
.global character_count
.global start_pattern_animation
.global do_pattern_animation

current_txt_ptr: .quad 0
current_txt_offset: .quad 0
is_animation_running: .byte 0
animation_cur_x: .quad 0
animation_counter: .quad 0
animation_txt_length: .quad 0

second_toggle_state: .byte 0

toggle_every_second:
    xorb $1, second_toggle_state
    ret

start_pattern_animation:
    # RDI=pointer to string to animate
    movq    %rdi, current_txt_ptr
    movq    $80, animation_cur_x
    call    character_count
    addq    $80, %rax # add 80, to cover distance: left most at rightmost pixel -> rightmost at leftmost pixel
    movq    %rax, animation_txt_length
    movq    $0, current_txt_offset
    movq    $0, animation_counter
    movb    $1, is_animation_running
    ret

do_pattern_animation:
    cmpb    $0, is_animation_running
    je      1f
    cmpq    $0, animation_cur_x
    jne     2f
    incq    current_txt_offset
    jmp     3f
2:
    decq    animation_cur_x
3:
    incq    animation_counter
    movq    animation_counter, %rcx
    cmpq    animation_txt_length, %rcx
    jne     pattern_animate
    movb    $0, is_animation_running
    jmp     1f
pattern_animate:
    movq    animation_cur_x, %rdi
    movq    $10, %rsi
    movq    current_txt_ptr, %rdx
    addq    current_txt_offset, %rdx
    movb    $0x0f, %cl
    call    print_pattern_screen_width
1:
    ret

# Clear the screen
clear_screen:
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq $0, %r8
	xloop:
		cmpq $80, %r8
		je endxloop
		movq $0, %r9
		yloop:
			cmpq $25, %r9
			je endyloop
			movq %r8, %rdi 
			movq %r9, %rsi 
			movb $0x00, %cl
			call putChar
			incq %r9
			jmp yloop
		endyloop:

		incq %r8
		jmp xloop
	endxloop:

	movq    %rbp, %rsp
	popq 	%rbp

	ret

# RDI -> pointer to the string 
# RAX -> number of characters
# gets the character count until a new line/ zero byte
character_count:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq    $0, %rax 
	loop_chars: 
		cmpb $0, (%rdi) # check 0 bytes
		je end_loop_chars

		cmpb $0x0A, (%rdi) # check new line
		je end_loop_chars

		incq %rax
		incq %rdi 
		jmp loop_chars
	end_loop_chars:
		

	# epilogue
	movq    %rbp, %rsp
	popq 	%rbp

	ret

# RDI -> X
# RSI -> Y
# RDX -> address of the string
# RCX -> color
# we are going to write the center of the string at the specified position
# (x,y) is the center of the text that we are writing
# Make sure that there is enough space for it
print_pattern_screen_width:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# r9 -> message address
	# r8 -> the initial x coordinate

	andq	$0xff, %rdi # x
	andq	$0xff, %rsi # y
	movq 	%rdx,  %r9 # the message address

	pushq   %r15
	movq 	$1,    %r15 # is the current character normal


	movq 	%rdi, %r8   # store the x coord into r8
	
	ppsw_loop: 
		cmpb $0x00, (%r9) # compare char with 0 bytes
		je ppsw_end_loop # end the loop

		cmpb $0x0A, (%r9) # compare with the \n
		jne ppsw_normal  # if it is not equl jump to normal
		ppsw_new_line:
			# we have a new line
			incb %sil # go to the next line increasing y
			movq %r8, %rdi # reset x coord to the initial one
            addq current_txt_offset, %r9 # Add offset on new line to the text
			movq $1, %r15 # reset the flag
			jmp ppsw_end_else 
		ppsw_normal:
			# we have a proper character : not \n or 0 byte 
			cmpq $1,%r15 
			jne ppsw_second_time
            cmpb $80, %dil # Check if we're at the end of the column
            je ppsw_end_else # end the loop

			ppsw_second_time:
			# save contents of x,y,z,color
			pushq %rdi 
			pushq %rsi
			pushq %rdx
			pushq %rcx

			# RDI(dil) -> x 
			# RSI(sil) -> y
			# RDX -> character
			# RCX -> color
			movb (%r9), %dl 
			call putChar

			# pop in reverse order 	
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi

			incq %rdi # increase x by 1
			jmp ppsw_end_else
		ppsw_end_else:

		incq %r9
		jmp ppsw_loop

	ppsw_end_loop:
	
	movq $0, %rax # no error
	popq 	%r15

	# epilogue
	movq    %rbp, %rsp
	popq 	%rbp
	ret

# RDI -> X
# RSI -> Y
# RDX -> address of the string
# RCX -> color
# we are going to write the center of the string at the specified position
# (x,y) is the center of the text that we are writing
# Make sure that there is enough space for it
print_pattern:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# r9 -> message address
	# r8 -> the initial x coordinate

	andq	$0xff, %rdi # x
	andq	$0xff, %rsi # y
	movq 	%rdx,  %r9 # the message address

	pushq   %r15
	movq 	$1,    %r15 # is the current character normal


	movq 	%rdi, %r8   # store the x coord into r8
	
	loop: 
		cmpb $0x00, (%r9) # compare char with 0 bytes
		je end_loop # end the loop

		cmpb $0x0A, (%r9) # compare with the \n
		jne normal  # if it is not equl jump to normal
		new_line:
			# we have a new line
			incb %sil # go to the next line increasing y
			movq %r8, %rdi # reset x coord to the initial one
			movq $1, %r15 # reset the flag
			jmp end_else 
		normal:
			# we have a proper character : not \n or 0 byte 
			cmpq $1,%r15 
			jne second_time
			// first_tine:
			// 	movq $0, %r15
			// 	# we encountered the first char of the line
			// 	# call the character count function
			// 	pushq %rdi # push the x coordinate
			// 	pushq %r8 
			
			// 	movq %r9, %rdi # get the current pointer to the text
			// 	call character_count # get the char count into rax

			// 	popq %r8
			// 	popq %rdi # get the x coordinate back

			// 	# Disable this for no center
			// 	// # compute x - rax/2
			// 	// shr $1, %rax # divie rax by 2
			// 	// subq %rax, %rdi # rdi - rax/2

			// 	cmpq $0, %rdi 
			// 	jle  error # we can't fit it in the screen if x < 0

			
			second_time:
			# save contents of x,y,z,color
			pushq %rdi 
			pushq %rsi
			pushq %rdx
			pushq %rcx

			# RDI(dil) -> x 
			# RSI(sil) -> y
			# RDX -> character
			# RCX -> color
			movb (%r9), %dl 
			call putChar

			# pop in reverse order 	
			popq %rcx
			popq %rdx
			popq %rsi
			popq %rdi

			incq %rdi # increase x by 1
			jmp end_else
		end_else:

		incq %r9
		jmp loop

	end_loop:
	
	movq $0, %rax # no error
	popq 	%r15

	# epilogue
	movq    %rbp, %rsp
	popq 	%rbp
	ret
	error:
		movq $1, %rax # error 

		popq 	%r15
		# epilogue
		movq    %rbp, %rsp
		popq 	%rbp
		ret
