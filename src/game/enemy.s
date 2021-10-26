.file "src/game/enemy.s"

.section .game.text

	default_y_spawn_pos: .byte 4
	enemy_ship_type_1: .asciz "\\__Y__/"
	enemy_ship_type_2: .asciz "|___   ___|
    | |"


	ship_type_1: .byte 0  
	enemy_ship_type_1_width:  .byte 7 
	enemy_ship_type_1_height:   .byte 1
	enemy_ship_type_1_canon_x: .byte 4


	ship_type_2: .byte 0
    enemy_ship_type_2_width: .byte 11
   	enemy_ship_type_2_height:  .byte 1
	enemy_ship_type_2_canon_x:  .byte 5
	
	lose: .asciz "YOU LOST"
.data
	pos_y:  .quad 0
	pos_x:	.quad 34
	enemy_array: .skip 1024
	current_pointer: .quad 0
	number_of_ships: .quad 0
	attribute_count: .quad 12

.global number_of_ships, get_ship_at_position, enemy_loop

enemy_loop:
	call print_score
	call print_all_enemy_ships
	call detect_collision_enemy_bullet
	call detect_collision_two_bullets

	ret

# Creates a ship that has the following attributes
# rdi: x -> top left x coord
# rsi: y -> top left y coord
# rdx: width 
# rcx: height
# r8:  the type of the ship
# r9:  x coord of the bullet
# r10: y coord of the bullet
# r11: boolean shot; true if shoot animation should be performed/ is being performed
# r12: the health of the ship
# stack-parameter1: the health of the ship
# stack-parameter2: colour of the ship
# stack-parameter3: movement boolean of the ship; 0 - moves, 1 - does not move
# stack-parameter4: points for killing this ship
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
	movb    %r8b, 4(%r15) # type of the ship
	movb    %r9b, 5(%r15) # x coord of the bullet
	movb    %r10b, 6(%r15) # y coord of the bullet
	movb 	%r11b, 7(%r15) # shooting boolean


	movb 	16(%rbp), %sil
	movb 	%sil, 8(%r15) # health
	movb 	24(%rbp), %sil
	movb 	%sil, 9(%r15) # colour
	movb 	32(%rbp), %sil
	movb 	%sil, 10(%r15) # movement boolean
	movb 	40(%rbp), %sil
	movb 	%sil, 11(%r15) # points

	movq    12(%r15), %rax # the next free position



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



# rdi -> ship type(1,2,3) byte
# rax -> returns the pointer to the ship of that type

get_ship_pointer_from_type:

	movq	$0, %rax # pointer to the ship type
	cmpb    $1, %dil   # check if the type of this is 1  
	jne     ship_is_type_2

	ship_is_type_1:
	movq    $ship_type_1, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_2:
	movq    $ship_type_2, %rax 
	jmp 	end_ship_type_if_else
	end_ship_type_if_else:

	ret

# returns the initial address into rax
# rdi -> x position of the basic ship
# rsi -> type of ship 
# based on the type of the ship width, height will be set
# also the life of the ship
create_basic_ship:
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq 	%rdi 
	movb    %sil, %dil 
	call    get_ship_pointer_from_type
	popq    %rdi 

	pushq    %rsi 

	# rdi -> dil from the parameter x coord
	movb 	default_y_spawn_pos,  %sil # default value for y ship pos
	movb    1(%rax), %dl # width
	movb    2(%rax), %cl # height
	movb    3(%rax), %r9b # canon position
	popq 	%rax
	movb    %al,  %r8b # type of the ship
	addb	%dil, %r9b # x coord bullet

	# calculate the y position of the bullet
	# bullet_start_y = y pos ship + height
	movb    %sil, %r10b  
	addb    %cl, %r10b  

	movb 	$1, %r11b # shooting by default

	pushq 	$1 # points for killing the ship
	pushq 	$0 # no movement by default
	pushq 	$2 # colour
	pushq 	$3 # 3 hp
	call    create_ship

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret

