;This source code made by Gleb Larionov, Prague.
;Changed by Leonid Yadrennikov, Tyumen.
;v1 - 05.10.2021 - ros_checksum removed, ES1841 memory switching-on added
;v2 - 13.10.2021 - int vector table loader and table itself shortened (like in PCBIOSv3),
;		   BX register in STGTST is free
;___________________	 	 	 	
; v4 - ??/??/???? (Other version than 24/04/1981) новая клавиатура
 PAGE 55,120
;  БАЗОВАЯ СИСТЕМА ВВОДА/ВЫВОДА (БСУВВ)
;___________________
port_a	equ	60h
cod	equ	0f000h
dat	equ	0040h
sta	equ	0030h
xxdat	equ	0050h
video_ra equ	0b800h
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
;_______________
;  Расположение прерываний 8086
;_________________________
abs0	segment para
zb	label	byte
zw	label	word
stg_loc0 label	byte
 	org	2*4
nmi_ptr label	word
 	org	5*4
int5_ptr label	word
 	org	8*4
int_addr label	word
int_ptr label	dword
 	org	0dh*4
hdisk_int  label  dword
 	org	10h*4
video_int label word
 	org	13h*4
org_vector  label  dword
 	org	19h*4
boot_vec  label  dword
 	org	1dh*4
parm_ptr label	dword
 	org	01eh*4
disk_pointer label dword
diskette_parm  label  dword
 	org	01fh*4
ext_ptr label	dword
 	org	040h*4
disk_vector  label  dword
 	org	041h*4

hf_tbl_vec  label  dword
 	org	410h
eq_fl	label	byte

 	org	413h
mem_siz label	word
 	org	472h
res_fl	label	word
 	org	4d0h
csi	label	word
 	org	4e0h
tabl1	label	word
 	org	7c00h
boot_locn label far
abs0	ends

;______________________
;  Использование стека только во время инициализации
;______________________
stac	segment para stack
 	dw	128 dup(?)



tos	label	word
stac	ends

;______________________
;  Область данных ПЗУ
;____________________
data segment	para
rs232_base dw 4 dup(?)



printer_base dw 4 dup(?)



equip_flag dw ?
mfg_tst db	?
memory_size dw	?
io_ram_size dw	?
;_______________
;  Область данных клавиатуры
;_________________
kb_flag db	?

;  Размещение флажков в kb_flag

ins_state equ	80h
caps_state equ	40h
num_state equ	20h
scroll_state equ 10h
alt_shift equ	08h
ctl_shift equ	04h
left_shift equ	02h
right_shift equ 01h

kb_flag_1 db	?

ins_shift equ	80h
caps_shift equ	40h
num_shift equ	20h
scroll_shift equ 10h
hold_state equ	08h
inv_shift equ	04h
lat	 	equ	02h
lat_shift	equ	01h



alt_input db	?
buffer_head dw	?
buffer_tail dw	?
kb_buffer dw	16 dup(?)



kb_buffer_end label word

;  head=tail указывает на заполнение буфера

num_key equ	69
scroll_key equ	70
alt_key equ	56
ctl_key equ	29
caps_key equ	86
left_key equ	84
right_key equ	85
ins_key equ	82
del_key equ	83
inf_key   equ	89
inv_key_l  equ	88
inv_key_r equ	90
rus_key    equ	91
lat_key equ	87

;____________________
;  Область данных НГМД
;____________________
seek_status db	?
;
;
int_flag equ	080h
motor_status db ?
;
;
motor_count db	?
motor_wait equ	37

;
diskette_status db ?
time_out equ	80h
bad_seek equ	40h
bad_nec  equ	20h
bad_crc  equ	10h
dma_boundary equ 09h
bad_dma  equ	08h
record_not_fnd equ 04h
write_protect equ 03h
bad_addr_mark equ 02h
bad_cmd equ	01h

cmd_block  label  byte
hd_error  label  byte
nec_status db	7 dup(?)




;_____________________
;  Область данных ЭЛИ
;_____________________
crt_mode db	?
crt_cols dw	?
crt_len  dw	?
crt_start dw	?
cursor_posn dw	8 dup(?)



cursor_mode dw	?
active_page db	?
addr_6845 dw	?
crt_mode_set db ?
crt_pallette db ?

;___________________
;  Область данных НМД
;___________________
io_rom_init dw	?
io_rom_seg dw	?
last_val db	?

;___________________
;  Область данных таймера
;___________________
timer_low dw	?
timer_high dw	?
timer_ofl db	?
;___________________
;  Область данных системы
;___________________
bios_break db	?
reset_flag dw	?
diskw_status  db  ?
hf_num	db   ?
control_byte  db  ?
port_off  db  ?
 	 	org	7ch
stat_offset	label	byte ; смещение для хранения состояний модема

 	org	80h
buffer_start	dw	?
buffer_end	dw	?
 	org	0090h
idnpol	dw	?
 	org	0e0h
tabl	label	word

	org	3ff0h
tmp_tos	label	word
;
data	ends

;___________________
;  Область расширения данных
;_________________________________
xxdata segment	para
status_byte db	?
xxdata	ends

;_________________
;  Буфер ЭЛИ
;___________________
video_ram segment para
regen	label	byte
regenw	label	word
 	db	16384 dup(?)



video_ram ends
;____________________
;  Основной массив в ПЗУ (сегмент code)
;____________________

code segment para

		org 0E000h

a5700051Copr_Ib	db '5700051 copr. ibm 1981'
c1		dw offset c11		; адрес	возврата
caw		dw offset ca3
 	assume cs:code,ss:code,es:abs0,ds:data

stgtst:
 	 	mov	cx,4000h

stgtst_cnt	proc	near
		shr	cx,1		;rc words count is 2x less than bytes
		cld
		mov	ds, cx
		mov	ax, 0FFFFh
		mov	dx, 0AA55h
		sub	di, di
		repe stosw

c2a:
		dec	di
		dec	di
		std

c2b:
		mov	si, di
		mov	cx, ds
;---------------rc:
		mov	bh, ah
		mov	bl, bh		;rc now old pattern is in BX

c3:
		db	26h		;rc ES segment prefix
		lodsw
		xor	ax, bx
		jnz	c7x
		in	al, 62h
		and	al, 40h
		mov	al, 0
		jnz	c7x
		cmp	bx, 0
		jz	c3a
		mov	al, dl
		mov	ah, al		;rc now new pattern is in AX
		stosw

c3a:
		loop	c3
		cmp	bx, 0
		jz	c7x
		mov	bx, ax
		xchg	dh, dl
		cld
		inc	di
		inc	di
		jz	c2b
		dec	di
		dec	di
		mov	dx, 1
		jmp	short c2a

c7x:
		retn
stgtst_cnt	endp


;____________________
;  Сброс системы - фаза 1
;____________________
;_____________________
;  Проверка 16К памяти
;_____________________
;___________________
;  ТЕСТ.01
;	Тест процессора 8086. Осуществляет проверку регистра
;	признаков, команд перехода и считывания-записи
;	общих и сегментных регистров.
;_____________________________________
reset	label	near
start:	cli	 	 	; сброс признака разрешения прерывания
 	mov	ah,0d5h 	;уст признаки SF,CF,ZF,AF
 	sahf
 	jnc	err01	 	;CF=0,в программу ошибок
 	jnz	err01	 	;ZF=0,в программу ошибок
 	jnp	err01	 	;PF=0,в программу ошибок
 	jns	err01	 	;SF=0,в программу ошибок
 	lahf	 	 	;загрузить признаки в AH
 	mov	cl,5	 	;загрузить счетчик
 	shr	ah,cl	 	;выделить бит переноса
 	jnc	err01	 	;признак AF=0
 	mov	al,40h	 	;уст признак переполнения
 	shl	al,1	 	;уст для контроля
 	jno	err01	 	;признак OF не уст
 	xor	ah,ah	 	;уст AH=0
 	sahf	 	 	;уст в исходное состояние SF,CF,ZF,PF
 	jc	err01	 	;признак CF=1
 	jz	err01	 	;признак ZF=1
 	js	err01	 	;признак SF=1
 	jp	err01	 	;признак PF=1
 	lahf	 	 	;загрузить признаки в AH
 	mov	cl,5	 	;загрузить счетчик
 	shr	ah,cl	 	;выделить бит переноса
 	jc	err01	 	;признак IF=1
 	shl	ah,1	 	;контроль, что OF сброшен
 	jo	err01
 	mov	ax,0ffffh	;уст эталона в AX
 	stc
c8:	mov	ds,ax	 	;запись во все регистры
 	mov	bx,ds
 	mov	es,bx
 	mov	cx,es
 	mov	ss,cx
 	mov	dx,ss
 	mov	sp,dx
 	mov	bp,sp
 	mov	si,bp
 	mov	di,si
 	jnc	c9
 	xor	ax,di	 	;проверка всех регистров
 	 	 	 	;эталонами "FFFF", "0000"
 	jnz	err01
 	clc
 	jnc	c8
c9:
 	or	ax,di	 	;нулевым шаблоном все регистры проверены ?
 	jz	c10	 	;ДА - переход к следующему тесту
err01:	jmp   short  start
;_______________________
; ТЕСТ.02
;_______________________
c10:
 	mov	al,0	 	;запретить прерывaния NMI
 	out	0a0h,al
 	out	83h,al	 	;инициализация регистрa страниц ПДП
 	mov	al,99h	 	;уст A,C -ввод, B - вывод
       out	cmd_port,al	 	;запись в регистр режима
 	 	 	 	 	;трехканального порта
 	mov	al,0fch 	 	;блокировка контроля по четности
 	out	port_b,al
 	sub	al,al
 	mov	dx,3d8h
 	out	dx,al	 	;блокировка цветного ЭЛИ
 	inc	al
 	mov	dx,3b8h
 	out	dx,al	 	;блокировка черно-белого ЭЛИ
 	mov	ax,cod	 	;уст сегментного регистра SS
 	mov	ss,ax
 	mov	bx,0e000h	 	;уст начального адреса памяти
 	mov	sp,offset c1	 	;уст адреса возврата
 	jmp	short ros
		nop
c11:	jne	err01
;------------------------
;  ТЕСТ.03
;   Осуществляет проверку, инициализацию и запуск ПДП и
; таймера 1 для регенерации памяти
;_________________________
;   Блокировка контроллера ПДП

ros:	mov	al,04
 	out	dma08,al

;   Проверка правильности функционирования
;   таймера 1

 	mov	al,54h	 	;выбор таймера 1,LSB, режим 2
 	out	timer+3,al
 	sub	cx,cx
 	mov	bl,cl
 	mov	al,cl	 	;уст начального счетчика таймера в 0
 	out	timer+1,al
c12:
 	mov	al,40h
 	out	timer+3,al
 	in	al,timer+1	;считывание счетчика таймера 1
 	or	bl,al	 	;все биты таймера включены ?
 	cmp	bl,0ffh 	;ДА - сравнение с FF
 	je	c13	 	;биты таймера сброшены
 	loop	c12	 	;биты таймера установлены
 	jmp	short err01	;сбой таймера 1, останов системы
c13:
 	mov	al,bl	 	;уст счетчика таймера 1
 	sub	cx,cx
 	out	timer+1,al
c14:	 	;цикл таймера
 	mov	al,40h
 	out	timer+3,al
 	in	al,timer+1	 	;считывание счетчика таймера 1
 	and	bl,al
 	jz	c15
 	loop	c14	 	;цикл таймера
 	jmp	short err01

;   Инициализация таймера 1

c15:
 	mov	al,54h
 	out	timer+3,al	;запись в регистр режима таймера
 	mov	al,7	;уст коэффициента деления для регенерации
 	out	timer+1,al	;запись в счетчик таймера 1
 	out	dma+0dh,al	;послать гашение ПДП

;   Цикл проверки регистров ПДП

 	mov	al,0ffh 	;запись шаблона FF во все регистры
c16:	mov	bl,al	 	;сохранить шаблон для сравнения
 	mov	bh,al
 	mov	cx,8	 	;уст цикла счетчика
 	mov	dx,dma	 	;уст адреса регистра порта ввода/вывода
c17:	out	dx,al	 	;запись  шаблона в регистр
 	out	dx,al	 	;старшие 16 бит регистра
 	mov	ax,0101h	;изменение AX перед считыванием
 	in	al,dx
 	mov	ah,al	 	;сохранить младшие 16 бит регистра
 	in	al,dx
 	cmp	bx,ax	 	;считан тот же шаблон ?
 	je	c18	 	;ДА - проверка следующего регистра
 	jmp	err01	 	;НЕТ - ошибка
c18:	 	 	 	;выбор следующего регистра ПДП
 	inc	dx	 	;установка адреса следующего
 	 	 	 	;регистра ПДП
 	loop	c17	 	;запись шаблона для следующего регистра
 	not	al	 	  ;уст шаблона в 0
 	jz	c16

;   Инициализация и запуск ПДП

 	mov	al,0ffh 	;уст счетчика 64K для регенерации
 	out	dma+1,al
 	out	dma+1,al
 	mov	al,058h 	;уст режим ПДП, счетчик 0, считывание
 	out	dma+0bh,al	;запись в регистр режима ПДП
 	mov	al,0	 	;доступность контроллера ПДП
 	out	dma+8,al	;уст регистр команд ПДП
 	out	dma+10,al	;доступность канала 0 для регенерации
 	mov	al,41h	 	;уст режим дла канала 1
 	out	dma+0bh,al
 	mov	al,42h	 	;уст режим для канала 2
 	out	dma+0bh,al
 	mov	al,43h	 	;уст режим для канала 3
 	out	dma+0bh,al
;======================================RCgoff begin
;-----------------turn ES1841 memory on, if present
		mov dx,2b0h
		mov al,0ch			;0b0000.1100 - turn RD,WR on, no reconfig
		out dx,al
;======================================RCgoff end
		mov	ax, dat
		mov	ds, ax
		
		mov	bx, ds:reset_flag
		mov si, ds:memory_size		;keep memory size in SI after reboot
		sub	ax, ax
		mov	es, ax
		in	al, port_c
		and	al, 0Fh
		inc	al
		add	al, al
		mov	dx, 0
		mov	bp,ax				;BP will be segment count (and will be 0, i.e. no error, after finish)
		xor	ax, ax				;write 0 to mem
		cld

		sub	di, di				;not in loop because after writing 32768 words already will be DI=0
c19:
		mov	cx, 32768
		rep stosw				;clear full segment (32768 words=6536 bytes)
		add	dx, 4096			;next segment
		mov	es, dx
		dec	bp
		jz	c21
		jmp	short c19
;____________________
;   Инициализация контроллера
;   прерываний 8259
;____________________
c21:
 	mov	al,13h	 	;ICW1 - EDGE, SNGL, ICW4
 	out	inta00,al
 	mov	al,8	 	;УСТ ICW2 - прерывание типа 8(8-F)
 	out	inta01,al
 	mov	al,9	 	;уст ICW4 - BUFFERD , режим 8086
 	out	inta01,al
		sub	ax, ax
		mov	es, ax
									;DS still points to BIOS data area
		mov	ds:reset_flag, bx
		mov	ds:memory_size, si
		cmp	ds:reset_flag, 1234h
		jz	c25
		mov	ds, ax
		mov	sp, offset tmp_tos
		mov	ss, ax
		mov	di, ax
		mov	bx, 9*4		; int 9	(KBD)
		mov	word ptr [bx], offset d11
		inc	bx
		inc	bx
		mov	[bx], cs
		call	kbd_reset
		cmp	bl, 65h		; Manufacturing test mode - viz document in BIOS root or http://www.vcfed.org/forum/archive/index.php/t-12377.html
		jnz	c23
		mov	dl, 0FFh

c22:
		call	sp_test
		mov	al, bl
		stosb
		dec	dl
		jnz	c22
		int	3Eh

c23:
		push	cs
		pop	ss
		assume ss:code
		cli
		mov	sp, offset caw	; [caw]	= offset ca3 (next jmp -> indirect call)
		jmp	stgtst

ca3:
		jz	c25
		jmp	err01

;   Установка сегмента стека и SP

c25:
 	mov	ax,sta	 	;получить величину стека
 	mov	ss,ax	 	;уст стек
 	mov	sp,offset tos	;стек готов
 	jmp	short tst6	;переход к следующему тесту

;ros_checksum proc  near
; 	mov	cx,8192 	;число байт для сложения
; 	xor	al,al
;c26:	add	al,cs:[bx]
; 	inc	bx	 	;указание следующего байта
; 	loop	c26	 	;сложить все байты в модуле ROS
; 	or	al,al	 	;сумма = 0 ?
; 	ret
;ros_checksum endp
;______________________
;   Начальный тест надежности
;______________________
 	assume	cs:code,es:abs0

d1		db 'parity check 2'


d1l	equ	14
d2		db 'parity check 1'


d2l	equ	14
;______________________
;   ТЕСТ.06
;	 Тест контроллера прерываний
;	 8259
;_______________________
tst6:
;   Проверка регистра масок прерываний (IMR)

 	cli	 	 	;сброс признака разрешения прерываний
 	mov	al,0	 	;уст IMR в 0
 	out	inta01,al
 	in	al,inta01	;считывание IMR
 	or	al,al	 	;IMR=0 ?
 	jnz	d6	 	;IMR не 0,в программу ошибок
 	mov	al,0ffh 	;недоступность прерываний
 	out	inta01,al	;запись в IMR
 	in	al,inta01	;считывание IMR
 	add	al,1	 	;все биты IMR установлены ?
 	jnz	d6	 	;НЕТ - в программу ошибок

 	sub	ax,ax	 	;уст регистра ES
 	mov	es,ax


;   Контроль ожидания прерывания

 	cld	 	 	; уст признак направления
 	mov	cx,20h		;rc все прерывания 00..1F, относящиеся к BIOS
 	xor	di,di
d3:
 	mov	ax,offset d11	; установить адрес процедуры прерываний
 	stosw
 	mov	ax,cod	; получить адрес сегмента процедуры
 	stosw
 	loop	d3

;   Установка указателя вектора прерывания NMI
 	mov	es:nmi_ptr,offset nmi_int
;-----уст вектора прерываний 5
 	mov	es:int5_ptr,offset print_screen   ; печать экрана

;   Прерывания замаскированы

 	xor	ah,ah	 	;очистить регистр AH
 	sti	 	 	; установка признака разрешения прерывания
 	sub	cx,cx	 	; ожидание 1 сек любого прерывания,
d4:	loop	d4	 	; которое может произойти
d5:	loop	d5
 	or	ah,ah	 	; прерывание возникло ?
 	jz	d7	 	; нет - к следующему тесту
d6:	mov	dx,101h 	; уст длительности звукового сигнала
 	call	err_beep	; идти в программу звукового сигнала
 	cli
 	hlt	 	 	; останов системы
;__________________
;   ТЕСТ.07
;	 Проверка таймера 8253
;___________________
d7:
 	mov	ah,0	 	; сброс признака прерывания таймера
 	xor	ch,ch	 	; очистить регистр CH
 	mov	al,0feh   ; маскировать все прерывания, кроме LVL 0
 	out	inta01,al	; запись IMR
 	mov	al,00010000b	; выбрать TIM 0, LSD, режим 0, BINARY
 	out	tim_ctl,al  ;записать регистр режима управления таймера
 	mov	cl,16h	 	; уст счетчик программного цикла
 	mov	al,cl	 	; установить счетчик таймера 0
 	out	timero,al	; записать счетчик таймера 0
d8:	test	ah,0ffh 	; прерывание таймера 0 произошло ?
 	jnz	d9	 	; да - таймер считал медленно
 	loop	d8	 	; ожидание прерывания определенное время
 	jmp	short d6   ;прерывание таймера 0 не произошло - ошибка
d9:	mov	cl,18	 	; уст счетчик программного цикла
 	mov	al,0ffh 	; записать счетчик таймера 0
 	out	timero,al
 	mov	ah,0	 	; сброс признака,полученного прерывания
 	mov	al,0feh 	; недоступность прерываний таймера 0
 	out	inta01,al
d10:	test	ah,0ffh 	; прерывание таймера 0 произошло ?
 	jnz	d6	 	; да - таймер считает быстро
 	loop	d10	 	; ожидание прерывания определенное время
 	jmp	short tst8	 	; переход к следующему тесту
	nop
;____________________
;   Программа обслуживания
;   временного прерывания
;____________________
d11	proc	near
 	mov	ah,1
 	push	ax	 	; хранить регистр AX
 	mov	al,0ffh 	; размаскировать все прерывания
 	out	inta01,al
 	mov	al,eoi
 	out	inta00,al
 	pop	ax	 	; восстановить регистр AX
 	iret
d11	endp

nmi_int proc	near
 	push	ax	 	; хранить регистр AX
 	in	al,port_c
 	test	al,40h	 	; ошибка паритета при вводе/выводе ?
 	jz	d12	 	; да - признак сбрасывается в 0
 	mov	si,offset d1	; адрес поля сообщения об ошибке
 	mov	cx,d1l	 	; длина поля сообщения об ошибке
 	jmp	short d13	; отобразить ошибку на дисплее
d12:
 	test	al,80h
 	jz	d14
 	mov	si,offset d2	; адрес поля сообщения об ошибке
 	mov	cx,d2l	 	; длина поля сообщения об ошибке
d13:
 	mov	ax,0	 	; инициировать и установить режим ЭЛИ
 	int	10h	 	; вызвать процедуру VIDEO_IO
 	call	p_msg	 	; распечатать ошибку
 	cli
 	hlt	 	 	; останов системы
d14:
 	pop	ax	 	; восстановить AX
 	iret
nmi_int endp
;____________________
;   Начальный тест надежности
;____________________
 	assume	cs:code,ds:data

e1	db	' 201'
e1l	equ	04h

;   Выполнение программы БСУВВ,
;   генерирующей вектора прерываний

tst8:
 	cld	 	 	; установить признак направления вперед
 	mov	di,offset video_int   ; уст адреса области прерываний
 	push	cs
 	pop	ds	 	; уст адреса таблицы векторов
 	mov	si,offset vector_table+10h  ; смещение VECTOR_TABLE+(2*8) (начало прогр прерыв)
 	mov	cx,10h
e1a: 	movsw	 	; передать таблицу векторов в память
	inc	di
	inc	di
	loop	e1a

;   Установка таймера 0 в режим 3

 	mov	al,0ffh
 	out	inta01,al
 	mov	al,36h	 	; выбор счетчика 0,считывания-за-
; писи младшего,затем старшего байта счетчика,уст режима 3
 	out	timer+3,al	; запись режима таймера
 	mov	al,0c7h
 	out	timer,al	; записать младшую часть счетчика
 	mov	al,0dbh
 	out	timer,al	; записать старшую часть счетчика


 	assume	ds:data
 	mov	ax,dat	 	; DS - сегмент данных
 	mov	ds,ax
e3:
 	cmp	reset_flag,1234h
 	jz	e3a
 	call	bct	;загрузка знакогенератора Ч/Б ЭЛИ
