;***************************************************************************
;
;	    Filename: Hex_to_One.inc
;	    Date: 04/24/2025
;	    File Version: 1
;	    Author: Owen Fujii
;	    Company: Idaho State University
;	    Description: A Sub routine for converting hex to base one
;			 is an 8 bit base one
;
;*************************************************************************
	
;*************************************************************************
; 
;	    Revision History:
;   
;	    Modified as listed
;	    
;
;*************************************************************************
	HEX_IN EQU H'042'	
		
Hex_To_One CODE

Hex_To_One
		BTFSC HEX_IN,3
		RETLW H'080'	    ; FOR CASE 0x08
		BTFSS HEX_IN,0
		GOTO SECOND_SET
		BTFSS HEX_IN,1
		GOTO BIT2_FALSE
		BTFSC HEX_IN,2
		RETLW H'040'	    ; FOR CASE 0x07
		RETLW H'004'	    ; FOR CASE 0x03
BIT2_FALSE
		BTFSC HEX_IN,2
		RETLW H'010'	    ; FOR CASE 0x05
		RETLW H'001'	    ; FOR CASE 0x01
SECOND_SET
		BTFSS HEX_IN,1
		GOTO THIRD_SET
		BTFSC HEX_IN,2
		RETLW H'020'	    ; FOR CASE 0x06
		RETLW H'002'	    ; FOR CASE 0x02
THIRD_SET		
		BTFSC HEX_IN,2
		RETLW H'008'	    ; FOR CASE 0x04
		RETLW H'000'	    ; RETURN 0x00 IF NO VALID CASE FOUND
		RETURN		    ; JUST IN CASE ;)