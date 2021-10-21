.file "src/game/enemy.s"

.section .game.text
	enemy_ship: .asciz "\\         /
 \\       /
  \\__Y__/"
.data
	pos_y:  .quad 0
	pos_x:	.quad 34
	enemy_array: .skip 1024
	current_pointer: .quad 0
	index_count: 	.quad 0
	attribute_count: .quad 5
.global enemy_test

# Creates a ship that has the following attributes
# rdi: x -> top left x coord
# rsi: y -> top left y coord
# rdx: width 
# rcx: height
# r8:  the type of the ship 0,1,2
# we use the current_pointer as the memeory position
# return the next free position
create_ship:
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r15
	movq	current_pointer,%r15

	movb	%dil, (%r15) # x coordinate
	movb	%sil, 1(%r15)# y coordinate
	movb	%dl,  2(%r15) # width
	movb 	%cl,  3(%r15) # height 
	movb    %r8b, 4(%r15) # the type of the shup

	movq    5(%r15), %rax # the next free position

	movq	attribute_count, %rsi
	addq	%rsi, current_pointer 	 # next free position 
	# current_pointer = current_pointer + attribute_count

	incq	index_count  # increment the ship count

	popq	%r15
	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

# returns the initial address into rax
# rdi -> x position of the basic ship
# rsi -> pointer
create_basic_ship:
	pushq   %rbp 
	movq 	%rsp, %rbp

	# rdi -> dil from the parameter
	// movb	$10, %dil
	movb 	$0,  %sil #y
	movb 	$3,  %dl  # width
	movb    $7,  %cl  # height
	movb    $0,  %r8b # type 0
	call    create_ship


	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

enemy_test:
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq	$0, index_count
	# current_pointer <- enemy_array
	movq	enemy_array,%rax 
	movq	%rax,current_pointer

	movb	$20, %dil  # x
	call    create_basic_ship

	movb	$35, %dil  # x
	call    create_basic_ship

	movb	$50, %dil  # x
	call    create_basic_ship

	movq 	enemy_array, %rdi 
	call 	print_ships

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

# rdi -> a pointer to the ship in memory
# print the ships based on the index_count
print_ships:
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r15
	movq	%rdi, %r15

	movq	index_count, %rcx
	print_ships_loop:
		cmpq	$0, %rcx 
		je 		end_ships_loop
		pushq	%rcx 

		movb	(%r15), 	 %dil # x
		movb    1(%r15),     %sil # y
		movq    $enemy_ship, %rdx # the pattern of our ship
		movb    $0x0f,       %cl # color 
		call    print_pattern

		popq 	%rcx
		decq	%rcx
		addq	attribute_count, %r15
		jmp 	print_ships_loop
			
	end_ships_loop:


	popq	%r15


	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret




