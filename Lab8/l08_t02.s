/*
-------------------------------------------------------
l08_t02.s
-------------------------------------------------------
Author:
ID:
Email:
Date:    2024-02-21
-------------------------------------------------------
Uses a subroutine to read strings from the UART into memory.
-------------------------------------------------------
*/
// Constants
.equ SIZE, 20 // Size of string buffer storage (bytes)

.org 0x1000   // Start at memory location 1000
.text         // Code section
.global _start
_start:

//=======================================================

mov    r5, #SIZE

//=======================================================

ldr    r4, =First
bl     ReadString
ldr    r4, =Second
bl     ReadString
ldr    r4, =Third
bl     ReadString
ldr    r4, =Last
bl     ReadString

_stop:
b _stop

// Subroutine constants
.equ UART_BASE, 0xff201000  // UART base address
.equ ENTER, 0x0A            // The enter key code
.equ VALID, 0x8000          // Valid data in UART mask

ReadString:
/*
-------------------------------------------------------
Reads an ENTER terminated string from the UART.
-------------------------------------------------------
Parameters:
  r4 - address of string buffer
  r5 - size of string buffer
Uses:
  r0 - holds character to print
  r1 - address of UART
-------------------------------------------------------
*/

//=======================================================

stmfd sp!, {r0, r1, r4, r5}
ldr   r1, =UART_BASE
sub   r5, r5, #1           // leave room for null terminator

rsLOOP:
cmp   r5, #0
beq   rsDONE

ldr   r0, [r1]
tst   r0, #VALID
beq   rsDONE

and   r0, r0, #0xFF
cmp   r0, #ENTER
beq   rsNULL

strb  r0, [r4], #1
sub   r5, r5, #1
b     rsLOOP

rsNULL:
mov   r0, #0
strb  r0, [r4]
b     rsEXIT

rsDONE:
mov   r0, #0
strb  r0, [r4]

rsEXIT:
ldmfd sp!, {r0, r1, r4, r5}

//=======================================================

bx    lr                    // return from subroutine

.data
.align
// The list of strings
First:
.space  SIZE
Second:
.space SIZE
Third:
.space SIZE
Last:
.space SIZE
_Last:    // End of list address

.end