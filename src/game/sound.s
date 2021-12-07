.section .game.text
.global audio_loop


play_song:
    # DIL=index in playlist to play
    # RSI=1 if we should loop; 0 otherwise
    call    muteSpeaker # Maybe previous song is still playing
    movb    %dil, current_song_index # Change the song based on the playlist
    movb    $1, is_player_running # Signal to audio_loop it can play the song
    movb    %sil, is_player_looping # Set the loop parameter for the player
    movq    $0, sound_index # Reset player position to the start
    ret

resume_previous_song:
    movb    $0, is_player_running # Signal to audio_loop it can't play the song
    call    muteSpeaker
    movq    previous_sound_index, %rax
    movq    %rax, sound_index
    movb    previous_song_index, %al
    movb    %al, current_song_index
    movb    $1, is_player_looping
    movb    $1, is_player_running # Signal to audio_loop it can play the song
    ret

pause_song:
    cmpb    $2, current_song_index # If the 'ship killed' song is playing we don't want to restore it later
    je      no_save_restore
    movq    sound_index, %rax
    movq    %rax, previous_sound_index
    movb    current_song_index, %al
    movb    %al, previous_song_index
no_save_restore:
    movb    $0, is_player_running
    call    muteSpeaker
    ret

audio_loop:
	pushq	%r15 
    cmpb    $0, is_player_running 
    je      2f

	movq    sound_index, %r15 

    movzb   current_song_index, %rcx
    shl     $3, %rcx
    movq    playlist(%rcx), %rcx

	movb    (%r15, %rcx), %dil

	cmpb	 $255,%dil
	jz 		 ignore
	cmpb     $254, %dil
	jz 		 note_off
	
	play_midi_note:
		shl 	$1, %dil 
		movzx   %dil, %rdi 
		movw	midi_note_to_freq_table(%rdi), %di

		call 	playFrequency
		call    unmuteSpeaker
		jmp 	ignore
	
	note_off:
		call 	muteSpeaker
	ignore:
        incq	%r15 
        movzb   current_song_index, %rcx # Get the index of the current song
        shl     $3, %rcx
        movq    playlist_length(%rcx), %rcx # Get the length (in bytes) of the current song
        cmpq	%rcx, %r15 # Check if we've reached the end of the song
        jne     1f
        cmpb    $1, is_player_looping # Check if we should loop
        je      player_loop_song # If yes loop the song
        movb	$0, is_player_running # We've reached the end stop the player (since we don't loop)
        jmp     2f

    player_loop_song:
        # First 8 bytes are trash
        movq    $0, sound_index # If we're looping reset sound index and keep playing
        jmp     2f
	1:
	movq	%r15,sound_index

    2:
	popq	%r15
	
	ret 


.section .game.data

is_player_running:      .byte 0
current_song_index:     .byte 0
is_player_looping:      .byte 0
previous_sound_index:   .quad 0
previous_song_index:    .quad 0

playlist:
    .quad boss_music
    .quad game_music
    .quad ship_killed_music

playlist_length:
    .quad 576
    .quad 994
    .quad 3

