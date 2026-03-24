/*
-------------------------------------------------------
l07_t02.s
-------------------------------------------------------
Author:
ID:
Email:
Date:    2024-02-22
-------------------------------------------------------
Subroutines for determining if a string is a palindrome.
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

// Test a string to see if it is a palindrome
ldr    r4, =Test1
ldr    r5, =_Test1 - 2
bl     PrintString
bl     PrintEnter
bl     Palindrome
bl     PrintTrueFalse
bl     PrintEnter

ldr    r4, =Test2
ldr    r5, =_Test2 - 2
bl     PrintString
bl     PrintEnter
bl     Palindrome
bl     PrintTrueFalse
bl     PrintEnter

ldr    r4, =Test3
ldr    r5, =_Test3 - 2
bl     PrintString
bl     PrintEnter
bl     Palindrome
bl     PrintTrueFalse
bl     PrintEnter

ldr    r4, =Test4
ldr    r5, =_Test4 - 2
bl     PrintString
bl     PrintEnter
bl     Palindrome
bl     PrintTrueFalse
bl     PrintEnter

_stop:
b    _stop

//-------------------------------------------------------

// Constants
.equ UART_BASE, 0xff201000     // UART base address
.equ ENTER, 0x0a     // enter character
.equ VALID, 0x8000   // Valid data in UART mask
.equ DIFF, 'a' - 'A' // Difference between upper and lower case letters

//-------------------------------------------------------
PrintChar:
/*
-------------------------------------------------------
Prints single character to UART.
-------------------------------------------------------
Parameters:
  r2 - address of character to print
Uses:
  r1 - address of UART
-------------------------------------------------------
*/
stmfd   sp!, {r1, lr}
ldr     r1, =UART_BASE  // Load UART base address
strb    r2, [r1]        // copy the character to the UART DATA field
ldmfd   sp!, {r1, lr}
bx      lr

//-------------------------------------------------------
PrintString:
/*
-------------------------------------------------------
Prints a null terminated string to the UART.
-------------------------------------------------------
Parameters:
  r4 - address of string
Uses:
  r1 - address of UART
  r2 - current character to print
-------------------------------------------------------
*/
stmfd   sp!, {r1-r2, r4, lr}
ldr     r1, =UART_BASE
psLOOP:
ldrb    r2, [r4], #1     // load a single byte from the string
cmp     r2, #0           // compare to null character
beq     _PrintString     // stop when the null character is found
strb    r2, [r1]         // else copy the character to the UART DATA field
b       psLOOP
_PrintString:
ldmfd   sp!, {r1-r2, r4, lr}
bx      lr

//-------------------------------------------------------
PrintEnter:
/*
-------------------------------------------------------
Prints the ENTER character to the UART.
-------------------------------------------------------
Uses:
  r2 - holds ENTER character
-------------------------------------------------------
*/
stmfd   sp!, {r2, lr}
mov     r2, #ENTER       // Load ENTER character
bl      PrintChar
ldmfd   sp!, {r2, lr}
bx      lr

//-------------------------------------------------------
PrintTrueFalse:
/*
-------------------------------------------------------
Prints "T" or "F" as appropriate
-------------------------------------------------------
Parameter
  r0 - input parameter of 0 (false) or 1 (true)
Uses:
  r2 - 'T' or 'F' character to print
-------------------------------------------------------
*/
stmfd   sp!, {r2, lr}
cmp     r0, #0           // Is r0 False?
moveq   r2, #'F'         // load "False" message
movne   r2, #'T'         // load "True" message
bl      PrintChar
ldmfd   sp!, {r2, lr}
bx      lr

//-------------------------------------------------------
isLowerCase:
/*
-------------------------------------------------------
Determines if a character is a lower case letter.
-------------------------------------------------------
Parameters
  r2 - character to test
Returns:
  r0 - returns True (1) if lower case, False (0) otherwise
-------------------------------------------------------
*/
mov    r0, #0           // default False
cmp    r2, #'a'
blt    _isLowerCase     // less than 'a', return False
cmp    r2, #'z'
movle  r0, #1           // less than or equal to 'z', return True
_isLowerCase:
bx lr

