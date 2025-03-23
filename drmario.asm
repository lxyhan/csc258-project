######################## CSC258 Assembly Final Project #######################
# This file contains our implementation of Dr Mario.
#
# Student 1: Name, Student Number
# Student 2: Name, Student Number (if applicable)
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       1
# - Unit height in pixels:      1
# - Display width in pixels:    256
# - Display height in pixels:   224
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
## Bitmap Assets
##############################################################################
DISPLAY_BUFFER:     # space allocated to avoid overlap between bitmap region
    .space 230000   # and .data segment in memory; DO NOT USE
F_BACKDROP:
    .asciiz "sprites/bottle.bmp"
    .align 2
BACKDROP:           # capsule pixel array; each pixel is 4 bytes \\
    .space 229376   # 256 * 244 * 4 = 229376
F_CAP_BLUE_LEFT:
    .asciiz "sprites/cap_blue_left.bmp"
    .align 2
F_CAP_BLUE_RIGHT:
    .asciiz "sprites/cap_blue_right.bmp"
    .align 2
F_CAP_BLUE_TOP:
    .asciiz "sprites/cap_blue_top.bmp"
    .align 2
F_CAP_BLUE_BOTTOM:
    .asciiz "sprites/cap_blue_bottom.bmp"
    .align 2
F_CAP_BLUE_CENTRE:
    .asciiz "sprites/cap_blue_centre.bmp"
    .align 2
F_CAP_GREEN_LEFT:
    .asciiz "sprites/cap_green_left.bmp"
    .align 2
F_CAP_GREEN_RIGHT:
    .asciiz "sprites/cap_green_right.bmp"
    .align 2
F_CAP_GREEN_TOP:
    .asciiz "sprites/cap_green_top.bmp"
    .align 2
F_CAP_GREEN_BOTTOM:
    .asciiz "sprites/cap_green_bottom.bmp"
    .align 2
F_CAP_GREEN_CENTRE:
    .asciiz "sprites/cap_green_centre.bmp"
    .align 2
F_CAP_RED_LEFT:
    .asciiz "sprites/cap_red_left.bmp"
    .align 2
F_CAP_RED_RIGHT:
    .asciiz "sprites/cap_red_right.bmp"
    .align 2
F_CAP_RED_TOP:
    .asciiz "sprites/cap_red_top.bmp"
    .align 2
F_CAP_RED_BOTTOM:
    .asciiz "sprites/cap_red_bottom.bmp"
    .align 2
F_CAP_RED_CENTRE:
    .asciiz "sprites/cap_red_centre.bmp"
    .align 2
CAP_BLUE:         # capsule pixel array; each pixel is 4 bytes \\
    .space 1280   # 256 * 5 = 1280; we store the bitmap in order \\
CAP_GREEN:       # [left, right, up, down, centre]
    .space 1280
CAP_RED:
    .space 1280

F_VIRUS_BLUE:
    .asciiz "sprites/virus_blue.bmp"
    .align 2
F_VIRUS_GREEN:
    .asciiz "sprites/virus_green.bmp"
    .align 2
F_VIRUS_RED:
    .asciiz "sprites/virus_red.bmp"
    .align 2
VIRUS_BLUE:      # virus pixel array; each pixel is 4 bytes, and \\
    .space 256   # the dimensions of the sprite are TILE_SIZE x TILE_SIZE \\
VIRUS_GREEN:    # so that our size is 8 * 8 * 4 = 256
    .space 256
VIRUS_RED:
    .space 256

##############################################################################
# Immutable Data
##############################################################################
BITMAP_OFFSET_IDX:  # byte at which the bitmap's offset info is found
    .word 10
DISPLAY_WIDTH:      # width of total display, in pixels
    .word 256       # chosen to replicate original Dr. Mario dimensions
DISPLAY_HEIGHT:     # height of total display, in pixels
    .word 224       # chosen to replicate original Dr. Mario dimensions
