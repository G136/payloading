%define LOAD_ADDRESS 0x7C00     ; this being a multiple of 0x10 is assumed
;;%define N            0x10000
;;^^^^^^^^^ is there a convention to declare im excpecting this from the outside

[BITS 16]
	cli

	; us above, stack below
	mov ax, LOAD_ADDRESS / 0x10
	mov ds, ax

	xor ax, ax
	mov ss, ax
	mov sp, LOAD_ADDRESS
	;mov bp, sp


	; reading FLOPPY sectors, bios gave us DL (drive number)
	mov ch, 0                             ; C*, floppy: [0, 79]
	mov dh, 0                             ; H,  floppy: [0, 1]
	mov cl, 2 ; don't (re-)read ourselves ; S,  floppy: [1, 18]

	mov di, (LOAD_ADDRESS + 0x200) / 0x10 ; reading destination
	mov si, (N + 0x1ff) / 0x200           ; remaining unread sectors

read_sector:
	; reading one sector at a time by moving the extra segment (no offset)
	mov ah, 0x2
	mov al, 1
	mov es, di
	mov bx, 0
	int 0x13

	; handle reading error
	jc party


	; iterate
	add di, 0x200 / 0x10
	dec si
	cmp si, 0
	jna read_fin


	inc cl
	cmp cl, 18
	jna read_sector

	; carry S
	mov cl, 1
	inc dh
	cmp dh, 1
	jna read_sector

	; carry H
	mov dh, 0
	inc ch
	cmp ch, 79
	jna read_sector

	; handle overflow
	jmp party


read_fin:
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


signature:
	times 510-($-$$) db 0
	db 0b01010101
	db 0b10101010
