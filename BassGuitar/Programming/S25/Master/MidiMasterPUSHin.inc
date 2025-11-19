;***************************************************************************
;
;	    Filename: PUSHin.inc
;	    Date: 09/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Sub routine for saving status and working 
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 09/25/2024 - Finished 09/25/2024
;	    Modified 09/26/24
;		CHANGED ORDER OF MOVWF FOR CORRECT STORAGE
;
;*************************************************************************
PUSHIN_CODE CODE

PUSHIN
		MOVWF H'20'
		MOVF STATUS,0      ; ROUTINE FOR RESTORING WORKING AND STATUS
		MOVWF H'21'	
		RETURN