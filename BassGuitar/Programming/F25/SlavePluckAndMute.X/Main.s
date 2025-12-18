;***************************************************************************
;
;	    Filename: Pluck_MuteTEMP.S
;	    Date: 12/05/2025
;	    File Version: 1
;	    Author: Brandon Barrera
;	    Company: Idaho State University
;	    Description: A Program for a slave I2C device that plucks & mutes 
;			 the strings of a bass guitar
    
;**************************************************************************
	
;**************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 12/05/2025
;
;*************************************************************************
    
; PIC16F1788 Configuration Bit Settings

; Assembly source line config statements

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
  CONFIG  PLLEN = OFF            ; PLL Enable (4x PLL enabled)
  CONFIG  STVREN = OFF          ; Stack Overflow/Underflow Reset Enable (Stack Overflow or Underflow will not cause a Reset)
  CONFIG  BORV = HI             ; Brown-out Reset Voltage Selection (Brown-out Reset Voltage (Vbor), high trip point selected.)
  CONFIG  LPBOR = OFF           ; Low Power Brown-Out Reset Enable Bit (Low power brown-out is disabled)
  CONFIG  DEBUG = OFF           ; In-Circuit Debugger Mode (In-Circuit Debugger disabled, ICSPCLK and ICSPDAT are general purpose I/O pins)
  CONFIG  LVP = OFF             ; Low-Voltage Programming Enable (High-voltage on MCLR/VPP must be used for programming)

// config statements should precede project file includes.
#include <xc.inc>
#include <pic16f1788.inc>

BANK_SAVE EQU 0x020
W_SAVE EQU 0x021
MIDI_STATUS EQU 0x022
MIDI_PREVIOUS_NOTE EQU 0x023
MIDI_NOTE EQU 0x024
MIDI_VELOCITY EQU 0x025
DATA_BYTE EQU 0x070
DATA_RX_1 EQU 0x071
DATA_RX_2 EQU 0x072
DATA_RX_3 EQU 0x073
TEMP EQU 0x077
COUNT1 EQU 0x02A
COUNT2 EQU 0x02B
STRING EQU 0x02C
ACTIVE_SOLNOIDS EQU 0x02D
CURRENT_NOTE EQU 0x02E

;Reset Vector
PSECT resetVect,class=CODE,delta=2  ;-Wl,-presetVect=00h
  GOTO Setup

;Interrupt Vector
PSECT isrVect,class=CODE,delta=2     ;-Wl,-pisrVect=04h
  GOTO InterruptHandler
  
;Start of program 
PSECT code,class=CODE,delta=2	;-Wl,-pcode=08h
 
