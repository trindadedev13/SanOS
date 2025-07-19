[BITS    16]
[ORG     0x7C00]

BootMain:
         ; Set 13h Video Mode
         mov    ah, 0x00    ; set mode
         mov    al, 0x13    ; 13h
         int    0x10

         mov    si, welcome
         mov    bl, 0x0A    ; color = green
         call   DrawString

         mov    si, sanOS
         mov    bl, 0x0C    ; color = red
         call   DrawString

         jmp    $

welcome: db "Welcome to ", 0x00
sanOS: db "SanOS!", 0x00

%include "src/draw.asm"

times 510 - ($ - $$) db 0x00
dw    0xAA55