;_____________________
;   ТЕСТ.08
;	 Инициализация и запуск
;	 контроллера ЭЛИ
;______________________
e3a:	in	al,port_a	; считывание состояния переключателей
 	mov	ah,0
 	mov	equip_flag,ax	; запомнить считанное состояние пере-
 	 	 	 	; ключателей
 	and	al,30h	 	; выделить переключатели ЭЛИ
 	jnz	e7	 	; переключатели ЭЛИ установлены в 0 ?
 	jmp	e19	 	; пропустить тест ЭЛИ
e7:
 	xchg	ah,al
 	cmp	ah,30h	 	; адаптер ч/б ?
 	je	e8	 	; да - установить режим для ч/б адаптера
 	inc	al	 ; уст цветной режим для цветного адаптера
 	cmp	ah,20h	 	; режим 80х25 установлен ?
 	jne	e8	 	; нет - уст режим для 40х25
 	mov	al,3	 	; установить режим 80х25
e8:
 	push	ax	 	; хранить режим ЭЛИ в стеке
 	sub	ah,ah	 	;
 	int	10h
 	pop	ax
 	push	ax
 	mov	bx,0b000h
 	mov	dx,3b8h 	; регистр режима для ч/б
 	mov	cx,4096 	; счетчик байт для ч/б адаптера
 	mov	al,1	 	; уст режим для ч/б адаптера
 	cmp	ah,30h	 	; ч/б адаптер ЭЛИ подключен ?
 	je	e9	 	; переход к проверке буфера ЭЛИ
 	mov	bx,0b800h
 	mov	dx,3d8h 	; регистр режима для цветного адаптера
 	mov	cx,4000h
 	dec	al	 	; уст режим в 0 для цветного адаптера
;
;	Проверка буфера ЭЛИ
;
e9:
 	out	dx,al	 	; блокировка ЭЛИ для цветного адаптера
 	mov	es,bx
 	mov	ax,dat	 	; DS - сегмент данных
 	mov	ds,ax
 	cmp	reset_flag,1234h
 	je	e10
 	mov	ds,bx	 	;
 	call	stgtst_cnt	; переход к проверке памяти
 	je	e10
 	mov	dx,102h
 	call	err_beep

;___________________________
;
;   ТЕСТ.09
;	 Осуществляет проверку формирования строк в буфере ЭЛИ
;_________________________
e10:
 	pop	ax   ; получить считанные переключатели ЭЛИ в AH
 	push	ax	 	; сохранить их
 	mov	ah,0
 	int	10h
 	mov	ax,7020h	; запись пробелов в режиме реверса
 	sub	di,di	 	; установка начала области
 	mov	cx,40	 	;
 	cld	    ; установить признак направления для уменьшения
 	rep	stosw	 	; записать в память
;______________________
;    ТЕСТ.10
;	  Осуществляет проверку линий интерфейса ЭЛИ
;______________________
 	pop	ax	 	; получить считанные переключатели
 	push	ax	 	; сохранить их
 	cmp	ah,30h	 	; ч/б адаптер подключен ?
 	mov	dx,03bah	; уст адрес порта состояния ч/б дисплея
 	je	e11	 	; да - переход к следующей строке
 	mov	dx,03dah	; цветной адаптер подключен
;
;	Тест строчной развертки
;
e11:
 	mov	ah,8
e12:
 	sub	cx,cx
e13:	in	al,dx	    ;считывание порта состояния контроллера СМ607
 	and	al,ah	 	; проверка строки
 	jnz	e14
 	loop	e13
 	jmp	short e17	; переход к сообщению об ошибке
e14:	sub	cx,cx
e15:	in	al,dx	  ;считывание порта состояния контроллера СМ607
 	and	al,ah
 	jz	e16
 	loop	e15
 	jmp	short e17
;
;	Следующий строчный импульс
;
e16:
 	mov	cl,3	 	; получить следующий бит для контроля
 	shr	ah,cl
 	jnz	e12
 	jmp	short e18	; отобразить курсор на экране
;
;	Сообщение об ошибке конттроллера СМ607
;
e17:
 	mov	dx,103h
 	call	err_beep
;
;	Отображение курсора на экране
;
e18:
 	pop	ax	 	; получить считанные переключатели в AH
 	mov	ah,0	 	; установить режим
 	int	10h
;______________________
;   ТЕСТ.11
;	 Дополнительный тест памяти
;______________________
 	assume	ds:data
e19:
 	mov	ax,dat
 	mov	ds,ax
	 	cmp	reset_flag,1234h
		je	skip_size_det
		in	al, port_c
		and	al, 0Fh
		inc	al
		mov	ah, 80h
		mul	ah
		mov	ds:memory_size,	ax
skip_size_det:
		mov	ax,ds:memory_size		;restore if reboot and no damages if power-on
		mov	ds:io_ram_size,	ax



;   Проверка любой действительной памяти
;   на считывание и запись

 	jmp	e190

;   Печать адреса и эталона, если
;   произошла ошибка данных


osh:
 	mov	ch,al	 	;
 	mov	al,dh	 	; получить измененный адрес
 	mov	cl,4
 	shr	al,cl	 	;
 	call	xlat_print_cod	; преобразование и печать кода
 	mov	al,dh
 	and	al,0fh
 	call	xlat_print_cod	; преобразование и печать кода
 	mov	al,ch	 	; получить следующий шаблон
 	mov	cl,4
 	shr	al,cl
 	call	xlat_print_cod	; преобразование и печать кода
 	mov	al,ch	 	;
 	and	al,0fh	 	;
 	call	xlat_print_cod	; преобразование и печать кода
 	mov	si,offset e1	; установить адрес поля сообщения
 	 	 	 	; об ошибке
 	mov	cx,e1l	 	; получить счетчик поля сообщения об ошибке
 	call	p_msg	 	; печать ошибки
e22:
 	jmp	short tst12	 	; переход к следующему тесту
	nop
;_____________________
;
;   Процедура вывода на экран сообщения об ошибке в коде ASCII
;
;_______________________

xlat_print_cod proc near
 	push	ds	 	; сохранить DS
 	push	cs
 	pop	ds
 	mov	bx,offset f4e	; адрес таблицы кодов ASCII
 	xlatb
 	mov	ah,14
 	mov	bh,0
 	int	10h
 	pop	ds
 	ret
xlat_print_cod endp
;______________________
;   Сброс системы - фаза 4
;______________________
;
;   Коды сообщений об ошибках
;_______________________

 	assume	cs:code,ds:data
f1	db	' 301'
f1l	equ	4h	 	; сообщение клавиатуры
f2	db	'131'
f2l	equ	3h	 	; сообщение кассеты
f3	db	'601'
f3l	equ	3h	 	; сообщение НГМД

f4	label	word
 	dw	378h
f4e	label	word
ascii_tbl db	'0123456789abcdef'


;______________________
;   ТЕСТ.12
;   Тест клавиатуры
;______________________
tst12:

 	mov	ax,dat
 	mov	ds,ax
 	call	kbd_reset	; Сброс клавиатуры
 	mov	al,4dh	 	; доступность клавиатуры
 	out	port_b,al
	jcxz	f6	 	; нет - печать ошибки
 	cmp	bl,0aah 	; код сканирования 'AA' ?
 	jne	f6	 	; нет - печать ошибки

;   Поиск "залипших" клавиш

 	mov	al,0cch       ; сброс клавиатуры, уст синхронизации
 	out	port_b,al
 	mov	al,4ch	      ; доступность клавиатуры
 	out	port_b,al
 	sub	cx,cx
;
;	Ожидание прерывания клавиатуры
;
f5:
 	loop	f5	 	; задержка
 	in	al,kbd_in	; получение кода сканирования
 	cmp	al,0	 	; код сканирования равен 0 ?
 	je	f7	 	; да - продолжение тестирования
 	mov	ch,al	 	; сохранить код сканирования
 	mov	cl,4
 	shr	al,cl
 	call	xlat_print_cod	; преобразование и печать
 	mov	al,ch	 	; восстановить код сканирования
 	and	al,0fh	 	; выделить младший байт
 	call	xlat_print_cod	; преобразование и печать
f6:	mov	si,offset f1	; получить адрес поля сообщения об
 	 	 	 	; ошибке
 	mov	cx,f1l	 	 ; длина поля сообщения об ошибке
 	call	p_msg	 	 ; вывод сообщения об ошибке на экран

;   Установка таблицы векторов прерываний

f7:
 	sub	ax,ax
 	mov	es,ax
 	mov	cx,8	 	; получить счетчик векторов
 	push	cs
 	pop	ds
 	mov	si,offset vector_table	 ; адрес таблицы векторов
 	mov	di,offset int_ptr
 	cld
f7a:	movsw
	inc	di
	inc	di
	loop	f7a
	jmp short tst14
	
	org	0e47dh		;rc для устранения съезжания при переделке загрузчика таблицы векторв прерываний

;______________________
;   ТЕСТ.14
;   Осуществляет проверку НГМД
;______________________
tst14:	mov	ax,dat	 	; уст. регистр DS
 	mov	ds,ax
 	mov	al,0fch  ; доступность прерываний таймера и клавиатуры
 	out	inta01,al
 	mov	al,byte ptr equip_flag	; получить состояние переклю-
 	 	 	 	 	; чателей
 	test	al,01h	 	; первоначальная загрузка с НГМД ?
 	jnz	f10	 	; да - проверка управления НГМД
 	jmp	f23
f10:
 	mov	al,0bch 	; доступность прерываний с НГМД,
 	out	inta01,al	; клавиатуры и таймера
 	mov	ah,0	 	; сброс контроллера НГМД
 	int	13h	 	; переход к сбросу НГМД
 	test	ah,0ffh 	; состояние верно ?
 	jnz	f13	 	; нет - сбой устройства

;   Включить мотор устройства 0

 	mov	dx,03f2h	; получить адрес адаптера НГМД
 	mov	al,1ch	 	; включить мотор
 	out	dx,al
 	sub	cx,cx

;    Ожидание включения мотора НГМД

f11:
 	loop	f11
f12:	 	 	 	; ожидание мотора 1
 	loop	f12
 	xor	dx,dx
 	mov	ch,1	 	; выбор первой дорожки
 	mov seek_status,dl
 	call	seek	 	; переход к рекалибровке НГМД
 	jc	f13	 	; перейти в программу ошибок
 	mov	ch,34	 	; выбор 34 дорожки
 	call	seek
 	jnc	f14	 	; выключить мотор

;    Ошибки НГМД

f13:
 	mov	si,offset f3	; получить адрес поля сообщения об
 	 	 	 	; ошибке
 	mov	cx,f3l	 	; установить счетчик
 	call	p_msg	 	; идти в программу ошибок

;   Выключить мотор устройства 0

f14:
 	mov	al,0ch	 	; выключить мотор устройства 0
 	mov	dx,03f2h	; уст адрес порта управления НГМД
 	out	dx,al

;   Установка печати и базового адреса
;   адаптера стыка С2, если устройства подключены

f15:
 	cmp	bp,0000h
 	jz	dal
 	mov	dx,3
 	call	err_beep
 	mov	si,offset f39
		mov	cx, 23
 	call	p_msg
err_wait:
 	mov	ah,0
 	int	16h
 	cmp	ah,3bh
 	jnz	err_wait
dal:	sub	ah,ah
 	mov	al,crt_mode
 	int	10h
		mov	ds:buffer_head,	offset kb_buffer ; ERROR - Must be approx. 6 lines upper, before int 16h
		mov	ds:buffer_tail,	offset kb_buffer ; ERROR - Must be approx. 6 lines upper, before int 16h
 	mov	bp,offset f4	; таблица PRT_SRC
 	mov	si,0
f16:
 	mov	dx,cs:[bp]	; получить базовый адрес печати
 	mov	al,0aah 	; записать данные в порт А
 	out	dx,al
 	sub	al,al
 	in	al,dx	 	; считывание порта А
 	cmp	al,0aah 	; шаблон данных тот же
 	jne	f17	    ; нет - проверка следующего устройства печати
 	mov	word ptr printer_base[si],dx  ;да-уст базовый адрес
 	inc	si	 	; вычисление следующего слова
 	inc	si
f17:
 	inc	bp	 	; указать следующий базовый адрес
 	inc	bp
 	cmp	bp,offset f4e	; все возможные адреса проверены ?
 	jne	f16	 	; нет, к проверке следующего адреса печати
 	mov	bx,0
 	mov	dx,3ffh 	; проверка подключения адаптера 1 стыка С2
 	mov	al,8ah
 	out	dx,al
 	mov	dx,2ffh
 	out	dx,al
 	mov	dx,3fch
 	mov	al,0aah
 	out	dx,al
 	inc	dx
		xor	ax, ax
		out	dx, al
 	in	al,dx
 	cmp	al,0aah
 	jnz	f18
 	mov  word ptr rs232_base[bx],3f8h  ; уст адрес адаптера 1
 	inc	bx
 	inc	bx
f18:	mov	dx,2fch 	; проверка подключения адаптера 2 стыка С2
 	mov	al,0aah
 	out	dx,al
 	inc	dx
		xor	ax, ax
		out	dx, al
 	in	al,dx
 	cmp	al,0aah
 	jnz	f19
 	mov  word ptr rs232_base[bx],2f8h   ; уст адрес адаптера 2
 	inc	bx
 	inc	bx



;_____Установка EQUIP_FLAG для инди-
;     кации номера печати

f19:
		jmp	f19a

f19b:
 	ror	al,cl
 	or	al,bl
 	mov	byte ptr equip_flag+1,al
 	mov	dx,201h
 	in	al,dx
 	test	al,0fh
 	jnz	f20	 	 	   ; проверка адаптера игр
 	or	byte ptr equip_flag+1,16
f20:
		jmp	f20a
		nop

f20b:
		mov	dx, 1
 	call	err_beep	; переход к подпрограмме звукового сигнала
f21:
		jmp	boot_strap

f23:
 	jmp	f15

;    Установка длительности звукового сигнала

 	assume	cs:code,ds:data
err_beep proc	near
 	pushf	 	 	; сохранить признаки
 	cli	 	 	; сброс признака разрешения прерывания
 	push	ds	 	; сохранить DS
 	mov	ax,dat	 	; DS - сегмент данных
 	mov	ds,ax
 	or	dh,dh
 	jz	g3
g1:	 	 	 	 ; длинный звуковой сигнал
 	mov	bl,6	 	 ; счетчик для звуковых сигналов
 	call	beep	 	 ; выполнить звуковой сигнал
g2:	loop	g2	 	 ; задержка между звуковыми сигналами
 	dec	dh
 	jnz	g1
g3:	 	 	 	 ; короткий звуковой сигнал
 	mov	bl,1   ; счетчик для короткого звукового сигнала
 	call	beep	 	; выполнить звуковой сигнал
g4:	loop	g4	 	; задержка между звуковыми сигналами
 	dec	dl	 	;
 	jnz	g3	 	; выполнить
g5:	loop	g5	 	; длинная задержка перед возвратом
g6:	loop	g6
 	pop	ds	 	; восстановление DS
 	popf	 	   ; восстановление первоначальных признаков
 	ret	 	 	; возврат к программе
err_beep	endp

;   Подпрограмма звукового сигнала

beep	proc	near
 	mov	al,10110110b	; таймер 2,младший и старший счет-
 	 	 	 	; чики, двоичный счет
 	out	timer+3,al	; записать в регистр режима
 	mov	ax,45eh 	; делитель
 	out	timer+2,al	; записать младший счетчик
 	mov	al,ah
 	out	timer+2,al	; записать старший счетчик
 	in	al,port_b	; получить текущее состояние порта
 	mov	ah,al	 	; сохранить это состояние
 	or	al,03	 	; включить звук
 	out	port_b,al
 	sub	cx,cx	 	; установить счетчик ожидания
g7:	loop	g7	 	; задержка перед выключением
 	dec	bl	 	; задержка счетчика закончена ?
 	jnz	g7	; нет - продолжение подачи звукового сигнала
 	mov	al,ah	 	; восстановить значение порта
 	out	port_b,al
 	ret	 	 	; возврат к программе
beep	endp
;_____________________
;   Эта процедура вызывает программный
;   сброс клавиатуры
;_____________________
kbd_reset proc	near
 	mov	al,0ch	   ; установить низкий уровень синхронизации
 	out	port_b,al	; записать порт B
 	mov	cx,30000	; время длительности низкого уровня
g8:	loop	g8
 	mov	al,0cch 	; уст CLK
 	out	port_b,al
sp_test:
 	mov	al,4ch	 	; уст высокий уровень синхронизации
 	out	port_b,al
 	mov	al,0fdh 	; разрешить прерывания клавиатуры
 	out	inta01,al	; записать регистр масок
 	sti	 	 	; уст признака разрешения прерывания
 	mov	ah,0
 	sub	cx,cx	 	; уст счетчика ожидания прерываний
g9:	test	ah,0ffh 	; прерывание клавиатуры возникло ?
 	jnz	g10   ;  да - считывание возвращенного кода сканирования
 	loop	g9	 	; нет - цикл ожидания
g10:	in	al,port_a   ; считать код сканирования клавиатуры
 	mov	bl,al	 	; сохранить этот код
 	mov	al,0cch 	; очистка клавиатуры
 	out	port_b,al
 	ret	 	 	; возврат к программе
kbd_reset	endp
;_____________________
;   Эта программа выводит на экран дисплея
;   сообщения об ошибках
;
;     Необходимые условия:
;   SI = адрес поля сообщения об ошибке
;   CX = длина поля сообщения об ошибке
;   Максимальный размер передаваемой
;   информации - 36 знаков
;
;______________________
p_msg	proc	near
 	mov	ax,dat
 	mov	ds,ax
 	mov	bp,si
g12:
 	mov	al,cs:[si]	; поместить знак в AL
 	inc	si	 	; указать следующий знак
 	mov	bh,0	 	; установить страницу
 	mov	ah,14	 	; уст функцию записи знака
 	int	10h	 	; и записать знак
 	loop	g12	; продолжать до записи всего сообщения
 	mov	ax,0e0dh   ; переместить курсор в начало строки
 	int	10h
 	mov	ax,0e0ah  ; переместить курсор на следующую строку
 	int	10h
 	ret
p_msg	endp


e190:
		push	ds
		mov	ax, 16
		cmp	ds:reset_flag, 1234h
		jnz	e20a
		jmp	e22

e20a:
		mov	ax, 16
		jmp	short prt_siz

e20b:
		mov	bx, ds:memory_size
		sub	bx, 16
		mov	cl, 4
		shr	bx, cl
		mov	cx, bx
		mov	bx, 400h

e20c:
		mov	ds, bx
		
		mov	es, bx
		add	bx, 400h
		push	dx
		push	cx
		push	bx
		push	ax
		call	stgtst
		jnz	e21a
		pop	ax
		add	ax, 16

prt_siz:
		push	ax
		mov	bx, 10
		mov	cx, 3

decimal_loop:
		xor	dx, dx
		div	bx
		or	dl, 30h
		push	dx
		loop	decimal_loop
		mov	cx, 3

prt_dec_loop:
		pop	ax
		call	prt_hex
		loop	prt_dec_loop
		mov	cx, 7
		mov	si, offset e300	; " Kb OK\r"

kb_ok:
		mov	al, cs:[si]
		inc	si
		call	prt_hex
		loop	kb_ok
		pop	ax
		cmp	ax, 16
		jz	e20b
		pop	bx
		pop	cx
		pop	dx
		loop	e20c
		mov	al, 10
		call	prt_hex
		pop	ds
		
		jmp	e22

e21a:
		pop	bx
		add	sp, 6
		mov	dx, es
		pop	ds
		push	ds
		mov	ds:memory_size,	bx
		jmp	osh

prt_hex		proc near
		mov	ah, 14
		mov	bh, 0
		int	10h
		retn
prt_hex		endp

e300		db ' Kb OK',0Dh
f39		db 'ERROR (RESUME="F1" KEY)'

;   Таблица кодов русских больших букв (заглавных)

rust2	label	byte
 	db	1bh,'!@#$',37,05eh,'&*()_+'


 	db	08h,0
 	db	0b9h,0c6h,0c3h,0bah,0b5h,0bdh,0b3h,0c8h

 	db	0c9h,0b7h,0b6h,0cdh,0dh,-1,0c4h,0cbh

 	db	0b2h,0b0h,0bfh,0c0h,0beh,0bbh,0b4h,27h

 	db	'"',0b1h,0ceh,7ch,0cfh,0c7h,0c1h,0bch,0b8h

 	db	0c2h,0cch,'<>?',0c5h,000,-1,' ',0cah




;___int 19_____________
;   Программа загрузки системы с НГМД
;
; Программа считывает содержимое дорожки 0 сектора 1 в
; ячейку boot_locn (адрес 7C00,сегмент 0)
;   Если НГМД отсутствует или произошла аппаратная ошибка,
; устанавливается прерывание типа INT 18H, которое вызывает
; выполнение программ тестирования и инициализации
; системы
;
;_________________________
 	assume	cs:code,ds:data
boot_strap proc near

 	sti	 	      ; установить признак разрешения прерывания
 	mov	ax,dat	      ; установить адресацию
 	mov	ds,ax
 	mov	ax,equip_flag ; получить состояние переключателей
 	test	al,1	      ; опрос первоначальной загрузки
 	jz	h3

;   Система загружается с НГМД
;   CX содержит счетчик повторений

 	mov	cx,4	 	; установить счетчик повторений
h1:	 	 	 	; первоначальная загрузка
 	push	cx	 	; сохранить счетчик повторений
 	mov	ah,0	 	; сброс НГМД
 	int	13h
 	jc	h2	 	; если ошибка,повторить
 	mov	ah,2	 	; считать сектор 1
 	mov	bx,0	 	;
 	mov	es,bx
 	mov	bx,offset boot_locn
 	mov	dx,0	 	;
 	mov	cx,1	 	; сектор 1 , дорожка 0
 	mov	al,1	 	; считывание первого сектора
 	int	13h
h2:	pop	cx	 	; восстановить счетчик повторений
 	jnc	h4	 	; уст CF при безуспешном считывании
 	loop	h1	 	; цикл повторения

;   Загрузка с НГМД недоступна

h3:	 	 	 	; кассета
 	jmp	err01	; отсутствует дискет загрузки

;   Загрузка завершилась успешно

h4:					; 
		jmp far ptr boot_locn 	; db 0EAh, 00h, 7Ch, 00h, 00h	; (0000:7C00)	; ###Gleb###

boot_strap	endp
;--------------------
;   Эта программа посылает байт в контроллер адаптера НГМД
; после проверки корректности управления и готовности
; контроллера.
;   Программа ожидает байт состояния определенное время
; и проверяет готовность НГМД к работе.
;
;   ВВОД   (AH) - выводимый байт
;
;   ВЫВОД  CY=0 - успешно,
;	   CY=1 - не успешно.Состояние
;	   НГМД анализируется.
;-----------------------
nec_output proc near
 	push	dx	 	; сохранить регистры
 	push	cx
 	mov	dx,03f4h	; состояние порта
 	xor	cx,cx	 	; счетчик времени вывода
