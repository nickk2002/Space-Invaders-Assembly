.section .kernel.data
.section .kernel

.global log_char
.global log_newline
.global log_string
.global log_numq
.global log_numl
.global log_numw
.global log_numb

log_numq:
    # INPUT: RDI=the number
    push %rbp
    movq %rsp, %rbp

    subq $24, %rsp
    movq %rsp, %rsi
    call itoa_q
    movq %rax, %rdi
    call log_string

    movq %rbp, %rsp
    popq %rbp
    ret

log_numl:
    # INPUT: RDI=the number
    push %rbp
    movq %rsp, %rbp

    subq $24, %rsp
    movq %rsp, %rsi

    # andq trick doesn't compile, using this trick instead to remove top 4 bytes
    xor %rcx, %rcx
    movl %edi, %ecx
    movq %rcx, %rdi

    call itoa_l
    movq %rax, %rdi
    call log_string

    movq %rbp, %rsp
    popq %rbp
    ret

log_numw:
    # INPUT: RDI=the number
    push %rbp
    movq %rsp, %rbp

    subq $24, %rsp
    movq %rsp, %rsi
    andq $0xFFFF, %rdi
    call itoa_w
    movq %rax, %rdi
    call log_string

    movq %rbp, %rsp
    popq %rbp
    ret

log_numb:
    # INPUT: RDI=the number
    push %rbp
    movq %rsp, %rbp

    subq $24, %rsp
    movq %rsp, %rsi
    andq $0xFF, %rdi
    call itoa_b
    movq %rax, %rdi
    call log_string

    movq %rbp, %rsp
    popq %rbp
    ret

itoa_q:
    # INPUT: DIL=the number; RSI=pointer to location to store string (24 bytes)
    push %rbp
    movq %rsp, %rbp

    pushq %rdi # Save the original number
    cmpq $0, %rdi
    jge get_numq
    neg %rdi

get_numq:
    call utoa
    popq %rdi
    cmpq $0, %rdi
    jge itoa_doneq
    decq %rax
    movb $'-', (%rax)

itoa_doneq:
    movq %rbp, %rsp
    popq %rbp
    ret

itoa_l:
    # INPUT: DIL=the number; RSI=pointer to location to store string (24 bytes)
    push %rbp
    movq %rsp, %rbp

    pushq %rdi # Save the original number
    cmpl $0, %edi
    jge get_numl
    neg %edi

get_numl:
    call utoa
    popq %rdi
    cmpl $0, %edi
    jge itoa_donel
    decq %rax
    movb $'-', (%rax)

itoa_donel:
    movq %rbp, %rsp
    popq %rbp
    ret

itoa_w:
    # INPUT: DIL=the number; RSI=pointer to location to store string (24 bytes)
    push %rbp
    movq %rsp, %rbp

    pushq %rdi # Save the original number
    cmpw $0, %di
    jge get_numw
    neg %di

get_numw:
    call utoa
    popq %rdi
    cmpw $0, %di
    jge itoa_donew
    decq %rax
    movb $'-', (%rax)

itoa_donew:
    movq %rbp, %rsp
    popq %rbp
    ret

itoa_b:
    # INPUT: DIL=the number; RSI=pointer to location to store string (24 bytes)
    push %rbp
    movq %rsp, %rbp

    pushq %rdi # Save the original number
    cmpb $0, %dil
    jge get_numb
    neg %dil

get_numb:
    call utoa
    popq %rdi
    cmpb $0, %dil
    jge itoa_doneb
    decq %rax
    movb $'-', (%rax)

itoa_doneb:
    movq %rbp, %rsp
    popq %rbp
    ret

utoa:
    # INPUT: RDI=the number; RSI=pointer to location to store string (24 bytes)
    push %rbp
    movq %rsp, %rbp

    addq $23, %rsi # Point to next start of free space on passed stack location
    movb $0x00, (%rsi) # Make string zero terminated

    movq $10, %rcx
    movq %rdi, %rax
    to_char_loop:
        decq %rsi
        movq $0, %rdx
        divq %rcx
        addb $0x30, %dl
        movb %dl, (%rsi)
        cmpq $0, %rax
        jne to_char_loop

    movq %rsi, %rax # Start of pointer moved to return value

    movq %rbp, %rsp
    popq %rbp
    ret

log_newline:
    push %rbp
    movq %rsp, %rbp

    movb $'\n', %dil
    call write_serial

    movq %rbp, %rsp
    popq %rbp
    ret

log_char:
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    call write_serial

    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    ret

log_string:
    # INPUT: RDI=pointer to zero terminated string
    # Prologue
    pushq %rbp
    movq %rsp, %rbp

    movq %rdi, %rdx
    movb $0x01, %ch
send_string_loop:
    movb (%rdx), %cl
    cmpb $0x00, %ch
    je send_string_end
    movb %cl, %dil
    pushq %rcx
    pushq %rdx

    call write_serial
    popq %rdx
    popq %rcx

    incq %rdx
    shl $8, %rcx
    jmp send_string_loop

send_string_end:
    # Epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
