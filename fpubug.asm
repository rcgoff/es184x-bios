;this program causes INT from 8087
;during sqrt(-2.0)
;in ES1841, when SW1.1 deleted,
;8087's INT drives 8086's NMI

;but because of PORTC.7 leaved unconnected,
;and NMI handler in BIOS leaved the same 
;as in 5150 PC, NMI handler will produce
;"parity check 1" and halt the system 

;L.Yadrennikov (RCgoff) 17.10.2017


code	segment
assume	cs:code, ds:code, ss:code, es:code
org	100h
main	proc
	finit
	mov	ax,0ff00h
	fstcw	fpusta
	and	ax,fpusta	;disable all exception and interrupt masks in FPU status
	mov	fpusta,ax
	fldcw	fpusta
	fld	x		;load -2.0
	fsqrt			;comput sqt, should be interrupt here
	fstp	z               ;if no, load result to mem (should be "indef")
	push	cs
	pop	ds
	mov	dx,offset z
	mov	ah,09h
	int	21h             ;out result to console
	mov	ax,4c00h
	int	21h             ;exit to ms-dos
main	endp
x	dd	-2.0
fpusta	dw	?
z	dd	?	
usd	db	24h
code	ends
end	main
