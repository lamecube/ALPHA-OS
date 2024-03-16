.syntax unified
.cpu cortex-m0plus
.thumb

.data

gpio_all_pins_mask: .word 0
gpio_even_pins_mask: .word 0

.text

@ RP2040 Section: 2.19.6.1. IO - User Bank
.equ IO_BANK0_BASE, 0x40014000
.equ IO_BANK0_GPIO_CTRL_BASE, IO_BANK0_BASE + 0x04

.equ FUNCSEL_SIO, 5
.equ GPIO_FUNCSEL, FUNCSEL_SIO
.equ GPIO_INIT_VALUE, (GPIO_FUNCSEL<<0)

@ RP2040 Section: 2.19.6.3. Pad Control - User Bank
.equ PADS_BANK0_BASE, 0x4001c000 
.equ PADS_BANK0_GPIO_OFFSET, 0x04 
.equ PADS_BANK0_GPIO_BASE, PADS_BANK0_BASE + PADS_BANK0_GPIO_OFFSET
@ Bit 7 - OD Output disable. Has priority over output enable from peripherals RW 0x0
@ Bit 6 - IE Input enable RW 0x1
@ Bits 5:4 - DRIVE Drive strength.
@           0x0 → 2mA
@           0x1 → 4mA
@           0x2 → 8mA
@           0x3 → 12mA
@           RW 0x1
@ Bit 3 - PUE Pull up enable RW 0x0
@ Bit 2 - PDE Pull down enable RW 0x1
@ Bit 1 - SCHMITT Enable schmitt trigger RW 0x1
@ Bit 0 - SLEWFAST Slew rate control. 1 = Fast, 0 = Slow RW 0x0
@          bit nums:   76543210
.equ PAD_INIT_VALUE, 0b00010110

@ RP2040 Section: 2.3.1. SIO
@ 2.3.1.7. List of Registers
.equ SIO_BASE, 0xd0000000
.equ GPIO_OE,     SIO_BASE + 0x020 @ GPIO output enable
.equ GPIO_OE_SET, SIO_BASE + 0x024 @ GPIO output enable set
.equ GPIO_OE_CLR, SIO_BASE + 0x028 @ GPIO output enable clear
.equ GPIO_OE_XOR, SIO_BASE + 0x02c @ GPIO output enable XOR
.equ GPIO_OUT,     SIO_BASE + 0x010 @ GPIO output value
.equ GPIO_OUT_SET, SIO_BASE + 0x014 @ GPIO output value set
.equ GPIO_OUT_CLR, SIO_BASE + 0x018 @ GPIO output value clear
.equ GPIO_OUT_XOR, SIO_BASE + 0x01c @ GPIO output value XOR

@ RP2040 Section: 4.6. Timer
@ Use TIMERAWL raw timer because we don't need the latching behaviour of TIMELR
.equ TIMER_BASE, 0x40054000
.equ TIMER_TIMERAWL, TIMER_BASE + 0x28

LEDS: .byte 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 26
LEDS_LEN = . - LEDS

.global my_main
.thumb_func
my_main:
    push    {r0-r7, lr}     @ For now we don't ever plan to return to the C world, but play it safe anyway and protect the C environment
    bl      init_all_gpios
    bl      compute_led_masks
    bl      flash_leds
    pop     {r0-r7, pc}

.thumb_func
init_all_gpios:
    push    {r0-r2, LR}
    @ Usage:
    @ r0 - reserved for calling init_single_gpio
    @ r1 - base address of LED numbers array
    @ r2 - initially offset of last value in LED numbers array, then counted down
    ldr     r1, =LEDS
    movs    r2, #LEDS_LEN-1
_init_all_gpios_loop:
    ldrb    r0, [r1, r2]
    bl      init_single_gpio
    subs    r2, r2, #1
    bpl     _init_all_gpios_loop
    pop     {r0-r2, PC}

