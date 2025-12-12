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
