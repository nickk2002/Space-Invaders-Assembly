.file "src/game/enemy.s"

.section .game.text

	default_y_spawn_pos: .byte 4
	enemy_ship_type_1: .asciz "\\__Y__/"
	enemy_ship_type_2: .asciz "|___   ___|
    | |"
    enemy_ship_type_3: .asciz "[___U___]"
    enemy_ship_type_4: .asciz ""
    enemy_ship_type_5: .asciz ""
    enemy_ship_type_6: .asciz " .-------------------------------------------------------------.
'------..-------------..----------..----------..----------..--.|
|       \\\\           THE BIG FAT BUS          ||          ||  ||
|        \\\\           ||          ||          ||          ||  ||
|    ||   || //   //  ||   //  // ||//   //   ||   //   //|| /||
|_.------\"''----------''----------''----------''----------''--'|
| |      |  _-_  |       |       |    |  .-.    |      ||==| C|
| |  __  |.'.-.' |   _   |   _   |    |.'.-.'.  |  __  | \"__=='
'---------'|( )|'-----------| |---------'|( )|'----------\"\"
"


	ship_type_1: .byte 0  
	enemy_ship_type_1_width:  .byte 7 
	enemy_ship_type_1_height:   .byte 1
	enemy_ship_type_1_canon_x: .byte 3
	enemy_ship_type_1_points:  .byte 1
	enemy_ship_type_1_movement:  .byte 1
	enemy_ship_type_1_full_auto:  .byte 0
	enemy_ship_type_1_hp: .byte 1

	ship_type_2: .byte 0
    enemy_ship_type_2_width: .byte 11
   	enemy_ship_type_2_height:  .byte 2
	enemy_ship_type_2_canon_x:  .byte 5
	enemy_ship_type_2_points:  .byte 3
	enemy_ship_type_2_movement:  .byte 0
	enemy_ship_type_2_full_auto:  .byte 1
	enemy_ship_type_2_hp: .byte 2

	ship_type_3: .byte 0
    enemy_ship_type_3_width: .byte 9
   	enemy_ship_type_3_height:  .byte 1
	enemy_ship_type_3_canon_x:  .byte 3
	enemy_ship_type_3_points:  .byte 10
	enemy_ship_type_3_movement:  .byte 1
	enemy_ship_type_3_full_auto:  .byte 1
	enemy_ship_type_3_hp: .byte 3

	ship_type_4: .byte 0
    enemy_ship_type_boss1_width: .byte 0
   	enemy_ship_type_boss1_height:  .byte 8
	enemy_ship_type_boss1_canon_x:  .byte 13
	enemy_ship_type_boss1_points:  .byte 5
	enemy_ship_type_boss1_movement:  .byte 1
	enemy_ship_type_boss1_full_auto:  .byte 1
	enemy_ship_type_boss1_hp: .byte 25

	ship_type_5: .byte 0
    enemy_ship_type_boss2_width: .byte 0
   	enemy_ship_type_boss2_height:  .byte 8
	enemy_ship_type_boss2_canon_x:  .byte 29
	enemy_ship_type_boss2_points:  .byte 5
	enemy_ship_type_boss2_movement:  .byte 1
	enemy_ship_type_boss2_full_auto:  .byte 1
	enemy_ship_type_boss2_hp:	.byte 25

	ship_type_6: .byte 0
    enemy_ship_type_boss3_width: .byte 64
   	enemy_ship_type_boss3_height:  .byte 8
	enemy_ship_type_boss3_canon_x:  .byte 43
	enemy_ship_type_boss3_points:  .byte 5
	enemy_ship_type_boss3_movement:  .byte 1
	enemy_ship_type_boss3_full_auto:  .byte 1
	enemy_ship_type_boss3_hp:	.byte 25

.data
	pos_y:  .quad 0
	pos_x:	.quad 34
	enemy_array: .skip 1024
	current_pointer: .quad 0
	number_of_ships: .quad 0
	attribute_count: .quad 16
	wave_counter: .quad 1
	easy_string: .asciz "[Difficulty]: easy\n"
	medium_string: .asciz "[Difficulty]: medium\n"
	hard_string: .asciz "[Difficulty]: hard\n"
	wave_1_created: .asciz "[Waves]: Wave 1 created!\n"
	wave_2_created: .asciz "[Waves]: Wave 2 created!\n"
	wave_3_created: .asciz "[Waves]: Wave 3 created!\n"
	wave_4_created: .asciz "[Waves]: The boss created!\n"

