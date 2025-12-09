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
    ADDRESS_W	EQU 0X040
    DATA_TX_1	EQU 0X041
    DATA_TX_2	EQU 0X042
    DATA_TX_3	EQU 0X043	
    PORTB_CHECK	EQU 0X044
    BUF_SAVE    EQU 0X050 
    BYTE_1	EQU 0X070
    BYTE_2	EQU 0X071
    BYTE_3	EQU 0X072
    RX_BYTE	EQU 0X073
    TEMP	EQU 0X074
    TEMP_2	EQU 0X075
    I2C_SEND    EQU 0X076
    NOTE_SELECT	EQU 0X077
    W_SAVE	EQU 0X078
    BSR_SAVE    EQU 0X079
    STATUS_SAVE EQU 0X07A
    FF_REG	EQU 0X07B
;Start of Program
PSECT resetVect,class=CODE,delta=2
GOTO START
    
PSECT isrVect,class=CODE,delta=2
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
    MOVLW   0X00
    MOVWF   RX_BYTE
    MOVLW   0XFF
    MOVWF   FF_REG
    GOTO POWERUP
    ;</editor-fold>    
      
POWERUP:
    BANKSEL LATC
    BSF	LATC,0
    GOTO MAIN
    
MAIN:
    BANKSEL PORTB
    BTFSC   I2C_SEND,0	;TEST TO SEE IF MY 3BYTE HAPPENED, IF SO THEN START I2C
    GOTO    TEST_ADDRESS    ;TEST TO SEE IF MY CHANNEL MATCHES THE DIP SWITCH ADDRESS
    GOTO MAIN
    
TEST_ADDRESS:
    BCF	I2C_SEND,0
    BANKSEL PORTB
    MOVF    BYTE_1,0
;-------------------REMOVE THE TOP NIBBLE FROM THE FIRST BYTE SO I CAN TEST JUST THE BOTTOM NIBBLE-------------
    MOVWF   TEMP
    BTFSC   TEMP,0
    BSF	TEMP_2,0
    BTFSC   TEMP,1
    BSF	TEMP_2,1
    BTFSC   TEMP,2
    BSF	TEMP_2,2
    BTFSC   TEMP,3
    BSF	TEMP_2,3
    CLRF    TEMP
;---------------------------------------------------------------------------------------------------------------- 
    MOVF    PORTB,0
    XORWF   TEMP_2,0
    XORLW   0X00
    BTFSS   STATUS,2
    GOTO    MAIN
    CALL    NOTE_TEST
    
COMPARE:
    BANKSEL PORTA
    MOVF    NOTE_SELECT,0
    SUBWF   FF_REG,0
    ADDWF   BYTE_2,0
    BANKSEL STATUS
    BTFSS   STATUS,0
    CALL    I2C_WRITE
    CLRF    TEMP
    GOTO    MAIN
    
//<editor-fold defaultstate="collapsed" desc="NOTE FILTERING">
NOTE_TEST:
;------ADDS VALUES TO A REGISTER BASED UPON WHAT DIP SWITCHES ARE PRESSED-------
    BANKSEL PORTA
    MOVLW   0X07    
    MOVWF   NOTE_SELECT
    CLRF    TEMP_2
    CLRF    TEMP
    MOVLW   8
    BTFSC   PORTA,0
    ADDWF   NOTE_SELECT,1
    MOVLW   16
    BTFSC   PORTA,1
    ADDWF   NOTE_SELECT,1
    MOVLW   32
    BTFSC   PORTA,2
    ADDWF   NOTE_SELECT,1
    MOVLW   64
    BTFSC   PORTA,3
    ADDWF   NOTE_SELECT,1
    RETURN
    
    RECEPTION: 
    MOVWF   W_SAVE
    MOVF    BSR,0
    MOVWF   BSR_SAVE
    MOVF    STATUS,0
    MOVWF   STATUS_SAVE   
    BANKSEL RC1REG
    MOVF    RC1REG,0
    MOVWF   TEMP
    BTFSC   RX_BYTE,1
    GOTO    BYTE3
    BTFSC   RX_BYTE,0
    GOTO    BYTE2
BYTE1:
    BANKSEL PORTB
//<editor-fold defaultstate="collapsed" desc="ON/OFF TEST">
;----------------TEST ADDRESS FOR A NOTE ON OR OFF-----------------
    BTFSS   TEMP,7
    GOTO END_RECIVE
    BTFSC   TEMP,6
    GOTO END_RECIVE
    BTFSC   TEMP,5
    GOTO END_RECIVE
;------------------------------------------------------------------//</editor-fold>
    MOVF    TEMP,0
    MOVWF   BYTE_1
    BSF	RX_BYTE,0
    GOTO END_RECIVE
BYTE2:
    BANKSEL PORTB
    MOVF    TEMP,0
    MOVWF   BYTE_2
    BCF	RX_BYTE,0
    BSF	RX_BYTE,1
    GOTO END_RECIVE   
BYTE3:
    BANKSEL PORTB
    BSF	I2C_SEND,0
    MOVF    TEMP,0
    MOVWF   BYTE_3
    BCF	RX_BYTE,0
    BCF	RX_BYTE,1
    GOTO END_RECIVE  
END_RECIVE:
    MOVF    BSR_SAVE,0
    MOVWF   BSR
    MOVF    STATUS_SAVE,0
    MOVWF   STATUS
    MOVF    W_SAVE,0
    RETFIE  
END