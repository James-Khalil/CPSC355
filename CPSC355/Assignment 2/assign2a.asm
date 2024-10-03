// File: assign2a.asm
// Author: James Khalil
// Date: October 08, 2021
//
// Description:
// Reverse bits of variables, print orignal and reversed result in hexadecimal

print:      .string "original: 0x%08X   reversed: 0x%08X\n %d, %d"

	    .balign 4     	  		// Makes sure all instructions are divisible by 4

	    .global main			// Makes the label "main" visible to the linker
main:	    stp	x29, x30, [sp, -16]!   		// Allocate 16 bytes of memory from RAM
	    mov	x29, sp				// Update FP to the current SP

            define(x_r, w19)                    // Represents the variable x
            define(y_r, w20)                    // Rpresents the variable y
            define(t1_r, w21)                   // Represents the variable t1
            define(t2_r, w22)                   // Represents the variable t2
            define(t3_r, w23)                   // Represents the variable t3
            define(t4_r, w24)                   // Represents the variable t4

            mov x_r, 0x07FC07FC                 // Value 0111111111000000011111111100

                                                // Step 1
            and t1_r, x_r, 0x55555555           // Only keeps 1 if bit is in both x and 0x55555555, then places result in t1
            lsl t1_r, t1_r, 1                   // Shift bits of t1 left by 1, fill the first bit with a 0
            lsr t2_r, x_r, 1                    // Logical shift left of x by 1, and place the result in t2
            and t2_r, t2_r, 0x55555555          // Bitmask 00111111111000000011111111100000
            orr y_r, t1_r, t2_r                 // Places a one in each bit that t1 or t2 has a 1 in, then places
                                                // the result in y
test1:                                          // Breakpoint to see values of t1, t2, x, and y

                                                // Step 2
            and t1_r, y_r, 0x33333333           // Only keeps 1 if bit is in both y and 0x33333333, then places result in t1
            lsl t1_r, t1_r, 2                   // Logical shift left of t1 by 2, fill the first two bits with a 0
            lsr t2_r, y_r, 2                    // Logical shift right of y by 2, fill the last two bits with a 0 and place the result in t2
            and t2_r, t2_r, 0x33333333          // Bitmask 0x33333333
            orr y_r, t1_r, t2_r                 // Places a one in each bit that t1 or t2 has a 1 in, then places
                                                // the result in y
test2:
                                                // Step 3
            and t1_r, y_r, 0x0F0F0F0F           // Only keeps 1 if bit is in both y and 0x0F0F0F0F, then places result in t1
            lsl t1_r, t1_r, 4                   // Logical shift left of t1 by 4, fill the first four bits with a 0
            lsr t2_r, y_r, 4                    // Logical shift right of y by 4, place the result in t2
            and t2_r, t2_r, 0x0F0F0F0F          // And operator between t2 and 0x0F0F0F0F
            orr y_r, t1_r, t2_r                 // Or operator between t1 and t2, where the result goes into y
test3:

                                                // Step 4
            lsl t1_r, y_r, 24                   // Logical shift left of y by 24, store the result in t1
            and t2_r, y_r, 0xFF00               // And operator between y and 0xFF00, store the result in t2
            lsl t2_r, t2_r, 8                   // Logical shift left of t2 by 8
            lsr t3_r, y_r, 8                    // Logical shift left of y by 8, store the result in t3
            and t3_r, t3_r, 0xFF00              // And operator between t3 and 0xFF00
            lsr t4_r, y_r, 24                   // Logical shift left of y by 24 bits, store the result in t4
            orr y_r, t1_r, t2_r                 // Or operator between t1 and t2, store result in y
            orr y_r, y_r, t3_r                  // Or operator between t3, t2, and t1, store result in y
            orr y_r, y_r, t4_r                  // Or operator between t4,t3,t2, and t1, store result in y
test4:

            adrp x0, print			// adrp sets our string to register 0
	    add w0, w0, :lo12:print		// add the lower 12 bits of our variable
	    mov w1, x_r				// make register 1 equal to x
	    mov w2, y_r		   	    	// make register 2 equal to y
	    bl printf

    	    ldp x29, x30, [sp], 16		// Loads the pair of registers and deallocates 16 bytes of memory from the stack
	    ret					// Returns to calling code (in OS)
