/*
This file is part of gamelib-x64.

Copyright (C) 2014 Otto Visser

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

.include "src/kernel/00_boot_vars.s"

.file "src/kernel/ps2.s"

.section .kernel.data
ps2_init_str:		.asciz "* Initializing PS/2 subsystem...\n"
ps2_init_done_str:	.asciz "* Initializing PS/2 subsystem: done\n"
ps2_status_str:		.asciz "ps/2 status: %x\n"
keyboard_in_str:	.asciz "Keyboard in: %x\n"

PS2_COMMAND	= 0x64
PS2_DATA	= 0x60

read_bytes:	.quad 0	# our "buffer"
code_set1:	.byte 0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 0
			.byte 0, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0
			.byte 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '\`'
			.byte 0, '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0
			.byte '*', 0, ' ', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			.byte '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.'
			.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

key_states:
    .skip 128

.section .kernel

init_ps2:
	enter	$0, $0

	mov		$ps2_init_str, %r8
	#call	printf

	# steps analogue to http://wiki.osdev.org/%228042%22_PS/2_Controller
	# step 1: TODO: make sure USB goes first and disables USB legacy; after that we check there's ps/2 or not
	# step 2: TODO check that with ACPI (bit 1, offset 109 in FADT should be on)
	# step 3: disable devices
	#mov		$0xAD, %rax
	#out		%al, $PS2_COMMAND
	#mov		$0xA7, %rax
	#out		%al, $PS2_COMMAND

	# step 4: flush the buffer
	in		$PS2_DATA, %al		# ignore content

	# step 5: set controller configuration byte
	
	# step 6: perform self test
#	mov		$0xAA, %rax
#	out		%al, $PS2_COMMAND
# TODO check response: 0x55

	# step 7: one or two channels? (see step 5)

# step 8: perform interface test

# step 9: enable devices

# step 10: reset devices

	mov		$ps2_init_done_str, %r8
	#call	printf

    # Initialize the key_states to zero
    movq $127, %rcx
ps2_reset_key_states:
    movb $0, key_states(%rcx)
    loop ps2_reset_key_states

	leave
	ret

print_ps2_status:
	enter	$0, $0
	push	%rax

	mov		$0, %rax
	in		$PS2_COMMAND, %al
	push	%rax
	mov		$ps2_status_str, %r8
	#call	printf

	leave
	ret

ps2_bottom_half:
	enter	$0, $0
	push	%rax

	movq	$0, %rax
	in		$PS2_DATA, %al
    # PS2 scan code is now in AL
	bt		$7, %rax			# TODO this way we only handle presses, not releases for now
	jc		ps2_set_key_release
	mov		read_bytes, %rbx
	shl		$8, %rbx
	mov		%al, %bl
	mov		%rbx, read_bytes
    andb $0b01111111, %al # Remove key press/release indicator

ps2_set_key_down:
    movb $1, key_states(%rax)
    jmp ps2_finish_processing

ps2_set_key_release:
    andb $0b01111111, %al # Remove key press/release indicator
    movb $2, key_states(%rax)

ps2_finish_processing:
	pop		%rax
	leave
	ret

ps2_getkey:
	enter	$0, $0
	push	%rax

	mov		$0, %r8					# prepare an answer

	mov		read_bytes, %rax		# TODO actually have a buffer
	mov		%rax, %r8
	and		$0xFF, %r8
	cmp		$0, %r8
	je		9f
	shr		$8, %rax
	mov		%rax, read_bytes

9:
	pop		%rax
	leave
	ret

ps2_translate_scancode:
	enter	$0, $0
	push	%rax

	mov		$code_set1, %rax
	mov		(%rax, %r8, 1), %al
	and		$0xFF, %rax
	mov		%rax, %r8

	pop		%rax
	leave
	ret

ps2_is_key_down:
    # INPUT: DIL=scan code of the key (can be the pressed or released version)
    andb $0b01111111, %dil # Remove key press/release indicator
    movb key_states(%rdi), %al # Get the state of the key
    cmpb $1, %al
    je signal_key_down
    movq $0, %rax
    jmp ps2_is_key_down_finish

signal_key_down:
    movq $1, %rax
    movb $0, key_states(%rdi)

ps2_is_key_down_finish:
    ret

ps2_is_key_up:
    # INPUT: DIL=scan code of the key (can be the pressed or released version)
    andb $0b01111111, %dil # Remove key press/release indicator
    movb key_states(%rdi), %al # Get the state of the key
    cmpb $2, %al
    je signal_key_up
    movq $0, %rax
    jmp ps2_is_key_up_finish

signal_key_up:
    movq $1, %rax
    movb $0, key_states(%rdi)

ps2_is_key_up_finish:
    ret