Setup:
    MOVLB 0x07		;Bank 7
    CLRF INLVLA		;Configures voltage level to trigger IOC, Port A
    CLRF INLVLB		;Configures voltage level to trigger IOC, Port B
    CLRF INLVLC		;Configures voltage level to trigger IOC, Port C
    
    ;----------------------------------------------------------
    MOVLB 0x06		;Bank 6
    CLRF SLRCONA	;Configures Slew Rate Limit, Port A
    CLRF SLRCONB	;Configures Slew Rate Limit, Port B
    CLRF SLRCONC	;Configures Slew Rate Limit, Port C
    
    ;----------------------------------------------------------
    MOVLB 0x05		;Bank 5
    CLRF ODCONA		;Configures Sink/Source Current, Port A
    CLRF ODCONB		;Configures Sink/Source Current, Port B
    MOVLW 0x18
    MOVWF ODCONC	;Configures Sink/Source Current, Port C
    
    ;----------------------------------------------------------
    MOVLB 0x04		;Bank 4
    CLRF WPUA		;Configures Internal Pull-ups, Port A
    CLRF WPUB		;Configures Internal Pull-ups, Port B
    CLRF WPUC		;Configures Internal Pull-ups, Port C
    MOVLW 0x20
    MOVWF SSP1ADD	;Configures I2C address
    MOVLW 0X36
    MOVWF SSP1CON1	;Enable SDA/SCL Pins, Clock, & Set as 7 bit address Slave
    MOVLW 0X81
    MOVWF SSP1CON2	;Enable General Call & Clock Strechting
    MOVLW 0X08
    MOVWF SSP1CON3	;Disable Slave Interrupts, SDA Hold Time of 300nS, Auto Enable Address & Data Clock Stretching
    MOVLW 0X80
    MOVWF SSP1STAT	;Disable Slew Rate Control & flags
    MOVLW 0XFE
    MOVWF SSP1MSK	;Enable address matching
    CLRF APFCON1
    
    ;----------------------------------------------------------
    MOVLB 0x03		;Bank 3
    CLRF ANSELA		;Configures Analog Inputs, Port A
    CLRF ANSELB		;Configures Analog Inputs, Port B
    CLRF ANSELC		;Configures Analog Inputs, Port C
    
    ;----------------------------------------------------------
    MOVLB 0x02		;Bank 2
    
    ;----------------------------------------------------------
    MOVLB 0x01		;Bank 1
    CLRF TRISA		;Configures I/0, Port A
    CLRF TRISB		;Configures I/0, Port B
    MOVLW 0x18
    MOVWF TRISC		;Configures I/0, Port C
    MOVLW 0x80
    MOVWF OPTION_REG	;Settings for TMR0, INT edge, and Pullup control, All Ports
    BTFSC OSCSTAT, 6	;Is PLL ready?
    GOTO $-1		;No
    MOVLW 0X78		;Configures Oscillator, Internal, 16MHz
    MOVWF OSCCON
    BTFSC OSCSTAT, 5	;Is Osc ready?
    GOTO $-1		;No
    MOVLW 0x08
    MOVWF PIE1		;Enable I2C Interrupts
    
    ;----------------------------------------------------------
    MOVLB 0x00		;Bank 0
    MOVLW 0xFF
    MOVWF PORTA		;Clears port to ensure known state, Port A
    MOVLW 0xFF
    MOVWF PORTB		;Clears port to ensure known state, Port B
    MOVLW 0xF9
    MOVWF PORTC		;Clears port to ensure known state, Port C
    CLRF BANK_SAVE
    CLRF W_SAVE
    CLRF MIDI_STATUS
    CLRF MIDI_PREVIOUS_NOTE
    CLRF MIDI_NOTE
    CLRF MIDI_VELOCITY
    CLRF DATA_BYTE
    CLRF DATA_RX_1
    CLRF DATA_RX_2
    CLRF DATA_RX_3
    CLRF COUNT1
    CLRF COUNT2
    CLRF STRING
    CLRF ACTIVE_SOLNOIDS
    CLRF CURRENT_NOTE
    BCF PIR1, 3		;Clears I2C flag to ensure known state
    MOVLW 0xC0
    MOVWF INTCON	;Configures Allowed interrupts, Globals & Preriphrials
    
    ;----------------------------------------------------------
    BSF PORTC, 1	;Indicate power on
    GOTO Main		;End of Setup

Main:    
    MOVLB 0x00		;Bank 0
    MOVLW 0xFF
    MOVWF PORTA		;Clears port to ensure known state, Port A
    MOVLW 0xEA
    MOVWF PORTB		;Clears port to ensure known state, Port B
    MOVLW 0xBB
    MOVWF PORTC		;Clears port to ensure known state, Port C
    GOTO Main

InterruptHandler:
    ;<editor-fold defaultstate="collapsed" desc="Save Bank & W">
    MOVWF W_SAVE		
    MOVF BSR, 0		;Save Bank & W
    MOVWF BANK_SAVE;</editor-fold>
    BTFSC PIR1, 3	;Is I2C flag set?
    CALL TrueRecieve 	;Yes
    CALL MuteCheck	;No
;<editor-fold defaultstate="collapsed" desc="Restore: Restore Bank & W">
Restore:
    MOVLB 0x00		;Bank 0
    BCF PIR1, 3		;Clear I2C flag
    MOVLB 0x04		;Bank 4
    BSF SSP1CON1, 4	;Hold clock Low
    MOVF BANK_SAVE, 0	
    MOVWF BSR		;Restore Bank & W
    MOVF W_SAVE, 0	
    RETFIE;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="MuteCheck: Determines if string should be muted">
MuteCheck:
    MOVLB 0x00		;Bank 0
    MOVLW 0x00
    XORWF MIDI_NOTE, 0
    BTFSC STATUS, 2	;Is note 0?
    RETURN		;Yes
    MOVLW 0x80
    XORWF MIDI_STATUS, 0	
    BTFSS STATUS, 2	;Is note off?
    RETURN		;No
    MOVF MIDI_PREVIOUS_NOTE, 0
    XORWF MIDI_NOTE, 0		
    BTFSS STATUS, 2	;Is Note = Previous Note?
    CALL Mute		;No
    GOTO StringMath;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Mute: Determines which string should be muted">
Mute:
    CLRF STRING		;Clear for clarity
    MOVF MIDI_PREVIOUS_NOTE, 0
    CALL FindString	;Find previous string
    BTFSC STRING, 0	;Is it E?
    GOTO E		;Yes
    BTFSC STRING, 1	;Is it A?
    GOTO A		;Yes
    BTFSC STRING, 2	;Is it D?
    GOTO D		;Yes
    BTFSC STRING, 3	;Is it G?
    GOTO G		;Yes
    RETURN		;Safty;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="E-G: Energizes Mute Solnoids">