.thumb_func
init_single_gpio:
    @ Input:
    @ r0 - LED number
    push    {r1-r3, LR}
    @ Usage:
    @ r1 - base addresses
    @ r2 - computed address offsets
    @ r3 - (computed) values to set in register

    @ init IO_BANK0 register
    ldr     r1, =IO_BANK0_GPIO_CTRL_BASE
    ldr     r3, =GPIO_INIT_VALUE    @ Load early to reduce stall cycles (Probably makes no difference on Cortex M0+!)
    lsls    r2, r0, #3      @ Multiply LED number by 8 because IO_BANK0 config is pairs of 32 bit, 4 byte registers
    str     r3, [r1, r2]

    @ init PAD
    ldr     r1, =PADS_BANK0_GPIO_BASE
    ldr     r3, =PAD_INIT_VALUE    @ Load early to reduce stall cycles (Probably makes no difference on Cortex M0+!)
    lsls    r2, r0, #2      @ Multiply LED number by 4 as 4 bytes per registers
    str     r3, [r1, r2]

    @ init SIO (Set low, output enable)
    movs    r3, #1
    lsls    r3, r3, r0
    ldr     r1, =GPIO_OUT_CLR
    str     r3, [r1]
    ldr     r1, =GPIO_OE_SET
    str     r3, [r1]

    pop     {r1-r3, PC}

compute_led_masks:
    push    {r0-r6, LR}
    @ Usage:
    @ r0 - base address of LED numbers array
    @ r1 - initially offset of last value in LED numbers array, then counted down
    @ r2 - computed gpio_all_pins_mask
    @ r3 - computed gpio_even_pins_mask
    @ r4 - value read from array
    @ r5 - update value
    @ r6 - immediate value #1!
    ldr     r0, =LEDS
    movs    r1, #LEDS_LEN-1
    movs    r2, #0
    movs    r3, #0
    movs    r6, #1
_compute_led_masks_loop:
    ldrb    r4, [r0, r1]                @ Load LED number
    movs    r5, #1                      @ Compute bit to update
    lsls    r5, r4                      @ ...
    orrs    r2, r2, r5                  @ Insert bit into gpio_all_pins_mask
    tst     r1, r6                      @ Test if even/odd
    bne     _compute_led_masks_skip_odd
    orrs    r3, r3, r5                  @ Conditionally insert bit into gpio_even_pins_mask
_compute_led_masks_skip_odd:
    subs    r1, r1, #1                  @ Move on to next LED number
    cmp     r1, #0                      @ Loop if more LEDs to do
    bpl     _compute_led_masks_loop     @ ...
    ldr     r5, =gpio_all_pins_mask     @ Save computed gpio_all_pins_mask value
    str     r2, [r5]                    @ ...
    ldr     r5, =gpio_even_pins_mask    @ Save computed gpio_even_pins_mask value
    str     r3, [r5]                    @ ...
    pop     {r0-r6, PC}

.thumb_func
flash_leds:
    push    {r0-r2, LR}
    ldr     r0, =gpio_even_pins_mask    @ Set even pins high
    ldr     r0, [r0]                    @ ...
    ldr     r1, =GPIO_OUT_SET
    str     r0, [r1]
    ldr     r0, =gpio_all_pins_mask     @ Load all pins mask
    ldr     r0, [r0]                    @ ...
    ldr     r1, =GPIO_OUT_XOR           @ Load GPIO XOR register address
_flash_leds_loop:
    bl      wait_1_second
    str     r0, [r1]                    @ Invert output pins
    b       _flash_leds_loop
    @ Never returns

.thumb_func
wait_1_second:
    push    {r0-r3, LR}
    @ Usage:
    @ r0 - 1 million
    @ r1 - TIMER_TIMERAWL address
    @ r2 - start time
    @ r3 - current time and delta time
    ldr     r0, =#1000000
    ldr     r1, =TIMER_TIMERAWL
    ldr     r2, [r1]
_wait_1_second_loop:
    ldr     r3, [r1]
    subs    r3, r3, r2  @ r3 = delta time
    cmp     r3, r0      @ compare to 1 million
    blt     _wait_1_second_loop
    pop     {r0-r3, PC}