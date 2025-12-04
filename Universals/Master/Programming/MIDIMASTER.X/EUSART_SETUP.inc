;-----------------------------------------------------------------------------------------------------------------------------------------------
; PROJECT NAME:	SETUP FOR 1788
;DATE:		1 DECEMBER 2025
;VERSION:		1
;CREATOR:		PAYDEN HOSKINS
;COMPANY:	IDAHO STATE UNIVERSITY
;DESCRIPTION:	SETUP INCLUDE FILE FOR THE 1788 FOR EUSART RECIVE
;		ADDRESSES ALL PORTS AND OTHER REGISTERS
;-----------------------------------------------------------------------------------------------------------------------------------------------
#include <pic16f1788.inc>
#include <xc.inc>
    
BYTE_1	EQU 0X070
BYTE_2	EQU 0X071
BYTE_3	EQU 0X072
RX_BYTE	EQU 0X073
TEMP	EQU 0X074

PSECT    code

EUSART_SETUP:
    ;--------------------------------------------------------EUART------------------------------------------------------------------------------
    ; EUART SETUP HERE
    BANKSEL TRISC
    BSF	TRISC,7
    BANKSEL BAUD1CON
    CLRF BAUD1CON	    ; CLEAR BAUD RATE CTL FOR 16-BIT ASYNC
    BANKSEL SP1BRGL
    CLRF SP1BRGL
    MOVLW 0X1F	    ; SET BAUD FOR ASYNC 31.25K
    MOVWF SP1BRGL
    BANKSEL SP1BRGH	    ; CLEAR UPPER REGISTER // PRECAUSION
    MOVLW 0X1F
    MOVWF   SP1BRGH
    BANKSEL TX1STA
    CLRF TX1STA		    ; CLEAR TRANSMIT REGISTER
    BSF	TX1STA,2
    BANKSEL RC1REG
    CLRF RC1REG
    BANKSEL RC1STA
    CLRF RC1STA	
    MOVLW 0XB0	    ; SET FOR CONTINUOUS RECIEVE
    MOVWF RC1STA
    BANKSEL PIE1
    BSF PIE1,5	    ; ENABLE RECIEVE INTERRUPT FOR UART
    ; PIN ASSIGNMENTS
    BANKSEL APFCON1
    CLRF APFCON1	    ; SET PINS
    BANKSEL APFCON2
    CLRF APFCON2	    ; SET PINS
       
    RETURN  