######################## CSC258 Assembly Final Project #######################
# This file contains our implementation of Dr Mario.
#
# Student 1: Stefan Barna, 1010257758
# Student 2: James Han, 1010051989
#
# We assert that the code submitted here is entirely our own w
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
DISPLAY_REGION_BUFFER:   # space allocated to avoid overlap between bitmap region
    .space 230000        # and .data segment in memory; DO NOT USE
F_BACKDROP:
    .asciiz "sprites/backdrop.bmp"
    .align 2
BACKDROP:           # capsule pixel array; each pixel is 4 bytes \\
    .space 229376   # DISPLAY_WIDTH * DISPLAY_WIDTH * 4 = 229376
F_BOTTLE_GRID_IMG:
    .asciiz "sprites/grid.bmp"
    .align 2
BOTTLE_GRID_IMG:
    .space 32768    # 4 * BOTTLE_WIDTH * BOTTLE_HEIGHT * TILE_SIZE ^ 2
F_CAP_BLUE_LEFT:
    .asciiz "sprites/entities/cap_blue_left.bmp"
    .align 2
F_CAP_BLUE_RIGHT:
    .asciiz "sprites/entities/cap_blue_right.bmp"
    .align 2
F_CAP_BLUE_TOP:
    .asciiz "sprites/entities/cap_blue_top.bmp"
    .align 2
F_CAP_BLUE_BOTTOM:
    .asciiz "sprites/entities/cap_blue_bottom.bmp"
    .align 2
F_CAP_BLUE_CENTRE:
    .asciiz "sprites/entities/cap_blue_centre.bmp"
    .align 2
F_CAP_GREEN_LEFT:
    .asciiz "sprites/entities/cap_green_left.bmp"
    .align 2
F_CAP_GREEN_RIGHT:
    .asciiz "sprites/entities/cap_green_right.bmp"
    .align 2
F_CAP_GREEN_TOP:
    .asciiz "sprites/entities/cap_green_top.bmp"
    .align 2
F_CAP_GREEN_BOTTOM:
    .asciiz "sprites/entities/cap_green_bottom.bmp"
    .align 2
F_CAP_GREEN_CENTRE:
    .asciiz "sprites/entities/cap_green_centre.bmp"
    .align 2
F_CAP_RED_LEFT:
    .asciiz "sprites/entities/cap_red_left.bmp"
    .align 2
F_CAP_RED_RIGHT:
    .asciiz "sprites/entities/cap_red_right.bmp"
    .align 2
F_CAP_RED_TOP:
    .asciiz "sprites/entities/cap_red_top.bmp"
    .align 2
F_CAP_RED_BOTTOM:
    .asciiz "sprites/entities/cap_red_bottom.bmp"
    .align 2
F_CAP_RED_CENTRE:
    .asciiz "sprites/entities/cap_red_centre.bmp"
    .align 2
CAP_BLUE:         # capsule pixel array; each pixel is 4 bytes \\
    .space 1280   # 8 * 8 * 4 * 5 = 1280; we store the bitmap in order \\
CAP_GREEN:        # [left, right, up, down, centre]
    .space 1280
CAP_RED:
    .space 1280

F_VIRUS_BLUE:
    .asciiz "sprites/entities/virus_blue.bmp"
    .align 2
F_VIRUS_GREEN:
    .asciiz "sprites/entities/virus_green.bmp"
    .align 2
F_VIRUS_RED:
    .asciiz "sprites/entities/virus_red.bmp"
    .align 2
VIRUS_BLUE:      # virus pixel array; each pixel is 4 bytes, and \\
    .space 256   # the dimensions of the sprite are TILE_SIZE x TILE_SIZE \\
VIRUS_GREEN:     # so that our size is 8 * 8 * 4 = 256
    .space 256
VIRUS_RED:
    .space 256

F_DIGIT_0:       # because of limitations on fread, we must store each digit \\
    .asciiz "sprites/digits/0.bmp" # digit in its own file, tragically :(
    .align 2
F_DIGIT_1:
    .asciiz "sprites/digits/1.bmp"
    .align 2
F_DIGIT_2:
    .asciiz "sprites/digits/2.bmp"
    .align 2
F_DIGIT_3:
    .asciiz "sprites/digits/3.bmp"
    .align 2
F_DIGIT_4:
    .asciiz "sprites/digits/4.bmp"
    .align 2
F_DIGIT_5:
    .asciiz "sprites/digits/5.bmp"
    .align 2
F_DIGIT_6:
    .asciiz "sprites/digits/6.bmp"
    .align 2
F_DIGIT_7:
    .asciiz "sprites/digits/7.bmp"
    .align 2
F_DIGIT_8:
    .asciiz "sprites/digits/8.bmp"
    .align 2
F_DIGIT_9:
    .asciiz "sprites/digits/9.bmp"
    .align 2
DIGITS:          # pixel contiguous list of pixel arrays; each pixel is 4 \\
    .space 5120  # bytes, and the dimension of each of 10 digits is \\
                 # TILE_SIZE x 2 TILE_SIZE so array size is 8 * 16 * 4 * 10 = 5120 
F_SCOREBOARD:
    .asciiz "sprites/scoreboard.bmp"
    .align 2
SCOREBOARD:      # space for 4 digits, so 4 * sizeof(DIGITS)
    .space 2048

F_PAUSED:
    .asciiz "sprites/paused.bmp"
    .align 2
PAUSED_IMG:      # 5 width, 2 height region, in tiles
    .space 2560  # 5 x TILE_SIZE x 2 x TILE_SIZE x 4 bytes per px

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
PREVIEW_OFFSET:     # the (x, y) starting position of the preview capsule \\
    .word 0xa80080  # in pixels; equates to (168, 120)
SCORE_OFFSET:       # the (x, y) starting position of the scoreboard \\
    .word 0xb80038  # for current score; equates to (176, 56)
PAUSE_OFFSET:
    .word 0x80008   # the (x, y) starting position of the pause indicator

VIRUS_CAP:          # number of viruses to spawn at game start
    .word 4
VIRUS_YLIM:         # greatest height from the bottom of the bottle
    .word 10        # that a virus may spawn

SLEEP_TIME:         # time to sleep between frames by default
    .word 16
DELTA_CAP_DEFAULT:  # time interval between gravity applications \\
    .word 1000       # by default
DELTA_CAP_ACCEL:    # time interval between gravity applications \\
    .word 180       # when accelerated by user input

VIRUS_CLEAR_PTS:    # points received for clearing a virus
    .word 500
CAPSULE_CLEAR_PTS:  # points receieved for clearing a capsule
    .word 25

SCREEN_BACKUP:      # display pixel storage; used for graphical \\
    .space 229376   # transforms as in the pause screen
SCREEN_DESAT:       # display pixel storage for post-transformation \\
    .space 229376   # pixels; to be displayed during pause screen

ADDR_DSPL:          # address of the bitmap display
    .word 0x10008000
ADDR_KBRD:          # address of the keyboard; queue of key presses
    .word 0xffff0000
ADDR_KBRD_HOLD:     # address of the keyboard for key hold -- offset by \\
    .word 0xffff0080   # n to see if the ascii character n is held

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
BOTTLE_DSPL_BUF:    # buffer to draw all bottle entities and grid, \\
    .space 32768    # which will then be drawn to the display; this \\
                    # is used to remove flickering; we compute with \\
                    # TILE_SIZE^2 * BOTTLE_WIDTH * BOTTLE_HEIGHT * 4 bytes per pixel

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

NEXT_E1:            # entity bytes for the first and second halves of the \\
    .space 4        # NEXT capsule, to become the player capsule after the \\ 
NEXT_E2:            # current player capsule lands
    .space 4

TOUCHDOWN_LIST:     # list used in storing the entities that have just \\
    .space 256      # landed on some surface (are no longer falling)
CLEAR_LIST:         # list used in storing the entities that must be \\
    .space 256      # removed from the playing grid

DELTA_CAP:          # time interval between gravity applications
    .space 4
DELTA:              # time since last gravity application
    .word 0
TIMESTAMP:          # the last time measured on the most recent time syscall
    .space 4

VIRUS_COUNT:        # the number of viruses remaining on the bottle grid
    .word 4

SCORE:              # player score
    .word 0
SCORE_DISPL_BUF:    # buffer to draw all digits of player score, \\
    .space 2048     # which will then be drawn to the display; this \\
                    # is used to remove flickering; we compute with \\
                    # TILE_SIZE * ( 2 TILE_SIZE ) * 4 * 4 bytes per pixel
    
GARBAGE:
    .space 32
BITMAP_OFFSET:
    .space 4
    

##############################################################################
# Music and Sound Data
##############################################################################
NOTES:
    .word 76, 76, 60, 76, 60, 72, 76, 60, 79, 60, 60, 60, 67
DURATIONS:
    .word 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200, 200  # 13 entries