TILE_SIZE:          # number of pixels that a capsule half occupies
    .word 8
BOTTLE_WIDTH:       # number of tiles in a bottle row
    .word 8
BOTTLE_HEIGHT:      # number of tiles in a bottle column
    .word 16
BOTTLE_OFFSET:      # the (x, y) starting position of the bottle's \\
    .word 0x400048  # interior, in pixels; equates to (x, y) = (96, 64)
VIRUS_CAP:          # number of viruses to spawn at game start
    .word 4
VIRUS_YLIM:         # greatest height from the bottom of the bottle
    .word 10        # that a virus may spawn
ADDR_DSPL:          # address of the bitmap display
    .word 0x10008000
ADDR_KBRD:          # address of the keyboard
    .word 0xffff0000

##############################################################################
# Mutable Data
##############################################################################
BOTTLE:             # BOTTLE_WIDTH * BOTTLE_HEIGHT * 1 byte per tile
    .space 128      # this is an array containing the contents of the bottle \\
                    # i.e. viruses and capsules that have landed
# each byte in this array carries three pieces of information:
# [ direction | colour | type  ]
# [ 4 bits    | 3 bits | 1 bit ]
# direction represents which part of the capsule this entity represents
# code | direction
# ----------------
# 0000 | left
# 0001 | right
# 0010 | top
# 0011 | bottom
# 0100 | centre
# ----------------
# colour represents the virus/capsule colour
# code | colour
# -------------
#  100 | blue
#  010 | green
#  001 | red
# -------------
# type is a single bit: 0 if entity is a virus, 1 if it is a capsule;
# a virus utilizes the colour field, but the direction field MUST BE 0x00
# if the entire entity is 0x00, there is nothing at this position

CAPSULE_P1:         # position of first and second half of player capsule, \\ 
    .space 4        # resp, as tile coordinates in the bottle grid. \\
CAPSULE_P2:         # the first half is always the bottom-left corner. \\
    .space 4        # positions are in format
                    # (xn, yn) = (CAPSULE_Pn[31:16], CAPSULE_Pn[15:0])
CAPSULE_E1:         # direction and colour of first and second half of player \\ 
    .space 1        # capsule, organized as described above in form \\
CAPSULE_E2:         # [ direction | colour | 1 ], and encoded as the entries
    .space 1        # of BOTTLE are
    .align 2

GARBAGE:
    .space 32
BITMAP_OFFSET:
    .space 4

##############################################################################
# Code
##############################################################################
    .text
	.globl main

## Initialize the game. This includes loading all assets, generating a
## starting capsule, and randomly positioning viruses.
# This function takes no arguments.
main:
    jal init_bottle      # zero out the initial bottle array
    jal init_bmp         # initialize the bitmap
    jal generate_virus   # place initial viruses in bottle
    jal generate_capsule # generate a new capsule for the player

    jal draw       # the player capsule is not drawn

    # TODO: jump to game_loop once it is developed!
    j exit

## The main game loop. This runs indefinitely once the game state
## is initialized by the main function.
# This function takes no arguments.
game_loop:
    # 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop

## Exit the program gracefully.
exit:
    li $v0, 10   # send a system call to exit the program
    syscall

## Initialize all values within the BOTTLE array to zero, so that there
## are no non-zero entries that are not deliberately entered later on.
init_bottle:
    la $t9, BOTTLE
    
    li $t0, 0               # introduce loop variable $t0
    lw $t1, BOTTLE_WIDTH    # compute the length of the BOTTLE array; \\
    lw $t2, BOTTLE_HEIGHT   # this is BOTTLE_LENGTH * BOTTLE_WIDTH
    mult $t1, $t2
    mtlo $t1                # use array length as the bound on $t0
  init_bottle_loop:
    beq $t0, $t1 init_bottle_exit
    sb $zero, 0($t9)        # set value at $t0 to zero

    addi $t9, $t9, 1        # move the location you're working with
    addi $t0, $t0, 1        # update loop variable
    j init_bottle_loop
  init_bottle_exit:
    jr $ra
    

