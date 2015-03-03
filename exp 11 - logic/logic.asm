.CSEG
.ORG 0x01

;----PORTS----------------
.EQU TCCR            = 0xFF
.EQU TCCNT2          = 0xFE
.EQU TCCNT1          = 0xFD
.EQU TCCNT0          = 0xFC
.EQU SWITCHES        = 0x20
.EQU LEDS            = 0x40

;-------------------------

;---NUMERIC CONSTANTS-----
; --For Prescale
.EQU PRESCALE_OFF    = 0x02
.EQU PRESCALE_ON     = 0x82

; --Use to set TCCNT to 2 Hz
; 12,500,000 --> 0xBEBC20
.EQU TWOHZA          = 0xBE
.EQU TWOHZB          = 0xBC
.EQU TWOHZC          = 0x20

; --Use to set TCCNT to 10 Hz
;  2,500,000 --> 0x2625A0
:.EQU TENHZA         = 0x26
.EQU TENHZB          = 0xBC
.EQU TENHZC          = 0x20


.EQU TENHZ           = 0x01
.EQU TWOHZ           = 0x80


;---REGISTER MAP---------------
; r0  => in from switches
; r1  => upper byte of counter
; r2  => middl byte of counter
; r3  => lower byte of counter
; r4  => Holds prescale
; r5  => LED out
;------------------------------

main:       SEI
            MOV      r0, TWOHZ
            CALL     switch_dec
            BRN      main


;---------------------------------
; Decodes the input from the switches and sets
; registers r1 to r3 accordingly to the input from the switches.
; Also sets r4 to hold the appropriate prescale.
;
; Dependant Registers:
;          r0: Input from switches used to decode.
; Independant Registers:
;  r1, r2, r3: Changed to hold the value of the 3-byte long count limit for TCCNT.
;          r4: Appropriate prescale is placed in here, depending if we are flashing the LED
;              at a 2 Hz or 10 Hz frequency
;          r5: Clear the LEDs in case an illegal state is given.
;---------------------------------
switch_dec: IN       r0, SWITCHES
two_check:  CMP      r0, TWOHZ
            BRNE     ten_check
            MOV      r1, TWOHZA
            MOV      r2, TWOHZB
            MOV      r3, TWOHZC
            BRN      prescale
ten_check:  CMP      r0, TENHZ
            BRNE     def_action
            MOV      r1, TENHZA
            MOV      r2, TENHZB
            MOV      r3, TENHZC
            BRN      prescale
def_action: MOV      r4, PRESCALE_OFF
            MOV      r1, 0x00
            RET
prescale:   MOV      r4, PRESCALE_ON
            OUT      r1, TCCNT2
            OUT      r2, TCCNT1
            OUT      r3, TCCNT0
            OUT      r4, TCCR
            RET

ISR:        EXOR     r5, 0x01
            CMP      r1, 0x00
            BRNE     isr_exit
            MOV      r5, 0x00
isr_exit:   OUT      r5, LEDS
            RETIE

.ORG 0x3FF
            BRN      ISR
