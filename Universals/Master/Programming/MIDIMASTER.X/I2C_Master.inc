;-----------------------------------------------------------------------------------------------------------------------------------------------
; PROJECT NAME:	SETUP FOR 1788
;DATE:		10 APRIL 2025
;VERSION:		2
;CREATOR:		JUSTIN BELL, REVISED BY PAYDEN HOSKINS
;COMPANY:	IDAHO STATE UNIVERSITY
;DESCRIPTION:	SETUP INCLUDE FILE FOR THE 1788 AS A MASTER
;		ADDRESSES ALL PORTS AND OTHER REGISTERS
;-----------------------------------------------------------------------------------------------------------------------------------------------
    
    
    ;Before an I2C_WRITE call Main Code Should:
    ;1. Clear SSP1IF to prevent collision errors 
    ;2. Load ADDRESS_W Registers for Peripheral
    ;3. Load DATA_TX_1 Register with First Byte Data
    ;4. Load DATA_TX_2 Register with Second Byte Data
    ;5. Call I2C_WRITE

#include <xc.inc>  
    		


PSECT code

I2C_SETUP_SERVER:
    BANKSEL APFCON1
    BCF APFCON1, 3
    BCF APFCON1, 4
    BANKSEL TRISC
    BSF TRISC,3
    BSF TRISC,4 		;Set SCL and SDA as inputs
    BANKSEL SSP1ADD
    MOVLW 0X27
    MOVWF SSP1ADD		;Set BAUD Generator to 100Khz (4M Occilator)
    BANKSEL SSP1CON1
    MOVLW 0X28
    MOVWF SSP1CON1		;Enable SDA and SLC Pins and Set as I2C Master Mode
    BANKSEL SSP1CON2
    MOVLW 0X00
    MOVWF SSP1CON2		;Disable General Call
    BANKSEL SSP1CON3
    MOVLW 0X08	;Min SDA Hold time 300ns
    MOVWF SSP1CON3
    BANKSEL SSP1STAT
    MOVLW 0XC0
    MOVWF SSP1STAT		;Not in Tx mode, Slew Rate Control Disabled
    RETURN