jumptable_difficulties:
	.quad set_difficulty_easy
	.quad set_difficulty_medium
	.quad set_difficulty_hard

.global number_of_ships, get_ship_at_position, enemy_loop,enemy_init


set_difficulty_easy:
	movq	$easy_string, %rdi 
	call    log_string

	#init player easy lives
	movb    initial_health_easy, %ah
	movb 	%ah, nr_lives

	movb    $1, enemy_ship_type_1_hp
	movb    $3, enemy_ship_type_2_hp
	movb    $3, enemy_ship_type_3_hp
	movb    $15, enemy_ship_type_boss3_hp

    movb    $1, enemy_ship_type_1_points
    movb    $3, enemy_ship_type_2_points
    movb    $10, enemy_ship_type_3_points
    movb    $20, enemy_ship_type_boss3_points

	ret 

set_difficulty_medium:
	movq	$medium_string, %rdi 
	call    log_string

	#init player medium lives
	movb    initial_health_medium, %ah
	movb 	%ah, nr_lives

	movb    $4, enemy_ship_type_1_hp
	movb    $4, enemy_ship_type_2_hp
	movb    $6, enemy_ship_type_3_hp
	movb    $20, enemy_ship_type_boss3_hp

    movb    $2, enemy_ship_type_1_points
    movb    $4, enemy_ship_type_2_points
    movb    $15, enemy_ship_type_3_points
    movb    $25, enemy_ship_type_boss3_points

	ret 

set_difficulty_hard:
	movq	$hard_string, %rdi 
	call    log_string

	#init player hard lives
	movb    initial_health_hard, %ah
	movb 	%ah, nr_lives

	movb    $5, enemy_ship_type_1_hp
	movb    $8, enemy_ship_type_2_hp
	movb    $8, enemy_ship_type_3_hp
	movb    $30, enemy_ship_type_boss3_hp

    movb    $4, enemy_ship_type_1_points
    movb    $6, enemy_ship_type_2_points
    movb    $20, enemy_ship_type_3_points
    movb    $40, enemy_ship_type_boss3_points

	ret 

enemy_init:
	call 	delete_ships
	movq 	$1,wave_counter
	call    enemy_handle_difficulties
	call 	enemy_wave_1
	ret

enemy_handle_difficulties:
	
	movq	$0, %rdi 	
	cmpb	$1, difficulty_level
	je 		handle_difficulty
	incq	%rdi 

	cmpb	$2, difficulty_level
	je 		handle_difficulty
	incq	%rdi 

	cmpb	$3, difficulty_level
	je 		handle_difficulty
	incq	%rdi 

	handle_difficulty:
		call	*jumptable_difficulties(,%rdi,8)

	ret
	
