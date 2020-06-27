@ This file is part of the Team 28 Project
@ Licensing information can be found in the LICENSE file
@ (C) 2014 The Team 28 Authors. All rights reserved.
.global start

.include "ports.s"

.section .text
@ ------------------------------------------------------------------------------
@ Entry point of the application
@ ------------------------------------------------------------------------------
kernel:
  bl        setup_core
  bl        setup_uart
  bl        setup_mode
  bl        setup_stack
  bl        setup_ivt
  bl        setup_vfp
  bl        setup_gfx
  bl        setup_cache
  bl        setup_input
  bl        setup_sound
  b         setup_game

setup_core:
  mrc       p15,0,r0,c0,c0,5
  ands      r0,#3
  bne       hang
  mov       pc, lr

@ ------------------------------------------------------------------------------
@ Enter Supervisor Mode (EL1) from other EL1 mode, or from Hypervisor mode (EL2)
@
@ See:
@   * https://github.com/vanvught/rpidmx512/blob/28aacaf229e097eb0b3ba692de6ff89111b22977/firmware-template/vectors.s
@   * https://github.com/torvalds/linux/blob/097f70b3c4d84ffccca15195bdfde3a37c0a7c0f/arch/arm/include/asm/assembler.h#L331-L361
@   * https://github.com/alexhoppus/rpios/blob/master/uart_bootloader/boot.S
@   * https://github.com/dwelch67/raspberrypi/tree/master/boards/pi3/aarch32/SVC
@   * https://www.raspberrypi.org/forums/viewtopic.php?f=72&t=138201
@ ------------------------------------------------------------------------------
setup_mode:
  mov       r10, lr
  cpsid     if              @ Disable IRQ & FIQ

@ HCPTR = 0x000033FF = 0000 0000 0000 0000 0011 0011 1111 1111
@   bits set: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13
@   => no traps set at all

@ CPSR  = 0x200001DA = 0010 0000 0000 0000 0000 0001 1101 1010
@   bits set: 1, 3, 4, 6, 7, 8, 29
@   M = 0xA => Hyp mode
@   F = 0x1 => FIQ masked
@   I = 0x1 => IRQ masked
@   A = 0x1 => SError (abort) interrupt masked
@   E = 0x0 => Little endian
@   GE = 0x0
@   DIT = 0x0 => The architecture makes no statement about the timing properties of any instructions.
@   PAN = 0x0 => The translation system is the same as ARMv8.0.
@   Q = 0x0
@   V = 0x0
@   C = 0x1
@   Z = 0x0
@   N = 0x0

  mrs       r0, cpsr        @ Check for HYP mode
  eor       r0, r0, #0x1A   @ Flip bits 1, 3, 4
  tst       r0, #0x1F       @ Set Z flag if mode == HYP
  bic       r0, r0, #0x1F   @ Clear mode and bit 4 (RES 1)
  orr       r0, r0, #0xD3   @ Mask IRQ/FIQ bits and set SVC mode
  bne       2f              @ Jump to 2f if not HYP mode
  orr       r0, r0, #0x100  @ Mask Abort (SError) bit
  adr       lr, 3f          @ Prepare return address for SVC mode as label 3f
  msr       spsr_cxsf, r0   @ Prepare PSTATE for SVC mode
  msr       ELR_hyp, lr     @ Set return address
  eret                      @ Switch to Supervisor mode and jump to label 3f
2:
  msr       cpsr_c, r0      @ Update only the mode and IRQ/FIQ mask bits
3:
  mov       pc, r10

@ ------------------------------------------------------------------------------
@ Sets up stacks for all EL1 operating modes
@ ------------------------------------------------------------------------------
setup_stack:
  mov       r0, #0xD1       @ FIQ
  msr       cpsr_c, r0
  ldr       sp, =stack_fiq
  mov       r0, #0xD2       @ IRQ
  msr       cpsr_c, r0
  ldr       sp, =stack_irq
  mov       r0, #0xD7       @ ABT
  msr       cpsr_c, r0
  ldr       sp, =stack_abt
  mov       r0, #0xDB       @ UND
  msr       cpsr_c, r0
  ldr       sp, =stack_und
  mov       r0, #0xDF       @ SYS
  msr       cpsr_c, r0
  ldr       sp, =stack_sys
  mov       r0, #0xD3       @ SVC
  msr       cpsr_c, r0
  ldr       sp, =stack_svc

@ CPSR  = 0x200001D3 = 0010 0000 0000 0000 0000 0001 1101 0011
@   bits set: 0, 1, 4, 6, 7, 8, 29
@   M = 0x3 => Supervisor mode
@   F = 0x1 => FIQ masked
@   I = 0x1 => IRQ masked
@   A = 0x1 => SError interrupt masked
@   E = 0x0 => Little endian
@   GE = 0x0
@   DIT = 0x0 => The architecture makes no statement about the timing properties of any instructions.
@   PAN = 0x0 => The translation system is the same as ARMv8.0.
@   Q = 0x0
@   V = 0x0
@   C = 0x1
@   Z = 0x0
@   N = 0x0

  mov       pc, lr