j23:
 	in	al,dx	 	; получить состояние
 	test	al,040h 	; проверка управляющих бит
 	jz	j25	 	; биты управления нормальные
 	loop	j23
j24:
 	or	diskette_status,time_out
 	pop	cx
 	pop	dx	; установить код ошибки и восстановить регистры
 	pop	ax	 	; адрес возврата
 	stc	 	 	;
 	ret

j25:
 	xor	cx,cx	 	; обнуление счетчика
j26:
 	in	al,dx	 	; получить состояние
 	test	al,080h 	; проверка готовности
 	jnz	j27	 	; да - идти на выход
 	loop	j26	 	; повторить
 	jmp	short j24	; ошибка состояния
j27:	 	 	 	; выход
 	mov	al,ah	 	; получить байт
 	mov	dx,03f5h	; переслать байт данных в порт
 	out	dx,al
 	pop	cx	 	; восстановить регистры
 	pop	dx
 	ret	 	 	;
nec_output	endp

;___int 16_________________
;
;   Программа поддержки клавиатуры
;
;   Эта программа считывает в регистр
; AX код сканирования клавиши и код
; ASCII из буфера клавиатуры.
;
;   Программа выполняет три функции, код
; которых задается в регистре AH:
;
;    AH=0 - считать следующий символ
;	     из буфера.При выходе код
;	     сканирования в AH,код
;	     ASCII в AL.
;   AH=1 - установить ZF, если код
;	     ASCII прочитан:
;
;	     ZF=0 - буфер заполнен,
;	     ZF=1 - буфер пустой.
;   При выходе в AX помещен адрес вершины буфера клавиатуры.
;   AH=2 - возврат текущего состояния в регистр AL
;	      из постоянно распределенной области памяти с
;	   адресом 00417H.
;
;   При выполнении программ клавиатуры используются флажки,
; которые устанавливаются в постоянно распределенной области
; памяти по адресам 00417H и 00418H и имеют значение:
;   00417H
;	  0 - правое переключение регистра;
;	  1 - левое переключение регистра;
;	     2 - УПР;
;	  3 - ДОП;
;	  4 - ФСД;
;	  5 - ЦИФ;
;	  6 - ФПБ;
;	  7 - ВСТ;
;   00418H
;	  0 - состояние клавиши ЛАТ между нажатием и отжатием;
;	  1 - ЛАТ;
;	  2 - Р/Л;
;	  3 - пауза;
;	  4 - ФСД;
;	  5 - ЦИФ;
;	  6 - ФПБ;
;	  7 - ВСТ.
;
;   Флажки, соответствующие разрядам 4-7 постоянно распределенной
; области памяти с адресом 00417H, устанавливаются по нажатию
; клавиш ВСТ, ФПБ, ЦИФ, ФСД и сохраняют свои значения до сле-
; дующего нажатия соответствующей клавиши.
; Одноименные флажки, соответствующие разрядам 4-7 постоянно
; распределенной области памяти с адресом 00418H, и флажки
; ДОП, УПР, левое переключение регистра, правое переключение
; регистра, Р/Л устанавливаются по нажатию клавиш и сбрасываются
; по отжатию.
;
;------------------------------
 	assume	cs:code,ds:data


k4	proc	near
 	add	bx,2
 	cmp  bx, offset kb_buffer_end	 	 ; конец буфера ?
 	jne	k5	 	 	 ; нет - продолжить
 	mov	bx, offset kb_buffer 	 ; да - уст начала буфера
k5:
 	ret
k4	endp

error_beep proc near
 	push	ax
 	push	bx
 	push	cx
 	mov	bx,0c0h
 	in	al,kb_ctl
 	push	ax
k65:
 	and	al,0fch
 	out	kb_ctl,al
 	mov	cx,48h
k66:	loop	k66
 	or	al,2
 	out	kb_ctl,al
 	mov	cx,48h
k67:	loop	k67
 	dec	bx
 	jnz	k65
 	pop	ax
 	out	kb_ctl,al
 	pop	cx
 	pop	bx
 	pop	ax
 	ret
error_beep	endp

;---

k54:
 	cmp	al,59
 	jb	k55
 	mov	al,0
		jmp	short k57
		nop

k55:	mov	bx,offset k10
 	test	kb_flag_1,lat
 	jz	k99

;---

k56:
 	dec	al
 	xlat	cs:k11

;---

k57:
 	cmp	al,-1
 	je	k59
 	cmp	ah,-1
 	je	k59
;---

k58:
 	test	kb_flag,caps_state
 	jz	k61

;---
 	test	kb_flag_1,lat
 	jnz	k88
 	jmp	k89
k88:
 	test	kb_flag,left_shift+right_shift
 	jz	k60

;----------

 	cmp	al,'A'
 	jb	k61
 	cmp	al,'Z'
 	ja	k61
 	add	al,'a'-'A'
		jmp	short k61
		nop

k59:
 	jmp	k26


k60:
 	cmp	al,'a'
 	jb	k61
 	cmp	al,'z'
 	ja	k61
 	sub	al,'a'-'A'

k61:
 	mov	bx,buffer_tail
 	mov	si,bx
 	call   k4
 	cmp	bx,buffer_head
 	je	k62
 	mov	word ptr [si],ax
 	mov	buffer_tail,bx
 	jmp	k26
k99:	mov	bx,offset rust
 	jmp k56

;---

k62:
 	call	error_beep
 	jmp	k26

;---

k63:
 	sub	al,59
k64:
 	xlat	cs:k9
 	mov	ah,al
 	mov	al,0
		jmp	short k57
		db 34 dup(0)

;---

keyboard_io proc	far
 	sti	 	 	;
 	push	ds
 	push	bx
 	mov	bx,dat
 	mov	ds,bx	 	; установить сегмент данных
 	or	ah,ah	 	; AH=0
 	jz	k1	     ; переход к считыванию следующего символа
 	dec	ah	 	; AH=1
 	jz	k2	     ; переход к считыванию кода ASCII
 	dec	ah	 	     ; AH=2
 	jz	k3	     ; переход к получению байта состояния
 	pop	bx	 	     ; восстановить регистр
 	pop	ds
 	iret

;   Считывание кода сканирования и кода ASCII из буфера клавиатуры
;
k1:
 	sti	 	; уст признака разрешения прерывания
 	nop	 	 	; задержка
 	cli	 	; сброс признака разрешения прерывания
 	mov	bx,buffer_head	; уст вершину буфера по чтению
 	cmp	bx,buffer_tail	; сравнить с вершиной буфера по записи
 	jz	k1
 	mov	ax,word ptr [bx] ; получить код сканирования и код ASCII
 	call	k4
 	mov	buffer_head,bx	; запомнить вершину буфера по чтению
 	pop	bx	 	; восстановить регистр
 	pop	ds	 	; восстановить сегмент
 	iret	 	 	; возврат к программе

;   Считать код ASCII

k2:
 	cli	 	; Сброс признака разрешения прерывания
 	mov	bx,buffer_head	; получить указатель вершины буфера
 	 	 	 	; по чтению
 	cmp	bx,buffer_tail	; сравнить с вершиной буфера по записи
 	mov	ax,word ptr [bx]
 	sti	 	 	; уст признак разрешения прерывания
 	pop	bx	 	; восстановить регистр
 	pop	ds	 	; восстановить сегмент
 	ret	2

;   Получение младшего байта состояния (флажков)

k3:
 	mov	al,kb_flag	; получить младший байт состояния     на
 	pop	bx	 	; восстановить регистр
 	pop	ds	 	; восстановить сегмент
 	iret	 	 	; возврат к программе
keyboard_io	endp

;   Таблица кодов сканирования управляющих клавиш

k6	label	byte
 	db	ins_key
 	db	caps_key,num_key,scroll_key,alt_key,ctl_key
 	db	left_key,right_key
 	db	inv_key_l
 	db	inv_key_r,lat_key,rus_key
k6l	equ	0ch

;   Таблица масок нажатых управляющих клавиш

k7	label	byte
 	db	ins_shift
 	db	caps_shift,num_shift,scroll_shift,alt_shift,ctl_shift
 	db	left_shift,right_shift


;   Таблица кодов сканирования при нажатой клавише УПР для
; кодов сканирования клавиш меньше 59

k8	db	27,-1,0,-1,-1,-1,30,-1

 	db	-1,-1,-1,31,-1,127,-1,17

 	db	23,5,18,20,25,21,9,15

 	db	16,27,29,10,-1,1,19

 	db	4,6,7,8,10,11,12,-1,-1

 	db	-1,-1,28,26,24,3,22,2

 	db	14,13,-1,-1,-1,-1,-1,-1

 	db	' ',-1

;   Таблица кодов сканирования при нажатой клавише УПР для
; кодов сканирования клавиш больше 59
k9	label	byte
 	db	94,95,96,97,98,99,100,101

 	db	102,103,-1,-1,119,-1,132,-1

 	db	115,-1,116,-1,117,-1,118,-1

 	db	-1

;   Таблица кодов ASCII нижнего регистра клавиатуры

k10	label	byte
 	db	27,'1234567890-='


 	db	08h,09h
 	db	'qwertyuiop[]',0dh,-1,'asdfghjkl;:',60h,7eh




 	db	05ch,'zxcvbnm',',./{'

 	db	'*',-1,' }'

;   Таблица кодов ASCII верхнего регистра клавиатуры

k11	label	byte
 	db	27,'!@#$',37,05eh,'&*()_+'


 	db	08h,0
 	db	'QWERTYUIOP',-1,-1,0dh,-1


 	db	'ASDFGHJKL'

 	db	027h,'"',-1,-1,7ch
 	db	'ZXCVBNM'

 	db	'<>?',-1,0,-1,' ',-1


;   Таблица кодов сканирования клавиш Ф11 - Ф20 (на верхнем
; регистре Ф1 - Ф10)

k12	label	byte
 	db	84,85,86,87,88,89,90

 	db	91,92,93

;   Таблица кодов сканирования одновременно нажатых клавиш
; ДОП и Ф1 - Ф10

k13	label byte
 	db	104,105,106,107,108
 	db	109,110,111,112,113

;   Таблица кодов правого пятнадцатиклавишного поля на верхнем
; регистре

k14	label	byte
 	db	'789-456+1230.'



;   Таблица кодов правого пятнадцатиклавишного поля на нижнем
; регистре

k15	label byte
 	db	71,72,73,-1,75,-1,77

 	db	-1,79,80,81,82,83

		db 9 dup(0)

;----INT 9--------------------------
;
;    Программа обработки прерывания клавиатуры
;
; Программа считывает код сканирования клавиши в регистр AL.
; Единичное состояние разряда 7 в коде сканирования означает,
; что клавиша отжата.
;   В результате выполнения программы в регистре AX формируется
; слово, старший байт которого (AH) содержит код сканирования,
; а младший (AL) - код ASCII. Эта информация помещается в буфер
; клавиатуры. После заполнения буфера подается звуковой сигнал.
;
;-----------------------------------

kb_int proc far
 	sti	 	   ; установка признака разрешения прерывания
 	push	ax
 	push	bx
 	push	cx
 	push	dx
 	push	si
 	push	di
 	push	ds
 	push	es
 	cld	 	       ; установить признак направления вперед
 	mov	ax,dat	       ; установить адресацию
 	mov	ds,ax
 	in	al,kb_dat      ; считать код сканирования
 	push	ax
 	in	al,kb_ctl      ; считать значение порта 61
 	mov	ah,al	       ; сохранить считанное значение
 	or	al,80h	       ; установить бит 7 порта 61
 	out	kb_ctl,al      ; для работы с клавиатурой
 	xchg	ah,al	       ; восстановить значение порта 61
 	out	kb_ctl,al
 	pop	ax	       ; восстановить код сканирования
 	mov	ah,al	       ; и сохранить его в AH

;---

 	cmp	al,0ffh  ; сравнение с кодом заполнения буфера
 	 	 	 ; клавиатуры
 	jnz	k16	 	; продолжить
 	jmp	k62	; переход на звуковой сигнал по заполнению
 	 	 	; буфера клавиатуры

k16:
 	and	al,07fh 	; сброс бита отжатия клавиши
 	push	cs
 	pop	es
 	mov	di,offset k6  ; установить адрес таблицы сканирования
 	 	 	      ; управляющих клавиш
 	mov	cx,k6l
 	repne scasb	; сравнение полученного кода ска-
 	 	 	; нирования с содержимым таблицы
 	mov	al,ah	 	; запомнить код сканирования
 	je	k17	 	; переход по совпадению
 	jmp	k25	 	; переход по несовпадению
k406:
 	test	kb_flag_1,lat
 	jnz	k26a
 	test	kb_flag,left_shift+right_shift
 	mov	ax,5cf1h
 	jz	k407
 	mov	ax,5cf0h

;   Получение маски нажатой управляющей клавиши

k407:
 	jmp	k57

k17:	sub	di,offset k6+1
 	cmp	di,8
 	jb	k300
 	mov	ah,6
 	cmp	di,0ah
 	jb	k301
 	test	al,80h
 	jz	k26a
 	and	kb_flag_1,not lat+lat_shift
 	cmp	di,0bh
 	je	k401
 	test	kb_flag_1,inv_shift
 	jz	k400
 	or	kb_flag_1,lat_shift
		jmp	short k26a
		nop
k400:	or	kb_flag_1,lat+lat_shift
		jmp	short k26a
		nop
k401:	test	kb_flag_1,inv_shift
 	jz	k26a
 	or	kb_flag_1,lat
		jmp	short k26a
		nop
k300:	mov	ah,cs:k7[di]
k301:
 	test	al,80h	 	; клавиша отжата ?
 	jnz	k23	; переход, если клавиша отжата

;   Управляющая клавиша нажата

 	cmp	ah,scroll_shift ; нажата управляющая клавиша с
 	 	 	 	;  запоминанием ?
 	jae	k18	 	; переход, если да

;---
 	cmp	ah,6
 	je	k302

 	or	kb_flag,ah	; установка масок управляющих клавиш
 	 	 	 	; без запоминания
 	jmp	k26	 	; к выходу из прерывания
k302:	or	kb_flag_1,inv_shift+lat
 	test	kb_flag_1,lat_shift
 	jz	k26a
 	and	kb_flag_1,not lat
k26a:
 	jmp	k26

;   Опрос нажатия клавиши с запоминанием

k18:
 	test	kb_flag,ctl_shift	  ; опрос клавиши УПР
 	jnz	k25
 	cmp	al,ins_key	 	  ; опрос клавиши ВСТ
 	jnz	k22
 	test	kb_flag,alt_shift	  ; опрос клавиши ДОП
 	jz	k19
		jmp	short k25
		nop
k19:	test	kb_flag,num_state  ; опрос клавиши ЦИФ
 	jnz	k21
 	test	kb_flag,left_shift+right_shift ; опрос клавиш левого
 	 	 	     ; и правого переключения регистров
 	jz	k22

k20:
 	mov	ax,5230h
 	jmp	k57	      ; установка кода нуля
k21:
 	test	kb_flag,left_shift+right_shift
 	jz	k20

k22:
 	test	ah,kb_flag_1
 	jnz	k26
 	or	kb_flag_1,ah
 	xor	kb_flag,ah
 	cmp	al,ins_key
 	jne	k26
 	mov	ax,ins_key*256
 	jmp	k57

k303:
 	and	kb_flag_1,not inv_shift
 	xor	kb_flag_1,lat
 	jmp	short k304

;   Управляющая клавиша отжата

k23:

 	cmp	ah,scroll_shift
 	jae	k24
 	not	ah
 	cmp	ah,0f9h
 	je	k303
 	and	kb_flag,ah
k304:
 	cmp	al,alt_key+80h
 	jne	k26

;---

 	mov	al,alt_input
 	mov	ah,0
 	mov	alt_input,ah
 	cmp	al,0
 	je	k26
 	jmp	k58

k24:
 	not	ah
 	and	kb_flag_1,ah
		jmp	short k26
		nop

k25:
 	cmp	al,80h
 	jae	k26
 	cmp	al,inf_key
 	je	k307
 	cmp	al,92
 	jne	k406b
 	jmp	k406
k406b:
 	test	kb_flag_1,hold_state
 	jz	k28
 	cmp	al,num_key
 	je	k26
 	and	kb_flag_1,not hold_state

k26:
 	cli
 	mov	al,eoi
 	out	020h,al
k27:
 	pop	es
 	pop	ds
 	pop	di
 	pop	si
 	pop	dx
 	pop	cx
 	pop	bx
 	pop	ax
 	iret

k307:	mov	ax,0a000h
 	jmp	k57


;---

k28:
 	test	kb_flag,alt_shift
 	jnz	k29
		jmp	short k38
		nop
		
;---

k29:
 	test	kb_flag,ctl_shift
 	jz	k31
 	cmp	al,del_key
 	jne	k31

;---

 	mov	reset_flag,1234h
	db	0eah			;	db	0eah,5bh,0e0h,00h,0f0h	; jmp far ptr start
	dw	offset start, cod	;	###Gleb###

;---




k31:
 	cmp	al,57
 	jne	k32
 	mov	al,' '
 	jmp	k57

;---

k32:
 	mov	di,offset k30
 	mov	cx,10
		repne scasb
 	jne	k33
 	sub	di,offset k30+1
 	mov	al,alt_input
 	mov	ah,10
 	mul	ah
 	add	ax,di
 	mov	alt_input,al
		jmp	short k26

;---

k33:
 	mov	alt_input,00h
 	mov	cx,0026
		repne scasb
 	jne	k34
 	mov	al,0
 	jmp	k57

;---

k34:
 	cmp	al,2
 	jb	k35
 	cmp	al,14
 	jae	k35
 	add	ah,118
 	mov	al,0
 	jmp	k57

;---

k35:
 	cmp	al,59
 	jae	k37
k36:
		jmp	short k26
k37:
 	cmp	al,71
 	jae	k36
 	mov	bx,offset k13
 	jmp	k63

;---

k38:
 	test	kb_flag,ctl_shift
 	jz	k44

;---
;---

 	cmp	al,scroll_key
 	jne	k39
 	mov	bx,offset kb_buffer
 	mov	buffer_head,bx
 	mov	buffer_tail,bx
 	mov	bios_break,80h
 	int	1bh
 	mov	ax,0
 	jmp	k57

k39:
 	cmp	al,num_key
 	jne	k41
 	or	kb_flag_1,hold_state
 	mov	al,eoi
 	out	020h,al

;---

 	cmp	crt_mode,7
 	je	k40
 	mov	dx,03d8h
 	mov	al,crt_mode_set
 	out	dx,al
k40:
 	test	kb_flag_1,hold_state
 	jnz	k40
 	jmp	k27
k41:

;---

 	cmp	al,55
 	jne	k42
 	mov	ax,114*256
 	jmp	k57

;---

k42:
 	mov	bx,offset k8
 	cmp	al,59
 	jae	k43
 	jmp	k56
k43:
 	mov	bx,offset k9
 	jmp	k63

;---

k44:

 	cmp	al,71
 	jae	k48
 	test	kb_flag,left_shift+right_shift
 	jz	k54a

;---

 	cmp	al,15
 	jne	k45
 	mov	ax,15*256
 	jmp	k57

k54a:
 	jmp k54

k45:
 	cmp	al,55
 	jne	k46

;---

 	mov	al,eoi
 	out	020h,al
 	int	5h
 	jmp	k27

k46:
 	cmp	al,59
 	jb	k47
 	mov	bx,offset k12
 	jmp	k63

k47:
 	test	kb_flag_1,lat
 	jz	k98
 	mov	bx,offset k11
 	jmp	 k56
k98:	mov	bx,offset rust2
 	jmp	k56

;---

k48:
 	test	kb_flag,num_state
 	jnz	k52
 	test	kb_flag,left_shift+right_shift
 	jnz	k53

;---

k49:

 	cmp	al,74
 	je	k50
 	cmp	al,78
 	je	k51
 	sub	al,71
 	mov	bx,offset k15
 	jmp	  k64

k50:	mov	ax,74*256+'-'
 	jmp	 k57

k51:	mov	ax,78*256+'+'
 	jmp	 k57

;---

k52:
 	test	kb_flag,left_shift+right_shift
 	jnz	k49

k53:
 	sub	al,70
 	mov	bx,offset k14
 	jmp	 k56
kb_int	endp

		db 7 dup(0)

;--- int 13H---------
;   Программа обслуживания накопителя на гибком магнитном
; диске выполняет шесть функций, код которых задается
; в регистре AH:
;   AH=0 - сбросить  НГМД;
;   AH=1 - считать байт состояния НГМД. Состояние соответствует
; последней выполняемой операции и передается в регистр AL из
; постоянно распределенной области оперативной памяти с адресом
; 00441H;
;    AH=2H - считать указанный сектор в память;
;    AH=3H - записать указанный сектор из памяти;
;    AH=4H - верификация;
;    AH=5H - форматизация.
;    Для выполнения функций записи, считывания, верификации,
; форматизации в регистрах задается следующая информация:
;    DL - номер устройства (0-3, контролируемое значение);
;    DH - номер головки (0-1, неконтролируемое значение);
;    CH - номер дорожки (0-39, неконтролируемое значение);
;    CL - номер сектора (1-8, неконтролируемое значение);
;    AL - количество секторов (1-8, неконтролируемое значение).
;
;    Для выполнения форматизации необходимо сформировать в
; памяти четырехбайтную таблицу для каждого сектора, содержащую
; следующую информацию:
;    номер дорожки;
;    номер головки;
;    номер сектора;
;    количество байт в секторе (00 - 128 байт, 01 - 256 байт,
; 02 - 512 байт, 03 - 1024 байта).
;    Адрес таблицы задается в регистрах ES:BX.
;
;    После выполнения программы в регистре AH находится
; байт состояния НГМД.
;
;    Байт состояния НГМД имеет следующее значение:
;    80 - тайм-аут;
;    40 - сбой позиционирования;
;    20 - сбой контроллера;
;    10 - ошибка кода циклического контроля при считывании;
;    09 - переход адреса через сегмент (64К байт);
;    08 - переполнение;
;    04 - сектор не найден;
;    03 - защита записи;
;    02 - не обнаружен маркер идентификатора сектора;
;    01 - команда отвергнута.
;    При успешном завершении программы признак CF=0,  в про-
; тивном случае - признак CF=1 (регистр AH содержит код ошибки).
;    Регистр AL содержит количество реально считанных секторов.
;    Адрес программы обслуживания накопителя на гибком магнитном
; диске записывается в вектор 40H в процедуре сброса по включению
; питания.
;-------------------------
 	assume	cs:code,ds:data,es:data
diskette_io proc	far
 	sti	 	 	; установить признак прерывания
 	push	bx	 	; сохранить адрес
 	push	cx
 	push	ds	   ; сохранить сегментное значение регистра
 	push	si	   ; сохранить все регистры во время операции
 	push	di
 	push	bp
 	push	dx
 	mov	bp,sp	   ; установить указатель вершины стека
 	mov	si,dat
 	mov	ds,si	 	; установить область данных
 	call	j1	 	;
 	mov	bx,4	 	; получить параметры ожидания мотора
 	call	get_parm
 	mov	motor_count,ah	; уст время отсчета для мотора
 	mov	ah,diskette_status  ; получить состояние операции
 	cmp	ah,1	 	; уст признак CF для индикации
 	cmc	 	 	; успешной операции
 	pop	dx	 	; восстановить все регистры
 	pop	bp
 	pop	di
 	pop	si
 	pop	ds
 	pop	cx
 	pop	bx
 	ret	2
