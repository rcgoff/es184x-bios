	PUBLIC keyboard_io
	PUBLIC kb_int
	PUBLIC error_beep

	EXTERN rust:near
	EXTERN rust2:near
	EXTERN k30:near
	EXTERN reset:near

.XLIST	
INCLUDE POSTEQU0.inc
INCLUDE DSEG40.inc
.LIST

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
code	segment	byte public
	assume	cs:code,ds:data

k4	proc	near
	add	bx,2
;1841 	cmp  bx,buffer_end	 	 ; конец буфера ?
	cmp  bx,offset kb_buffer_end 	 ; конец буфера ?
	jne	k5	 	 	 ; нет - продолжить
;1841 	mov	bx,buffer_start 	 ; да - уст начала буфера
	mov	bx,offset kb_buffer 	 ; да - уст начала буфера
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

;------ PLAIN OLD LOWER CASE

k54:					;rc обычный нижний регистр
	cmp	al,59                   ; TEST FOR FUNCTION KEYS
	jb	caps                    ; NOT-LOWER-FUNCTION
	mov	al,0                    ; SCAN CODE IN AH ALREADY
	jmp	short k57               ; BUFFER_FILL

;------TRANSLATE THE CHARACTER

k56:                                    ; TRANSLATE-CHAR
	dec	al                      ; CONVERT ORIGIN
	xlat	cs:k11                  ; CONVERT THE SCAN CODE TO ASCII

;------ PUT CHARACTER INTO BUFFER

k57:                                    ; BUFFER-FILL
	cmp	al,-1                   ; IS THIS AN IGNORE CHAR
	je	k59                     ; YES, DO NOTHING WITH IT
	cmp	ah,-1                   ; LOOK FOR -1 PSEUDO SCAN
	je	k59                     ; NEAR_INTERRUPT_RETURN

k58:                                    ; BUFFER-FILL-NOTEST
	jmp	short k61               ;old caps processing removed

k59:                                    ; NEAR-INTERRUPT-RETURN
	jmp	k26                     ; INTERRUPT_RETURN

k61:                                    ; NOT-CAPS-STATE
	mov	bx,buffer_tail          ; GET THE END POINTER TO THE BUFFER
	mov	si,bx                   ; SAVE THE VALUE
	call   k4                       ; ADVANCE THE TAIL
	cmp	bx,buffer_head          ; HAS THE BUFFER WRAPPED AROUND
	je	k62                     ; BUFFER_FULL_BEEP
	mov	word ptr [si],ax        ; STORE THE VALUE
	mov	buffer_tail,bx          ; MOVE THE POINTER UP
	jmp	k26                     ; INTERRUPT_RETURN

;------ BUFFER IS FULL, SOUND THE BEEPER

k62:                                    ; BUFFER-FULL-BEEP
	call	error_beep
	jmp	k26                     ; INTERRUPT_RETURN

;------ TRANSLATE SCAN FOR PSEUDO SCAN CODES

k63:                                    ; TRANSLATE-SCAN
	sub	al,59                   ; CONVERT ORIGIN TO FUNCTION KEYS
k64:                                    ; TRANSLATE-SCAN-ORGD
	xlat	cs:k9                   ; CTL TABLE SCAN
	mov	ah,al                   ; PUT VALUE INTO AH
	mov	al,0                    ; ZERO ASCII CODE
	jmp	k57                     ; PUT IT INTO THE BUFFER

;------ set keyb boolean value: 0=lower, 1=upper case

caps:	mov	dl,kb_flag_1				;bit 1 set =lat
	shl	dl,1					;for second call, where setting rus/lat table
	and	dl,lat*2
	xor	dl,lat*2				;bit 2 set=rus
	mov	bx,offset capst				;lat caps-able table
	jz	decd                                    ;Z=lat
	mov	bx,offset capstru			;rus caps-able table
decd:	push	ax                                      ;save scancode in AL and AH 
							;(later code destroys AH, DECODE - dec al)
	call	decode					;CY = code in AL is /caps_able
	call	upplow					;CY = uppercase
;select keyboard table
	mov	bx,0
	jnc	ruslat
	add	bx,2					;offset in bytes for upper case
ruslat:	add	bl,dl					;dl=4 if rus table, see above
setbl:	db	2eh,8bh,9fh 
	dw	scode_tbl_sel 
;setbl:	mov	bx,cs:[offset scode_tbl_sel+bx]
	pop	ax					;restore scancode in AL and AH
	jmp	short k56

