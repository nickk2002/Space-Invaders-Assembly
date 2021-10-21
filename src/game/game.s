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
	x: .byte 0
	y: .byte 0
	maxX: .byte 80
	maxY: .byte 25
	counter: .byte 10
	start_anim: .quad 0


.section .game.text
	

# this function simulates the "shooting" when you press Z in mainLoop
do_animation:
	# prologue
	pushq   %rbp 
	movq 	%rsp, %rbp

	# check if start_anim is 0
	cmpq    $0, %r15
	je      epilogue # if it is 0 jump to epilogue


	# print character 'A' at coords (x,y)
	movq 	x, 	%rdi 
	movq	y,	%rsi 
	movb 	$'A', %dl
	movb    $0x0f, %cl
	call    putChar

	# decrease y because we are going up 
	decb    y 
	cmpb	$0, y 
	jne     epilogue # if y is not 0 we still have an animation going

	# reached end of the animation
	movq    $24, y  # intialize y to the bottom of the screen again
	movq 	$0, %r15

epilogue:		
	movq    %rbp, %rsp
	popq 	%rbp

	ret

gameInit:
	# set the timer to 1193182/39772 = 30 fps 
	movq $39772, %rdi 
	call setTimer # set timer 30 fps I think?

	# clear the screen
	call clear_screen

	# setup x,y coords of the missle that shoots
	# is in at the bottom of the screen in the middle
	movq $40, x 
	movq $24, y
	movq $0, %r15
	ret

gameLoop:	
	# prologue
	# start_anim should be a var but it does not work.
	# i replaced start_anim with %r15 and it worked!
	pushq   %rbp 
	movq 	%rsp, %rbp

	call clear_screen
	

	call readKeyCode
	cmpq $0x2C, %rax # check if the key Z was pressed 
	jne did_not_press

	# we did press Z
	# we mark start_anim true
	movq $1, %r15
	
	did_not_press:
	# we call the animation either way because the animation checks the start_anim value
	call do_animation

	# epilogue
	movq    %rbp, %rsp
	popq    %rbp 

	ret