diskette_io	endp
j1	proc	near
 	mov	dh,al	 	; сохранить количество секторов
 	and	motor_status,07fh   ; указать операцию считывания
 	or	ah,ah	 	; AH=0
 	jz	disk_reset
 	dec	ah	 	; AH=1
 	jz	disk_status
 	mov	diskette_status,0   ; сброс состояния
 	cmp	dl,4	 	; проверка количества устройств
 	jae	j3	 	; переход по ошибке
 	dec	ah	 	; AH=2
 	jz	disk_read
 	dec	ah	 	; AH=3
 	jnz	j2
 	jmp	disk_write
j2:
 	dec	ah	 	; AH=4
 	jz	disk_verf
 	dec	ah	 	; AH=5
 	jz	disk_format
j3:
 	mov	diskette_status,bad_cmd   ; неверная команда

 	ret	 	 	; операция не определена
j1	endp

;   Сбросить НГМД

disk_reset proc near
 	mov	dx,03f2h
 	cli	 	 	; сброс признака разрешения прерывания
 	mov	al,motor_status  ; какой мотор включен
 	mov	cl,4	 	; счетчик сдвига
 	sal	al,cl
 	test	al,20h	 	; выбрать соответствующее устройство
 	jnz	j5	 	; переход, если включен мотор первого
 	 	 	 	; устройства
 	test	al,40h
 	jnz	j4	 	; переход, если включен мотор второго
 	 	 	 	; устройства
 	test	al,80h
 	jz	j6	 	; переход, если включен мотор нулевого
 	 	 	 	; устройства
 	inc	al
j4:	inc	al
j5:	inc	al
j6:	or	al,8	 	; включить доступность прерывания
 	out	dx,al	 	; сброс адаптера
 	mov	seek_status,0
 	mov	diskette_status,0  ; уст нормальное состояние НГМД
 	or	al,4	 	; выключить сброс
 	out	dx,al
 	sti	 	 	; установить бит разрешения прерывания
 	call	chk_stat_2	; выполнить прерывание после сброса
 	mov	al,nec_status
 	cmp	al,0c0h    ; проверка готовности устройства для передачи
 	jz	j7	 	; устройство готово
 	or	diskette_status,bad_nec  ; уст код ошибки
 	jmp	short j8

;   Послать команду в контроллер

j7:
 	mov	ah,03h	 	; установить команду
 	call	nec_output	; передать команду
 	mov	bx,1	 	; передача первого байта параметров
 	call	get_parm	; в контроллер
 	mov	bx,3	 	; передача второго байта параметров
 	call	get_parm	; в контроллер
j8:
 	ret	 	 	; возврат к прерванной программе
disk_reset	endp

;
; Считать байт состояния НГМД (AH=1)
;

disk_status proc near
 	mov	al,diskette_status
 	ret
disk_status	endp

;   Считать указанный сектор в память (AH=2)

disk_read proc near
 	mov	al,046h 	; установить команду
j9:
 	call	dma_setup	; установить ПДП
 	mov	ah,0e6h     ; уст команду считывания  контроллера
 	jmp	short rw_opn	; переход к выполнению операции
disk_read	endp

;   Верификация (AH=4)

disk_verf proc near
 	mov	al,042h 	; установить команду
 	jmp	short j9
disk_verf	endp

;   Форматизация (AH=5)

disk_format proc near
 	or	motor_status,80h  ; индикация операции записи
 	mov	al,04ah 	  ; установить команду
 	call	dma_setup	  ; установить ПДП
 	mov	ah,04dh 	  ; установить команду
 	jmp	short rw_opn
j10:
 	mov	bx,7	 	  ; получить значение сектора
 	call	get_parm
 	mov	bx,9	 	; получить значение дорожки на секторе
 	call	get_parm
 	mov	bx,15	 	; получить значение длины интервала
 	call	get_parm	; для контроллера
 	mov	bx,17	 	; получить полный байт
 	jmp	j16
disk_format	endp

;   Записать указанный сектор из памяти (AH=3)

disk_write proc near
 	or	motor_status,80h	; индикация операции записи
 	mov	al,04ah 	 	; уст код операции записи
 	call	dma_setup
 	mov	ah,0c5h 	 	; команда записи на НГМД
disk_write	endp

;______________________
; rw_opn
;   Программа выполнения операций
;   считывания, записи, верификации
;----------------------
rw_opn	proc	near
 	jnc	j11	 	; проверка ошибки ПДП
 	mov	diskette_status,dma_boundary   ; установить ошибку
 	mov	al,0	 	;
 	ret	 	 	; возврат к основной программе
j11:
 	push	ax	 	; сохранить команду

;   Включить мотор и выбрать устройство

 	push	cx
 	mov	cl,dl	 	; уст номер устройства, как счетчик сдвига
 	mov	al,1	 	; маска для определения мотора устройства
 	sal	al,cl	 	; сдвиг
 	cli	 	 	; сбросить бит разрешения прерывания
 	mov	motor_count,0ffh  ; установить счетчик
 	test	al,motor_status
 	jnz	j14
 	and	motor_status,0f0h  ; выключить все биты мотора
 	or	motor_status,al    ; включить мотор
 	sti	 	 	; установить бит разрешения прерывания
 	mov	al,10h	 	; бит маски
 	sal	al,cl	 	; уст бит маски для доступности мотора
 	or	al,dl	 	; включить бит выбора устройства
 	or	al,0ch	 	; нет сброса, доступность прерывания ПДП
 	push	dx
 	mov	dx,03f2h	; установить адрес порта
 	out	dx,al
 	pop	dx	 	; восстановить регистры
 	push	cx	 	;задержка для включения мотора устройства
 	mov	cx,3
x2:	push	cx
 	mov	cx,0
x1:	loop	x1
 	pop	cx
 	loop	x2
 	pop	cx

;   Ожидание включения мотора для операции записи

 	test	motor_status,80h  ; запись ?
 	jz	j14	; нет - продолжать без ожидания
 	mov	bx,20	 	; установить ожидание включения мотора
 	call	get_parm	; получить параметры
 	or	ah,ah
j12:
 	jz	j14	 	; выход по окончании времени ожидания
 	sub	cx,cx	 	; установить счетчик
j13:	loop	j13	 	; ожидать требуемое время
 	dec	ah	 	; уменьшеть значение времени
 	jmp	short j12	; повторить цикл

j14:
 	sti	 	 	; уст признак разрешения прерывания
 	pop	cx

;   Выполнить операцию поиска

 	call	seek	 	; установить дорожку
 	pop	ax	 	; восстановить команду
 	mov	bh,ah	 	; сохранить команду в BH
 	mov	dh,0	 	; уст 0 сектор в случае ошибки
 	jc	j17	 	; выход, если ошибка
 	mov	si,offset j17

 	push	si

;   Послать параметры в контроллер

 	call	nec_output	; передача команды
 	mov	ah,byte ptr [bp+1]  ; уст номер головки
 	sal	ah,1	 	; сдвиг на 2
 	sal	ah,1
 	and	ah,4	 	; выделить бит
 	or	ah,dl	 	; операция OR с номером устройства
 	call	nec_output

;   Проверка операции форматизации

 	cmp	bh,04dh 	; форматизация ?
 	jne	j15    ; нет - продолжать запись/считывание/верификацию
 	jmp	j10

j15:	mov	ah,ch	 	; номер цилиндра
 	call	nec_output
 	mov	ah,byte ptr [bp+1]  ; номер головки
 	call	nec_output
 	mov	ah,cl	 	; номер сектора
 	call	nec_output
 	mov	bx,7
 	call	get_parm
 	mov	bx,9
 	call	get_parm
 	mov	bx,11
 	call	get_parm
 	mov	bx,13
j16:
 	call	get_parm
 	pop	si

;   Операция запущена

 	call	wait_int	; ожидание прерывания
j17:
 	jc	j21	 	; поиск ошибки
 	call	results 	; получить состояние контроллера
 	jc	j20	 	; поиск ошибки

;   Проверка  состояния, полученного из контроллера

 	cld	 	 	; установить направление коррекции
 	mov	si,offset nec_status
 	lods	nec_status
 	and	al,0c0h 	; проверить нормальное окончание
 	jz	j22
 	cmp	al,040h 	; проверить неверное окончание
 	jnz	j18

;   Обнаруженно неверное окончание

 	lods	nec_status
 	sal	al,1
 	mov	ah,record_not_fnd
 	jc	j19
 	sal	al,1
 	sal	al,1
 	mov	ah,bad_crc
 	jc	j19
 	sal	al,1
 	mov	ah,bad_dma
 	jc	j19
 	sal	al,1
 	sal	al,1
 	mov	ah,record_not_fnd
 	jc	j19
 	sal	al,1
 	mov	ah,write_protect  ; проверка защиты записи
 	jc	j19
 	sal	al,1
 	mov	ah,bad_addr_mark
 	jc	j19

;   Контроллер вышел из строя

j18:
 	mov	ah,bad_nec
j19:
 	or	diskette_status,ah
 	call	num_trans
j20:
 	ret	 	; возврат к программе, вызвавшей прерывание

j21:
 	call	results 	; вызов результатов в буфер
 	ret

;   Операция была успешной

j22:
 	call	num_trans
 	xor	ah,ah	 	; нет ошибок
 	ret
rw_opn	endp
;------------------------
;get_parm
;
;   ВХОД   BX - индекс байта,деленный
;	 	на 2,который будет
;	 	выбран,если младший
;	 	бит BX установлен,то
;	 	байт немедленно пере-
;	 	дается контроллеру.
;
;   ВЫХОД  AH - байт из блока.
;-------------------------
get_parm proc	near
 	push	ds	 	; сохранить сегмент
 	sub	ax,ax	 	; AX=0
 	mov	ds,ax
 	assume	ds:abs0
 	lds	si,disk_pointer
 	shr	bx,1	 	; делить BX на 2, уст флаг для выхода
 	mov	ah,zb[si+bx]	; получить слово
 	pop	ds	 	; восстановить сегмент
 	assume	ds:data
 	jc	nec_op	 	 ;если флаг установлен, выход
 	ret	 	; возврат к программе, вызвавшей прерывание
nec_op: jmp	nec_output
get_parm endp
;----------------------------
;   Позиционирование
;
;   Эта программа позиционирует голов-
; ку обозначенного устройства на нуж-
; ную дорожку. Если устройство не
; было выбрано до тех пор, пока не
; была сброшена команда,то устройство
; будет рекалибровано.
;
;   ВВОД
;	(DL) - номер усройства для
;	       позиционирования,
;	(CH) - номер дорожки.
;
;   ВЫВОД
;	 CY=0 - успешно,
;	 CY=1 - сбой (состояние НГМД установить
;	 	согласно  AX).
;----------------------------
seek	proc	near
 	mov	al,1	 	; уст маску
 	push	cx
 	mov	cl,dl	 	; установить номер устройства
 	rol	al,cl	 	; циклический сдвиг влево
 	pop	cx
 	test	al,seek_status
 	jnz	j28
 	or	seek_status,al
 	mov	ah,07h
 	call	nec_output
 	mov	ah,dl
 	call	nec_output
 	call	chk_stat_2   ; получить и обработать прерывание
 	mov	ah,07h	 	; команда рекалибровки
 	call	nec_output
 	mov	ah,dl
 	call	nec_output
 	call	chk_stat_2
 	jc	j32	 	; сбой позиционирования


j28:
 	mov	ah,0fh
 	call	nec_output
 	mov	ah,dl	 	; номер устройства
 	call	nec_output
 	mov	ah,ch	 	; номер дорожки
		nop
 	test	byte ptr equip_flag,4
 	jnz	j300
 	add	ah,ah	 	; удвоение номера дорожки
j300:
 	call	nec_output
 	call	chk_stat_2	; получить конечное прерывание и
 	 	 	 	; считать состояние


 	pushf	 	 	; сохранить значение флажков
 	mov	bx,18
 	call	get_parm
 	push	cx	 	; сохранить регистр
j29:
 	mov	cx,550	 	; организовать цикл = 1 ms
 	or	ah,ah	 	; проверка окончания времени
 	jz	j31
j30:	loop	j30	 	; задержка 1ms
 	dec	ah	 	; вычитание из счетчика
 	jmp	short j29	; возврат к началу цикла
j31:
 	pop	cx	 	; восстановить состояние
 	popf
j32:	 	 	 	; ошибка позиционирования
 	ret	 	; возврат к программе, вызвавшей прерывание
seek	endp
;-----------------------
; dma_setup
;   Программа установки ПДП для операций записи,считывания,верифи-
; кации.
;
;   ВВОД
;
;	(AL) - байт режима для ПДП,
;	(ES:BX) - адрес считывания/записи информации.
;
;------------------------
dma_setup proc	near
 	push	cx	 	; сохранить регистр
 	out	dma+12,al
 	out	dma+11,al	; вывод байта состояния
 	mov	ax,es	 	; получить значение ES
 	mov	cl,4	 	; счетчик для сдвига
 	rol ax,cl	 	; циклический сдвиг влево
 	mov	ch,al	 	;
 	and	al,0f0h 	;
 	add	ax,bx
 	jnc	j33
 	inc	ch	 	; перенос означает, что старшие 4 бита
 	 	 	 	; должны быть прибавлены
j33:
 	push	ax	 	; сохранить начальный адрес
 	out	dma+4,al	; вывод младшей половины адреса
 	mov	al,ah
 	out	dma+4,al	; вывод старшей половины адреса
 	mov	al,ch	 	; получить 4 старших бита
 	and	al,0fh
 	out	081h,al   ; вывод 4 старших бит на регистр страниц

;   Определение счетчика

 	mov	ah,dh	 	; номер сектора
 	sub	al,al	 	;
 	shr	ax,1	 	;
 	push	ax
 	mov	bx,6	 	; получить параметры байт/сектор
 	call	get_parm
 	mov	cl,ah	 	; счетчик сдига (0=128, 1=256 и т.д)
 	pop	ax
 	shl	ax,cl	 	; сдвиг
 	dec	ax	 	; -1
 	push	ax	 	; сохранить значение счетчика
 	out	dma+5,al	; вывести младший байт счетчика
 	mov	al,ah
 	out	dma+5,al	; вывести старший байт счетчика
 	pop	cx	 	; восстановить значение счетчика
 	pop	ax	 	; восстановить значение адреса
 	add	ax,cx	 	; проверка заполнения 64K
 	pop	cx	 	; восстановить регистр
 	mov	al,2	 	; режим для 8237
 	out	dma+10,al	; инициализация канала НГМД
 	ret	 	; возврат к программе, вызвавшей прерывание
dma_setup	endp
;-----------------------
;chk_stat_2
;   Эта программа обрабатывает прерывания ,полученные после
; рекалибровки, позиционирования или сброса адаптера. Прерывание
; ожидается, принимается, обрабатывается и результат выдается программе,
; вызвавшей прерывание.
;
;   ВЫВОД
;	  CY=0 - успешно,
;	  CY=1 - сбой (ошибка в состоянии НГМД),
;--------------------------
chk_stat_2 proc near
 	call	wait_int	; ожидание прерывания
 	jc	j34	 	; если ошибка, то возврат
 	mov	ah,08h	 	; команда получения состояния
 	call	nec_output
 	call	results 	; считать результаты
 	jc	j34
 	mov	al,nec_status	; получить первый байт состояния
 	and	al,060h 	; выделить биты
 	cmp	al,060h 	; проверка
 	jz	j35	   ; если ошибка, то идти на метку
 	clc	 	 	; возврат
j34:
 	ret	 	; возврат к программе, вызвавшей прерывание
j35:
 	or	diskette_status,bad_seek
 	stc	 	 	; ошибка в возвращенном коде
 	ret
chk_stat_2	endp
;---------------------------------
; wait_int
;   Эта программа ожидает прерывание, которое возникает во время
; программы вывода. Если устройство не готово, ошибка может быть
; возвращена.
;
;
;   ВЫВОД
;	      CY=0 - успешно,
;	      CY=1 - сбой(состояние НГМД устанавливается),
;-----------------------------------
wait_int proc	near
 	sti	 	 	; установить признак разрешения прерывания
 	push	bx
 	push	cx	 	; сохранить регистр
 	mov	bl,2	 	; количество циклов
 	xor	cx,cx	 	; длителность одного цикла ожидания
j36:
 	test	seek_status,int_flag  ; опрос наличия прерывания
 	jnz	j37
 	loop	j36	 	; возврат к началу цикла
 	dec	bl
 	jnz	j36
 	or	diskette_status,time_out
 	stc	 	 	; возврат при ошибке
j37:
 	pushf	 	 	; сохранить текущие признаки
 	and	seek_status,not int_flag
 	popf	 	 	; восстановить признаки
 	pop	cx
 	pop	bx	 	; восстановить регистр
 	ret	 	; возврат к программе, вызвавшей прерывание
wait_int	endp

		db 3 dup(0)

;---------------------------
;disk_int
;   Эта программа обрабатывает прерывания НГМД
;
;   ВЫВОД  - признак прерывания устанавливается в SEEK_STATUS.
;---------------------------
disk_int proc	far
 	sti	 	 	; установить признак разрешения прерывания
 	push	ds
 	push	ax
 	mov	ax,dat
 	mov	ds,ax
 	or	seek_status,int_flag
 	mov	al,20h	 	; установить конец прерывания
 	out	20h,al	 	; послать конец прерывания в порт
 	pop	ax
 	pop	ds
 	iret	 	 	; возврат из прерывания
disk_int	endp
;----------------------------
;
;   Эта программа считывет все, что контроллер адаптера НГМД указывает
; программе, следующей за прерыванием.
;
;
;   ВЫВОД
;	   CF=0 - успешно,
;	   CF=1 - сбой
;----------------------------
results proc	near
 	cld
 	mov	di,offset nec_status
 	push	cx	 	; сохранить счетчик
 	push	dx
 	push	bx
 	mov	bl,7	 	; установить длину области состояния


j38:
 	xor	cx,cx	 	; длительность одного цикла
 	mov	dx,03f4h	; адрес порта
j39:
 	in	al,dx	 	; получить состояние
 	test	al,080h 	; готово ?
 	jnz	j40a
 	loop	j39
 	or	diskette_status,time_out
j40:	 	 	 	; ошибка
 	stc	 	 	; возврат по ошибке
 	pop	bx
 	pop	dx
 	pop	cx
 	ret

;   Проверка признака направления

j40a:	in	al,dx	 	; получить регистр состояния
 	test	al,040h 	; сбой позиционирования
 	jnz	j42	; если все нормально, считать состояние
j41:
 	or	diskette_status,bad_nec
 	jmp	short j40	; ошибка

;   Считывание состояния

j42:
 	inc	dx	 	; указать порт
 	in	al,dx	 	; ввести данные
 	mov    byte ptr [di],al  ; сохранить байт
 	inc	di	 	; увеличить адрес
 	mov	cx,000ah	; счетчик
j43:	loop	j43
 	dec	dx
 	in	al,dx	 	; получить состояние
 	test	al,010h
 	jz	j44
 	dec	bl	 	; -1 из количества циклов
 	jnz	j38
 	jmp	short j41	; сигнал неверен

j44:
 	pop	bx	 	; восстановить регистры
 	pop	dx
 	pop	cx
 	ret	 	 	; возврат из прерывания
results endp
;-----------------------------
; num_trans
;   Эта программа вычисляет количество секторов, которое действительно
; было записано или считано с НГМД
;
;   ВВОД
;	 (CH) - цилиндр,
;	 (CL) - сектор.
;
;   ВЫВОД
;	 (AL) - количество действительно переданных секторов.
;
;------------------------------
num_trans proc	near
 	mov	al,nec_status+3  ; получить последний цилиндр
 	cmp	al,ch	 	; сравнить со стартовым
 	mov	al,nec_status+5  ; получить последний сектор
 	jz	j45
 	mov	bx,8
 	call	get_parm	; получить значение EOT
 	mov	al,ah	 	; AH в AL
 	inc	al	 	; EOT+1
j45:	sub	al,cl	    ; вычисление стартового номера из конечного
 	ret
num_trans endp

;-------------------------------
; disk_base
;   Эта программа устанавливает параметры,требуемые для операций
; НГМД.
;--------------------------------

disk_base label byte
 	db	11001111b	;
 	db	2	 	;
 	db	motor_wait	;
 	db	2	 	;
 	db	8	 	;
 	db	02ah	 	;
 	db	0ffh	 	;
 	db	050h	 	;
 	db	0f6h	 	;
 	db	25	 	;
 	db	4	 	;
;--- int 17-------------------
;   Программа связи с печатающим устройством
;
;   Эта программа выполняет три функции, код которых задается
; в регистре AH:
;   AH=0 - печать знака, заданного в регистре AL. Если в
; результате выполнения функции знак не напечатается, то в регистре
; AL устанавливается "1" (тайм-аут);
;   AH=1 - инициализация порта печати. После выполнения функции
; в регистре AH находится байт состояния печатающего устройства;
;   AH=2H - считывание байта состояния печатающего устройства.
;   В регистре DX необходимо задать ноль.
;   Значение разрядов байта состояния печатающего устройства:
;   0 - тайм-аут;
;   3 - ошибка ввода-вывода;
;   4 - выбран (SLCT);
;   5 - конец бумаги (PE);
;   6 - подтверждение;
;   7 - занято.
;------------------------------

 	assume	cs:code,ds:data
printer_io proc far
 	sti	 	 	; установить признак разрешения прерывания
 	push	ds	 	; сохранить сегмент
 	push	dx
 	push	si
 	push	cx
 	push	bx
 	mov	si,dat
 	mov	ds,si	 	; установить сегмент
 	mov	si,dx
 	shl	si,1
 	mov	dx,printer_base[si]  ; получить базовый адрес
 	 	 	 	     ; печатающего устройства
 	or	dx,dx	 	   ; печать подключена ?
 	jz	b1	 	   ; нет, возврат
 	or	ah,ah	 	   ; AH=0 ?
 	jz	b2	 	   ; да, переход к печати знака
 	dec	ah	 	   ; AH=1 ?
 	jz	b8	 	   ; да, переход к инициализации
 	dec	ah	 	   ; AH=2 ?
 	jz	b5	   ; да, переход к считыванию байта состояния

;    Выход из программы

b1:
 	pop	bx	 	; восстановить регистры
 	pop	cx
 	pop	si
 	pop	dx
 	pop	ds
 	iret

;   Печать знака, заданного в AL

b2:
 	push	ax
 	mov	bl,10	 	; количество циклов ожидания
 	xor	cx,cx	 	; длительность одного цикла
 	out	dx,al	 	; вывести символ в порт
 	inc	dx	 	; -1 из адреса порта