enemy_loop:
	call print_all_enemy_ships
	call detect_collision_enemy_bullet
	call detect_collision_two_bullets
	call hanlde_ships
	call all_ships_killed

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
# stack-parameter3: movement of the ship; 0 - moves, 1/2 - oscillates horizontally (1 - first move is to the left, 2 - first move is to the right)
# stack-parameter4: points for killing this ship
# stack-parameter5: boolean for full auto; 1 - full auto; 0 - no full auto
# 15th byte is the x coordinate where the bullet was shot from
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


	movb 	48(%rbp), %sil
	movb 	%sil, 8(%r15) # health
	movb 	40(%rbp), %sil
	movb 	%sil, 9(%r15) # colour
	movb 	32(%rbp), %sil
	movb 	%sil, 10(%r15) # movement
	movb 	24(%rbp), %sil
	movb 	%sil, 11(%r15) # points
	movb 	16(%rbp), %sil
	movb 	%sil, 12(%r15) # full auto

	movq    16(%r15), %rax # the next free position

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
	je      ship_is_type_1

	cmpb    $2, %dil   # check if the type of this is 2 
	je      ship_is_type_2

	cmpb    $3, %dil   # check if the type of this is 3
	je      ship_is_type_3

	cmpb    $4, %dil   # check if the type of this is 4
	je      ship_is_type_4

	cmpb    $5, %dil   # check if the type of this is 5
	je      ship_is_type_5

	cmpb    $6, %dil   # check if the type of this is 6
	je      ship_is_type_6

	ship_is_type_1:
	movq    $ship_type_1, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_2:
	movq    $ship_type_2, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_3:
	movq    $ship_type_3, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_4:
	movq    $ship_type_4, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_5:
	movq    $ship_type_5, %rax 
	jmp 	end_ship_type_if_else

	ship_is_type_6:
	movq    $ship_type_6, %rax 
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

	pushq 	%r13
	pushq 	%r14
	pushq 	%r15

	pushq 	%rdi 
	movb    %sil, %dil 
	call    get_ship_pointer_from_type
	popq    %rdi 

	pushq 	 %rax
	pushq    %rsi 

	# rdi -> dil from the parameter x coord
	movb 	default_y_spawn_pos,  %sil # default value for y ship pos
	movb    1(%rax), %dl # width
	movb    2(%rax), %cl # height
	movb    3(%rax), %r9b # canon position
	xorq 	%r15, %r15
	movb 	4(%rax), %r15b # points for the ship; since it is a stack-passed parameter, it is pushed later in this subroutine
	xorq 	%r14, %r14
	movb 	5(%rax), %r14b # movement parameter of the ship
	xorq 	%r13, %r13
	movb 	6(%rax), %r13b # full auto boolean
	popq 	%rax       # get type of the ship back
	movb    %al,  %r8b # type of the ship
	addb	%dil, %r9b # x coord bullet

	# calculate the y position of the bullet
	# bullet_start_y = y pos ship + height
	movb    %sil, %r10b  
	addb    %cl, %r10b  

	movb 	%r13b, %r11b # default shooting value based on full auto boolean 

	popq	%rax    # get pointer back
	movb	7(%rax), %al
	andq    $0xff, %rax
	// movq	%rax, %rdi 
	// call    log_numq

	pushq 	%rax # hp of the ship

	pushq 	$2 # colour
	pushq 	%r14 # movement
	pushq 	%r15 # points for killing the ship
	pushq 	%r13 # full auto boolean
	call    create_ship

	# epilogue
	popq 	%r13
	popq 	%r14
	popq 	%r15

	movq    %rbp, %rsp
	popq    %rbp 

	ret


delete_ships:
	movq	$0, number_of_ships
	# current_pointer <- enemy_array
	movq	enemy_array,%rax 
	movq	%rax,current_pointer

	ret 


enemy_wave_4:


	movq	$wave_4_created, %rdi
	call    log_string

	call    delete_ships
	

	# THE BOSSS
	movb 	$10, %dil
	movb 	$4, %sil
	call  	create_basic_ship

	movb 	$10, %dil
	movb 	$5, %sil
	call  	create_basic_ship

	movb 	$10, %dil
	movb 	$4, %sil
	call  	create_basic_ship

	movb 	$10, %dil
	movb 	$5, %sil
	call  	create_basic_ship

	movb 	$10, %dil
	movb 	$5, %sil
	call  	create_basic_ship

	movb 	$10, %dil
	movb 	$6, %sil
	call  	create_basic_ship

    # Start the boss music
    call    pause_song
    movb 	$0, %dil
    movb 	$1, %sil
    call 	play_song

    # Do the big fat bus animation
    movq    $pattern_big_fat_bus, %rdi
    call    start_pattern_animation
	ret

enemy_wave_3:
	movq	$wave_3_created, %rdi
	call    log_string

	call    delete_ships

	
	movb	$15, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship

	movb    $7, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	# HERE
	movb	$60, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $60, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$60, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	movb    $0, enemy_ship_type_3_movement
	movb	$25, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $1, enemy_ship_type_3_movement

	movb    $7, default_y_spawn_pos
	movb	$25, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$25, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	movb	$45, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $7, default_y_spawn_pos
	movb	$45, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $10, default_y_spawn_pos
	movb	$45, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	ret



