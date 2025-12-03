;Payden Hoskins
;11/18/25
;Final	Project
;RCET3375
    
;-------------------------------------------------------------------------------
    
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
#include "88Setup.inc"
#include "I2C_Master.inc"
#include "EUSART_SETUP.inc"
;Code Section
;-------------------------------------------------------------------------------
;Register/Variable setup
 BUF_SAVE   EQU	0X050
 BSR_SAVE   EQU	0X051  
   
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
BANKSEL	PORTC
BSF PORTC,1
GOTO	RECEPTION
RETFIE
   
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
;<editor-fold defaultstate="collapsed" desc="STARTUP CODE.">
START:
    CALL SETUP88		;Typical register configuration    
    CALL I2C_SETUP_SERVER	;Addresses relevent I2C registers for I2C master/server
    CALL EUSART_SETUP
    BANKSEL ADDRESS_W
    MOVLW   0X00
    MOVWF   ADDRESS_W
    BANKSEL DATA_TX_1
    MOVLW   0XAA
    MOVWF   DATA_TX_1
    BANKSEL DATA_TX_2
    MOVLW   0X55
    MOVWF   DATA_TX_2
    MOVLW   0X67
    MOVWF   DATA_TX_3
    GOTO MAIN
    ;</editor-fold>    
       
MAIN:
    BANKSEL PORTC
    BTFSC PORTC,0          ; BUTTON PRESSED?
    CALL I2C_WRITE
    GOTO MAIN
    
END