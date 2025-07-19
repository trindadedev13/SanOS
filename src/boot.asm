[BITS    16]
[ORG     0x7C00]

; OS Start
BootMain:
         ; Set 13h Video Mode
         mov     ah, 0x00    ; set mode
         mov     al, 0x13    ; 13h
         int    0x10
         
         ; Draw the Welcome
         mov     si, welcome
         mov     bl, 0x0A    ; color = green
         call    DrawString

         ; Draw the SanOS Text
         mov     si, sanOS
         mov     bl, 0x0C    ; color = red
         call    DrawString

         jmp     $

welcome: db "Welcome to ", 0x00
sanOS: db "SanOS!", 0x00

%include "src/draw.asm"

; Fill the bytes to fit 512
times 510 - ($ - $$) db 0x00
dw    0xAA55