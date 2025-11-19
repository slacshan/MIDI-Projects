;***************************************************************************
;
;	    Filename: EEWRITE.inc
;	    Date: 10/22/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Sub routine for writing to EEPROM
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	  	Started 10/22/2024-10/24/2024
;	    
;
;*************************************************************************
    
EEWRITE_CODE CODE
 
EEWRITE
	
    BANKSEL INTCON
    BCF INTCON,7
    BANKSEL EECON1
    BCF EECON1,EEPGD	; SET FOR DATA MEMORY
    BSF EECON1,WREN	; ENABLE REGISTER
    
    MOVLW H'55'		; REQUIRED CODE, EECON2 IS NOT PHYSICAL
    MOVWF EECON2
    MOVLW H'AA'
    MOVWF EECON2
    
    BSF EECON1,WR
    BTFSC EECON1,WR	; ENABLE AND WAIT FOR WRITE
    GOTO $-1
    BCF EECON1,WREN	; DISABLE REGISTER
    
    BANKSEL PIR2
    BCF PIR2,EEIF	; CLEAR INTERRUPT FLAG
    RETURN