ASYNC:
    .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  # 13 entries
    .align 2  # word alignmet
NOTE_COUNT:
    .word 13  # actual count, updates
CURRENT_NOTE:
    .word 0  # current note index
LAST_NOTE_TIME:
    .word 0  # timestamp of last note that was played
TIME_ACCUMULATOR:
    .word 0  # tracks overflow time between notes

##############################################################################
# Stack Macros
##############################################################################
.macro push (%reg)
    addi $sp, $sp, -4
    sw %reg, 0($sp)
.end_macro

.macro pop (%reg)
    lw %reg, 0($sp)
    addi $sp, $sp, 4
.end_macro

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
    jal gen_preview_capsule
    jal load_next_capsule
    jal gen_preview_capsule
    jal init_music       # initialize the music system
    jal draw_backdrop    # draw the backdrop only once
    jal draw             # draw the state of the game before start
    
    li $v0, 30
    syscall              # determine current system time
    sw $a0, TIMESTAMP    # load system time as first timestamp
    j game_loop          # begin the main game loop

## Exit the program gracefully.
exit:
    li $v0, 10   # send a system call to exit the program
    syscall

##############################################################################
# Init Functions
##############################################################################

## Copy a specified number of bytes from a source starting memory 
## address to a target starting memory address.
# This function does not touch the $s registers.
# Takes in the following parameters:
# - $a0 : the address of the source in memory
# - $a1 : the address of the target in memory 
# - $a2 : the number of bytes to copy from source to targed
memcpy:
    move $t4, $a0
    move $t5, $a1
    
    li $t0, 0                    # set the loop variable
    move $t1, $a2                # TILE_SIZE^2 * BOTTLE_HEIGHT * BOTTLE_WIDTH * 4
  memcpy_loop:
    beq $t0, $t1, memcpy_exit
    
    lb $t3, 0($t4)
    sb $t3, 0($t5)
  
    addi $t4, $t4, 1
    addi $t5, $t5, 1
    addi $t0, $t0, 1
  
    j memcpy_loop
  memcpy_exit:
    jr $ra

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

    la $a0, F_BOTTLE_GRID_IMG  # read in the playing grid pixel array; this will always be \\
    la $a1, BOTTLE_GRID_IMG    # displayed behing the bottle entities
    li $a2, 32768              # BOTTLE_WIDTH * BOTTLE_HEIGHT * TILE_SIZE^2 * 4
    jal load_bmp

    #################
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

    #################
    lw $s2, TILE_SIZE        # determine the number of pixels occupied by a digit \\
    mult $s2, $s2            # (ie viruses and capsules); as each pixel occupies 4 bytes, \\
    mflo $s2                 # $s2 = array size = TILE_SIZE * ( 2 * TILE_SIZE ) * 4,
    sll $s2, $s2, 3          # because a digit is 1 x 2 tiles

    la $s0, DIGITS           # read in the list of digit pixel arrays, digit by digit
    la $a0, F_DIGIT_0
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    add $s0, $s0, $s2
    la $a0, F_DIGIT_1
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_2
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_3
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_4
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_5
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_6
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_7
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_8
    move $a1, $s0
    move $a2, $s2
    jal load_bmp
    
    add $s0, $s0, $s2
    la $a0, F_DIGIT_9
    move $a1, $s0
    move $a2, $s2
    jal load_bmp

    la $a0, F_SCOREBOARD
    la $a1, SCOREBOARD
    sll $a2, $s2, 2          # we display 4 digits in scoreboard, so 4 times size \\
    jal load_bmp             # of one digit

    #################
    la $a0, F_PAUSED
    la $a1, PAUSED_IMG
    li $a2, 2560             # 7 x TILE_SIZE x 2 x TILE_SIZE x 4 bytes per px
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

## Place the provided entity byte at the provided coordinate in
## the BOTTLE array. This function *does not check* that the
## region in the array is currently unoccupied!
# Takes in the following parameters:
# - $a0 : the position, in tile coordinates, to check for a collision;
#          this should be in format (x, y) = ($a0[31:16], $a0[15:0]) 
# - $a0 : the entity byte to store at the given coordinate; this has
#         format described for BOTTLE entities : [ dir | col | type ]
commit_to_bottle:
    lw $t0, BOTTLE_WIDTH
    andi $t2, $a0, 0x0000ffff     # extract first half y position
    andi $t3, $a0, 0xffff0000     # extract first half x position
    srl $t3, $t3, 16
    mult $t0, $t2                 # compute the position in the array
    mflo $t4                      # at which to place the entity byte:
    add $t4, $t4, $t3             # pos = y * WIDTH + x
    
    la $t9, BOTTLE
    add $t9, $t9, $t4
    sb $a1, 0($t9)                # store byte at the calculated position

    jr $ra

## Generate VIRUS_COUNT viruses on the bottle grid.
# This function takes no arguments.
generate_virus:
    push ($ra)          # save return address on stack

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

    # NOTE: the following is equivalent to calling validate, then
    # commit_to_bottle. However, calling those procedures involves
    # packaging data in the right format, which the procedures then
    # unpackage themselves. This ultimately leads to more instructions
    # processed for little to no reason (save for the readability that
    # this note hopes to account for)
    la $t4, BOTTLE         # check that the randomized position, \\
    lw $t5, BOTTLE_WIDTH   # at index y * BOTTLE_WIDTH + x since \\
    mult $t3, $t5          # each entry occupies only 1 byte, \\
    mflo $t5               # is empty; if it is, then save the \\
    add $t5, $t5, $t2      # virus at that position; otherwise, \\
    add $t4, $t4, $t5      # try again
    lb $t6, 0($t4)
    bne $t6, $zero, generate_virus_loop

    push ($t0)             # generate a new colour for this virus; \\
    push ($t1)             # as this makes a function call, we \\
    push ($t4)             # must store the return address and \\
                           # any data that we need to persist \\
                           # in the stack
    
    jal generate_colour
 
    pop ($t4)              # retrieve data from the stack
    pop ($t1)
    pop ($t0)

    sll $v0, $v0, 1        # we want entry to have form \\
    sb $v0, 0($t4)         # [ 0000 | colour | 0 ] for a coloured \\
                           # virus, so we shift one left and save

    addi, $t0, $t0, 1      # only increment if a virus was \\
    j generate_virus_loop  # successfully generated
  generate_virus_exit:
    pop ($ra)              # retrieve return address from stack
    jr $ra

## Generate the next capsule to load. This is used in the preview
## for the NEXT capsule.
# This function takes no arguments.
gen_preview_capsule:
    push ($ra)                 # store return address on stack
    
    jal generate_colour        # generate a colour for the first capsule \\
    move $t0, $v0              # half, and shift left by one to align with \\
    sll $t0, $t0, 1            # the expected formatting (colour data ends \\
    ori $t0, $t0, 0b00000001   # at bit 1 not 0); then indicate the entity \\
    sb $t0, NEXT_E1            # is a capsule in the last bit with 1

    jal generate_colour        # generate a colour for the second capsule \\
    move $t0, $v0              # half and set up entity byte using the \\
    sll $t0, $t0, 1            # same procedure as the first capsule half
    ori $t0, $t0, 0b00010001
    sb $t0, NEXT_E2
    
    pop ($ra)                  # retrieve return address from stack
    jr $ra

## Generate a new player capsule and load its information into.
## CAPSULE_Pn and CAPSULE_En memory locations.
# This function takes no arguments, and returns:
# - $v0 : 1 if the capsule was successfully generated; 0 if the 
#         capsule cannot generate. This latter circumstance only 
#         occurs if the capsule init position is already occupied
#         by some other entity, and should be used to trigger Game Over.
load_next_capsule:
    li $s7, 0              # the default return value is 0
  
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
    
    push ($ra)             # store the return address for the current \\
                           # function in the stack prior to making other
                           # function calls

    lw $a0, CAPSULE_P2     # validate the position of the new capsule; \\
    jal validate           # if it is colliding with something, \\
    move $s0, $v0          # we cannot spawn it, meaning the player has \\ 
    lw $a0, CAPSULE_P1     # flooded the bottle; the game is lost
    jal validate
    move $s1, $v0
    and $s0, $s0, $s1      # can only spawn if neither validation fails
    beq $s0, 0, load_capsule_exit

    li $s7, 1              # if we reach this point, the position is valid, \\
                           # and capsule generation has succeeded
    
    lb $t0, NEXT_E1        # load preview capsule data into player capsule
    sb $t0, CAPSULE_E1
    lb $t0, NEXT_E2
    sb $t0, CAPSULE_E2
    
  load_capsule_exit:
    move $v0, $s7          # shift the return value into the correct register
    pop ($ra)              # retrieve the return address stored on \\
    jr $ra                 # the stack, and return to the caller

##############################################################################
# Main Game Loop Functions
##############################################################################