b3:	 	 	 	; ожидание BUSY
 	in	al,dx	 	; получить состояние
 	mov	ah,al	 	; переслать состояние в AH
 	test	al,80h	 	; печать занята ?
 	jnz	b4	 	; переход, если да
 	loop	b3	 	; цикл ожидания закончился ?
 	dec	bl	 	; да, -1 из количества циклов
 	jnz	b3	 	; время ожидания истекло ?
 	or	ah,1	 	; да, уст бит "тайм-аут"
 	and	ah,0f9h 	;
 	jmp	short b7
b4:	 	 	 	; OUT_STROBE
 	mov	al,0dh	 	; установить высокий строб
 	inc	dx	; стробирование битом 0 порта C для 8255
 	out	dx,al
 	mov	al,0ch	 	; установить низкий строб
 	out	dx,al
 	pop	ax	 	;

;   Считывание байта состояния печатающего устройства

b5:
 	push	ax	 	; сохранить регистр
b6:
 	mov	dx,printer_base[si]  ; получить адрес печати
 	inc	dx
 	in	al,dx	 	; получить состояние печати
 	mov	ah,al
 	and	ah,0f8h
b7:
 	pop	dx
 	mov	al,dl
 	xor	ah,48h
 	jmp	short b1	; к выходу из программы

;   Инициализация порта печатающего устройства

b8:
 	push	ax
 	add	dx,2	 	; указать порт
 	mov	al,8
 	out	dx,al
 	mov	ax,1000 	 ; время задержки
b9:
 	dec	ax	 	 ; цикл задержки
 	jnz	b9
 	mov	al,0ch
 	out	dx,al
 	jmp	short b6    ; переход к считыванию байта состояния
printer_io	endp
;--- int 10------------------
;
;   Программа обработки прерывания ЭЛИ
;
;   Эта программа обеспечивает выполнение функций обслуживания
; адаптера ЭЛИ, код которых задается в регистре AH:
;
;    AH=0   - установить режим работы адаптера ЭЛИ. В результате
; выполнения функции в регистре AL могут устанавливаться следу-
; ющие режимы:
;    0 - 40х25, черно-белый, алфавитно-цифровой;
;    1 - 40х25, цветной, алфавитно-цифровой;
;    2 - 80х25, черно-белый, алфавитно-цифровой;
;    3 - 80х25, цветной, алфавитно-цифровой;
;    4 - 320х200, цветной, графический;
;    5 - 320х200, черно-белый, графический;
;    6 - 640х200, черно-белый, графический;
;    7 - 80х25, черно-белый, алфавитно-цифровой.
;    Режимы 0 - 6 используются для ЭМ адаптера ЭЛИ, режим 7
; используется для монохромного черно-белого 80х25 адаптера.
;
;    AH=1   - установить размер курсора. Функция задает размер кур-
; сора и управление им.
;   Разряды 0 - 4 регистра CL определяют конечную границу курсора,
; разряды 0 - 4 регистра CH - начальную границу курсора.
;    Разряды 6 и 5 задают управление курсором:
;    00 - курсор мерцает с частотой, задаваемой аппаратурно;
;    01 - курсор отсутствует.
;    Аппаратурно всегда вызывается мерцание курсора с частотой,
; равной 1/16 частоты кадровой развертки.
;
;    AH=2   - установить текущую позицию курсора. Для выполнения
; функции необходимо задать следующие координаты курсора:
;    BH - страница;
;    DX - строка и колонка.
; При графическом режиме регистр BH=0.
;
;    AH=3   - считать текущее положение курсора. Функция вос-
; станавливает текущее положение курсора. Перед выполнением
; функции в регистре BH необходимо задать страницу.
;    После выполнения программы регистры содержат следующую
; информацию:
;    DH - строка;
;    DL - колонка;
;    CX - размер курсора и управление им.
;
;    AH=5  - установить активную страницу буфера адаптера.
; Функция используется только в алфавитно-цифровом режиме.
; Для ее выполнения необходимо в регистре AL задать страницу:
;    0-7 - для режимов 0 и 1;
;    0-3 - для режимов 2 и 3.
;    Значения режимов те же, что и для функции AH=0.
;
;    AH=6   - переместить блок символов вверх по экрану.
; Функция перемещает символы в пределах заданной области вверх
; по экрану, заполняя нижние строки пробелами с заданным атрибу-
; том.
;    Для выполнения функции необходимо задать следующие пара-
; метры;
;    AL - количество перемещаемых строк. Для очистки блока AL=0;
;    CX - координаты левого верхнего угла блока (строка,колонка);
;    DX - координаты правого нижнего угла блока;
;    BH - атрибут символа пробела.
;
;    AH=7   - переместить блок символов вниз. Функция перемещает
; символы в пределах заданной области вниз по экрану, заполняя
; верхние строки пробелами с заданным атрибутом.
;    Для выполнения функции необходимо задать те же параметры,
; что и для функции AH=6H.
;
;    AH=8   - считать атрибут и код символа, находящегося в теку-
; щей позиции курсора. Функция считывает атрибут и код символа
; и помещает их в регистр AX (AL - код символа, AH - атрибут
; символа).
;    Для выполнения функции необходимо в регистре BH задать
; страницу (только для алфавитно-цифрового режима).
;
;    AH=9   - записать атрибут и код символа в текущую позицию
; курсора. Функция помещает код символа и его атрибут в текущую
; позицию курсора.
;    Для выполнения функции необходимо задать следующие параметры:
;    BH - отображаемая страница (только для алфавитно-цифрового
; режима;
;    CX - количество записываемых символов;
;    AL - код символа;
;    BL - атрибут символа для алфавитно-цифрового режима или
; цвет знака для графики. При записи точки разряд 7 регистра BL=1.    =1
;
;    AH=10 - записать символ в текущую позицию курсора. Атрибут
; не изменяется.
;    Для выполнения функции необходимо задать следующие параметры:
;    BH - отображаемая страница (только для алфавитно-цифрового
; режима);
;    CX - количество повторений символа;
;    AL - код записываемого символа.	 	 	 	      ся
;	 	 	 	 	 	 	 	      -
;    AH=11 - установить цветовую палитру.	 	 	      ь
;    При выполнении функции используются два варианта.
;    Для первого варианта в регистре BH задается ноль,а в регистре
; BL - значения пяти младших разрядов, используемых для выбора
; цветовой палитры (цвет заднего плана для цветного графического
; режима 320х200 или цвет каймы для цветного графического режима
; 40х25).
;    Для второго варианта в регистре BH задается "1", а в регистре
; BL - номер цветовой палитры (0 или 1).
;    Палитра 0 состоит из зеленого (1), красного (2) и желтого (3)
; цветов, палитра 1 - из голубого (1), фиолетового (2) и белого (3).
; При работе с видеомонитором цвета палитры заменяются соответству-
; ющими градациями цвета.
;    Результатом выполнения функции является установка цветовой       )
; палитры в регистре выбора цвета (3D9).
;
;    AH=12  - записать точку. Функция определяет относительный
; адрес байта внутри буфера ЭЛИ, по которому должна быть записана
; точка с заданными координатами.
;    Для выполнения функции необходимо задать следующие параметры:    ,
;    DX - строка;
;    CX - колонка;
;    AL - цвет выводимой точки. Если разряд 7 регистра AL уста-       3)
; новлен в "1", то выполняется операция XOR над значением точки
; из буфера и значением точки из регистра AL.
;
;    AH=13 - считать точку. Функция определяет относительный
; адрес байта внутри буфера ЭЛИ, по которому должна быть считана
; точка с заданными координатами.
;    Перед выполнением программы в регистрах задаются те же парамет-
; ры, что и для функции AH=12.
;   После выполнения программы в регистре AL находится значение
; считанной точки.
;
;    AH=14 - записать телетайп. Функция выводит символ в буфер
; ЭЛИ с одновременной установкой позиции курсора и передвижением
; курсора на экране.
;    После записи символа в последнюю позицию строки выполняется
; автоматический переход на новую строку. Если страница экрана
; заполнена, выполняется перемещение на одну строку вверх. Осво-
; бодившаяся строка заполняется значением атрибута символа для
; алфавитно-цифрового режима или нулями - для графики.
;    После записи очередного символа курсор устанавливается
; в следующую позицию.
;    Для выполнения программы необходимо задать следующие параметры:
;    AL - код выводимого символа;
;    BL - цвет переднего плана (для графического режима).
;    Программа обрабатывает следующие служебные символы:
;    0BH - сдвиг курсора на одну позицию (без очистки);
;    0DH - перемещение курсора в начало строки;
;    0AH - перемещение курсора на следующую строку;
;    07H - звуковой сигнал.
;
;    AH=15 - получить текущее состояние ЭЛИ. Функция считывает
; текущее состояние ЭЛИ из памяти и размещает его в следующих
; регистрах;
;    AH - количество колонок (40 или 80);
;    AL - текущий режим (0-7). Значения режимов те же, что и для
; функции AH=0;
;    BH - номер активной страницы.
;
;   AH=17 - загрузить знакогенератор пользователя. Функция дает
; возможность пользователю загружать знакогенератор любым, необ-
; ходимым ему алфавитом.
;    Для выполнения программы необходимо задать следующие параметры:
;    ES:BP - адрес таблицы, сформированной пользователем;
;    CX    - количество передаваемых символов;
;    BL    - код символа, начиная с которого загружается таблица
; пользователя;
;    BH - количество байт на знакоместо;
;    DL - идентификатор таблицы пользователя;
;    AL - режим:
;	 	  AL=0	 -  загрузить знакогенератор
;	 	  AL=1	 -  выдать идентификатор таблицы
;	 	  AL=3	 -  загрузить вторую половину знакогенератора:
;	 	 	    BL=0 - загрузить вторую половину знакогене
;	 	 	    ратора из ПЗУ кодовой таблицы с русским
;	 	 	    алфавитом,
;	 	 	    BL=1 - загрузить вторую половину знакогене
;	 	 	    ратора из ПЗУ стандартной кодовой таблицей
;	 	 	    ASCII (USA)
;   На выходе:
;	AH   -	количество байт на знакоместо
;	AL   -	идентификатор таблицы пользователя
;	CF=1   -   операция завершена успешно
;
;    AH=19 - переслать цепочку символов. Функция позволяет пере-
; сылать символы четырьмя способами, тип которых задается в
; регистре AL:
;    AL=0 - символ, символ, символ, ...
; В регистре BL задается атрибут, курсор не движется;
;    AL=1 - символ, символ, символ, ...
; В регистре BL задается атрибут, курсор движется;
;    AL=2H - символ, атрибут, символ, атрибут, ...
; Курсор не движется;
;    AL=3H - символ, атрибут, символ, атрибут, ...
; Курсор движется.
;     Кроме того необходимо задать в регистрах:
;    ES:BP - начальный адрес цепочки символов;
;    CX    - количество символов;
;    DH,DL - строку и колонку для начала записи;
;    BH    - номер страницы.
;-----------------------------------------------------------

 	assume cs:code,ds:data,es:video_ram

m1	label	word	 	; таблица функций адаптера ЭЛИ
 	dw	offset	set_mode
 	dw	offset	set_ctype
 	dw	offset	set_cpos
 	dw	offset	read_cursor
 	dw	offset	read_lpen
 	dw	offset	act_disp_page
 	dw	offset	scroll_up
 	dw	offset	scroll_down
 	dw	offset	read_ac_current
 	dw	offset	write_ac_current
 	dw	offset	write_c_current
 	dw	offset	set_color
 	dw	offset	write_dot
 	dw	offset	read_dot
 	dw	offset	write_tty2
 	dw	offset	video_state
m1l	equ	20h

video_io proc	near
 	sti	 	    ; установить признак разрешения прерывания
 	cld
 	push	es
 	push	ds
 	push	dx
 	push	cx
 	push	bx
 	push	si
 	push	di
 	push	ax	 	; сохранить значение AX
 	mov	al,ah	 	; переслать AH в AL
 	xor	ah,ah	 	; обнулить старший байт
 	sal	ax,1	 	; умножить на 2
 	mov	si,ax	 	; поместить в SI
 	cmp	ax,m1l	 	; проверка длины таблицы функций
 	jb	m2	 	; адаптера ЭЛИ
 	pop	ax	 	; восстановить AX
 	jmp	video_return	; выход, если AX неверно
m2:	mov	ax,dat
 	mov	ds,ax
 	mov	ax,0b800h	; сегмент для цветного адаптера
 	mov	di,equip_flag	; получить тип адаптера
	and	di,30h 		; выделить биты режима ; db 81h,0E7h,30h,00h	; ###Gleb###
 	cmp	di,30h	 	; есть установка ч/б адаптера ?
 	jne	m3
 	mov	ax,0b000h	; уст адреса буфера для ч/б адаптера
m3:	mov	es,ax
 	pop	ax	 	; восстановить значение
 	mov	ah,crt_mode	; получить текущий режим в AH
 	jmp   cs:m1[si]
video_io	endp
;-------------------------
; set mode

;   Эта программа устанавливает режим работы адаптера ЭЛИ
;
;   ВХОД
;	   (AL) - содержит значение режима.
;
;--------------------------

;   Таблицы параметров ЭЛИ

video_parms label	byte

;   Таблица инициализации

 	db	38h,28h,2dh,0ah,1fh,6,19h   ; уст для 40х25

 	db	1ch,2,7,6,7
 	db	0,0,0,0
m4	equ	10h

 	db	71h,50h,5ah,0ah,1fh,6,19h   ; уст для 80х25

 	db	1ch,2,7,6,7
 	db	0,0,0,0

 	db	38h,28h,2dh,0ah,7fh,6,64h   ; уст для графики

 	db	70h,2,1,6,7
 	db	0,0,0,0

 	db	62h,50h,50h,0fh,19h,6,19h   ; уст для 80х25 ч/б адаптера

 	db	19h,2,0dh,0bh,0ch
 	db	0,0,0,0

m5	label	word	 	; таблица для восстановления длины
 	dw	2048
 	dw	4096
 	dw	16384
 	dw	16384

;   Колонки
m6	label	byte
 	db	40,40,80,80,40,40,80,80


;--- c_reg_tab
m7	label	byte	 	; таблица установки режима
 	db	2ch,28h,2dh,29h,2ah,2eh,1eh,29h


set_mode proc	near
 	mov	dx,03d4h	; адрес цветного адаптера
 	mov	bl,0	 ; уст значение для цветного адаптера
 	cmp	di,30h	 	; установлен ч/б адаптер ?
 	jne	m8	 	; переход, если указан цветной
 	mov	al,7	 	; указать ч/б режим
 	mov	dx,03b4h	; адрес для ч/б адаптера
 	inc	bl	 	; установить режим для ч/б адаптера
m8:	mov	ah,al	 	; сохранить режим в AH
 	mov	crt_mode,al
 	mov	addr_6845,dx	; сохранить адрес управляющего порта
 	 	 	 	; для активного дисплея
 	push	ds
 	push	ax	 	; сохранить режим
 	push	dx	 	; сохранить значение порта вывода
 	add	dx,4	 	; указать адрес регистра управления
 	mov	al,bl	 	; получить режим для адаптера
 	out	dx,al	 	; сброс экрана
 	pop	dx	 	; восстановить DX
 	sub	ax,ax
 	mov	ds,ax	 	; установить адрес таблицы векторов
 	assume	ds:abs0
 	lds	bx,parm_ptr ; получить значение параметров адаптера ЭЛИ
 	pop	ax	 	; восстановить AX
 	assume	ds:code
 	mov	cx,m4	   ; установить длину таблицы параметров
 	cmp	ah,2	 	; определение режима
 	jc	m9	 	; режим 0 или 1 ?
 	add	bx,cx	 	; уст начало таблицы параметров
 	cmp	ah,4
 	jc	m9	 	; режим 2 или 3
 	add	bx,cx	 	; начало таблицы для графики
 	cmp	ah,7
 	jc	m9	 	; режимы 4, 5 или 6 ?
 	add	bx,cx	 	; уст начало таблицы для ч/б адаптера

;   BX указывает на строку таблицы инициализации

m9:	 	 	 	; OUT_INIT
 	push	ax	 	; сохранить режим в AH
 	xor	ah,ah	 	;

;   Цикл таблицы, устанавливающий адреса регистров и выводящий значения
; из таблицы

m10:
 	mov	al,ah	 	;
 	out	dx,al
 	inc	dx	 	; указать адрес порта
 	inc	ah	 	;
 	mov	al,byte ptr [bx]   ; получить значение таблицы
 	out	dx,al	 	; послать строку из таблицы в порт
 	inc	bx	 	; +1 к адресу таблицы
 	dec	dx	 	; -1 из адреса порта
 	loop	m10	 	; передана вся таблица ?
 	pop	ax	 	; вернуть режимы
 	pop	ds	 	; вернуть сегмент
 	assume	ds:data

;   Инициализация буфера дисплея

 	xor	di,di	 	; DI=0
 	mov	crt_start,di	; сохранить начальный адрес
 	mov	active_page,0	; установить активную страницу
 	mov	cx,8192 	; количество слов в цветном адаптере
 	cmp	ah,4	 	; опрос графики
 	jc	m12	 	; нет инициализации графики
 	cmp	ah,7	 	; опрос ч/б адаптера
 	je	m11	 	; инициализация ч/б адаптера
 	xor	ax,ax	 	; для графического режима
 	jmp	short m13	; очистить буфер
m11:	 	 	 	; инициализация ч/б адаптера
 	mov	cx,2048 	; об'ем буфера ч/б адаптера
m12:
 	mov	ax,' '+7*256    ; заполнить характеристики для альфа
m13:	 	 	 	; очистить буфер
 	rep	stosw	 	; заполнить область буфера пробелами

;   Формирование порта управления режимом

 	mov	cursor_mode,67h   ; установить режим текущего курсора (ERROR - MUS BE 607h)
 	mov	al,crt_mode	; получить режим в регистре AX
 	xor	ah,ah
 	mov	si,ax	 	; таблица указателей режима
 	mov	dx,addr_6845	; подготовить адрес порта для вывода
 	add	dx,4
 	mov al,cs:m7[si]
 	out	dx,al
 	mov	crt_mode_set,al

;   Форморование количества колонок

 	mov al,cs:m6[si]
 	xor	ah,ah
 	mov	crt_cols,ax	; коичество колонок на экране

;   Установить позицию курсора

	and	si,0eh	 	; db 81h,0E6h,0Eh,00h	; ###Gleb###
 	mov cx,cs:m5[si]  ; длина для очистки
 	mov	crt_len,cx
 	mov	cx,8	 	; очистить все позиции курсора
 	mov	di,offset cursor_posn
 	push	ds	 	; восстановить сегмент
 	pop	es
 	xor	ax,ax
 	rep	stosw	 	; заполнить нулями

;   Установка регистра сканирования

 	inc	dx	 	; уст порт сканирования по умолчанию
 	mov	al,30h	 	; значение 30H для всех режимов,
 	 	 	 	; исключая 640х200
 	cmp	crt_mode,6	; режим ч/б 640х200
 	jnz	m14	 	; если не 640х200
 	mov	al,3fh	 	; если 640х200, то поместить в 3FH
m14:	out	dx,al	 	; вывод правильного значения в порт 3D9
 	mov	crt_pallette,al   ; сохранить значение для использования

;   Нормальный возврат

video_return:
 	pop	di
 	pop	si
 	pop	bx
m15:
 	pop	cx	 	; восстановление регистров
 	pop	dx
 	pop	ds
 	pop	es
 	iret	 	 	; возврат из прерывания
set_mode	endp
;--------------------
; set_ctype
;
;   Эта программа устанавливает размер курсора и управление им
;
;   ВХОД
;	   (CX) - содержит размер курсора. (CH - начальная граница,
;	 	  CL - конечная граница)
;
;--------------------
set_ctype proc	near
 	mov	ah,10	 	; установить регистр 6845 для курсора
 	mov	cursor_mode,cx	 ; сохранить в области данных
 	call	m16	 	; вывод регистра CX
 	jmp	short video_return

m16:
 	mov	dx,addr_6845	; адрес регистра
 	mov	al,ah	 	; получить значение
 	out	dx,al	 	; установить регистр
 	inc	dx	 	; регистр данных
 	mov	al,ch	 	; данные
 	out	dx,al
 	dec	dx
 	mov	al,ah
 	inc	al	 	; указать другой регистр данных
 	out	dx,al	 	; установить второй регистр
 	inc	dx
 	mov	al,cl	 	; второе значение данных
 	out	dx,al
 	ret	 	 	; возврат
set_ctype	endp
;----------------------------
; set_cpos
;
;   Установить текущую позицию курсора
;
;   ВХОД
;	   DX - строка, колонка,
;	   BH - номер страницы.
;
;-----------------------------
set_cpos proc	near
 	mov	cl,bh
 	xor	ch,ch	 	; установить счетчик
 	sal	cx,1	 	; сдвиг слова
 	mov	si,cx
 	mov word ptr [si + offset cursor_posn],dx  ;сохранить указатель
 	cmp	active_page,bh
 	jnz	m17
 	mov	ax,dx	 	; получить строку/колонку в AX
 	call	m18	 	; установить курсор
m17:
 	jmp	short video_return  ; возврат
set_cpos	endp

;   Установить позицию курсора, AX содержит  строку/колонку

m18	proc	near
 	call	position
 	mov	cx,ax
 	add	cx,crt_start	; сложить с начальным адресом страницы
 	sar	cx,1	 	; делить на 2
 	mov	ah,14
 	call	m16
 	ret
m18	endp
;---------------------------
; read_cursor
;
;   Считать текущее положение курсора
;
;   Эта программа восстанавливает текущее положение курсора
;
;   ВХОД
;	   BH - номер страницы
;
;   ВЫХОД
;	   DX - строка/колонка текущей позиции курсора,
;	   CX - размер курсора и управление им
;
;---------------------------
read_cursor proc near
 	mov	bl,bh
 	xor	bh,bh
 	sal	bx,1
 	mov dx,word ptr [bx+offset cursor_posn]
 	mov	cx,cursor_mode
 	pop	di	 	; восстановить регистры
 	pop	si
 	pop	bx
 	pop	ax
 	pop	ax
 	pop	ds
 	pop	es
 	iret
read_cursor	endp
;-----------------------------
; act_disp_page
;
;    Эта программа устанавливает активную страницу буфера адаптера ЭЛИ
;
;   ВХОД
;	   AL - страница.
;
;   ВЫХОД
;	   Выполняется сброс контроллера для установки новой страницы.
;
;-----------------------------
act_disp_page proc	near
 	mov	active_page,al	; сохранить значение активной страницы
 	mov	cx,crt_len	; получить длину области буфера
 	cbw	 	 	; преобразовать AL
 	push	ax	 	; сохранить значение страницы
 	mul	cx
 	mov	crt_start,ax	; сохранить начальный адрес
 	 	 	 	; для следующего требования
 	mov	cx,ax	 	; переслать начальный адрес в CX
 	sar	cx,1	 	; делить на 2
 	mov	ah,12
 	call	m16
 	pop	bx	 	; восстановить значение страницы
 	sal	bx,1
 	mov ax,word ptr [bx+offset cursor_posn]   ; получить курсор
 	call	m18	 	; установить позицию курсора
 	jmp	video_return
