;***************************************************************************
;
;	    Filename: EEREAD.inc
;	    Date: 10/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A sub routine for reading EEPROM
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 10/23/2024
;
;*************************************************************************


EEREAD_CODE CODE
 
EEREAD
		BANKSEL EEADR
		MOVWF EEADR	  ; IMPORT WORKING FROM MAIN PROGRAM
		BANKSEL EECON1
		BCF EECON1,7	
		BSF EECON1,RD	  ; ENABLE READ
		BANKSEL EEDAT
		MOVF EEDAT,0	  ; MOVE DATA TO WORKING
		RETURN