;ES1840 bios v.5
;Modified by Leonid Yadrennikov, Tyumen.
;05.10.2021-04.04.2021.
;Based on ES1840 bios v.4 source code made by Gleb Larionov, Prague.

;New features are:
;-this BIOS can work with both ES1840 and ES1841 memory boards;
;-this BIOS can work with both ES1840 and ES1841 CPU boards with no errors;
;-if jumpers set to RAM size bigger then real amount, or BIOS is running on
;	ES1841, RAM size if auto-detected;
;-upper bound for RAM in any case is 704 Kb;
;-power-on memory test is twice as fast then in ES1840 BIOS v.4;
;-improved memory diagnostics:
;	--this BIOS can detect bank (0/1) where RAM error occured (like ES-1841)
;	--in addition and unlike ES1841, this BIOS also can detect bank where
;	  parity chip error ocured.
;-keyboard driver supports both ISO 8859-5 and CP866 code tables, 
;	with hot switching between them by Ctrl-Inf.

EXTERN	BCT:near
EXTERN	OSH2:near
EXTERN	PRINT_SCREEN:near
EXTERN	VECTOR_TABLE:near
EXTERN	SEEK:near
EXTERN	F19A:near
EXTERN	F20A:near
EXTERN	INFOSTR

PUBLIC	RUST2
PUBLIC	P_MSG
PUBLIC	RESET
PUBLIC	NEC_OUTPUT
PUBLIC	E1
PUBLIC	F19B
PUBLIC	F20B
PUBLIC	START
PUBLIC	TST12
PUBLIC	PRT_STR
PUBLIC	BEEP
PUBLIC	BOOT_STRAP

INCLUDE POSTEQU0.INC
INCLUDE DSEG40.INC

;____________________
;  Основной массив в ПЗУ (сегмент code)
;____________________

code segment byte public

infolen	equ	16h			; строка с датой последних изменений (хранится в infolen40.asm)
					; ссылка на нее - infostr
					; в infolen40.asm прописан начальный адрес BIOS - E000h 

c1		dw offset c11		; адрес	возврата
caw		dw offset ca3
 	assume cs:code,ss:code,es:abs0,ds:data

stgtst:
 	 	mov	cx,4000h/2		;rc 2x less because 16bit (by-word) testing

stgtst_cnt	proc	near
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
		jnz	c4			;rc if error, make it 8bit compartible
		in	al, port_c
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
		
c4:						;rc make 16-bit test result 8-bit (old) error processing compartible
		cmp al,0
		jne c7x			;rc L-byte - proceed as usual, precerving NZ flag
		mov al,ah		;rc else make compartible with 8bit
		dec di			;rc set DI to even address and NZ flag
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
 	mov	cx,4096/2 	; счетчик байт для ч/б адаптера
 	mov	al,1	 	; уст режим для ч/б адаптера
 	cmp	ah,30h	 	; ч/б адаптер ЭЛИ подключен ?
 	je	e9	 	; переход к проверке буфера ЭЛИ
 	mov	bx,0b800h
 	mov	dx,3d8h 	; регистр режима для цветного адаптера
 	mov	cx,4000h/2
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
	pushf
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
	popf
	je	tst12				;skip memtest on reboot



;   Проверка любой действительной памяти
;   на считывание и запись

 	jmp	e190

;   Печать адреса и эталона, если
;   произошла ошибка данных

osh:
	push	ax
	cmp ax,0		;rc это ошибка четности?
	je parity

usual:
	mov ax,es
	mov al,ah		; получить адрес (8 старших разрядов) в AL
	call prn_hex_byte
	pop ax			; получить XOR записанного и прочтенного
	call prn_hex_byte
	jmp osh2

parity:
;checking L-byte
	mov si,di		;restore SI independently of D-flag
	xchg ax,bx		;pattern for test in al (from bl)
	stosb
;clear parity flip-flop on CPU module
	in al,port_b
	push ax
	or al,00100000b		;clear parity flip-flop (bit5=1)
	out port_b,al
	pop ax
	out port_b,al		;restore initial value of port_b
