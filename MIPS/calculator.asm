.data
    buffer: .space 1
    prompt_num1 .asciiz "\nEnter the first number: '\0'"
    prompt_op .asciiz "\nEnter the operator: '\0'"
    prompt_num2 .asciiz "\nEnter the second number: '\0'"
    output .asciiz "\nThe result is: '0'"

.text

main:
    # handle input of first number
    # TODO: handle negative sign
    # going to use $t1 for first operand

    # handle input of operators
    # going to use $t0 for operator

    # assign static operators for reference
    sbi 43, 0($t0) # addition
    sbi 45, 1($t0) # subtraction
    sbi 42, 2($t0) # multiplication
    sbi 47, 3($t0) # division

    # syscall, ask the user for input
    li $v0, 4 # load immediate 4 into $v0, print_string
    la $a0, prompt_num1 # load addr prompt_num1 into $a0
    syscall
    li $v0, 6 # syscall, read_float
    syscall
    sw $v0, 0($t1) # store output
    li $v0, 4
    la $a0, prompt_op
    syscall
    li $v0, 5 # read_int for operator
    syscall
    sw $v0, $t2 # store operator in $t2
    li $v0, 4
    la $a0, prompt_num2
    syscall
    li $v0, 6 # read_float
    sw $v0, 4($t1)
    # need to parse string to find operator
    j which_operator

    which_operator:
        lb $t3, 0($t0) # load addition operator, $t3
        bne $t2, $t3, not_addition
        j basic_addition

    not_addition:
        lb $t3, 1($t0) # load subtraction operator
        bne $t2, $t3, not_subtraction
        j basic_subtraction

    not_subtraction:
        lb $t3, 2($t0) # load multiplication operator
        bne $t2, $t3, basic_division # if not, has to be division
        j basic_multiplication # else, multiplication

    # handle input of last number
    # going to use $t3 for last operand & store in $t4
    basic_addition:
        add $t4, $t1, $t3
        j display_output

    basic_subtraction:
        sub $t4, $t1, $t3
        j display_output

    basic_multiplication:
        mult $t1, $t3 # multiply with overflow, check $hi/$low
        j display_output64

    basic_division:
        div $t1, $t3 # check $hi/$low for overflow
        j display_output64

    display_output:
        lw
        li $v0, 1 # print_int
        syscall
    display_output64:





    # syscall, display input
    # code in #v0 = 4 print_string

    li $v0, 10 # end program
    syscall
