.data
    prompt_num1: .asciiz "\nEnter the first integer: "
    prompt_op: .asciiz "\nEnter the operator: "
    prompt_num2: .asciiz "\nEnter the second integer: "
    output: .asciiz "\nThe result is: "
    integer_division: "\nHope you weren't expecting a floating point number!"
    end_options: .asciiz "\nPress (1) restart, (2) see history, (3) exit"
    history_options: .asciiz "/nPress (1) for more, (0) to go back"
    history_empty_msg: .asciiz "/nHistory empty!"

.text

main:
    # create array in heap for history
    # increment stack for 4 words
    addi $sp, $sp, -20
    # store $s to save val
    sw $s0, 0($sp)
    sw $s1, -4($sp)
    sw $s2, -8($sp)
    sw $s3, -12($sp)
    sw $s4, -16($sp)

    li $v0, 9 # sbrk for heap alloc
    addi $a0, $zero, 400 # alloc 100 words
    syscall
    # store array[] to $s0
    move $s0, $v0
    # create ptr to walk array
    add $t0, $zero, $s0

    # assign static operators for reference
    addi $s1, $zero, 43 # addition
    addi $s2, $zero, 45 # subtraction
    addi $s3, $zero, 42 # multiplication
    addi $s4, $zero, 47 # division

repeat_calc:
    # syscall, ask the user for input
    # li: ori $v0, $zero, 4
    li $v0, 4 # load immediate 4 into $v0, print_string
    # la: lui $at, hi_prompt_num1
    #     ori $a0, $at, lo_prompt_num1
    la $a0, prompt_num1 # load addr prompt_num1 into $a0
    syscall
    li $v0, 5 # syscall, read_int
    syscall
    sw $v0, 0($t0) # store in first byte of heap
    lw $t1, 0($t0) # store num1 into $t1
    addiu $t0, $zero, 4 # increment array
    li $v0, 4
    la $a0, prompt_op
    syscall
    li $v0, 12 # read_character for operator
    syscall
    sw $v0, 0($t0) # store in second byte of heap
    lw $t2, 0($t0) # load operator into $t2
    addiu $t0, $zero, 4 # ++arr
    li $v0, 4
    la $a0, prompt_num2
    syscall
    li $v0, 5 # read_int
    syscall
    sw $v0, 0($t0) # store in third byte of stack
    lw $t3, 0($t0) # store num2 in #t3
    addiu $t0, $zero, 4 # ++arr
    # need to parse character to find operator
    j which_operator

    which_operator:
        bne $s1, $t2, not_addition
        j basic_addition

    not_addition:
        bne $s2, $t2, not_subtraction
        j basic_subtraction

    not_subtraction:
        bne $s3, $t2, basic_division # if not, has to be division
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
        # check remainder
        #beq $t5, $zero, display_output


    display_output:
        la $a0, output # load output message
        li $v0, 4 # print_string
        syscall
        addi $t1, $zero, 61 # equal sign
        sw $t1, 0($t0)
        addiu $t0, $t0, 4
        sw $t4, 0($t0)
        addiu $t0, $t0, 4
        add $a0, $t4, $zero # load 32 bit result
        li $v0, 1 # print_int
        syscall
        bne $s4, $t2, prompt_end_options # check if integer division
        la $a0, integer_division # load integer division message
        li $v0, 4
        syscall
        # NOTE: 20 bytes heap used
        j prompt_end_options

    display_output64:
        la $a0, output # load output message
        li $v0, 4 # print_string
        syscall
        addi $t1, $zero, 61
        sw $t1, 0($t0)
        addiu $t0, $t0, 4
        sw $t5, 0($t0)
        addiu $t0, $t0, 4
        sw $t4, 0($t0)
        add $a0, $t5, $zero # load upper 32 bits
        li $v0, 1 # print_int
        syscall
        add $a0, $t4, $zero # cat lower 32 bits
        li $v0, 1 # print_int
        syscall
        bne $t9, $t2, prompt_end_options # check if integer division
        la $a0, integer_division # load integer division message
        li $v0, 4
        syscall
        # NOTE: 24 bytes heap used
        # $t5 is the flag for display_output64 history
        addi $t5, $zero, 1
        j prompt_end_options

    show_history:
        # need guard to not go out of array bounds
        # need to read arr from back, init reverse ptr
        add $t6, $zero, $t0
        lw $t9, 0($t6)
        addi $t6, $t6, -4
        lw $t8, 0($t6)
        addi $t6, $t6, -4
        lw $t7, 0($t6)
        addi $t6, $t6, -4
        lw $t4, 0($t6)
        addi $t6, $t6, -4
        lw $a0, 0($t6)
        addi $t6, $t6, -4
        bne $t5, $zero, history64
        li $v0, 1
        syscall
        add $a0, $zero, $t4
        li $v0, 11 # print_char
        syscall
        add $a0, $zero, $t7
        li $v0, 1
        syscall
        add $a0, $zero, $t8
        li $v0, 11
        syscall
        add $a0, $zero, $t9
        li $v0, 1
        syscall
        resume history:
        la $a0, history_options
        li $v0, 4
        syscall
        li $v0, 5
        beq $v0, $zero, prompt_end_options
        # array bounds guarded
        stl $t1, $s0, $t6
        bne $t1, $zero, history_empty
        j show_history

    history64:
        lw $t3, 0($t6)
        addi $t6, t6, -4
        li $v0, 1
        syscall
        add $a0, $zero, $t4
        li $v0, 11 # print_char
        syscall
        add $a0, $zero, $t7
        li $v0, 1
        syscall
        add $a0, $zero, $t8
        li $v0, 11
        syscall
        add $a0, $zero, $t3
        add $a1, $zero, $t9
        li $v0, 1
        syscall
        j resume_history

    history_empty:
        la $a0, history_empty_msg
        li $v0, 4
        syscall

    prompt_end_options:
        la $a0, end_options
        li $v0, 4
        syscall
        li $v0, 5
        syscall
        add $t1, $v0, $zero
        # init values for comparison
        addi $t2, $zero, 1
        addi $t3, $zero, 2
        addi $t4, $zero, 3
        beq $t1, $t2, repeat_calc
        beq $t1, $t3, show_history
exit:
    # restore $s
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 20 # reset stack pointer
    li $v0, 10 # end program
    syscall