scode_tbl_sel label word
	dw	k10                     ;LAT LCASE
	dw	k11                     ;LAT UCSASE
	dw	rust                    ;RUS ISO LCASE
	dw	rust2                   ;RUS ISO UCASE

;------ decode necessary byte in array
;and position in the byte
;on call, AL contains scan-code
;BX contains pointer to array
;on return, we have boolean value:
;is this code CapsLock-influenced (CY=0) or not (CY=1)
;ax and cx will be destroyed

decode:
	push bx
	mov ah,0
	dec ax		;dec because scancodes starts from 1 (not 0). ax (not al) i.e. 1 byte instead of 2 
	mov ch,0
	mov bl,8
	div bl		;now quotient (byte nr) is in AL and the remainder (index in byte) is in AH
;get byte from table
	mov cl,ah	;remainder (index in byte)
	pop bx		;restore pointer to array
	xlat cs:capst
;set necessary bit to 1 in mask
	inc cl  	;index in byte starts from 0, but we're shifting from CY
	stc
	rcr ch,cl	;index=0 means bit 7 (CAPST filled in tha way) - shift to RIGHT
;get necessary bit in carry flag
	and al,ch
	rcl al,cl
	retn

;------ check if we need to use UPPER or LOWER keys
;on call, CY= /this-scancode-is-caps-able
;on return, CY=UPPERCASE
;in other words, CY=SHIFT xor (CAPS & CAPS_ABLE)
;AH,BX,CL are destroyed

upplow:	mov	cl,2
	rcr	bl,cl					;bl = /caps_able in Z position (bit 6)
	test	kb_flag,left_shift+right_shift		;z flag=0 if SHIFT
	lahf
	mov	bh,ah					;bh = /shift
	test	kb_flag,caps_state			;z flag=0 if CAPS
	lahf                                            ;ah = /caps

;formula is: value= SHIFT xor (CAPS & CAPS_ABLE)
;that is equal to: /SHIFT xor (/CAPS or /CAPS_ABLE)

;now, calculate by formula
	or	ah,bl
	xor	ah,bh					;now bit6 (Z-position) of ah contains answer
	rcl	ah,cl					;now CY contains answer
	retn

;---
;org	00d3h
;	db	34 dup (0)
;1841 	org	0e82eh
keyboard_io proc	far
	sti	 	 	;
	push	ds
	push	bx
	mov	bx,data
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
	db	27,'1234567'		;byte1
	db	'890-=',08h,09h,'q'	;byte2
	db	'wertyuio'		;byte3
	db	'p[]',0dh,-1,'asd'	;byte4
	db	'fghjkl;:'		;byte5
	db	60h,7eh,05ch,'zxcvb'	;byte6
	db	'nm,./{*',-1		;byte7
	db	' }'			;byte8

;   Таблица кодов ASCII верхнего регистра клавиатуры

k11	label	byte
	db	27,'!@#$',37,05eh,'&'	;byte1
	db	'*()_+',08h,0,'Q'	;byte2
	db	'WERTYUIO'		;byte3
	db	'P',-1,-1,0dh,-1,'ASD'	;byte4
	db	'FGHJKL',027h,'"'	;byte5
	db	-1,-1,7ch,'ZXCVB'	;byte6
	db	'NM<>?',-1,0,-1		;byte7
	db	' ',-1			;byte8


;------ CapsLock table (latin)

capst	label	byte
;		27,'1234567'		;byte1
	db	0ffh

;		'890-='08h,09h,'q'	;byte2
        db	11111110b

;		'wertyuio'		;byte3
	db	0

;		'p[]',0dh,-1,'asd'	;byte4
	db	01111000b

;		'fghjkl;:'		;byte5
	db	00000011b

;		60h,7eh,05ch,'zxcvb'	;byte6
	db	11100000b

;		'nm,./{*',-1		;byte7
	db	00111111b

;		' }'			;byte8
	db	0ffh


;------ CapsLock table (cyrillic)
;first 3 bytes are the same

capstru	label 	byte
;					;byte1
	db	0ffh

;		последняя - Й		;byte2
	db	11111110b

;		'ЦУКЕНГШЩ'	 	;byte3
	db	0

;		'ЗЖЭ',0dh,-1,'ФЫВ' 	;byte4
	db	00011000b

;		'АПРОЛД',27h,'"' 	;byte5
	db	00000011b

;		'БЮ',7ch,'ЯЧСМИ'	;byte6
	db	00100000b

;		'ТЬ','<>?','Х',0,-1	;byte7
	db	00111011b