enemy_creation:
	movq	$0, number_of_ships
	# current_pointer <- enemy_array
	movq	enemy_array,%rax 
	movq	%rax,current_pointer
	
	movb	$10, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb	$40, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship

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
		cmpb 	$0, 8(%r15)
		jle  	print_ships_loop_finish

		pushq	%rcx 


		movq	$0, %rax 
		cmpb	$1, 4(%r15)  # check if the type is 1
		jne     print_type_2
		print_type_1:
			movq    $enemy_ship_type_1,%rax    
			jmp   	end_print_type

		print_type_2:
			movq    $enemy_ship_type_2,%rax    
			jmp   	end_print_type

		end_print_type:
		movb	(%r15), %dil # x
		movb    1(%r15),%sil # y
		movq    %rax, %rdx 	# the pattern of our ship
		movb    9(%r15), %cl # color 

		call    print_pattern

		# print enemy's hp
		movb	(%r15), 	 %dil # x
		addb 	$6, %dil
		movb    1(%r15),     %sil # y
		movq   	8(%r15), %rdx # the pattern of our ship
		addq 	$48, %rdx
		movb    9(%r15),       %cl # color 
		call    putChar

		popq 	%rcx

		print_ships_loop_finish:
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
		je      enemy_bullet_continue # if it is 0 jump to continue
		cmpb 	$0, 8(%r14)		# check if enemy ship is alive (health > 0)
		jle     enemy_bullet_continue # if it is 0 jump to continue

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

		# calculate the intial bullet y
		# y coord ship + height
		movb    1(%r14), %al 
		incb    %al 
		# reached end of the animation
		movb 	%al, 6(%r14)		# start y pos of bullet
		movb 	$1, 7(%r14)			# if you put 1 here instead of 0, it triggers full auto mode

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

# rax - index of the player's the ship that hit ship; if there was no hit returns -1
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
			call    decrease_one_life
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

# rax - index of the ship that hit the player's bullet; if there was no hit returns -1
detect_collision_two_bullets:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movq 	number_of_ships, %r15
	decq 	%r15

	movq 	$0, %rax
	dctb_loop:
		cmpq 	$1, %rax
		jge		epilogue_dctb

		cmpq 	$-1, %r15		# loop guard
		je 		epilogue_dctb

		# get the ship
		movq	%r15, %rdi
		call 	get_ship_at_position
		movq 	%rax, %r14

		# check collision
		movb 	bullet_position_y, %sil
		cmpb 	%sil, 6(%rax)
		jle  	two_bullets_collision_no

		movb 	bullet_position_x, %sil
		addb 	$2, %sil 					# hard coded cannon position
		cmpb 	%sil, 5(%rax)
		jne  	two_bullets_collision_no

		cmpb 	$1, start_anim
		jne 	two_bullets_collision_no

		two_bullets_collision_yes:

			# end player bullet animation
			movb    bullet_initial_y_pos, %al
			movb    %al, bullet_position_y  # intialize y to the bottom of the screen again
			movb	$0, start_anim


			# calculate the intial bullet y
			# y coord ship + height
			movb    1(%r14), %al 
			incb    %al 
			# reached end of the animation
			movb 	%al, 6(%r14)		# start y pos of bullet

			movq 	%r15, %rax
			jmp 	epilogue_dctb

		two_bullets_collision_no:
			movq 	$-1, %rax

		dctb_loop_finish:
			decq 	%r15
			jmp 	dctb_loop

	epilogue_dctb:
		# epilogue
		movq    %rbp, %rsp
		popq 	%rbp

		ret

print_score:
	// movq	$1, %rdi 
	// movq	$22, %rsi 
	// movq	$player_hp_message, %rdx
	// movq	$0x0f,	%rcx 
	// call    print_pattern

	// movq	$5, %rdi 
	// movq	$22, %rsi 
	// movq	nr_lives, %rdx
	// addq 	$0x30, %rdx
	// movq	$0x0f,	%rcx 
	// call    putChar

	ret 