//      ******        ******         ******
//      Branching work.  The guessing game.
//      Adapted from OSK CBM.PRG STUDIO code
//      https://oldskoolcoder.co.uk/
//      ******        ******         ******
    #import "constants.asm"         // imports the contstants asm
    #import "macro.asm"             // imports the macro asm.

BasicUpstart2(ENTER)        // 
start:

//      ******        ******         ******
//          variables
    .var SCRN_START=$0400
    .var Print=$ffd2    // The Kernal print routine - CHROUT
    .var Basin=$ffcf    // The Kernal input routine -  CHRIN
    .var FromNum=$b79e  // The Kernal print variable -
    .var GetLine=$a560  // 42336

    .var addlo=247
    .var addhi=248
    .var htlo=$14
    .var hthi=$15
 
//      ******        ******         ******
//      enviroment variables set to memory            
    Guess:
        brk     //  set to zero 
    NumberToGuess:
        brk     //  set to zero
    GuessNumber:
        brk     //  set to zero
//      ******        ******         ******
//      ******        ******         ******
//  setting strings to memory  
//  these strings will give info to the user to interact

.encoding "petscii_mixed"

GuessNumberTXT:    //  GuessNumberTEXT
    .text "you have now had "
        brk

GuessNumberEnd:
    .text "attempt(s)"
        brk     //  set to zero

PleaseMakeAGuessTXT:
    .text "please make a guess (0-255)?"
        brk     //  set to zero 

Congratulations_TXT:
    .text "congratulations, you guessed correctly, and only took "
        brk     //  set to zero

CongratulationsEnd_TXT:
    .text " guesses"
    .byte CHR_Return
        brk     //  set to zero 

CarrySet_TXT:
    .text "your number is too high"
    .byte 13
       brk     //  set to zero 

CarryClear_TXT:
    .text "your number is too low"
    .byte 13
        brk     //  set to zero

GuessAttempts_TXT:
    .text "that was guess number "
        brk     //  set to zero
//      ******        ******         ******

//  This is the code that runs the prog                                                                        *
ENTER:
    lda #0
    sta GuessNumber         // refer to above variable, set to 0
    jsr rand                // obviously  Generate a Number between 0 and 255
    sta NumberToGuess       // Store that number 
    //jsr PrintAccumlator    // Prints the value (test Purposes Only)
GuessLOOP:
    jsr GetNumber           // Gets the users inputted guess
    stx Guess               // Stores the users guess
    inc GuessNumber         // increases the number of guesses
    txa                     // Transfers Guess To Acc.
    cmp NumberToGuess       // Compare with generated number
    bne NotEqualToNumber
    jmp Congratulations
NotEqualToNumber:
    // beq Congratulations        // User Guesses Correctly
    bcc SorryYourGuessToLow     // User Guesses Low
    bcs SorryYourGuessToHigh    // User Guesses High
CarryOnGuessing:
    PrintText(GuessAttempts_TXT) // Print Attempts Text - PrintText GuessAttempts_TEXT
    lda GuessNumber              // Load Attempt Number
    sta NumberToPrint            // Store in Number To Print
    jsr DecimalPrint+3           // Print attempt number
    jsr CarrageReturn            // Print CarrageReturn
    jmp GuessLOOP                // Try Again


Congratulations:
    PrintText(Congratulations_TXT)      // Print Congrats text
    lda GuessNumber                     // Loads Attempts
    sta NumberToPrint                   //; Stores For printing
    jsr DecimalPrint+3                  //; Print attempt number
    PrintText(CongratulationsEnd_TXT)   //; Print Congrats End Text - PrintText CongratulationsEnd_TEXT:
    pla
    pla
    jmp $a474
    
SorryYourGuessToHigh:
    PrintText(CarrySet_TXT)             // Print To High Guess text - PrintText CarrySet_TEXT  
    jmp CarryOnGuessing                 // jump back

SorryYourGuessToLow:
    PrintText(CarryClear_TXT)           // Print Too Low Text -     PrintText CarryClear_TEXT 
    jmp CarryOnGuessing                 // Jump back


//      ******        ******         ******
//      this generates the 0 to 255e                                                                        *
rand:
    lda #0
    ldy #2
    jsr $b391
    jsr $e097
    ldy #0
    lda #$8b
    jsr $ba8c
    lda #0
    ldy #255
    jsr $b391
    lda $66
    eor $6e
    sta $6f
    jsr $ba30
    jsr $b1aa
    lda $65
   
    rts

