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

		define(x_r, x19)				// Refers to variable x
		define(A_r, x23)				// Refers to ax^4 (will eventually hold the entire equation)
		define(B_r, x24)				// Refers to bx^2
		define(L_r, x25)				// Refers to the current maximum value
		mov x_r, -10					// Initialize variablex to be -10

								// Since we can't multiply immediates, we need
								// To store those numbers in registers
		mov x20, -3					// Intialize register 20 to hold -3
		mov x21, 267					// Initialize register 21 to hold 267
		mov x22, 47					// Initialize register 22 to hold 47

top:								// Beginning of loop

		mul A_r, x_r, x_r				// Put the value of x squared in register 23
		mul A_r, A_r, x_r				// Multiply x squared by x to get x^3
		mul A_r, A_r, x_r				// Multiply x cubed by x to get x^4
		mul A_r, A_r, x20				// Multiply x^4 by -3 to get -3x^4

		mul B_r, x_r, x_r				// Put the value of x squared in B_r
		madd A_r, B_r, x21, A_r				// Multiply x squared by 267 to get 267x^2 and add it to A_r

		madd A_r, x_r, x22, A_r				// Multiply x by 47 and add it to A_r

		sub A_r, A_r, 43				// Subtract 43 from A_r

								// Note at this point we have created the equation
								// -3x^2 + 267x^2 + 47x - 43

		cmp A_r, L_r					// Compare A_r to L_r
		b.le next					// If less than or equal to, go to label 'next'

		mov L_r, A_r					// Change the largest number to the number just found to be larger

next:								// After if statement

		adrp x0, print					// adrp sets our string to register 0
		add x0, x0, :lo12:print				// add the lower 12 bits of our variable
		mov x1, x_r					// make register 1 equal to x
		mov x2, A_r					// make register 2 equal to y
		mov x3, L_r					// make register 3 equal to the maximum
		bl printf					// Print the current x and y value and current maximum
	
		add x_r,x_r,1					// Increment x by 1
		cmp x_r,10					// Compare x to 10
		b.le top					// If less than or equal to, go to label 'top'
done:								// Reaching this point means the loop has ended
		ldp x29, x30, [sp], 16				// Loads the pair of registers and deallocates 16 bytes of memory from the stack
		ret						// Returns to calling code (in OS)
