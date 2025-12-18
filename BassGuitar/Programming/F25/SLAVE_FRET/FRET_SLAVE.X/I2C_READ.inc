
;-----------------------------------------------------------------------------------------------------------------------------------------------
;PROJECT NAME:	SETUP FOR 1788
;DATE:		10 APRIL 2025
;VERSION:		2
;CREATOR:		JUSTIN BELL, REVISED BY PAYDEN HOSKINS
;COMPANY:	IDAHO STATE UNIVERSITY
;DESCRIPTION:	SETUP INCLUDE FILE FOR THE 1788 AS A SLAVE
;		ADDRESSES ALL PORTS AND OTHER REGISTERS
;-----------------------------------------------------------------------------------------------------------------------------------------------

    
#include <xc.inc>     
    

PSECT    code

I2C_SETUP_PERIPHERAL:
    BANKSEL SSP1CON1
    BCF SSP1CON1, 4
    BANKSEL TRISC
    BSF TRISC,3
    BSF TRISC,4		;Set SCL and SDA as inputs
    BANKSEL SSP1CON1
    MOVLW 0X36
    MOVWF SSP1CON1		;Enable SDA and SCL Pins, Enable Clock, and Set as 7 bit address Slave
    BANKSEL SSP1CON2
    MOVLW 0X81
    MOVWF SSP1CON2		;Enable General Call and Enable Clock Strechting
    BANKSEL SSP1CON3		
    MOVLW 0X08
    MOVWF SSP1CON3		;Disable Slave Interrupts, SDA Hold Time of 300nS, Auto Enable Address and Data Clock Stretching
    BANKSEL SSP1STAT
    MOVLW 0X80
    MOVWF SSP1STAT		;Disable Slew Rate Control and flags
    BANKSEL SSP1MSK
    MOVLW 0XFE
    MOVWF SSP1MSK		;Enable address matching
    RETURN

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
    BANKSEL PORTC
    BSF	PORTC,2
    GOTO GOOD_STOP
    
GOOD_STOP:
    BANKSEL PIR1
    BCF PIR1, 3
    BANKSEL SSP1CON1
    BSF SSP1CON1, 4
    RETURN			;Write Complete.  Return With 0x00 in Working Register