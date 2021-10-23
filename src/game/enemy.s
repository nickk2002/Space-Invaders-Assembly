.file "src/game/enemy.s"

.section .game.text
	enemy_ship: .asciz "\\___/"
	lose: .asciz "YOU LOST"
.data
	pos_y:  .quad 0
	pos_x:	.quad 34
	enemy_array: .skip 1024
	current_pointer: .quad 0
	number_of_ships: .quad 0
	attribute_count: .quad 8

.global enemy_test, number_of_ships, get_ship_at_position,print_all_enemy_ships, enemy_shoot

# Creates a ship that has the following attributes
# rdi: x -> top left x coord
# rsi: y -> top left y coord
# rdx: width 
# rcx: height
# r8:  the type of the ship 0,1,2
# r9:  x coord of the bullet
# r10: y coord of the bullet
# r11: boolean shot; true if shoot animation should be performed/ is being performed
# r11:  the health of the ship
# we use the current_pointer as the memeory position
# return the next free position
create_ship:
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r15
	pushq 	%r11
	pushq 	%r10
	movq	current_pointer, %r15

	movb	%dil, (%r15)  # x coordinate
	movb	%sil, 1(%r15) # y coordinate
	movb	%dl,  2(%r15) # width
	movb 	%cl,  3(%r15) # height 
	movb    %r8b, 4(%r15) # the type of the ship
	movb    %r9b, 5(%r15) # x coord of the bullet
	movb    %r10b, 6(%r15) # y coord of the bullet
	movb 	%r11b, 7(%r15) # shooting boolean

	movq    8(%r15), %rax # the next free position

	movq	attribute_count, %rsi
	addq	%rsi, current_pointer 	 # next free position 
	# current_pointer = current_pointer + attribute_count

	incq	number_of_ships  # increment the ship count

	popq 	%r10
	popq 	%r11
	popq	%r15
	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

# returns the initial address into rax
# rdi -> x position of the basic ship
create_basic_ship:
	pushq   %rbp 
	movq 	%rsp, %rbp

	# rdi -> dil from the parameter
	movb 	$0,  %sil #y
	movb 	$5,  %dl  # width
	movb    $1,  %cl  # height
	movb    $0,  %r8b # type 0
	movb 	$2, %r9b # hard coded cannon position displacement relative to x position of the ship
	addb	%dil, %r9b # x coord bullet
	movb 	$1,  %r10b # y coord bullet
	movb 	$1, %r11b # shooting by default
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

	movb	$40, %dil  # x
	call    create_basic_ship

	movb	$50, %dil  # x
	call    create_basic_ship

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

print_all_enemy_ships:

	movq	enemy_array, %rdi 
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
	call 	enemy_bullet_animation

	popq	%r15

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

# parameter %rdi - index of the ship which shoots
enemy_shoot:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	call 	get_ship_at_position 	# index already in %rdi
	movb 	$1, 7(%rax) 			# set boolean shooting to 1

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

enemy_bullet_animation:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%r13
	pushq 	%r14
	pushq 	%r15

	movq 	number_of_ships, %r15
	decq 	%r15

	enemy_bullet_loop:
		cmpq 	$-1, %r15	# loop guard
		je epilogue_seba

		# get the ship
		movq	%r15, %rdi
		call 	get_ship_at_position
		movq 	%rax, %r14
		cmpb 	$0, 7(%r14)		# check if bullet shooting boolean is 0
		je      enemy_bullet_continue # if it is 0 jump to epilogue

		# print character 'V' at coords (x,y)
		movb	6(%r14), %sil 	# y bullet position
		movb	(%r14), %dil
		addb 	$2, %dil 		# x bullet position hard coded cannon (TODO bullet now teleports accordingly to enemy ship's movement)
		movb 	%dil, 5(%r14)	# update x bullet position
		movb 	$'V', %dl
		movb    $0x0f, %cl
		call    putChar

		# increase y because we are going down 
		incb    6(%r14)
		cmpb	$25, 6(%r14) 		 # compare 25 with y coord of the bullet
		jl     enemy_bullet_continue # if y is less than 25 we still have an animation going

		# reached end of the animation
		movb 	$1, 6(%r14)			# hard coded enemy_bullet_initial_y_pos
		movb 	$0, 7(%r14)			# if you put 1 here instead of 0, it triggers full auto mode

		enemy_bullet_continue:
			decq 	%r15
			jmp 	enemy_bullet_loop

	epilogue_seba:
		popq 	%r15
		popq 	%r14
		popq 	%r13

		movq    %rbp, %rsp
		popq 	%rbp

		ret

# rax - index of the ship that hit the player's ship; if there was no hit returns -1
detect_collision_enemy_bullet:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq 	number_of_ships, %r15
	decq 	%r15

	movq 	$0, %rax
	dceb_loop:
		cmpq 	$1, %rax
		jge		epilogue_dceb

		cmpq 	$-1, %r15	# loop guard
		je 		epilogue_dceb

		# get the ship
		movq	%r15, %rdi
		call 	get_ship_at_position

		# check collision
		cmpb 	$24, 6(%rax)
		jl  	enemy_bullet_collision_no

		movb 	player_position_x, %sil
		cmpb 	%sil, 5(%rax)
		jl  	enemy_bullet_collision_no

		movb 	player_position_x, %sil
		addb 	player_size, %sil
		cmpb 	%sil, 5(%rax)
		jg  	enemy_bullet_collision_no

		enemy_bullet_collision_yes:
			addb 	$5, player_position_x

			movq 	%r15, %rax
			jmp 	epilogue_dceb

		enemy_bullet_collision_no:
			movq 	$-1, %rax

		dceb_loop_finish:
			decq 	%r15
			jmp 	dceb_loop

	epilogue_dceb:
		# epilogue
		movq    %rbp, %rsp
		popq 	%rbp

		ret