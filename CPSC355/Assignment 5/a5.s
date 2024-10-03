print_push:         .string "error: stack full\n"
print_pop:          .string "error: stack empty\n"
print_ungetch:      .string "ungetch: too many c haracters\n"

                    .balign 4     	        	                        // Makes sure all instructions are divisible by 4
                    .global push                                        // Make the subroutine global
push:               stp x29, x30, [sp, -16]!                            // Has one integer argument f, returns one integer argument
                    mov x29, sp                                         // Move the stack pointer into x29


                                                                        // Load sp_var into w1
                    adrp x1, sp_var
                    add x1, x1, :lo12:sp_var
                    ldr w1, [x1]

                                                                        // Load MAXVAL into w2
                    adrp x1, MAXVAL
                    add x1, x1, :lo12:MAXVAL
                    ldr w2, [x1]



                    cmp w1, W2                                          // Compare sp_var to MAXVAL                                
                    b.lt returnf                                        // If less than return f

                    adr x0, print_push                                  // "error: stack full\n"                                      
                    bl printf                                           // Print x0
                    bl clear                                            // Go to subroutine clear
                    mov w0, wzr                                         // Set return value to 0
                    bl end_push                                         // Go to end of subroutine without returning f

returnf:            
                    adrp x20, value_array                               // Set x20 to the value_array address
                    add x20, x20, :lo12:value_array
                                                                         // Store sp_var++
                    adrp x1, sp_var
                    add x1, x1, :lo12:sp_var
                    ldr w1, [x1]
                    add w1, w1, 1
                    str w1, [x1]
                    str w0, [x20, w1, SXTW 2]                       // w0 is the argument f

end_push:
                    ldp x29, x30, [sp], 16	                            // Loads the pair of registers and deallocates 16 bytes of memory from the stack
	                ret			                                        // Returns to calling code (in OS)
                    