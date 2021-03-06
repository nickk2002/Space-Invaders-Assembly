/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
is_first_run: .byte 1
init_done_str: .asciz "[INFO]: GameInit() done"
game_loop_str: .asciz "[INFO]: GameStarted() done"
pattern_animate_test: .asciz "==================================================test this is a test wow so much tesxt here this is a test =========== asdfkjawnetioj4@#$@#%T^@\nasdasdasdasd"

.section .game.text

gameInit:

	call 	clear_screen

    movq $init_done_str, %rdi
    call log_string
    call log_newline

    /*movq $pattern_big_fat_bus, %rdi*/
    /*call start_pattern_animation*/
    # TODO fix this
    // call 	timer_init

	ret
# run when the game is started again
game_started:

    call    player_init
    call    enemy_init
    
    movq    $game_loop_str, %rdi
    call    log_string
    call    log_newline
    movb    $0, won_animation

    movb    $1, %dil
    movb    $1, %sil
    call    play_song

    ret 

gameLoop:	
	# prologue
	# start_anim should be a var but it does not work.
	# i replaced start_anim with start_anim and it worked!
	pushq   %rbp 
	movq 	%rsp, %rbp

    call    clear_screen

    call 	is_game_started
    cmpb 	$1, %al
    je 		game_loop_running

    call 	main_menu_handle
    jmp 	game_loop_end

game_loop_running:
    cmpb 	$1, is_first_run
    jne 	not_first_run
    movb 	$0, is_first_run


    # Do things here when game is launched from the main menu for the first time
    movq 	$0, %rdi
reset_keypress_info:
    cmp 	$128, %rdi
    je 		not_first_run
    call 	isKeyUp
    incq 	%rdi
    jmp 	reset_keypress_info


not_first_run:
    cmpb    $1, player_dead 
    jne     1f

    pld: 
        # player is dead
        call    player_dead_screen
        call    pause_song

        jmp     game_loop_end

    1: 

    cmpb    $1, player_won
    jne     continue_playing  
    player_won_game:
        call    player_won_screen
        jmp     game_loop_end

    
    continue_playing:  

    # player is not dead and is still playing
	call 	clear_screen
    cmpb    $1, is_animation_running
    jne     3f

    call    do_pattern_animation
    jmp     game_loop_end

    3:
    cmpb    $0, is_player_running
    jne     4f
    call    resume_previous_song

    4:
    call 	player_loop
    call 	enemy_loop
    call 	display_information



game_loop_end:
    call putCharCommit
	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