E:
    BCF PORTA, 3	;Mute E
    CALL SmallDelay	;Keep Energized
    BCF STRING, 0	;Clear string
    BSF PORTA, 3	;De-Energize
    RETURN
    
A:
    BCF PORTA, 2	;Mute A
    CALL SmallDelay	;Keep Energized
    BCF STRING, 1	;Clear string
    BSF PORTA, 2	;De-Energize
    RETURN
    
D:
    BCF PORTA, 1 	;Mute D
    CALL SmallDelay	;Keep Energized
    BCF STRING, 2	;Clear string
    BSF PORTA, 1	;De-Energize
    RETURN
    
G:
    BCF PORTA, 0	;Mute G
    CALL SmallDelay	;Keep Energized
    BCF STRING, 3	;Clear string
    BSF PORTA, 0	;De-Energize
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="StringMath: Handles Empty notes and Initiates notes to be played ">
StringMath:
    MOVLW 0x3B		    
    SUBWF MIDI_NOTE, 0	;W = Note - 3B
    BTFSC STATUS, 0	;Is Note >= 3B?
    RETURN		;Yes
    MOVF MIDI_NOTE, 0	;No
    SUBLW 0x1C		;1C - Note
    BTFSC STATUS, 0	;Is Note <= 1C?
    RETURN		;Yes
    MOVF MIDI_PREVIOUS_NOTE, 0
    XORWF MIDI_NOTE, 0	
    BTFSC STATUS, 2	;Is Note = Previous Note?
    CALL ToggleSolnoid	;Yes
    MOVF MIDI_NOTE, 0	;No
    CALL FindString	;Find note string
    CALL PluckIt	;Play note
    MOVF MIDI_NOTE, 0
    MOVWF MIDI_PREVIOUS_NOTE	;Save old note
    CLRF MIDI_STATUS		;Clear Status
    CLRF MIDI_NOTE		;Clear Note
    CLRF MIDI_VELOCITY		;Clear Velocity
    RETURN;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="PluckIt: Determines String to be plucked">
PluckIt:
    BTFSC STRING, 0	;Is it E?
    GOTO CheckE		;Yes
    BTFSC STRING, 1	;Is it A?
    GOTO CheckA	;Yes
    BTFSC STRING, 2	;Is it D?
    GOTO CheckD	;Yes
    BTFSC STRING, 3	;Is it G?
    GOTO CheckG	;Yes
    RETURN;</editor-fold>
    
;<editor-fold defaultstate="collapsed" desc="CheckE: Energizes E solnoids">
CheckE:
    BTFSC ACTIVE_SOLNOIDS, 0	;Which solnoid?   
    GOTO SecondaryRC7		;Secondary
    BCF PORTB, 0	;Energize RB0
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTB, 0	;De-Energize RB0
    RETURN
SecondaryRC7:
    BCF PORTC, 7	;Energize RC7
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTC, 7	;De-Energize RC7
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="CheckA: Energizes A solnoids">
CheckA:
    BTFSC ACTIVE_SOLNOIDS, 0	;Which solnoid?   
    GOTO SecondaryRC5		;Secondary
    BCF PORTC, 6	;Energize RC6
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTC, 6	;De-Energize RC6
    RETURN
SecondaryRC5:
    BCF PORTC, 5	;Energize RC5
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTC, 5	;De-Energize RC5
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="CheckD: Energizes D solnoids">
CheckD:
    BTFSC ACTIVE_SOLNOIDS, 0	;Which solnoid?   
    GOTO SecondaryRB3		;Secondary
    BCF PORTB, 4	;Energize RB4
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTB, 4	;De-Energize RB4
    RETURN
SecondaryRB3:
    BCF PORTB, 3	;Energize RB3
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTB, 3	;De-Energize RB3
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="CheckG: Energizes G solnoids">
CheckG:
    BTFSC ACTIVE_SOLNOIDS, 0	;Which solnoid?   
    GOTO SecondaryRB1		;Secondary
    BCF PORTB, 2	;Energize RB2
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTB, 2	;De-Energize RB2
    RETURN