## The main game loop. This runs indefinitely once the game state
## is initialized by the main function.
# This function takes no arguments.
game_loop:
    lw $t0, DELTA_CAP_DEFAULT   # set the sleep time to the default amount; \\
    sw $t0, DELTA_CAP           # this may be modified on downward key press
  
    jal keyboard_input          # check for user input (keypresses / keyholds)
    
  after_keyboard_input:
    li $v0, 30
    syscall                 # load system time into ($a1, $a0)
    move $t1, $a0           # determine current timestamp
    lw $t2, TIMESTAMP       # determine previous timestamp
    
    lw $t0, DELTA
    subu $t3, $t1, $t2      # compute time elapsed
    add $t0, $t0, $t3       # add time elapsed to delta
    sw $t0, DELTA           # update delta
    sw $t1, TIMESTAMP       # update timestamp
    
    lw $t5, DELTA_CAP
    blt $t0, $t5, after_gravity   # if delta < delta_cap, continue; \\
    sub $t0, $t0, $t5             # otherwise, decrease delta by \\
                                  # its upper limit DELTA_CAP \\
    sw $t0, DELTA                 # update this reduced delta value
    li $a0, 0x1
    jal displace                  # displace the capsule y-pos by 1

    beq $v0, 1, after_gravity     # if no collision occurred, return to \\
                                  # business as usual; otherwise...
                                  
    jal play_place_sound

    lw $a0, CAPSULE_P1            # commit the contents of the capsule \\
    lb $a1, CAPSULE_E1            # to the BOTTLE array
    jal commit_to_bottle
    
    lw $a0, CAPSULE_P2
    lb $a1, CAPSULE_E2
    jal commit_to_bottle
    
    jal process_cascade           # Process cascading matches and gravity
    
    lw $t0, VIRUS_COUNT
    beq $t0, 0, exit        # if there are no more viruses, the game is won

    jal load_next_capsule   # load next capsule from preview
    beq $v0, 0, exit        # if the capsule fails to generate, it is game over
    jal gen_preview_capsule # create a new preview capsule if the game continues
    
  after_gravity:
    jal update_music
    jal draw                # draw the frame after all events are handled
    
    li $v0, 32
    lw, $a0, SLEEP_TIME   # set the amount of time to sleep
    srl $a0, $a0, 1 
    syscall               # sleep until the next frame     

    j game_loop           # return to the beginning of the loop

## Handle keyboard input. Will verify that input is recieved, and 
## otherwise do nothing.
# This function takes in no arguments.
keyboard_input:
    push ($ra)                      # save the return address
    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # load first word from keyboard
    lw $t1, 4($t0)                  # load the key pressed
    lw $t2, ADDR_KBRD_HOLD          # the start of keypress array

    # We use keypresses for triggers that the player will likely \\
    # only want to do once, and require more precision, such as such \\
    # as quit, pause, and rotate. These will be registered even if the \\
    # player is not pressing at the moment of the check due to queuing,
    # so we must also check that the key is actively being held. \\
    # Furthermore, there is a delay between the first press and the \\
    # repeating presses triggered afterwards by holding the key, making \
    # this resolution suboptimal for events the player will want to \\
    # trigger more than once in succession, such as downwards acceleration. \\
    # For these, we use keyhold triggers instead of keypress triggers.

    beq $t8, 0, keyhold_check            # if keypress is not triggered, \\
                                         # check only for keyhold signals
    # keyhold is always triggered when keypress is triggered but the converse \\
    # need not be true; to ensure that user input is only handled when the \\
    # input is actively being provided (so that buffering does not occur due \\
    # to queuing of keypresses), we require that keypress AND keyhold are triggered.
    # why even check for keypress then? because keypress will have a buffer time \\
    # between the first trigger and successive triggers. try pressing and holding \\
    # `a` in a textbox to see what this is referring to!
    addi $t3, $t2, 0x71
    lb $t3, 0($t3)                       # check that q is held
    seq $t4, $t1, 0x71                   # check that q is pressed
    and $t5, $t3, $t4                    # 1 if both conditions hold
    beq $t5, 1, exit                  # exit if q was pressed
    
    addi $t3, $t2, 0x70
    lb $t3, 0($t3)                       # check that p is held
    seq $t4, $t1, 0x70                   # check that p is pressed
    and $t5, $t3, $t4                    # 1 if both conditions hold
    beq $t5, 1, trig_pause            # pause if p was pressed

    addi $t3, $t2, 0x77
    lb $t3, 0($t3)                       # check that w is held
    seq $t4, $t1, 0x77                   # check that w is pressed
    and $t5, $t3, $t4                    # 1 if both conditions hold
    beq $t5, 1, trig_rotate           # rotate CCW if w was pressed

    addi $t3, $t2, 0x61
    lb $t3, 0($t3)                       # check that a is held
    seq $t4, $t1, 0x61                   # check that a is pressed
    and $t5, $t3, $t4                    # 1 if both conditions hold
    beq $t5, 1, trig_move_left        # move left if a was pressed

    addi $t3, $t2, 0x64
    lb $t3, 0($t3)                       # check that d is held
    seq $t4, $t1, 0x64                   # check that d is pressed
    and $t5, $t3, $t4                    # 1 if both conditions hold
    beq $t5, 1, trig_move_right       # move right if d was pressed

  keyhold_check:                         # even if ADDR_KBRD doesn't signal \\
    addi $t3, $t2, 0x73                  # sequence may have started: check \\
    lb $t3, 0($t3)                       # and handle this possibility.
    beq $t3, 1, trig_accel_down          # accelerate down if s was pressed

    j keyboard_input_exit                # if key is unrecognized, ignore it

  trig_rotate:                           # rotate the player controlled pill CCw
    jal rotate_capsule
    j keyboard_input_exit
  trig_move_left:                        # shift the player controlled pill left one tile
    li $a0, -0x00010000
    jal displace    
    j keyboard_input_exit
  trig_move_right:                       # shift the player controlled pill right one tile
    li $a0, 0x00010000
    jal displace
    j keyboard_input_exit
  trig_accel_down:                       # accelerate downwards fall
    lw $t1, DELTA_CAP                    # load previous delta capacity
    lw $t0, DELTA_CAP_ACCEL              # load delta value capacity when accelerating
    beq $t0, $t1, keyboard_input_exit    # if these two values are not already equal \\
                                         # this is the start of the faster fall;
    sw $t0, DELTA_CAP                    # set delta value capacity to the accelerated val
    sw $t0, DELTA                        # set the delta value to the capacity to immediately fall

    j keyboard_input_exit
  trig_pause:                            # pause the game if running, or start it if paused
    jal pause_menu
    j keyboard_input_exit
  keyboard_input_exit:
    pop ($ra)                       # retrieve return address from the stack
    jr $ra                          # return to caller

## Rotate the player capsule if possible. If a collision
## occurs during the rotation, return to original position.
# Takes in no parameter.
rotate_capsule:
    push ($ra)                      # store return address on stack
  
    lw $t0, CAPSULE_P1              # load capsule information
    lw $t1, CAPSULE_P2
    andi $t2, $t0, 0xffff           # extract the y components of each \\
    andi $t3, $t1, 0xffff           # player-controlled capsule half
    lb $t5, CAPSULE_E1
    lb $t6, CAPSULE_E2

    beq $t2, $t3, rotate_horizontal # if y1 == y2, then capsule is horizontal; \\
    addi $s1, $t0, 0x10000          # otherwise, we must have x1 == x2, so \\
    addi $s0, $t1, 0x1              # that the capsule is vertical
    andi $s3, $t5, 0b00001111       # wipe entity direction information
    ori $s3, $s3, 0b00010000        # replace with right
    andi $s2, $t6, 0b00001111       # do the same for the other half capsule
    ori $s2, $s2, 0b00000000        # replace with left
    j validate_rotation             # perform the appropriate transformations \\
  rotate_horizontal:                # to achieve the desired rotation
    move $s0, $t0
    addi $s1, $t1, -0x10001
    andi $s2, $t5, 0b00001111       # wipe entity direction information
    ori $s2, $s2, 0b00110000        # replace with bottom
    andi $s3, $t6, 0b00001111       # do the same for the other half capsule
    ori $s3, $s3, 0b00100000        # replace with top
  validate_rotation:
    move $a0, $s0                   # check that the positions of \\
    jal validate                    # both capsule halves are valid; \\
    move $s6, $v0                   # if they are, commit the changes \\
    move $a0, $s1                   # to the player capsule
    jal validate
    move $s7, $v0

    and $t4, $s6, $s7               # 1 if both positions are safe
    li $v0, 0                       # set the default return value to 0
    beq $t4, 0, rotate_capsule_exit # exit if new position is invalid

    sw $s0, CAPSULE_P1              # otherwise, commit the changes
    sw $s1, CAPSULE_P2
    sb $s2, CAPSULE_E1              # as entity direction data has been changed, \\
    sb $s3, CAPSULE_E2              # update also the entity bytes for each half
    
    jal play_rotate_sound
    
  rotate_capsule_exit:
    pop ($ra)                       # retrieve return address from stack
    jr $ra