//-------------------------------------------------------
isUpperCase:
/*
-------------------------------------------------------
Determines if a character is an upper case letter.
-------------------------------------------------------
Parameters
  r2 - character to test
Returns:
  r0 - returns True (1) if upper case, False (0) otherwise
-------------------------------------------------------
*/
mov    r0, #0           // default False
cmp    r2, #'A'
blt    _isUpperCase     // less than 'A', return False
cmp    r2, #'Z'
movle  r0, #1           // less than or equal to 'Z', return True
_isUpperCase:
bx lr

//-------------------------------------------------------
isLetter:
/*
-------------------------------------------------------
Determines if a character is a letter.
-------------------------------------------------------
Parameters
  r2 - character to test
Returns:
  r0 - returns True (1) if letter, False (0) otherwise
-------------------------------------------------------
*/
//=======================================================
// Preserve r2 and lr so the caller's copy of the character
// is not disturbed, making this routine re-entrant.
//=======================================================
stmfd   sp!, {r2, lr}

bl      isLowerCase          // test for lowercase
cmp     r0, #0
bleq    isUpperCase          // not lowercase? Test for uppercase.

ldmfd   sp!, {r2, lr}
bx      lr

//-------------------------------------------------------
toLower:
/*
-------------------------------------------------------
Converts a character to lower case.
-------------------------------------------------------
Parameters
  r2 - character to convert
Returns:
  r2 - lowercase version of character
-------------------------------------------------------
*/
stmfd   sp!, {lr}
bl      isUpperCase      // test for upper case
cmp     r0, #0
addne   r2, #DIFF        // Convert to lower case
ldmfd   sp!, {lr}
bx      lr

//-------------------------------------------------------
Palindrome:
/*
-------------------------------------------------------
Determines if a string is a palindrome.
-------------------------------------------------------
Parameters
  r4 - address of first character of string to test
  r5 - address of last character of string to test
Uses:
  r1, r2, r3, r4, r5
Returns:
  r0 - returns True (1) if palindrome, False (0) otherwise
-------------------------------------------------------
*/

//=======================================================
// Recursive palindrome checker using two pointers r4 (left)
// and r5 (right). Base case r4 >= r5 -> True. Skip any
// non-letter characters using isLetter. Compare letters
// case-insensitively using toLower, recurse inward.
//=======================================================
stmfd   sp!, {r1-r5, lr}      // save caller-saved registers and params

// base case: if r4 >= r5, string segment is a palindrome
cmp     r4, r5
bgt     Pal_true
beq     Pal_true

// check left character: is it a letter?
ldrb    r2, [r4]             // r2 = *r4
bl      isLetter
cmp     r0, #0
beq     Pal_skip_left        // non-letter on left, skip it

// left is letter; check right character
ldrb    r2, [r5]             // r2 = *r5
bl      isLetter
cmp     r0, #0
beq     Pal_skip_right       // non-letter on right, skip it

// both ends are letters: compare case-insensitive

// convert left char to lowercase
ldrb    r2, [r4]
bl      toLower
mov     r1, r2               // r1 = lowercase(*r4)

// convert right char to lowercase
ldrb    r2, [r5]
bl      toLower
mov     r3, r2               // r3 = lowercase(*r5)

// compare lowercase characters
cmp     r1, r3
bne     Pal_false            // mismatch -> not a palindrome

// characters equal: move inward and recurse
add     r4, r4, #1
sub     r5, r5, #1
bl      Palindrome           // recursive call, result in r0
b       Pal_exit

// skip non-letter on left: r4++
Pal_skip_left:
add     r4, r4, #1
bl      Palindrome
b       Pal_exit

// skip non-letter on right: r5--
Pal_skip_right:
sub     r5, r5, #1
bl      Palindrome
b       Pal_exit

Pal_true:
mov     r0, #1               // True
b       Pal_exit

Pal_false:
mov     r0, #0               // False

Pal_exit:
ldmfd   sp!, {r1-r5, lr}
bx      lr

//=======================================================

//-------------------------------------------------------
.data
Test1:
.asciz "otto"
_Test1:
Test2:
.asciz "RaceCar"
_Test2:
Test3:
.asciz "A man, a plan, a canal, Panama!"
_Test3:
Test4:
.asciz "David"
_Test4:

.end