## Load all pixel arrays into process memory from the set of bitmaps.
# This function takes no arguments.
init_bmp:
    move $s1, $ra              # save return address, as it will be overwritten in future calls
    
    la $a0, F_BACKDROP         # read in the backdrop pixel array; this will always be \\
    la $a1, BACKDROP           # displayed behind all other drawings
    li $a2, 229376             # 256 * 244 * 4 = 229376
    jal load_bmp
    
    lw $s2, TILE_SIZE          # determine the number of pixels occupied by a tile sprite \\
    mult $s2, $s2              # (ie viruses and capsules); as each pixel occupies 4 bytes, \\
    mflo $s2                   # $s2 = array size = TILE_SIZE * TILE_SIZE * 4
    sll $s2, $s2, 2
    
    la $s0, CAP_BLUE           # load into $s so that it is untouched by load_bmp function
    la $a0, F_CAP_BLUE_LEFT    # load the left-half of the blue capsule into the first 256 \\ 
    move $a1, $s0              # bytes of CAP_BLUE; we will then load the right-half of the \\
    move $a2, $s2              # blue capsule into the next 256 bytes of CAP_BLUE, and so on
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_BLUE_RIGHT   # unfortunately, there is no way to loop this as files are \\
    move $a1, $s0              # named distinctly; in theory, we could automate file search \\
    move $a2, $s2              # with well-chosen file names but this becomes ugly very fast
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_BLUE_TOP
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_BLUE_BOTTOM
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_CAP_BLUE_CENTRE
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    la $s0, CAP_GREEN          # read in the green capsule pixel arrays
    la $a0, F_CAP_GREEN_LEFT
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_GREEN_RIGHT
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_GREEN_TOP
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_GREEN_BOTTOM
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_CAP_GREEN_CENTRE
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    la $s0, CAP_RED          # read in the red capsule pixel arrays
    la $a0, F_CAP_RED_LEFT
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_RED_RIGHT
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_RED_TOP
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_CAP_RED_BOTTOM
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_CAP_RED_CENTRE
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    la $a0, F_VIRUS_BLUE     # read in the blue virus pixel array
    la $a1, VIRUS_BLUE
    move $a2, $s2
    jal load_bmp

    la $a0, F_VIRUS_GREEN    # read in the blue virus pixel array
    la $a1, VIRUS_GREEN
    move $a2, $s2
    jal load_bmp

    la $a0, F_VIRUS_RED      # read in the blue virus pixel array
    la $a1, VIRUS_RED
    move $a2, $s2
    jal load_bmp

    jr $s1

## Load the pixel data of a bitmap into memory. Reads through
## input bitmap metadata to determine where to begin reading
## the pixel array, so the buffer will contain only pixel data.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : name of file to be loaded
# - $a1 : address of buffer to load file contents to
# - $a2 : number of bytes to load from file into buffer
#  NOTE : recall each pixel is 4 bytes!
load_bmp:
    move $t0, $a0               # move arguments to temporary registers
    move $t1, $a1               # so that we can populate the $a
    move $t2, $a2               # registers with syscall arguments
    lw $t3, BITMAP_OFFSET_IDX   # bring the position of the offset to register
  
    li $v0, 13           # system call for opening a file
    move $a0, $t0        # load file name
    li $a1, 0            # open for reading
    li $a2, 0            # mode is ignored
    syscall              # open file
    move $t9, $v0        # store file descriptor in $t9

    li $v0, 14           # system call for reading file
    move $a0, $t9        # file descriptor to read from
    la $a1, GARBAGE      # throw away the contents of this read
    move $a2, $t3        # read until we arrive at the bitmap offset
    syscall

    li $v0, 14              # read the integer storing the bitmap's //
    move $a0, $t9           # offset (i.e. the byte at which the pixel //
    la $a1, BITMAP_OFFSET   # array begins) into BITMAP_OFFSET
    li $a2, 4
    syscall
    lw $t4, BITMAP_OFFSET   # $t4 now contains the first pixel byte

    sub $t4, $t4, $t3    # we traversed BITMAP_OFFSET_IDX bytes already
    addi $t4, $t4, -4    # we traversed 4 bytes reading BITMAP_OFFSET

    li $v0, 14           # jump to the start of the pixel array
    move $a0, $t9
    la $a1, GARBAGE      # throw away the contents of this read
    move $a2, $t4        # read remaining bytes until the first pixel
    syscall
    
    li $v0, 14           # system call for reading file
    move $a0, $t9        # file descriptor to read from
    move $a1, $t1        # address of buffer to read to
    move $a2, $t2        # number of bytes to read
    syscall              # read file

    li $v0, 16           # system call for closing a file
    move $a0, $t9        # file descriptor to close
    syscall              # close file

    jr $ra               # return to the caller