## Apply the pause menu view to the display. This is maintained
## until the 'p' key is pressed to unpause.
# This function takes in no arguments.
pause_menu:
    push ($ra)
    
    lw $a0, ADDR_DSPL         # copy the current display contents to \\
    la $a1, SCREEN_BACKUP     # a safe space prior to transformation
    li $a2, 229376            # DISPLAY_WIDTH * DISPLAY_HEIGHT * 4
    jal memcpy

    la $a0, SCREEN_BACKUP     # copy the saved display pixels to a space \\
    la $a1, SCREEN_DESAT      # where they can then be transformed
    li $a2, 229376            # DISPLAY_WIDTH * DISPLAY_HEIGHT * 4
    jal memcpy

    li $s0, 0                 # set a loop variable
    li $s1, 57344             # DISPLAY_WIDTH * DISPLAY_HEIGHT
    la $s2, SCREEN_DESAT      # load the memory to be transformed
  pause_desaturate_loop:
    bge $s0, $s1, pause_desaturate_loop_exit

    move $a0, $s2
    jal desaturate_px         # desaturate the pixel at the given location
    
    addi $s0, $s0, 1
    addi $s2, $s2, 4
    j pause_desaturate_loop
  pause_desaturate_loop_exit: # once we are done, every pixel is desaturated

    # attach the paused indicator on the desaturated screen
    la $a0, PAUSED_IMG        # source pixel array
    li $a1, 16                # height 2 tiles x 8 pixels per tile
    li $a2, 40                # width 5 tiles x 8 pixels per tile
    lw $a3, PAUSE_OFFSET      # top left corner to draw from
    lw $t0, DISPLAY_WIDTH     # width of target
    push ($t0)
    la $t0, SCREEN_DESAT      # target pixel array
    push ($t0)
    jal draw_region
    
    la $a0, SCREEN_DESAT      # move the transformed pixel screen to the \\
    lw $a1, ADDR_DSPL         # display's location in memory
    li $a2, 229376            # DISPLAY_WIDTH * DISPLAY_HEIGHT * 4
    jal memcpy

  pause_loop:
    li $v0, 32                # sleep for a frame
    lw $a0, SLEEP_TIME
    syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t1, 0($t0)                  # load first word from keyboard
    lw $t2, 4($t0)                  # load the key pressed
    seq $t4, $t1, 1                 # check that a key is pressed
    seq $t5, $t2, 0x70              # check that p is pressed
    and $t5, $t4, $t5               # 1 if both conditions hold, in \\
    beq $t5, 1, unpause          # which case we unpause

    j pause_loop
  unpause:
    li $v0, 30
    syscall                   # load system time into ($a1, $a0)
    sw $a0, TIMESTAMP         # determine current timestamp; this is to \\
                              # avoid drastic increments on DELTA over the \\
                              # time the game is paused

    la $a0, SCREEN_BACKUP     # restore the original display, as was before \\
    lw $a1, ADDR_DSPL         # modifications by the paused menu
    li $a2, 229376            # DISPLAY_WIDTH * DISPLAY_HEIGHT * 4
    jal memcpy

    pop ($ra)
    jr $ra

##############################################################################
# Physics Functions
##############################################################################

## Validate the position of a given entity. This function checks that
## the entity does not collide with any entity currently in the
## BOTTLE array, and verifies that it does not fall outside the bounds
## of the bottle grid.
# This function operates only on $t registers.
# Takes in the following parameters:
# - $a0 : the position, in tile coordinates, to check for a collision;
#          this should be in format (x, y) = ($a0[31:16], $a0[15:0]) 
# and returns:
# - $v0 : whether a collision occurs; 1 if there is no collision;
#         0 if there is a collision
validate: 
    # check that the entity is in bounds
    lw $t0, BOTTLE_WIDTH        # load in the bottle grid dimensions
    lw $t1, BOTTLE_HEIGHT
    li $t2, -1                  # used for bounding coordinates below
    andi $t3, $a0, 0xffff0000   # extract x and y information from \\
    srl $t3, $t3, 16            # the provided argument, in that order
    andi $t4, $a0, 0x0000ffff
    
    slt $t5, $t2, $t3           # check that x > -1
    slt $t7, $t3, $t0           # check that x < BOTTLE_WIDTH
    and $t5, $t5, $t7           # 1 if both conditions hold

    slt $t6, $t2, $t4           # check that y > -1 (unnecessary)
    slt $t7, $t4, $t1           # check that y < BOTTLE_HEIGHT
    and $t6, $t6, $t7           # 1 if both conditions hold

    and $v0, $t5, $t6           # 1 if all conditions hold; otherwise \\
    beq $v0, 0, validate_exit   # return with 0
    
    # check that the position is not occupied
    mult $t0, $t4               # compute the index of this entity in \\
    mflo $t8                    # the BOTTLE array; as each entry is \\
    add $t8, $t8, $t3           # 1 byte, this is y * WIDTH + x
    la $t9, BOTTLE
    add $t9, $t9, $t8
    lb $t9, 0($t9)              # this is the entry at position (x, y)

    beq $t9, 0, validate_exit   # $v0 is currently 1, so return 1 \\
    li $v0, 0                   # if entry is nonzero; else return 0
    
  validate_exit:
    jr $ra

## Apply an input displacement to the player capsule, and return
## whether the change in position was successful.
# Takes in the following parameter:
# - $a0 : the displacement to apply to the player capsule.
# Returns:
# - $v0 : whether the player capsule has been moved down; 1 if there
#         was no collision, and 0 otherwise
displace:
    push ($ra)                      # store the return address on the stack

    lw $t0, CAPSULE_P1              # load capsule information
    lw $t1, CAPSULE_P2
    add $s0, $t0, $a0               # shift the capsule halves' positions \\
    add $s1, $t1, $a0               # by the input amount

    move $a0, $s0                   # check that the positions of \\
    jal validate                    # both capsule halves are valid; \\
    move $s2, $v0                   # if they are, commit the changes \\
    move $a0, $s1                   # to the player capsule
    jal validate
    move $s3, $v0

    and $t4, $s2, $s3               # 1 if both positions are safe
    li $v0, 0                       # set the default return value to 0
    beq $t4, 0, displace_exit       # exit if new position is invalid

    sw $s0, CAPSULE_P1              # otherwise, commit the changes \\
    sw $s1, CAPSULE_P2              # and return 1
    li $v0, 1
  displace_exit:
    pop ($ra)                       # load the return address from the stack
    jr $ra

## Apply an input displacement to the target entity, and return
## whether the change in position was successful. This function resembles
## displace, but does not operate on the requirement that more than one 
## entity (two capsule halves) must be validated prior to moving either.
# Takes in the following parameters:
# - $a0 : the address of the entity position to check for modification
# - $a1 : the displacement to apply to the player capsule.
# Returns:
# - $v0 : whether the player capsule has been moved down; 1 if there
#         was no collision, and 0 otherwise
displace_solo:
    push ($ra)                   # store the return address on the stack

    move $s0, $a0
    lw $s1, 0($s0)
    add $s1, $s1, $a1            # apply displacement to the entity

    move $a0, $s1                # check that the positions of the \\
    jal validate                 # etnity is valid; if it is, commit \\
    move $s2, $v0                # the changes to the provided location \\

    li $v0, 0                         # set default return value to 0
    beq $s2, 0, displace_solo_exit    # exit if the new position is invalid
    
    sw $s1, 0($s0)               # otherwise, commit the changes and \\
    li $v0, 1                    # return 1
  displace_solo_exit:
    pop ($ra)                    # load the return address from the stack
    jr $ra

## Handles the cascade effect - checking for matches, applying gravity,
## and repeating until no more matches are found.
process_cascade:
     push ($ra)                 # store the return address on the stack
     
   cascade_loop:
     # Check for matches and clear them
     jal check_matches
     beq $v0, $zero, cascade_exit   # If no matches found, we're done
     
     # Draw the updated state (to show matches being cleared)
     jal draw
     
     # Sleep briefly to make the clearing visible
     li $v0, 32
     li $a0, 300            # Sleep for 300ms
     syscall
     
     # Apply gravity to make pieces fall
     jal apply_gravity
     
     # Draw the updated state (to show pieces falling)
     jal draw
     
     # Sleep briefly to make the falling visible
     li $v0, 32
     li $a0, 300            # Sleep for 300ms
     syscall
     
     # Repeat until no more matches are found
     j cascade_loop
     
   cascade_exit:
     pop ($ra)               # restore return address
     jr $ra                  # Return to caller
     
