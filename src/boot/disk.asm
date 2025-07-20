[BITS 16]

; -------------------------------------------------------------
; Converts a Logical Block Address (LBA) to Cylinder-Head-Sector (CHS) format
; Input : AX = LBA address
; Output: CH = cylinder low 8 bits
;         CL = sector number (1-based)
;         DH = head number
;         DL = drive number (unchanged)
; Registers preserved: AX, DX
; -------------------------------------------------------------
LBAtoCHS:
        ; Save original AX and DX to the stack
        push    ax
        push    dx

        ; Zero DX to prepare for 16-bit division
        xor     dx, dx
        ; Divide AX (LBA) by [SectorsPerTrack]
        ; Result: AX = quotient (LBA / SPT), DX = remainder (LBA % SPT)
        div     word [SectorsPerTrack]

        ; Sector = remainder + 1 (because sector numbers start from 1)
        inc     dx
        mov     cx, dx     ; Store sector number in CX (CL will be used later)

        ; Prepare for next division
        xor     dx, dx
        ; Divide AX (which now holds LBA / SPT) by [HeadsOrSides]
        ; Result: AX = cylinder number, DX = head number
        div     word [HeadsOrSides]

        ; Store head number in DH
        mov     dh, dl

        ; Store low 8 bits of cylinder number in CH
        mov     ch, al
        ; Shift high 2 bits of cylinder (from AH) into bits 6-7 of CL
        shl     ah, 0x06
        or      cl, ah     ; Combine high bits of cylinder into CL

        ; Restore saved AX (contains original LBA)
        pop     ax

        ; Move saved LBA (AX) into DL (restoring original DL value)
        mov     dl, al

        ; Restore original AX
        pop     ax

        ret

; -------------------------------------------------------------
; Reads disk geometry (SectorsPerTrack and HeadsOrSides)
; Output:
;   [SectorsPerTrack] = number of sectors per track (1–63)
;   [HeadsOrSides] = number of heads (sides)
; -------------------------------------------------------------
ReadDrive:
        pusha               ; Save all general-purpose registers

        ; Call BIOS function 08h to get drive parameters
        mov     ah, 0x08
        int     0x13

        ; Mask CL to keep only the lower 6 bits (sector count)
        and     cl, 0x3F
        xor     ch, ch
        mov     word [SectorsPerTrack], cx    ; Store sectors per track (CX)

        ; DH = number of heads - 1 → increment to get total heads
        inc     dh
        mov     [HeadsOrSides], dh            ; Store number of heads

        popa                ; Restore all registers

        ret

; -------------------------------------------------------------
; Reads sectors from disk using BIOS interrupt 13h
; Input:
;   AX = LBA address to read from
;   CL = Number of sectors to read
;   DL = Drive number
;   ES:BX = Memory buffer to store data
; -------------------------------------------------------------
DiskRead:
        pusha               ; Save all general-purpose registers

        push    cx          ; Save sector count

        call    LBAtoCHS    ; Convert LBA to CHS values (CH, CL, DH)

        pop     ax          ; Restore sector count into AX

        mov     ah, 0x02    ; BIOS function: Read sectors
        int     0x13        ; Call BIOS to read from disk

        popa                ; Restore registers

        ret