## Generate a random colour, in the format specified for BOTTLE
## entries. Returns a one-hot encoding of the colour generated:
## code | colour
## -------------
##  100 | blue
##  010 | green
##  001 | red
## Returns the colour in $v0.
generate_colour:
    li $v0, 42   # system call for generating a bounded random int
    li $a0, 0    # set the generator ID to 0 (irrelevant) 
    li $a1, 3    # generate a number in {0, 1, 2}
    syscall      # this random number is now stored in $a0
    
    li $t1, 1            # shift 1 based on generated integer; \\
    sllv $v0, $t1, $a0   # this is our return value
    jr $ra               # return to caller

## Generate VIRUS_COUNT viruses on the bottle grid.
# This function takes no arguments.
generate_virus:
    li $t0, 0           # introduce a loop variable $t0
    lw $t1, VIRUS_CAP   # bound loop variable by $t1
  generate_virus_loop:                  # exit loop once we have \\
    beq $t0, $t1, generate_virus_exit   # generated all viruses

    li $v0, 42             # generate a random int
    li $a0, 0              # set the generator ID to 0
    lw $a1, BOTTLE_WIDTH   # bound int above by bottle width
    syscall
    move $t2, $a0          # store this as our randomized x pos

    li $v0, 42             # generate a random int
    li $a0, 0
    lw $a1, VIRUS_YLIM     # int can only be in the lowest \\
    syscall                # VIRUS_YLIM rows
    lw $t3, BOTTLE_HEIGHT  # invert as y = 0 is at top of bottle: \\
    sub $t3, $t3, $a0      # we must subtract 1 from the result, as \\
    addi $t3, $t3, -1      # 16 - [0, YLIM] = [16 - YLIM, 16], allowing \\
                           # for y = 16, which we cannot have; \\
                           # store this as our randomized y pos

    la $t4, BOTTLE         # check that the randomized position, \\
    lw $t5, BOTTLE_WIDTH   # at index y * BOTTLE_WIDTH + x since \\
    mult $t3, $t5          # each entry occupies only 1 byte, \\
    mflo $t5               # is empty; if it is, then save the \\
    add $t5, $t5, $t2      # virus at that position; otherwise, \\
    add $t4, $t4, $t5      # try again
    lb $t6, 0($t4)
    bne $t6, $zero, generate_virus_loop

    addi $sp, $sp, -4      # generate a new colour for this virus; \\
    sw $t0, 0($sp)         # as this makes a function call, we \\
    addi $sp, $sp, -4      # must store the return address and \\
    sw $t1, 0($sp)         # any data that we need to persist \\
    addi $sp, $sp, -4      # in the stack
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    jal generate_colour

    lw $ra, 0($sp)         # load data from the stack
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    sll $v0, $v0, 1        # we want entry to have form \\
    sb $v0, 0($t4)         # [ 0000 | colour | 0 ] for a coloured \\
                           # virus, so we shift one left and save

    addi, $t0, $t0, 1      # only increment if a virus was \\
    j generate_virus_loop  # successfully generated
  generate_virus_exit:
    jr $ra

