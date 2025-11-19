;***************************************************************************
;
;	    Filename: POPout.inc
;	    Date: 09/24/2024
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A sub routine for restoring working and status
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    Started 09/25/2024 - Finished 09/25/2024
;
;*************************************************************************
	
POPOUT_CODE CODE
 
POPOUT
	    MOVF H'21',0
	    MOVWF STATUS
	    MOVF H'20',0
	    RETURN