## Checks for horizontal and vertical matches of 4+ of the same color
# Returns:
# - $v0 : 1 if matches were found and cleared, 0 otherwise
check_matches:
     push ($ra)              # save return address
     
     # Initialize return value to 0 (no matches found yet)
     li $v0, 0
     
     # Check for horizontal matches
     li $t0, 0               # Row counter (y)
     lw $t1, BOTTLE_HEIGHT   # Load bottle height for loop bound
     
 check_horiz_loop_y:
     bge $t0, $t1, check_horiz_done   # If y >= BOTTLE_HEIGHT, exit horizontal check
     
     li $t2, 0               # Column counter (x)
     lw $t3, BOTTLE_WIDTH
     addi $t3, $t3, -3       # Only need to check up to (width-3)
     
 check_horiz_loop_x:
     bgt $t2, $t3, check_horiz_next_y    # If x > (width-3), move to next row
     
     # Calculate position in bottle: (y * width + x)
     la $t4, BOTTLE          # Base address of bottle
     lw $t5, BOTTLE_WIDTH
     mult $t0, $t5           # y * width
     mflo $t5
     add $t5, $t5, $t2       # y * width + x
     add $t4, $t4, $t5       # Address of current position
     
     # Load the entity at current position
     lb $t5, 0($t4)
     
     # Skip if empty
     beq $t5, $zero, check_horiz_next_x
     
     # Extract color bits (bits 1-3)
     andi $t6, $t5, 0x0E
     
     # Check next 3 positions for same color
     lb $t7, 1($t4)          # Load entity at x+1
     beq $t7, $zero, check_horiz_next_x  # Skip if empty
     andi $t8, $t7, 0x0E     # Get color
     bne $t8, $t6, check_horiz_next_x  # Skip if color doesn't match
     
     lb $t7, 2($t4)          # Load entity at x+2
     beq $t7, $zero, check_horiz_next_x  # Skip if empty
     andi $t8, $t7, 0x0E     # Get color
     bne $t8, $t6, check_horiz_next_x  # Skip if color doesn't match
     
     lb $t7, 3($t4)          # Load entity at x+3
     beq $t7, $zero, check_horiz_next_x  # Skip if empty
     andi $t8, $t7, 0x0E     # Get color
     bne $t8, $t6, check_horiz_next_x  # Skip if color doesn't match
     
     # We found a match! Set return value to 1
     li $v0, 1
     
     # Check and update virus count if any are viruses
     lb $t7, 0($t4)
     andi $t8, $t7, 0x01     # Type bit (0=virus, 1=capsule)
     bne $t8, $zero, skip_h_virus1  # Skip if it's a capsule
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1       # Decrement virus count
     sw $t9, VIRUS_COUNT
 skip_h_virus1:
     
     lb $t7, 1($t4)
     andi $t8, $t7, 0x01
     bne $t8, $zero, skip_h_virus2
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_h_virus2:
     
     lb $t7, 2($t4)
     andi $t8, $t7, 0x01
     bne $t8, $zero, skip_h_virus3
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_h_virus3:
     
     lb $t7, 3($t4)
     andi $t8, $t7, 0x01
     bne $t8, $zero, skip_h_virus4
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_h_virus4:
     
     # Now clear the 4 matched entities
     sb $zero, 0($t4)
     sb $zero, 1($t4)
     sb $zero, 2($t4)
     sb $zero, 3($t4)
     
 check_horiz_next_x:
     addi $t2, $t2, 1        # Next column
     j check_horiz_loop_x
     
 check_horiz_next_y:
     addi $t0, $t0, 1        # Next row
     j check_horiz_loop_y
     
 check_horiz_done:
     # Now check for vertical matches
     li $t2, 0               # Column counter (x)
     lw $t3, BOTTLE_WIDTH
     
 check_vert_loop_x:
     bge $t2, $t3, check_vert_done   # If x >= BOTTLE_WIDTH, exit vertical check
     
     li $t0, 0               # Row counter (y)
     lw $t1, BOTTLE_HEIGHT
     addi $t1, $t1, -3       # Only need to check up to (height-3)
     
 check_vert_loop_y:
     bgt $t0, $t1, check_vert_next_x   # If y > (height-3), move to next column
     
     # Calculate position: (y * width + x)
     la $t4, BOTTLE
     lw $t5, BOTTLE_WIDTH
     mult $t0, $t5
     mflo $t5
     add $t5, $t5, $t2
     add $t4, $t4, $t5       # Address of current position
     
     # Load entity at current position
     lb $t5, 0($t4)
     
     # Skip if empty
     beq $t5, $zero, check_vert_next_y
     
     # Extract color
     andi $t6, $t5, 0x0E
     
     # Check next 3 positions below for same color
     lw $t9, BOTTLE_WIDTH
     
     add $t7, $t4, $t9       # Address of (x, y+1)
     lb $t8, 0($t7)
     beq $t8, $zero, check_vert_next_y  # Skip if empty
     andi $t8, $t8, 0x0E
     bne $t8, $t6, check_vert_next_y    # Skip if color doesn't match
     
     add $t7, $t7, $t9       # Address of (x, y+2)
     lb $t8, 0($t7)
     beq $t8, $zero, check_vert_next_y  # Skip if empty
     andi $t8, $t8, 0x0E
     bne $t8, $t6, check_vert_next_y    # Skip if color doesn't match
     
     add $t7, $t7, $t9       # Address of (x, y+3)
     lb $t8, 0($t7)
     beq $t8, $zero, check_vert_next_y  # Skip if empty
     andi $t8, $t8, 0x0E
     bne $t8, $t6, check_vert_next_y    # Skip if color doesn't match
     
     # We found a match! Set return value to 1
     li $v0, 1
     
     jal play_clear_sound
     
     # Check and update virus count if any are viruses
     lb $t7, 0($t4)
     andi $t8, $t7, 0x01     # Type bit (0=virus, 1=capsule)
     bne $t8, $zero, skip_v_virus1  # Skip if it's a capsule
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1       # Decrement virus count
     sw $t9, VIRUS_COUNT
 skip_v_virus1:
     
     lw $t9, BOTTLE_WIDTH
     add $t7, $t4, $t9       # Address of (x, y+1)
     lb $t8, 0($t7)
     andi $t8, $t8, 0x01
     bne $t8, $zero, skip_v_virus2
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_v_virus2:
     
     lw $t9, BOTTLE_WIDTH
     add $t7, $t4, $t9       # (x, y+1)
     add $t7, $t7, $t9       # (x, y+2)
     lb $t8, 0($t7)
     andi $t8, $t8, 0x01
     bne $t8, $zero, skip_v_virus3
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_v_virus3:
     
     lw $t9, BOTTLE_WIDTH
     add $t7, $t4, $t9       # (x, y+1)
     add $t7, $t7, $t9       # (x, y+2)
     add $t7, $t7, $t9       # (x, y+3)
     lb $t8, 0($t7)
     andi $t8, $t8, 0x01
     bne $t8, $zero, skip_v_virus4
     lw $t9, VIRUS_COUNT
     addi $t9, $t9, -1
     sw $t9, VIRUS_COUNT
 skip_v_virus4:
     
     # Now clear the 4 matched entities
     sb $zero, 0($t4)
     
     lw $t9, BOTTLE_WIDTH
     add $t7, $t4, $t9       # (x, y+1)
     sb $zero, 0($t7)
     
     add $t7, $t7, $t9       # (x, y+2)
     sb $zero, 0($t7)
     
     add $t7, $t7, $t9       # (x, y+3)
     sb $zero, 0($t7)
     
 check_vert_next_y:
     addi $t0, $t0, 1        # Next row
     j check_vert_loop_y
     
 check_vert_next_x:
     addi $t2, $t2, 1        # Next column
     j check_vert_loop_x
     
 check_vert_done:
     # Finished checking, return to caller
     pop ($ra)               # restore return address from stack
     jr $ra                  # Return to caller
     # apply_gravity function

