;
;
;-------rc программа ниже частично основана на IBM-ской e19, причем от XTBIOS.ASM (с печатью)
;	взял оттуда комментарии. Обработка ошибки (реконфигурация, ea1) - оригинальная минская.
;
 	assume cs:code,ds:data
e190:	push	ds
 	mov	ax,16
 	cmp	reset_flag,1234h
 	jnz	e20a
 	jmp	e22			;rc при горячей перезарузке просто выход (пропуск теста)
e20a:	mov	ax,16                   ; STARTING AMT. OF MEMORY OK   
 	jmp	short prt_siz           ; POST MESSAGE                 
e20b:	mov	bx,memory_size          ; GET MEM. SIZE WORD    
 	sub	bx,16                   ; 1ST 16K ALREADY DONE  
 	mov	cl,4
 	shr	bx,cl                   ; DIVIDE BY 16                
 	mov	cx,bx                   ; SAVE COUNT OF 16K BLOCKS    
 	mov	bx,0400h                ; SET PTR. TO RAM SEGMENT>16K 
e20c:	mov	ds,bx                   ; SET SEG. REG      
 	mov	es,bx                                       
 	add	bx,0400h                ; POINT TO NEXT 16K 
 	push	dx                                          
 	push	cx                      ; SAVE WORK REGS    
 	push	bx
 	push	ax
 	call	stgtst
 	jnz	e21a                    ; GO PRINT ERROR           
 	pop	ax                      ; RECOVER TESTED MEM NUMBER
 	add	ax,16
prt_siz:
 	push	ax
 	mov	bx,10                   ; SET UP FOR DECIMAL CONVERT    
 	mov	cx,3                    ; OF 3 NIBBLES                  
decimal_loop:
 	xor	dx,dx
 	div	bx                      ; DIVIDE BY 10   
 	or	dl,30h                  ; MAKE INTO ASCII
 	push	dx                      ; SAVE           
 	loop	decimal_loop
 	mov	cx,3
prt_dec_loop:
 	pop	ax                      ; RECOVER A NUMBER
 	call	prt_hex
 	loop	prt_dec_loop
 	mov	cx,22
 	mov	si,offset e300
kb_ok:	mov	al,byte ptr cs:[si]
 	inc	si
 	call	prt_hex
 	loop	kb_ok			;rc вывод строки e300 (kb объем памяти) - 22 символа, посимвольно
 	pop	ax                      ; RECOVER WORK REGS   
 	cmp	ax,16                   ; FIRST PASS?         
 	je	e20b                    
 	pop	bx                      ; RESTORE REGS              
 	pop	cx                                                  
 	pop	dx                                                  
 	loop	e20c                    ; LOOP TILL ALL MEM. CHECKED -----rc в XT e21
 	mov	al,10
 	call	prt_hex                 ; LINE FEED 
 	pop	ds
 	jmp	e22  			;rc это выход
e21a:                                   ;rc ошибка при stgtst
 	pop	bx
 	add	sp,6
 	mov	dx,ds
 	pop	ds
 	push	ds
 	push	bx
 	mov	bx,dx
 	push	ax
 	cmp	dh,60h			;rc ошибка в 512k-640k?
 	jnb	ea1                     ;rc да->ea1 (неустранимая ошибка)
 	mov	dx,2b0h
 	in	al,dx
 	test	al,3			;rc была реконфигурация платы 2b0?
 	jnz	ea1                     ;rc да->ea1 (неустранимая ошибка)
 	push	ax                      ;rc иначе инициализируем экран,
 	mov	al,crt_mode
 	mov	ah,0
 	int	10h
 	pop	ax
 	mov	dx,bx                   ;rc получаем из текущего адреса код реконфигурации,
 	and	dh,60h
 	xor	dh,60h
 	mov	cl,5
 	shr	dh,cl
 	or	al,dh
 	mov	dx,2b0h 		 
 	out	dx,al                   ;rc устраиваем реконфигурацию...
 	xor	ax,ax
 	mov	es,ax
 	mov	ds,ax
 	jmp	ca22			;rc ...и возвращаемся в тело ca0 на начало проверки

ea1:	pop	ax      		;rc случай неустранимой ошибки
 	mov	dx,bx
 	pop	bx
 	mov	tabl+2,bx		;rc записываем новое число исправных кб платы 2b0 в таблицу tabl
 	mov	memory_size,bx		;rc сокращаем память, доступную ОС
;rc------------------rc tabl и tabl1, так же как и mem_siz и memory_size, указывают на одни и те же места в ОЗУ, 
;rc------------------rc просто tabl и memory_size в сегменте обл данных BIOS (40h), а tabl1 и mem_siz в сегменте 0h
 	push	ax
 	mov	al,10 			;rc печатаем перевод строки
 	call	prt_hex
 	pop	ax
 	jmp	osh
prt_hex proc	near
 	mov	ah,14
 	mov	bh,0
 	int	10h
 	ret
prt_hex endp
