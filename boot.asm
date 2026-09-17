%define LOAD_ADDRESS 0x7C00
;;%define N            0x10000

[BITS 16]
	cli

	; us above, stack below
	mov ax, LOAD_ADDRESS / 0x10
	mov ds, ax
	mov ss, ax
	mov sp, 0
	mov bp, sp


	; reading FLOPPY sectors, bios gave us DL (drive number)
	mov ch, 0                             ; C*, floppy: [0, 79]
	mov dh, 0                             ; H,  floppy: [0, 1]
	mov cl, 2 ; don't (re-)read ourselves ; S,  floppy: [1, 18]

	mov di, (LOAD_ADDRESS + 0x200) / 0x10 ; reading destination
	mov si, N / 0x200                     ; remaining unread sectors

read_sector:
	; reading one sector at a time by moving the extra segment (no offset)
	mov ah, 0x2
	mov al, 1
	mov es, di
	mov bx, 0
	int 0x13

	; handle error
	jc party


	add di, 0x200 / 0x10
	dec si
	cmp si, 0
	jna halt


	inc cl
	cmp cl, 18
	jna read_sector
.carry_s:
	mov cl, 1
	inc dh
	cmp dh, 1
	jna read_sector
.carry_h:
	mov dh, 0
	inc ch
	cmp ch, 79
	jna read_sector

	; handle overflow
	jmp party


halt:
	hlt


party:
	mov ah, 0x0B
	;xor bh, bh
	inc bl
	int 0x10

	mov ah, 0x0E
	mov al, '!'
	int 0x10

	jmp party


___boot_sector_signature:
	times 510-($-$$) db 0
	db 0b01010101
	db 0b10101010
