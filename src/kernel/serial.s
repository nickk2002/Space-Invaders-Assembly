.include "src/kernel/00_boot_vars.s"

.file "src/kernel/serial.s"

.section .kernel.data
COM1 = 0x3f8
COM1_interrupt = COM1 + 1
COM1_fifo = COM1 + 2
COM1_control = COM1 + 3
COM1_modem = COM1 + 4
COM1_status = COM1 + 5
.section .kernel

init_serial:
	enter	$0, $0

    # Disable interrupts for the chip
    movb $0x00, %al
    mov $COM1_interrupt, %dx
    outb %al, %dx

    # Set the DLAB bit (allows the next 2 commands to set the baud rate)
    movb $0x80, %al
    mov $COM1_control, %dx
    outb %al, %dx

    # Baud rate (lowerbyte) rate divisor
    movb $0x02, %al
    mov $COM1, %dx
    outb %al, %dx

    # Baud rate (higherbyte) rate divisor
    movb $0x00, %al
    mov $COM1_interrupt, %dx
    outb %al, %dx

    # Message info: 8bit chars, no parity check, on stop bit
    movb $0x03, %al
    mov $COM1_control, %dx
    outb %al, %dx

    # Enable FIFO, 14-byte treshhold
    movb $0xc7, %al
    mov $COM1_fifo, %dx
    outb %al, %dx

    # IRQs enabled
    movb $0x0b, %al
    mov $COM1_modem, %dx
    outb %al, %dx

    # Set the chip into loopback mode
    movb $0x1e, %al
    mov $COM1_modem, %dx
    outb %al, %dx

    # Write some test data to the chip
    movb $0xae, %al
    mov $COM1, %dx
    outb %al, %dx

    # Read data from the chip
    mov $COM1, %dx
    inb %dx, %al

    # Check if the data read is the same we sent in the previous command
    cmpb $0xae, %al
    jne serial_init_failed # If different, the chip is faulty

    # Reset the chip into normal ooperation mode (disable loopback)
    movb $0x0f, %al
    mov $COM1_modem, %dx
    outb %al, %dx
    movq $0, %rax
    jmp serial_init_done
    

serial_init_failed:
    movq $1, %rax

serial_init_done:
	leave
	ret

write_serial:
    enter   $0, $0
write_serial_wait:
    # Read device status
    mov $COM1_status, %dx
    inb %dx, %al
    # Check if transmit is ready
    and $0x20, %al
    cmpb $0, %al
    je write_serial_wait # If not, we keep waiting
    # Write out character to COM1
    mov $COM1, %dx
    movb %dil, %al
    outb %al, %dx
    leave
    ret
