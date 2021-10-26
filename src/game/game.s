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

.section .game.text

gameInit:

	call 	clear_screen
	call 	player_init
	call 	enemy_wave_1


    # TODO fix this
    // call 	timer_init

	ret

gameLoop:	
	# prologue
	# start_anim should be a var but it does not work.
	# i replaced start_anim with start_anim and it worked!
	pushq   %rbp 
	movq 	%rsp, %rbp

    call 	muteSpeaker
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
	// # TODO: seems to work even though it is deleted
    cmp 	$128, %rdi
    je 		not_first_run
    call 	isKeyUp
    incq 	%rdi
    jmp 	reset_keypress_info

not_first_run:

    call 	muteSpeaker
	call 	clear_screen
	call 	player_loop
    call 	enemy_loop
    call 	display_information

game_loop_end:
	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