## Generate a new player capsule and load its information into.
## CAPSULE_Pn and CAPSULE_En memory locations.
# This function takes no arguments, and returns:
# - $v0 : 1 if the capsule was successfully generated; 0 if the 
#         capsule cannot generate. This latter circumstance only 
#         occurs if the capsule init position is already occupied
#         by some other entity, and should be used to trigger Game Over.
generate_capsule:
    lw $t0, BOTTLE_WIDTH   # the capsule is positioned in the middle \\
    sra $t0, $t0, 1        # of the top row, so compute the halfway \\
    sll $t2, $t0, 16       # point of the bottle grid for the x \\
    sw $t2, CAPSULE_P2     # coordinate, and set the y coordinate to 0
    # NOTE: we set P2 first to reduce the number of operations. For \\
    # example, a grid with width 8 will have midpoint 4. This is the \\
    # left half of the middle due to 0-indexing. To set P1 first, we \\
    # would subtract 1 from the midpoint, then add 1 back after for P2.

    addi $t1, $t0, -1      # the capsule always begins horizontally, \\
    sll $t1, $t1, 16       # so the first half is always to the left
    sw $t1, CAPSULE_P1
    
    addi $sp, $sp, -4      # store the return address for the current \\
    sw $ra, 0($sp)         # function in the stack prior to making other
                           # function calls

    jal generate_colour        # generate a colour for the first capsule \\
    move $t0, $v0              # half, and shift left by one to align with \\
    sll $t0, $t0, 1            # the expected formatting (colour data ends \\
    ori $t0, $t0, 0b00000001   # at bit 1 not 0); then indicate the entity \\
    sb $t0, CAPSULE_E1         # is a capsule in the last bit with 1

    jal generate_colour        # generate a colour for the second capsule \\
    move $t0, $v0              # half and set up entity byte using the \\
    sll $t0, $t0, 1            # same procedure as the first capsule half
    ori $t0, $t0, 0b00010001
    sb $t0, CAPSULE_E2
    
    lw $ra, 0($sp)         # retrieve the return address stored on \\
    addi $sp, $sp, 4       # the stack, and return to the caller
    jr $ra