enemy_wave_2:
	movq	$wave_2_created, %rdi
	call    log_string

	call   delete_ships
	
	movb	$15, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $7, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	# HERE
	movb	$60, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $60, default_y_spawn_pos
	movb	$15, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$60, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	movb    $0, enemy_ship_type_3_movement
	movb	$25, %dil  # x coord
	movb    $3, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $1, enemy_ship_type_3_movement

	movb    $7, default_y_spawn_pos
	movb	$25, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	movb    $10, default_y_spawn_pos
	movb	$25, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	movb	$45, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $7, default_y_spawn_pos
	movb	$45, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $10, default_y_spawn_pos
	movb	$45, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	ret

enemy_wave_1:
	movq	$wave_1_created, %rdi
	call    log_string

	call    delete_ships
	

	movb	$25, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $7, default_y_spawn_pos
	movb	$25, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos


	movb	$45, %dil  # x coord
	movb    $2, %sil  # ship type 1
	call    create_basic_ship
	
	movb    $7, default_y_spawn_pos
	movb	$45, %dil  # x coord
	movb    $1, %sil  # ship type 1
	call    create_basic_ship

	movb    $4, default_y_spawn_pos

	ret

enemy_wave_blank:
	movq 	$0, number_of_ships
	movb    $1, player_won
    call    pause_song # Pause the current song
    # TODO player a win song maybe?
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
		je     print_type_1
		cmpb	$2, 4(%r15)  # check if the type is 2
		je     print_type_2
		cmpb	$3, 4(%r15)  # check if the type is 3
		je     print_type_3
		cmpb	$4, 4(%r15)  # check if the type is 4
		je     print_type_4
		cmpb	$5, 4(%r15)  # check if the type is 5
		je     print_type_5
		cmpb	$6, 4(%r15)  # check if the type is 6
		je     print_type_6

		print_type_1:
			movq    $enemy_ship_type_1,%rax    
			jmp   	end_print_type

		print_type_2:
			movq    $enemy_ship_type_2,%rax    
			jmp   	end_print_type

		print_type_3:
			movq    $enemy_ship_type_3,%rax    
			jmp   	end_print_type

		print_type_4:
			movq    $enemy_ship_type_4,%rax    
			jmp   	end_print_type

		print_type_5:
			movq    $enemy_ship_type_5,%rax    
			jmp   	end_print_type

		print_type_6:
			movq    $enemy_ship_type_6,%rax    
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

# parameter %rdi - pointer to the ship which shoots
enemy_shoot:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	movb 	$1, 7(%rdi) 			# set boolean shooting to 1

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

		# calculate the intial bullet y
		# y coord ship + height
		movb    1(%r14), %al 
		addb    3(%r14), %al
		cmpb 	6(%r14), %al
		jne 	no_need_to_set_bullet_pos

		# save the x coord where the bullet was shot from in 15(%r14)
		movb    4(%r14), %dil # type of the ship
		call 	get_ship_pointer_from_type 
		# we have the ship pointer into rax ($ship1, $ship2)
		movb	(%r14), %dil
		addb 	3(%rax), %dil # 3(%rax) is the bullet cannon position relative to x
		movb 	%dil, 15(%r14)

		no_need_to_set_bullet_pos:
		# print character 'V' at coords (x,y)
		movb	6(%r14), %sil 	# y bullet position			

		movb	15(%r14), %dil
		
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
		addb    3(%r14), %al 
		# reached end of the animation
		movb 	%al, 6(%r14)		# start y pos of bullet
		// movb 	12(%r14), %dil 		# get full auto boolean of the ship
		// movb 	%dil, 7(%r14)			# if you put 1 here instead of 0, it triggers full auto mode
		movb 	$0, 7(%r14)

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

	pushq   %r15
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


		cmpb 	$0, 8(%rax)
		jle  	epilogue_dceb

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
		popq    %r15
		movq    %rbp, %rsp
		popq 	%rbp

		ret 
# rax - index of the ship that hit the player's bullet; if there was no hit returns -1
detect_collision_two_bullets:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	pushq   %r15
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

		# check if the enemy ship even shoots
		cmpb 	$0, 12(%rax)
		je 		dctb_loop_finish

		# check collision
		movb 	bullet_position_y, %sil
		cmpb 	%sil, 6(%rax)
		jle  	two_bullets_collision_no

		movb 	bullet_position_x, %sil

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
		popq    %r15

		movq    %rbp, %rsp
		popq 	%rbp
		ret

