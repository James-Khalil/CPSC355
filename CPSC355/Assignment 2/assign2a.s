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

                                // Represents the variable x
                                // Rpresents the variable y
                               // Represents the variable t1
                               // Represents the variable t2
                               // Represents the variable t3
                               // Represents the variable t4

            mov w19, 0x07FC07FC                 // Value 0111111111000000011111111100

                                                // Step 1
            and w21, w19, 0x55555555           // Only keeps 1 if bit is in both x and 0x55555555, then places result in t1
            lsl w21, w21, 1                   // Shift bits of t1 left by 1, fill the first bit with a 0
            lsr w22, w19, 1                    // Logical shift left of x by 1, and place the result in t2
            and w22, w22, 0x55555555          // Bitmask 00111111111000000011111111100000
            orr w20, w21, w22                 // Places a one in each bit that t1 or t2 has a 1 in, then places
                                                // the result in y
test1:                                          // Breakpoint to see values of t1, t2, x, and y

                                                // Step 2
            and w21, w20, 0x33333333           // Only keeps 1 if bit is in both y and 0x33333333, then places result in t1
            lsl w21, w21, 2                   // Logical shift left of t1 by 2, fill the first two bits with a 0
            lsr w22, w20, 2                    // Logical shift right of y by 2, fill the last two bits with a 0 and place the result in t2
            and w22, w22, 0x33333333          // Bitmask 0x33333333
            orr w20, w21, w22                 // Places a one in each bit that t1 or t2 has a 1 in, then places
                                                // the result in y
test2:
                                                // Step 3
            and w21, w20, 0x0F0F0F0F           // Only keeps 1 if bit is in both y and 0x0F0F0F0F, then places result in t1
            lsl w21, w21, 4                   // Logical shift left of t1 by 4, fill the first four bits with a 0
            lsr w22, w20, 4                    // Logical shift right of y by 4, place the result in t2
            and w22, w22, 0x0F0F0F0F          // And operator between t2 and 0x0F0F0F0F
            orr w20, w21, w22                 // Or operator between t1 and t2, where the result goes into y
test3:

                                                // Step 4
            lsl w21, w20, 24                   // Logical shift left of y by 24, store the result in t1
            and w22, w20, 0xFF00               // And operator between y and 0xFF00, store the result in t2
            lsl w22, w22, 8                   // Logical shift left of t2 by 8
            lsr w23, w20, 8                    // Logical shift left of y by 8, store the result in t3
            and w23, w23, 0xFF00              // And operator between t3 and 0xFF00
            lsr w24, w20, 24                   // Logical shift left of y by 24 bits, store the result in t4
            orr w20, w21, w22                 // Or operator between t1 and t2, store result in y
            orr w20, w20, w23                  // Or operator between t3, t2, and t1, store result in y
            orr w20, w20, w24                  // Or operator between t4,t3,t2, and t1, store result in y
test4:

            adrp x0, print			// adrp sets our string to register 0
	    add w0, w0, :lo12:print		// add the lower 12 bits of our variable
	    mov w1, w19				// make register 1 equal to x
	    mov w2, w20		   	    	// make register 2 equal to y
	    bl printf

    	    ldp x29, x30, [sp], 16		// Loads the pair of registers and deallocates 16 bytes of memory from the stack
	    ret					// Returns to calling code (in OS)