act_disp_page	endp
;------------------------------
; set color
;
;   Эта программа устанавливает цветовую палитру.
;
;   ВХОД
;	   BH=0
;	 	BL - значение пяти младших бит, используемых для выбора
;	 	     цветовой палитры (цвет заднего плана для цветной
;	 	     графики 320х200 или цвет каймы для цветного 40х25)
;	   BH=1
;	 	BL - номер цветовой палитры
;	 	     BL=0 - зеленый(1), красный(2), желтый(3),
;	 	     BL=1 - голубой(1), фиолетовый(2), белый (3)
;
;   ВЫХОД
;	   Установленная цветовая палитра в порту 3D9.
;------------------------------
set_color proc	near
 	mov	dx,addr_6845	; порт для палитры
 	add	dx,5	 	; установить порт
 	mov	al,crt_pallette   ; получить текущее значение палитры
 	or	bh,bh	 	; цвет 0 ?
 	jnz	m20	 	; вывод цвета 1

;   Обработка цветовой палитры 0

 	and	al,0e0h 	; сбросить 5 младших бит
 	and	bl,01fh 	; сбросить 3 старших бита
 	or	al,bl
m19:
 	out	dx,al	 	 ; вывод выбранного цвета в порт 3D9
 	mov	crt_pallette,al  ; сохранить значение цвета
 	jmp	video_return

;   Обработка цветовой палитры 1

m20:
 	and	al,0dfh 	;
 	shr	bl,1	 	; проверить младший бит BL
 	jnc	m19
 	or	al,20h	 	;
 	jmp	short m19	; переход
set_color	endp
;--------------------------
; video state
;
;   Эта программа получает текущее состояние ЭЛИ в AX.
;
;	   AH - количество колонок,
;	   AL - текущий режим,
;	   BH - номер активной страницы.
;
;---------------------------
video_state proc	near
 	mov	ah,byte ptr crt_cols   ; получить количество колонок
 	mov	al,crt_mode	 	; текущий режим
 	mov	bh,active_page	; получить текущую активную страницу
 	pop	di	 	; восстановить регистры
 	pop	si
 	pop	cx
 	jmp	m15	 	; возврат к программе
video_state	endp
;---------------------------
; position
;
;   Эта программа вычисляет адрес буфера символа в режиме альфа.
;
;   ВХОД
;	   AX - номер строки, номер колонки,
;
;   ВЫХОД
;	   AX - смещение символа с координатами (AH, AL) относительно
;	 	начала страницы. Смещение измеряется в байтах.
;
;----------------------------
position proc	near
 	push	bx	 	; сохранить регистр
 	mov	bx,ax
 	mov	al,ah	 	; строки в AL
 	mul	byte ptr crt_cols
 	xor	bh,bh
 	add	ax,bx	 	; добавить к значению колонки
 	sal	ax,1	 	; * 2 для байтов атрибута
 	pop	bx
 	ret
position	endp
;-------------------------------
;scroll up
;
;   Эта программа перемещает блок символов вверх по экрану.
;
;   ВХОД
;	   AH - текуший режим,
;	   AL - количество перемещаемых строк
;	   CX - координаты левого верхнего угла блока
;	 	(строка, колонка),
;	   DX - координаты правого нижнего угла
;	   BH - атрибут символа пробела (для опробеливания освобожда-
;	 	емых строк),
;
;   ВЫХОД
;	   Модифицированный буфер дисплея.
;
;-----------------------------------
 	assume cs:code,ds:data,es:data
scroll_up proc	near
 	mov	bl,al	    ; сохранить количество перемещаемых строк
 	cmp	ah,4	 	; проверка графического режима
 	jc	n1
 	cmp	ah,7	 	; проверка ч/б адаптера
 	je	n1
 	jmp	graphics_up
n1:
 	push	bx	 	; сохранить полный атрибут в BH
 	mov	ax,cx	 	; координаты левого верхнего угла
 	call	scroll_position
 	jz	n7
 	add	si,ax
 	mov	ah,dh	 	; строка
 	sub	ah,bl
n2:
 	call	n10	 	; сдвинуть одну строку
 	add	si,bp
 	add	di,bp	 	; указать на следующую строку в блоке
 	dec	ah	 	; счетчик строк для сдвига
 	jnz	n2	 	; цикл строки
n3:	 	 	 	; очистка входа
 	pop	ax	 	; восстановить атрибут в AH
 	mov	al,' '          ; заполнить пробелами
n4:	 	 	 	; очистка счетчика
 	call	n11	 	; очистка строки
 	add	di,bp	 	; указать следующую строку
 	dec	bl	 	; счетчик строк для сдвига
 	jnz	n4	 	; очистка счетчика
n5:	 	 	 	; конец сдвига
 	mov	ax,dat
 	mov	ds,ax
 	cmp	crt_mode,7	; ч/б адаптер ?
 	je	n6	 	; если да - пропуск режима сброса
 	mov	al,crt_mode_set
 	mov	dx,03d8h	; установить порт цветного адаптера
 	out	dx,al
n6:
 	jmp	video_return
n7:
 	mov	bl,dh
 	jmp	short n3	; очистить
scroll_up	endp

;   Обработка сдвига

scroll_position proc	near
 	cmp	crt_mode,2
 	jb	n9	 	; обработать 80х25 отдельно
 	cmp	crt_mode,3
 	ja	n9

;   Сдиг для цветного адаптера в режиме 80х25

 	push	dx
 	mov	dx,3dah 	; обработка цветного адаптера
 	push	ax
n8:	 	 	 	; ожидание доступности дисплея
 	in	al,dx
 	test	al,8
 	jz	n8	 	; ожидание доступности дисплея
 	mov	al,25h
 	mov	dx,03d8h
 	out	dx,al	 	; выключить ЭЛИ
 	pop	ax
 	pop	dx
n9:	call	position
 	add	ax,crt_start	; смещение активной страницы
 	mov	di,ax	 	; для адреса сдвига
 	mov	si,ax
 	sub	dx,cx	 	; DX=строка
 	inc	dh
 	inc	dl	 	; прибавление к началу
 	xor	ch,ch	 	; установить старший байт счетчика в 0
 	mov	bp,crt_cols	; получить число колонок дисплея
 	add	bp,bp	 	; увеличить на 2 байт атрибута
 	mov	al,bl	 	; получить счетчик строки
 	mul	byte ptr crt_cols   ; определить смещение из адреса,
 	add	ax,ax	  ; умноженного на 2, для байта атрибута
 	push	es	; установить адресацию для области буфера
 	pop	ds
 	cmp	bl,0	 	; 0 означает очистку блока
 	ret	 	 	; возврат с установкой флажков
scroll_position endp

;   Перемещение строки

n10	proc	near
 	mov	cl,dl	 	; получить колонки для передачи
 	push	si
 	push	di	 	; сохранить начальный адрес
 	rep	movsw	 	; передать эту строку на экран
 	pop	di
 	pop	si	 	; восстановить адресацию
 	ret
n10	endp

;   очистка строки

n11	proc	near
 	mov	cl,dl	 	; получить колонки для очистки
 	push	di
 	rep	stosw	 	; запомнить полный знак
 	pop	di
 	ret
n11	endp
;------------------------
; scroll_down
;
;   Эта программа перемещает блок символов вниз по
; экрану, заполняя верхние строки пробелом с заданным атрибутом
;
;   ВХОД
;	   AH - текущий режим,
;	   AL - количество строк,
;	   CX - верхний левый угол блока,
;	   DX - правый нижний угол блока,
;	   BH - атрибут символа-заполнителя (пробела),
;
;-------------------------
scroll_down proc near
 	std	 	 	; уст направление сдвига вниз
 	mov	bl,al	 	; количество строк в BL
 	cmp	ah,4	 	; проверка графики
 	jc	n12
 	cmp	ah,7	 	; проверка ч/б адаптера
 	je	n12
 	jmp	graphics_down
n12:
 	push	bx	 	; сохранить атрибут в BH
 	mov	ax,dx	 	; нижний правый угол
 	call	scroll_position
 	jz	n16
 	sub	si,ax	 	; SI для адресации
 	mov	ah,dh
 	sub	ah,bl	 	; передать количество строк
n13:
 	call	n10	 	; передать одну строку
 	sub	si,bp
 	sub	di,bp
 	dec	ah
 	jnz	n13
n14:
 	pop	ax	 	; восстановить атрибут в AH
 	mov	al,' '
n15:
 	call	n11	 	; очистка одной строки
 	sub	di,bp	 	; перейти к следующей строке
 	dec	bl
 	jnz	n15
 	jmp	n5	 	; конец сдвига
n16:
 	mov	bl,dh
 	jmp	short n14
scroll_down  endp
;--------------------
; read_ac_current
;
;   Эта программа считывает атрибут и код символа, находящегося в теку-
; щем положении курсора
;
;   ВХОД
;	   AH - текущий режим,
;	   BH - номер страницы (только для режима альфа),
;
;   ВЫХОД
;	   AL - код символа,
;	   AH - атрибут символа.
;
;---------------------
 	assume cs:code,ds:data,es:data
read_ac_current proc near
 	cmp	ah,4	 	; это графика ?
 	jc	p1
 	cmp	ah,7	 	; ч/б адаптер ?
 	je	p1
 	jmp	graphics_read
p1:	 	 	 	;
 	call	find_position
 	mov	si,bx	 	; установить адресацию в SI


 	mov	dx,addr_6845	; получить базовый адрес
 	add	dx,6	 	; порт состояния
 	push	es
 	pop	ds	 	; получить сегмент
p2:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jnz	p2	 	; ожидание
 	cli	 	   ; сброс признака разрешения прерывания
p3:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jz	p3	 	; ожидание
 	lodsw	 	 	; получить символ/атрибут
 	jmp	video_return
read_ac_current endp

find_position proc near
 	mov	cl,bh	 	; поместить страницу в CX
 	xor	ch,ch
 	mov	si,cx	 	; передать в SI индекс, умноженный на 2
 	sal	si,1	 	; для слова смещения
 	mov ax,word ptr [si+offset cursor_posn]   ; получить строку/ко-
 	 	 	 	; лонку этой страницы
 	xor	bx,bx	 	; установить начальный адрес в 0
 	jcxz	p5
p4:
 	add	bx,crt_len	; длина буфера
 	loop	p4
p5:
 	call	position
 	add	bx,ax
 	ret
find_position	endp
;---------------------
;write_ac_current
;
;   Эта программа записывает атрибут и код символа в текущую позицию
; курсора
;
;   ВХОД
;	   AH - текущий режим,
;	   BH - номер страницы,
;	   CX - счетчик (количество повторений символов),
;	   AL - код символа,
;	   BL - атрибут символа (для режимов альфа) или цвет символа
;	 	для графики.
;
;----------------------
write_ac_current proc near
 	cmp	ah,4	 	; это графика ?
 	jc	p6
 	cmp	ah,7	 	; это ч/б адаптер ?
 	je	p6
 	jmp	graphics_write
p6:
 	mov	ah,bl	 	; получить атрибут в AH
 	push	ax	 	; хранить
 	push	cx	 	; хранить счетчик
 	call	find_position
 	mov	di,bx	 	; адрес в DI
 	pop	cx	 	; вернуть счетчик
 	pop	bx	 	; и символ
p7:	 	 	 	; цикл записи


 	mov	dx,addr_6845	; получить базовый адрес
 	add	dx,6	 	; указать порт состояния
p8:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jnz	p8	 	; ожидать
 	cli	 	     ; сброс признака разрешения прерывания
p9:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jz	p9	 	; ожидать
 	mov	ax,bx
 	stosw	 	 	; записать символ и атрибут
 	sti	 	 	; уст признак разрешения прерывания
 	loop	p7
 	jmp	video_return
write_ac_current  endp
;---------------------
;write_c_current
;
;   Эта программа записывает символ в текущую позицию курсора.
;
;   ВХОД
;	   BH - номер страницы (только для альфа режимов),
;	   CX - счетчик (количество повторений символа),
;	   AL - код символа,
;
;-----------------------
write_c_current proc near
 	cmp	ah,4	 	; это графика ?
 	jc	p10
 	cmp	ah,7	 	; это ч/б адаптер ?
 	je	p10
 	jmp	graphics_write
p10:
 	push	ax	 	; сохранить в стеке
 	push	cx	 	; сохранить количество повторений
 	call	find_position
 	mov	di,bx	 	; адрес в DI
 	pop	cx	 	; вернуть количество повторений
 	pop	bx	 	; BL - код символа
p11:


 	mov	dx,addr_6845	; получить базовый адрес
 	add	dx,6	 	; указать порт состояния
p12:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jnz	p12	 	; ожидать
 	cli	 	 	; сброс признака разрешения прерывания
p13:
 	in	al,dx	 	; получить состояние
 	test	al,1
 	jz	p13	 	; ожидание
 	mov	al,bl	 	; восстановить символ
 	stosb	 	 	; записать символ
 	inc	di
 	loop	p11	 	; цикл
 	jmp	video_return
write_c_current endp
;---------------------
; read dot - write dot
;
;   Эта программа считывает/записывает точку.
;
;   ВХОД
;	   DX - строка (0-199),
;	   CX - колонка (0-639),
;	   AL - цвет выводимой точки.
;	 	Если бит 7=1, то выполняется операция
;	 	XOR над значением точки из буфера дисплея и значением
;	 	точки из регистра AL (при записи точки).
;
;   ВЫХОД
;	   AL - значение считанной точки
;
;----------------------
 	assume cs:code,ds:data,es:data
read_dot proc	near
 	call	r3	 	; определить положение точки
 	mov	al,es:[si]	; получить байт
 	and	al,ah	 	; размаскировать другие биты в байте
 	shl	al,cl	 	;
 	mov	cl,dh	 	; получить число бит результата
 	rol	al,cl
 	jmp	video_return	; выход из прерывания
read_dot	endp

write_dot proc	near
 	push	ax	 	; сохранить значение точки
 	push	ax	 	; еще раз
 	call	r3	 	; определить положение точки
 	shr	al,cl	 	; сдвиг для установки бит при выводе
 	and	al,ah	 	; сбросить другие биты
 	mov	cl,es:[si]	; получить текущий байт
 	pop	bx
 	test	bl,80h
 	jnz	r2
 	not	ah	  ; установить маску для передачи указанных бит
 	and	cl,ah
 	or	al,cl
r1:
 	mov es:[si],al	 	; восстановить байт в памяти
 	pop	ax
 	jmp	video_return	; к выходу из программы
r2:
 	xor	al,cl	 	; исключающее ИЛИ над значениями точки
 	jmp	short r1	; конец записи
write_dot	endp

;-------------------------------------
;
;   Эта программа определяет относительный адрес байта (внутри буфера
; дисплея), из которого должна быть считана/записана точка,с заданными
; координатами.
;
;   ВХОД
;	   DX - строка (0-199),
;	   CX - колонка (0-639).
;
;   ВЫХОД
;	   SI - относительный адрес байта, содержащего точку внутри
;	 	буфера дисплея,
;	   AH - маска для выделения значения заданной точки внутри байта
;	   CL - константа сдвига маски в AH в крайнюю левую позицию,
;	   DH - число бит, определяющих значение точки.
;
;--------------------------------------

r3	proc	near
 	push	bx	 	; сохранить BX
 	push	ax	 	; сохранить AL

;   Вычисление первого байта указанной строки умножением на 40.
; Наименьший бит строки определяет четно/нечетную 80-байтовую строку.

 	mov	al,40
 	push	dx	 	; сохранить значение строки
 	and	dl,0feh 	; сброс четно/нечетного бита
 	mul	dl   ; AX содержит адрес первого байта указанной строки
 	pop	dx	 	; восстановить его
 	test	dl,1	 	; проверить четность/нечетность
 	jz	r4	 	; переход,если строка четная
 	add	ax,2000h	; смещение для нахождения нечетных строк
r4:	 	 	 	; четная строка
 	mov	si,ax	 	; передать указатель в SI
 	pop	ax	 	; восстановить значение AL
 	mov	dx,cx	 	; значение колонки в DX

;   Определение действительных графических режимов
;
;   Установка регистров согласно режимaм
;
;	  BH - количество бит, определяющее точку,
;	  BL - константа выделения точки из левых бит байта,
;	  CH - константа для выделения из номера колонки номера позиции
;	       первого бита, определяющего точку в байте, т.е. получение
;	       остатка от деления номера на 8 (для режима 640х200) или
;	       номера на 4 (для режима 320х200),
;	  CL - константа сдвига (для выполнения деления на 8 или на 4).

 	mov	bx,2c0h
 	mov	cx,302h 	; установка параметров
 	cmp	crt_mode,6
 	jc	r5	 	;
 	mov	bx,180h
 	mov	cx,703h 	; уст параметры для старшего регистра

;   Определение бита смещения в байте по маске
r5:
 	and	ch,dl	 	;

;   Определение байта смещения в колонке

 	shr	dx,cl	 	; сдвиг для коррекции
 	add	si,dx	 	; получить указатель
 	mov	dh,bh	; получить указатель битов результата в DH

;   Умножение BH (количество бит в байте) на CH (бит смещения)

 	sub	cl,cl
r6:
 	ror	al,1	; левое крайнее значение в AL для записи
 	add	cl,ch	 	; прибавить значение бита смещения
 	dec	bh	 	; счетчик контроля
 	jnz	r6	; на выходе CL содержит счетчик сдвига для
 	 	 	 	; восстановления
 	mov	ah,bl	 	; получить маску в AH
 	shr	ah,cl	 	; передать маску в ячейку
 	pop	bx	 	; восстановить регистр
 	ret	 	 	; возврат с восстановлением
r3	endp

;----------------------------------------
;
;
;    Программа перемещает блок символов вверх в режиме графики
;
;-----------------------------------------

graphics_up proc near
 	mov	bl,al	 	; сохранить количество символов
 	mov	ax,cx	 	; получить верхний левый угол в AX


 	call	graph_posn
 	mov	di,ax	 	; сохранить результат

;   Определить размеры блока

 	sub	dx,cx
 	add	dx,101h
 	sal	dh,1
 	sal	dh,1

 	cmp	crt_mode,6
 	jnc	r7

 	sal	dl,1
 	sal	di,1	 	;

;   Определение адреса источника в буфере
r7:
 	push	es
 	pop	ds
 	sub	ch,ch	 	; обнулить старший байт счетчика
 	sal	bl,1	 	; умножение числа строк на 4
 	sal	bl,1
 	jz	r11	 	; если 0, занести пробелы
 	mov	al,bl	 	; получить число строк в AL
 	mov	ah,80	 	; 80 байт/строк
 	mul	ah	 	; определить смещение источника
 	mov	si,di	 	; установить источник
 	add	si,ax	 	; сложить источник с ним
 	mov	ah,dh	 	; количество строк
 	sub	ah,bl	 	; определить число перемещений

r8:
 	call	r17	 	; перемещение одной строки
 	sub	si,2000h-80	; перемещение в следующую строку
 	sub	di,2000h-80
 	dec	ah	 	; количество строк для перемещения
 	jnz	r8	; продолжать, пока все строки не переместятся

;   Заполнение освобожденных строк
r9:
 	mov	al,bh
r10:
 	call	r18	 	; очистить эту строку
 	sub	di,2000h-80	; указать на следующую
 	dec	bl	 	; количество строк для заполнения
 	jnz	r10	 	; цикл очистки
 	jmp	video_return	; к выходу из программы

r11:
 	mov	bl,dh	 	; установить количество пробелов
 	jmp	short r9	; очистить
graphics_up	endp

;---------------------------------
;
;   Программа перемещает блок символов вниз в режиме графики
;
;----------------------------------

graphics_down proc	near
 	std	 	 	; установить направление
 	mov	bl,al	 	; сохранить количество строк
 	mov	ax,dx	 	; получить нижнюю правую позицию в AX


 	call	graph_posn
 	mov	di,ax	 	; сохранить результат

;   Определение размера блока

 	sub	dx,cx
 	add	dx,101h
 	sal	dh,1
 	sal	dh,1


 	cmp	crt_mode,6
 	jnc	r12

 	sal	dl,1
 	sal	di,1
 	inc	di

;   Определение адреса источника в буфере
r12:
 	push	es
 	pop	ds
 	sub	ch,ch	 	; обнулить старший байт счетчика
 	add	di,240	 	; указать последнюю строку
 	sal	bl,1	 	; умножить количество строк на 4
 	sal	bl,1
 	jz	r16	 	; если 0, заполнить пробелом
 	mov	al,bl	 	; получить количество строк в AL
 	mov	ah,80	 	; 80 байт/строк
 	mul	ah	 	; определить смещение источника
 	mov	si,di	 	; установить источник
 	sub	si,ax	 	; вычесть смещение
 	mov	ah,dh	 	; количество строк
 	sub	ah,bl	 	; определить число для перемещения

r13:
 	call	r17	 	; переместить одну строку
 	sub	si,2000h+80	; установить следующую строку
 	sub	di,2000h+80
 	dec	ah	 	; количество строк для перемещения
 	jnz	r13	 	; продолжать, пока все не переместятся

;   Заполнение освобожденных строк
r14:
 	mov	al,bh	 	; атрибут заполнения
r15:
 	call	r18	 	; очистить строку
 	sub	di,2000h+80	; указать следующую строку
 	dec	bl	 	; число строк для заполнения
 	jnz	r15
 	cld	 	 	; сброс признака направления
 	jmp	video_return	; к выходу из программы

r16:
 	mov	bl,dh
 	jmp	short r14	; очистить
graphics_down endp

;   Программа перемещения одной строки

r17	proc	near
 	mov	cl,dl	 	; число байт в строке
 	push	si
 	push	di	 	; хранить указатели
 	rep	movsb	 	; переместить четное поле
 	pop	di
 	pop	si
 	add	si,2000h
 	add	di,2000h	; указать нечетное поле
 	push	si
 	push	di	 	; сохранить указатели
 	mov	cl,dl	 	; возврат счвтчика
 	rep	movsb	 	; передать нечетное поле
 	pop	di
 	pop	si	 	; возврат указателей
 	ret	 	 	; возврат к программе
r17	endp

;   Заполнение пробелами строки

r18	proc	near
 	mov	cl,dl	 	; число байт в поле
 	push	di	 	; хранить указатель
 	rep	stosb	 	; запомнить новое значение
 	pop	di	 	; вернуть указатель
 	add	di,2000h	; указать нечетное поле
 	push	di
 	mov	cl,dl
 	rep	stosb	 	; заполнить нечетное поле
 	pop	di
 	ret	 	 	; возврат к программе
r18	endp

;--------------------------------------
;
;  graphics_write
;
;   Эта программа записывает символ в режиме графики
;
;   ВХОД
;	   AL - код символа,
;	   BL - атрибут цвета, который используется в качестве цвета
;	 	переднего плана (цвет символа). Если бит 7 BL=1, то
;	 	выполняется операция XOR над байтом в буфере и байтом
;	 	в генераторе символов,
;	   CX - счетчик повторений символа
;
;----------------------------------------

 	assume cs:code,ds:data,es:data
