// File: assign3.asm
// Author: James Khalil
// Date: October 22, 2021
//
// Description:
// Sort an array of size 100

print1:  .string "Unsorted array: %d\n"
print2:  .string "v[%d] = %d\n"
print3:  .string "\nSorted array:\n"
                                        // Set the bytes required for allocation
        array_size = 100
        gap_size = 4
        i_size = 4
        j_size = 4
        v_size = array_size * 4
        alloc = -(16 + i_size + j_size + gap_size + v_size) & -16
        dealloc = -alloc
        gap_s = 16
        i_s = 20
        j_s = 24
        v_s = 28

                                        // Defining fp and lr
        
        
	.balign 4     	        	// Makes sure all instructions are divisible by 4
	.global main	                // Makes the label "main" visible to the linker
main:	stp	x29, x30, [sp, alloc]!    // Allocate the needed bytes of memory from RAM
	mov	x29, sp		        // Update FP to the current SP

                        // Define register 19 as w19
                      // Define register 20 as w20
                        // Define register 21 as w21
                     // Define register 22 as w22
                       // Define register 23 as v[j]
                        // Register x24 is base address (v[0])
                    // Register w25 is v[j+gap]
        add x24, x29, v_s                // Set x24 to base address
        mov w19, 0                      // Initialize w19 to 0

        str w19, [x29, i_s]              // Write memory before changing value of variable
init:                                   // Top of loop to create and print array
        cmp w19, array_size		// Compare w19 to array_size
	b.ge exit_init			// If greater than or equal to, go to label 'exit_init'
        bl rand                         // Generate a random number and place it in w0
        and w22, w0, 0x1FF           // mod the result with 512 and place it in temp
        str w22, [x24, w19, SXTW 2]  // Store the result in address v_s + i_s*4 in frame pointer

        add w19, w19, 1                 // Increment w19 by 1
        b init                          // Unconditionally go to label init
exit_init:
        ldr w19, [x29, i_s]              // Read memory after using variable to reset w19

        adrp x0, print1			// adrp sets our string to register 0
	add w0, w0, :lo12:print1	// add the lower 12 bits of our variable
        bl printf                       // Print statement print1

        str w19, [x29, i_s]              // Write memory before changing value of variable
display:                                // Print the unsorted array
        cmp w19, array_size		// Compare w19 to array_size
	b.ge exit_display		// If greater than or equal to, go to label 'exit_display'

        adr x0, print2
	mov w1, w19		        // make register 1 equal to w19
        ldr w22, [x24, w19, SXTW 2]  // Load the value at v[i] and store it in temp 
        mov w2, w22			// make register 2 equal to temp 
        bl printf                       // Print statement print2

        add w19, w19, 1                 // Increment w19 by 1
        b display                       // Unconditionally go to label 'display'
exit_display:
        ldr w19, [x29, i_s]              // Read memory after using variable to reset w19


        mov w20, array_size           // Set gap equal to array_size
        lsr w20, w20, 1             // Set gap equal to array_size divided by 2
        str w20, [x29, gap_s]          // Store the value of w20 at address gap_s
gap_loop:
        cmp w20, 0		        // Compare gap to 0
	b.le skip_gap_loop		// If less than or equal to, go to label 'skip_gap_loop'

        mov w19, w20                  // Set i equal to gap
        str w19, [x29, i_s]              // Store the value of w19 at address i_s
i_loop:
        cmp w19, array_size             // Compare i to array_size
	b.ge skip_i_loop        	// If greater than or equal to, go to label 'skip_i_loop'

        sub w21, w19, w20             // Set j equal to i - gap
        str w21, [x29, j_s]              // Store the value of w21 at address j_s
j_loop:
        cmp w21, 0			// Compare j to 0
	b.lt skip_j_loop		// If less than, go to label 'skip_j_loop'
        
        ldr w23, [x24, w21, SXTW 2]    // Is now value v[j]
        add w26, w20, w21             // Represents index j+gap
        ldr w25, [x24, w26, SXTW 2] // Is now value v[j+gap]

        cmp w23,w25	        // Compare v[j] to v[j+gap]
	b.ge skip_j_loop		// If greater than or equal to, go to label 'skip_j_loop'

        str w25, [x24, w21, SXTW 2] // v[j] = v[j+gap]
        str w23, [x24, w26, SXTW 2]    // v[j+gap] = v[j]

        sub w21, w21, w20             // Subtract gap from j
        b j_loop                        // Unconditional branch to label 'j_loop'
skip_j_loop:                            // End of j_loop
        ldr w21, [x29, j_s]              // Load the value at address j_s in w21

        add w19, w19, 1                 // Increment i by 1
        b i_loop                        // Unconditional branch to label 'i_loop'
skip_i_loop:                            // End of i_loop
        ldr w19, [x29, i_s]              // Store the value at address i_s in w19

        lsr w20, w20, 1             // Divide gap by 2
        b gap_loop                      // Unconditional branch to label 'gap_loop'
skip_gap_loop:                          // End of gap_loop
        ldr w20, [x29, gap_s]          // Store the value at address gap_s in w20

        mov w19, 0                      // Initialize w19 to 0
        adrp x0, print3			// adrp sets our string to register 0
	add w0, w0, :lo12:print3	// add the lower 12 bits of our variable
        bl printf                       // Print statement print1

        str w19, [x29, i_s]              // Write memory before changing value of variable
final_display:                          // Displays the sorted array
        cmp w19, array_size	        // Compare w19 to array_size
	b.ge exit_final_display		// If greater than or equal to, go to label 'exit_display'

        adrp x0, print2			// adrp sets our string to register 0
	add w0, w0, :lo12:print2	// add the lower 12 bits of our variable
	mov w1, w19		        // make register 1 equal to w19
        ldr w22, [x24, w19, SXTW 2]  // Load the value at v[i] and store it in temp
        mov w2, w22			// make register 2 equal to w22 
        bl printf                       // Print statement print2

        add w19, w19, 1                 // Increment w19 by 1
        b final_display                 // Unconditionally go to label 'display'
exit_final_display:                     // End of final_display loop
        ldr w19, [x29, i_s]              // Read memory after using variable to reset w19

exit:                                   // End of program
        mov w0, 0                       // Set return value
    	ldp x29, x30, [sp], dealloc	// Loads the pair of registers and deallocates 16 bytes of memory from the stack
	ret			        // Returns to calling code (in OS)
            