[BITS    16]

; ah = Scancode of the key pressed down
; al = ASCII char of the button pressed
ReadKey:
         mov     ax, 0x00
         int     0x16
         ret