## Makes floating capsules fall until they hit an obstacle.
# Returns:
# - $v0: 1 if any capsules fell, 0 otherwise
apply_gravity:
     push ($ra)              # save return address on stack
     
     li $v0, 0               # Default: nothing fell
     
     # We'll need multiple passes through the grid to ensure all pieces fall fully
     li $t9, 1               # Set flag to indicate we need to keep checking
     
 gravity_outer_loop:
     beq $t9, $zero, gravity_exit  # If no pieces fell in the last pass, we're done
     
     li $t9, 0               # Reset the flag for this pass
     
     # Start from second-to-last row (bottom row can't fall further)
     lw $t0, BOTTLE_HEIGHT   
     addi $t0, $t0, -2       # Start at height-2
     
 gravity_row_loop:
     bltz $t0, gravity_outer_loop  # If we've gone through all rows, start a new pass
     
     li $t1, 0               # Column counter
     lw $t2, BOTTLE_WIDTH    
     
 gravity_col_loop:
     bge $t1, $t2, gravity_next_row  # If done with this row, go to next row up
     
     # Calculate position: BOTTLE + (y * width + x)
     la $t3, BOTTLE
     lw $t4, BOTTLE_WIDTH
     mult $t0, $t4
     mflo $t4
     add $t4, $t4, $t1
     add $t3, $t3, $t4       # Current position address
     
     # Load entity at current position
     lb $t4, 0($t3)
     
     # Skip if empty
     beq $t4, $zero, gravity_next_col
     
     # Check if it's a capsule (not a virus)
     andi $t5, $t4, 0x01     # Type bit (0=virus, 1=capsule)
     beq $t5, $zero, gravity_next_col  # Skip if it's a virus (viruses don't fall)
     
     # Check if the space below is empty
     lw $t6, BOTTLE_WIDTH
     add $t7, $t3, $t6       # Address of position below
     lb $t8, 0($t7)          # Entity below
     bne $t8, $zero, gravity_next_col  # Skip if space below is not empty
     
     # Space below is empty, make this capsule part fall
     sb $t4, 0($t7)          # Copy entity to position below
     sb $zero, 0($t3)        # Clear current position
     li $v0, 1               # Set return value to indicate something fell
     li $t9, 1               # Set flag to indicate we need another pass
     
 gravity_next_col:
     addi $t1, $t1, 1        # Next column
     j gravity_col_loop
     
 gravity_next_row:
     addi $t0, $t0, -1       # Move up one row (decreasing y)
     j gravity_row_loop
     
 gravity_exit:
     pop ($ra)               # restore return address
     jr $ra                  # Return to caller

##############################################################################
# Display Functions
##############################################################################

## Given the input pixel, returns a desaturated version of the pixel.
## This does not return anything, but mutates the pixel at the given address.
# This function modifies only $t registers.
# This function recieves the following argument:
# - $a0 : the address of the first byte of the 4-byte pixel; the 
#         pixel should be in form RRGGBBAA, where AA is ignored
desaturate_px:
    lb $t0, 0($a0)       # $t0 = red value
    andi $t0, $t0, 0xff  # we must ignore anything but the last byte
    lb $t1, 1($a0)       # $t1 = green value
    andi $t1, $t1, 0xff
    lb $t2, 2($a0)       # $t2 = blue value
    andi $t2, $t2, 0xff

    add $t3, $t0, $t1  # our greyscale value is
    add $t3, $t3, $t2  # $t3 = i = (R + G + B) / 3
    li $t4, 3
    div $t3, $t4
    mflo $t3

    sub $t4, $t3, $t0  # $t4 = dr = i - R
    sub $t5, $t3, $t1  # $t5 = dg = i - G
    sub $t6, $t3, $t2  # $t6 = db = i - B

    sra $t4, $t4, 1    # dilate the change in colour to half \\
    sra $t5, $t5, 1    # of its current value, to avoid going \\
    sra $t6, $t6, 1    # completely greyscale

    add $t0, $t0, $t4  # update red, green, and blue \\
    add $t1, $t1, $t5  # values by changes in colour \\
    add $t2, $t2, $t6  # dr, dg, and db

    sb $t0, 0($a0)     # save these changed colours at \\
    sb $t1, 1($a0)     # the original address
    sb $t2, 2($a0)
    
    jr $ra

## Draw a the current state of the game, including the backdrop,
## all sprites / indicators, and the contents of the bottle. If
## CAPSULE_P1 is -1, this function does not draw the current capsule
## controlled by the player.
## This function only modifies $t registers.
draw:
    push ($ra)               # save return address, as it will be overwritten in future calls
    
    # TODO: draw the doctor (only necessary if we choose to animate)

    jal draw_scoreboard       # display the current player score
    jal draw_preview          # display the preview for the next capsule
    jal draw_bottle           # display the contents of the bottle grid

  draw_return:
    pop ($ra)               # reload the return address from the stack
    jr $ra                  # return to the caller

## Draw the game backdrop, including the bottle graphics and other statics.
# Takes in no arguments.
draw_backdrop:
    push ($ra)               # store return address on stack
  
    la $a0, BACKDROP         # draw the backdrop
    lw $a1, DISPLAY_HEIGHT   # backdrop takes up the entire display
    lw $a2, DISPLAY_WIDTH    # the backdrop begins at the top-left \\
    li $a3, 0x0              # of the display

    lw $t0, DISPLAY_WIDTH    # the width of the draw region is DISPLAY_WIDTH
    push ($t0)
    lw $t0, ADDR_DSPL        # draw directly on the display
    push ($t0)
    jal draw_region

    pop ($ra)                # retrieve return address from stack
    jr $ra

## Populates the SCORE_DISPL_BUF with the digits of the player score,
## then draws the contents of SCORE_DISPL_BUF into the actual display.
# Takes in no arguments.
draw_scoreboard:
    push ($ra)              # save the return address on the stack
  
    lw $s0, TILE_SIZE       # determine the number of pixels occupied by a digit \\
    mult $s0, $s0           # (ie viruses and capsules); as each pixel occupies 4 bytes, \\
    mflo $s0                # $s2 = array size = TILE_SIZE * ( 2 * TILE_SIZE ) * 4,
    sll $s0, $s0, 3         # because a digit is 1 x 2 tiles
    
    la $a0, SCOREBOARD      # reset the scoreboard display buffer prior to decorating \\
    la $a1, SCORE_DISPL_BUF # it with the constituent digits of the player score
    sll $a2, $s0, 2         # DIGIT_SIZE * 4
    jal memcpy

    la $s7, DIGITS          # load the address of the pixel array we read from
    lw $s1, SCORE           # begin parsing the player score
    li $s2, 3               # set loop variable $s2 = i to iterate in [0, 3]
    li $s3, 10              # we will be dividing by 10 frequently
  draw_scoreboard_loop:
    blt $s2, $zero, draw_scoreboard_loop_exit  # terminate when $s2 < 0

    div $s1, $s3
    mfhi $s4                # set $s4 = digit to be remainder of score / 10
    mflo $s1                # set new score to be the quotient of score / 10

    lw $t0, TILE_SIZE

    mult $s0, $s4           # digit position in DIGITS is digit * digit size
    mflo $a0                # we computed digit size as $s0 above
    add $a0, $s7, $a0       # add this to the address of the buffer
    sll $a1, $t0, 1         # a digit has twice the height of a tile
    move $a2, $t0           # a digit has the width of a tile

    # only the x-coordinate is variable; y is fixed as 0 for offset
    mult $t0, $s2           # the offset of this drawing is determined by our
    mflo $a3                # loop variable; it is i * TILE_SIZE for the x-coord
    sll $a3, $a3, 16        # shift so that x coordinat is in upper half
                            # of the byte to follow expected formatting

    sll $t1, $t0, 2         # width of buffer is 4 times width of tile
    push ($t1)
    la $t1, SCORE_DISPL_BUF
    push ($t1)

    jal draw_region
    
    addi $s2, $s2, -1
    j draw_scoreboard_loop
  draw_scoreboard_loop_exit:
    la $a0, SCORE_DISPL_BUF
    lw $a1, TILE_SIZE
    sll $a1, $a1, 1
    lw $a2, TILE_SIZE
    sll $a2, $a2, 2
    lw $a3, SCORE_OFFSET
    lw $t0, DISPLAY_WIDTH
    push ($t0)
    lw $t0, ADDR_DSPL
    push ($t0)
    jal draw_region

    pop ($ra)               # retrieve the return address from the stack
    jr $ra

