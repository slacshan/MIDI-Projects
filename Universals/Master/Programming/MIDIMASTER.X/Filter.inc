;-----------------------------------------------------------------------------------------------------------------------------------------------
; PROJECT NAME:	FILTER CODE INC FILE
;DATE:		5 DECEMBER 2025
;VERSION:		1
;CREATOR:		PAYDEN HOSKINS
;COMPANY:	IDAHO STATE UNIVERSITY
;DESCRIPTION:	CODE THAT FILTERS WHAT IS SENT BASED ON NOTE AND ADDRESS DIP SWITCH
;-----------------------------------------------------------------------------------------------------------------------------------------------

#include <xc.inc> 
    
PSECT code
    
TEST_NOTE:
;------ADDS VALUES TO A REGISTER BASED UPON WHAT DIP SWITCHES ARE PRESSED-------
    BANKSEL PORTA
    CLRF    TEMP_2
    CLRF    TEMP
    CLRF    NOTE_SELECT
    MOVLW   3
    BTFSC   PORTA,0
    ADDWF   NOTE_SELECT,1
    MOVLW   6
    BTFSC   PORTA,1
    ADDWF   NOTE_SELECT,1
    MOVLW   12
    BTFSC   PORTA,2
    ADDWF   NOTE_SELECT,1
    MOVLW   24
    BTFSC   PORTA,3
    ADDWF   NOTE_SELECT,1
    GOTO    LOOKUP_TABLE
;--------------LOOKUP TABLE THAT SELECTS THE NOTE COMPARISON VALUE--------------
    //<editor-fold defaultstate="collapsed" desc="LOOKUP TABLE">
LOOKUP_TABLE:   
    BANKSEL PCL
    MOVF    NOTE_SELECT,0
    ADDWF   PCL,1
    MOVLW   7
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   15
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   23
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   31
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   39
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   47
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   55
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   63
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   71
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   79
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   87
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   95
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   103
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   111
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   119
    MOVWF   TEMP
    GOTO COMPARE
    MOVLW   127
    MOVWF   TEMP
    GOTO COMPARE//</editor-fold>
;----------MAKES SURE THE NOTE BEING SENT IS NOT ABOVE THE MAX NOTE-----------
    