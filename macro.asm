// Macros

// macro to print text
   .macro PrintText(Address)  
    {
    ldy # >Address             // Load Hi Byte to Y
    lda # <Address             // Load Lo Byte to Acc.
                               // Print The text until hit Zero
      jsr String
    }