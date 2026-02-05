/*
-------------------------------------------------------
intro.s
-------------------------------------------------------
Author:
ID:
Email:
Date:
-------------------------------------------------------
Assign to and add contents of registers.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

mov r0, #9       // Store decimal 9 in register r0
mov r1, #14     // Store hex E (decimal 14) in register r1
add r2, r1, r0  // Add the contents of r0 and r1 and put result in r2
mov r3, #8		//store value of 8 in r3
add r3, r3, r3	// try storing a new value in r3 that is old r3 plus old r3
mov r5 , #4
add r4, #5 , r5
// End program
_stop:
b _stop