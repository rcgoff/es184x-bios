;___________________
;  БАЗОВАЯ СИСТЕМА ВВОДА/ВЫВОДА (БСУВВ)
;___________________
port_a	equ	60h
cod	equ	0f000h
dat	equ	0040h
sta	equ	0030h
xxdat	equ	0050h
;video_ra equ	0b800h
port_b	equ	61h
port_c	equ	62h
cmd_port equ	63h
inta00	equ	20h
inta01	equ	21h
eoi	equ	20h
timer	equ	40h
tim_ctl equ	43h
timero	equ	40h
tmint	equ	01
dma08	equ	08
dma	equ	00
max_period equ	540h
min_period equ	410h
kbd_in	equ	60h
kbdint	equ	02
kb_dat	equ	60h
kb_ctl	equ	61h


e1l	equ	4