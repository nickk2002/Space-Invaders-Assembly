// .data
// 	code_set_test:	.byte 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0

// .text
// 	format: 	.asciz "Printing: %d \n"



// .global main

// main:
	
// 	pushq %rbp 
// 	movq %rsp, %rbp 

// 	movq $code_set_test, %r8
// 	xorq %rsi, %rsi
// 	movq $format, %rdi 
// 	movq $3, %rax
// 	movb (%r8,%rax),%sil
// 	movq $0, %rax
// 	// call printf

// 	movq %rbp, %rsp 
// 	popq %rbp 

// 	ret 
