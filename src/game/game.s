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

.section .game.text

gameInit:
	# set the timer to 1193182/39772 = 30 fps 
	movq 	$39772, %rdi 
	call 	setTimer # set timer 30 fps I think?

	call 	player_init

	call 	enemy_creation

	# clear the screen
	call 	clear_screen

	ret

gameLoop:	
	# prologue
	# start_anim should be a var but it does not work.
	# i replaced start_anim with start_anim and it worked!
	pushq   %rbp 
	movq 	%rsp, %rbp

    call 	muteSpeaker
	call 	clear_screen
	call 	player_loop
	call 	print_all_enemy_ships
	call 	detect_collision_enemy_bullet

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