## Populates the BOTTLE_DSPL_BUF with the contents of the bottle, then
## draws the contents of BOTTLE_DSPL_BUF into the actual display.
# Takes in no arguments.
draw_bottle:
    push ($ra)                # store return address on the stack

    la $a0, BOTTLE_GRID_IMG # reset the bottle display buffer prior to decorating it \\
    la $a1, BOTTLE_DSPL_BUF # with the player capsule and the grid entities
    li $a2, 32768           # TILE_SIZE^2 * BOTTLE_HEIGHT * BOTTLE_WIDTH * 4
    jal memcpy
    
    la $t0, BOTTLE          # we begin drawing the bottle's contents
    li $t1, 0               # introduce a loop variable y = $t1
    lw $t2, BOTTLE_HEIGHT   # y is bound above by the bottle height
  buf_bottle_loop_y:
    beq $t1, $t2, buf_bottle_loop_y_end   # terminate the loop once we read all rows
    
    li $t3, 0               # introduce a loop variable x = $t3
    lw $t4, BOTTLE_WIDTH    # x is bound above by the bottle width
  buf_bottle_loop_x:
    beq $t3, $t4, buf_bottle_loop_x_end   # terminate the loop once we read this row

    lw $t6, BOTTLE_WIDTH    # load information about (x, y) from the bottle;
    mult $t6, $t1           # (x, y) information is stored at BOTTLE[x + y * BOTTLE_WIDTH] \\
    mflo $t6                # because each entry occupies one byte
    add $t6, $t6, $t3
    add $t6, $t6, $t0
    lb $t5, 0($t6)
    
    beq $t5, 0, buf_bottle_sprite_end   # if there is nothing at this entry, \\
                                        # skip to the next position
    
    push ($t0)              # save the current state of each register on the stack: \\
    push ($t1)              # there is no guarantee that registers will not change \\
    push ($t2)              # during the draw_entity function call
    push ($t3)
    push ($t4)

    move $t6, $t3           # our tile coordinate is (x, y) = ($t3, $t1); format \\
    sll $t6, $t6, 16        # this so that it can be fed into draw_entity
    add $t6, $t6, $t1

    move $a0, $t5
    move $a1, $t6
    jal draw_entity
    
    pop ($t4)              # load the state of each register prior to the function \\
    pop ($t3)              # call from the stack, so that we can be sure our data
    pop ($t2)              # is not modified
    pop ($t1)
    pop ($t0)

  buf_bottle_sprite_end:
    addi $t3, $t3, 1        # increment the loop variable
    j buf_bottle_loop_x
  buf_bottle_loop_x_end:
    addi $t1, $t1, 1        # increment the loop variable
    j buf_bottle_loop_y
  buf_bottle_loop_y_end:

    lw $t0, CAPSULE_P1        # load information about the first half \\
    lb $t2, CAPSULE_E1        # of the player-controlled capsule
    
    beq $t0, -1, draw_return  # if first argument is -1, do not draw \\
                              # the player capsule
    
    move $a0, $t2             # draw the first half of the player capsule
    move $a1, $t0
    jal draw_entity

    lw $t1, CAPSULE_P2        # load information about the second half \\
    lb $t3, CAPSULE_E2        # of the player-controlled capsule

    move $a0, $t3             # draw the second half of the player capsule
    move $a1, $t1
    jal draw_entity
  
    lw $t0, TILE_SIZE
    la $a0, BOTTLE_DSPL_BUF   # address of pixel array to read from (buffer)
    lw $a1, BOTTLE_HEIGHT     # height of region; this is HEIGHT * TILE_SIZE
    mult $t0, $a1
    mflo $a1
    lw $a2, BOTTLE_WIDTH      # width of region; this is WIDTH * TILE_SIZE
    mult $t0, $a2
    mflo $a2
    lw $a3, BOTTLE_OFFSET     # top-left corner of the region to draw on
  
    lw $t1, DISPLAY_WIDTH     # draw region width is DISPLAY_WIDTH
    push ($t1)
    lw $t1, ADDR_DSPL         # draw directly on the display
    push ($t1)
    jal draw_region
  
    pop ($ra)                 # retrieve return address from stack
    jr $ra

## Given an entity byte, return the address of the first element for 
## the pixel array of corresponding to that entity byte.
# Takes in the following parameter:
# - $a0 : the entity byte for the entity to be drawn
# Returns:
# - $v0 : the address of the first element of the pixel array, of
#         size TILE_SIZE x TILE_SIZE, depicting the entity byte
find_entity_array:
                            # extract the data from the entity byte:
    andi $t7, $a0, 0x0f     # load the lower 4 bits of the entity: [colour | type]
    andi $t8, $a0, 0xf0     # load the upper 4 bits of the entity: [direction]
    srl $t8, $t8, 4         # shift the direction values into the lower 4 bits
  
    # determine the array offset (TILE_SIZE * TILE_SIZE * 4 * t8)
    lw $t9, TILE_SIZE       # determine the offset of the pixel array at which to \\
    mult $t9, $t9           # begin drawing -- this is useful for the capsule \\
    mflo $t9                # pixel arrays, which contain 5 sequences of 256 bytes \\
    sll $t9, $t9, 2         # each of which corresponds to a specific direction.
    mult $t9, $t8           # the offset is computed by
    mflo $t9                # 4(TILE_SIZE * TILE_SIZE) * direction (ie $t8)
    
    beq $t7, 0b1000, find_entity_case_blue_virus     # determine which sprite to draw; \\
    beq $t7, 0b0100, find_entity_case_green_virus    # if we do not match any case, the \\
    beq $t7, 0b0010, find_entity_case_red_virus      # data is corrupted
    beq $t7, 0b1001, find_entity_case_blue_capsule
    beq $t7, 0b0101, find_entity_case_green_capsule
    beq $t7, 0b0011, find_entity_case_red_capsule
    j find_array_end
    
  find_entity_case_blue_virus:
    la $v0, VIRUS_BLUE
    j find_array_end
  find_entity_case_green_virus:
    la $v0, VIRUS_GREEN
    j find_array_end
  find_entity_case_red_virus:
    la $v0, VIRUS_RED
    j find_array_end
  find_entity_case_blue_capsule:
    la $v0, CAP_BLUE
    add $v0, $v0, $t9
    j find_array_end
  find_entity_case_green_capsule:
    la $v0, CAP_GREEN
    add $v0, $v0, $t9
    j find_array_end
  find_entity_case_red_capsule:
    la $v0, CAP_RED
    add $v0, $v0, $t9
  find_array_end:
    jr $ra

## Draw the entity (either a capsule half or a virus) with the given
## entity byte, containing [ direction | colour | type ] information,
## on the bottle grid BUFFER (not display) at the specified location.
# Takes in the following parameters:
# - $a0 : the entity byte for the entity to be drawn
# - $a1 : the (x, y) coordinate, in terms of tiles, of the entity;
#         this should be in format (x, y) = ($a1[31:16], $a1[15:0]) 
draw_entity:
    push ($ra)              # store the return address on the stack

    move $t1, $a1
    lw $t0, TILE_SIZE       # each entry in the bottle is one tile, which has dimension \\
    mult $t1, $t0           # TILE_SIZE; thus, to determine the position in the buffer \\
    mflo $t1                # we simply compute 8(x, y)

    move $a0, $a0           # keeping this in case we migrate the code so source changes
    jal find_entity_array   # find which array we must draw pixel data from
    move $a0, $v0
    
    lw $a1, TILE_SIZE       # load arguments for draw_region
    lw $a2, TILE_SIZE
    move $a3, $t1

    lw $t0, BOTTLE_WIDTH    # set draw region width to BOTTLE_WIDTH * TILE_SIZE
    lw $t1, TILE_SIZE       # and load onto stack
    mult $t0, $t1
    mflo $t0
    push ($t0)
    la $t0, BOTTLE_DSPL_BUF # set draw_region to draw on the buffered region \\
    push ($t0)              # instead of the actual display
    jal draw_region         # call to draw the entity
    
    pop ($ra)               # retrieve the return address from the stack
    jr $ra

## Display the preview of the next capsule to be generated on the 
## play field. The entity bytes are extracted from NEXT_E1 and NEXT_E2.
# Takes in no arguments.
draw_preview:
    push ($ra)              # save return address on stack
  
    lw $a0, NEXT_E1
    jal find_entity_array   # determine what our source pixel array is
    move $a0, $v0
    
    lw $a1, TILE_SIZE       # we are drawing an entity, which occupies \\
    lw $a2, TILE_SIZE       # a single tile of dimension TILE_SIZE
    lw $a3, PREVIEW_OFFSET  # set start position of drawing region
    lw $t0, DISPLAY_WIDTH
    push ($t0)              # set width to total display width
    lw $t0, ADDR_DSPL       # draw directly on the screen
    push ($t0)
    jal draw_region

    lw $a0, NEXT_E2         # do everything again for the second half
    jal find_entity_array   # determine what our source pixel array is
    move $a0, $v0
    
    lw $a1, TILE_SIZE       # we are drawing an entity, which occupies \\
    lw $a2, TILE_SIZE       # a single tile of dimension TILE_SIZE
    lw $a3, PREVIEW_OFFSET  # set start position of drawing region \\
    sll $t0, $a2, 16        # shift TILE_SIZE to be added to x-coordinate, \\
    add $a3, $a3, $t0       # as we offset drawing by TILE_SIZE to the right
    lw $t0, DISPLAY_WIDTH
    push ($t0)              # set width to total display width
    lw $t0, ADDR_DSPL       # draw directly on the screen
    push ($t0)
    jal draw_region
    
    pop ($ra)               # retrieve return address from stack
    jr $ra

