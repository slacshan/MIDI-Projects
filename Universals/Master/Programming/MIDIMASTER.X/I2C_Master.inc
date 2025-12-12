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

    
I2C_WRITE:
    CALL I2C_IDLE		;Ensure the I2C BUS is idle
    BANKSEL SSP1CON2
    BSF SSP1CON2, 0		;Generate Start Condition
START_WRITE_DONE:
    BTFSC SSP1CON2, 0
    GOTO START_WRITE_DONE	;Wait Until Start Condition Completes
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO $-2
    BCF PIR1, 3  
    BANKSEL ADDRESS_W
    MOVF    ADDRESS_W,0
    BANKSEL SSP1BUF
    MOVWF SSP1BUF		;Send Peripheral Address (Write)
ADDRESS_SENT_W:
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO $-2
    BCF PIR1, 3
    BANKSEL SSP1STAT
    BTFSC SSP1STAT,0		
    GOTO $-2		;Wait Until Buffer is Clear (Address is Sent)
    CALL I2C_IDLE		;Ensure the I2C BUS is idle
    BANKSEL SSP1CON2
    BTFSC SSP1CON2, 6	;Was an Acknowledge Received?
    GOTO    BAD_COND		;Acknowledge Not Received    
    BANKSEL SSP1BUF
    MOVF BYTE_1,0
    MOVWF SSP1BUF		;Send First Data Byte
DATA_1_SENT_W:
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO $-2
    BCF PIR1, 3
    BANKSEL SSP1STAT
    BTFSC SSP1STAT,0
    GOTO $-2		;Wait Until Buffer is Clear (Data is Sent)
    CALL I2C_IDLE		;Ensure the I2C BUS is idle
    BANKSEL SSP1CON2
    BTFSC SSP1CON2,6	;Was an Acknowledge Received?
    GOTO    BAD_COND		;Acknowledge Not Received
    BANKSEL SSP1BUF
    MOVF BYTE_2,0
    MOVWF SSP1BUF		;Send Second Data Byte
DATA_2_SENT:
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO $-2
    BCF PIR1, 3
    BANKSEL SSP1STAT		;Note I2C can use as many data bytes as desired, this program is only setup for two
    BTFSC SSP1STAT,0
    GOTO $-2		;Wait Unitl Buffer is Clear (Data is Sent)
    CALL I2C_IDLE
    BANKSEL SSP1CON2
    BTFSC SSP1CON2,6		;Was an Acknowledge Received?
    GOTO BAD_COND		;Acknowledge not Received
    BANKSEL SSP1BUF
    MOVF BYTE_3,0
    MOVWF SSP1BUF		;Send Third Data Byte
DATA_3_SENT:
    BANKSEL PIR1
    BTFSS PIR1, 3
    GOTO $-2
    BCF PIR1, 3
    BANKSEL SSP1STAT		;Note I2C can use as many data bytes as desired, this program is only setup for two
    BTFSC SSP1STAT,0
    GOTO $-2		;Wait Unitl Buffer is Clear (Data is Sent)
    CALL I2C_IDLE
    BANKSEL SSP1CON2
    BTFSC SSP1CON2,6		;Was an Acknowledge Received?
    GOTO BAD_COND		;Acknowledge not Received    
GOOD_STOP:
    BANKSEL SSP1CON2
    BSF SSP1CON2,2		;Generate a Stop Condition
GOOD_STOP_DONE:
    BTFSC SSP1CON2,2
    GOTO GOOD_STOP_DONE	;Wait Until Stop Condition Completes
    MOVLW 0X00
    RETURN			;Write Complete.  Return With 0x00 in Working Register

BAD_COND:
    BANKSEL SSP1CON2
    BSF SSP1CON2,2		;Generate Stop Condition
BAD_STOP_DONE:
    BTFSC SSP1CON2,2
    GOTO BAD_STOP_DONE	;Wait Until Stop Condition Completes
    MOVLW 0XFF
    RETURN			;Write Failed.  Return Wif 0xFF in Working Register

I2C_IDLE:
    BANKSEL SSP1CON2
    MOVLW 0X1F
    ANDWF SSP1CON2		;Compare to 0x1F to Test for 5 Busy Conditions
    BANKSEL STATUS
    BTFSS STATUS,2
    GOTO I2C_IDLE		;If any Conditions Still Busy Wait
CHECK_R_W:
    BANKSEL SSP1STAT
    BTFSC SSP1STAT,2
    GOTO CHECK_R_W		;Wait Until  a Transmission is Not in Process
    RETURN			;I2C BUS is Idle Exit Routine