[BITS    16]
[ORG 0x0000]

KernelMain:

         ; mov     [DriveNumber], dl

         ; Set 13h Video Mode
         mov     ah, 0x00    ; set mode
         mov     al, 0x13    ; 13h
         int     0x10

         ; Draw the Welcome
         mov     si, welcome
         mov     bl, 0x0A    ; color = green
         call    PrintString

         ; Draw the SanOS Text
         mov     si, sanOS
         mov     bl, 0x0C    ; color = red
         call    PrintString

         jmp     $

welcome: db "Welcome to ", 0x00
sanOS: db "SanOS!", 0x00

%include "src/graphics/graphics.asm"
%include "src/drivers/keyboard.asm"