# %rdi parameter - pointer to the ship
delete_dead_ship:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp


	pushq 	%r15

	movq 	%rdi, %r15

	cmpb 	$0, 8(%r15) # check if the health is 0
	jne		epilogue_dds

	movb    $0, 1(%r15)
	movb    $1, 2(%r15)
	# delete the ship
	movb 	$-1, 8(%r15) # set health to -1 so that it does not trigger delete ship again
	movq 	%r15, %rdi
	call 	swap

	decq 	number_of_ships
    call    pause_song # Pauses the main game song (saves state)
    movb    $2, %dil
    movb    $0, %sil
    call    play_song # Play the ship killed sound effect


	epilogue_dds:
		popq 	%r15

		# epilogue
		movq    %rbp, %rsp
		popq 	%rbp

		ret

# handles calls some subroutines for every ship
hanlde_ships:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp


	pushq 	%r14
	pushq  	%r15

	movq 	number_of_ships, %r15
	decq 	%r15

	handle_ships_loop:
		cmpq 	$-1, %r15		# loop guard
		je 		epilogue_handle_ships

		# get the ship
		movq	%r15, %rdi
		call 	get_ship_at_position
		movq 	%rax, %r14

		movq 	%r14, %rdi
		call 	delete_dead_ship

		movq 	%r14, %rdi
		call  	ship_move

		movq 	%r14, %rdi
		call 	random_shot

		decq 	%r15
		jmp 	handle_ships_loop

	epilogue_handle_ships:
		popq 	%r15
		popq 	%r14

		# epilogue
		movq    %rbp, %rsp
		popq 	%rbp

		ret

# parameter %rdi - the pointer to the ship to be swapped with the last one
swap:
	pushq 	%r15

	movq 	%rdi, %r15

	movq 	number_of_ships, %rdi
	decq 	%rdi
	call  	get_ship_at_position

	movq 	(%r15), %rdi
	xchgq 	%rdi, (%rax)
	movq 	%rdi, (%r15)

	movq 	8(%r15), %rdi
	xchgq 	%rdi, 8(%rax)
	movq 	%rdi, 8(%r15)

	popq 	%r15
	ret

all_ships_killed:
	cmpq 	$4, wave_counter
	je  	boss_wave  # 4 wave is boss

	cmpq 	$0, number_of_ships
	jne 	epilogue_ask
	jmp  	standard_wave

	boss_wave:
		# check if one ship was killed from the ships
		cmpq 	$5, number_of_ships
		je 		wave_blank
		jmp 	epilogue_ask


	standard_wave:
		incq 	wave_counter

		cmpq 	$2, wave_counter
		je 		wave2

		cmpq 	$3, wave_counter
		je 		wave3

		cmpq 	$4, wave_counter
		je 		wave4

		jmp    epilogue_ask

	wave2:
	movq 	$0, number_of_ships
	call  	enemy_wave_2 	# create another wave
	jmp  	epilogue_ask

	wave3:
	movq 	$0, number_of_ships
	call  	enemy_wave_3 	# create another wave
	jmp  	epilogue_ask

	wave4:
	movq	$0, number_of_ships
	call    enemy_wave_4 
	jmp     epilogue_ask


	wave_blank:
		movq 	number_of_ships, %rdi 
		// decq	%rdi 
		call    get_ship_at_position
		movb    $0, 1(%rax)
		movb    $0, 2(%rax)

		movq 	$0, number_of_ships
		call  	enemy_wave_blank 	# create another wave
		jmp  	epilogue_ask

	epilogue_ask:
		ret

