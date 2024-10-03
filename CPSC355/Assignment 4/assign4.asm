// File: assign4.asm
// Author: James Khalil
// Date: November 5, 2021
//
// Description:
// Learn subroutines, arguments, and pointers


FALSE = 0                                                               // Boolean values
TRUE = 1

coord_x = 0                                                             // Nested Offset
coord_y = 4                                                             // Nested Offset

size_width = 0                                                          // Nested Offset
size_length = 4                                                         // Nested Offset

pyramid_center = 0                                                      // Struct coord
pyramid_base = 8                                                        // Struct size
pyramid_height = 16                                                     // Int
pyramid_volume = 20                                                     // Int

pyramid_size = 24                                                       // Two pyramids of size 24
khafre_size = pyramid_size                              
cheops_size = pyramid_size

alloc = -(16 + khafre_size + cheops_size) & -16                         // Only the pyramids will be stored on the stack
dealloc = -alloc

khafre_s = 16      
cheops_s = 40
                                                                        // w0-w2 are value arguments, x3 and x4 are address arguments
define(vArg_1, w0)
define(vArg_2, w1)
define(vArg_3, w2)
define(aArg_1, x3)
define(aArg_2, x4)
                                                                        // rename x29 and x30 to fp and lr for more correctness
define(fp, x29)
define(lr, x30)

print1:             .string "Initial pyramid values:\n"                 // Print for initialized values
print2:             .string "\nNew pyramid values:\n"                   // Print for finalized values

pyramidprint1:      .string "Pyramid %s\n"                              // Needs the string of the pyramid
pyramidprint2:      .string "\tCenter = (%d, %d)\n"                     // Needs x and y coord of pyramid
pyramidprint3:      .string "\tBase width = %d  Base length = %d\n"     // Needs width and length base of pyramid
pyramidprint4:      .string "\tHeight = %d\n"                           // Needs height of pyramid
pyramidprint5:      .string "\tVolume = %d\n\n"                         // Needs volume of pyramid

khafre_string:      .string "khafre"                                    // String variables khafre and cheops
cheops_string:      .string "cheops"

	                .balign 4     	        	                        // Makes sure all instructions are divisible by 4
	                .global main	                                    // Makes the label "main" visible to the linker

newPyramid:         stp fp, lr, [sp, -16]!                              // newPyramid subroutine initializes the values

                                                                        // aArg_1 is the address for the pyramid structure in question
                                                                        // so we offset based on what pyramid value we want

                    str wzr, [aArg_1, pyramid_center + coord_x]         // Coordinate x starts at 0
                    str wzr, [aArg_1, pyramid_center + coord_y]         // Coordinate y starts at 0
                    str vArg_1, [aArg_1, pyramid_base + size_width]     // Set the width to the defined argument
                    str vArg_2, [aArg_1, pyramid_base + size_length]    // Set the length to the defined argument
                    str vArg_3, [aArg_1, pyramid_height]                // Set the height to the defined argument

                                                                        // Volume is calcualted using width, lenght, and height
                    ldr w20, [aArg_1, pyramid_base + size_width]        // Load the value of width into w20
                    ldr w21, [aArg_1, pyramid_base + size_length]       // Load the value of length into w21 
                    ldr w22, [aArg_1, pyramid_height]                   // Load the value of height into w22

                    mul w20, w20, w21                                   // Multiply width and length
                    mul w20, w20, w22                                   // Mulitply width and lenght and height
                    mov w19, 3                                          // Can't divide by immediates so store 3 in w19
                    sdiv w20, w20, w19                                  // Divide width length and height by 3
                    str w20, [aArg_1, pyramid_volume]                   // Store the result at the pyramid volume offset

                    ldp fp, lr, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)

relocate:           stp fp, lr, [sp, -16]!                              // Relocate subroutine changes the coordinates

                    ldr w19, [aArg_1, pyramid_center + coord_x]         // Load coordiante x into w19
                    add w19, w19, vArg_1                                // Add the first arguemnt to w19
                    str w19, [aArg_1, pyramid_center + coord_x]         // Store w19 into coordinate x in stack

                    ldr w19, [aArg_1, pyramid_center + coord_y]         // Load coordinate y into w19
                    add w19, w19, vArg_2                                // Add the second argument to w19
                    str w19, [aArg_1, pyramid_center + coord_y]         // Store w19 into coordinate y in stack

                    ldp fp, lr, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)

