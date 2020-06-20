@ This file is part of the Team 28 Project
@ Licensing information can be found in the LICENSE file
@ (C) 2014 The Team 28 Authors. All rights reserved.

@ ------------------------------------------------------------------------------
@ System timer
@ ------------------------------------------------------------------------------
.equ STIMER_CS,        0x3F003000
.equ STIMER_CLO,       0x3F003004
.equ STIMER_CHI,       0x3F003008
.equ STIMER_C0,        0x3F00300C
.equ STIMER_C1,        0x3F003010
.equ STIMER_C2,        0x3F003014
.equ STIMER_C3,        0x3F003018

@ ------------------------------------------------------------------------------
@ Interrupt register
@ ------------------------------------------------------------------------------
.equ IRQ_PENDING,      0x3F00B200
.equ IRQ_GPU_PENDING1, 0x3F00B204
.equ IRQ_GPU_PENDING2, 0x3F00B208
.equ IRQ_FIQ,          0x3F00B20C
.equ IRQ_EN1,          0x3F00B210
.equ IRQ_EN2,          0x3F00B214
.equ IRQ_ENB,          0x3F00B218
.equ IRQ_DS1,          0x3F00B21C
.equ IRQ_DS2,          0x3F00B220
.equ IRQ_DSB,          0x3F00B224

@ ------------------------------------------------------------------------------
@ ARM timer
@ ------------------------------------------------------------------------------
.equ TIMER_LOD,        0x3F00B400
.equ TIMER_VAL,        0x3F00B404
.equ TIMER_CTL,        0x3F00B408
.equ TIMER_CLI,        0x3F00B40C
.equ TIMER_RIS,        0x3F00B410
.equ TIMER_MIS,        0x3F00B414
.equ TIMER_RLD,        0x3F00B418
.equ TIMER_DIV,        0x3F00B41C
.equ TIMER_CNT,        0x3F00B420

@ ------------------------------------------------------------------------------
@ Mailbox Ports
@ ------------------------------------------------------------------------------
.equ MBOX_BASE,        0x3F00B880
.equ MBOX_READ,        0x3F00B880
.equ MBOX_POLL,        0x3F00B890
.equ MBOX_SENDER,      0x3F00B894
.equ MBOX_STATUS,      0x3F00B898
.equ MBOX_CONFIG,      0x3F00B89C
.equ MBOX_WRITE,       0x3F00B8A0

@ ------------------------------------------------------------------------------
@ GPIO Ports
@ ------------------------------------------------------------------------------
.equ GPIO_FSEL0,       0x3F200000
.equ GPIO_FSEL1,       0x3F200004
.equ GPIO_FSEL2,       0x3F200008
.equ GPIO_FSEL3,       0x3F20000C
.equ GPIO_FSEL4,       0x3F200010
.equ GPIO_FSEL5,       0x3F200014
.equ GPIO_SET0,        0x3F20001C
.equ GPIO_SET1,        0x3F200020
.equ GPIO_CLR0,        0x3F200028
.equ GPIO_CLR1,        0x3F20002C
.equ GPIO_LEV0,        0x3F200034
.equ GPIO_LEV1,        0x3F200038
.equ GPIO_EDS0,        0x3F200040
.equ GPIO_EDS1,        0x3F200044
.equ GPIO_REN0,        0x3F20004C
.equ GPIO_REN1,        0x3F200050
.equ GPIO_FEN0,        0x3F200058
.equ GPIO_FEN1,        0x3F20005C
.equ GPIO_HEN0,        0x3F200064
.equ GPIO_HEN1,        0x3F200068
.equ GPIO_LEN0,        0x3F200070
.equ GPIO_LEN1,        0x3F200074
.equ GPIO_AREN0,       0x3F20007C
.equ GPIO_AREN1,       0x3F200080
.equ GPIO_AFEN0,       0x3F200088
.equ GPIO_AFEN1,       0x3F20008C
.equ GPIO_PUD,         0x3F200094
.equ GPIO_UDCLK0,      0x3F200098
.equ GPIO_UDCLK1,      0x3F20009C

@ ------------------------------------------------------------------------------
@ PL011 UART Ports
@ ------------------------------------------------------------------------------
.equ UART_DR,          0x3F201000
.equ UART_RSECR,       0x3F201004
.equ UART_FR,          0x3F201018
.equ UART_ILPR,        0x3F201020
.equ UART_IBRD,        0x3F201024
.equ UART_FBRC,        0x3F201028
.equ UART_LCRH,        0x3F20102C
.equ UART_CR,          0x3F201030
.equ UART_IFLS,        0x3F201034
.equ UART_IMSC,        0x3F201038
.equ UART_RIS,         0x3F20103C
.equ UART_MIS,         0x3F201040
.equ UART_ICR,         0x3F201044
.equ UART_DMACR,       0x3F201048
.equ UART_ITCR,        0x3F201080
.equ UART_ITIP,        0x3F201084
.equ UART_ITOP,        0x3F201088
.equ UART_TDR,         0x3F20108C

@ ------------------------------------------------------------------------------
@ Clock manager
@ ------------------------------------------------------------------------------
.equ CM_PWMCTL,        0x3F1010A0
.equ CM_PWMDIV,        0x3F1010A4

@ ------------------------------------------------------------------------------
@ Direct Memory Access
@ ------------------------------------------------------------------------------
.equ DMA0_CS,          0x3F007000
.equ DMA0_CONBLK,      0x3F007004
.equ DMA_INT_STATUS,   0x3F007FE0
.equ DMA_ENABLE,       0x3F007FF0

@ ------------------------------------------------------------------------------
@ Pulse Width modulator
@ ------------------------------------------------------------------------------
.equ PWM_CTL,          0x3F20C000
.equ PWM_STA,          0x3F20C004
.equ PWM_DMAC,         0x3F20C008
.equ PWM_RNG1,         0x3F20C010
.equ PWM_DAT1,         0x3F20C014
.equ PWM_FIF1,         0x3F20C018
.equ PWM_RNG2,         0x3F20C020
.equ PWM_DAT2,         0x3F20C024
