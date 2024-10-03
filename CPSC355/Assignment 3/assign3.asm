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
        define(fp, x29)
        define(lr, x30)
	.balign 4     	        	// Makes sure all instructions are divisible by 4
	.global main	                // Makes the label "main" visible to the linker
main:	stp	fp, lr, [sp, alloc]!    // Allocate the needed bytes of memory from RAM
	mov	fp, sp		        // Update FP to the current SP

        define(i_r, w19)                // Define register 19 as i_r
        define(gap_r, w20)              // Define register 20 as gap_r
        define(j_r, w21)                // Define register 21 as j_r
        define(temp_r, w22)             // Define register 22 as temp_r
        define(vj_r, w23)               // Define register 23 as v[j]
        define(v_r, x24)                // Register x24 is base address (v[0])
        define(vjgap_r, w25)            // Register w25 is v[j+gap]
        add v_r, fp, v_s                // Set v_r to base address
        mov i_r, 0                      // Initialize i_r to 0

        str i_r, [fp, i_s]              // Write memory before changing value of variable
init:                                   // Top of loop to create and print array
        cmp i_r, array_size		// Compare i_r to array_size
	b.ge exit_init			// If greater than or equal to, go to label 'exit_init'
        bl rand                         // Generate a random number and place it in w0
        and temp_r, w0, 0x1FF           // mod the result with 512 and place it in temp
        str temp_r, [v_r, i_r, SXTW 2]  // Store the result in address v_s + i_s*4 in frame pointer

        add i_r, i_r, 1                 // Increment i_r by 1
        b init                          // Unconditionally go to label init
exit_init:
        ldr i_r, [fp, i_s]              // Read memory after using variable to reset i_r

        adrp x0, print1			// adrp sets our string to register 0
	add w0, w0, :lo12:print1	// add the lower 12 bits of our variable
        bl printf                       // Print statement print1

        str i_r, [fp, i_s]              // Write memory before changing value of variable
display:                                // Print the unsorted array
        cmp i_r, array_size		// Compare i_r to array_size
	b.ge exit_display		// If greater than or equal to, go to label 'exit_display'

        adr x0, print2
	mov w1, i_r		        // make register 1 equal to i_r
        ldr temp_r, [v_r, i_r, SXTW 2]  // Load the value at v[i] and store it in temp 
        mov w2, temp_r			// make register 2 equal to temp 
        bl printf                       // Print statement print2

        add i_r, i_r, 1                 // Increment i_r by 1
        b display                       // Unconditionally go to label 'display'
exit_display:
        ldr i_r, [fp, i_s]              // Read memory after using variable to reset i_r


        mov gap_r, array_size           // Set gap equal to array_size
        lsr gap_r, gap_r, 1             // Set gap equal to array_size divided by 2
        str gap_r, [fp, gap_s]          // Store the value of gap_r at address gap_s
gap_loop:
        cmp gap_r, 0		        // Compare gap to 0
	b.le skip_gap_loop		// If less than or equal to, go to label 'skip_gap_loop'

        mov i_r, gap_r                  // Set i equal to gap
        str i_r, [fp, i_s]              // Store the value of i_r at address i_s
i_loop:
        cmp i_r, array_size             // Compare i to array_size
	b.ge skip_i_loop        	// If greater than or equal to, go to label 'skip_i_loop'

        sub j_r, i_r, gap_r             // Set j equal to i - gap
        str j_r, [fp, j_s]              // Store the value of j_r at address j_s
j_loop:
        cmp j_r, 0			// Compare j to 0
	b.lt skip_j_loop		// If less than, go to label 'skip_j_loop'
        
        ldr vj_r, [v_r, j_r, SXTW 2]    // Is now value v[j]
        add w26, gap_r, j_r             // Represents index j+gap
        ldr vjgap_r, [v_r, w26, SXTW 2] // Is now value v[j+gap]

        cmp vj_r,vjgap_r	        // Compare v[j] to v[j+gap]
	b.ge skip_j_loop		// If greater than or equal to, go to label 'skip_j_loop'

        str vjgap_r, [v_r, j_r, SXTW 2] // v[j] = v[j+gap]
        str vj_r, [v_r, w26, SXTW 2]    // v[j+gap] = v[j]

        sub j_r, j_r, gap_r             // Subtract gap from j
        b j_loop                        // Unconditional branch to label 'j_loop'
skip_j_loop:                            // End of j_loop
        ldr j_r, [fp, j_s]              // Load the value at address j_s in j_r

        add i_r, i_r, 1                 // Increment i by 1
        b i_loop                        // Unconditional branch to label 'i_loop'
skip_i_loop:                            // End of i_loop
        ldr i_r, [fp, i_s]              // Store the value at address i_s in i_r

        lsr gap_r, gap_r, 1             // Divide gap by 2
        b gap_loop                      // Unconditional branch to label 'gap_loop'
skip_gap_loop:                          // End of gap_loop
        ldr gap_r, [fp, gap_s]          // Store the value at address gap_s in gap_r

        mov i_r, 0                      // Initialize i_r to 0
        adrp x0, print3			// adrp sets our string to register 0
	add w0, w0, :lo12:print3	// add the lower 12 bits of our variable
        bl printf                       // Print statement print1

        str i_r, [fp, i_s]              // Write memory before changing value of variable
final_display:                          // Displays the sorted array
        cmp i_r, array_size	        // Compare i_r to array_size
	b.ge exit_final_display		// If greater than or equal to, go to label 'exit_display'

        adrp x0, print2			// adrp sets our string to register 0
	add w0, w0, :lo12:print2	// add the lower 12 bits of our variable
	mov w1, i_r		        // make register 1 equal to i_r
        ldr temp_r, [v_r, i_r, SXTW 2]  // Load the value at v[i] and store it in temp
        mov w2, temp_r			// make register 2 equal to temp_r 
        bl printf                       // Print statement print2

        add i_r, i_r, 1                 // Increment i_r by 1
        b final_display                 // Unconditionally go to label 'display'
exit_final_display:                     // End of final_display loop
        ldr i_r, [fp, i_s]              // Read memory after using variable to reset i_r

exit:                                   // End of program
        mov w0, 0                       // Set return value
    	ldp fp, lr, [sp], dealloc	// Loads the pair of registers and deallocates 16 bytes of memory from the stack
	ret			        // Returns to calling code (in OS)
            