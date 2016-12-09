/******************************************************************************************************
 * @file final_skm0213.s
 * @author Satej Mhatre
 * Code snippets are taken from: Christopher D. McMurrough from http://github.com/cmcmurrough/cse2312
 ******************************************************************************************************/

.global main
.func main

main:
    BL  _getint
    MOV R4, R0
    MOV R1, R4
    BL _printf
    BL  _getchar            @ branch to scanf procedure with return
    MOV R5, R0
    BL _check_char


_printf:
    PUSH {LR}
    LDR R0, =printf_str     @ R0 contains formatted string address
    MOV R1, R1              @ R1 contains printf argument (redundant line)
    BL printf               @ call printf
    POP {PC}

_printf_result:
    PUSH {LR}               @ push LR to stack
    LDR R0, =result_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ pop LR from stack and return

_getint:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_getchar:
    PUSH {LR}
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    POP {PC}

_scanf:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_invalid_char:
    LDR R0,=result_str      @ string at label hello_str:
    BL printf               @ call printf, where R1 is the print argument
    MOV PC, R7

_abs:
    PUSH {LR}
    VMOV S0, R1             @ move the numerator to floating point register
    VCVT.F32.S32 S0, S0     @ convert unsigned bit representation to single float
    VABS.F32 S2, S0        @ compute S2 = |S0|
    VCVT.F64.F32 D4, S2     @ covert the result to double precision for printing
    VMOV R1, R2, D4         @ split the double VFP register into two ARM registers
    BL  _printf_result      @ print the result
    POP {PC}

_square_root:
    PUSH {LR}
    VMOV S0, R1             @ move the numerator to floating point register
    VCVT.F32.U32 S0, S0     @ convert unsigned bit representation to single float
    VSQRT.F32 S2, S0        @ compute S2 = sqrt(S0)
    VCVT.F64.F32 D4, S2     @ covert the result to double precision for printing
    VMOV R1, R2, D4         @ split the double VFP register into two ARM registers
    BL  _printf_result      @ print the result
    POP {PC}

_find_pow:
    VMUL.F32 S4, S1, S2
    MOV PC, LR
_pow:
    PUSH {LR}
    BL  _getint
    MOV R6, R0
    VMOV S1, R6             @ move the numerator to floating point register
    VMOV S2, R1             @ move the numerator to floating point register
    VCVT.F32.U32 S1, S1     @ convert unsigned bit representation to single float
    VCVT.F32.U32 S2, S2     @ convert unsigned bit representation to single float
    PUSH {R1}
_pow_start:
    VMOV S4, S1
    MOV R2, #0
    CMP R2, R6
    BLT _find_pow
    BEQ _pow_finish
    B _pow_start
_pow_finish:
    POP {R1}
    VCVT.F64.F32 D4, S4     @ covert the result to double precision for printing
    VMOV R1, R2, D4         @ split the double VFP register into two ARM registers
    BL  _printf_result      @ print the result
    POP {PC}
_inverse:
    MOV PC, LR
_check_char:
    PUSH {LR}
    MOV R1, R4
    CMP R5, #'a'
    BEQ _abs
    CMP R5, #'s'
    BEQ _square_root
    CMP R5, #'p'
    BEQ _pow
    CMP R5, #'i'
    BEQ _inverse
    BNE _invalid_char
    POP {PC}


.data
read_char:      .ascii      " "
result_str:     .asciz      "%f\n"
exit_str:       .ascii      "Terminating program.\n"
format_str:     .asciz      "%f"
printf_str:     .ascii      "%f\n"