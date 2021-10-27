.file "src/game/enemy.s"

.section .game.text
	enemy_ship: .asciz "\\___/"
.data
	pos_y:  .quad 0
	pos_x:	.quad 34
	enemy_array: .skip 1024
	current_pointer: .quad 0
	number_of_ships: 	.quad 0
	attribute_count: .quad 5
	start_enemy_bullet_animation: .byte 0
	enemy_bullets: .fill 10 		# 5 enemy bullets supported

.global enemy_test, number_of_ships, get_ship_at_position,print_all_enemy_ships

# Creates a ship that has the following attributes
# rdi: x -> top left x coord
# rsi: y -> top left y coord
# rdx: width 
# rcx: height
# r8:  the type of the ship 0,1,2
# r9:  the health of the ship
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
	movb    %r8b, 4(%r15) # the type of the ship

	movq    5(%r15), %rax # the next free position

	movq	attribute_count, %rsi
	addq	%rsi, current_pointer 	 # next free position 
	# current_pointer = current_pointer + attribute_count

	incq	number_of_ships  # increment the ship count

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
	movb 	$5,  %dl  # width
	movb    $1,  %cl  # height
	movb    $0,  %r8b # type 0
	call    create_ship


	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

enemy_creation:
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq	$0, number_of_ships
	# current_pointer <- enemy_array
	movq	enemy_array,%rax 
	movq	%rax,current_pointer

	movb	$0, %dil  # x
	call    create_basic_ship

	movb	$35, %dil  # x
	call    create_basic_ship

	movb	$50, %dil  # x
	call    create_basic_ship

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

print_all_enemy_ships:

	movq	enemy_array,%rdi 
	call 	print_ships

	ret

# returns a pointer to a ship at position i in the array
# rdi -> index of the ship
# rax -> the pointer to the ship
get_ship_at_position:
	pushq   %rbp 
	movq 	%rsp, %rbp

	# array_index + attribute_count * rdi
	movq	attribute_count, %rax
	mulq	%rdi 
	addq	enemy_array, %rax
	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
# rdi -> a pointer to the ship in memory
# print the ships based on the number_of_ships
print_ships:
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r15
	movq	%rdi, %r15

	movq	number_of_ships, %rcx
	print_ships_loop:
		cmpq	$0, %rcx 
		je 		end_ships_loop
		pushq	%rcx 

		movb	(%r15), 	 %dil # x
		movb    1(%r15),     %sil # y
		movq    $enemy_ship, %rdx # the pattern of our ship
		movb    $0x04,       %cl # color 
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

enemy_shoot:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movb $1, start_enemy_bullet_animation

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

enemy_bullet_animation:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# check if start_anim is 0
	cmpb    $0, start_enemy_bullet_animation
	je      epilogue_seba # if it is 0 jump to epilogue

	# check if there is a collision
	// call  	detectCollision

	# print character 'V' at coords (x,y)
	movb 	($enemy_bullets), 	%dil 
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

epilogue_seba:		
	movq    %rbp, %rsp
	popq 	%rbp

	ret

