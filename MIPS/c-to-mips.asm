###############################################################################
# c-to-mips.asm
# author: agge3
# created: 2023.12.7
# purpose: implement C fn in MIPS
###############################################################################

    .data
n:  .word   5 # int n = 5
a:  .word   1, 2, 3, 4, 5, 6, 7, 8, 9, 10 # int[] a, ele initialized
size:   .word   10 # int size = 10

    .text
main:
    lw $a0, n
    jal fact

    lw $a0, a # stores &a[0] in $a0, $a0 = ptr *a
    lw $a1, size
    jal timesTwo

    lw $a0, a
    lw $a0, size
    jal sum

    lw $a0, a
    lw $a1, size
    jal average

    lw $a0, a
    lw $a1, size
    jal center

    jal exit

fact:
    # create stack frame
    subi $sp, $sp, 24
    # store $a0-3 & $ra in stack frame
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    sw $a3, 12($sp)
    sw $ra, 16($sp)

        # base case
        stli $t0, $a0, 2
        beq $t0, $zero, _fact_recusive_case

    addi $v0, $zero, 1
    # collapse stack frame
    addi $sp, $sp, 24
    jr $ra
_fact_recursive_case:
        # arg0 is arg0 for fact
        subi $a0, $a0, 1
        jal fact

    lw $ra, 16($sp) # restore $ra
    lw $a0, 0($sp) # restore $a0
    mult $v0, $a0, $v0 # return = n * return of fact(n - 1)
    # collapse stack frame
    addi $sp, $sp, 24
    jr $ra

times_two:
    addi $t0, $zero, 0 # i counter for loop
_times_two_loop:
        addi $t1, $zero, 0 # make sure $t1 = 0, to do mult
        lw $t1, 0($a0) # load a[i] into $t1
        srl $t1, $t1, 1 # mult $t1 by 2
        sw $t1, 0($a0) # store $t1 back into a[i]
        addi $t0, $t0, 4 # ++i
        addi $a0, $a0, 4 # ++a
        slt $t2, $t0, $a1 # i < size
        bne $t2, $zero, _times_two_loop
    # void fn - no return val
    jr $ra

sum:
    addi $t0, $zero, 0 # i counter for loop
    addi $t1, $zero, 0 # sum = 0, to add a[i] to
_sum_loop:
        lw $t2, 0($a0) # load a[i] into $t2
        add $t1, $t2, $t1 # add to sum
        addi $t0, $t0, 4 # ++i
        addi $a0, $a0, 4 # ++i
        stl $t3, $t0, $a1 # i < size
        bne $t2, $zero, sum_loop
    # int fn - return sum in $v0
    add $v0, $t1, $zero
    jr $ra

average:
    # create stack frame
    subi $sp, $sp, 24
    # store $a0-3 & $ra in stack frame
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    sw $a3, 12($sp)
    sw $ra, 16($sp)
    # $a0 & $a1 are same args for sum
    jal sum
    lw $ra, 16($sp) # restore original $ra
    div $v0, $v0, $a1 # avg = $v0 (sum) / $a1 (size), & return int avg
    addi $sp, $sp, 24 # collapse stack frame
    jr $ra

center:
    # create stack frame
    subi $sp, $sp, 24
    # store $a0-3 & $ra in stack frame
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    sw $a3, 12($sp)
    sw $ra, 16($sp)
    # $a0 & $a1 are same args for average
    jal average
    lw $ra, 16($sp) # restore original $ra
    # loop
    addi $t0, $zero, 0 # i counter for loop
_center_loop:
        lw $t1, 0($a0)
        sub $t1, $t1, $v0 # a[i] - average
        sw $t1, 0($a0)
        addi $t0, $t0, 4 # ++i
        addi $a0, $a0, 4 # ++a
        slt $t2, $t0, $a1 # i < size
        bne $t1, $zero, _center_loop
    # void fn - no return val
    jr $ra

exit:
    li $v0, 10 # exit code
    syscall
