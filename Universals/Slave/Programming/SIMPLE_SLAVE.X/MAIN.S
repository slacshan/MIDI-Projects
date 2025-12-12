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
#include "88Setup_Slave.inc"
#include "I2C_Peripheral.inc"
;Code Section

;EQU STATMENTS
DATA_BYTE			EQU	0X070
DATA_RX_1			EQU	0X071
DATA_RX_2			EQU	0X072
DATA_RX_3			EQU	0X073
			
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
GOTO	INTERRUPT
RETFIE
   
PSECT code,class=CODE,delta=2
;Setup code that runs once at power up/ reset
 
;PIC SETUP
;<editor-fold defaultstate="collapsed" desc="STARTUP CODE.">
START:
    CALL SETUP88		;Typical register configuration  
    CALL I2C_SETUP_PERIPHERAL
    BANKSEL LATA
    BCF	LATA,0
    BCF	LATA,1
    BCF	LATA,2
    CLRF    DATA_BYTE
    CLRF	DATA_RX_1
    CLRF	DATA_RX_2
    CLRF	DATA_RX_3
    GOTO    POWERUP
    ;</editor-fold>
    
POWERUP:
    BANKSEL LATC
    BSF	LATC,0
    GOTO MAIN
    
MAIN:
    GOTO    MAIN
  
INTERRUPT:
    CALL    I2C_READ
    RETFIE
    
I2C_READ:
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO GOOD_STOP
    BANKSEL SSP1STAT
    BTFSC SSP1STAT, 2
    GOTO LOAD_BUFFER
    BTFSC SSP1STAT, 5
    GOTO RX_DATA
    BANKSEL SSP1BUF
    MOVF SSP1BUF,0
    BANKSEL DATA_BYTE
    CLRF DATA_BYTE
    GOTO GOOD_STOP
    
LOAD_BUFFER:
    ;LOAD BUFFER WITH DATA FOR THE MASTER TO READ
    GOTO GOOD_STOP
    
RX_DATA:
    BTFSC DATA_BYTE, 1
    GOTO RX_THREE
    BTFSC DATA_BYTE, 0
    GOTO RX_TWO
RX_ONE:
    BANKSEL SSP1BUF
    MOVF SSP1BUF,0
    MOVWF DATA_RX_1
    BSF DATA_BYTE, 0
    GOTO GOOD_STOP
    
RX_TWO:
    BANKSEL SSP1BUF
    MOVF SSP1BUF,0
    MOVWF DATA_RX_2
    BCF DATA_BYTE, 0
    BSF DATA_BYTE, 1
    GOTO GOOD_STOP
    
RX_THREE:
    CLRF   DATA_RX_3 
    BANKSEL SSP1BUF
    MOVF SSP1BUF,0
    MOVWF DATA_RX_3
    BCF DATA_BYTE, 0
    BCF DATA_BYTE, 1
    GOTO GOOD_STOP
    
GOOD_STOP:
    BANKSEL PIR1
    BCF PIR1, 3
    BANKSEL SSP1CON1
    BSF SSP1CON1, 4
    RETURN			;Write Complete.  Return With 0x00 in Working Register
    
END