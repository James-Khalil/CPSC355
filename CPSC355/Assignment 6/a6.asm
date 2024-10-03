// File: a6.asm
// Author: James Khalil
// Date: December 8, 2021
//
// Description:
// Take x values from an input bin, and 
// solve arctan(x) using series expansion

                                                                                                // definition varaibles for arctan()
                define(arctanx_r, d10)                                                          // current value of arctan(x)
                define(n_r, d14)                                                                // n value (x^n/n)
                define(term_r, d13)                                                             // term value (eg. x^3/3)

                // defining variables for main()
                define(argc_r, w20)                                                             // number of args                      
                define(argv_r, x21)                                                             // arg char (will be path name)
                define(fileD_r, w22)                                                            // file descriptor 
                define(index_r, w23)                                                            // index between -95 to 95 (5 increments)
                define(bytes_read_r, x24)                                                       // tracks bytes read (8 bytes at a time)
                define(buf_base_r, x26)                                                         // buffer base register

                // constants
                LOWER_LIMIT = -95                                                               // lower limit
                UPPER_LIMIT = +95                                                               // upper limit
                INCREMENT = 5                                                                   // increment

                // sizes and allocation
                buf_size = 8                                                                    // 8 bytes long in bin file
                buf_s = 16                                                                      // offset

                alloc = -(16 + buf_size) & -16                                                  // allocation calc
                dealloc = -alloc                                                                // dealloc

                .text                                                                           // start text section

// main()

main:           stp     x29, x30, [sp, alloc]!                                                  // Main function, will call all other subroutines from here
                mov     x29, sp                                                                 // Update FP to the current SP

                mov     argc_r, w0                                                              // get number of args
                mov     argv_r, x1                                                              // get arg

                cmp     argc_r, 2                                                               // check if number of args = 2
                b.eq    main_next                                                               // if = 2, then branch to main_next

                                                                                                // if != 2, then arg use is incorrect, print this
                adr x0, print_argE                                                              // "\n[ERROR] Incorrect arguments. Expected: ./a6 {filename}.bin\n\n"
                bl      printf                                                                  // call printf
                b       end                                                                     // branch to end

main_next:      adr     x0, print_open                                                          // print "\nOpening file: %s \n"
                ldr     x1, [argv_r, 8]                                                         // arg string is title so "opening ... [arg]"
                bl      printf                                                                  // call printf

                mov     x0, -100                                                                // read input from file begins, first arg (cwd)
                ldr     x1, [argv_r, 8]                                                         // pathname
                mov     w2, 0                                                                   // read only
                mov     w3, 0                                                                   // not used  
                mov     x8, 56                                                                  // openat I/O request
                svc     0

                mov     fileD_r, w0                                                             // move w0 into file descriptor
                cmp     fileD_r, 0                                                              // compare file descriptor to 0
                b.ge    open_s                                                                  // if greater than or equal go to branch open_s

                adr     x0, print_open_e                                                        // print "\n[ERROR] File error, cannot open.\n\n"                                    
                bl      printf                                                                  // cal printf

                mov     x0, -1                                                                  // return with -1                         
                b       end                                                                     // branch to end of main

open_s:         add     buf_base_r, x29, buf_s                                                  // calc base address of buffer

                mov     index_r, LOWER_LIMIT                                                    // move -95 to index register
                b       loop_test                                                               // branch to loop test

loop_start:     mov     w0, fileD_r                                                             // file descriptor 1st arg 
                mov     x1, buf_base_r                                                          // buf 2nd arg
                mov     w2, buf_size                                                            // 8-bytes 3rd arg
                mov     x8, 63                                                                  // mov 63 into x8
                svc     0                                                                       // call sys function
                mov     bytes_read_r, x0                                                        // move x0 to number of bytes read

                cmp     bytes_read_r, buf_size                                                  // compare bytes read to buf_size (8 bytes)
                b.ne    loop_exit                                                               // loop exit if not equal

                ldr     d0, [buf_base_r]                                                        // load x (read from earlier) into d0

                fmov     d3, d0                                                                 // clone x

                b       arctancalc                                                              // branch to  arctancalc

arctancalc:     adr     x27, temp_f                                                             // calculate address of temp_f
                ldr     d0, [x27]                                                               // load the address of x27 in d0

                scvtf   d1, index_r                                                             // convert index_r into signed floating point num and move to d1

                adr     x27, hundred_div                                                        // calc hundred_div address
                ldr     d2, [x27]                                                               // load the address of x27 in d2

                fdiv    d0, d1, d2                                                              // d1 / d2 = d0

                bl      arctan                                                                  // branch to arctan function, passing in x

                fmov     d1, d3

                adr     x0, print_calc                                                          // print "%.10f\n"
                bl      printf                                                                  // call printf

                add     index_r, index_r, INCREMENT                                             // increment index by 5