graphics_write proc near
 	mov	ah,0	 	; AH=0
 	push	ax	 	; сохранить значение кода символа

;   Определение позиции в области буфера засылкой туда кода точек

 	call	s26	 	; найти ячейку в области буфера
 	mov	di,ax	 	; указатель области в DI

;   Определение области для получения кода точки

 	pop	ax	 	; восстановить код точки
 	cmp	al,80h	 	; во второй половине ?
 	jae	s1	 	; да

;   Изображение есть в первой половине памяти

 	mov	si, offset crt_char_gen  ; смещение изображения
 	push	cs	 	; хранить сегмент в стеке
 	jmp	short s2	; определить режим

;   Изображение есть во второй части памяти

s1:
 	sub	al,80h	 	; 0 во вторую половину
 	push	ds	 	; хранить указатель данных
 	sub	si,si
 	mov	ds,si	 	; установить адресацию
 	assume	ds:abs0
 	lds	si,ext_ptr	; получить смещение
 	mov	dx,ds	 	; получить сегмент
 	assume	ds:data
 	pop	ds	 	; восстановить сегмент данных
 	push	dx	 	; хранить сегмент в стеке

;   Опеделение графического режима операции

s2:	 	 	 	; определение режима
 	sal	ax,1	 	; умножить указатель кода на 8
 	sal	ax,1
 	sal	ax,1
 	add	si,ax	 	; SI содержит смещение
 	cmp	crt_mode,6
 	pop	ds	 	; восстановить указатель таблицы
 	jc	s7	; проверка для средней разрешающей способности

;   Высокая разрешающая способность
s3:
 	push	di	 	; сохранить указатель области
 	push	si	 	; сохранить указатель кода
 	mov	dh,4	 	; количество циклов
s4:
 	lodsb	 	 	; выборка четного байта
 	test	bl,80h
 	jnz	s6
 	stosb
 	lodsb
s5:
 	mov es:[di+1fffh],al	; запомнить во второй части
 	add	di,79	 	; передать следующую строку
 	dec	dh	 	; выполнить цикл
 	jnz	s4
 	pop	si
 	pop	di	 	; восстановить указатель области
 	inc	di	; указать на следующую позицию символа
 	loop	s3	 	; записать последующие символы
 	jmp	video_return

s6:
 	xor al,es:[di]
 	stosb	 	 	; запомнить код
 	lodsb	 	 	; выборка нечетного символа
 	xor  al,es:[di+1fffh]
 	jmp	s5	 	; повторить

;   Средняя разрешающая способность записи
s7:
 	mov	dl,bl	 	; сохранить старший бит цвета
 	sal	di,1	; умножить на 2, т.к. два байта/символа
 	call	s19	 	; расширение BL до полного слова цвета
s8:
 	push	di
 	push	si
 	mov	dh,4	 	; число циклов
s9:
 	lodsb	 	 	; получить код точки
 	call	s21	 	; продублировать
 	and	ax,bx	 	; окрашивание в заданный цвет
 	test	dl,80h
 	jz	s10
 	xor	ah,es:[di]	; выполнить функцию XOR со "старым"
 	xor	al,es:[di+1]	; и "новым" цветами
s10:	mov  es:[di],ah 	; запомнить первый байт
 	mov es:[di+1],al	; запомнить второй байт
 	lodsb	 	 	; получить код точки
 	call	s21
 	and	ax,bx	 	; окрашивание нечетного байта
 	test	dl,80h
 	jz  s11
 	xor	ah,es:[di+2000h]   ; из первой половины
 	xor	al,es:[di+2001h]   ; и из второй половины
s11:	mov	es:[di+2000h],ah
 	mov	es:[di+2001h],al   ; запомнить вторую часть буфера
 	add	di,80	 	; указать следующую ячейку
 	dec	dh
 	jnz	s9	 	; повторить
 	pop	si
 	pop	di
 	add	di,2	 	; переход к следующему символу
 	loop	s8	 	; режим записи
 	jmp	video_return
graphics_write	endp
;-------------------------------------
;graphics_read
;
;   Программа считывает символ в режиме графики
;
;-------------------------------------
graphics_read	proc	near
 	call	s26
 	mov	si,ax	 	; сохранить в SI
 	sub	sp,8	 	; зарезервировать в стеке 8 байт для
 	 	 	 	; записи символа из буфера дисплея
 	mov	bp,sp	 	; указатель для хранения области

;   Определение режима графики

 	cmp	crt_mode,6
 	push	es
 	pop	ds	 	; указать сегмент
 	jc	s13	 	; средняя разрешающая способность

;  Высокая разрешающая способность для считавания

 	mov	dh,4
s12:
 	mov	al,byte ptr [si]   ; получить первый байт
 	mov byte ptr [bp],al	   ; запомнить в памяти
 	inc	bp
 	mov al,byte ptr [si+2000h]   ; получить младший байт
 	mov byte ptr [bp],al
 	inc	bp
 	add	si,80	 	; переход на следующую четную строку
 	dec	dh
 	jnz	s12	 	; повторить
 	jmp	short s15 	; переход к хранению кодов точек
	nop

;   Средняя разрешающая способность для считывания
s13:
 	sal	si,1	  ; смещение умножить на 2, т.к. 2 байта/символа
 	mov	dh,4
s14:
 	call	s23
 	add	si,2000h
 	call	s23
 	sub	si,2000h-80
 	dec	dh
 	jnz	s14	 	; повторить

;   Сохранить
s15:
 	mov	di,offset crt_char_gen	 ; смещение
 	push	cs
 	pop	es
 	sub	bp,8	 	; восстановить начальный адрес
 	mov	si,bp
 	cld	 	 	; установить направление
 	mov	al,0
s16:
 	push	ss
 	pop	ds
 	mov	dx,128	 	; количество символов
s17:
 	push	si
 	push	di
 	mov	cx,8	 	; количество байт в символе
 	repe	cmpsb	 	; сравнить
 	pop	di
 	pop	si
 	jz	s18	 	; если признак = 0,символы сравнились
 	inc	al	 	; не сравнились
 	add	di,8	 	; следующий код точки
 	dec	dx	 	; - 1 из счетчика
 	jnz	s17	 	; повторить


 	cmp	al,0
 	je	s18    ; переход, если все сканировано, но символ
 	 	       ; не найден
 	sub	ax,ax
 	mov	ds,ax	 	; установить адресацию вектора
 	assume	ds:abs0
 	les	di,ext_ptr
 	mov	ax,es
 	or	ax,di
 	jz	s18
 	mov	al,128	 	; начало второй части
 	jmp	short s16	; вернуться и повторить
 	assume	ds:data

s18:
 	add	sp,8
 	jmp	video_return
graphics_read	endp

;---------------------------------
;
;   Эта программа заполняет регистр BX двумя младшими битами
; регистра BL.
;
;   ВХОД
;	   BL - используемый цвет (младшие два бита).
;
;   ВЫХОД
;	   BX - используемый цвет (восемь повторений двух битов цвета).
;
;---------------------------------
s19	proc	near
 	and	bl,3	 	; выделить биты цвета
 	mov	al,bl	 	; переписать в AL
 	push	cx	 	; сохранить регистр
 	mov	cx,3	 	; количество повторений
s20:
 	sal	al,1
 	sal	al,1	 	; сдвиг влево на 2
 	or	bl,al	 	; в BL накапливается результат
 	loop	s20	 	; цикл
 	mov	bh,bl	 	; заполнить
 	pop	cx
 	ret	 	 	; все выполнено
s19	endp
;--------------------------------------
;
;   Эта программа берет байт в AL и удваивает все биты, превращая
; 8 бит в 16 бит. Результат помещается в AX.
;--------------------------------------
s21	proc	near
 	push	dx	 	; сохранить регистры
 	push	cx
 	push	bx
 	mov	dx,0	 	; результат удвоения
 	mov	cx,1	 	; маска
s22:
 	mov	bx,ax
 	and	bx,cx	 	; выделение бита
 	or	dx,bx	 	; накапливание результата
 	shl	ax,1
 	shl	cx,1	 	; сдвинуть базу и маску на 1
 	mov	bx,ax
 	and	bx,cx
 	or	dx,bx
 	shl	cx,1	; сдиг маски, для выделения следующего бита
 	jnc	s22
 	mov	ax,dx
 	pop	bx	 	; восстановить регистры
 	pop	cx
 	pop	dx
 	ret	 	 	; к выходу из прерывания
s21	endp

;----------------------------------
;
;   Эта программа преобразовывает двух-битовое представление точки
; (C1,C0) в однобитовое
; (C1,C0) к однобитовому.
;
;----------------------------------
s23	proc	near
 	mov	ah,byte ptr [si]   ; получить первый байт
 	mov	al,byte ptr [si+1]   ; получить второй байт
 	mov	cx,0c000h	; 2 бита маски
 	mov	dl,0	 	; регистр результата
s24:
 	test	ax,cx	 	; проверка 2 младших бит AX на 0
 	clc	 	 	; сбросить признак переноса CF
 	jz	s25	 	; переход если 0
 	stc	 	 	; нет - установить CF
s25:	rcl	dl,1	 	; циклический сдвиг
 	shr	cx,1
 	shr	cx,1
 	jnc	s24	 	; повторить, если CF=1
 	mov byte ptr [bp],dl	; запомнить результат
 	inc	bp
 	ret	 	 	; к выходу из прерывания
s23	endp

;---------------------------------------
;
;   Эта программа определает положение курсора относительно	 мяти и
; начала буфера в режиме графики	 	 	 	 /символ
;
;   ВЫХОД
;	   AX  содержит смещение курсора
;
;-----------------------------------------
s26	proc	near
 	mov	ax,cursor_posn	; получить текущее положение курсора
graph_posn	label	near
 	push	bx	 	; сохранить регистр
 	mov	bx,ax	 	; сохранить текущее положение курсора
 	mov	al,ah	 	; строка
 	mul	byte ptr crt_cols   ; умножить на байт/колонку
 	shl	ax,1	 	; умножить на 4
 	shl	ax,1
 	sub	bh,bh	 	; выделить значение колонки
 	add	ax,bx	 	; определить смещение
 	pop	bx
 	ret	 	 	; к выходу из прерывания
s26	endp

;----------------------------------------
;
;   Записать телетайп (INT 10H, AH=14)
;
;   Эта программа выводит символ в буфер ЭЛИ с одновременной уста-
; новкой позиции курсора и передвижением курсора на экране.
;   После записи символа в последнюю позицию строки выполняется ав-
; томатический переход на новую строку. Если страница экрана за-
; полнена (позиция курсора 24,79/39), выполняется перемещение экрана
; на одну строку вверх. Освободившаяся строка заполняется значением
; атрибута символа (для алфавитно-цифрового режима). Для графики цвет=00
; После записи очередного символа курсор установлен в следующую позицию.
;
;   ВХОД
;	   AL - код выводимого символа,
;	   BL - цвет переднего плана для графики.
;
;----------------------------------------

 	assume	cs:code,ds:data
write_tty	proc	near
 	push	ax	 	; сохранить регистры
 	push	ax
 	mov	ah,3
 	int	10h	 	; считать положение текущего курсора
 	pop	ax	 	; восстановить символ

;   DX содержит текущую позицию курсора

 	cmp	al,8	 	; есть возврат на одну позицию ?
 	je	u8	 	; возврат на одну позицию
 	cmp	al,0dh	 	; есть возврат каретки ?
 	je	u9	 	; возврат каретки
 	cmp	al,0ah	 	; есть граница поля ?
 	je	u10	 	; граница поля
 	cmp	al,07h	 	; звуковой сигнал ?
 	je	u11	 	; звуковой сигнал

;   Запись символа на экран

 	mov	bh,active_page
 	mov	ah,10	 	; запись символа без атрибута
 	mov	cx,1
 	int	10h

;   Положение курсора для следующего символа

 	inc	dl
 	cmp	dl,byte ptr crt_cols
 	jnz	u7	 	; переход к установке курсора
 	mov	dl,0
 	cmp	dh,24	 	; проверка граничной строки
 	jnz	u6	 	; установить курсор

;   Сдвиг экрана
u1:

 	mov	ah,2
 	mov	bh,0
 	int	10h	 	; установить курсор


 	mov	al,crt_mode	; получить текущий режим
 	cmp	al,4
 	jc	u2	 	; считывание курсора
 	cmp	al,7
 	mov	bh,0	 	; цвет заднего плана
 	jne	u3

u2:	 	 	 	; считывание курсора
 	mov	ah,8
 	int	10h	   ; считать символ/атрибут текущего курсора
 	mov	bh,ah	 	; запомнить в BH

;   Перемещение экрана на одну строку вверх

u3:
 	mov	ax,601h
 	mov	cx,0	 	; верхний левый угол
 	mov	dh,24	 	; координаты нижнего правого
 	mov	dl,byte ptr crt_cols	; угла
 	dec	dl
u4:
 	int	10h

;   Выход из прерывания

u5:
 	pop	ax	 	; восстановить символ
 	jmp	video_return	; возврат к программе

u6:	 	 	 	; установить курсор
 	inc	dh	 	; следующая строка
u7:	 	 	 	; установить курсор
 	mov	ah,2
 	jmp	short u4	; установить новый курсор

;   Сдвиг курсора на одну позицию влево

u8:
 	cmp	dl,0
 	je	u7	 	; установить курсор
 	dec	dl	 	; нет - снова его передать
 	jmp	short u7

;   Перемещение курсора в начало строки

u9:
 	mov	dl,0
 	jmp	short u7	; установить курсор

;   Перемещение курсора на следующую строку

u10:
 	cmp	dh,24	 	; последняя строка экрана
 	jne	u6	 	; да - сдвиг экрана
 	jmp	short u1	; нет - снова установить курсор

;   Звуковой сигнал

u11:
 	mov	bl,2	 	; уст длительность звукового сигнала
 	call	beep	 	; звук
 	jmp	short u5	; возврат
write_tty	endp

;
;----------------------------------------
;
;   Эта программа считывает положение светового пера.
; Проверяется переключатель и триггер светового пера. Если бит 1 ре-
; гистра состояния (порт 3DA)=1, то триггер установлен. Если бит 2 порта
; 3DA=0, то установлен переключатель.
;   Порты 3BD и 3DC используются для установки и сброса триггера и пере-
; ключателя светового пера.
;   В регистрах R16 и R17 контроллера содержится адрес координат пера
; относительно начала буфера дисплея.
;   Если триггер и переключатель установлены, то программа определяет
; положение светового пера, в противном случае, возврат без выдачи
; информации.
;
;   В ППЭВМ ЕС1841 функция не поддерживается
;-------------------------------------------------




 	assume	cs:code,ds:data

;   Таблица поправок для получения фактических координат светового пера

v1	label	byte
 	db	3,3,5,5,3,3,3,4

read_lpen	proc	near


 	mov	ah,0	 	; код возврата, если перо не включено
 	mov	dx,addr_6845	; получить базовый адрес 6845
 	add	dx,6	 	; указать регистр состояния
 	in	al,dx	 	; получить регистр состояния
 	test	al,4	 	; проверить переключатель светового пера
 	jnz	v6	 	; не установлено, возврат

;   Проверка триггера светового пера

 	test	al,2	 	; проверить триггер светового пера
 	jz	v7	 	; возврат без сброса триггера

;   Триггер был установлен, считать значение в AH

 	mov	ah,16	 	; уст регистры светового пера 6845

;   Ввод регистров, указанных AH и преобразование в строки колонки в DX

 	mov	dx,addr_6845
 	mov	al,ah
 	out	dx,al	 	; вывести в порт
 	inc	dx
 	in	al,dx	 	; получить значение из порта
 	mov	ch,al	 	; сохранить его в CX
 	dec	dx	 	; регистр адреса
 	inc	ah
 	mov	al,ah	 	; второй регистр данных
 	out	dx,al
 	inc	dx
 	in	al,dx	 	; получить второе значение данных
 	mov	ah,ch	 	; AX содержит координаты светового пера


 	mov	bl,crt_mode
 	sub	bh,bh	 	; выделить значение режима в BX
 	mov	bl,cs:v1[bx]	; значение поправки
 	sub	ax,bx
 	sub	ax,crt_start

 	jns	v2
 	mov	ax,0	 	; поместить 0

;   Определить режим

v2:
 	mov	cl,3	 	; установить счетчик
 	cmp	crt_mode,4	; определить, режим графики или
 	 	 	 	; альфа
 	jb	v4	 	; альфа-перо
 	cmp	crt_mode,7
 	je	v4	 	; альфа-перо

;   Графический режим

 	mov	dl,40	 	; делитель для графики
 	div	dl	; определение строки (AL) и колонки (AH)
 	 	 	 	; пределы AL 0-99, AH 0-39

;   Определение положения строки для графики

 	mov	ch,al	 	; сохранить значение строки в CH
 	add	ch,ch	 	; умножить на 2 четно/нечетное поле
 	mov	bl,ah	 	; значение колонки в BX
 	sub	bh,bh	 	; умножить на 8 для среднего результата
 	cmp	crt_mode,6	; определить среднюю или наивысшую
 	 	 	 	; разрешающую способность
 	jne	v3	 	; не наивысшая разрешающая способность
 	mov	cl,4	 ; сдвинуть значение наивысшей разрешающей
 	 	 	 ; способности
 	sal	ah,1	; сдвиг на 1 разряд влево значения колонки
v3:	 	 	 	; не наивысшая разрешающая способность
 	shl	bx,cl	; умножить на 16 для наивысшей разрешающей
 	 	 	; способности

;   Определение положения символа для альфа

 	mov	dl,ah	 	; значение колонки для возврата
 	mov	dh,al	 	; значение строки
 	shr	dh,1	 	; делить на 4
 	shr	dh,1	 	; для значения в пределах 0-24
 	jmp	short v5	; возврат светового пера

;   Режим альфа светового пера

v4:	 	 	 	; альфа светового пера
 	div	byte ptr crt_cols  ; строка, колонка
 	mov	dh,al	 	; строка в DH
 	mov	dl,ah	 	; колонка в DL
 	sal	al,cl	 	; умножение строк на 8
 	mov	ch,al
 	mov	bl,ah
 	xor	bh,bh
 	sal	bx,cl
v5:
 	mov	ah,1	 	; указать, что все установлено
v6:
 	push	dx	 	; сохранить значение возврата
 	mov	dx,addr_6845	; получить базовый адрес
 	add	dx,7
 	out	dx,al	 	; вывод
 	pop	dx	 	; восстановить значение
v7:
 	pop	di	 	 ; восстановить регистры
 	pop	si
 	pop	ds
 	pop	ds
 	pop	ds
 	pop	ds
 	pop	es
 	iret
read_lpen	endp

;--- int 12 ------------------------------------
;
;    Программа определения размера памяти.
;
;    Эта программа передает в регистр AX об'ем памяти в Кбайтах.
;
;-----------------------------------------

 	assume	cs:code,ds:data
memory_size_determine	proc	far
 	sti	 	 	; установить бит разрешения прерывания
 	push	ds	 	; сохранить сегмент
 	mov	ax,dat	 	; установить адресацию
 	mov	ds,ax
 	mov	ax,memory_size	; получить значение размера памяти
 	pop	ds	 	; восстановить сегмент
 	iret	 	 	; возврат из прерывания
memory_size_determine	endp

;--- int 11-------------------------------
;
;    Программа определения состава оборудования.
;
;   Эта программа передает в регистр AX конфигурацию системы.
;
;   Разряды регистра AX имеют следующее значение:
;   0	    - загрузка системы с НГМД;
;   5,4     - тип подключенного ЭЛИ и режим его работы:
;	      00 - не используется;
;	      01 - 40х25, черно-белый режим цветного графического
;	 	   ЭЛИ;
;	      10 - 80х25, черно-белый режим цветного графического
;	 	   ЭЛИ;
;	      11 - 80х25, черно-белый режим монохромного ЭЛИ.
;   7,6     - количество НГМД;
;   11,10,9 - количество адаптеров стыка С2;
;   12	    - адаптер игр;
;   15,14   - количество печатающих устройств.
;   Разряды 6 и 7 устанавливаются только в том случае, если
; разряд 0 установлен в "1".
;
;----------------------------------------------

 	assume	cs:code,ds:data
equipment	proc	far
 	sti	 	 	; установить признак разрешения прерывания
 	push	ds	 	; сохранить сегмент
 	mov	ax,dat	 	; установить адресацию
 	mov	ds,ax
 	mov	ax,equip_flag	; получить конфигурацию системы
 	pop	ds	 	; восстановить сегмент
 	iret	 	 	; возврат из прерывания
equipment	endp

;****************************************
;
;   Загрузка знакогенератора
;
;****************************************

bct	proc	near
 	mov	ax,0dc00h
 	mov	es,ax
 	mov	cx,1400h
 	mov	dx,3b8h
 	xor	ax,ax
 	out	dx,al
 	xor	di,di
 	cld
 	rep	stosw
bct3:	mov	si,offset crt_char_gen
 	xor	di,di
 	xor	ax,ax
 	mov	cl,128
bct1:
 	mov	bl,8
bct2:	mov	al,cs:[si]
 	inc	si
 	mov	word ptr es:[di],ax
 	inc	di
 	inc	di
 	dec	bl
 	jnz	bct2
 	add	di,10h
 	dec	cl
		jnz	bct1
		mov	al, 1
		out	dx, al
		mov	ax, 0B800h
		mov	es, ax
		mov	al, 1
		mov	dx, 3DFh
		out	dx, al
		mov	dl, 0D8h
		mov	al, 0
		out	dx, al
		xor	di, di
		mov	cx, 1024
		mov	si, offset crt_char_gen
		xor	di, di
		db	02eh		;cs:  segment prefix (not handled by Turbo Assembler)
		rep movsb
		mov	al, 00001001b
		out	dx, al
		mov	al,0
		mov	dl, 0DFh
		out	dx, al
		ret
bct	endp

org	0f8cbh
;
;   Таблица кодов русских маленьких букв (строчных)
;
rust	label	byte
 	db	1bh,'1234567890-='


 	db	08h,09h
 	db	0d9h,0e6h,0e3h,0dah,0d5h,0ddh,0d3h,0e8h

 	db	0e9h,0d7h,0d6h,0edh,0dh,-1,0e4h,0ebh

 	db	0d2h,0d0h,0dfh,0e0h,0deh,0dbh,0d4h,';:'

 	db	0d1h,0eeh,5ch,0efh,0e7h,0e1h,0dch,0d8h

 	db	0e2h,0ech,',./',0e5h,'*'

 	db	-1,' ',0eah


k30	label	byte
 	db	82,79,80,81,75,76,77

 	db	71,72,73
;---
 	db	16,17,18,19,20,21,22,23

 	db	24,25,30,31,32,33,34,35

 	db	36,37,38,44,45,46,47,48

 	db	49,50

;	Временный обработчик прерываний стыка С2

