[BITS    16]

; ==== Screen ====
; 320x200
; width = 320
; height = 200
; ================


; al = char
; bl = color
PrintChar:
        mov      ah, 0x0E
        int      0x10
        ret

; si = str
; bl = color
PrintString:
        mov      ah, 0x0e                   ; teletype output
        mov      al, [si]                   ; al = *si

        PrintString.Loop:
                 int      0x10              ; draw

                 inc      si                ; si++
                 mov      al, [si]          ; al = *si
                 cmp      al, 0x00          ; compare if current char is null(0x00)
                 jne      PrintString.Loop  ; jump if not equals to next letter

        ret