@ ------------------------------------------------------------------------------
@ Never returns; loops forever, waiting for interrupts
@ ------------------------------------------------------------------------------
hang:
  wfi                       @ Wait for interrupt; like 'wfe' but more sleepy
  b         hang

@ ------------------------------------------------------------------------------
@ Relocates the interrupt vector table to start of RAM
@ ------------------------------------------------------------------------------
setup_ivt:
  ldr       r10, =ivt_start
  ldr       r11, =0x00000000
  ldm       r10!, {r0 - r7}
  stm       r11!, {r0 - r7}
  ldm       r10,  {r0 - r7}
  stm       r11,  {r0 - r7}
  mov       pc, lr

@ ------------------------------------------------------------------------------
@ Enables the L1 cache
@ ------------------------------------------------------------------------------
setup_cache:
@ mov       r0, #0
@ mcr       p15, 0, r0, c7, c7, 0     @ Invalidate caches
@ mcr       p15, 0, r0, c8, c7, 0     @ Invalidate TLB
  mrc       p15, 0, r0, c1, c0, 0     @ r0 = SCTLR
  ldr       r1, =0x1004               @ r1 = data cache enable        (0x0004)
                                      @    & instruction cache enable (0x1000)
  orr       r0, r0, r1                @ Mask bits on
  mcr       p15, 0, r0, c1, c0, 0     @ Apply update

@ SCTLR = 0x00C5183C = 0000 0000 1100 0101 0001 1000 0011 1100
@   bits set: 2, 3, 4, 5, 11, 12, 16, 18, 22, 23

@ VBAR  = 0x00000000 = 0000 0000 0000 0000 0000 0000 0000 0000

  mov       pc, lr

@ ------------------------------------------------------------------------------
@ Enables the vectored floating point unit
@ ------------------------------------------------------------------------------
setup_vfp:
  mrc       p15, 0, r0, c1, c0, 2
  orr       r0, r0, #0xF00000         @ Single + double precision
  mcr       p15, 0, r0, c1, c0, 2

@ FPEXC = 0x00000700
@   bits set: 8, 9, 10, 30
@   => standard defaults, no exceptions or special handling etc

  vmrs      r0, fpexc
  orr       r0, #0x40000000           @ Set VFP enable bit
  vmsr      fpexc, r0

@ NSACR = 0x00000C00 = 0000 0000 0000 0000 0000 1100 0000 0000
@   bits set: 10, 11
@   cp10/cp11 "Advanced SIMD and floating-point features can be accessed from both Security states"

@ CPACR = 0x00F00000 = 0000 0000 1111 0000 0000 0000 0000 0000
@   bits set: 20, 21, 22, 23
@   cp10/cp11 "This control permits full access to the floating-point and Advanced SIMD functionality from PL0 and PL1"
@   "The CPACR has no effect on floating-point and Advanced SIMD accesses from PL2. These can be disabled by the HCPTR.TCP10 field."

  mov       pc, lr

