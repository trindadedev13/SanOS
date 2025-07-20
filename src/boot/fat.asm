[BITS    16]

;FAT size (sectors) = FAT sectors * FAT tables
;FAT size (bytes) = FAT sectors * FAT tables * Bytes per sector

;---------------------------------------------------------------------

;Root entry = 32 bytes
;Root directory size = (Dir entry count * Root entry + Bytes per sector - 1) / Bytes per sectors
;Bytes per sector - 1 makes that any parcial part of an sector be rounded up to the next sector

;FILE NAME (always 11 chars) ex: "KERNEL  BIN" (uses first low cluster since its FAT12)

;---------------------------------------------------------------------

;Logical Block Address for a cluster
;LBA = Data region begin + (cluster-2) * Sectors per cluster
;Data region begin = Reserved + FAT tables + Root directory
;Data region begin = LBA address of the begin of data section in our FAT
;Cluster-2 = Storage unit since cluster 0 is reserved and cluster 1 is our FAT

;---------------------------------------------------------------------

;MicroOS File System
;FAT size (sectors) = 9 * 2 = 18
;FAT size (bytes) = 18 * 512 = 9216
;Data region begin = 19
;Root dir size = (224 * 32 + 511) / 512 = 14
;LBA = 1+18+14 + (3-2) * 1 = 33

;---------------------------------------------------------------------

;Reading files from directories

;1 - Slit path into components and convert to FAT file naming scheme

;2 - Read first directory from root directory, using same procedure as reading files.

;3 - Search the next component from the path in the directory, and read it

;4 - Repeat until reaching and reading the file

;-------------------------------------------------------------

; -------------------------------------------------------------
; Load the Root Directory into memory
; -------------------------------------------------------------
LoadRootDir:
        ; Clear DX and BX for safe division and multiplication
        xor     dx, dx
        xor     bx, bx

        ; Compute Root Directory Size:
        ; Each entry is 32 bytes, so RootDirSize = (Entries * 32) / BytesPerSector
        mov     ax, [RootDirEntries]
        shl     ax, 0x05               ; Multiply by 32 (shift left by 5)
        div     word [BytesPerSectors]

        ; Compute Root Directory LBA:
        ; RootDirLBA = ReservedSectors + (TotalFATs * SectorsPerFAT)
        mov     ax, [SectorsPerFAT]
        mov     bl, [TotalFATs]
        mul     bx                     ; AX = SectorsPerFAT * TotalFATs
        add     ax, [ReservedSectors]  ; Add reserved sectors to get RootDirLBA

        ; Setup parameters for DiskRead
        mov     cl, al                 ; Number of sectors to read = RootDirSize (from AX, now in CL)
        mov     dl, [DriveNumber]      ; Set drive number
        mov     bx, RootDirBuffer      ; Set buffer where RootDir will be stored
        call    DiskRead               ; Read the Root Directory into memory

        ret

; -------------------------------------------------------------
; Search for the kernel file ("KERNEL  BIN") in the Root Directory
; Output: kernelcluster = starting cluster of the file
; -------------------------------------------------------------
FindKernel:
        ; BX = entry counter, DI = pointer to current directory entry
        xor     bx, bx
        mov     di, RootDirBuffer

        .searchKernel:
                 ; Compare 11 characters with the expected filename
                 mov     si, kernelbin
                 mov     cx, 11
                 push    di
                 repe    cmpsb                 ; Compare current entry name with "KERNEL  BIN"
                 pop     di

                 je      .foundKernel          ; If match found, jump to handler

                 ; Move to the next 32-byte directory entry
                 add     di, 0x20
                 inc     bx

                 ; Check if all entries have been searched
                 cmp     bx, [RootDirEntries]
                 jl      .searchKernel         ; If not done, loop again

                 ; File not found
                 jmp     .failedKernel

        .foundKernel:
                 ; Extract the starting cluster of the kernel file (offset 26 in entry)
                 mov     ax, [di + 26]
                 mov     [kernelcluster], ax

                 ; Load FAT table into memory (used later for cluster chaining)
                 mov     ax, [ReservedSectors] ; Start of FAT
                 mov     bx, RootDirBuffer     ; Reuse RootDirBuffer to store FAT
                 mov     cl, [SectorsPerFAT]   ; Size of FAT in sectors
                 mov     dl, [DriveNumber]
                 call    DiskRead

                 ret

        .failedKernel:
                 ; Show error: print 'X' using BIOS teletype (int 10h)
                 mov     ah, 0x0E
                 mov     al, 'X'
                 int     0x10

                 ; Halt system
                 cli
                 hlt

; -------------------------------------------------------------
; Load the kernel into memory by following the FAT cluster chain
; -------------------------------------------------------------
LoadKernel:
        ; Setup segment where kernel will be loaded
        mov     bx, KERNELSEG
        mov     es, bx
        mov     bx, KERNELOFFSET       ; ES:BX = destination address

    .kernelLoop:
        ; Get current cluster number
        mov     ax, [kernelcluster]

        ; Add 0x1F to convert cluster number to actual LBA (FAT12 data area starts at cluster 2)
        mov     dl, [DriveNumber]
        add     ax, 0x1F
        mov     cl, 0x01               ; Read 1 sector (one cluster = one sector for FAT12)
        call    DiskRead

        ; Move buffer pointer forward for next sector
        add     bx, [BytesPerSectors]

        ; Get the FAT entry for the current cluster
        mov     ax, [kernelcluster]
        mov     cx, 0x03
        mul     cx                     ; Multiply cluster by 3 (FAT12 uses 12 bits per entry)

        mov     cx, 0x02
        div     cx                     ; AX = offset in FAT table; DX = cluster % 2

        ; Read FAT entry from buffer
        mov     si, RootDirBuffer
        add     si, ax
        mov     ax, [ds:si]            ; Read 2 bytes (because FAT12 entries are packed)

        or      dx, dx
        jz      .even                  ; Even cluster: lower 12 bits
                                       ; Odd cluster: upper 12 bits

    .odd:
        shr     ax, 0x04               ; Odd entries: shift right 4 bits
        jmp     .nextCluster

    .even:
        and     ax, 0x0FFF             ; Mask lower 12 bits for even entries

    .nextCluster:
        ; If cluster is >= 0x0FF8, end of file reached
        cmp     ax, 0x0FF8
        jae     .end

        ; Not end of chain: load next cluster
        mov     [kernelcluster], ax
        jmp     .kernelLoop

    .end:
        ; Set DS and ES to point to kernel segment before jumping
        mov     dl, [DriveNumber]
        mov     ax, KERNELSEG
        mov     ds, ax
        mov     es, ax

        ; Jump to kernel start
        jmp     KERNELSEG:KERNELOFFSET

        ; Should never reach this point
        cli
        hlt
