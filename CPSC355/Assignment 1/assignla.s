// File: assignment1.s
// Author: James Khalil
// Date: September 28, 2021
//
// Description:
// Find the maximum of the equation -3x^4 + 267x^2 + 47x -43

print:		.string "x value: %d	y value: %d\nmximum y value: %d\n"
								// String for printing the current x and y and the current maximum

		.balign 4					// Makes sure all instructions are divisible by 4


		.global main					// Makes the label "main" visible to the linker
main:		stp		x29, x30, [sp, -16]!		// Allocate 16 bytes of memory from RAM
		mov		x29, sp				// Update FP to the current SP

								// Since we can't multiply immediates, we need
								// To store those numbers in register
		mov x19, -10					// Initialize variable x to be -10
		mov x20, -3					// Intialize register 20 to hold -3
		mov x21, 267					// Initialize register 21 to hold 267
		mov x22, 47					// Initialize register 22 to hold 47

top:								// Beginning of loop

		cmp x19,10					// Compare x to 10
		b.gt done					// Conditional branch where if greater than go to label 'done'
								// This ends the loop once x is greater than 10

		mul x23, x19, x19				// Put the value of x squared in register 23
		mul x23, x23, x19				// Multiply x squared by x to get x^3
		mul x23, x23, x19				// Multiply x cubed by x to get x^4
		mul x23, x23, x20				// Multiply x^4 by -3 to get -3x^4

		mul x24, x19, x19				// Put the value of x squared in regster 24
		mul x24, x24, x21				// Multiply x squared by 267 to get 267x^2

		mul x25, x19, x22				// Multiply x by 47 and store the value in register 25

		add x23, x23, x24				// Add -3x^4 and 267x^2
		add x23, x23, x25				// Add -3x^2 + 267x^2 and 47x
		sub x23, x23, 43				// Subtract -3x^2 + 267x^2 + 47x and 43
								// Note at this point we have created the equation
								// -3x^2 + 267x^2 + 47x - 43

		cmp x23, x26					// Compare register 23 to register 26
		b.le next					// If less than or equal to, go to label 'next'

		mov x26, x23					// Change the largest number to the number just found to be larger

next:								// After if statement

		adrp x0, print					// adrp sets our string to register 0
		add x0, x0, :lo12:print				// add the lower 12 bits of our variable
		mov x1, x19					// make register 1 equal to x
		mov x2, x23					// make register 2 equal to y
		mov x3, x26					// make register 3 equal to the maximum
		bl printf					// Print the current x and y value and current maximum

		add x19,x19,1					// Increment x by 1
		b top						// Unconditional branch to label 'top'

done:								// Reaching this point means the loop has ended

		ldp x29, x30, [sp], 16				// Loads the pair of registers and deallocates 16 bytes of memory from the stack
		ret						// Returns to calling code (in OS)
