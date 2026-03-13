/*
-------------------------------------------------------
l06_t03.s
-------------------------------------------------------
*/
.equ SIZE, 80

.org 0x1000
.text
.global _start
_start:
    // r0 = &First
    ldr     r0, =First
    // r1 = &Second
    ldr     r1, =Second
    // r2 = &Common
    ldr     r2, =Common
    // r3 = SIZE
    mov     r3, #SIZE

    // push parameters: first, second, common, size
    stmfd   sp!, {r0}        // first
    stmfd   sp!, {r1}        // second
    stmfd   sp!, {r2}        // common
    stmfd   sp!, {r3}        // size

    bl      FindCommon

    // clean up parameter space
    add     sp, sp, #16

_stop:
    b       _stop

//-------------------------------------------------------
FindCommon:
/*
Equivalent of: FindCommon(*first, *second, *common, size)
*/
    //===================================================
    // prologue
    //===================================================
    stmfd   sp!, {fp}        // preserve frame pointer
    mov     fp, sp           // set frame pointer
    // no locals, so no sub sp, sp, #...
    stmfd   sp!, {r0-r5, lr} // save used regs + lr

    // Stack layout (matching lab06 style):
    // [fp, #4]  = first
    // [fp, #8]  = second
    // [fp, #12] = common
    // [fp, #16] = size
    ldr     r0, [fp, #4]     // first
    ldr     r1, [fp, #8]     // second
    ldr     r2, [fp, #12]    // common
    ldr     r3, [fp, #16]    // size

FCLoop:
    cmp     r3, #1
    beq     _FindCommon
    ldrb    r4, [r0], #1
    ldrb    r5, [r1], #1
    cmp     r4, r5
    bne     _FindCommon
    cmp     r5, #0
    beq     _FindCommon
    strb    r4, [r2], #1
    sub     r3, r3, #1
    b       FCLoop

_FindCommon:
    mov     r4, #0
    strb    r4, [r2]         // terminate common with null

    //===================================================
    // epilogue
    //===================================================
    ldmfd   sp!, {r0-r5, lr} // restore regs + lr
    ldmfd   sp!, {fp}        // restore frame pointer
    bx      lr

//-------------------------------------------------------
.data
First:
    .asciz "pandemic"
Second:
    .asciz "pandemonium"
Common:
    .space SIZE
.end