rs232_io:
		mov	ax, 61F0h
		iret

int15h:
		stc
		mov	ah, 86h
		retf	2

;---
k89:	test	kb_flag,left_shift+right_shift
 	jz	k80
 	cmp	al,0f0h
 	je	k89a
 	cmp	al,0b0h
 	jb	k81
 	cmp	al,0cfh
 	ja	k81
 	add	al,20h
k81:	jmp	k61
k80:	cmp	al,0f1h
 	je	k89b
 	cmp	al,0d0h
 	jb	k81
 	cmp	al,0feh
 	ja	k81
 	sub	al,20h
 	jmp	k61
k89b:	sub	al,01h
 	jmp	k61
k89a:	add	al,01h
 	jmp	k61

write_tty2:
		mov	bh, ds:active_page
		jmp	write_tty

f19a:
		inc	dx
		mov	al, 8
		out	dx, al
		mov	dx, 3FEh
		out	dx, al
		mov	al, 0A4h
		out	inta01,	al
		mov	ax, si
		mov	cl, 3
		jmp	f19b

f20a:
		mov	al, 80h
		out	0A0h, al
		mov	al, 0BCh
		out	21h, al
		jmp	f20b
;
dummm_return:	push	ax
 	 	mov	al,20h
 	 	out	20h,al
 	 	pop	ax
 	 	iret

		db 220 dup(0)
		
;**************************************
;
;   Знакогенератор графический 320х200 и 640х200
;
;***************************************



crt_char_gen  label  byte
 	db	000h,000h,000h,000h,000h,000h,000h,000h ;d_00

 	db	07eh,081h,0a5h,081h,0bdh,099h,081h,07eh ;d_01

 	db	07eh,0ffh,0dbh,0ffh,0c3h,0e7h,0ffh,07eh ;d_02

 	db	06ch,0feh,0feh,0feh,07ch,038h,010h,000h ;d_03

 	db	010h,038h,07ch,0feh,07ch,038h,010h,000h ;d_04

 	db	038h,07ch,038h,0feh,0feh,07ch,038h,07ch ;d_05

 	db	010h,010h,038h,07ch,0feh,07ch,038h,07ch ;d_06

 	db	000h,000h,018h,03ch,03ch,018h,000h,000h ;d_07

 	db	0ffh,0ffh,0e7h,0c3h,0c3h,0e7h,0ffh,0ffh ;d_08

 	db	000h,03ch,066h,042h,042h,066h,03ch,000h ;d_09

 	db	0ffh,0c3h,099h,0bdh,0bdh,099h,0c3h,0ffh ;d_0a

 	db	00fh,007h,00fh,07dh,0cch,0cch,0cch,078h ;d_0b

 	db	03ch,066h,066h,066h,03ch,018h,07eh,018h ;d_0c

 	db	03fh,033h,03fh,030h,030h,070h,0f0h,0e0h ;d_0d

 	db	07fh,063h,07fh,063h,063h,067h,0e6h,0c0h ;d_0e

 	db	099h,05ah,03ch,0e7h,0e7h,03ch,05ah,099h ;d_0f


 	db	080h,0e0h,0f8h,0feh,0f8h,0e0h,080h,000h ;d_10

 	db	002h,00eh,03eh,0feh,03eh,00eh,002h,000h ;d_11

 	db	018h,03ch,07eh,018h,018h,07eh,03ch,018h ;d_12

 	db	066h,066h,066h,066h,066h,000h,066h,000h ;d_13

 	db	07fh,0dbh,0dbh,07bh,01bh,01bh,01bh,000h ;d_14

 	db	03eh,063h,038h,06ch,06ch,038h,0cch,078h ;d_15

 	db	000h,000h,000h,000h,07eh,07eh,07eh,000h ;d_16

 	db	018h,03ch,07eh,018h,07eh,03ch,018h,0ffh ;d_17

 	db	018h,03ch,07eh,018h,018h,018h,018h,000h ;d_18

 	db	018h,018h,018h,018h,07eh,03ch,018h,000h ;d_19

 	db	000h,018h,00ch,0feh,00ch,018h,000h,000h ;d_1a

 	db	000h,030h,060h,0feh,060h,030h,000h,000h ;d_1b

 	db	000h,000h,0c0h,0c0h,0c0h,0feh,000h,000h ;d_1c

 	db	000h,024h,066h,0ffh,066h,024h,000h,000h ;d_1d

 	db	000h,018h,03ch,07eh,0ffh,0ffh,000h,000h ;d_1e

 	db	000h,0ffh,0ffh,07eh,03ch,018h,000h,000h ;d_1f


 	db	000h,000h,000h,000h,000h,000h,000h,000h ;sp d_20

 	db	030h,078h,078h,030h,030h,000h,030h,000h ;! d_21

 	db	06ch,06ch,06ch,000h,000h,000h,000h,000h ;"d_22

 	db	06ch,06ch,0feh,06ch,0feh,06ch,06ch,000h ;# d_23

 	db	030h,07ch,0c0h,078h,00ch,0f8h,030h,000h ;$ d_24

 	db	000h,0c6h,0cch,018h,030h,066h,0c6h,000h ;per cent d_25

 	db	038h,06ch,038h,076h,0dch,0cch,076h,000h ;& d_26

 	db	060h,060h,0c0h,000h,000h,000h,000h,000h ;' d_27

 	db	018h,030h,060h,060h,060h,030h,018h,000h ;( d_28

 	db	060h,030h,018h,018h,018h,030h,060h,000h ;) d_29

 	db	000h,066h,03ch,0ffh,03ch,066h,000h,000h ;* d_2a

 	db	000h,030h,030h,0fch,030h,030h,000h,000h ;+ d_2b

 	db	000h,000h,000h,000h,000h,030h,030h,060h ;, d_2c

 	db	000h,000h,000h,0fch,000h,000h,000h,000h ;- d_2d

 	db	000h,000h,000h,000h,000h,030h,030h,000h ;. d_2e

 	db	006h,00ch,018h,030h,060h,0c0h,080h,000h ;/ d_2f


 	db	07ch,0c6h,0ceh,0deh,0f6h,0e6h,07ch,000h ;0 d_30

 	db	030h,070h,030h,030h,030h,030h,0fch,000h ;1 d_31

 	db	078h,0cch,00ch,038h,060h,0cch,0fch,000h ;2 d_32

 	db	078h,0cch,00ch,038h,00ch,0cch,078h,000h ;3 d_33

 	db	01ch,03ch,06ch,0cch,0feh,00ch,01eh,000h ;4 d_34

 	db	0fch,0c0h,0f8h,00ch,00ch,0cch,078h,000h ;5 d_35

 	db	038h,060h,0c0h,0f8h,0cch,0cch,078h,000h ;6 d_36

 	db	0fch,0cch,00ch,018h,030h,030h,030h,000h ;7 d_37

 	db	078h,0cch,0cch,078h,0cch,0cch,078h,000h ;8 d_38

 	db	078h,0cch,0cch,07ch,00ch,018h,070h,000h ;9 d_39

 	db	000h,030h,030h,000h,000h,030h,030h,000h ;: d_3a

 	db	000h,030h,030h,000h,000h,030h,030h,060h ;; d_3b

 	db	018h,030h,060h,0c0h,060h,030h,018h,000h ;< d_3c

 	db	000h,000h,0fch,000h,000h,0fch,000h,000h ;= d_3d

 	db	060h,030h,018h,00ch,018h,030h,060h,000h ;> d_3e

 	db	078h,0cch,00ch,018h,030h,000h,030h,000h ;? d_3f


 	db	07ch,0c6h,0deh,0deh,0deh,0c0h,078h,000h ;@ d_40

 	db	030h,078h,0cch,0cch,0fch,0cch,0cch,000h ;A d_41

 	db	0fch,066h,066h,07ch,066h,066h,0fch,000h ;B d_42

 	db	03ch,066h,0c0h,0c0h,0c0h,066h,03ch,000h ;C d_43

 	db	0f8h,06ch,066h,066h,066h,06ch,0f8h,000h ;D d_44

 	db	0feh,062h,068h,078h,068h,062h,0feh,000h ;E d_45

 	db	0feh,062h,068h,078h,068h,060h,0f0h,000h ;F d_46

 	db	03ch,066h,0c0h,0c0h,0ceh,066h,03eh,000h ;G d_47

 	db	0cch,0cch,0cch,0fch,0cch,0cch,0cch,000h ;H d_48

 	db	078h,030h,030h,030h,030h,030h,078h,000h ;I d_49

 	db	01eh,00ch,00ch,00ch,0cch,0cch,078h,000h ;J d_4a

 	db	0e6h,066h,06ch,078h,06ch,066h,0e6h,000h ;K d_4b

 	db	0f0h,060h,060h,060h,062h,066h,0feh,000h ;L d_4c

 	db	0c6h,0eeh,0feh,0feh,0d6h,0c6h,0c6h,000h ;M d_4d

 	db	0c6h,0e6h,0f6h,0deh,0ceh,0c6h,0c6h,000h ;N d_4e

 	db	038h,06ch,0c6h,0c6h,0c6h,06ch,038h,000h ;O d_4f


 	db	0fch,066h,066h,07ch,060h,060h,0f0h,000h ;P d_50

 	db	078h,0cch,0cch,0cch,0dch,078h,01ch,000h ;Q d_51

 	db	0fch,066h,066h,07ch,06ch,066h,0e6h,000h ;R d_52

 	db	078h,0cch,0e0h,070h,01ch,0cch,078h,000h ;S d_53

 	db	0fch,0b4h,030h,030h,030h,030h,078h,000h ;T d_54

 	db	0cch,0cch,0cch,0cch,0cch,0cch,0fch,000h ;U d_55

 	db	0cch,0cch,0cch,0cch,0cch,078h,030h,000h ;V d_56

 	db	0c6h,0c6h,0c6h,0d6h,0feh,0eeh,0c6h,000h ;W d_57

 	db	0c6h,0c6h,06ch,038h,038h,06ch,0c6h,000h ;X d_58

 	db	0cch,0cch,0cch,078h,030h,030h,078h,000h ;Y d_59

 	db	0feh,0c6h,08ch,018h,032h,066h,0feh,000h ;Z d_5a

 	db	078h,060h,060h,060h,060h,060h,078h,000h ;( d_5b

 	db	0c0h,060h,030h,018h,00ch,006h,002h,000h ;backslash

 	db	078h,018h,018h,018h,018h,018h,078h,000h ;) d_5d

 	db	010h,038h,06ch,0c6h,000h,000h,000h,000h ;cimpqumflex

 	db	000h,000h,000h,000h,000h,000h,000h,0ffh ;_ d_5f


 	db	030h,030h,018h,000h,000h,000h,000h,000h ;  d_60

 	db	000h,000h,078h,00ch,07ch,0cch,076h,000h ;lower case a

 	db	0e0h,060h,060h,07ch,066h,066h,0dch,000h ;b d_62

 	db	000h,000h,078h,0cch,0c0h,0cch,078h,000h ;c d_63

 	db	01ch,00ch,00ch,07ch,0cch,0cch,076h,000h ;d d_64

 	db	000h,000h,078h,0cch,0fch,0c0h,078h,000h ;e d_65

 	db	038h,06ch,060h,0f0h,060h,060h,0f0h,000h ;f d_66

 	db	000h,000h,076h,0cch,0cch,07ch,00ch,0f8h ;g d_67

 	db	0e0h,060h,06ch,076h,066h,066h,0e6h,000h ;h d_68

 	db	030h,000h,070h,030h,030h,030h,078h,000h ;i d_69

 	db	00ch,000h,00ch,00ch,00ch,0cch,0cch,078h ;j d_6a

 	db	0e0h,060h,066h,06ch,078h,06ch,0e6h,000h ;k d_6b

 	db	070h,030h,030h,030h,030h,030h,078h,000h ;l d_6c

 	db	000h,000h,0cch,0feh,0feh,0d6h,0c6h,000h ;m d_6d

 	db	000h,000h,0f8h,0cch,0cch,0cch,0cch,000h ;n d_6e

 	db	000h,000h,078h,0cch,0cch,0cch,078h,000h ;o d_6f


 	db	000h,000h,0dch,066h,066h,07ch,060h,0f0h ;p d_70

 	db	000h,000h,076h,0cch,0cch,07ch,00ch,01eh ;q d_71

 	db	000h,000h,0dch,076h,066h,060h,0f0h,000h ;r d_72

 	db	000h,000h,07ch,0c0h,078h,00ch,0f8h,000h ;s d_73

 	db	010h,030h,07ch,030h,030h,034h,018h,000h ;t d_74

 	db	000h,000h,0cch,0cch,0cch,0cch,076h,000h ;u d_75

 	db	000h,000h,0cch,0cch,0cch,078h,030h,000h ;v d_76

 	db	000h,000h,0c6h,0d6h,0feh,0feh,06ch,000h ;w d_77

 	db	000h,000h,0c6h,06ch,038h,06ch,0c6h,000h ;x d_78

 	db	000h,000h,0cch,0cch,0cch,07ch,00ch,0f8h ;y d_79

 	db	000h,000h,0fch,098h,030h,064h,0fch,000h ;z d_7a

 	db	01ch,030h,030h,0e0h,030h,030h,01ch,000h ;  d_7b

 	db	018h,018h,018h,000h,018h,018h,018h,000h ;  d_7c

 	db	0e0h,030h,030h,01ch,030h,030h,0e0h,000h ;  d_7d

 	db	076h,0dch,000h,000h,000h,000h,000h,000h ;  d_7e

 	db	000h,010h,038h,06ch,0c6h,0c6h,0feh,000h ;delta d_7f


;---int 1a-------------------------------
;
;   Программа установки-считывания времени суток
;
;   Эта программа обеспечивает выполнение двух функций, код которых
; задается в регистре AH:
;   AH=0 - считать текущее состояние часов. После выполнения коман-
; ды регистры CX и DX содержат старшую и младшую части счетчика.
;   Если регистр AL содержит "0", то счет идет в течение одних
; суток, при любом другом значении счет переходит на следующие
; сутки;
;
;   AH=1 - записать текущее состояние часов. Регистры CX и DX
; содержат старшую и младшую части счетчика.
;
;------------------------------------------
 	assume	cs:code,ds:data
time_of_day	proc	far
 	sti	 	; уст признак разрешения прерывания
 	push	ds	; сохранить сегмент
 	push	ax	; сохранить параметры
 	mov	ax,dat
 	mov	ds,ax
 	pop	ax
 	or	ah,ah	; AH=0 ?
 	jz	t2  ; да, переход к считыванию текущего состояния
 	dec	ah	; AH=1 ?
 	jz	t3  ; да, переход к установке текущего состояния

t1:	; Возврат из программы

 	sti	 	; уст признак разрешения прерывания
 	pop	ds	; возврат сегмента
 	iret	 	; возврат к программе,вызвавшей процедуру

t2:	; Считать текущее состояния часов

 	cli	 	; сбросить признак разрешения прерывания
 	mov	al,timer_ofl  ; считать в AL флажок перехода на сле-
 	mov	timer_ofl,0   ; дующие сутки и сбросить его в памяти
 	mov	cx,timer_high	 	; установить старшую и младшую
 	mov	dx,timer_low	 	; части счетчика
 	jmp	short t1

t3:	; Установить текущее состояние часов

 	cli	 	; сброс признака разрешения прерывания
 	mov	timer_low,dx	 	; установить младшую и старшую
 	mov	timer_high,cx	 	; части счетчика
 	mov	timer_ofl,0	; сброс флажка перехода через сутки
 	jmp	short t1	; возврат из программы отсчета времени
time_of_day	endp

;-------int 08-------------------
;
;   Программа обработки прерывания таймера КР580ВИ53 (INT 8H) об-
; рабатывает прерывания, аппаратурно возникающие от нулевого канала
; таймера, на вход которого подаются сигналы с частотой 1,228 МГц,
; делящиеся на 56263 для обеспечения 18,2 прерываний в секунду.
;   При обработке прерывания корректируется программный счетчик,
; хранящийся в памяти по адресу 0046CH (младшая часть счетчика) и
; адресу 0047EH (старшая часть счетчика) и используемый для уста-
; новки времени суток.
;   В функции программы входит коррекция счетчика, управляющего
; двигателем НГМД. После обнуления счетчика двигатель выключается.
;   Вектор 1CH дает возможность пользователю входить в заданную
; программу с частотой прерывания таймера (18.2 прерываний в секун-
; ду). Для этого в таблице векторов прерываний по адресу 007CH
; необходимо задать адрес пользовательской программы.
;
;---------------------------------------------------

timer_int	proc	far
 	sti	 	; уст признак разрешения прерывания
 	push	ds
 	push	ax
 	push	dx
 	mov	ax,dat
 	mov	ds,ax
 	inc	timer_low    ; +1 к старшей части счетчика
 	jnz	t4
 	inc	timer_high   ; +1 к старшей части счетчика

t4:	; Опрос счетчика = 24 часам

 	cmp	timer_high,018h
 	jnz	t5
 	cmp	timer_low,0b0h
 	jnz	t5

;   Таймер исчерпал 24 часа

 	mov	timer_high,0   ; сброс старшей и младшей частей
 	mov	timer_low,0    ; счетчика и установка флажка пере-
 	mov	timer_ofl,1    ; хода счета на следующие сутки

;   Выключение мотора НГМД, если счетчик управления мотором
; исчерпан

t5:
 	dec	motor_count
 	jnz	t6	 	; переход, если счетчик не установлен
 	and	motor_status,0f0h
 	mov	al,0ch
 	mov	dx,03f2h
 	out	dx,al	 	; выключить мотор

t6:
 	int	1ch	; передача управления программе пользователя
 	mov	al,eoi
 	out	020h,al        ; конец прерывания
 	pop	dx
 	pop	ax
 	pop	ds
 	iret	 	 	; возврат из прерывания
timer_int	endp
;---------------------------------
;
;   Эти вектора передаются в область прерывания 8086 во время
; включения питания.
;
;---------------------------------
vector_table	label	word	; таблица векторов прерываний

 	dw	offset timer_int	; прерывание 8
 	dw	offset kb_int	 	; прерывание 9
 	dw	offset dummy_return	; прерывание А
 	dw	offset dummm_return	; прерывание B
 	dw	offset dummm_return	; прерывание C
 	dw	offset dummy_return	; прерывание D
 	dw	offset disk_int 	; прерывание E
 	dw	offset dummy_return	; прерывание F
 	dw	offset video_io 	; прерывание 10H
 	dw	offset equipment	; прерывание 11H
 	dw	offset memory_size_determine	; прерывание 12H
 	dw	offset diskette_io	; прерывание 13H
 	dw	offset rs232_io 	; прерывание  14H
 	dw	offset int15h		; int 15h (rc заглушка)
 	dw	offset keyboard_io	; прерывание 16H
 	dw	offset printer_io	; прерывание 17H
	dw	offset start		; rc перывание 18h, поставил как в 1841 перезагрузку
 	dw	offset boot_strap	; прерывание 19H
 	dw	time_of_day	; прерывание 1АH - время суток
 	dw	dummy_return	; прерывание 1BH - прерывание клавиатуры
 	dw	dummy_return	; прерывание 1C - прерывание таймера
 	dw	video_parms	; прерывание 1D - параметры видео
 	dw	offset	disk_base   ;прерывание 1EH - параметры НГМД
 	dw	0		; 1FH - адрес таблицы пользов. знакогенер. (не инициализируется)

	org	0ff53h		;rc для того, чтобы не съехало при сокращении таблицы векторов
dummy_return:
 	iret

;---int 5----------------------
;
;   Программа вывода на печать содержимого буфера ЭЛИ вызывается
; одновременным нажатием клавиши ПЕЧ и клавиши переключения регист-
; ров. Позиция курсора сохраняется до завершения процедуры обработки
; прерывания. Повторное нажатие названных клавиш во время обработки
; прерывания игнорируется.
;   При выполнении программы в постоянно распределенной рабочей
; области памяти по адресу 0500H устанавливается следующая
; информация:
;   0	 - содержимое буфера ЭЛИ еще не выведено на печать, либо
; вывод уже завершен;
;   1	 - в процессе вывода содержимого буфера ЭЛИ на печать;
;   255  - при печати обнаружена ошибка.
;-----------------------------------------------------

 	assume	cs:code,ds:xxdata

print_screen	proc	far
 	sti	 	     ; уст признак разрешения прерывания
 	push	ds
 	push	ax
 	push	bx
 	push	cx   ; будет использоваться заглавная буква для курсора
 	push	dx   ; будет содержать текущее положение курсора
 	mov	ax,xxdat	; адрес 50
 	mov	ds,ax
 	cmp	status_byte,1	; печать готова ?
 	jz	exit	 	; переход, если печать готова
 	mov	status_byte,1	;
 	mov	ah,15	 	; требуется текущий режим экрана
 	int	10h	 	; AL - режим, AH - число строк/колонок
 	 	 	 	; BH - страница,выведенная на экран


;*************************************8
;
;   В этом месте:
;	 	    AX - колонка, строка,
;	 	    BH - номер отображаемой страницы.
;
;   Стек содержит DS, AX, BX, CX, DX.
;
;	 	    AL - режим
;
;**************************************

 	mov	cl,ah
 	mov	ch,25
 	call	crlf
 	push	cx
 	mov	ah,3
 	int	10h
 	pop	cx
 	push	dx
 	xor	dx,dx

;**************************************
;
;    Считывание знака, находящегося в текущей позиции курсора
; и вывод на печать
;
;**************************************

pri10:	mov	ah,2
 	int	10h
 	mov	ah,8
 	int	10h
 	or	al,al
 	jnz	pri15
 	mov	al,' '
pri15:
 	push	dx
 	xor	dx,dx
 	xor	ah,ah
 	int	17h
 	pop	dx
 	test	ah,25h
 	jnz	err10
 	inc	dl
 	cmp	cl,dl
 	jnz	pri10
 	xor	dl,dl
 	mov	ah,dl
 	push	dx
 	call	crlf
 	pop	dx
 	inc	dh
 	cmp	ch,dh
 	jnz	pri10
	pop	dx
 	mov	ah,2
 	int	10h
 	mov	status_byte,0
 	jmp	short exit
err10:	pop	dx
 	mov	ah,2
 	int	10h
	mov	status_byte,0ffh

exit:	pop	dx
 	pop	cx
 	pop	bx
 	pop	ax
 	pop	ds
 	iret
print_screen	endp

;   Возврат каретки

crlf	proc	near
 	xor	dx,dx
 	xor	ah,ah
 	mov	al,12q
 	int	17h
 	xor	ah,ah
 	mov	al,15q
 	int	17h
 	ret
crlf	endp

		db 22 dup(0)

;--------------------------------------
;
;   Включение питания
;
;--------------------------------------

;vector segment at 0ffffh

;   Переход по включению питания

POST: 		db	0eah		; db	0eah,5bh,0e0h,00h,0f0h	; jmp reset
		dw	offset reset, cod	; ###Gleb###

		db '04/24/81'

		db    0, 0	
		
		db    0	;  
;vector ends






code	ends
 	end	POST
