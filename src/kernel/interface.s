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

.global setTimer
.global putChar
.global readKeyCode
.global unmuteSpeaker
.global muteSpeaker
.global playFrequency
.global isKeyDown
.global isKeyUp
.global getRandom

.section .kernel.data
cur_random: .quad 107

.section .kernel

# void setTimer(int16 reloadValue)
#
# The timer used by this library continually counts down from the reloadValue
# and fires an interrupt whenever this counter reaches zero. As the timer has
# a clock of 1193182 Hz, the interrupt rate is (1193182 / reloadValue) Hz.
# E.g., for 60 Hz the reloadValue should be set to 19886.
#
# Note: this library uses the legacy PIT, which is not guaranteed to reach
#       more than 100 Hz on physical machines. (100 Hz is typically used by
#       operating systems to schedule processes.)
# The maximum value of rdi is 2^16 - 1
setTimer:
	pushq	%rbp
	movq	%rsp, %rbp

	movb	$0x36, %al
	outb	%al, $0x43

	movq	%rdi, %rax
	outb	%al, $0x40
	xchgb	%al, %ah
	outb	%al, $0x40

	movq	%rbp, %rsp
	popq	%rbp
	ret

# void putChar(int8 x, int8 y, int8 char, int8 color)
#
# Writes a character to the screen at coordinates (x, y). The resolution of
# the screen is 80 by 25 characters. For more information, look up "VGA text mode".
putChar:
	pushq	%rbp
	movq	%rsp, %rbp

	# The address to write to is 0xB8000 + 2 * (80 * y + x)
	andq	$0xFF, %rdi
	andq	$0xFF, %rsi
	shlq	$4, %rsi		# RSI = 16 * y
	movq	%rsi, %rax		# RAX = 16 * y
	shlq	$2, %rsi		# RSI = 64 * y
	addq	%rsi, %rax		# RAX = 80 * y
	addq	%rdi, %rax

	# Ensure the index on the screen is within bounds
	cmpq	$2000, %rax
	jae		1f

	movq	$0xB8000, %rdi
	shlq	$1, %rax
	addq	%rax, %rdi		# RDI now holds the address at which the 

	# Write the character
	movb	%dl, %al
	movb	%cl, %ah
	movw	%ax, (%rdi)

1:
	movq	%rbp, %rsp
	popq	%rbp
	ret

# int8 readKeyCode()
#
# Reads a single byte from the keyboard buffer. If a byte could be read,
# it is returned in the lowest 8 bits of the return value. Otherwise, 0
# is returned. For information on how to interpret these bytes, look up
# PS2 scan codes.
readKeyCode:
	pushq	%rbp
	movq	%rsp, %rbp

	call	ps2_getkey
	movq	$0, %rax
	or		%r8, %r8
	jz		1f
	movzx	%r8b, %rax

1:
	movq	%rbp, %rsp
	popq	%rbp
	ret


muteSpeaker:
    inb $0x61, %al
    andb $0b11111100, %al # Maybe last bit is 0 as well
    outb %al, $0x61
    ret

unmuteSpeaker:
    inb $0x61, %al
    orb $0b00000011, %al # Maybe last bit is 1 as well
    outb %al, $0x61
    ret

playFrequency:
    # INPUT: RDI=frequency to play
    movb $0xb6, %al # Select PIT channel2 (pc speaker)
    outb %al, $0x43 # Send command to control channel
    movq %rdi, %rax # Store frequency in rax
    # Write the frequency to channel 2
    outb %al, $0x42
    xchgb %al, %ah
    outb %al, $0x42
    ret

isKeyDown:
    call ps2_is_key_down
    ret

isKeyUp:
    call ps2_is_key_up
    ret

rng_get_next:
    movq    cur_random, %rax
    movq    $48271, %rcx
    mulq    %rcx
    movq    %rax, cur_random
    movq    $2147483647, %rcx
    movq    $0, %rdx # No top 64 bits
    divq    %rcx
    movq    %rdx, %rax
    ret

getRandom:
    # RDI=the upper bound (exclusive) of the random number
    call    rng_get_next # Generate the next random number
    movq    $0, %rdx # No top 64 bits
    divq    %rdi # Divide the random with our limit
    movq    %rdx, %rax # Get the modulo of the division, as the result
    ret
