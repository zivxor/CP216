/*
-------------------------------------------------------
count1.s
-------------------------------------------------------
Author: Zivkovic Luka
ID:		169102858
Email:	zivk2858@mylaurier.ca
Date:	02-09-2026
-------------------------------------------------------
A simple count down program (bge)
-------------------------------------------------------
*/
.org 0x1000  // Start at memory location 1000
.text        // Code section
.global _start
_start:

// Store data in registers
ldr r0, =counter  // Initialize a countdown value
mov r3 , r0
TOP:
sub r3, r3, #1 // Decrement the countdown value
cmp r3, #0  // Compare the countdown value to 0
bge TOP   // Branch to top under certain conditions

_stop:
b _stop

.data

counter:
.word 5

.end