SecondaryRB1:
    BCF PORTB, 1	;Energize RB1
    CALL SmallDelay	;Keep enegized
    CLRF STRING		;Clear string
    BSF PORTB, 1	;De-Energize RB1
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="ToggleSolnoid: Toggles active solnoids">
ToggleSolnoid:
    MOVLW 0x01
    XORWF ACTIVE_SOLNOIDS, 1	;Toggle active solnoids
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="FindString: Finds and sets current string">
FindString:
    ;<editor-fold defaultstate="collapsed" desc="E String">
    MOVWF CURRENT_NOTE	;Save Note for comparison
    MOVLW 0x2A		    
    SUBWF CURRENT_NOTE, 0	;W = Note - 2A
    BTFSC STATUS, 0	;Is Note >= 2A?
    GOTO SetE		;No, Set String E
    MOVF CURRENT_NOTE, 0	;Yes
    SUBLW 0x1C		;1C - Note
    BTFSC STATUS, 0	;Is Note <= 1C?
    GOTO SetE		;No, Set String E;</editor-fold>
    ;<editor-fold defaultstate="collapsed" desc="A String">
    MOVLW 0x31		;Yes    
    SUBWF CURRENT_NOTE, 0	;W = Note - 31
    BTFSC STATUS, 0	;Is Note >= 31?
    GOTO SetA		;No, Set String A
    MOVF CURRENT_NOTE, 0	;Yes
    SUBLW 0x21		;21 - Note
    BTFSC STATUS, 0	;Is Note <= 21?
    GOTO SetA		;No, Set String A;</editor-fold>
    ;<editor-fold defaultstate="collapsed" desc="D String">
    MOVLW 0x36		;Yes    
    SUBWF CURRENT_NOTE, 0	;W = Note - 36
    BTFSC STATUS, 0	;Is Note >= 36?
    GOTO SetD		;No, Set String D
    MOVF CURRENT_NOTE, 0	;Yes
    SUBLW 0x28		;28 - Note
    BTFSC STATUS, 0	;Is Note <= 28?
    GOTO SetD		;No, Set String D;</editor-fold>
    ;<editor-fold defaultstate="collapsed" desc="G String">
    MOVLW 0x3B		;Yes    
    SUBWF CURRENT_NOTE, 0	;W = Note - 3B
    BTFSC STATUS, 0	;Is Note >= 3B?
    GOTO SetG		;No, Set String G
    MOVF CURRENT_NOTE, 0	;Yes
    SUBLW 0x2D		;2D - Note
    BTFSC STATUS, 0	;Is Note <= 2D?
    GOTO SetG		;No, Set String G
    RETURN		;None;</editor-fold>
SetE:
    BSF STRING, 0	;Set E string
    RETURN
SetA:
    BSF STRING, 1	;Set A string
    RETURN
SetD:
    BSF STRING, 2	;Set D string
    RETURN
SetG:
    BSF STRING, 3	;Set G string
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="TrueRecieve: reads I2C and saves data">
TrueRecieve:
    CALL Recieve
    MOVLB 0x00		;Bank 0
    MOVF DATA_RX_1, 0
    MOVWF MIDI_STATUS	;Save note status
    MOVF DATA_RX_2, 0	
    MOVWF MIDI_NOTE	;Save note value
    MOVF DATA_RX_3, 0
    MOVWF MIDI_VELOCITY	;Save note velocity
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Recieve: Byte seperation Logic">
Recieve:
    BSF PORTC, 2	;Status: Revieving
    MOVLB 0x04		;Bank 4
    MOVF SSP1BUF, 0	;Recieve I2C
    BTFSC SSP1STAT, 0	;Is it done?
    GOTO $-1		;No, wait
    BTFSS SSP1STAT, 5	;Is it address or data?
    RETURN		;Address, Disregard
    MOVLB 0x00		;Bank 0
    MOVWF TEMP		;Data, Save
    MOVLW 0x02		
    XORWF DATA_BYTE, 0	
    BTFSC STATUS, 2	;Is it byte 3?
    GOTO Byte3		;Yes
    MOVLW 0x01		
    XORWF DATA_BYTE, 0	
    BTFSC STATUS, 2	;Is it byte 2?
    GOTO Byte2		;Yes
    MOVLW 0x00		
    XORWF DATA_BYTE	
    BTFSC STATUS, 2	;Is it byte 1?
    GOTO Byte1		;Yes
    RETURN;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="Byte1-6: Saves buffer data to Rx registers">
Byte1:
    MOVF TEMP, 0	;Move data to W
    MOVWF DATA_RX_1	;Save first Byte
    INCF DATA_BYTE, 1	;Increament for next byte
    RETURN	;Return
    
Byte2:
    MOVF TEMP, 0	;Move data to W
    MOVWF DATA_RX_2	;Save second Byte
    INCF DATA_BYTE, 1	;Increament for next byte
    RETURN	;Return
    
Byte3:
    MOVF TEMP, 0	;Move data to W
    MOVWF DATA_RX_3	;Save third Byte
    CLRF DATA_BYTE	;Reset
    RETURN	;Return;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="SmallDelay: A small delay">
SmallDelay:
    MOVLB 0x00	    ;Bank 0
    MOVLW 0x01
    MOVWF COUNT2
Loop2:
    MOVLW 0x67
    MOVWF COUNT1
Loop1:
    DECFSZ COUNT1
    GOTO Loop1
    DECFSZ COUNT2   ;Is count1 0?
    GOTO Loop2	    ;No
    RETURN	    ;Yes, return;</editor-fold>

END