# %rdi parameter - pointer to the ship
ship_move:
	cmpb 	$0, 10(%rdi)
	je  	epilogue_sh

	cmpq 	$3, wave_counter
	jne  	normal_ship_movement

	# boss ship movement
	cmpb 	$6, 4(%rdi)
	jne 	epilogue_sh  	# not real boss component (type 6)

	pushq 	%rdi
	movq  	$15, %rdi
	call 	getRandom
	cmpq 	$1, %rax
	popq 	%rdi
	jne 	epilogue_sh

	pushq 	%rdi
	movq  	$7, %rdi
	call 	getRandom
	movq 	$20, %rdi
	mulq 	%rdi
	incq 	%rax 	# %rax has now 0(?), 21, 41, 61, 81, 101, or 121
	popq 	%rdi
	movb 	%al, 10(%rdi)

	normal_ship_movement:
	cmpb 	$21, 10(%rdi)
	je  	enemy_ship_move_left

	cmpb 	$41, 10(%rdi)
	je  	enemy_ship_move_left

	cmpb 	$61, 10(%rdi)
	je  	enemy_ship_move_down

	cmpb 	$81, 10(%rdi)
	je  	enemy_ship_move_right

	cmpb 	$101, 10(%rdi)
	je  	enemy_ship_move_right

	cmpb 	$121, 10(%rdi)
	je  	enemy_ship_move_up

	incb 	10(%rdi)
	jmp 	epilogue_sh

	enemy_ship_move_down:
		cmpq 	$3, wave_counter
		jne  	normal_ship_movement_down

		movb 	$20, %r8b
		subb 	3(%rdi), %r8b
		cmpb 	%r8b, 1(%rdi)
		jge  	epilogue_sh

		incb 	1(%rdi)
		subq 	$16, %rdi
		incb 	1(%rdi)
		subq 	$16, %rdi
		incb 	1(%rdi)
		subq 	$16, %rdi
		incb 	1(%rdi)
		subq 	$16, %rdi
		incb 	1(%rdi)
		subq 	$16, %rdi
		incb 	1(%rdi)
		jmp  	epilogue_sh

		normal_ship_movement_down:
		incb 	1(%rdi)
		incb 	10(%rdi)
		jmp 	epilogue_sh

	enemy_ship_move_right:
		cmpq 	$3, wave_counter
		jne  	normal_ship_movement_right

		movb 	$80, %r8b
		subb 	2(%rdi), %r8b
		cmpb 	%r8b, (%rdi)
		jge  	epilogue_sh

		incb 	(%rdi)
		subq 	$16, %rdi
		incb 	(%rdi)
		subq 	$16, %rdi
		incb 	(%rdi)
		subq 	$16, %rdi
		incb 	(%rdi)
		subq 	$16, %rdi
		incb 	(%rdi)
		subq 	$16, %rdi
		incb 	(%rdi)
		jmp  	epilogue_sh

		normal_ship_movement_right:
		incb 	(%rdi)
		incb 	10(%rdi)
		jmp 	epilogue_sh

	enemy_ship_move_up:
		cmpq 	$3, wave_counter
		jne  	normal_ship_movement_up

		cmpb 	$4, 1(%rdi)
		jle  	epilogue_sh

		decb 	1(%rdi)
		subq 	$16, %rdi
		decb 	1(%rdi)
		subq 	$16, %rdi
		decb 	1(%rdi)
		subq 	$16, %rdi
		decb 	1(%rdi)
		subq 	$16, %rdi
		decb 	1(%rdi)
		subq 	$16, %rdi
		decb 	1(%rdi)
		jmp  	epilogue_sh

		normal_ship_movement_up:
		decb 	1(%rdi)
		movb 	$1, 10(%rdi)
		jmp 	epilogue_sh	

	enemy_ship_move_left:
		cmpq 	$3, wave_counter
		jne  	normal_ship_movement_left

		cmpb 	$1, (%rdi)
		jle 	epilogue_sh

		decb 	(%rdi)
		subq 	$16, %rdi
		decb 	(%rdi)
		subq 	$16, %rdi
		decb 	(%rdi)
		subq 	$16, %rdi
		decb 	(%rdi)
		subq 	$16, %rdi
		decb 	(%rdi)
		subq 	$16, %rdi
		decb 	(%rdi)
		jmp  	epilogue_sh

		normal_ship_movement_left:
		decb 	(%rdi)
		incb 	10(%rdi)

	epilogue_sh:
		ret

# %rdi parameter - the pointer to the ship
random_shot:
	pushq	%r15

	cmpb 	$1, 12(%rdi) 	# check full auto boolean
	jne 	epilogue_rs

	movq  	%rdi, %r15
	movq 	$15, %rdi 		# 1 in 15 change of shooting every fram iff the ship has full auto set to 1
	call 	getRandom
	cmpq 	$1, %rax
	jne  	epilogue_rs

	movq 	%r15, %rdi
	call 	enemy_shoot

	epilogue_rs:
		popq 	%r15

		ret
