.file "src/game/game_engine.s"

.global clear_screen
.global print_pattern
.global character_count


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