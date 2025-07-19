[BITS    16]

;
; Screen
; 320x200
; width = 320
; height = 200
;


; al = color
; cx = x
; dx = y
SetPixel:
         mov ah, 0x0C
         int 0x10
         ret

; si = string
; bl = color
DrawString:
         mov    ah, 0x0E ; Teletype output
         mov    al, [si] ; al = *si (si[0])

         DrawLoop:
                 int    0x10       ; draw

                 inc    si         ; si++
                 mov    al, [si]   ; al = *si
                 cmp    al, 0x00   ; compare if al is 0(null)
                 jne    DrawLoop   ; if no, draw
         ret