;check parity for L-byte
	db 26h			;es seg prefix
	lodsb
	in	al, port_c	;read parity checker
	and	al, 40h
	jz h_parity		;Z means: L-byte wasn't erroneous
	dec di			;since DI was incremented by stosb, for L-error we should restore it
h_parity:
	jmp short usual

prn_hex_byte proc near
	push ax
	mov	cl,4
	shr	al,cl	 	;
	call	xlat_print_cod	; преобразование и печать старшего разряда
	pop ax
	and	al,0fh
	call	xlat_print_cod	; преобразование и печать младшего разряда
	ret
prn_hex_byte endp

;______________________
;   Сброс системы - фаза 4
;______________________
;
;   Коды сообщений об ошибках
;_______________________

 	assume	cs:code,ds:data
f1	db	' 301'
f1l	equ	4h	 	; сообщение клавиатуры
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
	
	db	(?)		;rc для устранения съезжания при переделке загрузчика таблицы векторв прерываний

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
 	mov	bp,si
p_msg_noerr:
	call prt_str
 	mov	ax,0e0dh   ; переместить курсор в начало строки
 	int	10h
 	mov	ax,0e0ah  ; переместить курсор на следующую строку
 	int	10h
 	ret
p_msg	endp


e190:
	mov	si,offset infostr	; адрес поля информации о BIOS
 	mov	cx, infolen		; длина информации
 	call	p_msg_noerr 		; вывод на экран
	push	ds
	mov	ax, 16
	jmp short prt_siz

e20b:
	mov	bx, ds:memory_size
	sub	bx, ax		;ax stores 16d, subtract tested bytes so bytes to test are in bx
	xchg	bx,ax		;order for div command format
	div	bx		;now ax stores amount of 16K-fragments to test
	xchg	cx,ax		;now cx has that amount
	xchg	bx,ax		;ax stores 16d back
	mov	bx, 400h

e20c:
	mov	es, bx
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
	mov	cl, 3		;after normal STGTST end CX=0, so we can set only CL

decimal_loop:
	xor	dx, dx
	div	bx
	or	dl, 30h
	push	dx
	loop	decimal_loop
	mov	cl, 3		;after decimal_loop end CX=0, so we can set only CL

prt_dec_loop:
	pop	ax
	call	prt_hex
	loop	prt_dec_loop
	mov	cl, 7		;after prt_dec_loop end CX=0, so we can set only CL
	mov	si, offset e300	; " Kb OK\r"
	call	prt_str
	pop	ax
	cmp	ax, 16
	jz	e20b
	pop	bx
	pop	cx
	pop	dx
	add	bh, 4		;next 16k-block
	cmp	bh,0b0h		;b000 (704kb) is mda-display buffer beginning
	je	stoptst
	loop	e20c
stoptst:pop	ds
	mov	ds:memory_size,	ax	;if break from loop occured
pre12:	mov	al, 10		;line feed
	call	prt_hex
	jmp	tst12


e21a:
	pop	cx		;restore memory size before last STGTST call
	add	sp, 6
	pop	ds		;restore pointer to BIOS data area
				;from the very beginning of e190
	mov	ds:memory_size,	cx
	cmp	ax,0aaaah	;rc это отсутствие памяти?
	je	pre12		;rc отсутствие, значит - не ошибка
	jmp	osh

	db	3 dup (?)	;rc для устранения съезжаний адресов последующего кода

prt_hex		proc near
		mov	ah, 14
		int	10h
		retn
prt_hex		endp

e300		db ' Kb OK',0Dh
f39		db 'ERROR (RESUME="F1" KEY)'

prt_str		proc near
		cld
		db	2eh		;cs segment prefix
		lodsb
		call	prt_hex
		loop	prt_str
		ret
prt_str		endp

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
 	int	10h
 	pop	ds
 	ret
xlat_print_cod endp


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
code	ends
	end