## Draw a the current state of the game, including the backdrop,
## all sprites / indicators, and the contents of the bottle. If
## CAPSULE_P1 is 0, this function does not draw the current capsule
## controlled by the player.
## This function only modifies $t registers.
draw:
    addi $sp, $sp, -4
    sw $ra, 0($sp)           # save return address, as it will be overwritten in future calls
    
    la $a0, BACKDROP         # draw the backdrop
    lw $a1, DISPLAY_HEIGHT   # backdrop takes up the entire display
    lw $a2, DISPLAY_WIDTH
    li $a3, 0x0              # the backdrop begins at the top-left \\
    jal draw_region          # of the display
    
    # TODO: draw the doctor (only necessary if we choose to animate)
    # TODO: draw the score on the score board
    
    la $t0, BOTTLE          # we begin drawing the bottle's contents
    li $t1, 0               # introduce a loop variable y = $t1
    lw $t2, BOTTLE_HEIGHT   # y is bound above by the bottle height
  draw_bottle_loop_y:
    beq $t1, $t2, draw_bottle_loop_y_end   # terminate the loop once we read all rows
    
    li $t3, 0               # introduce a loop variable x = $t3
    lw $t4, BOTTLE_WIDTH    # x is bound above by the bottle width
  draw_bottle_loop_x:
    beq $t3, $t4, draw_bottle_loop_x_end   # terminate the loop once we read this row

    lw $t6, BOTTLE_WIDTH    # load information about (x, y) from the bottle;
    mult $t6, $t1           # (x, y) information is stored at BOTTLE[x + y * BOTTLE_WIDTH] \\
    mflo $t6                # because each entry occupies one byte
    add $t6, $t6, $t3
    add $t6, $t6, $t0
    lb $t5, 0($t6)
    
    beq $t5, 0, draw_bottle_sprite_end   # if there is nothing at this entry, \\
                                         # skip to the next position
    
    addi $sp, $sp, -4       # save the current state of each register on the stack: \\
    sw $t0, 0($sp)          # there is no guarantee that registers will not change \\
    addi $sp, $sp, -4       # during the draw_entity function call
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)

    move $t6, $t3           # our tile coordinate is (x, y) = ($t3, $t1); format \\
    sll $t6, $t6, 16        # this so that it can be fed into draw_entity
    add $t6, $t6, $t1

    move $a0, $t5
    move $a1, $t6
    jal draw_entity
  
    lw $t4, 0($sp)         # load the state of each register prior to the function \\
    addi $sp, $sp, 4       # call from the stack, so that we can be sure our data
    lw $t3, 0($sp)         # is not modified
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4

  draw_bottle_sprite_end:
    addi $t3, $t3, 1        # increment the loop variable
    j draw_bottle_loop_x
  draw_bottle_loop_x_end:
    addi $t1, $t1, 1        # increment the loop variable
    j draw_bottle_loop_y
  draw_bottle_loop_y_end:
    
    lw $t0, CAPSULE_P1        # load information about the first half \\
    lb $t2, CAPSULE_E1        # of the player-controlled capsule
    
    beq $t0, 0, draw_return   # if first argument is zero, do not draw \\
                              # the player capsule
    
    move $a0, $t2             # draw the first half of the player capsule
    move $a1, $t0
    jal draw_entity

    lw $t1, CAPSULE_P2        # load information about the second half \\
    lb $t3, CAPSULE_E2        # of the player-controlled capsule

    move $a0, $t3             # draw the second half of the player capsule
    move $a1, $t1
    jal draw_entity

  draw_return:
    lw $ra, 0($sp)          # reload the return address from the stack
    addi $sp, $sp, 4
    jr $ra                  # return to the caller

## Draw the entity (either a capsule half or a virus) with the given
## entity byte, containing [ direction | colour | type ] information,
## on the bottle grid at the specified location.
# Takes in the following parameters:
# - $a0 : the entity byte for the entity to be drawn
# - $a1 : the (x, y) coordinate, in terms of tiles, of the entity;
#         this should be in format (x, y) = ($a1[31:16], $a1[15:0]) 
draw_entity:
                            # extract the data from the entity byte:
    andi $t7, $a0, 0x0f     # load the lower 4 bits of the entity: [colour | type]
    andi $t8, $a0, 0xf0     # load the upper 4 bits of the entity: [direction]
    srl $t8, $t8, 4         # shift the direction values into the lower 4 bits

    move $t1, $a1
    lw $t0, TILE_SIZE       # each entry in the bottle is one tile, which has dimension \\
    mult $t1, $t0           # TILE_SIZE; add this to the offset to determine the global \\
    mflo $t1                # position: global position = 8(x, y) + BOTTLE_OFFSET
    lw $t5, BOTTLE_OFFSET
    add $t1, $t1, $t5
    
    # determine the array offset (TILE_SIZE * TILE_SIZE * 4 * t5)
    lw $t9, TILE_SIZE       # determine the offset of the pixel array at which to \\
    mult $t9, $t9           # begin drawing -- this is useful for the capsule \\
    mflo $t9                # pixel arrays, which contain 5 sequences of 256 bytes \\
    sll $t9, $t9, 2         # each of which corresponds to a specific direction.
    mult $t9, $t8           # the offset is computed by
    mflo $t9                # 4(TILE_SIZE * TILE_SIZE) * direction (ie $t8)
    
    lw $a1, TILE_SIZE       # load arguments for draw_region; these are not \\
    lw $a2, TILE_SIZE       # dependent on what we are drawing (ie the pixel array)
    move $a3, $t1
    
    beq $t7, 0b1000, draw_entity_case_blue_virus     # determine which sprite to draw; \\
    beq $t7, 0b0100, draw_entity_case_green_virus    # if we do not match any case, the \\
    beq $t7, 0b0010, draw_entity_case_red_virus      # data is corrupted
    beq $t7, 0b1001, draw_entity_case_blue_capsule
    beq $t7, 0b0101, draw_entity_case_green_capsule
    beq $t7, 0b0011, draw_entity_case_red_capsule
    
  draw_entity_case_blue_virus:
    la $a0, VIRUS_BLUE
    j draw_entity_switch_end
  draw_entity_case_green_virus:
    la $a0, VIRUS_GREEN
    j draw_entity_switch_end
  draw_entity_case_red_virus:
    la $a0, VIRUS_RED
    j draw_entity_switch_end
  draw_entity_case_blue_capsule:
    la $a0, CAP_BLUE
    add $a0, $a0, $t9
    j draw_entity_switch_end
  draw_entity_case_green_capsule:
    la $a0, CAP_GREEN
    add $a0, $a0, $t9
    j draw_entity_switch_end
  draw_entity_case_red_capsule:
    la $a0, CAP_RED
    add $a0, $a0, $t9
  draw_entity_switch_end:

    addi $sp, $sp, -4      # save return address, as this will be overwritten in \\
    sw $ra, 0($sp)         # the next jal instruction
    
    jal draw_region        # call to draw the entity
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra

