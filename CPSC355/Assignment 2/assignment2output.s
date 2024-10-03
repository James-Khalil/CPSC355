// File: assign2a.asm
// Author: James Khalil
// Date: October 10, 2021
//
// Description:
// Reverse bits of variables

print:      .string "original: 0x%08X   reversed: 0x%08X\n %d, %d"

		    //.balign 4       					// Makes sure all instructions are divisible by 4

		    .global main					    // Makes the label "main" visible to the linker
main:	    stp		x29, x30, [sp, -16]!    	// Allocate 16 bytes of memory from RAM
		    mov		x29, sp				        // Update FP to the current SP

            
            
            
            
            
            

            mov w19, 0x01FF01FF                 // Value 0111111111000000011111111100

            and w21, w19, 0x55555555           // Bitmask 00111111111000000011111111100000
curiosity:            
            lsl w21, w21, 1
            lsr w22, w19, 1
            and w22, w22, 0x55555555
            orr w20, w21, w22
test1:

            and w21, w20, 0x33333333
            lsl w21, w21, 2            
            lsr w22, w20, 2
            and w22, w22, 0x33333333
            orr w20, w21, w22
test2:

            and w21, w20, 0x0F0F0F0F
            lsl w21, w21, 4
            lsr w22, w20, 4
            and w22, w22, 0x0F0F0F0F
            orr w20, w21, w22
test3:

            lsl w21, w20, 24
            and w22, w20, 0xFF00
            lsl w22, w22, 8
            lsr w23, w20, 8
            and w23, w23, 0xFF00
            lsr w24, w20, 24
            orr w20, w21, w22
            orr w20, w20, w23
            orr w20, w20, w24
test4:

            adrp x0, print					    // adrp sets our string to register 0
		    add w0, w0, :lo12:print				// add the lower 12 bits of our variable
		    mov w1, w19				        	// make register 1 equal to x
		    mov w2, w20		        			// make register 2 equal to y
		    bl printf

    		ldp x29, x30, [sp], 16				// Loads the pair of registers and deallocates 16 bytes of memory from the stack
	    	ret						            // Returns to calling code (in OS)        