expand:             stp fp, lr, [sp, -16]!                              // subroutine for increasing the base, width, and height by a factor
                    mov	fp, sp		                                    // Update FP to the current SP

                    ldr w19, [aArg_1, pyramid_base + size_width]        // load the width into w19
                    mul w19, w19, vArg_1                                // Multiply w19 by the argument
                    str w19, [aArg_1, pyramid_base + size_width]        // Store w19 back into width
                    
                    ldr w20, [aArg_1, pyramid_base + size_length]       // load the length into w20
                    mul w20, w20, vArg_1                                // Multiply w20 by the factor
                    str w20, [aArg_1, pyramid_base + size_length]       // Store w20 back into length

                    ldr w21, [aArg_1, pyramid_height]                   // Load the height into w21
                    mul w21, w21, vArg_1                                // Multiply w21 by the factor
                    str w21, [aArg_1, pyramid_height]                   // Store w21 back into height

                    mul w19, w19, w20                                   // Multiply the new width and length
                    mul w19, w19, w21                                   // Multiply width, length, and height
                    mov w21, 3                                          // Can't divide by immediates so store 3 in w19
                    sdiv w19, w19, w21                                  // Divide width length and height by 3
                    str w19, [aArg_1, pyramid_volume]                   // Store the result in volume

                    ldp fp, lr, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)


printPyramid:       stp fp, lr, [sp, -16]!                              // subroutine for printing pyramid information

                    mov x19, aArg_1                                     // Move the address argument into x19
                                                                        // aArg_1 will be overwritten when we branch into printf

                    mov w1, w0                                          // Move vArg_1 into w1 before it is overwritten on line 123
                    adr x0, pyramidprint1                               // Set up our print statement
                    bl printf                                           // Print

                    adr x0, pyramidprint2                               // Set up print statement for coordinates
	                ldr w1, [x19, pyramid_center + coord_x]             // Set w1 to x coordinate
                    ldr w2, [x19, pyramid_center + coord_y]             // Set w2 to y coordinate
                    bl printf                                           // Print

                    adr x0, pyramidprint3                               // Print statement for width and length
                    ldr w1, [x19, pyramid_base + size_width]            // Set w1 to width
                    ldr w2, [x19, pyramid_base + size_length]           // Set w2 to length
                    bl printf                                           // Print result

                    adr x0, pyramidprint4                               // Print statement for height
	                ldr w1, [x19, pyramid_height]                       // Set w1 to height
                    bl printf                                           // Print height

                    adr x0, pyramidprint5                               // Print statement for volume
	                ldr w1, [x19, pyramid_volume]                       // Set w1 to volume
                    bl printf                                           // Print volume

                    ldp fp, lr, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)


equalSize:          stp fp, lr, [sp, -16]!                              // subroutine for checking if the pyramids are of equal size

                    w0 = FALSE                                          // Intialize w0 to FALSE. If not changed, w0 will be returned as FALSE
                    ldr w19, [aArg_1, pyramid_base + size_width]        // Load the width of pyramid 1 into w19
                    ldr w20, [aArg_2, pyramid_base + size_width]        // Load the width of pyramid 2 into w20
                    cmp w19, w20                                        // Compare w19 and w20
                    b.ne exit_equalSize                                 // If not equal skip to end of subroutine

                    ldr w19, [aArg_1, pyramid_base + size_length]       // Load the length of pyramid 1 into w19
                    ldr w20, [aArg_2, pyramid_base + size_length]       // Load the length of pyramid 2 into w20
                    cmp w19, w20                                        // Compare w19 and w20
                    b.ne exit_equalSize                                 // If not equal skip to the end of subroutine

                    ldr w19, [aArg_1, pyramid_height]                   // Load the height of pyramid 1 into w19
                    ldr w20, [aArg_2, pyramid_height]                   // Load the height of pyramid 2 into w20
                    cmp w19, w20                                        // Compare w19 and w20
                    b.ne exit_equalSize                                 // If not equal skip to the end of subroutine
                    w0 = TRUE                                           // Set w0 to TRUE
                                                                        // Note this only happens is all the compares found to be equal