;		' Ъ'		 	;byte8
	db	10111111b



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

;1841 	org	0e987h
	db	9 dup (0)

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
	mov	ax,data	       ; установить адресацию
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
	repne 	scasb	; сравнение полученного кода сканирования с содержимым таблицы
	mov	al,ah	 	; запомнить код сканирования
	je	k17	 	; переход по совпадению
	jmp	k25	 	; переход по несовпадению

k406:           			;rc это обработчик клавиши Ё
	test	kb_flag_1,lat
	jnz	k26a                    ;rc в ЛАТ-режиме клавиша не генерирует ничего, выход
	call	upplow			;rc CY=1: верхний регистр
	mov	ax,5cf1h		;rc ё
	jnc	k407
	mov	ax,5cf0h                ;rc Ё
k407:					;rc передвинул сюда, двумя строками выше  (это ж не получение маски)
	jmp	k57

;   Получение маски нажатой управляющей клавиши


k17:	sub	di,offset k6+1		;rc получить индекс упр клавиши в табл k6, начиная с 0
	cmp	di,8
	jb	k300                    ;rc меньше 8 (это совместимые клавиши) обрабатываются как в IBM
	mov	ah,6                    ;rc маска 0b00000110 для руслат  (inv_shift + lat)
	cmp	di,0ah
	jb	k301                    ;rc если inv_key (Р/Л)
	test	al,80h
	jz	k26a                    ;rc если не отпускание РУС или ЛАТ -> вых (борьба с автоповтором?)

				;rc здесь мы после отпускания РУС или ЛАТ
	and	kb_flag_1,not lat+lat_shift   ;rc not действует на оба, сбрасываем lat и "светодиодный" lat
	cmp	di,0bh
	je	k401                    ;rc переход, если РУС
				;rc если ЛАТ:
	test	kb_flag_1,inv_shift
	jz	k400                    ;rc переход по ненажатию Р/Л
	or	kb_flag_1,lat_shift     ;rc нажата Р/Л->отметить нажатие ("светодиодный") ЛАТа и всё
	jmp	short k26a
k400:	or	kb_flag_1,lat+lat_shift ;rc не нажата Р/Л и нажат ЛАТ->включить ЛАТ и факт нажатия ("светодиодный")
	jmp	short k26a

				;РУС:
k401:	test	kb_flag_1,inv_shift
	jz	k26a                    ;rc по ненажатию Р/Л выход ("светодиодный" выключен заранее)
	or	kb_flag_1,lat           ;rc нажата Р/Л и отпущена РУС: включить lat ///???
	jmp	short k26a

				;rc далее IBM-ский код				
k300:	mov	ah,cs:k7[di]            ;rc аналогично IBM считыаем маску из k7 для совместимых упр клавиш
k301:
	test	al,80h	 	; клавиша отжата ?
	jnz	k23	; переход, если клавиша отжата

;   Управляющая клавиша нажата

	cmp	ah,scroll_shift ; нажата управляющая клавиша с
	 	 	 	;  запоминанием ?
	jae	k18	 	; переход, если да

;---
	cmp	ah,6
	je	k302            ; rc нажата Р/Л

	or	kb_flag,ah	; установка масок управляющих клавиш
	 	 	 	; без запоминания
	jmp	k26	 	; к выходу из прерывания

k302:	or	kb_flag_1,inv_shift+lat ;rc обработка нажатия Р/Л: ставим факт нажатия и латиницу
	test	kb_flag_1,lat_shift	;rc светодиодный ЛАТ есть?
	jz	k26a                    ;rc нет -> выходим
	and	kb_flag_1,not lat       ;rc есть -> сбрасываем латиницу
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

k303:						;rc отжатие Р/Л
	and	kb_flag_1,not inv_shift         ;rc сброс флажка нажатия Р/Л
	xor	kb_flag_1,lat                   ;rc переключение раскладки
	jmp	short k304

;   Управляющая клавиша отжата
			;rc если сюда попали при нажатии ЕС-клавиши Р/Л, то ah=6
k23:

	cmp	ah,scroll_shift
	jae	k24				;rc это были переключатели с фиксацией?
	not	ah                              ;rc да - переходим к ним
	cmp	ah,0f9h				;rc было ah=6? Р/Л?
	je	k303                            ;rc да->обрабатываем
	and	kb_flag,ah                      ;rc это и далее - продолжение IBM-ского кода
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
;---