loop_test:      cmp     index_r, UPPER_LIMIT                                                    // compare index_r to 95
                b.le    loop_start                                                              // if less than branch to loop start

loop_exit:      adr     x0, print_end                                                           // print "\nEnd of file reached.\n\n"
                bl      printf                                                                  // branch to printf

                mov     w0, fileD_r                                                             // file descriptor in w0
                mov     x8, 57                                                                  // move 57 in x8
                svc     0                                                                       // call sys function 0

end:            ldp     x29, x30, [sp], dealloc                                                 // Loads the pairs of registers and deallocates the specified amount from the stack
                ret                                                                             // Returns to calling code (in OS)


print_argE:     .string "\n Invalid argument\n Expected: ./a6 'filename'.bin\n\n"               // incorrect use of arguments
print_open:     .string "\nOpening file: %s \n"                                                 // opening file
print_open_e:   .string "\n[ERROR] File error, cannot open.\n\n"                                // error opening
print_calc:     .string "arctan(%.10f) = %.10f\n"                                               // arctan(x) with 10 decimal precision
print_end:      .string "End of file reached.\n\n"                                              // end of file message

                .data                                                                           // start data section

STOP_LIMIT:     .double 0r1.0e-13                                                               // stop limit for terms in expansion
zero_float:     .double 0r0.0                                                                   // zero const
hundred_div:    .double 0r100.0                                                                 // divide by 100 const
temp_f:  .double 0r0.0                                                                          // storage for float

                .text                                                                          // go to text
                .balign 4                                                                      // Makes sure all instructions are divisible by 4
	            .global main	                                                               // Makes the label "main" visible to the linker

arctan:         stp     x29, x30, [sp, -16]!                                                   // computes arctan(x)
                mov     x29, sp                                                                // mov sp to fp

                fmov    arctanx_r, d0                                                          // move d0 into d9
                fmov    d12, arctanx_r                                                         // constant for x
                fmov    n_r, 3.0                                                               // n, start at 3.0
                fmov    d16, 1.0                                                               // 1.0 constant
                fmov    d17, 1.0                                                               // add/sub alternator
                
                adrp    x19, zero_float                                                        // calc zero const address
                add     x19, x19, :lo12:zero_float                                             // low order 12 bits
                ldr     d19, [x19]                                                             // d19 = 0.0

                adrp    x11, STOP_LIMIT                                                        // calc STOP_LIMIT const address
                add     x11, x11, :lo12:STOP_LIMIT                                             // 12 bits
                ldr     d11, [x11]                                                             // d11 = STOP_LIMIT

arctan_top:     fmov    d15, 1.0                                                               // reset counter to 1
                fmov    term_r, d12                                                            // get original x
                fsub    d18, n_r, d16                                                          // number of iterations for x^n is n-1

arctan_exp:     fcmp    d15, d18                                                               // compare counter to n-1
                b.gt    arctan_next                                                            // if greater than branch to arctan_next

                fmul    term_r, term_r, d12                                                    // x * x
                fadd    d15, d15, d16                                                          // increment counter by 1
                b       arctan_exp                                                             // branch to top of exponential loop

arctan_next:    fdiv    term_r, term_r, n_r                                                    // divide the term by n (eg. x^3/3 where n = 3)

                fcmp    d17, d16                                                               // check if add/sub alternator = 1.0 (d16), if 1.0 then sub else add
                b.eq    arctan_sub                                                             // subtract term 

                // arctan_add
                fadd    arctanx_r, arctanx_r, term_r                                           // add the term

                fadd    n_r, n_r, d16                                                          // n++
                fadd    n_r, n_r, d16                                                          // add again for expansion

                fmov    d17, 1.0                                                               // remember to subtract the next one

                b       arctan_test                                                            // branch to test

arctan_sub:     fsub    arctanx_r, arctanx_r, term_r                                           // sub the term

                fadd    n_r, n_r, d16                                                          // n++
                fadd    n_r, n_r, d16                                                          // add again for expansion

                fmov    d17, 2.0                                                               // remember to add the next one

                b       arctan_test                                                            // branch to test

arctan_test:    fabs    term_r, term_r                                                         // take abs val of the term
                fcmp    term_r, d11                                                            // compare term to 1.0e-13
                b.le    arctan_end                                                             // if less than or equal to branch to end
                b       arctan_top                                                             // go to top of loop

arctan_end:     fmov    d0, arctanx_r                                                          // return arctan(x)
                ldp     x29, x30, [sp], 16                                                     // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	            ret 			                                                               // Returns to calling code (in OS)