exit_equalSize:                                                         // Branch to here if any of the compares are not equal
                    ldp fp, lr, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)


main:               stp fp, lr, [sp, alloc]!                            // Main function, will call all other subroutines from here
                    mov	fp, sp		                                    // Update FP to the current SP
                    
                                                                        // Initializing pyramids khafre and cheops
                    mov vArg_1, 10                                      // vArg_1 = 10 (used for width)
                    mov vArg_2, 10                                      // vArg_2 = 10 (used for length)
                    mov vArg_3, 9                                       // vArg_3 = 9 (used for height)
                    add aArg_1, fp, khafre_s                            // Address of pyramid khafre in stack
                    bl newPyramid                                       // Call to subroutine
                    mov vArg_1, 15                                      // vArg_1 = 15 (used for width)
                    mov vArg_2, 15                                      // vArg_2 = 15 (used for length)
                    mov vArg_3, 18                                      // vArg_3 = 18 (used for height)
                    add aArg_1, fp, cheops_s                            // Address of pyramid cheops in stack
                    bl newPyramid                                       // Call to subroutine

                                                                        // Printing initial values of pyramids
                    adr x0, print1                                      // Print statement saying it will print the original values
                    bl printf                                           // Print
                    add aArg_1, fp, khafre_s                            // Address of pyramid khafre in stack
                    adr x0, khafre_string                               // Name of pyramid (khafre)
                    bl printPyramid                                     // Call to subroutine
                    add aArg_1, fp, cheops_s                            // Address of pyramid cheops in stack
                    adr x0, cheops_string                               // Name of pyramid (cheops)
                    bl printPyramid                                     // Call to subroutine

                                                                        // Comparing sizes of khafre and cheops
                    add aArg_1, fp, khafre_s                            // Address of pyramid khafre in stack
                    add aArg_2, fp, cheops_s                            // Address of pyramid cheops in stack
                    bl equalSize                                        // Call to subroutine
                                                                        // (This subroutine returns a value in w0)
                    cmp w0, TRUE                                        // Comapre w0 to TRUE (1)
	                b.eq ifTrue                                         // If equal to TRUE then go to ifTrue
                    add aArg_1, fp, cheops_s                            // Address of pyramid cheops in stack
                    mov vArg_1, 9                                       // vArg_1 = 9 (used for factor)
                    bl expand                                           // Cal to subroutine
                    add aArg_1, fp, cheops_s                            // Address of pyramid cheops in stack
                    mov vArg_1, 27                                      // vArg_1 = 27 (used for delta of x coord)
                    mov vArg_2, -10                                     // vArg_2 = -10 (used for delta of y coord)
                    bl relocate                                         // Call to subroutine
                    add aArg_1, fp, khafre_s                            // Address of pyramid cheops in stack
                    mov vArg_1, -23                                     // vArg_1 = -23 (used for delta of x coord)
                    mov vArg_2, 17                                      // vArg_2 = 17 (used for delta of y coord)
                    bl relocate                                         // Call to subroutine
ifTrue:                                                                 // Branch to if pyramids are equal sizes, skipping relocation and expand subroutines

                                                                        // Printing new vlaues of pyramids
                    adr x0, print2                                      // Print statement saying it will print the new values
                    bl printf                                           // Print subroutine
                    add aArg_1, fp, khafre_s                            // Address of pyramid khafre in stack 
                    adr x0, khafre_string                               // Name of pyramid (khafre)
                    bl printPyramid                                     // Call to subroutine
                    add aArg_1, fp, cheops_s                            // Address of pyramid cheops in stack 
                    adr x0, cheops_string                               // Name of pyramid (cheops)
                    bl printPyramid                                     // Call to subroutine
                                        
                    ldp fp, lr, [sp], dealloc                           // Loads the pairs of registers and deallocates the specified amount from the stack
                    ret                                                 // Returns to calling code (in OS)