## Draw a pixel array with given width and height, positioned at a
## specified offset, to the display.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : address of pixel array to read from
# - $a1 : height of region to draw on
# - $a2 : width of region to draw on
# - $a3 : top-left corner of the region to draw on; this
#         should be in format (x0, y0) = ($a3[7:4], $a3[3:0]);
#         here, (x, y) is a pixel, not tile, coordinate
draw_region:
    lw $t0, ADDR_DSPL           # begin working with display region
    andi $t8, $a3, 0x0000ffff   # $t8 = y0 = $a3[15:0]
    andi $t9, $a3, 0xffff0000   # $t9 = x0 = $a3[31:16]
    srl $t9, $t9, 16
    
    li $t1, 0          # introduce a loop variable y = $t1
  draw_region_loop_y:
    bge $t1, $a1, draw_region_loop_y_end   # terminate the loop once we read all rows
    
    li $t2, 0          # introduce a loop variable x = $t2
  draw_region_loop_x:
    bge $t2, $a2, draw_region_loop_x_end   # terminate the loop once we read this row

    mult $t1, $a2      # assume only the lower bits will be significant: this is \\
    mflo $t3           # a safe assumption to make in our context
    add $t3, $t3, $t2  # $t3 = (y * width + x) * 4
    sll $t3, $t3, 2    # multiply by 4, as each pixel occupies 4 bytes of space
    
    add $t6, $a0, $t3
    lw $t4, 0($t6)              # retrieve the pixel at the (x, y) offset position
    andi $t5, $t4, 0xff000000                   # look at pixel transparency: if it is transparent \\
    beq $t5, $zero, draw_non_transparent_exit   # do not draw the pixel
    andi $t4, $t4, 0x00ffffff   # remove alpha-value, as it is not used
    
    lw $t5, DISPLAY_WIDTH       # retrieve display width: used in computing which \\
    add $t3, $t1, $t8           # pixel in the display to update
    mult $t3, $t5               # $t3 = ((y + y0) * width + (x + x0)) * 4
    mflo $t3                    # we apply the same reasoning as above
    add $t3, $t3, $t2
    add $t3, $t3, $t9
    sll $t3, $t3, 2

    add $t6, $t0, $t3    # update display to include the pixel retrieved from \\
    sw $t4, 0($t6)       # the pixel array

  draw_non_transparent_exit:
    addi $t2, $t2, 1     # increment the loop variable
    j draw_region_loop_x
  draw_region_loop_x_end:
    addi $t1, $t1, 1     # increment the loop variable
    j draw_region_loop_y
  draw_region_loop_y_end:
    jr $ra               # return to the caller
