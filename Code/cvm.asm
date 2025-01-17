#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
		
			jmp ioinit
			db     	5 dup(0)
			dw		interrupt
			dw		0000
			db		1012 dup(0)
			
ioinit:		
		porta		equ 	10h
		portb		equ		12h
		portc		equ		14h
		ctrio		equ		16h
		
		weight_need	equ		02h
		motor		equ		03h
		button		equ		04h
		choc_no_1	equ		05h
		choc_no_2	equ		06h
		choc_no_3	equ		07h
		
		mov ax,0100h
        mov ds,ax
        mov es,ax
        mov ss,ax
        mov sp,0FFFEh
		
		mov al,10010001b
		out	ctrio,al
		
		mov al,10
		mov choc_no_1,al
		mov choc_no_2,al
		mov choc_no_3,al
		
x1:		jmp x1

interrupt:
		
		call delay		
		in al,portc		;stores state of buttons in al then checks if a button has been pressed
		and al,07h
		cmp al,07h
		jz exitp
		
		call delay
		in al,portc		;stores state of buttons in al then checks if a button has been actually pressed
		and al,07h
		mov button,al
		cmp al,07h
		jz exitp
		
		mov di,05h
		mov motor,00001100b
		
but1:					;button 1 was pressed the weight of the coins needed is stored
		cmp button,06h
		jnz but2
		mov weight_need,
		jmp x3
		
but2:					;button 2 was pressed the weight of the coins needed is stored and the motor selected
		cmp button,05h
		jnz but3
		mov weight_need,
		xor motor,00010000b
		inc di
		jmp x3
		
but3:					;button 3 was pressed the weight of the coins needed is stored and the motor selected
		cmp button,03h
		jnz exitp
		mov weight_need,
		xor motor,00100000b
		inc di
		inc di
x3:		
		mov bx,1770h

twomindelay:			
		call delay
		dec bx
		jnz twomindelay
		
		in al,porta
		cmp al,weight_need			;equal or more coin
		jb exitp
		
		out portb,motor
		xor motor,00001010b
		out portb,motor				;motor turned by one step
		xor motor,00000101b
		out portb,motor
		xor motor,00001010b
		out portb,motor
		
		sub [di],1
		
choc1:								;checking if chocolate 1 finished
		cmp [05h],0
		jnz choc2
		mov al,00001111
		out ctrio,al
choc2:								;checking if chocolate 2 finished
		cmp [06h],0
		jnz choc3
		mov al,00001101
		out ctrio,al
choc3:								;checking if chocolate 3 finished
		cmp [07h],0
		jnz exitp
		mov al,00001011
		out ctrio,al
		
exitp:		iret		
		
.exit

delay proc near
		mov cx,30d4h
	x2:	nop							;20ms delay
		nop
		nop
		nop
		loop x2
		ret
delay endp

end