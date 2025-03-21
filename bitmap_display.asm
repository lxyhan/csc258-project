##############################################################################
# Example: Displaying Pixels
#
# This file demonstrates how to draw pixels with different colours to the
# bitmap display.
##############################################################################

######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
##############################################################################
## Bitmap Files and Arrays
##############################################################################
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
CAP_BLUE:         # capsule pixel array; each pixel is 4 bytes \\
    .space 1280   # 256 * 5 = 1280; we store the bitmap in order \\
                  # [left, right, up, down, centre]

##############################################################################
# Immutable Data
##############################################################################
BITMAP_OFFSET_IDX:  # byte at which the bitmap's offset info is found
    .word 10
TILE_SIZE:          # number of pixels that a capsule half occupies
    .word 8
DISPLAY_WIDTH:      # width of total display, in pixels
    .word 32
DISPLAY_HEIGHT:     # height of total display, in pixels
    .word 32
ADDR_DSPL:          # address of the bitmap display
    .word 0x10008000

##############################################################################
# Mutable Data
##############################################################################
GARBAGE:
    .space 32
BITMAP_OFFSET:
    .word

    .text
	.globl main

main:
    la $s0, CAP_BLUE           # load into $s so that it is untouched by load_bmp function
    
    la $a0, F_CAP_BLUE_LEFT
    move $a1, $s0
    li $a2, 256
    jal load_bmp

    add $s0, $s0, 256
    la $a0, F_CAP_BLUE_RIGHT   # unfortunately, there is no way to loop this as these are \\
    move $a1, $s0              # named; in theory, we could automate file search but this \\
    li $a2, 256                # becomes remarkably ugly very fast
    jal load_bmp

    add $s0, $s0, 256
    la $a0, F_CAP_BLUE_TOP
    move $a1, $s0
    li $a2, 256
    jal load_bmp

    add $s0, $s0, 256
    la $a0, F_CAP_BLUE_BOTTOM
    move $a1, $s0
    li $a2, 256
    jal load_bmp
    
    add $s0, $s0, 256
    la $a0, F_CAP_BLUE_CENTRE
    move $a1, $s0
    li $a2, 256
    jal load_bmp

    la $s0, CAP_BLUE
    add $s0, $s0, 1024
    move $a0, $s0
    lw $a1, TILE_SIZE
    lw $a2, TILE_SIZE
    li $a3, 0x00080004
    jal draw_region

    j exit
exit:
    li $v0, 10              # terminate the program gracefully
    syscall

## Draw a pixel array with given width and height, positioned at a
## specified offset, to the display.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : pixel array to read from
# - $a1 : height of region to draw on
# - $a2 : width of region to draw on
# - $a3 : top-left corner of the region to draw on; this
#         should be in format (x0, y0) = ($a3[7:4], $a3[3:0]);
#         here, (x, y) is a pixel, not tile, coordinate
draw_region:
    lw $t0, ADDR_DSPL           # begin working with display region
    andi $t8, $a3, 0x0000ffff   # $t8 = y0 = $a3[3:0]
    andi $t9, $a3, 0xffff0000   # $t9 = x0 = $a3[7:4]
    srl $t9, $t9, 16
    
    li $t1, 0                       # introduce a loop variable y = $t1
draw_loop_y:
    bge $t1, $a1, draw_loop_y_end   # terminate the loop once we read all rows
    
    li $t2, 0                       # introduce a loop variable x = $t2

draw_loop_x:
    bge $t2, $a2, draw_loop_x_end   # terminate the loop once we read this row

    mult $t1, $a2      # assume only the lower bits will be significant: this is \\
    mflo $t3           # a safe assumption to make in our context
    add $t3, $t3, $t2  # $t3 = (y * width + x) * 4
    sll $t3, $t3, 2    # multiply by 4, as each pixel occupies 4 bytes of space
    
    add $t6, $a0, $t3
    lw $t4, 0($t6)              # retrieve the pixel at the (x, y) offset position
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

    addi $t2, $t2, 1     # increment the loop variable
    j draw_loop_x
draw_loop_x_end:
    addi $t1, $t1, 1     # increment the loop variable
    j draw_loop_y
draw_loop_y_end:
    jr $ra               # return to the caller

## Load the pixel data of a bitmap into memory. Reads through
## input bitmap metadata to determine where to begin reading
## the pixel array, so the buffer will contain only pixel data.
## This function only modifies $t registers.
# Takes in the following parameters:
# - $a0 : name of file to be loaded
# - $a1 : address of buffer to load file contents to
# - $a2 : number of bytes to load from file into buffer
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
