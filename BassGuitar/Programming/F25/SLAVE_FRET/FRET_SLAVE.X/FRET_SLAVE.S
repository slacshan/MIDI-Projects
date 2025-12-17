;***************************************************************************
;
;	    Filename: FRET_SLAVE.S
;	    Date: 12/04/2025
;	    File Version: 2
;	    Author: Jason Permann
;	    Co-Author: Brandon Barrera, Payden Hosknis
;	    Company: Idaho State University
;	    Description: A Program for a slave I2C device that can set one of
;				12 frets on a bass guitar
			    
;**************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 12/12/2025
;
;*************************************************************************
    
; PIC16F1788 Configuration Bit Settings

; Assembly source line config statements
	#include <xc.inc>
	#include "pic16f1788.inc"
	#include "88SetUp.inc"
	#include "I2C_READ.inc"
	
; CONFIG1
  CONFIG  FOSC = INTOSC         ; Oscillator Selection (INTOSC oscillator: I/O function on CLKIN pin)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable (WDT disabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable (PWRT disabled)
  CONFIG  MCLRE = ON            ; MCLR Pin Function Select (MCLR/VPP pin function is MCLR)
  CONFIG  CP = OFF              ; Flash Program Memory Code Protection (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Memory Code Protection (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable (Brown-out Reset disabled)
  CONFIG  CLKOUTEN = ON         ; Clock Out Enable (CLKOUT function is enabled on the CLKOUT pin)
  CONFIG  IESO = OFF            ; Internal/External Switchover (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable (Fail-Safe Clock Monitor is disabled)

; CONFIG2
  CONFIG  WRT = OFF             ; Flash Memory Self-Write Protection (Write protection off)
  CONFIG  VCAPEN = OFF          ; Voltage Regulator Capacitor Enable bit (Vcap functionality is disabled on RA6.)
  CONFIG  PLLEN = OFF           ; PLL Enable (4x PLL enabled)
  CONFIG  STVREN = OFF          ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will not cause a Reset)
  CONFIG  BORV = HI             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), high trip point selected.)
  CONFIG  LPBOR = OFF           ; Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
  CONFIG  DEBUG = OFF           ; In-Circuit Debugger Mode (In-Circuit Debugger disabled, ICSPCLK and ICSPDAT are general purpose I/O pins)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

;Properties
;-Wl,-presetVect=0h,-pisrVect=04,-pnotes=08h,-pcode=F0h
  ;pnotes must be notes rather than note, as note created a compiling error
  ;pcode must be equal to 89h or higher, so the notes table has enough room in PCL
  
; Code Section
;-------------------------------------------------------------------------------
    
;Register/Variable Setup
DATA_BYTE			EQU	0X070
DATA_RX_1			EQU	0X071
DATA_RX_2			EQU	0X072
DATA_RX_3			EQU	0X073
BANK_SAVE			EQU	0x074
W_SAVE				EQU	0x075
;Start Of Program
    PSECT resetVect,class=CODE,delta=2	;Reset Vector Adress
    GOTO    SETUP
    
    PSECT isrVect,class=CODE,delta=2
    GOTO    INTERUPT_HANDLER
;Setup Code That Runs Once At Power Up/Reset
    PSECT notes,class=CODE,delta=2 
;<editor-fold defaultstate="collapsed" desc="Look Up Table">
NOTE_TABLE:
    ADDWF   PCL,1   ;ADD working register (NOTE) to program counter  
    GOTO    OFR	;0
    GOTO    OFR	;1
    GOTO    OFR	;2
    GOTO    OFR	;3
    GOTO    OFR	;4
    GOTO    OFR	;5
    GOTO    OFR	;6
    GOTO    OFR	;7
    GOTO    OFR	;8
    GOTO    OFR	;9
    GOTO    OFR	;10
    GOTO    OFR	;11
    GOTO    OFR	;12
    GOTO    OFR	;13
    GOTO    OFR	;14
    GOTO    OFR	;15
    GOTO    OFR	;16
    GOTO    OFR ;17
    GOTO    OFR	;18
    GOTO    OFR	;19
    GOTO    OFR	;20
    GOTO    OFR	;21
    GOTO    OFR	;22
    GOTO    OFR	;23
    GOTO    OFR	;24
    GOTO    OFR	;25
    GOTO    OFR	;26
    GOTO    OFR	;27
    GOTO    F0	;28
    GOTO    F1	;29
    GOTO    F2	;30
    GOTO    F3	;31
    GOTO    F4	;32
    GOTO    F5	;33
    GOTO    F6	;34
    GOTO    F7	;35
    GOTO    F8	;36
    GOTO    F9	;37
    GOTO    F10	;38
    GOTO    F11	;39
    GOTO    F12	;40
    GOTO    OFR	;41
    GOTO    OFR	;42
    GOTO    OFR	;43
    GOTO    F11	;44
    GOTO    F12	;45
    GOTO    OFR	;46
    GOTO    OFR	;47
    GOTO    OFR	;48
    GOTO    F11	;49
    GOTO    F12	;50   
    GOTO    OFR	;51
    GOTO    OFR	;52
    GOTO    OFR	;53
    GOTO    F11	;54
    GOTO    F12	;55
    GOTO    OFR	;56
    GOTO    OFR	;57
    GOTO    OFR	;58
    GOTO    OFR	;59
    GOTO    OFR	;60
    GOTO    OFR	;61
    GOTO    OFR	;62
    GOTO    OFR	;63
    GOTO    OFR	;64
    GOTO    OFR	;65
    GOTO    OFR	;66
    GOTO    OFR	;67
    GOTO    OFR ;68
    GOTO    OFR	;69
    GOTO    OFR	;70
    GOTO    OFR	;71
    GOTO    OFR	;72
    GOTO    OFR	;73
    GOTO    OFR	;74
    GOTO    OFR	;75
    GOTO    OFR	;76
    GOTO    OFR	;77
    GOTO    OFR	;78
    GOTO    OFR	;79
    GOTO    OFR	;80
    GOTO    OFR	;81
    GOTO    OFR	;82
    GOTO    OFR	;83
    GOTO    OFR	;84
    GOTO    OFR	;85
    GOTO    OFR	;86
    GOTO    OFR	;87
    GOTO    OFR	;88
    GOTO    OFR	;89
    GOTO    OFR	;90
    GOTO    OFR	;91
    GOTO    OFR	;92
    GOTO    OFR	;93
    GOTO    OFR	;94
    GOTO    OFR	;95
    GOTO    OFR	;96
    GOTO    OFR	;97
    GOTO    OFR	;98
    GOTO    OFR	;99
    GOTO    OFR	;100    
    GOTO    OFR	;101
    GOTO    OFR	;102
    GOTO    OFR	;103
    GOTO    OFR	;104
    GOTO    OFR	;105
    GOTO    OFR	;106
    GOTO    OFR	;107
    GOTO    OFR	;108
    GOTO    OFR	;109
    GOTO    OFR	;110
    GOTO    OFR	;111
    GOTO    OFR	;112
    GOTO    OFR	;113
    GOTO    OFR	;114
    GOTO    OFR	;115
    GOTO    OFR	;116
    GOTO    OFR ;117
    GOTO    OFR	;118
    GOTO    OFR	;119
    GOTO    OFR	;120
    GOTO    OFR	;121
    GOTO    OFR	;122
    GOTO    OFR	;123
    GOTO    OFR	;124
    GOTO    OFR	;125
    GOTO    OFR	;126
    GOTO    OFR	;127;</editor-fold>
; Setup Code That Runs Once At Power Up/Reset
    PSECT code,class=CODE,delta=2
;-------------------------------------------------------------------------------
;<editor-fold defaultstate="collapsed" desc="MAIN">
MAIN:
    BANKSEL	PORTC
    BTFSC	PORTC,2
    GOTO	RX_HANDLER  ;Subroutine for handling a I2C RX
    GOTO	MAIN;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="INTERUPT HANDLER">
INTERUPT_HANDLER:
    MOVWF W_SAVE		
    MOVF BSR, 0		;Save Bank & W
    MOVWF BANK_SAVE
    
    CALL	PORT_RESET
    
    CALL	I2C_READ
    
    MOVF BANK_SAVE, 0	
    MOVWF BSR		;Restore Bank & W
    MOVF W_SAVE, 0
    
    RETFIE;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="RX_HANDLER">
RX_HANDLER:    
    BANKSEL	PORTC
    BCF		PORTC,2
    
    BTFSC	DATA_RX_1,4 ;Check if upper nibble of command byte is a note on or off (8 or 9) 
    GOTO	GRAB_NOTE	;Subroutine for when command byte is note on
    
    CALL	PORT_RESET
    GOTO	MAIN;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="Use Note Data">
GRAB_NOTE:
    MOVF	DATA_RX_2,0	;Move Note value to W
    GOTO	NOTE_TABLE	;Look up table that for all available notes (0-127)
    ;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Fret Handler">
F0:;no fret pressed
    GOTO	MAIN		    ;All functions complete go back to main
F1:  
    BANKSEL	PORTB
    BCF		PORTB,0		    ;set Fret 1
    GOTO	MAIN		    ;All functions complete go back to main
F2:
    BANKSEL	PORTC
    BCF		PORTC,7		    ;set Fret 2
    GOTO	MAIN		    ;All functions complete go back to main
F3:
    BANKSEL	PORTC
    BCF		PORTC,6		    ;set Fret 3
    GOTO	MAIN		    ;All functions complete go back to main
F4:
    BANKSEL	PORTC
    BCF		PORTC,5		    ;set Fret 4
    GOTO	MAIN		    ;All functions complete go back to main
F5:
    BANKSEL	PORTB
    BCF		PORTB,4		    ;set Fret 5
    GOTO	MAIN		    ;All functions complete go back to main
F6:
    BANKSEL	PORTB
    BCF		PORTB,3		    ;set Fret 6
    GOTO	MAIN		    ;All functions complete go back to main
F7:
    BANKSEL	PORTB
    BCF		PORTB,2		    ;set Fret 7
    GOTO	MAIN		    ;All functions complete go back to main
F8:
    BANKSEL	PORTB
    BCF		PORTB,1		    ;set Fret 8 
    GOTO	MAIN		    ;All functions complete go back to main
F9:
    BANKSEL	PORTA
    BCF		PORTA,3		    ;set Fret 9
    GOTO	MAIN		    ;All functions complete go back to main
F10:
    BANKSEL	PORTA
    BCF		PORTA,2		    ;set Fret 10
    GOTO	MAIN		    ;All functions complete go back to main
F11:
    BANKSEL	PORTA
    BCF		PORTA,1		    ;set Fret 11
    GOTO	MAIN		    ;All functions complete go back to main
F12:
    BANKSEL	PORTA
    BCF		PORTA,0		    ;set Fret 12 	
    GOTO	MAIN		    ;All functions complete go back to main
OFR:;OUT OF RANGE (no fret pressed)
    GOTO	MAIN		    ;All functions complete go back to main
    ;</editor-fold>


;<editor-fold defaultstate="collapsed" desc="PORT RESET">
PORT_RESET:	;Set all Ports HIGH to reset any Fret that was energized
    BANKSEL	PORTA
    MOVLW	0xFF
    MOVWF	PORTA
 
    BANKSEL	PORTB
    MOVLW	0xFF
    MOVWF	PORTB
 
    BANKSEL	PORTC
    MOVLW	0xFB	;LEAVE OUT STATUS LED
    MOVWF	PORTC
 
    RETURN;</editor-fold>

;Subroutines Section
;-------------------------------------------------------------------------------
;<editor-fold defaultstate="collapsed" desc="Sub for all Setup routines">
SETUP:
    CALL    SETUP88		    ;Call is needed as the setup88 include file has a return at the end
    CALL    I2C_SETUP_PERIPHERAL		    ;Call is needed as the I2C interupt include file has a return at the end of the peripheral setup
    CALL    POWER_ON		    ;Set POWER ON LED
    GOTO    MAIN;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="Power On">
POWER_ON:
    BANKSEL	PORTC
    BSF		PORTC,1	    ;Turn on Power LED
    RETURN;</editor-fold>

;-------------------------------------------------------------------------------
    
 END 