## Draw a pixel array with given width and height, positioned at a
## specified offset, to the display.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : address of pixel array to read from
# - $a1 : height of region to draw on, in pixels
# - $a2 : width of region to draw on, in pixels
# - $a3 : top-left corner of the region to draw on; this
#         should be in format (x0, y0) = ($a3[7:4], $a3[3:0]);
#         here, (x, y) is a pixel, not tile, coordinate
# - 4($sp) : the width of the region to draw on, in pixels
# - 0($sp) : the address of the region to draw on
draw_region:
    pop ($t0)                   # begin working with drawing region
    pop ($t7)                   # load drawing region width
    andi $t8, $a3, 0x0000ffff   # $t8 = y0 = $a3[15:0]
    andi $t9, $a3, 0xffff0000   # $t9 = x0 = $a3[31:16]
    srl $t9, $t9, 16
    
    li $t1, 0          # introduce a loop variable y = $t1
  draw_region_loop_y:
    bge $t1, $a1, draw_region_loop_y_end   # terminate the loop once we read all rows
    
    li $t2, 0          # introduce a loop variable x = $t2
  draw_region_loop_x:
    bge $t2, $a2, draw_region_loop_x_end   # terminate the loop once we read this row

    # compute the offset in the pixel array we read from
    mult $t1, $a2      # assume only the lower bits will be significant: this is \\
    mflo $t3           # a safe assumption to make in our context
    add $t3, $t3, $t2  # $t3 = (y * width + x) * 4
    sll $t3, $t3, 2    # multiply by 4, as each pixel occupies 4 bytes of space
    
    add $t6, $a0, $t3
    lw $t4, 0($t6)              # retrieve the pixel at the (x, y) offset position
    beq $t4, $zero, draw_non_transparent_exit   # if pixel is empty, it will be \\
                                                # rendered black, which we do not want; \\
                                                # instead, we do not draw it at all
    andi $t4, $t4, 0x00ffffff   # remove alpha-value, as it is not used
    
    add $t3, $t1, $t8           # determine pixel in the display to update
    mult $t3, $t7               # $t3 = ((y + y0) * width + (x + x0)) * 4
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

##############################################################################
# List ADT Functions
##############################################################################

# Lists are implemented as arrays where the first word stores size. Thus, it 
# takes form [ size | element 1 | element 2 | ... ]

## Fetch the number of elements in a list.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : the starting address of the target list
# Returns:
# - $v0 : the number of elements in the target list
list_size:
    lw $v0, 0($a0)        # size is stored as the first element
    jr $ra

## Fetch the element at the given index in a list. This
## function assumes the given index is valid, and will read 
## at the given index EVEN IF IT IS INVALID MEMORY.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : the starting address of the target list L
# - $a1 : the index of the element to access i; despite
#         the 0th element representing size in memory,
#         this parameter should be 0-indexed
# Returns:
# - $v0 : the value at index $a1, namely L[i]
list_at:
    li $t0, 4             # shift starting address by 4 bytes, \\
    add $a0, $a0, $t0     # so that we jump over the size word
    
    mult $a1, $t0         # compute 4 * i as the number of bytes \\
    mflo $t0              # to shift from the start of the array \\
    add $a0, $a0, $t0     # and read the target value from
    lw $v0, 0($a0)
    jr $ra

## Append an element to the end of a list.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : the starting address of the target list
# - $a1 : the element to append to the list
list_insert:
    lw $t0, 0($a0)        # load the old size 
    addi $t1, $t0, 1
    sw $t1, 0($a0)        # store size increased by 1

    li $t2, 4             # shift starting address by 4 bytes, \\
    add $a0, $a0, $t2     # so that we jump over the size word

    mult $t0, $t2         # compute 4 * size as the number of bytes \\
    mflo $t2              # to shift from the start of the array; \\
    add $a0, $a0, $t2     # then, store the new element at that \\
    sw $a1, 0($a0)        # position, so L[size] = element

    jr $ra
    

## Empty out the list. This effectively sets size to 0.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : the starting address of the target list
list_clear:
    sw $zero, 0($a0)     # reset size to 0
    jr $ra

##############################################################################
# Sound Functions
##############################################################################

## Initialize the music system
init_music:
    push ($ra)
    
    # Initialize MIDI synthesizer
    li $v0, 31
    li $a0, 0  # Instrument number (0 = piano)
    li $a1, 0  # Duration
    li $a2, 0  # instrument
    li $a3, 0  # volume
    syscall
    
    # Initialize the current note counter
    sw $zero, CURRENT_NOTE
    
    # Get initial timestamp
    li $v0, 30
    syscall
    sw $a0, LAST_NOTE_TIME
    
    pop ($ra)
    jr $ra
    
## Play a single note with the specified parameters:
# - $a0: Note pitch (0-127)
# - $a1: Duration in ms
# - $a2: Instrument (0-127)
# - $a3: Volume (0-127)
# - $t9: Async flag (0 = synchronous, 1 = asynchronous)
play_note:
    push ($ra)
    
    # Check if this is a rest (pitch = 0)
    beq $a0, $zero, play_done
    
    # Check if pitch is within valid range
    blt $a0, 1, fix_pitch_low
    bgt $a0, 127, fix_pitch_high
    j pitch_ok
    
fix_pitch_low:
    li $a0, 60  # Default to middle C if too low
    j pitch_ok
    
fix_pitch_high:
    li $a0, 127  # Cap at max MIDI note if too high
    
pitch_ok:
    # Load parameters
    move $t0, $a0  # Note pitch
    move $t1, $a1  # Duration
    move $t2, $a2  # Instrument
    move $t3, $a3  # Volume
    move $t4, $t9  # Async flag
    
    # Play the note
    beq $t4, $zero, play_sync
    
    # Play asynchronously
    li $v0, 31
    move $a0, $t0
    move $a1, $t1
    move $a2, $t2  # instrument
    move $a3, $t3  # volume
    syscall
    j play_done
    
play_sync:
    # Play synchronously
    li $v0, 33
    move $a0, $t0
    move $a1, $t1
    move $a2, $t2  # instrument
    move $a3, $t3  # volume
    syscall
    
play_done:
    pop ($ra)
    jr $ra
    
## Play sound when a capsule is placed down (collision code that Stefan wrote)
play_place_sound:
    push ($ra)
    li $v0, 31
    li $a0, 60  # C4 note
    li $a1, 150  # Duration
    li $a2, 127  # this is vo
    li $a3, 30  # change to volume 30
    syscall
    pop ($ra)
    jr $ra

## Play sound when capsule rotates on keyboard input
play_rotate_sound:
    push ($ra)
    li $v0, 31
    li $a0, 72  # C5 note
    li $a1, 50  # Duration
    li $a2, 100  # this is the instrument
    li $a3, 30  # change to volume 30
    syscall
    pop ($ra)
    jr $ra

## Play sound on cleared
play_clear_sound:
    push ($ra)
    li $v0, 31
    li $a0, 84  # C6 note
    li $a1, 300  # Duration
    li $a2, 127  # Volume
    li $a3, 30  # again, channel 30
    syscall
    pop ($ra)
    jr $ra

## Updates the background music, playing notes based on timing
update_music:
    push ($ra)
    
    # Get current time
    li $v0, 30
    syscall
    move $t0, $a0  # Current time
    
    # Load last note time
    lw $t1, LAST_NOTE_TIME
    
    # Calculate time elapsed since last check
    sub $t2, $t0, $t1
    
    # Load accumulated time
    lw $t3, TIME_ACCUMULATOR
    add $t3, $t3, $t2  # Add elapsed time to accumulator
    
    # Update last check time
    sw $t0, LAST_NOTE_TIME
    
check_play_note:
    # Load current note index and total note count
    lw $t4, CURRENT_NOTE
    lw $t5, NOTE_COUNT
    
    # Check if we've reached the end of the song
    bge $t4, $t5, reset_music
    
    # Load current note duration
    la $t6, DURATIONS
    sll $t7, $t4, 2  # Multiply by 4 (word size)
    add $t6, $t6, $t7
    lw $t8, 0($t6)  # Duration of current note
    
    # Check if enough time has passed to play next note
    blt $t3, $t8, update_music_done
    
    # Time to play the next note - reduce accumulator by note duration
    sub $t3, $t3, $t8
    
    # Get note pitch
    la $t6, NOTES
    sll $t7, $t4, 2  # Multiply by 4 (word size)
    add $t6, $t6, $t7
    lw $a0, 0($t6)  # Note pitch
    
    # Set up parameters for playing the note
    move $a1, $t8   # Duration
    li $a2, 1       # Instrument (acoustic grand)
    li $a3, 90      # Volume (slightly reduced)
    li $t9, 1       # Always play asynchronously
    
    # Save important registers before function call
    push ($t0)
    push ($t1)
    push ($t3)
    push ($t4)
    push ($t5)
    
    jal play_note
    
    # Restore registers after function call
    pop ($t5)
    pop ($t4)
    pop ($t3)
    pop ($t1)
    pop ($t0)
    
    # Increment to next note
    addi $t4, $t4, 1
    sw $t4, CURRENT_NOTE
    
    # Check if we should try to play another note immediately
    j check_play_note
    
reset_music:
    # Reset to beginning of song
    sw $zero, CURRENT_NOTE
    li $t3, 0
    
update_music_done:
    # Save accumulated time
    sw $t3, TIME_ACCUMULATOR
    
    pop ($ra)
    jr $ra