@ ------------------------------------------------------------------------------
@ Interrupt vector table
@
@ On startup, this table has to be relocated to the start of memory.
@ It contains jump to interrupt handlers.
@ ------------------------------------------------------------------------------
ivt_start:
.rept 8
  ldr pc, [pc, #0x18]
.endr
.word handler_hang
.word handler_undef
.word handler_hang
.word handler_hang
.word handler_hang
.word .
.word handler_hang
.word handler_hang

@ ------------------------------------------------------------------------------
@ Hang when something bad happens
@ ------------------------------------------------------------------------------
handler_hang:
  b         .

@ ------------------------------------------------------------------------------
@ Undefined instructions - clears FP exception bit
@ Like pro windows devs, we put a shitton of effort
@ into making an awesome, blue panic screeen
@ ------------------------------------------------------------------------------
handler_undef:
  @ Reset VFP
  mov         r0, #0x40000000
  fmxr        fpexc, r0

  @ Arguments for printf
  vstm.f32    sp!, {s0 - s31}
  stmfd       sp!, {r0 - r12}
  stmfd       sp!, {lr}

  @ Nice blue background
  ldr         r0, =0xFF0000FF
  bl          gfx_clear

  @ Print address
  ldr         r0, =1f
  mov         r1, #100
  mov         r2, #100
  ldr         r3, =0xFFFFFFFF
  bl          printf
  add         sp, sp, #4

  @ Present error message
  bl          gfx_swap

  @ Hang
  b           .

1:
  .ascii      "VFP crashed:\n"
  .ascii      " PC: %8x\n"
  .ascii      " r0: %8x   r1: %8x   r2: %8x   r3: %8x\n"
  .ascii      " r4: %8x   r5: %8x   r6: %8x   r7: %8x\n"
  .ascii      " r8: %8x   r9: %8x  r10: %8x  r11: %8x\n"
  .ascii      " s0: %8x   s1: %8x   s2: %8x   s3: %8x\n"
  .ascii      " s4: %8x   s5: %8x   s6: %8x   s7: %8x\n"
  .ascii      " s8: %8x   s9: %8x  s10: %8x  s11: %8x\n"
  .ascii      "s12: %8x  s13: %8x  s14: %8x  s15: %8x\n"
  .ascii      "s16: %8x  s17: %8x  s18: %8x  s19: %8x\n"
  .ascii      "s20: %8x  s21: %8x  s22: %8x  s23: %8x\n"
  .ascii      "s24: %8x  s25: %8x  s26: %8x  s27: %8x\n"
  .ascii      "s28: %8x  s29: %8x  s30: %8x  s31: %8x\n"
  .ascii      "\0"
  .align 2






@ ----------------------------------- TEMPORARY CODE ADDED FOR UART DEBUGGING -----------------------------------

.global    uart_send
uart_send:
    stmfd  sp!,     {fp, lr}
    add    fp, sp, #4
    sub    sp, sp, #8
    mov    r3, r0
    strb    r3, [fp, #-5]
.L4:
    ldr    r0, .L7
    ldr    r0, [r0]
    mov    r3, r0
    and    r3, r3, #32
    cmp    r3, #0
    bne    .L6
    b    .L4
.L6:
    ldrb    r3, [fp, #-5]
    mov    r1, r3
    ldr    r0, .L7+4
    str    r1,[r0]
    sub    sp, fp, #4
    ldmfd  sp!,     {fp, lr}
    bx    lr
.L8:
    .align    2
.L7:
    .word    1059147860
    .word    1059147840


.global    uart_recv
uart_recv:
    stmfd  sp!,     {fp, lr}
    add    fp, sp, #4
.L12:
    ldr    r0, .L16
    ldr    r0, [r0]
    mov    r3, r0
    and    r3, r3, #1
    cmp    r3, #0
    bne    .L15
    b    .L12
.L15:
    ldr    r0, .L16+4
    ldr    r0, [r0]
    mov    r3, r0
    and    r3, r3, #255
    mov    r0, r3
    sub    sp, fp, #4
    ldmfd  sp!,     {fp, lr}
    mov pc, lr
.L17:
    .align    2
.L16:
    .word    1059147860
    .word    1059147840


setup_uart:
    stmfd  sp!,     {fp, lr}
    add    fp, sp, #4
    sub    sp, sp, #8
    ldr    r0, .L22
    ldr    r0, [r0]
    str    r0, [fp, #-8]
    ldr    r3, [fp, #-8]
    bic    r3, r3, #28672
    str    r3, [fp, #-8]
    ldr    r3, [fp, #-8]
    orr    r3, r3, #8192
    str    r3, [fp, #-8]
    ldr    r3, [fp, #-8]
    bic    r3, r3, #229376
    str    r3, [fp, #-8]
    ldr    r3, [fp, #-8]
    orr    r3, r3, #65536
    str    r3, [fp, #-8]
    ldr    r1, [fp, #-8]
    ldr    r0, .L22
    str    r1,[r0]
    mov    r1, #0
    ldr    r0, .L22+4
    str    r1,[r0]
    mov    r0, #150
1:  subs   r0, r0, #1
    bne    1b
    mov    r1, #49152
    ldr    r0, .L22+8
    str    r1,[r0]
    mov    r0, #150
2:  subs   r0, r0, #1
    bne    2b
    mov    r1, #0
    ldr    r0, .L22+8
    str    r1,[r0]
    mov    r1, #1
    ldr    r0, .L22+12
    str    r1,[r0]
    mov    r1, #0
    ldr    r0, .L22+16
    str    r1,[r0]
    mov    r1, #0
    ldr    r0, .L22+20
    str    r1,[r0]
    mov    r1, #3
    ldr    r0, .L22+24
    str    r1,[r0]
    mov    r1, #0
    ldr    r0, .L22+28
    str    r1,[r0]
    ldr    r1, .L22+32
    ldr    r0, .L22+36
    str    r1,[r0]
    mov    r1, #3
    ldr    r0, .L22+16
    str    r1,[r0]
    sub    sp, fp, #4
    ldmfd  sp!,     {fp, lr}
    mov pc, lr
.L23:
    .align    2
.L22:
    .word    1059061764
    .word    1059061908
    .word    1059061912
    .word    1059147780
    .word    1059147872
    .word    1059147844
    .word    1059147852
    .word    1059147856
    .word    270
    .word    1059147880







@ On entry:
@   r0 = hex value to convert to text and write to uart
@   r2 = number of bits to print (multiple of 4)
.globl uart_hex_r0
uart_hex_r0:
  stmfd  sp!,     {fp, lr}

  stmfd  sp!,     {r0, r2}
  mov     r0, #'0'
  bl      uart_send
  mov     r0, #'x'
  bl      uart_send
  ldmfd  sp!,      {r0, r2}

  ror     r0, r0, r2
1:
  ror     r0, r0, #28
  and     r3, r0, #0x0f
  cmp     r3, #10
  addlo   r3, #48
  addhs   r3, #55

  stmfd  sp!,     {r0, r2}
  mov     r0, r3
  bl      uart_send
  ldmfd  sp!,      {r0, r2}

  subs    r2, r2, #4
  bne     1b
  mov     r0, #10
  bl      uart_send
  mov     r0, #13
  bl      uart_send
  ldmfd  sp!,      {fp, lr}
  mov pc, lr