//      ******        ******         ******
//      ******        ******         ******
//      * GetNumber                                                                 
//      * This asks the user to imput an number between 0 and 255  
//      * If Inputs : None                        
//      * And Outputs : X Register Contains Number Entered                         
//      ******        ******         ******
//      * Variables                                                                 
//      ******        ******         ******
//      * Code                                                                       
GetNumber:
    jsr CarrageReturn
    PrintText(PleaseMakeAGuessTXT)   //  PrintText PleaseMakeAGuessTXT  
    jsr GetLine
    lda #1
    ldx #$ff
    sta $7b
    stx $7a
    jsr $0073
    jsr $b79e
    rts

//      ******        ******         ******
//      PrintAccumlator                                                             
//      ******        ******         ******
//      * This prints the number from the Accumulator to binary / Hex / Decimal       
//      Inputs : Accumulator : Number To Print Out                                 
//      ******        ******         ******
//      Variables                                                                   
    StatusState:
    brk
    NumberToPrint:
    brk
    NumberToWork:
    brk
//      ******        ******         ******
//      * Code to Print
//      ******        ******         ******                                                                       *
PrintAccumlator:
    php
    sta NumberToPrint       // Store away the Accumulator
    pla                     // Pull Status From Stack
    sta StatusState         // Store Status
    pha
    pha                     // Push the Acc to Stack
    txa                     // Move X to Acc.
    pha                     // Push Acc (x) to Stack
    tya                     // Move Y to Acc.
    pha                     // Push Acc (y) to Stack
    ldy #>rgtxt             // Load Hi Byte to Y
    lda #<rgtxt             // Load Lo Byte to Acc.
    jsr String              // Print The text until hit Zero

    lda StatusState
    jsr status_register
    jsr space
    jsr BinPrint            // Print Binary Array for NumberToPrint
    jsr space               // Add a space
    jsr HexadecimalPrint    // Print Hexadecimal for NumberToPrint
    jsr space               // Add a space
    jsr DecimalPrint        // Print Decimal for NumberToPrint
    jsr CarrageReturn
    pla                     // Pull Acc (y) off Stack
    tay                     // Move Acc. To Y
    pla                     // Pull Acc (x) off Stack
    tax                     // Move Acc. to X
    pla                     // Pull Acc off Stack
    plp
    rts                     // Return Back
//          ************************************

//          ************************************                                                                            *
//          space                                                                       
//          ************************************
//          * This rotuines prints a space on the screen                                  
//          ************************************
//          *  Inputs : None                                                              
//          ************************************
//          *  Variables                                                                   
//          ************************************
//          * Code                             
space:
    lda #CHR_Space          // Load Space Character 
    jmp Print               // Print This Character
//          ************************************

//          ************************************                                                                         
//          * CarrageReturn                                                                                                                                     
//          ************************************
//          * This rotuines prints a space on the screen                                  
//          ************************************
//          *  Inputs : None                                                           
//          ************************************
//          * Variables                                                         
//          ************************************
//          * Code                                                                       
CarrageReturn:
    lda #CHR_Return         // Load Return Character 
    jmp Print               // Print This Character
//          ************************************

//          ************************************                                                                     
//          * String                                                                  
//          ************************************
//          * This routine prints a string of characters terminating in a zero byte   
//          ************************************
//          *  Inputs : Accumulator : Lo Byte Address of String                           
//          *         : Y Register  : Hi Byte Address of String                           
//          ************************************
//          * Variables                                                                   
//          ************************************
//          * Code                                                                        
String:
    sta htlo                // Store Lo Byte Address of String
    sty hthi                // Store Hi Byte Address of String
string_nxtchr:
    ldy #0                  // Initialise Index Y
    lda (htlo),y            // Load Character at address + Y
    cmp #0                  // Is it Zero?
    beq string_rts          // If Zero, goto end of routine
    jsr Print               // Print this character
    clc                     // Clear The Carry
    inc htlo                // Increase Lo Byte
    bne string_nxtchr       // Branch away if Page Not Crossed
    inc hthi                // Increase Hi byte
    jmp string_nxtchr       // Jump back to get Next Character
string_rts:
    rts                     // Return Back
//          ************************************

rgtxt:
    .byte CHR_Return
    .text "nv-bdizc binary    hex   dec."
    .byte CHR_Return
    brk 

//          ************************************
//          * status_register                                                             
//          *                                                                             
//          ************************************
//          * This routine prints the contents of the status register                     
//          ************************************
//          *  Inputs : Accumulator : Status Register                                     
//          ************************************
//          * Variables                                                                   
    streg:
    brk
//          ************************************
//          * Code                                                                        
status_register:
    ldy #0                  // Initialise Y Register
streg1:
    sta streg               // Store Acc. into Status Register Variable
