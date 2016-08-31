TITLE	lab05
; Programmer:	Marcus Ross
; Due:		21 Mar, 2014
; Description:	This program takes a hard coded initial value for a wholesale price, then, for ten iterations, adds 25 to it, calculates a markup amount, calculates a retail price, calculates a discount amount, calculates a sale price and displays all said values. After the last iteration, it displays the sum of values for each type of price.

		.MODEL SMALL
		.386
		.STACK 64
;==========================
		.DATA
loops		EQU	10	; for loop counter
gap		EQU	25	; added to wholesale price each loop
whole		DW	10	; wholesale price; 0th iteration
retail	DW	?	; retail price
wholeSum	DW	?	; sum of wholesale prices
retailSum	DW	?	; sum of retail prices
saleSum	DW	?	; sum of sale prices
newLine	DB	10, 13, 36
tab		EQU	9	; ASCII
dollar	EQU	36	; ASCII
colon		EQU	58	; ASCII
header	DB	9, 'Whole', 9, 'Markup', 9, 'Retail', 9, 'Discnt.', 9, 'Sale', 10, 13, 36
total		DB	'Total:', 9, 36
;==========================
		.CODE

		EXTRN	GetDec : NEAR, PutDec : NEAR

Main		PROC	NEAR
		mov	ax, @data	; init data
		mov	ds, ax	; segment register

		call	dispHead	; display header

		mov	cx, loops	; number of times to loop

begin:	call	calcWhole	; determine wholesale price to operate on
		call	calcMark	; determine markup amount
		call	calcRtail	; determine retail price
		call	calcDisc	; determine discount amount
		call	calcSale	; determine sale price
		call	dispRep	; display report

		dec	cx		; decrement loop counter
		jnz	begin		; loop if loop counter != 0

		call	dispTot	; display totals

		mov	ax, 4c00h	; return code 0
		int	21h
		ENDP
;==========================
dCh		MACRO	char		; display character
		mov	dl, char
		mov	ah, 2h
		int	21h
		ENDM
;==========================
dispHead	PROC	NEAR
		mov	dx, OFFSET header
		mov	ah, 9h	; display column headers
		int	21h
		ret
		ENDP
;==========================
calcWhole	PROC	NEAR
		add	whole, gap		; add 25 to previous wholesale price
		mov	ax, whole		; prep to operate on whole
		add	wholeSum, ax	; add new wholesale to running total
		ret
		ENDP
;==========================
calcMark	PROC	NEAR
		cmp	ax, 100		; wholesale - 100
		jb	less100		; jump if whole < 100
		mov	bx, 45		; if whole !< 100, markup = 45
		jmp	doneMark		; jump to end

less100:	cmp	ax, 50		; wholesale - 50
		jbe	less50		; jump if whole <= 50
		mov	bx, 35		; if whole !<= 50, markup = 35
		jmp	doneMark		; jump to end

less50:	mov	bx, 25		; if whole <= 50, markup = 25
doneMark:	ret
		ENDP
;==========================
calcRtail	PROC	NEAR
		add	ax, bx		; whole + markup = retail
		mov	retail, ax		; store retail price for display
		add	retailSum, ax	; add retail to running total
		ret
		ENDP
;==========================
calcDisc	PROC	NEAR
		cmp	ax, 125	; retail - 125
		jbe	less125	; jump if <= 125
		cmp	ax, 250	; retail - 250
		jb	less250	; jump if < 250
		mov	dx, 75	; if retail >= 250, discount = 75
		jmp	doneDisc	; jump to end

less250:	mov	dx, 50	; if retail < 250, discount = 50
		jmp	doneDisc	; jump to end

less125:	mov	dx, 25	; if retail <= 125, discount = 25
doneDisc:	ret
		ENDP
;==========================
calcSale	PROC	NEAR
		sub	ax, dx		; retail - discount = sale price
		add	saleSum, ax	; add sale price to running total
		ret
		ENDP
;==========================
dispRep	PROC	NEAR
		push	ax		; sale price
		push	dx		; discount

		mov	ax, cx	; operate on loop counter
		sub	ax, 11	; |n-11| = iteration number
		neg	ax
		call	PutDec	; display iteration number
		dCh	colon		; display colon
		dCh	tab		; display tab

		dCh	dollar	; display dollar sign
		mov	ax, whole	; display wholesale price
		call	PutDec
		dCh	tab		; display tab

		dCh	dollar	; display dollar sign
		mov	ax, bx	; display markup amount
		call	PutDec
		dCh	tab		; display tab

		dCh	dollar	; display dollar sign
		mov	ax, retail	; display retail price
		call PutDec
		dCh	tab		; display tab

		dCh	dollar	; display dollar sign
		pop	dx		; discount
		mov	ax, dx	; display discount amount
		call PutDec
		dCh	tab		; display tab

		dCh	dollar	; display dollar sign
		pop	ax		; save price
		call	PutDec	; display save price

		mov	dx, OFFSET newLine
		mov	ah, 9h	; display new line
		int	21h
		ret
		ENDP
;==========================
dispTot	PROC	NEAR
		mov	dx, OFFSET total
		mov	ah, 9h	; display row header
		int	21h

		dCh	dollar	; display dollar sign
		mov	ax, wholeSum
		call	PutDec	; display sum of wholesales
		dCh	tab		; display tab
		int	21h		; display another tab

		dCh	dollar	; display dollar sign
		mov	ax, retailSum
		call	PutDec	; display sum of retails
		dCh	tab		; display tab
		int	21h		; display another tab

		dCh	dollar	; display dollar sign
		mov	ax, saleSum
		call	PutDec	; display sum of sales
		ret
		ENDP
;==========================
	END	Main