sound_index: .quad 0
midi_note_to_freq_table:
    .byte 0x14, 0x3a, 0x15, 0x1a, 0xe2, 0xfb, 0x60, 0xdf, 0x79, 0xc4, 0x13, 0xab, 0x1b, 0x93, 0x7b, 0x7c
    .byte 0x20, 0x67, 0xf8, 0x52, 0xf2, 0x3f, 0xfd, 0x2d, 0x0a, 0x1d, 0x0a, 0x0d, 0xf1, 0xfd, 0xb0, 0xef
    .byte 0x3c, 0xe2, 0x89, 0xd5, 0x8d, 0xc9, 0x3d, 0xbe, 0x90, 0xb3, 0x7c, 0xa9, 0xf9, 0x9f, 0xfe, 0x96
    .byte 0x85, 0x8e, 0x85, 0x86, 0xf8, 0x7e, 0xd8, 0x77, 0x1e, 0x71, 0xc4, 0x6a, 0xc6, 0x64, 0x1e, 0x5f
    .byte 0xc8, 0x59, 0xbe, 0x54, 0xfc, 0x4f, 0x7f, 0x4b, 0x42, 0x47, 0x42, 0x43, 0x7c, 0x3f, 0xec, 0x3b
    .byte 0x8f, 0x38, 0x62, 0x35, 0x63, 0x32, 0x8f, 0x2f, 0xe4, 0x2c, 0x5f, 0x2a, 0xfe, 0x27, 0xbf, 0x25
    .byte 0xa1, 0x23, 0xa1, 0x21, 0xbe, 0x1f, 0xf6, 0x1d, 0x47, 0x1c, 0xb1, 0x1a, 0x31, 0x19, 0xc7, 0x17
    .byte 0x72, 0x16, 0x2f, 0x15, 0xff, 0x13, 0xdf, 0x12, 0xd0, 0x11, 0xd0, 0x10, 0xdf, 0x0f, 0xfb, 0x0e
    .byte 0x23, 0x0e, 0x58, 0x0d, 0x98, 0x0c, 0xe3, 0x0b, 0x39, 0x0b, 0x97, 0x0a, 0xff, 0x09, 0x6f, 0x09
    .byte 0xe8, 0x08, 0x68, 0x08, 0xef, 0x07, 0x7d, 0x07, 0x11, 0x07, 0xac, 0x06, 0x4c, 0x06, 0xf1, 0x05
    .byte 0x9c, 0x05, 0x4b, 0x05, 0xff, 0x04, 0xb7, 0x04, 0x74, 0x04, 0x34, 0x04, 0xf7, 0x03, 0xbe, 0x03
    .byte 0x88, 0x03, 0x56, 0x03, 0x26, 0x03, 0xf8, 0x02, 0xce, 0x02, 0xa5, 0x02, 0x7f, 0x02, 0x5b, 0x02
    .byte 0x3a, 0x02, 0x1a, 0x02, 0xfb, 0x01, 0xdf, 0x01, 0xc4, 0x01, 0xab, 0x01, 0x93, 0x01, 0x7c, 0x01
    .byte 0x67, 0x01, 0x52, 0x01, 0x3f, 0x01, 0x2d, 0x01, 0x1d, 0x01, 0x0d, 0x01, 0xfd, 0x00, 0xef, 0x00
    .byte 0xe2, 0x00, 0xd5, 0x00, 0xc9, 0x00, 0xbe, 0x00, 0xb3, 0x00, 0xa9, 0x00, 0x9f, 0x00, 0x96, 0x00
    .byte 0x8e, 0x00, 0x86, 0x00, 0x7e, 0x00, 0x77, 0x00, 0x71, 0x00, 0x6a, 0x00, 0x64, 0x00, 0x5f, 0x00

ship_killed_music:
    .byte 0x3c, 0xfe, 0x43

game_music:
    # Short C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # F
    .byte 0x41, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Eflat
    .byte 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Eflat
    .byte 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Wait
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

    # SECTION 2
    # Short C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Eflat
    .byte 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    # D
    .byte 0x3e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    # C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Wait
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

    # SECTION 3
    # Short C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x35, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x35, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # F
    .byte 0x3c, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Eflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Eflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Wait
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

    # SECTION 4
    # Short C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x35, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x35, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # D, Eflat
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Eflat
    .byte 0x3a, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    # D
    .byte 0x39, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    # C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short Bflat
    .byte 0x35, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Short C
    .byte 0x37, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe
    # Wait
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff


.data
boss_music:
    # Sol
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff 
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    #La
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe 

    # Sib
    .byte 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff 
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # SECTION 2
    # La
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Sol
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff 
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe


    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Bflat
    .byte 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # Bflat
    .byte 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Wait
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # SECTION 2 (again)
    # La
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Sol
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff 
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Bflat
    .byte 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # Bflat
    .byte 0x2e, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # A
    .byte 0x2d, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
    # G
    .byte 0x2b, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe

    # Wait
    .byte 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe, 0xfe
