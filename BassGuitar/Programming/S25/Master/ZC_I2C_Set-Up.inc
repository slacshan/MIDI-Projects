   ;File Contains the sub routine to Set UP as Server/Peripheral and Read/Write Out I2C 
    
    ;Before an I2C_WRITE call Main Code Should:
    ;1. Load ADDRESS_W(R) Registers for Peripheral (Read and Write Registers)
    ;2. Load DATA_TX_1 Register with First Byte Data
    ;3. Load DATA_TX_2 Register with Second Byte Data (Optional)
    ;4. Set TWO_BYTES_F Bit 0.  0=Only One Byte  1=Two Bytes
    ;5. Call I2C_WRITE
    
    ;Before an I2C_READ call Main Code Should:
    ;1. Load ADDRESS_W(R) Registers for Peripheral (Read and Write Registers)
    ;2. Load DATA_TX_1 Register with the Desired Address To be Read
    ;3. Call I2C_READ
    ;4. Save DATA_RECEIVED to Desired Register
    
    ADDRESS_W			EQU	H'040'
    ADDRESS_R			EQU	H'041'
    DATA_TX_1			EQU	H'042'
    DATA_TX_2			EQU	H'043'
    DATA_RECEIVED			EQU	H'044'
    TWO_BYTES_F			EQU	H'045'
    
    
    I2C_CODE    CODE
    
    I2C_SETUP_SERVER
    ;**************Peripheral Address Set***************

    ;**************Master SetUp************************
	BANKSEL	    TRISC
	BSF	    TRISC,3
	BSF	    TRISC,4 		;Set SCL and SDA as inputs
	BANKSEL	    SSPADD
	MOVLW	    H'27'
	MOVWF	    SSPADD		;Set BAUD Generator to 100Khz (16M Occilator)
	BANKSEL	    SSPCON
	MOVLW	    H'28'		
	MOVWF	    SSPCON		;Enable SDA and SLC Pins and Set as I2C Master Mode
	BANKSEL	    SSPCON2
	MOVLW	    H'00'
	MOVWF	    SSPCON2		;Disable General Call
	BANKSEL	    SSP1CON3
	MOVLW	    H'08'		;Min SDA Hold time 300ns
	MOVWF	    SSP1CON3
	BANKSEL	    SSPSTAT
	MOVLW	    H'A0'		
	MOVWF	    SSPSTAT		;Not in Tx mode, Slew Rate Control Disabled
	RETURN
	
    I2C_SETUP_PERIPHERAL
    ;**************Slave SetUp**************************
	BANKSEL	    TRISC
	BSF	    TRISC,3
	BSF	    TRISC,4		;Set SCL and SDA as inputs
	BANKSEL	    SSPADD
	MOVLW	    H'05'
	MOVWF	    SSPADD		;Peripheral Address
	BANKSEL	    SSPCON
	MOVLW	    H'3E'
	MOVWF	    SSPCON		;Enable SDA and SCL Pins, Enable Clock, and Set as 7 bit address Slave
	BANKSEL	    SSPCON2
	MOVLW	    H'01'
	MOVWF	    SSPCON2		;Disable General Call and Enable Clock Strechting
	BANKSEL	    SSP1CON3		
	MOVLW	    H'0B'
	MOVWF	    SSP1CON3		;Disable Slave Interrupts, SDA Hold Time of 300nS, Auto Enable Address and Data Clock Stretching
	BANKSEL	    SSPSTAT
	MOVLW	    H'80'
	MOVWF	    SSPSTAT		;Disable Slew Rate Control and flags
	RETURN
	
    I2C_WRITE
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Start Condition
    START_WRITE_DONE
	BTFSC	    SSPCON2,0
	GOTO	    START_WRITE_DONE	;Wait Until Start Condition Completes
	BANKSEL	    ADDRESS_W
	MOVFW	    ADDRESS_W
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Write)
    ADDRESS_SENT_W
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_W	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    DATA_TX_1
	MOVFW	    DATA_TX_1
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send First Data Byte
    DATA_1_SENT_W
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0
	GOTO	    DATA_1_SENT_W	;Wait Until Buffer is Clear (Data is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    TWO_BYTES_F
	BTFSS	    TWO_BYTES_F,0	;If Two Bytes Flag is Set Send Second Byte
	GOTO	    GOOD_STOP		;Two Bytes Flag is 0 End Transmission
	BANKSEL	    DATA_TX_2
	MOVFW	    DATA_TX_2
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Second Data Byte
    DATA_2_SENT
	BANKSEL	    SSPBUF
	BTFSC	    SSPBUF,0
	GOTO	    DATA_2_SENT		;Wait Unitl Buffer is Clear (Data is Sent)
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge not Received
    GOOD_STOP
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate a Stop Condition
    GOOD_STOP_DONE
	BTFSC	    SSPCON2,2
	GOTO	    GOOD_STOP_DONE	;Wait Until Stop Condition Completes
	MOVLW	    H'00'
	RETURN				;Write Complete.  Return With 0x00 in Working Register
	
I2C_READ
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Start Condition
    START_READ_DONE_1
	BTFSC	    SSPCON2,0
	GOTO	    START_READ_DONE_1	;Wait Until Start Condition Completes
	BANKSEL	    ADDRESS_W
	MOVFW	    ADDRESS_W
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Write)
    ADDRESS_SENT_R_1
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_R_1	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    DATA_TX_1
	MOVFW	    DATA_TX_1
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send First Data Byte
    DATA_1_SENT_R
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0
	GOTO	    DATA_1_SENT_R	;Wait Until Buffer is Clear (Data is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,0		;Generate Repeated Start Condition
    START_READ_DONE_2
	BTFSC	    SSPCON2,0
	GOTO	    START_READ_DONE_2	;Wait Until Repeated Start Condition Completes
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    ADDRESS_R
	MOVFW	    ADDRESS_R
	BANKSEL	    SSPBUF
	MOVWF	    SSPBUF		;Send Peripheral Address (Read)
    ADDRESS_SENT_R_2
	BANKSEL	    SSPSTAT
	BTFSC	    SSPSTAT,0		
	GOTO	    ADDRESS_SENT_R_2	;Wait Until Buffer is Clear (Address is Sent)
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BTFSC	    SSPCON2,6		;Was an Acknowledge Received?
	GOTO	    BAD_COND		;Acknowledge Not Received
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,3		;Enable Receive Mode
	BANKSEL	    PIR1
	BCF	    PIR1,3		;Clear SSP interrupt Flag
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF		;Clear SSPBUF Buffer
	CALL	    I2C_IDLE		;Ensure the I2C BUS is idle
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,5		;Set Acknowledge Data to NACK
	BSF	    SSPCON2,4		;Send NACK (Stop Data Receive)
    NACK_DONE
	BTFSC	    SSPCON2,4
	GOTO	    NACK_DONE		;Wait Until NACK Completes
	BANKSEL	    SSPCON2
	BCF	    SSPCON2,3		;Disable Receive Mode
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate Stop Condition
    READ_STOP_DONE_2
	BTFSC	    SSPCON2,2
	GOTO	    READ_STOP_DONE_2	;Wait Until Stop Condition Completes
	BANKSEL	    SSPBUF
	MOVFW	    SSPBUF
	BANKSEL	    DATA_RECEIVED
	MOVWF	    DATA_RECEIVED	;Save Data Sent By the Peripheral
	RETURN
	
	
    BAD_COND
	BANKSEL	    SSPCON2
	BSF	    SSPCON2,2		;Generate Stop Condition
    BAD_STOP_DONE
	BTFSC	    SSPCON2,2
	GOTO	    BAD_STOP_DONE	;Wait Until Stop Condition Completes
	MOVLW	    H'FF'
	RETURN				;Write Failed.  Return Wif 0xFF in Working Register
	
    I2C_IDLE
	BANKSEL	    SSPCON2
	MOVLW	    H'1F'
	ANDWF	    SSPCON2		;Compare to 0x1F to Test for 5 Busy Conditions
	BANKSEL	    STATUS
	BTFSS	    STATUS,2
	GOTO	    I2C_IDLE		;If any Conditions Still Busy Wait
    CHECK_R_W
	BANKSEL	   SSPSTAT
	BTFSC	   SSPSTAT,2
	GOTO	   CHECK_R_W		;Wait Until  a Transmission is Not in Process
	RETURN				;I2C BUS is Idle Exit Routine
	
	
	
	
	