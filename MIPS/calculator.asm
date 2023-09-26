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

# going to use $t2 for operator logic
which_operator:
lb $t2, 0($t0) # load addition operator
bne $t1, $t2, not_addition
jal basic_addition

not_addition:
lb $t2, 1($t0) # load subtraction operator
bne $t1, $t2, not_subtraction
jal basic_subtraction


not_subtraction:
lb $t2, 2($t0) # load multiplication operator
bne $t2, $t1, basic_division # if not, has to be division
jal basic_multiplication # else, multiplication

# handle input of last number
# going to use $t3 for last operand & store in $t4
basic_addition:
# handle input
add $t4, $t1, $t3

basic_subtraction:
# handle input
sub $t4, $t1, $t3


basic_multiplication:
# handle input
mult $t1, $t3 # multiply with overflow, check $hi/$low

basic_division:
# handle input
div $t1, $t3 # check $hi/$low for overflow

