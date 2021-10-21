.file "src/game/game_engine.s"

.global clear_screen



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