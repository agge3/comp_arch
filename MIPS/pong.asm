.data
    welcome: .asciiz "Welcome to MIP(pong)S!"
    play_string: .asciiz "Press 'Enter' to play!\nPress 'Esc' to exit... :("
    exit_string: .asciiz "Are you sure you want to exit? y/n"

.text

# define global variables
addi $t0, $zero, 800
sw $t0, 0($gp) # window_width
addi $t0, $zero, 600
sw $t0, 4($gp) # window_height
addi $t0, $zero, 10
sw $t0, 8($gp) # ball_width & ball_height
li.s $f0, 8 # loadi.single precision
sw $f0, 12($gp) # ball_velocity, 8 byte float
addi $t0, $zero, 60
sw $t0, 20($gp) # paddle_width
addi $t0, $zero, 20
sw $f0, 24($gp) # paddle_height

# draw the window
lw $t0, 0($gp)
lw $t1, 4($gp)
mult $s0, $t0, $t1 # no overflow, window dimensions in $s0

# draw the ball
lw $a0, 8($gp) # ball_width
addi $a1, $zero, 400 # starting x-coordinate
addi $a2, $zero, 300 # starting y-coordinate
add $a3, $zero, $a0 # ball_height
jal ball

ball:
    # $a1 is xmin (left edge)
    # $a0 is width
    # $a2 is ymin (top edge)
    # $a3 is height

    beq $a0, $zero, ball_return # 0 width: draw nothing
    beq $a3, $zero, ball_return # 0 height: draw nothing

    li $t0, -1 # white, color in $t0
    la $t1, frame_buffer

    # scale x values to bytes (4 bytes per pixel)
    sll $a0, $a0, 2
    sll $a1, $a1, 2
    # scale y values to bytes (512 * 4 bytes per display row)
    sll $a2, $a2, 11
    sll $a3, $a3, 11

    # translate y values to display row starting addresses
    addu $t2, $a2, $t1
    addu $a3, $a3, $t1
    # translate y values to ball row starting addresses
    addu $a3, $a3, $a1
    addu $t2, $a3, $a1
    # compute the ending address for the first ball row
    addu $t2, $t2, $a0

    # bytes per display row
    li $t4, 0xC80

# draw the paddles
lw $t0, 20($gp)
lw $t0, 34($gp)
mult $t0, $t0, $t1 # paddle1 in $f0, no overflow
add $t1, $zero, $t0 # paddle2 in $f1