k25:						;rc как и в IBM, здесь мы, если не управляющая клавиша
						;rc (т.е. ее код не в k6) или если мы нажали ins-num-caps-scroll,
						;rc когда ранее была зажата ctrl или alt
	cmp	al,80h
	jae	k26
	cmp	al,inf_key
	je	k307  				;rc обработчик клавиши ИНФ (выдает 0a00h расшир код)
	cmp	al,92
	jne	k406b
	jmp	k406				;rc обработчик клавиши Ё (выдает ASCII F0h/F1h в режиме РУС)
k406b:                                          ;rc далее как в IBM
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

k307:	mov	ax,0a000h			;rc клавиша ИНФ, расширенный скан-код
;1841 	jmp	inf_rc	 	    ;rc обработаем смену кодовой таблицы, если Ctrl-Инф
	jmp	k57


;---

k28:
	test	kb_flag,alt_shift
	jnz	k29
	jmp	short k38

;---

k29:
	test	kb_flag,ctl_shift
	jz	k31
	cmp	al,del_key
	jne	k31

;---
k306:
	mov	reset_flag,1234h
	db	0eah
	dw	offset reset,cod
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
	jmp	 k26

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
	jmp	short k26	;в 1841 masm автоматически поставил короткий переход
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

;------ NOT IN CONTROL SHIFT

k44:					; NOT-CTL-SHIFT

	cmp	al,71                   ; TEST FOR KEYPAD REGION
	jae	k48                     ; HANDLE KEYPAD REGION
	test	kb_flag,left_shift+right_shift
	jz	k54a                    ; TEST FOR SHIFT STATE

;------ UPPER CASE, HANDLE SPECIAL CASES

	cmp	al,15                   ; BACK TAB KEY
	jne	k45                     ; NOT-BACK-TAB
	mov	ax,15*256               ; SET PSEUDO SCAN CODE
	jmp	k57                     ; BUFFER_FILL

k54a:
	jmp k54

k45:                                    ; NOT-BACK-TAB
	cmp	al,55                   ; PRINT SCREEN KEY
	jne	k46                     ; NOT-PRINT-SCREEN

;------ ISSUE INTERRUPT TO INDICATE PRINT SCREEN FUNCTION

	mov	al,eoi                  ; END OF CURRENT INTERRUPT
	out	020h,al                 ;  SO FURTHER THINGS CAN HAPPEN
	int	5h                      ; ISSUE PRINT SCREEN INTERRUPT
	jmp	k27                     ; GO BACK WITHOUT EOI OCCURRING
	
k46:                                    ; NOT-PRINT-SCREEN
	cmp	al,59                   ; FUNCTION KEYS
	jb	k47                     ; NOT-UPPER-FUNCTION
	mov	bx,offset k12           ; UPPER CASE PSEUDO SCAN CODES
	jmp	k63                     ; TRANSLATE_SCAN
	
k47:                                    ; NOT-UPPER-FUNCTION
	jmp	caps

;------ KEYPAD KEYS, MUST TEST NUM LOCK FOR DETERMINATION

k48:                                    ; KEYPAD-REGION
	test	kb_flag,num_state       ; ARE WE IN NUM_LOCK
	jnz	k52                     ; TEST FOR SURE
	test	kb_flag,left_shift+right_shift ; ARE WE IN SHIFT STATE
	jnz	k53                     ; IF SHIFTED, REALLY NUM STATE

;------ BASE CASE FOR KEYPAD

k49:                                    ; BASE-CASE

	cmp	al,74                   ; SPECIAL CASE FOR A COUPLE OF KEYS
	je	k50                     ; MINUS
	cmp	al,78
	je	k51
	sub	al,71                   ; CONVERT ORIGIN
	mov	bx,offset k15           ; BASE CASE TABLE
	jmp	  k64                   ; CONVERT TO PSEUDO SCAN
	
k50:	mov	ax,74*256+'-'           ; MINUS
	jmp	 k57                    ; BUFFER_FILL
	
k51:	mov	ax,78*256+'+'           ; PLUS
	jmp	 k57                    ; BUFFER_FILL

;------ MIGHT BE NUM LOCK, TEST SHIFT STATUS

k52:                                    ; ALMOST-NUM-STATE
	test	kb_flag,left_shift+right_shift
	jnz	k49                     ; SHIFTED TEMP OUT OF NUM STATE
	
k53:                                    ; REALLY_NUM_STATE
	sub	al,70                   ; CONVERT ORIGIN
	mov	bx,offset k14           ; NUM STATE TABLE
	jmp	 k56                    ; TRANSLATE_CHAR
kb_int	endp

code	ends
	end