streg3:
    asl streg               // logically shift the acc left, and carry set or not
    lda #0                  // Load Zero into Accu.
    adc #'0'                // Add "0" to Acc. with  carry
    cpy #2                  // is y = 2
    bne streg2              // if yes, branch past the '-' symbol
    lda #'-'                // Load Acc with "-"
streg2:
    jsr Print               // Print The contents of the Acc
    iny                     // increase the index Y
    cpy#8                   // test for 8 (8th bit of the number)
    bne streg3              // Branch if not equal back to next bit
    rts                     // Return Back
//      ******        ******         ******                                                                     
//      * BinPrint                                                                    
//      ******        ******         ******
//      * This routine prints the contents NumberToPrint as a binary number           
//      ******        ******         ******
//      *  Inputs : None                                                              
//      ******        ******         ******
//      * Variables                                                                   
//      ******        ******         ******
//      * Code                                                                        
BinPrint:
    jsr prPercent           // Print "%"
    ldy #0                  // Initialise Y Index Register with zero
    lda NumberToPrint       // Load Acc with number to print
    sta NumberToWork        // Store Acc to Number To Work
binpr4:
    asl NumberToWork        // Logically shift left Number to Work into Carry
    lda #0                  // Load Acc with Zero
    adc #0                  // Add Acc with "0" plus Carry
    jsr Print               // Print this character either '0' ot '1'
    iny                     // increase Y index
    cpy #8                  // have we hit bit 8?
    bne binpr4              // No, get next Bit
    rts                     // Return Back 
//      ******        ******         ******                                                               
//      * DecimalPrint                                                       
//      *                                                                        
//      * This routine prints the contents NumberToPrint as a decimal number         
//      ******        ******         ******
//      *  Inputs : None                                                          
//      ******        ******         ******
//      * Variables                                  
//      ******        ******         ******
//      * Code                    
DecimalPrint:
    jsr prHash              // Print "#"
    lda #$00                // Initialise Acc with zero
    ldx NumberToPrint       // Load X Register with NumberToPrint
    stx NumberToWork        // Store X Register to NumberToWork
    jmp $bdcd               // Jump To Basic Decimal Number Print Routine

//      ******        ******         ******
prDollar:
    lda #'$'
    .byte 44
prBracketOpen:
    lda #'('
    .byte 44
prBracketClosed:
    lda #')'
    .byte 44
prComma:
    lda #','
    .byte 44
prx:
    lda #'x'
    .byte 44
pry:
    lda #'y'
    .byte 44
prPercent: 
    lda #'%'
    .byte 44
prHash:
    lda #'#'
    jmp Print

//      ******        ******         ******
//      * HexaDecimalPrint                                                    
//      * This routine prints the contents NumberToPrint as a hexadecimal number      
//      ******        ******         ******
//      *  Inputs : None                                                              
//      * Variables                                                                   
//      ******        ******         ******
//      * Code                                                                        
HexadecimalPrint:
    jsr prDollar            // Print a "$"
    ldx #$00                // Initialise X Register with Zero
    lda NumberToPrint       // Load Acc with NumberToPrint
    sta NumberToWork        // Store Acc to NumberToPrint
    jmp pbyte2              // Jump to Hexadecimal routine
//      ******        ******         ******                                                 
//      * pbyte2       
//      ******        ******         ******
//      * This routine evaluates and prints a four character hexadecimal number    
//      *  Inputs : Accumulator : Lo Byte of the number to be converted              
//      *           X Register  : Hi Byte of the number to be converted               
//      ******        ******         ******
//      * Variables                                                   
//      * Code                                       
pbyte2:
    pha                     // Push Acc to the Stack 
    txa                     // Tansfer X register To Acc
    jsr pbyte1              // Execute 2 digit Hexadecimal convertor
    pla                     // Pull Acc from Stack
pbyte1:
    pha                     // Push Acc to the Stack 
                            // Convert Acc into a nibble Top '4 bits'
    lsr                     // Logically shift Right Acc
    lsr                     // Logically shift Right Acc
    lsr                     // Logically shift Right Acc
    lsr                     // Logically shift Right Acc
    jsr pbyte               // Execute 1 digit Hexadecimal number
    tax                     // Transfer Acc back into X Register 
    pla                     // Pull Acc from the Stack
    and #15                 // AND with %00001111 to filter out lower nibble
pbyte:
    clc                     // Clear the Carry
                            // Perform Test weather number is greater than 10
    adc #$f6                // Add #$F6 to Acc with carry
    bcc pbyte_skip          // Branch is carry  is still clear
    adc #6                  // Add #$06 to Acc to align PETSCII Character 'A'
pbyte_skip:
    adc #$3a                // Add #$3A to align for PETSCII Character '0'
    jmp Print               // Jump to the Print Routine for that character
//      ******        ******         ******
//      ******        ******         ******