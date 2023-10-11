.data
    prompt_num1: .asciiz "\nEnter the first integer: "
    prompt_op: .asciiz "\nEnter the operator: "
    prompt_num2: .asciiz "\nEnter the second integer: "
    output: .asciiz "\nThe result is: "
    integer_division: "\nHope you weren't expecting a floating point number!"

.text

main:
    # increment stack for 3 words
    addi $sp, $sp, -12
    # assign static operators for reference
    addi $t0, $zero, 43 # addition
    addi $t7, $zero, 45 # subtraction
    addi $t8, $zero, 42 # multiplication
    addi $t9, $zero, 47 # division

    # syscall, ask the user for input
    # li: ori $v0, $zero, 4
    li $v0, 4 # load immediate 4 into $v0, print_string
    # la: lui $at, hi_prompt_num1
    #     ori $a0, $at, lo_prompt_num1
    la $a0, prompt_num1 # load addr prompt_num1 into $a0
    syscall
    li $v0, 5 # syscall, read_int
    syscall
    sw $v0, 0($sp) # store in first byte of stack
    lw $t1, 0($sp) # store num1 into $t1
    li $v0, 4
    la $a0, prompt_op
    syscall
    li $v0, 12 # read_character for operator
    syscall
    sw $v0, -4($sp) # store in second byte of stack
    lw $t2, -4($sp) # load operator into $t2
    li $v0, 4
    la $a0, prompt_num2
    syscall
    li $v0, 5 # read_int
    syscall
    sw $v0, -8($sp) # store in third byte of stack
    lw $t3, -8($sp) # store num2 in #t3
    # need to parse character to find operator
    j which_operator

    which_operator:
        bne $t0, $t2, not_addition
        j basic_addition

    not_addition:
        bne $t7, $t2, not_subtraction
        j basic_subtraction

    not_subtraction:
        bne $t8, $t2, basic_division # if not, has to be division
        j basic_multiplication # else, multiplication

    basic_addition:
        add $t4, $t1, $t3
        j display_output

    basic_subtraction:
        sub $t4, $t1, $t3
        j display_output

    basic_multiplication:
        mult $t1, $t3 # multiply with overflow, check $hi/$lo
        mflo $t4
        mfhi $t5
        # check if 32 bit or 64 bit
        beq $t5, $zero, display_output
        j display_output64

    basic_division:
        div $t1, $t3 # check $hi/$lo for overflow
        mflo $t4
        mfhi $t5
        # check if 32 bit or 64 bit
        beq $t5, $zero, display_output
        j display_output64

    display_output:
        la $a0, output # load output message
        li $v0, 4 # print_string
        syscall
        add $a0, $t4, $zero # load 32 bit result
        li $v0, 1 # print_int
        syscall
        bne $t9, $t2, exit # check if integer division
        la $a0, integer_division # load integer division message
        li $v0, 4
        syscall
        j exit

    display_output64:
        la $a0, output # load output message
        li $v0, 4 # print_string
        syscall
        add $a0, $t5, $zero # load upper 32 bits
        li $v0, 1 # print_int
        syscall
        add $a0, $t4, $zero # cat lower 32 bits
        li $v0, 1 # print_int
        syscall
        bne $t9, $t2, exit # check if integer division
        la $a0, integer_division # load integer division message
        li $v0, 4
        syscall
        j exit

    exit:
        addi $sp, $sp, 12 # reset stack pointer
        li $v0, 10 # end program
        syscall
