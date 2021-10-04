;___________________	 	 	 	
; v4 - ??/??/???? (Other version than 24/04/1981) ����� ���������
 PAGE 55,120
;  ������� ������� �����/������ (�����)
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
;  ��ᯮ������� ���뢠��� 8086
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
;  �ᯮ�짮����� �⥪� ⮫쪮 �� �६� ���樠����樨
;______________________
stac	segment para stack
 	dw	128 dup(?)



tos	label	word
stac	ends

;______________________
;  ������� ������ ���
;____________________
data segment	para
rs232_base dw 4 dup(?)



printer_base dw 4 dup(?)



equip_flag dw ?
mfg_tst db	?
memory_size dw	?
io_ram_size dw	?
;_______________
;  ������� ������ ����������
;_________________
kb_flag db	?

;  �����饭�� 䫠���� � kb_flag

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

;  head=tail 㪠�뢠�� �� ���������� ����

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
;  ������� ������ ����
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
;  ������� ������ ���
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
;  ������� ������ ���
;___________________
io_rom_init dw	?
io_rom_seg dw	?
last_val db	?

;___________________
;  ������� ������ ⠩���
;___________________
timer_low dw	?
timer_high dw	?
timer_ofl db	?
;___________________
;  ������� ������ ��⥬�
;___________________
bios_break db	?
reset_flag dw	?
diskw_status  db  ?
hf_num	db   ?
control_byte  db  ?
port_off  db  ?
 	 	org	7ch
stat_offset	label	byte ; ᬥ饭�� ��� �࠭���� ���ﭨ� ������

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
;  ������� ���७�� ������
;_________________________________
xxdata segment	para
status_byte db	?
xxdata	ends

;_________________
;  ���� ���
;___________________
video_ram segment para
regen	label	byte
regenw	label	word
 	db	16384 dup(?)



video_ram ends
;____________________
;  �᭮���� ���ᨢ � ��� (ᥣ���� code)
;____________________

code segment para

		org 0E000h

a5700051Copr_Ib	db '5700051 copr. ibm 1981'
c1		dw offset c11		; ����	������
caw		dw offset ca3
 	assume cs:code,ss:code,es:abs0,ds:data

stgtst:
 	 	mov	cx,4000h

stgtst_cnt	proc	near
		cld
		mov	bx, cx
		mov	ax, 0FFFFh
		mov	dx, 0AA55h
		sub	di, di
		repe stosb

c2a:
		dec	di
		std

c2b:
		mov	si, di
		mov	cx, bx

c3:
		lodsb
		xor	al, ah
		jnz	c7x
		in	al, 62h
		and	al, 40h
		mov	al, 0
		jnz	c7x
		cmp	ah, 0
		jz	c3a
		mov	al, dl
		stosb

c3a:
		loop	c3
		cmp	ah, 0
		jz	c7x
		mov	ah, al
		xchg	dh, dl
		cld
		inc	di
		jz	c2b
		dec	di
		mov	dx, 1
		jmp	short c2a

c7x:
		retn
stgtst_cnt	endp


;____________________
;  ���� ��⥬� - 䠧� 1
;____________________
;_____________________
;  �஢�ઠ 16� �����
;_____________________
;___________________
;  ����.01
;	���� ������ 8086. �����⢫�� �஢��� ॣ����
;	�ਧ�����, ������ ���室� � ���뢠���-�����
;	���� � ᥣ������ ॣ���஢.
;_____________________________________
reset	label	near
start:	cli	 	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	ah,0d5h 	;��� �ਧ���� SF,CF,ZF,AF
 	sahf
 	jnc	err01	 	;CF=0,� �ணࠬ�� �訡��
 	jnz	err01	 	;ZF=0,� �ணࠬ�� �訡��
 	jnp	err01	 	;PF=0,� �ணࠬ�� �訡��
 	jns	err01	 	;SF=0,� �ணࠬ�� �訡��
 	lahf	 	 	;����㧨�� �ਧ���� � AH
 	mov	cl,5	 	;����㧨�� ���稪
 	shr	ah,cl	 	;�뤥���� ��� ��७��
 	jnc	err01	 	;�ਧ��� AF=0
 	mov	al,40h	 	;��� �ਧ��� ��९�������
 	shl	al,1	 	;��� ��� ����஫�
 	jno	err01	 	;�ਧ��� OF �� ���
 	xor	ah,ah	 	;��� AH=0
 	sahf	 	 	;��� � ��室��� ���ﭨ� SF,CF,ZF,PF
 	jc	err01	 	;�ਧ��� CF=1
 	jz	err01	 	;�ਧ��� ZF=1
 	js	err01	 	;�ਧ��� SF=1
 	jp	err01	 	;�ਧ��� PF=1
 	lahf	 	 	;����㧨�� �ਧ���� � AH
 	mov	cl,5	 	;����㧨�� ���稪
 	shr	ah,cl	 	;�뤥���� ��� ��७��
 	jc	err01	 	;�ਧ��� IF=1
 	shl	ah,1	 	;����஫�, �� OF ��襭
 	jo	err01
 	mov	ax,0ffffh	;��� �⠫��� � AX
 	stc
c8:	mov	ds,ax	 	;������ �� �� ॣ�����
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
 	xor	ax,di	 	;�஢�ઠ ��� ॣ���஢
 	 	 	 	;�⠫����� "FFFF", "0000"
 	jnz	err01
 	clc
 	jnc	c8
c9:
 	or	ax,di	 	;�㫥�� 蠡����� �� ॣ����� �஢�७� ?
 	jz	c10	 	;�� - ���室 � ᫥���饬� ����
err01:	jmp   short  start
;_______________________
; ����.02
;_______________________
c10:
 	mov	al,0	 	;������� ����a��� NMI
 	out	0a0h,al
 	out	83h,al	 	;���樠������ ॣ����a ��࠭�� ���
 	mov	al,99h	 	;��� A,C -����, B - �뢮�
       out	cmd_port,al	 	;������ � ॣ���� ०���
 	 	 	 	 	;��媠���쭮�� ����
 	mov	al,0fch 	 	;�����஢�� ����஫� �� �⭮��
 	out	port_b,al
 	sub	al,al
 	mov	dx,3d8h
 	out	dx,al	 	;�����஢�� 梥⭮�� ���
 	inc	al
 	mov	dx,3b8h
 	out	dx,al	 	;�����஢�� �୮-������ ���
 	mov	ax,cod	 	;��� ᥣ���⭮�� ॣ���� SS
 	mov	ss,ax
 	mov	bx,0e000h	 	;��� ��砫쭮�� ���� �����
 	mov	sp,offset c1	 	;��� ���� ������
 	jmp	short ros
		nop
c11:	jne	err01
;------------------------
;  ����.03
;   �����⢫�� �஢���, ���樠������ � ����� ��� �
; ⠩��� 1 ��� ॣ����樨 �����
;_________________________
;   �����஢�� ����஫��� ���

ros:	mov	al,04
 	out	dma08,al

;   �஢�ઠ �ࠢ��쭮�� �㭪樮��஢����
;   ⠩��� 1

 	mov	al,54h	 	;�롮� ⠩��� 1,LSB, ०�� 2
 	out	timer+3,al
 	sub	cx,cx
 	mov	bl,cl
 	mov	al,cl	 	;��� ��砫쭮�� ���稪� ⠩��� � 0
 	out	timer+1,al
c12:
 	mov	al,40h
 	out	timer+3,al
 	in	al,timer+1	;���뢠��� ���稪� ⠩��� 1
 	or	bl,al	 	;�� ���� ⠩��� ����祭� ?
 	cmp	bl,0ffh 	;�� - �ࠢ����� � FF
 	je	c13	 	;���� ⠩��� ��襭�
 	loop	c12	 	;���� ⠩��� ��⠭������
 	jmp	short err01	;ᡮ� ⠩��� 1, ��⠭�� ��⥬�
c13:
 	mov	al,bl	 	;��� ���稪� ⠩��� 1
 	sub	cx,cx
 	out	timer+1,al
c14:	 	;横� ⠩���
 	mov	al,40h
 	out	timer+3,al
 	in	al,timer+1	 	;���뢠��� ���稪� ⠩��� 1
 	and	bl,al
 	jz	c15
 	loop	c14	 	;横� ⠩���
 	jmp	short err01

;   ���樠������ ⠩��� 1

c15:
 	mov	al,54h
 	out	timer+3,al	;������ � ॣ���� ०��� ⠩���
 	mov	al,7	;��� �����樥�� ������� ��� ॣ����樨
 	out	timer+1,al	;������ � ���稪 ⠩��� 1
 	out	dma+0dh,al	;��᫠�� ��襭�� ���

;   ���� �஢�ન ॣ���஢ ���

 	mov	al,0ffh 	;������ 蠡���� FF �� �� ॣ�����
c16:	mov	bl,al	 	;��࠭��� 蠡��� ��� �ࠢ�����
 	mov	bh,al
 	mov	cx,8	 	;��� 横�� ���稪�
 	mov	dx,dma	 	;��� ���� ॣ���� ���� �����/�뢮��
c17:	out	dx,al	 	;������  蠡���� � ॣ����
 	out	dx,al	 	;���訥 16 ��� ॣ����
 	mov	ax,0101h	;��������� AX ��। ���뢠����
 	in	al,dx
 	mov	ah,al	 	;��࠭��� ����訥 16 ��� ॣ����
 	in	al,dx
 	cmp	bx,ax	 	;��⠭ �� �� 蠡��� ?
 	je	c18	 	;�� - �஢�ઠ ᫥���饣� ॣ����
 	jmp	err01	 	;��� - �訡��
c18:	 	 	 	;�롮� ᫥���饣� ॣ���� ���
 	inc	dx	 	;��⠭���� ���� ᫥���饣�
 	 	 	 	;ॣ���� ���
 	loop	c17	 	;������ 蠡���� ��� ᫥���饣� ॣ����
 	not	al	 	  ;��� 蠡���� � 0
 	jz	c16

;   ���樠������ � ����� ���

 	mov	al,0ffh 	;��� ���稪� 64K ��� ॣ����樨
 	out	dma+1,al
 	out	dma+1,al
 	mov	al,058h 	;��� ०�� ���, ���稪 0, ���뢠���
 	out	dma+0bh,al	;������ � ॣ���� ०��� ���
 	mov	al,0	 	;����㯭���� ����஫��� ���
 	out	dma+8,al	;��� ॣ���� ������ ���
 	out	dma+10,al	;����㯭���� ������ 0 ��� ॣ����樨
 	mov	al,41h	 	;��� ०�� ��� ������ 1
 	out	dma+0bh,al
 	mov	al,42h	 	;��� ०�� ��� ������ 2
 	out	dma+0bh,al
 	mov	al,43h	 	;��� ०�� ��� ������ 3
 	out	dma+0bh,al
		mov	ax, dat
		mov	ds, ax
		
		mov	bx, ds:reset_flag
		sub	ax, ax
		mov	es, ax
		mov	ds, ax
		in	al, port_c
		and	al, 0Fh
		inc	al
		add	al, al
		mov	dx, 0
		mov	ah, al
		mov	al, 0
		cld

c19:
		sub	di, di
		mov	cx, 0

c20:
		stosb
		loop	c20
		add	dx, 4096
		mov	es, dx
		dec	ah
		jz	c21
		jmp	short c19
;____________________
;   ���樠������ ����஫���
;   ���뢠��� 8259
;____________________
c21:
 	mov	al,13h	 	;ICW1 - EDGE, SNGL, ICW4
 	out	inta00,al
 	mov	al,8	 	;��� ICW2 - ���뢠��� ⨯� 8(8-F)
 	out	inta01,al
 	mov	al,9	 	;��� ICW4 - BUFFERD , ०�� 8086
 	out	inta01,al
		sub	ax, ax
		mov	es, ax
		mov	si, dat
		mov	ds, si
		
		mov	ds:reset_flag, bx
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

;   ��⠭���� ᥣ���� �⥪� � SP

c25:
 	mov	ax,sta	 	;������� ����稭� �⥪�
 	mov	ss,ax	 	;��� �⥪
 	mov	sp,offset tos	;�⥪ ��⮢

;   ��⠭���� 㪠��⥫� ����� ���뢠��� NMI

 	mov	es:nmi_ptr,offset nmi_int
 	mov	es:nmi_ptr+2,cod
 	jmp	short tst6	;���室 � ᫥���饬� ����

ros_checksum proc  near
 	mov	cx,8192 	;�᫮ ���� ��� ᫮�����
 	xor	al,al
c26:	add	al,cs:[bx]
 	inc	bx	 	;㪠����� ᫥���饣� ����
 	loop	c26	 	;᫮���� �� ����� � ���㫥 ROS
 	or	al,al	 	;�㬬� = 0 ?
 	ret
ros_checksum endp
;______________________
;   ��砫�� ��� ���������
;______________________
 	assume	cs:code,es:abs0

d1		db 'parity check 2'


d1l	equ	14
d2		db 'parity check 1'


d2l	equ	14
;______________________
;   ����.06
;	 ���� ����஫��� ���뢠���
;	 8259
;_______________________
tst6:
 	sub	ax,ax	 	;��� ॣ���� ES
 	mov	es,ax

;-----��� ����� ���뢠��� 5

 	mov	es:int5_ptr,offset print_screen   ; ����� �࠭�
 	mov	es:int5_ptr+2,cod

;   �஢�ઠ ॣ���� ��᮪ ���뢠��� (IMR)

 	cli	 	 	;��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	al,0	 	;��� IMR � 0
 	out	inta01,al
 	in	al,inta01	;���뢠��� IMR
 	or	al,al	 	;IMR=0 ?
 	jnz	d6	 	;IMR �� 0,� �ணࠬ�� �訡��
 	mov	al,0ffh 	;������㯭���� ���뢠���
 	out	inta01,al	;������ � IMR
 	in	al,inta01	;���뢠��� IMR
 	add	al,1	 	;�� ���� IMR ��⠭������ ?
 	jnz	d6	 	;��� - � �ணࠬ�� �訡��

;   ����஫� �������� ���뢠���

 	cld	 	 	; ��� �ਧ��� ���ࠢ�����
 	mov	cx,8
 	mov	di,offset int_ptr	; ��� ������ ⠡����
d3:
 	mov	ax,offset d11	; ��⠭����� ���� ��楤��� ���뢠���
 	stosw
 	mov	ax,cod	; ������� ���� ᥣ���� ��楤���
 	stosw
 	add	bx,4	;��� BX ��� 㪠����� ᫥���饣� ���祭��
 	loop	d3

;   ���뢠��� ࠧ��᪨஢���

 	xor	ah,ah	 	;������ ॣ���� AH
 	sti	 	 	; ��⠭���� �ਧ���� ࠧ�襭�� ���뢠���
 	sub	cx,cx	 	; �������� 1 ᥪ ��� ���뢠���,
d4:	loop	d4	 	; ���஥ ����� �ந����
d5:	loop	d5
 	or	ah,ah	 	; ���뢠��� �������� ?
 	jz	d7	 	; ��� - � ᫥���饬� ����
d6:	mov	dx,101h 	; ��� ���⥫쭮�� ��㪮���� ᨣ����
 	call	err_beep	; ��� � �ணࠬ�� ��㪮���� ᨣ����
 	cli
 	hlt	 	 	; ��⠭�� ��⥬�
;__________________
;   ����.07
;	 �஢�ઠ ⠩��� 8253
;___________________
d7:
 	mov	ah,0	 	; ��� �ਧ���� ���뢠��� ⠩���
 	xor	ch,ch	 	; ������ ॣ���� CH
 	mov	al,0feh   ; ��᪨஢��� �� ���뢠���, �஬� LVL 0
 	out	inta01,al	; ������ IMR
 	mov	al,00010000b	; ����� TIM 0, LSD, ०�� 0, BINARY
 	out	tim_ctl,al  ;������� ॣ���� ०��� �ࠢ����� ⠩���
 	mov	cl,16h	 	; ��� ���稪 �ணࠬ����� 横��
 	mov	al,cl	 	; ��⠭����� ���稪 ⠩��� 0
 	out	timero,al	; ������� ���稪 ⠩��� 0
d8:	test	ah,0ffh 	; ���뢠��� ⠩��� 0 �ந��諮 ?
 	jnz	d9	 	; �� - ⠩��� ��⠫ ��������
 	loop	d8	 	; �������� ���뢠��� ��।������� �६�
 	jmp	short d6   ;���뢠��� ⠩��� 0 �� �ந��諮 - �訡��
d9:	mov	cl,18	 	; ��� ���稪 �ணࠬ����� 横��
 	mov	al,0ffh 	; ������� ���稪 ⠩��� 0
 	out	timero,al
 	mov	ah,0	 	; ��� �ਧ����,����祭���� ���뢠���
 	mov	al,0feh 	; ������㯭���� ���뢠��� ⠩��� 0
 	out	inta01,al
d10:	test	ah,0ffh 	; ���뢠��� ⠩��� 0 �ந��諮 ?
 	jnz	d6	 	; �� - ⠩��� ��⠥� �����
 	loop	d10	 	; �������� ���뢠��� ��।������� �६�
 	jmp	short tst8	 	; ���室 � ᫥���饬� ����
	nop
;____________________
;   �ணࠬ�� ���㦨�����
;   �६������ ���뢠���
;____________________
d11	proc	near
 	mov	ah,1
 	push	ax	 	; �࠭��� ॣ���� AX
 	mov	al,0ffh 	; ࠧ��᪨஢��� �� ���뢠���
 	out	inta01,al
 	mov	al,eoi
 	out	inta00,al
 	pop	ax	 	; ����⠭����� ॣ���� AX
 	iret
d11	endp

nmi_int proc	near
 	push	ax	 	; �࠭��� ॣ���� AX
 	in	al,port_c
 	test	al,40h	 	; �訡�� ����� �� �����/�뢮�� ?
 	jz	d12	 	; �� - �ਧ��� ���뢠���� � 0
 	mov	si,offset d1	; ���� ���� ᮮ�饭�� �� �訡��
 	mov	cx,d1l	 	; ����� ���� ᮮ�饭�� �� �訡��
 	jmp	short d13	; �⮡ࠧ��� �訡�� �� ��ᯫ��
d12:
 	test	al,80h
 	jz	d14
 	mov	si,offset d2	; ���� ���� ᮮ�饭�� �� �訡��
 	mov	cx,d2l	 	; ����� ���� ᮮ�饭�� �� �訡��
d13:
 	mov	ax,0	 	; ���樨஢��� � ��⠭����� ०�� ���
 	int	10h	 	; �맢��� ��楤��� VIDEO_IO
 	call	p_msg	 	; �ᯥ���� �訡��
 	cli
 	hlt	 	 	; ��⠭�� ��⥬�
d14:
 	pop	ax	 	; ����⠭����� AX
 	iret
nmi_int endp
;____________________
;   ��砫�� ��� ���������
;____________________
 	assume	cs:code,ds:data

e1	db	' 201'
e1l	equ	04h

;   �믮������ �ணࠬ�� �����,
;   ��������饩 ����� ���뢠���

tst8:
 	cld	 	 	; ��⠭����� �ਧ��� ���ࠢ����� ���।
 	mov	di,offset video_int   ; ��� ���� ������ ���뢠���
 	push	cs
 	pop	ds	 	; ��� ���� ⠡���� ����஢
 	mov	si,offset vector_table+20h  ; ᬥ饭�� VECTOR_TABLE+32
 	mov	cx,20h
 	rep	movsw	 	; ��।��� ⠡���� ����஢ � ������

;   ��⠭���� ⠩��� 0 � ०�� 3

 	mov	al,0ffh
 	out	inta01,al
 	mov	al,36h	 	; �롮� ���稪� 0,���뢠���-��-
; ��� ����襣�,��⥬ ���襣� ���� ���稪�,��� ०��� 3
 	out	timer+3,al	; ������ ०��� ⠩���
 	mov	al,0c7h
 	out	timer,al	; ������� ������� ���� ���稪�
 	mov	al,0dbh
 	out	timer,al	; ������� ������ ���� ���稪�


 	assume	ds:data
 	mov	ax,dat	 	; DS - ᥣ���� ������
 	mov	ds,ax
e3:
 	cmp	reset_flag,1234h
 	jz	e3a
 	call	bct	;����㧪� ������������ �/� ���
;_____________________
;   ����.08
;	 ���樠������ � �����
;	 ����஫��� ���
;______________________
e3a:	in	al,port_a	; ���뢠��� ���ﭨ� ��४���⥫��
 	mov	ah,0
 	mov	equip_flag,ax	; ��������� ��⠭��� ���ﭨ� ���-
 	 	 	 	; ����⥫��
 	and	al,30h	 	; �뤥���� ��४���⥫� ���
 	jnz	e7	 	; ��४���⥫� ��� ��⠭������ � 0 ?
 	jmp	e19	 	; �ய����� ��� ���
e7:
 	xchg	ah,al
 	cmp	ah,30h	 	; ������ �/� ?
 	je	e8	 	; �� - ��⠭����� ०�� ��� �/� ������
 	inc	al	 ; ��� 梥⭮� ०�� ��� 梥⭮�� ������
 	cmp	ah,20h	 	; ०�� 80�25 ��⠭����� ?
 	jne	e8	 	; ��� - ��� ०�� ��� 40�25
 	mov	al,3	 	; ��⠭����� ०�� 80�25
e8:
 	push	ax	 	; �࠭��� ०�� ��� � �⥪�
 	sub	ah,ah	 	;
 	int	10h
 	pop	ax
 	push	ax
 	mov	bx,0b000h
 	mov	dx,3b8h 	; ॣ���� ०��� ��� �/�
 	mov	cx,4096 	; ���稪 ���� ��� �/� ������
 	mov	al,1	 	; ��� ०�� ��� �/� ������
 	cmp	ah,30h	 	; �/� ������ ��� ������祭 ?
 	je	e9	 	; ���室 � �஢�થ ���� ���
 	mov	bx,0b800h
 	mov	dx,3d8h 	; ॣ���� ०��� ��� 梥⭮�� ������
 	mov	cx,4000h
 	dec	al	 	; ��� ०�� � 0 ��� 梥⭮�� ������
;
;	�஢�ઠ ���� ���
;
e9:
 	out	dx,al	 	; �����஢�� ��� ��� 梥⭮�� ������
 	mov	es,bx
 	mov	ax,dat	 	; DS - ᥣ���� ������
 	mov	ds,ax
 	cmp	reset_flag,1234h
 	je	e10
 	mov	ds,bx	 	;
 	call	stgtst_cnt	; ���室 � �஢�થ �����
 	je	e10
 	mov	dx,102h
 	call	err_beep

;___________________________
;
;   ����.09
;	 �����⢫�� �஢��� �ନ஢���� ��ப � ���� ���
;_________________________
e10:
 	pop	ax   ; ������� ��⠭�� ��४���⥫� ��� � AH
 	push	ax	 	; ��࠭��� ��
 	mov	ah,0
 	int	10h
 	mov	ax,7020h	; ������ �஡���� � ०��� ॢ���
 	sub	di,di	 	; ��⠭���� ��砫� ������
 	mov	cx,40	 	;
 	cld	    ; ��⠭����� �ਧ��� ���ࠢ����� ��� 㬥��襭��
 	rep	stosw	 	; ������� � ������
;______________________
;    ����.10
;	  �����⢫�� �஢��� ����� ����䥩� ���
;______________________
 	pop	ax	 	; ������� ��⠭�� ��४���⥫�
 	push	ax	 	; ��࠭��� ��
 	cmp	ah,30h	 	; �/� ������ ������祭 ?
 	mov	dx,03bah	; ��� ���� ���� ���ﭨ� �/� ��ᯫ��
 	je	e11	 	; �� - ���室 � ᫥���饩 ��ப�
 	mov	dx,03dah	; 梥⭮� ������ ������祭
;
;	���� ���筮� ࠧ���⪨
;
e11:
 	mov	ah,8
e12:
 	sub	cx,cx
e13:	in	al,dx	    ;���뢠��� ���� ���ﭨ� ����஫��� ��607
 	and	al,ah	 	; �஢�ઠ ��ப�
 	jnz	e14
 	loop	e13
 	jmp	short e17	; ���室 � ᮮ�饭�� �� �訡��
e14:	sub	cx,cx
e15:	in	al,dx	  ;���뢠��� ���� ���ﭨ� ����஫��� ��607
 	and	al,ah
 	jz	e16
 	loop	e15
 	jmp	short e17
;
;	������騩 ����� ������
;
e16:
 	mov	cl,3	 	; ������� ᫥���騩 ��� ��� ����஫�
 	shr	ah,cl
 	jnz	e12
 	jmp	short e18	; �⮡ࠧ��� ����� �� �࠭�
;
;	����饭�� �� �訡�� �����஫��� ��607
;
e17:
 	mov	dx,103h
 	call	err_beep
;
;	�⮡ࠦ���� ����� �� �࠭�
;
e18:
 	pop	ax	 	; ������� ��⠭�� ��४���⥫� � AH
 	mov	ah,0	 	; ��⠭����� ०��
 	int	10h
;______________________
;   ����.11
;	 �������⥫�� ��� �����
;______________________
 	assume	ds:data
e19:
 	mov	ax,dat
 	mov	ds,ax
		in	al, port_c
		and	al, 0Fh
		inc	al
		mov	ah, 80h
		mul	ah
		mov	ds:io_ram_size,	ax ; Reserved in original IBM PC
		mov	dx, ax
		mov	ds:memory_size,	ax
 	cmp	reset_flag,1234h
 	je	e22

;   �஢�ઠ �� ����⢨⥫쭮� �����
;   �� ���뢠��� � ������

 	jmp	e190

;   ����� ���� � �⠫���, �᫨
;   �ந��諠 �訡�� ������


osh:
 	mov	ch,al	 	;
 	mov	al,dh	 	; ������� ��������� ����
 	mov	cl,4
 	shr	al,cl	 	;
 	call	xlat_print_cod	; �८�ࠧ������ � ����� ����
 	mov	al,dh
 	and	al,0fh
 	call	xlat_print_cod	; �८�ࠧ������ � ����� ����
 	mov	al,ch	 	; ������� ᫥���騩 蠡���
 	mov	cl,4
 	shr	al,cl
 	call	xlat_print_cod	; �८�ࠧ������ � ����� ����
 	mov	al,ch	 	;
 	and	al,0fh	 	;
 	call	xlat_print_cod	; �८�ࠧ������ � ����� ����
 	mov	si,offset e1	; ��⠭����� ���� ���� ᮮ�饭��
 	 	 	 	; �� �訡��
 	mov	cx,e1l	 	; ������� ���稪 ���� ᮮ�饭�� �� �訡��
 	call	p_msg	 	; ����� �訡��
e22:
 	jmp	short tst12	 	; ���室 � ᫥���饬� ����
	nop
;_____________________
;
;   ��楤�� �뢮�� �� �࠭ ᮮ�饭�� �� �訡�� � ���� ASCII
;
;_______________________

xlat_print_cod proc near
 	push	ds	 	; ��࠭��� DS
 	push	cs
 	pop	ds
 	mov	bx,offset f4e	; ���� ⠡���� ����� ASCII
 	xlatb
 	mov	ah,14
 	mov	bh,0
 	int	10h
 	pop	ds
 	ret
xlat_print_cod endp
;______________________
;   ���� ��⥬� - 䠧� 4
;______________________
;
;   ���� ᮮ�饭�� �� �訡���
;_______________________

 	assume	cs:code,ds:data
f1	db	' 301'
f1l	equ	4h	 	; ᮮ�饭�� ����������
f2	db	'131'
f2l	equ	3h	 	; ᮮ�饭�� ������
f3	db	'601'
f3l	equ	3h	 	; ᮮ�饭�� ����

f4	label	word
 	dw	378h
f4e	label	word
ascii_tbl db	'0123456789abcdef'


;______________________
;   ����.12
;   ���� ����������
;______________________
tst12:

 	mov	ax,dat
 	mov	ds,ax
 	call	kbd_reset	; ���� ����������
 	mov	al,4dh	 	; ����㯭���� ����������
 	out	port_b,al
	jcxz	f6	 	; ��� - ����� �訡��
 	cmp	bl,0aah 	; ��� ᪠��஢���� 'AA' ?
 	jne	f6	 	; ��� - ����� �訡��

;   ���� "�������" ������

 	mov	al,0cch       ; ��� ����������, ��� ᨭ�஭���樨
 	out	port_b,al
 	mov	al,4ch	      ; ����㯭���� ����������
 	out	port_b,al
 	sub	cx,cx
;
;	�������� ���뢠��� ����������
;
f5:
 	loop	f5	 	; ����প�
 	in	al,kbd_in	; ����祭�� ���� ᪠��஢����
 	cmp	al,0	 	; ��� ᪠��஢���� ࠢ�� 0 ?
 	je	f7	 	; �� - �த������� ���஢����
 	mov	ch,al	 	; ��࠭��� ��� ᪠��஢����
 	mov	cl,4
 	shr	al,cl
 	call	xlat_print_cod	; �८�ࠧ������ � �����
 	mov	al,ch	 	; ����⠭����� ��� ᪠��஢����
 	and	al,0fh	 	; �뤥���� ����訩 ����
 	call	xlat_print_cod	; �८�ࠧ������ � �����
f6:	mov	si,offset f1	; ������� ���� ���� ᮮ�饭�� ��
 	 	 	 	; �訡��
 	mov	cx,f1l	 	 ; ����� ���� ᮮ�饭�� �� �訡��
 	call	p_msg	 	 ; �뢮� ᮮ�饭�� �� �訡�� �� �࠭

;   ��⠭���� ⠡���� ����஢ ���뢠���

f7:
 	sub	ax,ax
 	mov	es,ax
 	mov	cx,24*2 	; ������� ���稪 ����஢
 	push	cs
 	pop	ds
 	mov	si,offset vector_table	 ; ���� ⠡���� ����஢
 	mov	di,offset int_ptr
 	cld
 	rep	movsw
;______________________
;   ����.14
;   �����⢫�� �஢��� ����
;______________________
	mov	ax,dat	 	; ���. ॣ���� DS
 	mov	ds,ax
 	mov	al,0fch  ; ����㯭���� ���뢠��� ⠩��� � ����������
 	out	inta01,al
 	mov	al,byte ptr equip_flag	; ������� ���ﭨ� ��४��-
 	 	 	 	 	; �⥫��
 	test	al,01h	 	; ��ࢮ��砫쭠� ����㧪� � ���� ?
 	jnz	f10	 	; �� - �஢�ઠ �ࠢ����� ����
 	jmp	f23
f10:
 	mov	al,0bch 	; ����㯭���� ���뢠��� � ����,
 	out	inta01,al	; ���������� � ⠩���
 	mov	ah,0	 	; ��� ����஫��� ����
 	int	13h	 	; ���室 � ���� ����
 	test	ah,0ffh 	; ���ﭨ� ��୮ ?
 	jnz	f13	 	; ��� - ᡮ� ���ன�⢠

;   ������� ���� ���ன�⢠ 0

 	mov	dx,03f2h	; ������� ���� ������ ����
 	mov	al,1ch	 	; ������� ����
 	out	dx,al
 	sub	cx,cx

;    �������� ����祭�� ���� ����

f11:
 	loop	f11
f12:	 	 	 	; �������� ���� 1
 	loop	f12
 	xor	dx,dx
 	mov	ch,1	 	; �롮� ��ࢮ� ��஦��
 	mov seek_status,dl
 	call	seek	 	; ���室 � ४����஢�� ����
 	jc	f13	 	; ��३� � �ணࠬ�� �訡��
 	mov	ch,34	 	; �롮� 34 ��஦��
 	call	seek
 	jnc	f14	 	; �몫���� ����

;    �訡�� ����

f13:
 	mov	si,offset f3	; ������� ���� ���� ᮮ�饭�� ��
 	 	 	 	; �訡��
 	mov	cx,f3l	 	; ��⠭����� ���稪
 	call	p_msg	 	; ��� � �ணࠬ�� �訡��

;   �몫���� ���� ���ன�⢠ 0

f14:
 	mov	al,0ch	 	; �몫���� ���� ���ன�⢠ 0
 	mov	dx,03f2h	; ��� ���� ���� �ࠢ����� ����
 	out	dx,al

;   ��⠭���� ���� � �������� ����
;   ������ ��몠 �2, �᫨ ���ன�⢠ ������祭�

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
 	mov	bp,offset f4	; ⠡��� PRT_SRC
 	mov	si,0
f16:
 	mov	dx,cs:[bp]	; ������� ������ ���� ����
 	mov	al,0aah 	; ������� ����� � ���� �
 	out	dx,al
 	sub	al,al
 	in	al,dx	 	; ���뢠��� ���� �
 	cmp	al,0aah 	; 蠡��� ������ �� ��
 	jne	f17	    ; ��� - �஢�ઠ ᫥���饣� ���ன�⢠ ����
 	mov	word ptr printer_base[si],dx  ;��-��� ������ ����
 	inc	si	 	; ���᫥��� ᫥���饣� ᫮��
 	inc	si
f17:
 	inc	bp	 	; 㪠���� ᫥���騩 ������ ����
 	inc	bp
 	cmp	bp,offset f4e	; �� �������� ���� �஢�७� ?
 	jne	f16	 	; ���, � �஢�થ ᫥���饣� ���� ����
 	mov	bx,0
 	mov	dx,3ffh 	; �஢�ઠ ������祭�� ������ 1 ��몠 �2
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
 	mov  word ptr rs232_base[bx],3f8h  ; ��� ���� ������ 1
 	inc	bx
 	inc	bx
f18:	mov	dx,2fch 	; �஢�ઠ ������祭�� ������ 2 ��몠 �2
 	mov	al,0aah
 	out	dx,al
 	inc	dx
		xor	ax, ax
		out	dx, al
 	in	al,dx
 	cmp	al,0aah
 	jnz	f19
 	mov  word ptr rs232_base[bx],2f8h   ; ��� ���� ������ 2
 	inc	bx
 	inc	bx



;_____��⠭���� EQUIP_FLAG ��� ����-
;     ��樨 ����� ����

f19:
		jmp	f19a

f19b:
 	ror	al,cl
 	or	al,bl
 	mov	byte ptr equip_flag+1,al
 	mov	dx,201h
 	in	al,dx
 	test	al,0fh
 	jnz	f20	 	 	   ; �஢�ઠ ������ ���
 	or	byte ptr equip_flag+1,16
f20:
		jmp	f20a
		nop

f20b:
		mov	dx, 1
 	call	err_beep	; ���室 � ����ணࠬ�� ��㪮���� ᨣ����
f21:
		jmp	boot_strap

f23:
 	jmp	f15

;    ��⠭���� ���⥫쭮�� ��㪮���� ᨣ����

 	assume	cs:code,ds:data
err_beep proc	near
 	pushf	 	 	; ��࠭��� �ਧ����
 	cli	 	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	push	ds	 	; ��࠭��� DS
 	mov	ax,dat	 	; DS - ᥣ���� ������
 	mov	ds,ax
 	or	dh,dh
 	jz	g3
g1:	 	 	 	 ; ������ ��㪮��� ᨣ���
 	mov	bl,6	 	 ; ���稪 ��� ��㪮��� ᨣ�����
 	call	beep	 	 ; �믮����� ��㪮��� ᨣ���
g2:	loop	g2	 	 ; ����প� ����� ��㪮�묨 ᨣ������
 	dec	dh
 	jnz	g1
g3:	 	 	 	 ; ���⪨� ��㪮��� ᨣ���
 	mov	bl,1   ; ���稪 ��� ���⪮�� ��㪮���� ᨣ����
 	call	beep	 	; �믮����� ��㪮��� ᨣ���
g4:	loop	g4	 	; ����প� ����� ��㪮�묨 ᨣ������
 	dec	dl	 	;
 	jnz	g3	 	; �믮�����
g5:	loop	g5	 	; ������� ����প� ��। �����⮬
g6:	loop	g6
 	pop	ds	 	; ����⠭������� DS
 	popf	 	   ; ����⠭������� ��ࢮ��砫��� �ਧ�����
 	ret	 	 	; ������ � �ணࠬ��
err_beep	endp

;   ����ணࠬ�� ��㪮���� ᨣ����

beep	proc	near
 	mov	al,10110110b	; ⠩��� 2,����訩 � ���訩 ���-
 	 	 	 	; 稪�, ������ ���
 	out	timer+3,al	; ������� � ॣ���� ०���
 	mov	ax,45eh 	; ����⥫�
 	out	timer+2,al	; ������� ����訩 ���稪
 	mov	al,ah
 	out	timer+2,al	; ������� ���訩 ���稪
 	in	al,port_b	; ������� ⥪�饥 ���ﭨ� ����
 	mov	ah,al	 	; ��࠭��� �� ���ﭨ�
 	or	al,03	 	; ������� ���
 	out	port_b,al
 	sub	cx,cx	 	; ��⠭����� ���稪 ��������
g7:	loop	g7	 	; ����প� ��। �몫�祭���
 	dec	bl	 	; ����প� ���稪� �����祭� ?
 	jnz	g7	; ��� - �த������� ����� ��㪮���� ᨣ����
 	mov	al,ah	 	; ����⠭����� ���祭�� ����
 	out	port_b,al
 	ret	 	 	; ������ � �ணࠬ��
beep	endp
;_____________________
;   �� ��楤�� ��뢠�� �ணࠬ���
;   ��� ����������
;_____________________
kbd_reset proc	near
 	mov	al,0ch	   ; ��⠭����� ������ �஢��� ᨭ�஭���樨
 	out	port_b,al	; ������� ���� B
 	mov	cx,30000	; �६� ���⥫쭮�� ������� �஢��
g8:	loop	g8
 	mov	al,0cch 	; ��� CLK
 	out	port_b,al
sp_test:
 	mov	al,4ch	 	; ��� ��᮪�� �஢��� ᨭ�஭���樨
 	out	port_b,al
 	mov	al,0fdh 	; ࠧ���� ���뢠��� ����������
 	out	inta01,al	; ������� ॣ���� ��᮪
 	sti	 	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	ah,0
 	sub	cx,cx	 	; ��� ���稪� �������� ���뢠���
g9:	test	ah,0ffh 	; ���뢠��� ���������� �������� ?
 	jnz	g10   ;  �� - ���뢠��� �����饭���� ���� ᪠��஢����
 	loop	g9	 	; ��� - 横� ��������
g10:	in	al,port_a   ; ����� ��� ᪠��஢���� ����������
 	mov	bl,al	 	; ��࠭��� ��� ���
 	mov	al,0cch 	; ���⪠ ����������
 	out	port_b,al
 	ret	 	 	; ������ � �ணࠬ��
kbd_reset	endp
;_____________________
;   �� �ணࠬ�� �뢮��� �� �࠭ ��ᯫ��
;   ᮮ�饭�� �� �訡���
;
;     ����室��� �᫮���:
;   SI = ���� ���� ᮮ�饭�� �� �訡��
;   CX = ����� ���� ᮮ�饭�� �� �訡��
;   ���ᨬ���� ࠧ��� ��।�������
;   ���ଠ樨 - 36 ������
;
;______________________
p_msg	proc	near
 	mov	ax,dat
 	mov	ds,ax
 	mov	bp,si
g12:
 	mov	al,cs:[si]	; �������� ���� � AL
 	inc	si	 	; 㪠���� ᫥���騩 ����
 	mov	bh,0	 	; ��⠭����� ��࠭���
 	mov	ah,14	 	; ��� �㭪�� ����� �����
 	int	10h	 	; � ������� ����
 	loop	g12	; �த������ �� ����� �ᥣ� ᮮ�饭��
 	mov	ax,0e0dh   ; ��६����� ����� � ��砫� ��ப�
 	int	10h
 	mov	ax,0e0ah  ; ��६����� ����� �� ᫥������ ��ப�
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
		mov	dx, ds
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

;   ������ ����� ���᪨� ������ �㪢 (���������)

rust2	label	byte
 	db	1bh,'!@#$',37,05eh,'&*()_+'


 	db	08h,0
 	db	0b9h,0c6h,0c3h,0bah,0b5h,0bdh,0b3h,0c8h

 	db	0c9h,0b7h,0b6h,0cdh,0dh,-1,0c4h,0cbh

 	db	0b2h,0b0h,0bfh,0c0h,0beh,0bbh,0b4h,27h

 	db	'"',0b1h,0ceh,7ch,0cfh,0c7h,0c1h,0bch,0b8h

 	db	0c2h,0cch,'<>?',0c5h,000,-1,' ',0cah




;___int 19_____________
;   �ணࠬ�� ����㧪� ��⥬� � ����
;
; �ணࠬ�� ���뢠�� ᮤ�ন��� ��஦�� 0 ᥪ�� 1 �
; �祩�� boot_locn (���� 7C00,ᥣ���� 0)
;   �᫨ ���� ��������� ��� �ந��諠 �����⭠� �訡��,
; ��⠭���������� ���뢠��� ⨯� INT 18H, ���஥ ��뢠��
; �믮������ �ணࠬ� ���஢���� � ���樠����樨
; ��⥬�
;
;_________________________
 	assume	cs:code,ds:data
boot_strap proc near

 	sti	 	      ; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	mov	ax,dat	      ; ��⠭����� ������
 	mov	ds,ax
 	mov	ax,equip_flag ; ������� ���ﭨ� ��४���⥫��
 	test	al,1	      ; ���� ��ࢮ��砫쭮� ����㧪�
 	jz	h3

;   ���⥬� ����㦠���� � ����
;   CX ᮤ�ন� ���稪 ����७��

 	mov	cx,4	 	; ��⠭����� ���稪 ����७��
h1:	 	 	 	; ��ࢮ��砫쭠� ����㧪�
 	push	cx	 	; ��࠭��� ���稪 ����७��
 	mov	ah,0	 	; ��� ����
 	int	13h
 	jc	h2	 	; �᫨ �訡��,�������
 	mov	ah,2	 	; ����� ᥪ�� 1
 	mov	bx,0	 	;
 	mov	es,bx
 	mov	bx,offset boot_locn
 	mov	dx,0	 	;
 	mov	cx,1	 	; ᥪ�� 1 , ��஦�� 0
 	mov	al,1	 	; ���뢠��� ��ࢮ�� ᥪ��
 	int	13h
h2:	pop	cx	 	; ����⠭����� ���稪 ����७��
 	jnc	h4	 	; ��� CF �� ����ᯥ譮� ���뢠���
 	loop	h1	 	; 横� ����७��

;   ����㧪� � ���� ������㯭�

h3:	 	 	 	; �����
 	jmp	err01	; ��������� ��᪥� ����㧪�

;   ����㧪� �����訫��� �ᯥ譮

h4:					; 
		jmp far ptr boot_locn 	; db 0EAh, 00h, 7Ch, 00h, 00h	; (0000:7C00)	; ###Gleb###

boot_strap	endp
;--------------------
;   �� �ணࠬ�� ���뫠�� ���� � ����஫��� ������ ����
; ��᫥ �஢�ન ���४⭮�� �ࠢ����� � ��⮢����
; ����஫���.
;   �ணࠬ�� ������� ���� ���ﭨ� ��।������� �६�
; � �஢���� ��⮢����� ���� � ࠡ��.
;
;   ����   (AH) - �뢮���� ����
;
;   �����  CY=0 - �ᯥ譮,
;	   CY=1 - �� �ᯥ譮.����ﭨ�
;	   ���� ������������.
;-----------------------
nec_output proc near
 	push	dx	 	; ��࠭��� ॣ�����
 	push	cx
 	mov	dx,03f4h	; ���ﭨ� ����
 	xor	cx,cx	 	; ���稪 �६��� �뢮��
j23:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,040h 	; �஢�ઠ �ࠢ����� ���
 	jz	j25	 	; ���� �ࠢ����� ��ଠ���
 	loop	j23
j24:
 	or	diskette_status,time_out
 	pop	cx
 	pop	dx	; ��⠭����� ��� �訡�� � ����⠭����� ॣ�����
 	pop	ax	 	; ���� ������
 	stc	 	 	;
 	ret

j25:
 	xor	cx,cx	 	; ���㫥��� ���稪�
j26:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,080h 	; �஢�ઠ ��⮢����
 	jnz	j27	 	; �� - ��� �� ��室
 	loop	j26	 	; �������
 	jmp	short j24	; �訡�� ���ﭨ�
j27:	 	 	 	; ��室
 	mov	al,ah	 	; ������� ����
 	mov	dx,03f5h	; ���᫠�� ���� ������ � ����
 	out	dx,al
 	pop	cx	 	; ����⠭����� ॣ�����
 	pop	dx
 	ret	 	 	;
nec_output	endp

;___int 16_________________
;
;   �ணࠬ�� �����প� ����������
;
;   �� �ணࠬ�� ���뢠�� � ॣ����
; AX ��� ᪠��஢���� ������ � ���
; ASCII �� ���� ����������.
;
;   �ணࠬ�� �믮���� �� �㭪樨, ���
; ������ �������� � ॣ���� AH:
;
;    AH=0 - ����� ᫥���騩 ᨬ���
;	     �� ����.�� ��室� ���
;	     ᪠��஢���� � AH,���
;	     ASCII � AL.
;   AH=1 - ��⠭����� ZF, �᫨ ���
;	     ASCII ���⠭:
;
;	     ZF=0 - ���� ��������,
;	     ZF=1 - ���� ���⮩.
;   �� ��室� � AX ����饭 ���� ���設� ���� ����������.
;   AH=2 - ������ ⥪�饣� ���ﭨ� � ॣ���� AL
;	      �� ����ﭭ� ��।������� ������ ����� �
;	   ���ᮬ 00417H.
;
;   �� �믮������ �ணࠬ� ���������� �ᯮ������� 䫠���,
; ����� ��⠭���������� � ����ﭭ� ��।������� ������
; ����� �� ���ᠬ 00417H � 00418H � ����� ���祭��:
;   00417H
;	  0 - �ࠢ�� ��४��祭�� ॣ����;
;	  1 - ����� ��४��祭�� ॣ����;
;	     2 - ���;
;	  3 - ���;
;	  4 - ���;
;	  5 - ���;
;	  6 - ���;
;	  7 - ���;
;   00418H
;	  0 - ���ﭨ� ������ ��� ����� ����⨥� � �⦠⨥�;
;	  1 - ���;
;	  2 - �/�;
;	  3 - ��㧠;
;	  4 - ���;
;	  5 - ���;
;	  6 - ���;
;	  7 - ���.
;
;   ������, ᮮ⢥�����騥 ࠧ�鸞� 4-7 ����ﭭ� ��।�������
; ������ ����� � ���ᮬ 00417H, ��⠭���������� �� ������
; ������ ���, ���, ���, ��� � ��࠭��� ᢮� ���祭�� �� ᫥-
; ���饣� ������ ᮮ⢥�����饩 ������.
; ���������� 䫠���, ᮮ⢥�����騥 ࠧ�鸞� 4-7 ����ﭭ�
; ��।������� ������ ����� � ���ᮬ 00418H, � 䫠���
; ���, ���, ����� ��४��祭�� ॣ����, �ࠢ�� ��४��祭��
; ॣ����, �/� ��⠭���������� �� ������ ������ � ���뢠����
; �� �⦠��.
;
;------------------------------
 	assume	cs:code,ds:data


k4	proc	near
 	add	bx,2
 	cmp  bx, offset kb_buffer_end	 	 ; ����� ���� ?
 	jne	k5	 	 	 ; ��� - �த������
 	mov	bx, offset kb_buffer 	 ; �� - ��� ��砫� ����
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
 	mov	ds,bx	 	; ��⠭����� ᥣ���� ������
 	or	ah,ah	 	; AH=0
 	jz	k1	     ; ���室 � ���뢠��� ᫥���饣� ᨬ����
 	dec	ah	 	; AH=1
 	jz	k2	     ; ���室 � ���뢠��� ���� ASCII
 	dec	ah	 	     ; AH=2
 	jz	k3	     ; ���室 � ����祭�� ���� ���ﭨ�
 	pop	bx	 	     ; ����⠭����� ॣ����
 	pop	ds
 	iret

;   ���뢠��� ���� ᪠��஢���� � ���� ASCII �� ���� ����������
;
k1:
 	sti	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	nop	 	 	; ����প�
 	cli	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	bx,buffer_head	; ��� ���設� ���� �� �⥭��
 	cmp	bx,buffer_tail	; �ࠢ���� � ���設�� ���� �� �����
 	jz	k1
 	mov	ax,word ptr [bx] ; ������� ��� ᪠��஢���� � ��� ASCII
 	call	k4
 	mov	buffer_head,bx	; ��������� ���設� ���� �� �⥭��
 	pop	bx	 	; ����⠭����� ॣ����
 	pop	ds	 	; ����⠭����� ᥣ����
 	iret	 	 	; ������ � �ணࠬ��

;   ����� ��� ASCII

k2:
 	cli	 	; ���� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	bx,buffer_head	; ������� 㪠��⥫� ���設� ����
 	 	 	 	; �� �⥭��
 	cmp	bx,buffer_tail	; �ࠢ���� � ���設�� ���� �� �����
 	mov	ax,word ptr [bx]
 	sti	 	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	pop	bx	 	; ����⠭����� ॣ����
 	pop	ds	 	; ����⠭����� ᥣ����
 	ret	2

;   ����祭�� ����襣� ���� ���ﭨ� (䫠����)

k3:
 	mov	al,kb_flag	; ������� ����訩 ���� ���ﭨ�     ��
 	pop	bx	 	; ����⠭����� ॣ����
 	pop	ds	 	; ����⠭����� ᥣ����
 	iret	 	 	; ������ � �ணࠬ��
keyboard_io	endp

;   ������ ����� ᪠��஢���� �ࠢ����� ������

k6	label	byte
 	db	ins_key
 	db	caps_key,num_key,scroll_key,alt_key,ctl_key
 	db	left_key,right_key
 	db	inv_key_l
 	db	inv_key_r,lat_key,rus_key
k6l	equ	0ch

;   ������ ��᮪ ������� �ࠢ����� ������

k7	label	byte
 	db	ins_shift
 	db	caps_shift,num_shift,scroll_shift,alt_shift,ctl_shift
 	db	left_shift,right_shift


;   ������ ����� ᪠��஢���� �� ����⮩ ������ ��� ���
; ����� ᪠��஢���� ������ ����� 59

k8	db	27,-1,0,-1,-1,-1,30,-1

 	db	-1,-1,-1,31,-1,127,-1,17

 	db	23,5,18,20,25,21,9,15

 	db	16,27,29,10,-1,1,19

 	db	4,6,7,8,10,11,12,-1,-1

 	db	-1,-1,28,26,24,3,22,2

 	db	14,13,-1,-1,-1,-1,-1,-1

 	db	' ',-1

;   ������ ����� ᪠��஢���� �� ����⮩ ������ ��� ���
; ����� ᪠��஢���� ������ ����� 59
k9	label	byte
 	db	94,95,96,97,98,99,100,101

 	db	102,103,-1,-1,119,-1,132,-1

 	db	115,-1,116,-1,117,-1,118,-1

 	db	-1

;   ������ ����� ASCII ������� ॣ���� ����������

k10	label	byte
 	db	27,'1234567890-='


 	db	08h,09h
 	db	'qwertyuiop[]',0dh,-1,'asdfghjkl;:',60h,7eh




 	db	05ch,'zxcvbnm',',./{'

 	db	'*',-1,' }'

;   ������ ����� ASCII ���孥�� ॣ���� ����������

k11	label	byte
 	db	27,'!@#$',37,05eh,'&*()_+'


 	db	08h,0
 	db	'QWERTYUIOP',-1,-1,0dh,-1


 	db	'ASDFGHJKL'

 	db	027h,'"',-1,-1,7ch
 	db	'ZXCVBNM'

 	db	'<>?',-1,0,-1,' ',-1


;   ������ ����� ᪠��஢���� ������ �11 - �20 (�� ���孥�
; ॣ���� �1 - �10)

k12	label	byte
 	db	84,85,86,87,88,89,90

 	db	91,92,93

;   ������ ����� ᪠��஢���� �����६���� ������� ������
; ��� � �1 - �10

k13	label byte
 	db	104,105,106,107,108
 	db	109,110,111,112,113

;   ������ ����� �ࠢ��� ��⭠��⨪����譮�� ���� �� ���孥�
; ॣ����

k14	label	byte
 	db	'789-456+1230.'



;   ������ ����� �ࠢ��� ��⭠��⨪����譮�� ���� �� ������
; ॣ����

k15	label byte
 	db	71,72,73,-1,75,-1,77

 	db	-1,79,80,81,82,83

		db 9 dup(0)

;----INT 9--------------------------
;
;    �ணࠬ�� ��ࠡ�⪨ ���뢠��� ����������
;
; �ணࠬ�� ���뢠�� ��� ᪠��஢���� ������ � ॣ���� AL.
; �����筮� ���ﭨ� ࠧ�鸞 7 � ���� ᪠��஢���� ����砥�,
; �� ������ �⦠�.
;   � १���� �믮������ �ணࠬ�� � ॣ���� AX �ନ�����
; ᫮��, ���訩 ���� ���ண� (AH) ᮤ�ন� ��� ᪠��஢����,
; � ����訩 (AL) - ��� ASCII. �� ���ଠ�� ����頥��� � ����
; ����������. ��᫥ ���������� ���� �������� ��㪮��� ᨣ���.
;
;-----------------------------------

kb_int proc far
 	sti	 	   ; ��⠭���� �ਧ���� ࠧ�襭�� ���뢠���
 	push	ax
 	push	bx
 	push	cx
 	push	dx
 	push	si
 	push	di
 	push	ds
 	push	es
 	cld	 	       ; ��⠭����� �ਧ��� ���ࠢ����� ���।
 	mov	ax,dat	       ; ��⠭����� ������
 	mov	ds,ax
 	in	al,kb_dat      ; ����� ��� ᪠��஢����
 	push	ax
 	in	al,kb_ctl      ; ����� ���祭�� ���� 61
 	mov	ah,al	       ; ��࠭��� ��⠭��� ���祭��
 	or	al,80h	       ; ��⠭����� ��� 7 ���� 61
 	out	kb_ctl,al      ; ��� ࠡ��� � ��������ன
 	xchg	ah,al	       ; ����⠭����� ���祭�� ���� 61
 	out	kb_ctl,al
 	pop	ax	       ; ����⠭����� ��� ᪠��஢����
 	mov	ah,al	       ; � ��࠭��� ��� � AH

;---

 	cmp	al,0ffh  ; �ࠢ����� � ����� ���������� ����
 	 	 	 ; ����������
 	jnz	k16	 	; �த������
 	jmp	k62	; ���室 �� ��㪮��� ᨣ��� �� ����������
 	 	 	; ���� ����������

k16:
 	and	al,07fh 	; ��� ��� �⦠�� ������
 	push	cs
 	pop	es
 	mov	di,offset k6  ; ��⠭����� ���� ⠡���� ᪠��஢����
 	 	 	      ; �ࠢ����� ������
 	mov	cx,k6l
 	repne scasb	; �ࠢ����� ����祭���� ���� ᪠-
 	 	 	; ��஢���� � ᮤ�ন�� ⠡����
 	mov	al,ah	 	; ��������� ��� ᪠��஢����
 	je	k17	 	; ���室 �� ᮢ�������
 	jmp	k25	 	; ���室 �� ��ᮢ�������
k406:
 	test	kb_flag_1,lat
 	jnz	k26a
 	test	kb_flag,left_shift+right_shift
 	mov	ax,5cf1h
 	jz	k407
 	mov	ax,5cf0h

;   ����祭�� ��᪨ ����⮩ �ࠢ���饩 ������

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
 	test	al,80h	 	; ������ �⦠� ?
 	jnz	k23	; ���室, �᫨ ������ �⦠�

;   ��ࠢ����� ������ �����

 	cmp	ah,scroll_shift ; ����� �ࠢ����� ������ �
 	 	 	 	;  ������������ ?
 	jae	k18	 	; ���室, �᫨ ��

;---
 	cmp	ah,6
 	je	k302

 	or	kb_flag,ah	; ��⠭���� ��᮪ �ࠢ����� ������
 	 	 	 	; ��� �����������
 	jmp	k26	 	; � ��室� �� ���뢠���
k302:	or	kb_flag_1,inv_shift+lat
 	test	kb_flag_1,lat_shift
 	jz	k26a
 	and	kb_flag_1,not lat
k26a:
 	jmp	k26

;   ���� ������ ������ � ������������

k18:
 	test	kb_flag,ctl_shift	  ; ���� ������ ���
 	jnz	k25
 	cmp	al,ins_key	 	  ; ���� ������ ���
 	jnz	k22
 	test	kb_flag,alt_shift	  ; ���� ������ ���
 	jz	k19
		jmp	short k25
		nop
k19:	test	kb_flag,num_state  ; ���� ������ ���
 	jnz	k21
 	test	kb_flag,left_shift+right_shift ; ���� ������ ������
 	 	 	     ; � �ࠢ��� ��४��祭�� ॣ���஢
 	jz	k22

k20:
 	mov	ax,5230h
 	jmp	k57	      ; ��⠭���� ���� ���
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

;   ��ࠢ����� ������ �⦠�

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
;   �ணࠬ�� ���㦨����� ������⥫� �� ������ �����⭮�
; ��᪥ �믮���� ���� �㭪権, ��� ������ ��������
; � ॣ���� AH:
;   AH=0 - �����  ����;
;   AH=1 - ����� ���� ���ﭨ� ����. ����ﭨ� ᮮ⢥�����
; ��᫥���� �믮��塞�� ����樨 � ��।����� � ॣ���� AL ��
; ����ﭭ� ��।������� ������ ����⨢��� ����� � ���ᮬ
; 00441H;
;    AH=2H - ����� 㪠����� ᥪ�� � ������;
;    AH=3H - ������� 㪠����� ᥪ�� �� �����;
;    AH=4H - ���䨪���;
;    AH=5H - �ଠ⨧���.
;    ��� �믮������ �㭪権 �����, ���뢠���, ���䨪�樨,
; �ଠ⨧�樨 � ॣ����� �������� ᫥����� ���ଠ��:
;    DL - ����� ���ன�⢠ (0-3, ����஫��㥬�� ���祭��);
;    DH - ����� ������� (0-1, ������஫��㥬�� ���祭��);
;    CH - ����� ��஦�� (0-39, ������஫��㥬�� ���祭��);
;    CL - ����� ᥪ�� (1-8, ������஫��㥬�� ���祭��);
;    AL - ������⢮ ᥪ�஢ (1-8, ������஫��㥬�� ���祭��).
;
;    ��� �믮������ �ଠ⨧�樨 ����室��� ��ନ஢��� �
; ����� ����塠���� ⠡���� ��� ������� ᥪ��, ᮤ�ঠ���
; ᫥������ ���ଠ��:
;    ����� ��஦��;
;    ����� �������;
;    ����� ᥪ��;
;    ������⢮ ���� � ᥪ�� (00 - 128 ����, 01 - 256 ����,
; 02 - 512 ����, 03 - 1024 ����).
;    ���� ⠡���� �������� � ॣ����� ES:BX.
;
;    ��᫥ �믮������ �ணࠬ�� � ॣ���� AH ��室����
; ���� ���ﭨ� ����.
;
;    ���� ���ﭨ� ���� ����� ᫥���饥 ���祭��:
;    80 - ⠩�-���;
;    40 - ᡮ� ����樮��஢����;
;    20 - ᡮ� ����஫���;
;    10 - �訡�� ���� 横���᪮�� ����஫� �� ���뢠���;
;    09 - ���室 ���� �१ ᥣ���� (64� ����);
;    08 - ��९�������;
;    04 - ᥪ�� �� ������;
;    03 - ���� �����;
;    02 - �� �����㦥� ��થ� �����䨪��� ᥪ��;
;    01 - ������� �⢥࣭��.
;    �� �ᯥ譮� �����襭�� �ணࠬ�� �ਧ��� CF=0,  � ��-
; ⨢��� ��砥 - �ਧ��� CF=1 (ॣ���� AH ᮤ�ন� ��� �訡��).
;    ������� AL ᮤ�ন� ������⢮ ॠ�쭮 ��⠭��� ᥪ�஢.
;    ���� �ணࠬ�� ���㦨����� ������⥫� �� ������ �����⭮�
; ��᪥ �����뢠���� � ����� 40H � ��楤�� ��� �� ����祭��
; ��⠭��.
;-------------------------
 	assume	cs:code,ds:data,es:data
diskette_io proc	far
 	sti	 	 	; ��⠭����� �ਧ��� ���뢠���
 	push	bx	 	; ��࠭��� ����
 	push	cx
 	push	ds	   ; ��࠭��� ᥣ���⭮� ���祭�� ॣ����
 	push	si	   ; ��࠭��� �� ॣ����� �� �६� ����樨
 	push	di
 	push	bp
 	push	dx
 	mov	bp,sp	   ; ��⠭����� 㪠��⥫� ���設� �⥪�
 	mov	si,dat
 	mov	ds,si	 	; ��⠭����� ������� ������
 	call	j1	 	;
 	mov	bx,4	 	; ������� ��ࠬ���� �������� ����
 	call	get_parm
 	mov	motor_count,ah	; ��� �६� ����� ��� ����
 	mov	ah,diskette_status  ; ������� ���ﭨ� ����樨
 	cmp	ah,1	 	; ��� �ਧ��� CF ��� ������樨
 	cmc	 	 	; �ᯥ譮� ����樨
 	pop	dx	 	; ����⠭����� �� ॣ�����
 	pop	bp
 	pop	di
 	pop	si
 	pop	ds
 	pop	cx
 	pop	bx
 	ret	2
diskette_io	endp
j1	proc	near
 	mov	dh,al	 	; ��࠭��� ������⢮ ᥪ�஢
 	and	motor_status,07fh   ; 㪠���� ������ ���뢠���
 	or	ah,ah	 	; AH=0
 	jz	disk_reset
 	dec	ah	 	; AH=1
 	jz	disk_status
 	mov	diskette_status,0   ; ��� ���ﭨ�
 	cmp	dl,4	 	; �஢�ઠ ������⢠ ���ன��
 	jae	j3	 	; ���室 �� �訡��
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
 	mov	diskette_status,bad_cmd   ; ����ୠ� �������

 	ret	 	 	; ������ �� ��।�����
j1	endp

;   ������ ����

disk_reset proc near
 	mov	dx,03f2h
 	cli	 	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	al,motor_status  ; ����� ���� ����祭
 	mov	cl,4	 	; ���稪 ᤢ���
 	sal	al,cl
 	test	al,20h	 	; ����� ᮮ⢥�����饥 ���ன�⢮
 	jnz	j5	 	; ���室, �᫨ ����祭 ���� ��ࢮ��
 	 	 	 	; ���ன�⢠
 	test	al,40h
 	jnz	j4	 	; ���室, �᫨ ����祭 ���� ��ண�
 	 	 	 	; ���ன�⢠
 	test	al,80h
 	jz	j6	 	; ���室, �᫨ ����祭 ���� �㫥����
 	 	 	 	; ���ன�⢠
 	inc	al
j4:	inc	al
j5:	inc	al
j6:	or	al,8	 	; ������� ����㯭���� ���뢠���
 	out	dx,al	 	; ��� ������
 	mov	seek_status,0
 	mov	diskette_status,0  ; ��� ��ଠ�쭮� ���ﭨ� ����
 	or	al,4	 	; �몫���� ���
 	out	dx,al
 	sti	 	 	; ��⠭����� ��� ࠧ�襭�� ���뢠���
 	call	chk_stat_2	; �믮����� ���뢠��� ��᫥ ���
 	mov	al,nec_status
 	cmp	al,0c0h    ; �஢�ઠ ��⮢���� ���ன�⢠ ��� ��।��
 	jz	j7	 	; ���ன�⢮ ��⮢�
 	or	diskette_status,bad_nec  ; ��� ��� �訡��
 	jmp	short j8

;   ��᫠�� ������� � ����஫���

j7:
 	mov	ah,03h	 	; ��⠭����� �������
 	call	nec_output	; ��।��� �������
 	mov	bx,1	 	; ��।�� ��ࢮ�� ���� ��ࠬ��஢
 	call	get_parm	; � ����஫���
 	mov	bx,3	 	; ��।�� ��ண� ���� ��ࠬ��஢
 	call	get_parm	; � ����஫���
j8:
 	ret	 	 	; ������ � ��ࢠ���� �ணࠬ��
disk_reset	endp

;
; ����� ���� ���ﭨ� ���� (AH=1)
;

disk_status proc near
 	mov	al,diskette_status
 	ret
disk_status	endp

;   ����� 㪠����� ᥪ�� � ������ (AH=2)

disk_read proc near
 	mov	al,046h 	; ��⠭����� �������
j9:
 	call	dma_setup	; ��⠭����� ���
 	mov	ah,0e6h     ; ��� ������� ���뢠���  ����஫���
 	jmp	short rw_opn	; ���室 � �믮������ ����樨
disk_read	endp

;   ���䨪��� (AH=4)

disk_verf proc near
 	mov	al,042h 	; ��⠭����� �������
 	jmp	short j9
disk_verf	endp

;   ��ଠ⨧��� (AH=5)

disk_format proc near
 	or	motor_status,80h  ; �������� ����樨 �����
 	mov	al,04ah 	  ; ��⠭����� �������
 	call	dma_setup	  ; ��⠭����� ���
 	mov	ah,04dh 	  ; ��⠭����� �������
 	jmp	short rw_opn
j10:
 	mov	bx,7	 	  ; ������� ���祭�� ᥪ��
 	call	get_parm
 	mov	bx,9	 	; ������� ���祭�� ��஦�� �� ᥪ��
 	call	get_parm
 	mov	bx,15	 	; ������� ���祭�� ����� ���ࢠ��
 	call	get_parm	; ��� ����஫���
 	mov	bx,17	 	; ������� ����� ����
 	jmp	j16
disk_format	endp

;   ������� 㪠����� ᥪ�� �� ����� (AH=3)

disk_write proc near
 	or	motor_status,80h	; �������� ����樨 �����
 	mov	al,04ah 	 	; ��� ��� ����樨 �����
 	call	dma_setup
 	mov	ah,0c5h 	 	; ������� ����� �� ����
disk_write	endp

;______________________
; rw_opn
;   �ணࠬ�� �믮������ ����権
;   ���뢠���, �����, ���䨪�樨
;----------------------
rw_opn	proc	near
 	jnc	j11	 	; �஢�ઠ �訡�� ���
 	mov	diskette_status,dma_boundary   ; ��⠭����� �訡��
 	mov	al,0	 	;
 	ret	 	 	; ������ � �᭮���� �ணࠬ��
j11:
 	push	ax	 	; ��࠭��� �������

;   ������� ���� � ����� ���ன�⢮

 	push	cx
 	mov	cl,dl	 	; ��� ����� ���ன�⢠, ��� ���稪 ᤢ���
 	mov	al,1	 	; ��᪠ ��� ��।������ ���� ���ன�⢠
 	sal	al,cl	 	; ᤢ��
 	cli	 	 	; ����� ��� ࠧ�襭�� ���뢠���
 	mov	motor_count,0ffh  ; ��⠭����� ���稪
 	test	al,motor_status
 	jnz	j14
 	and	motor_status,0f0h  ; �몫���� �� ���� ����
 	or	motor_status,al    ; ������� ����
 	sti	 	 	; ��⠭����� ��� ࠧ�襭�� ���뢠���
 	mov	al,10h	 	; ��� ��᪨
 	sal	al,cl	 	; ��� ��� ��᪨ ��� ����㯭��� ����
 	or	al,dl	 	; ������� ��� �롮� ���ன�⢠
 	or	al,0ch	 	; ��� ���, ����㯭���� ���뢠��� ���
 	push	dx
 	mov	dx,03f2h	; ��⠭����� ���� ����
 	out	dx,al
 	pop	dx	 	; ����⠭����� ॣ�����
 	push	cx	 	;����প� ��� ����祭�� ���� ���ன�⢠
 	mov	cx,3
x2:	push	cx
 	mov	cx,0
x1:	loop	x1
 	pop	cx
 	loop	x2
 	pop	cx

;   �������� ����祭�� ���� ��� ����樨 �����

 	test	motor_status,80h  ; ������ ?
 	jz	j14	; ��� - �த������ ��� ��������
 	mov	bx,20	 	; ��⠭����� �������� ����祭�� ����
 	call	get_parm	; ������� ��ࠬ����
 	or	ah,ah
j12:
 	jz	j14	 	; ��室 �� ����砭�� �६��� ��������
 	sub	cx,cx	 	; ��⠭����� ���稪
j13:	loop	j13	 	; ������� �ॡ㥬�� �६�
 	dec	ah	 	; 㬥����� ���祭�� �६���
 	jmp	short j12	; ������� 横�

j14:
 	sti	 	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	pop	cx

;   �믮����� ������ ���᪠

 	call	seek	 	; ��⠭����� ��஦��
 	pop	ax	 	; ����⠭����� �������
 	mov	bh,ah	 	; ��࠭��� ������� � BH
 	mov	dh,0	 	; ��� 0 ᥪ�� � ��砥 �訡��
 	jc	j17	 	; ��室, �᫨ �訡��
 	mov	si,offset j17

 	push	si

;   ��᫠�� ��ࠬ���� � ����஫���

 	call	nec_output	; ��।�� �������
 	mov	ah,byte ptr [bp+1]  ; ��� ����� �������
 	sal	ah,1	 	; ᤢ�� �� 2
 	sal	ah,1
 	and	ah,4	 	; �뤥���� ���
 	or	ah,dl	 	; ������ OR � ����஬ ���ன�⢠
 	call	nec_output

;   �஢�ઠ ����樨 �ଠ⨧�樨

 	cmp	bh,04dh 	; �ଠ⨧��� ?
 	jne	j15    ; ��� - �த������ ������/���뢠���/���䨪���
 	jmp	j10

j15:	mov	ah,ch	 	; ����� 樫����
 	call	nec_output
 	mov	ah,byte ptr [bp+1]  ; ����� �������
 	call	nec_output
 	mov	ah,cl	 	; ����� ᥪ��
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

;   ������ ����饭�

 	call	wait_int	; �������� ���뢠���
j17:
 	jc	j21	 	; ���� �訡��
 	call	results 	; ������� ���ﭨ� ����஫���
 	jc	j20	 	; ���� �訡��

;   �஢�ઠ  ���ﭨ�, ����祭���� �� ����஫���

 	cld	 	 	; ��⠭����� ���ࠢ����� ���४樨
 	mov	si,offset nec_status
 	lods	nec_status
 	and	al,0c0h 	; �஢���� ��ଠ�쭮� ����砭��
 	jz	j22
 	cmp	al,040h 	; �஢���� ����୮� ����砭��
 	jnz	j18

;   �����㦥��� ����୮� ����砭��

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
 	mov	ah,write_protect  ; �஢�ઠ ����� �����
 	jc	j19
 	sal	al,1
 	mov	ah,bad_addr_mark
 	jc	j19

;   ����஫��� ��襫 �� ����

j18:
 	mov	ah,bad_nec
j19:
 	or	diskette_status,ah
 	call	num_trans
j20:
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���

j21:
 	call	results 	; �맮� १���⮢ � ����
 	ret

;   ������ �뫠 �ᯥ譮�

j22:
 	call	num_trans
 	xor	ah,ah	 	; ��� �訡��
 	ret
rw_opn	endp
;------------------------
;get_parm
;
;   ����   BX - ������ ����,�������
;	 	�� 2,����� �㤥�
;	 	��࠭,�᫨ ����訩
;	 	��� BX ��⠭�����,�
;	 	���� ���������� ���-
;	 	������ ����஫����.
;
;   �����  AH - ���� �� �����.
;-------------------------
get_parm proc	near
 	push	ds	 	; ��࠭��� ᥣ����
 	sub	ax,ax	 	; AX=0
 	mov	ds,ax
 	assume	ds:abs0
 	lds	si,disk_pointer
 	shr	bx,1	 	; ������ BX �� 2, ��� 䫠� ��� ��室�
 	mov	ah,zb[si+bx]	; ������� ᫮��
 	pop	ds	 	; ����⠭����� ᥣ����
 	assume	ds:data
 	jc	nec_op	 	 ;�᫨ 䫠� ��⠭�����, ��室
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���
nec_op: jmp	nec_output
get_parm endp
;----------------------------
;   ����樮��஢����
;
;   �� �ணࠬ�� ����樮����� �����-
; �� ������祭���� ���ன�⢠ �� ��-
; ��� ��஦��. �᫨ ���ன�⢮ ��
; �뫮 ��࠭� �� �� ���, ���� ��
; �뫠 ��襭� �������,� ���ன�⢮
; �㤥� ४����஢���.
;
;   ����
;	(DL) - ����� ��ன�⢠ ���
;	       ����樮��஢����,
;	(CH) - ����� ��஦��.
;
;   �����
;	 CY=0 - �ᯥ譮,
;	 CY=1 - ᡮ� (���ﭨ� ���� ��⠭�����
;	 	ᮣ��᭮  AX).
;----------------------------
seek	proc	near
 	mov	al,1	 	; ��� ����
 	push	cx
 	mov	cl,dl	 	; ��⠭����� ����� ���ன�⢠
 	rol	al,cl	 	; 横���᪨� ᤢ�� �����
 	pop	cx
 	test	al,seek_status
 	jnz	j28
 	or	seek_status,al
 	mov	ah,07h
 	call	nec_output
 	mov	ah,dl
 	call	nec_output
 	call	chk_stat_2   ; ������� � ��ࠡ���� ���뢠���
 	mov	ah,07h	 	; ������� ४����஢��
 	call	nec_output
 	mov	ah,dl
 	call	nec_output
 	call	chk_stat_2
 	jc	j32	 	; ᡮ� ����樮��஢����


j28:
 	mov	ah,0fh
 	call	nec_output
 	mov	ah,dl	 	; ����� ���ன�⢠
 	call	nec_output
 	mov	ah,ch	 	; ����� ��஦��
		nop
 	test	byte ptr equip_flag,4
 	jnz	j300
 	add	ah,ah	 	; 㤢����� ����� ��஦��
j300:
 	call	nec_output
 	call	chk_stat_2	; ������� ����筮� ���뢠��� �
 	 	 	 	; ����� ���ﭨ�


 	pushf	 	 	; ��࠭��� ���祭�� 䫠����
 	mov	bx,18
 	call	get_parm
 	push	cx	 	; ��࠭��� ॣ����
j29:
 	mov	cx,550	 	; �࣠�������� 横� = 1 ms
 	or	ah,ah	 	; �஢�ઠ ����砭�� �६���
 	jz	j31
j30:	loop	j30	 	; ����প� 1ms
 	dec	ah	 	; ���⠭�� �� ���稪�
 	jmp	short j29	; ������ � ��砫� 横��
j31:
 	pop	cx	 	; ����⠭����� ���ﭨ�
 	popf
j32:	 	 	 	; �訡�� ����樮��஢����
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���
seek	endp
;-----------------------
; dma_setup
;   �ணࠬ�� ��⠭���� ��� ��� ����権 �����,���뢠���,����-
; ��樨.
;
;   ����
;
;	(AL) - ���� ०��� ��� ���,
;	(ES:BX) - ���� ���뢠���/����� ���ଠ樨.
;
;------------------------
dma_setup proc	near
 	push	cx	 	; ��࠭��� ॣ����
 	out	dma+12,al
 	out	dma+11,al	; �뢮� ���� ���ﭨ�
 	mov	ax,es	 	; ������� ���祭�� ES
 	mov	cl,4	 	; ���稪 ��� ᤢ���
 	rol ax,cl	 	; 横���᪨� ᤢ�� �����
 	mov	ch,al	 	;
 	and	al,0f0h 	;
 	add	ax,bx
 	jnc	j33
 	inc	ch	 	; ��७�� ����砥�, �� ���訥 4 ���
 	 	 	 	; ������ ���� �ਡ������
j33:
 	push	ax	 	; ��࠭��� ��砫�� ����
 	out	dma+4,al	; �뢮� ����襩 �������� ����
 	mov	al,ah
 	out	dma+4,al	; �뢮� ���襩 �������� ����
 	mov	al,ch	 	; ������� 4 ����� ���
 	and	al,0fh
 	out	081h,al   ; �뢮� 4 ����� ��� �� ॣ���� ��࠭��

;   ��।������ ���稪�

 	mov	ah,dh	 	; ����� ᥪ��
 	sub	al,al	 	;
 	shr	ax,1	 	;
 	push	ax
 	mov	bx,6	 	; ������� ��ࠬ���� ����/ᥪ��
 	call	get_parm
 	mov	cl,ah	 	; ���稪 ᤨ�� (0=128, 1=256 � �.�)
 	pop	ax
 	shl	ax,cl	 	; ᤢ��
 	dec	ax	 	; -1
 	push	ax	 	; ��࠭��� ���祭�� ���稪�
 	out	dma+5,al	; �뢥�� ����訩 ���� ���稪�
 	mov	al,ah
 	out	dma+5,al	; �뢥�� ���訩 ���� ���稪�
 	pop	cx	 	; ����⠭����� ���祭�� ���稪�
 	pop	ax	 	; ����⠭����� ���祭�� ����
 	add	ax,cx	 	; �஢�ઠ ���������� 64K
 	pop	cx	 	; ����⠭����� ॣ����
 	mov	al,2	 	; ०�� ��� 8237
 	out	dma+10,al	; ���樠������ ������ ����
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���
dma_setup	endp
;-----------------------
;chk_stat_2
;   �� �ணࠬ�� ��ࠡ��뢠�� ���뢠��� ,����祭�� ��᫥
; ४����஢��, ����樮��஢���� ��� ��� ������. ���뢠���
; ���������, �ਭ�������, ��ࠡ��뢠���� � १���� �뤠���� �ணࠬ��,
; �맢��襩 ���뢠���.
;
;   �����
;	  CY=0 - �ᯥ譮,
;	  CY=1 - ᡮ� (�訡�� � ���ﭨ� ����),
;--------------------------
chk_stat_2 proc near
 	call	wait_int	; �������� ���뢠���
 	jc	j34	 	; �᫨ �訡��, � ������
 	mov	ah,08h	 	; ������� ����祭�� ���ﭨ�
 	call	nec_output
 	call	results 	; ����� १�����
 	jc	j34
 	mov	al,nec_status	; ������� ���� ���� ���ﭨ�
 	and	al,060h 	; �뤥���� ����
 	cmp	al,060h 	; �஢�ઠ
 	jz	j35	   ; �᫨ �訡��, � ��� �� ����
 	clc	 	 	; ������
j34:
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���
j35:
 	or	diskette_status,bad_seek
 	stc	 	 	; �訡�� � �����饭��� ����
 	ret
chk_stat_2	endp
;---------------------------------
; wait_int
;   �� �ணࠬ�� ������� ���뢠���, ���஥ ��������� �� �६�
; �ணࠬ�� �뢮��. �᫨ ���ன�⢮ �� ��⮢�, �訡�� ����� ����
; �����饭�.
;
;
;   �����
;	      CY=0 - �ᯥ譮,
;	      CY=1 - ᡮ�(���ﭨ� ���� ��⠭����������),
;-----------------------------------
wait_int proc	near
 	sti	 	 	; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	push	bx
 	push	cx	 	; ��࠭��� ॣ����
 	mov	bl,2	 	; ������⢮ 横���
 	xor	cx,cx	 	; ���⥫����� ������ 横�� ��������
j36:
 	test	seek_status,int_flag  ; ���� ������ ���뢠���
 	jnz	j37
 	loop	j36	 	; ������ � ��砫� 横��
 	dec	bl
 	jnz	j36
 	or	diskette_status,time_out
 	stc	 	 	; ������ �� �訡��
j37:
 	pushf	 	 	; ��࠭��� ⥪�騥 �ਧ����
 	and	seek_status,not int_flag
 	popf	 	 	; ����⠭����� �ਧ����
 	pop	cx
 	pop	bx	 	; ����⠭����� ॣ����
 	ret	 	; ������ � �ணࠬ��, �맢��襩 ���뢠���
wait_int	endp

		db 3 dup(0)

;---------------------------
;disk_int
;   �� �ணࠬ�� ��ࠡ��뢠�� ���뢠��� ����
;
;   �����  - �ਧ��� ���뢠��� ��⠭���������� � SEEK_STATUS.
;---------------------------
disk_int proc	far
 	sti	 	 	; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds
 	push	ax
 	mov	ax,dat
 	mov	ds,ax
 	or	seek_status,int_flag
 	mov	al,20h	 	; ��⠭����� ����� ���뢠���
 	out	20h,al	 	; ��᫠�� ����� ���뢠��� � ����
 	pop	ax
 	pop	ds
 	iret	 	 	; ������ �� ���뢠���
disk_int	endp
;----------------------------
;
;   �� �ணࠬ�� ���뢥� ��, �� ����஫��� ������ ���� 㪠�뢠��
; �ணࠬ��, ᫥���饩 �� ���뢠����.
;
;
;   �����
;	   CF=0 - �ᯥ譮,
;	   CF=1 - ᡮ�
;----------------------------
results proc	near
 	cld
 	mov	di,offset nec_status
 	push	cx	 	; ��࠭��� ���稪
 	push	dx
 	push	bx
 	mov	bl,7	 	; ��⠭����� ����� ������ ���ﭨ�


j38:
 	xor	cx,cx	 	; ���⥫쭮��� ������ 横��
 	mov	dx,03f4h	; ���� ����
j39:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,080h 	; ��⮢� ?
 	jnz	j40a
 	loop	j39
 	or	diskette_status,time_out
j40:	 	 	 	; �訡��
 	stc	 	 	; ������ �� �訡��
 	pop	bx
 	pop	dx
 	pop	cx
 	ret

;   �஢�ઠ �ਧ���� ���ࠢ�����

j40a:	in	al,dx	 	; ������� ॣ���� ���ﭨ�
 	test	al,040h 	; ᡮ� ����樮��஢����
 	jnz	j42	; �᫨ �� ��ଠ�쭮, ����� ���ﭨ�
j41:
 	or	diskette_status,bad_nec
 	jmp	short j40	; �訡��

;   ���뢠��� ���ﭨ�

j42:
 	inc	dx	 	; 㪠���� ����
 	in	al,dx	 	; ����� �����
 	mov    byte ptr [di],al  ; ��࠭��� ����
 	inc	di	 	; 㢥����� ����
 	mov	cx,000ah	; ���稪
j43:	loop	j43
 	dec	dx
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,010h
 	jz	j44
 	dec	bl	 	; -1 �� ������⢠ 横���
 	jnz	j38
 	jmp	short j41	; ᨣ��� ����७

j44:
 	pop	bx	 	; ����⠭����� ॣ�����
 	pop	dx
 	pop	cx
 	ret	 	 	; ������ �� ���뢠���
results endp
;-----------------------------
; num_trans
;   �� �ணࠬ�� ������ ������⢮ ᥪ�஢, ���஥ ����⢨⥫쭮
; �뫮 ����ᠭ� ��� ��⠭� � ����
;
;   ����
;	 (CH) - 樫����,
;	 (CL) - ᥪ��.
;
;   �����
;	 (AL) - ������⢮ ����⢨⥫쭮 ��।����� ᥪ�஢.
;
;------------------------------
num_trans proc	near
 	mov	al,nec_status+3  ; ������� ��᫥���� 樫����
 	cmp	al,ch	 	; �ࠢ���� � ���⮢�
 	mov	al,nec_status+5  ; ������� ��᫥���� ᥪ��
 	jz	j45
 	mov	bx,8
 	call	get_parm	; ������� ���祭�� EOT
 	mov	al,ah	 	; AH � AL
 	inc	al	 	; EOT+1
j45:	sub	al,cl	    ; ���᫥��� ���⮢��� ����� �� ����筮��
 	ret
num_trans endp

;-------------------------------
; disk_base
;   �� �ணࠬ�� ��⠭�������� ��ࠬ����,�ॡ㥬� ��� ����権
; ����.
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
;   �ணࠬ�� �裡 � �����騬 ���ன�⢮�
;
;   �� �ணࠬ�� �믮���� �� �㭪樨, ��� ������ ��������
; � ॣ���� AH:
;   AH=0 - ����� �����, ��������� � ॣ���� AL. �᫨ �
; १���� �믮������ �㭪樨 ���� �� �����⠥���, � � ॣ����
; AL ��⠭���������� "1" (⠩�-���);
;   AH=1 - ���樠������ ���� ����. ��᫥ �믮������ �㭪樨
; � ॣ���� AH ��室���� ���� ���ﭨ� �����饣� ���ன�⢠;
;   AH=2H - ���뢠��� ���� ���ﭨ� �����饣� ���ன�⢠.
;   � ॣ���� DX ����室��� ������ ����.
;   ���祭�� ࠧ�冷� ���� ���ﭨ� �����饣� ���ன�⢠:
;   0 - ⠩�-���;
;   3 - �訡�� �����-�뢮��;
;   4 - ��࠭ (SLCT);
;   5 - ����� �㬠�� (PE);
;   6 - ���⢥ত����;
;   7 - �����.
;------------------------------

 	assume	cs:code,ds:data
printer_io proc far
 	sti	 	 	; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds	 	; ��࠭��� ᥣ����
 	push	dx
 	push	si
 	push	cx
 	push	bx
 	mov	si,dat
 	mov	ds,si	 	; ��⠭����� ᥣ����
 	mov	si,dx
 	shl	si,1
 	mov	dx,printer_base[si]  ; ������� ������ ����
 	 	 	 	     ; �����饣� ���ன�⢠
 	or	dx,dx	 	   ; ����� ������祭� ?
 	jz	b1	 	   ; ���, ������
 	or	ah,ah	 	   ; AH=0 ?
 	jz	b2	 	   ; ��, ���室 � ���� �����
 	dec	ah	 	   ; AH=1 ?
 	jz	b8	 	   ; ��, ���室 � ���樠����樨
 	dec	ah	 	   ; AH=2 ?
 	jz	b5	   ; ��, ���室 � ���뢠��� ���� ���ﭨ�

;    ��室 �� �ணࠬ��

b1:
 	pop	bx	 	; ����⠭����� ॣ�����
 	pop	cx
 	pop	si
 	pop	dx
 	pop	ds
 	iret

;   ����� �����, ��������� � AL

b2:
 	push	ax
 	mov	bl,10	 	; ������⢮ 横��� ��������
 	xor	cx,cx	 	; ���⥫쭮��� ������ 横��
 	out	dx,al	 	; �뢥�� ᨬ��� � ����
 	inc	dx	 	; -1 �� ���� ����
b3:	 	 	 	; �������� BUSY
 	in	al,dx	 	; ������� ���ﭨ�
 	mov	ah,al	 	; ���᫠�� ���ﭨ� � AH
 	test	al,80h	 	; ����� ����� ?
 	jnz	b4	 	; ���室, �᫨ ��
 	loop	b3	 	; 横� �������� �����稫�� ?
 	dec	bl	 	; ��, -1 �� ������⢠ 横���
 	jnz	b3	 	; �६� �������� ��⥪�� ?
 	or	ah,1	 	; ��, ��� ��� "⠩�-���"
 	and	ah,0f9h 	;
 	jmp	short b7
b4:	 	 	 	; OUT_STROBE
 	mov	al,0dh	 	; ��⠭����� ��᮪�� ��஡
 	inc	dx	; ��஡�஢���� ��⮬ 0 ���� C ��� 8255
 	out	dx,al
 	mov	al,0ch	 	; ��⠭����� ������ ��஡
 	out	dx,al
 	pop	ax	 	;

;   ���뢠��� ���� ���ﭨ� �����饣� ���ன�⢠

b5:
 	push	ax	 	; ��࠭��� ॣ����
b6:
 	mov	dx,printer_base[si]  ; ������� ���� ����
 	inc	dx
 	in	al,dx	 	; ������� ���ﭨ� ����
 	mov	ah,al
 	and	ah,0f8h
b7:
 	pop	dx
 	mov	al,dl
 	xor	ah,48h
 	jmp	short b1	; � ��室� �� �ணࠬ��

;   ���樠������ ���� �����饣� ���ன�⢠

b8:
 	push	ax
 	add	dx,2	 	; 㪠���� ����
 	mov	al,8
 	out	dx,al
 	mov	ax,1000 	 ; �६� ����প�
b9:
 	dec	ax	 	 ; 横� ����প�
 	jnz	b9
 	mov	al,0ch
 	out	dx,al
 	jmp	short b6    ; ���室 � ���뢠��� ���� ���ﭨ�
printer_io	endp
;--- int 10------------------
;
;   �ணࠬ�� ��ࠡ�⪨ ���뢠��� ���
;
;   �� �ணࠬ�� ���ᯥ稢��� �믮������ �㭪権 ���㦨�����
; ������ ���, ��� ������ �������� � ॣ���� AH:
;
;    AH=0   - ��⠭����� ०�� ࠡ��� ������ ���. � १����
; �믮������ �㭪樨 � ॣ���� AL ����� ��⠭���������� ᫥��-
; �騥 ०���:
;    0 - 40�25, �୮-����, ��䠢�⭮-��஢��;
;    1 - 40�25, 梥⭮�, ��䠢�⭮-��஢��;
;    2 - 80�25, �୮-����, ��䠢�⭮-��஢��;
;    3 - 80�25, 梥⭮�, ��䠢�⭮-��஢��;
;    4 - 320�200, 梥⭮�, ����᪨�;
;    5 - 320�200, �୮-����, ����᪨�;
;    6 - 640�200, �୮-����, ����᪨�;
;    7 - 80�25, �୮-����, ��䠢�⭮-��஢��.
;    ������ 0 - 6 �ᯮ������� ��� �� ������ ���, ०�� 7
; �ᯮ������ ��� �����஬���� �୮-������ 80�25 ������.
;
;    AH=1   - ��⠭����� ࠧ��� �����. �㭪�� ������ ࠧ��� ���-
; �� � �ࠢ����� ��.
;   ������ 0 - 4 ॣ���� CL ��।����� ������� �࠭��� �����,
; ࠧ��� 0 - 4 ॣ���� CH - ��砫��� �࠭��� �����.
;    ������ 6 � 5 ������ �ࠢ����� ����஬:
;    00 - ����� ���栥� � ���⮩, ���������� �������୮;
;    01 - ����� ���������.
;    �������୮ �ᥣ�� ��뢠���� ���栭�� ����� � ���⮩,
; ࠢ��� 1/16 ����� ���஢�� ࠧ���⪨.
;
;    AH=2   - ��⠭����� ⥪���� ������ �����. ��� �믮������
; �㭪樨 ����室��� ������ ᫥���騥 ���न���� �����:
;    BH - ��࠭��;
;    DX - ��ப� � �������.
; �� ����᪮� ०��� ॣ���� BH=0.
;
;    AH=3   - ����� ⥪�饥 ��������� �����. �㭪�� ���-
; �⠭�������� ⥪�饥 ��������� �����. ��। �믮�������
; �㭪樨 � ॣ���� BH ����室��� ������ ��࠭���.
;    ��᫥ �믮������ �ணࠬ�� ॣ����� ᮤ�ঠ� ᫥������
; ���ଠ��:
;    DH - ��ப�;
;    DL - �������;
;    CX - ࠧ��� ����� � �ࠢ����� ��.
;
;    AH=5  - ��⠭����� ��⨢��� ��࠭��� ���� ������.
; �㭪�� �ᯮ������ ⮫쪮 � ��䠢�⭮-��஢�� ०���.
; ��� �� �믮������ ����室��� � ॣ���� AL ������ ��࠭���:
;    0-7 - ��� ०���� 0 � 1;
;    0-3 - ��� ०���� 2 � 3.
;    ���祭�� ०���� � ��, �� � ��� �㭪樨 AH=0.
;
;    AH=6   - ��६����� ���� ᨬ����� ����� �� �࠭�.
; �㭪�� ��६�頥� ᨬ���� � �।���� �������� ������ �����
; �� �࠭�, �������� ������ ��ப� �஡����� � ������� ��ਡ�-
; ⮬.
;    ��� �믮������ �㭪樨 ����室��� ������ ᫥���騥 ���-
; �����;
;    AL - ������⢮ ��६�頥��� ��ப. ��� ���⪨ ����� AL=0;
;    CX - ���न���� ������ ���孥�� 㣫� ����� (��ப�,�������);
;    DX - ���न���� �ࠢ��� ������� 㣫� �����;
;    BH - ��ਡ�� ᨬ���� �஡���.
;
;    AH=7   - ��६����� ���� ᨬ����� ����. �㭪�� ��६�頥�
; ᨬ���� � �।���� �������� ������ ���� �� �࠭�, ��������
; ���孨� ��ப� �஡����� � ������� ��ਡ�⮬.
;    ��� �믮������ �㭪樨 ����室��� ������ � �� ��ࠬ����,
; �� � ��� �㭪樨 AH=6H.
;
;    AH=8   - ����� ��ਡ�� � ��� ᨬ����, ��室�饣��� � ⥪�-
; 饩 ����樨 �����. �㭪�� ���뢠�� ��ਡ�� � ��� ᨬ����
; � ����頥� �� � ॣ���� AX (AL - ��� ᨬ����, AH - ��ਡ��
; ᨬ����).
;    ��� �믮������ �㭪樨 ����室��� � ॣ���� BH ������
; ��࠭��� (⮫쪮 ��� ��䠢�⭮-��஢��� ०���).
;
;    AH=9   - ������� ��ਡ�� � ��� ᨬ���� � ⥪���� ������
; �����. �㭪�� ����頥� ��� ᨬ���� � ��� ��ਡ�� � ⥪����
; ������ �����.
;    ��� �믮������ �㭪樨 ����室��� ������ ᫥���騥 ��ࠬ����:
;    BH - �⮡ࠦ����� ��࠭�� (⮫쪮 ��� ��䠢�⭮-��஢���
; ०���;
;    CX - ������⢮ �����뢠���� ᨬ�����;
;    AL - ��� ᨬ����;
;    BL - ��ਡ�� ᨬ���� ��� ��䠢�⭮-��஢��� ०��� ���
; 梥� ����� ��� ��䨪�. �� ����� �窨 ࠧ�� 7 ॣ���� BL=1.    =1
;
;    AH=10 - ������� ᨬ��� � ⥪���� ������ �����. ��ਡ��
; �� ���������.
;    ��� �믮������ �㭪樨 ����室��� ������ ᫥���騥 ��ࠬ����:
;    BH - �⮡ࠦ����� ��࠭�� (⮫쪮 ��� ��䠢�⭮-��஢���
; ०���);
;    CX - ������⢮ ����७�� ᨬ����;
;    AL - ��� �����뢠����� ᨬ����.	 	 	 	      ��
;	 	 	 	 	 	 	 	      -
;    AH=11 - ��⠭����� 梥⮢�� �������.	 	 	      �
;    �� �믮������ �㭪樨 �ᯮ������� ��� ��ਠ��.
;    ��� ��ࢮ�� ��ਠ�� � ॣ���� BH �������� ����,� � ॣ����
; BL - ���祭�� ��� ������ ࠧ�冷�, �ᯮ��㥬�� ��� �롮�
; 梥⮢�� ������� (梥� ������� ����� ��� 梥⭮�� ����᪮��
; ०��� 320�200 ��� 梥� ����� ��� 梥⭮�� ����᪮�� ०���
; 40�25).
;    ��� ��ண� ��ਠ�� � ॣ���� BH �������� "1", � � ॣ����
; BL - ����� 梥⮢�� ������� (0 ��� 1).
;    ������ 0 ��⮨� �� �������� (1), ��᭮�� (2) � ���⮣� (3)
; 梥⮢, ������ 1 - �� ���㡮�� (1), 䨮��⮢��� (2) � ������ (3).
; �� ࠡ�� � ����������஬ 梥� ������� ���������� ᮮ⢥����-
; �騬� �ࠤ��ﬨ 梥�.
;    ������⮬ �믮������ �㭪樨 ���� ��⠭���� 梥⮢��       )
; ������� � ॣ���� �롮� 梥� (3D9).
;
;    AH=12  - ������� ���. �㭪�� ��।���� �⭮�⥫��
; ���� ���� ����� ���� ���, �� ���஬� ������ ���� ����ᠭ�
; �窠 � ������묨 ���न��⠬�.
;    ��� �믮������ �㭪樨 ����室��� ������ ᫥���騥 ��ࠬ����:    ,
;    DX - ��ப�;
;    CX - �������;
;    AL - 梥� �뢮����� �窨. �᫨ ࠧ�� 7 ॣ���� AL ���-       3)
; ������ � "1", � �믮������ ������ XOR ��� ���祭��� �窨
; �� ���� � ���祭��� �窨 �� ॣ���� AL.
;
;    AH=13 - ����� ���. �㭪�� ��।���� �⭮�⥫��
; ���� ���� ����� ���� ���, �� ���஬� ������ ���� ��⠭�
; �窠 � ������묨 ���न��⠬�.
;    ��। �믮������� �ணࠬ�� � ॣ����� �������� � �� ��ࠬ��-
; ��, �� � ��� �㭪樨 AH=12.
;   ��᫥ �믮������ �ணࠬ�� � ॣ���� AL ��室���� ���祭��
; ��⠭��� �窨.
;
;    AH=14 - ������� ⥫�⠩�. �㭪�� �뢮��� ᨬ��� � ����
; ��� � �����६����� ��⠭����� ����樨 ����� � ��।��������
; ����� �� �࠭�.
;    ��᫥ ����� ᨬ���� � ��᫥���� ������ ��ப� �믮������
; ��⮬���᪨� ���室 �� ����� ��ப�. �᫨ ��࠭�� �࠭�
; ���������, �믮������ ��६�饭�� �� ���� ��ப� �����. �᢮-
; ��������� ��ப� ���������� ���祭��� ��ਡ�� ᨬ���� ���
; ��䠢�⭮-��஢��� ०��� ��� ��ﬨ - ��� ��䨪�.
;    ��᫥ ����� ��।���� ᨬ���� ����� ��⠭����������
; � ᫥������ ������.
;    ��� �믮������ �ணࠬ�� ����室��� ������ ᫥���騥 ��ࠬ����:
;    AL - ��� �뢮������ ᨬ����;
;    BL - 梥� ��।���� ����� (��� ����᪮�� ०���).
;    �ணࠬ�� ��ࠡ��뢠�� ᫥���騥 �㦥��� ᨬ����:
;    0BH - ᤢ�� ����� �� ���� ������ (��� ���⪨);
;    0DH - ��६�饭�� ����� � ��砫� ��ப�;
;    0AH - ��६�饭�� ����� �� ᫥������ ��ப�;
;    07H - ��㪮��� ᨣ���.
;
;    AH=15 - ������� ⥪�饥 ���ﭨ� ���. �㭪�� ���뢠��
; ⥪�饥 ���ﭨ� ��� �� ����� � ࠧ��頥� ��� � ᫥�����
; ॣ�����;
;    AH - ������⢮ ������� (40 ��� 80);
;    AL - ⥪�騩 ०�� (0-7). ���祭�� ०���� � ��, �� � ���
; �㭪樨 AH=0;
;    BH - ����� ��⨢��� ��࠭���.
;
;   AH=17 - ����㧨�� ������������ ���짮��⥫�. �㭪�� ����
; ����������� ���짮��⥫� ����㦠�� ������������ ���, ����-
; 室��� ��� ��䠢�⮬.
;    ��� �믮������ �ணࠬ�� ����室��� ������ ᫥���騥 ��ࠬ����:
;    ES:BP - ���� ⠡����, ��ନ஢����� ���짮��⥫��;
;    CX    - ������⢮ ��।������� ᨬ�����;
;    BL    - ��� ᨬ����, ��稭�� � ���ண� ����㦠���� ⠡���
; ���짮��⥫�;
;    BH - ������⢮ ���� �� ���������;
;    DL - �����䨪��� ⠡���� ���짮��⥫�;
;    AL - ०��:
;	 	  AL=0	 -  ����㧨�� ������������
;	 	  AL=1	 -  �뤠�� �����䨪��� ⠡����
;	 	  AL=3	 -  ����㧨�� ����� �������� ������������:
;	 	 	    BL=0 - ����㧨�� ����� �������� ���������
;	 	 	    ��� �� ��� ������� ⠡���� � ���᪨�
;	 	 	    ��䠢�⮬,
;	 	 	    BL=1 - ����㧨�� ����� �������� ���������
;	 	 	    ��� �� ��� �⠭���⭮� ������� ⠡��楩
;	 	 	    ASCII (USA)
;   �� ��室�:
;	AH   -	������⢮ ���� �� ���������
;	AL   -	�����䨪��� ⠡���� ���짮��⥫�
;	CF=1   -   ������ �����襭� �ᯥ譮
;
;    AH=19 - ���᫠�� 楯��� ᨬ�����. �㭪�� �������� ���-
; �뫠�� ᨬ���� ������ ᯮᮡ���, ⨯ ������ �������� �
; ॣ���� AL:
;    AL=0 - ᨬ���, ᨬ���, ᨬ���, ...
; � ॣ���� BL �������� ��ਡ��, ����� �� ��������;
;    AL=1 - ᨬ���, ᨬ���, ᨬ���, ...
; � ॣ���� BL �������� ��ਡ��, ����� ��������;
;    AL=2H - ᨬ���, ��ਡ��, ᨬ���, ��ਡ��, ...
; ����� �� ��������;
;    AL=3H - ᨬ���, ��ਡ��, ᨬ���, ��ਡ��, ...
; ����� ��������.
;     �஬� ⮣� ����室��� ������ � ॣ�����:
;    ES:BP - ��砫�� ���� 楯�窨 ᨬ�����;
;    CX    - ������⢮ ᨬ�����;
;    DH,DL - ��ப� � ������� ��� ��砫� �����;
;    BH    - ����� ��࠭���.
;-----------------------------------------------------------

 	assume cs:code,ds:data,es:video_ram

m1	label	word	 	; ⠡��� �㭪権 ������ ���
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
 	sti	 	    ; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	cld
 	push	es
 	push	ds
 	push	dx
 	push	cx
 	push	bx
 	push	si
 	push	di
 	push	ax	 	; ��࠭��� ���祭�� AX
 	mov	al,ah	 	; ���᫠�� AH � AL
 	xor	ah,ah	 	; ���㫨�� ���訩 ����
 	sal	ax,1	 	; 㬭����� �� 2
 	mov	si,ax	 	; �������� � SI
 	cmp	ax,m1l	 	; �஢�ઠ ����� ⠡���� �㭪権
 	jb	m2	 	; ������ ���
 	pop	ax	 	; ����⠭����� AX
 	jmp	video_return	; ��室, �᫨ AX ����୮
m2:	mov	ax,dat
 	mov	ds,ax
 	mov	ax,0b800h	; ᥣ���� ��� 梥⭮�� ������
 	mov	di,equip_flag	; ������� ⨯ ������
	and	di,30h 		; �뤥���� ���� ०��� ; db 81h,0E7h,30h,00h	; ###Gleb###
 	cmp	di,30h	 	; ���� ��⠭���� �/� ������ ?
 	jne	m3
 	mov	ax,0b000h	; ��� ���� ���� ��� �/� ������
m3:	mov	es,ax
 	pop	ax	 	; ����⠭����� ���祭��
 	mov	ah,crt_mode	; ������� ⥪�騩 ०�� � AH
 	jmp   cs:m1[si]
video_io	endp
;-------------------------
; set mode

;   �� �ணࠬ�� ��⠭�������� ०�� ࠡ��� ������ ���
;
;   ����
;	   (AL) - ᮤ�ন� ���祭�� ०���.
;
;--------------------------

;   ������� ��ࠬ��஢ ���

video_parms label	byte

;   ������ ���樠����樨

 	db	38h,28h,2dh,0ah,1fh,6,19h   ; ��� ��� 40�25

 	db	1ch,2,7,6,7
 	db	0,0,0,0
m4	equ	10h

 	db	71h,50h,5ah,0ah,1fh,6,19h   ; ��� ��� 80�25

 	db	1ch,2,7,6,7
 	db	0,0,0,0

 	db	38h,28h,2dh,0ah,7fh,6,64h   ; ��� ��� ��䨪�

 	db	70h,2,1,6,7
 	db	0,0,0,0

 	db	62h,50h,50h,0fh,19h,6,19h   ; ��� ��� 80�25 �/� ������

 	db	19h,2,0dh,0bh,0ch
 	db	0,0,0,0

m5	label	word	 	; ⠡��� ��� ����⠭������� �����
 	dw	2048
 	dw	4096
 	dw	16384
 	dw	16384

;   �������
m6	label	byte
 	db	40,40,80,80,40,40,80,80


;--- c_reg_tab
m7	label	byte	 	; ⠡��� ��⠭���� ०���
 	db	2ch,28h,2dh,29h,2ah,2eh,1eh,29h


set_mode proc	near
 	mov	dx,03d4h	; ���� 梥⭮�� ������
 	mov	bl,0	 ; ��� ���祭�� ��� 梥⭮�� ������
 	cmp	di,30h	 	; ��⠭����� �/� ������ ?
 	jne	m8	 	; ���室, �᫨ 㪠��� 梥⭮�
 	mov	al,7	 	; 㪠���� �/� ०��
 	mov	dx,03b4h	; ���� ��� �/� ������
 	inc	bl	 	; ��⠭����� ०�� ��� �/� ������
m8:	mov	ah,al	 	; ��࠭��� ०�� � AH
 	mov	crt_mode,al
 	mov	addr_6845,dx	; ��࠭��� ���� �ࠢ���饣� ����
 	 	 	 	; ��� ��⨢���� ��ᯫ��
 	push	ds
 	push	ax	 	; ��࠭��� ०��
 	push	dx	 	; ��࠭��� ���祭�� ���� �뢮��
 	add	dx,4	 	; 㪠���� ���� ॣ���� �ࠢ�����
 	mov	al,bl	 	; ������� ०�� ��� ������
 	out	dx,al	 	; ��� �࠭�
 	pop	dx	 	; ����⠭����� DX
 	sub	ax,ax
 	mov	ds,ax	 	; ��⠭����� ���� ⠡���� ����஢
 	assume	ds:abs0
 	lds	bx,parm_ptr ; ������� ���祭�� ��ࠬ��஢ ������ ���
 	pop	ax	 	; ����⠭����� AX
 	assume	ds:code
 	mov	cx,m4	   ; ��⠭����� ����� ⠡���� ��ࠬ��஢
 	cmp	ah,2	 	; ��।������ ०���
 	jc	m9	 	; ०�� 0 ��� 1 ?
 	add	bx,cx	 	; ��� ��砫� ⠡���� ��ࠬ��஢
 	cmp	ah,4
 	jc	m9	 	; ०�� 2 ��� 3
 	add	bx,cx	 	; ��砫� ⠡���� ��� ��䨪�
 	cmp	ah,7
 	jc	m9	 	; ०��� 4, 5 ��� 6 ?
 	add	bx,cx	 	; ��� ��砫� ⠡���� ��� �/� ������

;   BX 㪠�뢠�� �� ��ப� ⠡���� ���樠����樨

m9:	 	 	 	; OUT_INIT
 	push	ax	 	; ��࠭��� ०�� � AH
 	xor	ah,ah	 	;

;   ���� ⠡����, ��⠭�������騩 ���� ॣ���஢ � �뢮��騩 ���祭��
; �� ⠡����

m10:
 	mov	al,ah	 	;
 	out	dx,al
 	inc	dx	 	; 㪠���� ���� ����
 	inc	ah	 	;
 	mov	al,byte ptr [bx]   ; ������� ���祭�� ⠡����
 	out	dx,al	 	; ��᫠�� ��ப� �� ⠡���� � ����
 	inc	bx	 	; +1 � ����� ⠡����
 	dec	dx	 	; -1 �� ���� ����
 	loop	m10	 	; ��।��� ��� ⠡��� ?
 	pop	ax	 	; ������ ०���
 	pop	ds	 	; ������ ᥣ����
 	assume	ds:data

;   ���樠������ ���� ��ᯫ��

 	xor	di,di	 	; DI=0
 	mov	crt_start,di	; ��࠭��� ��砫�� ����
 	mov	active_page,0	; ��⠭����� ��⨢��� ��࠭���
 	mov	cx,8192 	; ������⢮ ᫮� � 梥⭮� ������
 	cmp	ah,4	 	; ���� ��䨪�
 	jc	m12	 	; ��� ���樠����樨 ��䨪�
 	cmp	ah,7	 	; ���� �/� ������
 	je	m11	 	; ���樠������ �/� ������
 	xor	ax,ax	 	; ��� ����᪮�� ०���
 	jmp	short m13	; ������ ����
m11:	 	 	 	; ���樠������ �/� ������
 	mov	cx,2048 	; ��'�� ���� �/� ������
m12:
 	mov	ax,' '+7*256    ; ��������� �ࠪ���⨪� ��� ����
m13:	 	 	 	; ������ ����
 	rep	stosw	 	; ��������� ������� ���� �஡�����

;   ��ନ஢���� ���� �ࠢ����� ०����

 	mov	cursor_mode,67h   ; ��⠭����� ०�� ⥪�饣� ����� (ERROR - MUS BE 607h)
 	mov	al,crt_mode	; ������� ०�� � ॣ���� AX
 	xor	ah,ah
 	mov	si,ax	 	; ⠡��� 㪠��⥫�� ०���
 	mov	dx,addr_6845	; �����⮢��� ���� ���� ��� �뢮��
 	add	dx,4
 	mov al,cs:m7[si]
 	out	dx,al
 	mov	crt_mode_set,al

;   ��ମ஢���� ������⢠ �������

 	mov al,cs:m6[si]
 	xor	ah,ah
 	mov	crt_cols,ax	; �����⢮ ������� �� �࠭�

;   ��⠭����� ������ �����

	and	si,0eh	 	; db 81h,0E6h,0Eh,00h	; ###Gleb###
 	mov cx,cs:m5[si]  ; ����� ��� ���⪨
 	mov	crt_len,cx
 	mov	cx,8	 	; ������ �� ����樨 �����
 	mov	di,offset cursor_posn
 	push	ds	 	; ����⠭����� ᥣ����
 	pop	es
 	xor	ax,ax
 	rep	stosw	 	; ��������� ��ﬨ

;   ��⠭���� ॣ���� ᪠��஢����

 	inc	dx	 	; ��� ���� ᪠��஢���� �� 㬮�砭��
 	mov	al,30h	 	; ���祭�� 30H ��� ��� ०����,
 	 	 	 	; �᪫��� 640�200
 	cmp	crt_mode,6	; ०�� �/� 640�200
 	jnz	m14	 	; �᫨ �� 640�200
 	mov	al,3fh	 	; �᫨ 640�200, � �������� � 3FH
m14:	out	dx,al	 	; �뢮� �ࠢ��쭮�� ���祭�� � ���� 3D9
 	mov	crt_pallette,al   ; ��࠭��� ���祭�� ��� �ᯮ�짮�����

;   ��ଠ��� ������

video_return:
 	pop	di
 	pop	si
 	pop	bx
m15:
 	pop	cx	 	; ����⠭������� ॣ���஢
 	pop	dx
 	pop	ds
 	pop	es
 	iret	 	 	; ������ �� ���뢠���
set_mode	endp
;--------------------
; set_ctype
;
;   �� �ணࠬ�� ��⠭�������� ࠧ��� ����� � �ࠢ����� ��
;
;   ����
;	   (CX) - ᮤ�ন� ࠧ��� �����. (CH - ��砫쭠� �࠭��,
;	 	  CL - ����筠� �࠭��)
;
;--------------------
set_ctype proc	near
 	mov	ah,10	 	; ��⠭����� ॣ���� 6845 ��� �����
 	mov	cursor_mode,cx	 ; ��࠭��� � ������ ������
 	call	m16	 	; �뢮� ॣ���� CX
 	jmp	short video_return

m16:
 	mov	dx,addr_6845	; ���� ॣ����
 	mov	al,ah	 	; ������� ���祭��
 	out	dx,al	 	; ��⠭����� ॣ����
 	inc	dx	 	; ॣ���� ������
 	mov	al,ch	 	; �����
 	out	dx,al
 	dec	dx
 	mov	al,ah
 	inc	al	 	; 㪠���� ��㣮� ॣ���� ������
 	out	dx,al	 	; ��⠭����� ��ன ॣ����
 	inc	dx
 	mov	al,cl	 	; ��஥ ���祭�� ������
 	out	dx,al
 	ret	 	 	; ������
set_ctype	endp
;----------------------------
; set_cpos
;
;   ��⠭����� ⥪���� ������ �����
;
;   ����
;	   DX - ��ப�, �������,
;	   BH - ����� ��࠭���.
;
;-----------------------------
set_cpos proc	near
 	mov	cl,bh
 	xor	ch,ch	 	; ��⠭����� ���稪
 	sal	cx,1	 	; ᤢ�� ᫮��
 	mov	si,cx
 	mov word ptr [si + offset cursor_posn],dx  ;��࠭��� 㪠��⥫�
 	cmp	active_page,bh
 	jnz	m17
 	mov	ax,dx	 	; ������� ��ப�/������� � AX
 	call	m18	 	; ��⠭����� �����
m17:
 	jmp	short video_return  ; ������
set_cpos	endp

;   ��⠭����� ������ �����, AX ᮤ�ন�  ��ப�/�������

m18	proc	near
 	call	position
 	mov	cx,ax
 	add	cx,crt_start	; ᫮���� � ��砫�� ���ᮬ ��࠭���
 	sar	cx,1	 	; ������ �� 2
 	mov	ah,14
 	call	m16
 	ret
m18	endp
;---------------------------
; read_cursor
;
;   ����� ⥪�饥 ��������� �����
;
;   �� �ணࠬ�� ����⠭�������� ⥪�饥 ��������� �����
;
;   ����
;	   BH - ����� ��࠭���
;
;   �����
;	   DX - ��ப�/������� ⥪�饩 ����樨 �����,
;	   CX - ࠧ��� ����� � �ࠢ����� ��
;
;---------------------------
read_cursor proc near
 	mov	bl,bh
 	xor	bh,bh
 	sal	bx,1
 	mov dx,word ptr [bx+offset cursor_posn]
 	mov	cx,cursor_mode
 	pop	di	 	; ����⠭����� ॣ�����
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
;    �� �ணࠬ�� ��⠭�������� ��⨢��� ��࠭��� ���� ������ ���
;
;   ����
;	   AL - ��࠭��.
;
;   �����
;	   �믮������ ��� ����஫��� ��� ��⠭���� ����� ��࠭���.
;
;-----------------------------
act_disp_page proc	near
 	mov	active_page,al	; ��࠭��� ���祭�� ��⨢��� ��࠭���
 	mov	cx,crt_len	; ������� ����� ������ ����
 	cbw	 	 	; �८�ࠧ����� AL
 	push	ax	 	; ��࠭��� ���祭�� ��࠭���
 	mul	cx
 	mov	crt_start,ax	; ��࠭��� ��砫�� ����
 	 	 	 	; ��� ᫥���饣� �ॡ������
 	mov	cx,ax	 	; ���᫠�� ��砫�� ���� � CX
 	sar	cx,1	 	; ������ �� 2
 	mov	ah,12
 	call	m16
 	pop	bx	 	; ����⠭����� ���祭�� ��࠭���
 	sal	bx,1
 	mov ax,word ptr [bx+offset cursor_posn]   ; ������� �����
 	call	m18	 	; ��⠭����� ������ �����
 	jmp	video_return
act_disp_page	endp
;------------------------------
; set color
;
;   �� �ணࠬ�� ��⠭�������� 梥⮢�� �������.
;
;   ����
;	   BH=0
;	 	BL - ���祭�� ��� ������ ���, �ᯮ��㥬�� ��� �롮�
;	 	     梥⮢�� ������� (梥� ������� ����� ��� 梥⭮�
;	 	     ��䨪� 320�200 ��� 梥� ����� ��� 梥⭮�� 40�25)
;	   BH=1
;	 	BL - ����� 梥⮢�� �������
;	 	     BL=0 - ������(1), ����(2), �����(3),
;	 	     BL=1 - ���㡮�(1), 䨮��⮢�(2), ���� (3)
;
;   �����
;	   ��⠭�������� 梥⮢�� ������ � ����� 3D9.
;------------------------------
set_color proc	near
 	mov	dx,addr_6845	; ���� ��� �������
 	add	dx,5	 	; ��⠭����� ����
 	mov	al,crt_pallette   ; ������� ⥪�饥 ���祭�� �������
 	or	bh,bh	 	; 梥� 0 ?
 	jnz	m20	 	; �뢮� 梥� 1

;   ��ࠡ�⪠ 梥⮢�� ������� 0

 	and	al,0e0h 	; ����� 5 ������ ���
 	and	bl,01fh 	; ����� 3 ����� ���
 	or	al,bl
m19:
 	out	dx,al	 	 ; �뢮� ��࠭���� 梥� � ���� 3D9
 	mov	crt_pallette,al  ; ��࠭��� ���祭�� 梥�
 	jmp	video_return

;   ��ࠡ�⪠ 梥⮢�� ������� 1

m20:
 	and	al,0dfh 	;
 	shr	bl,1	 	; �஢���� ����訩 ��� BL
 	jnc	m19
 	or	al,20h	 	;
 	jmp	short m19	; ���室
set_color	endp
;--------------------------
; video state
;
;   �� �ணࠬ�� ����砥� ⥪�饥 ���ﭨ� ��� � AX.
;
;	   AH - ������⢮ �������,
;	   AL - ⥪�騩 ०��,
;	   BH - ����� ��⨢��� ��࠭���.
;
;---------------------------
video_state proc	near
 	mov	ah,byte ptr crt_cols   ; ������� ������⢮ �������
 	mov	al,crt_mode	 	; ⥪�騩 ०��
 	mov	bh,active_page	; ������� ⥪���� ��⨢��� ��࠭���
 	pop	di	 	; ����⠭����� ॣ�����
 	pop	si
 	pop	cx
 	jmp	m15	 	; ������ � �ணࠬ��
video_state	endp
;---------------------------
; position
;
;   �� �ணࠬ�� ������ ���� ���� ᨬ���� � ०��� ����.
;
;   ����
;	   AX - ����� ��ப�, ����� �������,
;
;   �����
;	   AX - ᬥ饭�� ᨬ���� � ���न��⠬� (AH, AL) �⭮�⥫쭮
;	 	��砫� ��࠭���. ���饭�� ��������� � �����.
;
;----------------------------
position proc	near
 	push	bx	 	; ��࠭��� ॣ����
 	mov	bx,ax
 	mov	al,ah	 	; ��ப� � AL
 	mul	byte ptr crt_cols
 	xor	bh,bh
 	add	ax,bx	 	; �������� � ���祭�� �������
 	sal	ax,1	 	; * 2 ��� ���⮢ ��ਡ��
 	pop	bx
 	ret
position	endp
;-------------------------------
;scroll up
;
;   �� �ணࠬ�� ��६�頥� ���� ᨬ����� ����� �� �࠭�.
;
;   ����
;	   AH - ⥪�訩 ०��,
;	   AL - ������⢮ ��६�頥��� ��ப
;	   CX - ���न���� ������ ���孥�� 㣫� �����
;	 	(��ப�, �������),
;	   DX - ���न���� �ࠢ��� ������� 㣫�
;	   BH - ��ਡ�� ᨬ���� �஡��� (��� ��஡�������� �᢮�����-
;	 	���� ��ப),
;
;   �����
;	   ������஢���� ���� ��ᯫ��.
;
;-----------------------------------
 	assume cs:code,ds:data,es:data
scroll_up proc	near
 	mov	bl,al	    ; ��࠭��� ������⢮ ��६�頥��� ��ப
 	cmp	ah,4	 	; �஢�ઠ ����᪮�� ०���
 	jc	n1
 	cmp	ah,7	 	; �஢�ઠ �/� ������
 	je	n1
 	jmp	graphics_up
n1:
 	push	bx	 	; ��࠭��� ����� ��ਡ�� � BH
 	mov	ax,cx	 	; ���न���� ������ ���孥�� 㣫�
 	call	scroll_position
 	jz	n7
 	add	si,ax
 	mov	ah,dh	 	; ��ப�
 	sub	ah,bl
n2:
 	call	n10	 	; ᤢ����� ���� ��ப�
 	add	si,bp
 	add	di,bp	 	; 㪠���� �� ᫥������ ��ப� � �����
 	dec	ah	 	; ���稪 ��ப ��� ᤢ���
 	jnz	n2	 	; 横� ��ப�
n3:	 	 	 	; ���⪠ �室�
 	pop	ax	 	; ����⠭����� ��ਡ�� � AH
 	mov	al,' '          ; ��������� �஡�����
n4:	 	 	 	; ���⪠ ���稪�
 	call	n11	 	; ���⪠ ��ப�
 	add	di,bp	 	; 㪠���� ᫥������ ��ப�
 	dec	bl	 	; ���稪 ��ப ��� ᤢ���
 	jnz	n4	 	; ���⪠ ���稪�
n5:	 	 	 	; ����� ᤢ���
 	mov	ax,dat
 	mov	ds,ax
 	cmp	crt_mode,7	; �/� ������ ?
 	je	n6	 	; �᫨ �� - �ய�� ०��� ���
 	mov	al,crt_mode_set
 	mov	dx,03d8h	; ��⠭����� ���� 梥⭮�� ������
 	out	dx,al
n6:
 	jmp	video_return
n7:
 	mov	bl,dh
 	jmp	short n3	; ������
scroll_up	endp

;   ��ࠡ�⪠ ᤢ���

scroll_position proc	near
 	cmp	crt_mode,2
 	jb	n9	 	; ��ࠡ���� 80�25 �⤥�쭮
 	cmp	crt_mode,3
 	ja	n9

;   ���� ��� 梥⭮�� ������ � ०��� 80�25

 	push	dx
 	mov	dx,3dah 	; ��ࠡ�⪠ 梥⭮�� ������
 	push	ax
n8:	 	 	 	; �������� ����㯭��� ��ᯫ��
 	in	al,dx
 	test	al,8
 	jz	n8	 	; �������� ����㯭��� ��ᯫ��
 	mov	al,25h
 	mov	dx,03d8h
 	out	dx,al	 	; �몫���� ���
 	pop	ax
 	pop	dx
n9:	call	position
 	add	ax,crt_start	; ᬥ饭�� ��⨢��� ��࠭���
 	mov	di,ax	 	; ��� ���� ᤢ���
 	mov	si,ax
 	sub	dx,cx	 	; DX=��ப�
 	inc	dh
 	inc	dl	 	; �ਡ������� � ��砫�
 	xor	ch,ch	 	; ��⠭����� ���訩 ���� ���稪� � 0
 	mov	bp,crt_cols	; ������� �᫮ ������� ��ᯫ��
 	add	bp,bp	 	; 㢥����� �� 2 ���� ��ਡ��
 	mov	al,bl	 	; ������� ���稪 ��ப�
 	mul	byte ptr crt_cols   ; ��।����� ᬥ饭�� �� ����,
 	add	ax,ax	  ; 㬭�������� �� 2, ��� ���� ��ਡ��
 	push	es	; ��⠭����� ������ ��� ������ ����
 	pop	ds
 	cmp	bl,0	 	; 0 ����砥� ����� �����
 	ret	 	 	; ������ � ��⠭����� 䫠����
scroll_position endp

;   ��६�饭�� ��ப�

n10	proc	near
 	mov	cl,dl	 	; ������� ������� ��� ��।��
 	push	si
 	push	di	 	; ��࠭��� ��砫�� ����
 	rep	movsw	 	; ��।��� ��� ��ப� �� �࠭
 	pop	di
 	pop	si	 	; ����⠭����� ������
 	ret
n10	endp

;   ���⪠ ��ப�

n11	proc	near
 	mov	cl,dl	 	; ������� ������� ��� ���⪨
 	push	di
 	rep	stosw	 	; ��������� ����� ����
 	pop	di
 	ret
n11	endp
;------------------------
; scroll_down
;
;   �� �ணࠬ�� ��६�頥� ���� ᨬ����� ���� ��
; �࠭�, �������� ���孨� ��ப� �஡���� � ������� ��ਡ�⮬
;
;   ����
;	   AH - ⥪�騩 ०��,
;	   AL - ������⢮ ��ப,
;	   CX - ���孨� ���� 㣮� �����,
;	   DX - �ࠢ� ������ 㣮� �����,
;	   BH - ��ਡ�� ᨬ����-�������⥫� (�஡���),
;
;-------------------------
scroll_down proc near
 	std	 	 	; ��� ���ࠢ����� ᤢ��� ����
 	mov	bl,al	 	; ������⢮ ��ப � BL
 	cmp	ah,4	 	; �஢�ઠ ��䨪�
 	jc	n12
 	cmp	ah,7	 	; �஢�ઠ �/� ������
 	je	n12
 	jmp	graphics_down
n12:
 	push	bx	 	; ��࠭��� ��ਡ�� � BH
 	mov	ax,dx	 	; ������ �ࠢ� 㣮�
 	call	scroll_position
 	jz	n16
 	sub	si,ax	 	; SI ��� ����樨
 	mov	ah,dh
 	sub	ah,bl	 	; ��।��� ������⢮ ��ப
n13:
 	call	n10	 	; ��।��� ���� ��ப�
 	sub	si,bp
 	sub	di,bp
 	dec	ah
 	jnz	n13
n14:
 	pop	ax	 	; ����⠭����� ��ਡ�� � AH
 	mov	al,' '
n15:
 	call	n11	 	; ���⪠ ����� ��ப�
 	sub	di,bp	 	; ��३� � ᫥���饩 ��ப�
 	dec	bl
 	jnz	n15
 	jmp	n5	 	; ����� ᤢ���
n16:
 	mov	bl,dh
 	jmp	short n14
scroll_down  endp
;--------------------
; read_ac_current
;
;   �� �ணࠬ�� ���뢠�� ��ਡ�� � ��� ᨬ����, ��室�饣��� � ⥪�-
; 饬 ��������� �����
;
;   ����
;	   AH - ⥪�騩 ०��,
;	   BH - ����� ��࠭��� (⮫쪮 ��� ०��� ����),
;
;   �����
;	   AL - ��� ᨬ����,
;	   AH - ��ਡ�� ᨬ����.
;
;---------------------
 	assume cs:code,ds:data,es:data
read_ac_current proc near
 	cmp	ah,4	 	; �� ��䨪� ?
 	jc	p1
 	cmp	ah,7	 	; �/� ������ ?
 	je	p1
 	jmp	graphics_read
p1:	 	 	 	;
 	call	find_position
 	mov	si,bx	 	; ��⠭����� ������ � SI


 	mov	dx,addr_6845	; ������� ������ ����
 	add	dx,6	 	; ���� ���ﭨ�
 	push	es
 	pop	ds	 	; ������� ᥣ����
p2:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jnz	p2	 	; ��������
 	cli	 	   ; ��� �ਧ���� ࠧ�襭�� ���뢠���
p3:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jz	p3	 	; ��������
 	lodsw	 	 	; ������� ᨬ���/��ਡ��
 	jmp	video_return
read_ac_current endp

find_position proc near
 	mov	cl,bh	 	; �������� ��࠭��� � CX
 	xor	ch,ch
 	mov	si,cx	 	; ��।��� � SI ������, 㬭������ �� 2
 	sal	si,1	 	; ��� ᫮�� ᬥ饭��
 	mov ax,word ptr [si+offset cursor_posn]   ; ������� ��ப�/��-
 	 	 	 	; ����� �⮩ ��࠭���
 	xor	bx,bx	 	; ��⠭����� ��砫�� ���� � 0
 	jcxz	p5
p4:
 	add	bx,crt_len	; ����� ����
 	loop	p4
p5:
 	call	position
 	add	bx,ax
 	ret
find_position	endp
;---------------------
;write_ac_current
;
;   �� �ணࠬ�� �����뢠�� ��ਡ�� � ��� ᨬ���� � ⥪���� ������
; �����
;
;   ����
;	   AH - ⥪�騩 ०��,
;	   BH - ����� ��࠭���,
;	   CX - ���稪 (������⢮ ����७�� ᨬ�����),
;	   AL - ��� ᨬ����,
;	   BL - ��ਡ�� ᨬ���� (��� ०���� ����) ��� 梥� ᨬ����
;	 	��� ��䨪�.
;
;----------------------
write_ac_current proc near
 	cmp	ah,4	 	; �� ��䨪� ?
 	jc	p6
 	cmp	ah,7	 	; �� �/� ������ ?
 	je	p6
 	jmp	graphics_write
p6:
 	mov	ah,bl	 	; ������� ��ਡ�� � AH
 	push	ax	 	; �࠭���
 	push	cx	 	; �࠭��� ���稪
 	call	find_position
 	mov	di,bx	 	; ���� � DI
 	pop	cx	 	; ������ ���稪
 	pop	bx	 	; � ᨬ���
p7:	 	 	 	; 横� �����


 	mov	dx,addr_6845	; ������� ������ ����
 	add	dx,6	 	; 㪠���� ���� ���ﭨ�
p8:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jnz	p8	 	; �������
 	cli	 	     ; ��� �ਧ���� ࠧ�襭�� ���뢠���
p9:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jz	p9	 	; �������
 	mov	ax,bx
 	stosw	 	 	; ������� ᨬ��� � ��ਡ��
 	sti	 	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	loop	p7
 	jmp	video_return
write_ac_current  endp
;---------------------
;write_c_current
;
;   �� �ணࠬ�� �����뢠�� ᨬ��� � ⥪���� ������ �����.
;
;   ����
;	   BH - ����� ��࠭��� (⮫쪮 ��� ���� ०����),
;	   CX - ���稪 (������⢮ ����७�� ᨬ����),
;	   AL - ��� ᨬ����,
;
;-----------------------
write_c_current proc near
 	cmp	ah,4	 	; �� ��䨪� ?
 	jc	p10
 	cmp	ah,7	 	; �� �/� ������ ?
 	je	p10
 	jmp	graphics_write
p10:
 	push	ax	 	; ��࠭��� � �⥪�
 	push	cx	 	; ��࠭��� ������⢮ ����७��
 	call	find_position
 	mov	di,bx	 	; ���� � DI
 	pop	cx	 	; ������ ������⢮ ����७��
 	pop	bx	 	; BL - ��� ᨬ����
p11:


 	mov	dx,addr_6845	; ������� ������ ����
 	add	dx,6	 	; 㪠���� ���� ���ﭨ�
p12:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jnz	p12	 	; �������
 	cli	 	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
p13:
 	in	al,dx	 	; ������� ���ﭨ�
 	test	al,1
 	jz	p13	 	; ��������
 	mov	al,bl	 	; ����⠭����� ᨬ���
 	stosb	 	 	; ������� ᨬ���
 	inc	di
 	loop	p11	 	; 横�
 	jmp	video_return
write_c_current endp
;---------------------
; read dot - write dot
;
;   �� �ணࠬ�� ���뢠��/�����뢠�� ���.
;
;   ����
;	   DX - ��ப� (0-199),
;	   CX - ������� (0-639),
;	   AL - 梥� �뢮����� �窨.
;	 	�᫨ ��� 7=1, � �믮������ ������
;	 	XOR ��� ���祭��� �窨 �� ���� ��ᯫ�� � ���祭���
;	 	�窨 �� ॣ���� AL (�� ����� �窨).
;
;   �����
;	   AL - ���祭�� ��⠭��� �窨
;
;----------------------
 	assume cs:code,ds:data,es:data
read_dot proc	near
 	call	r3	 	; ��।����� ��������� �窨
 	mov	al,es:[si]	; ������� ����
 	and	al,ah	 	; ࠧ��᪨஢��� ��㣨� ���� � ����
 	shl	al,cl	 	;
 	mov	cl,dh	 	; ������� �᫮ ��� १����
 	rol	al,cl
 	jmp	video_return	; ��室 �� ���뢠���
read_dot	endp

write_dot proc	near
 	push	ax	 	; ��࠭��� ���祭�� �窨
 	push	ax	 	; �� ࠧ
 	call	r3	 	; ��।����� ��������� �窨
 	shr	al,cl	 	; ᤢ�� ��� ��⠭���� ��� �� �뢮��
 	and	al,ah	 	; ����� ��㣨� ����
 	mov	cl,es:[si]	; ������� ⥪�騩 ����
 	pop	bx
 	test	bl,80h
 	jnz	r2
 	not	ah	  ; ��⠭����� ���� ��� ��।�� 㪠������ ���
 	and	cl,ah
 	or	al,cl
r1:
 	mov es:[si],al	 	; ����⠭����� ���� � �����
 	pop	ax
 	jmp	video_return	; � ��室� �� �ணࠬ��
r2:
 	xor	al,cl	 	; �᪫���饥 ��� ��� ���祭�ﬨ �窨
 	jmp	short r1	; ����� �����
write_dot	endp

;-------------------------------------
;
;   �� �ணࠬ�� ��।���� �⭮�⥫�� ���� ���� (����� ����
; ��ᯫ��), �� ���ண� ������ ���� ��⠭�/����ᠭ� �窠,� ������묨
; ���न��⠬�.
;
;   ����
;	   DX - ��ப� (0-199),
;	   CX - ������� (0-639).
;
;   �����
;	   SI - �⭮�⥫�� ���� ����, ᮤ�ঠ饣� ��� �����
;	 	���� ��ᯫ��,
;	   AH - ��᪠ ��� �뤥����� ���祭�� �������� �窨 ����� ����
;	   CL - ����⠭� ᤢ��� ��᪨ � AH � �ࠩ��� ����� ������,
;	   DH - �᫮ ���, ��।������ ���祭�� �窨.
;
;--------------------------------------

r3	proc	near
 	push	bx	 	; ��࠭��� BX
 	push	ax	 	; ��࠭��� AL

;   ���᫥��� ��ࢮ�� ���� 㪠������ ��ப� 㬭������� �� 40.
; �������訩 ��� ��ப� ��।���� �⭮/������ 80-���⮢�� ��ப�.

 	mov	al,40
 	push	dx	 	; ��࠭��� ���祭�� ��ப�
 	and	dl,0feh 	; ��� �⭮/���⭮�� ���
 	mul	dl   ; AX ᮤ�ন� ���� ��ࢮ�� ���� 㪠������ ��ப�
 	pop	dx	 	; ����⠭����� ���
 	test	dl,1	 	; �஢���� �⭮���/���⭮���
 	jz	r4	 	; ���室,�᫨ ��ப� �⭠�
 	add	ax,2000h	; ᬥ饭�� ��� ��宦����� ������ ��ப
r4:	 	 	 	; �⭠� ��ப�
 	mov	si,ax	 	; ��।��� 㪠��⥫� � SI
 	pop	ax	 	; ����⠭����� ���祭�� AL
 	mov	dx,cx	 	; ���祭�� ������� � DX

;   ��।������ ����⢨⥫��� ����᪨� ०����
;
;   ��⠭���� ॣ���஢ ᮣ��᭮ ०��a�
;
;	  BH - ������⢮ ���, ��।����饥 ���,
;	  BL - ����⠭� �뤥����� �窨 �� ����� ��� ����,
;	  CH - ����⠭� ��� �뤥����� �� ����� ������� ����� ����樨
;	       ��ࢮ�� ���, ��।����饣� ��� � ����, �.�. ����祭��
;	       ���⪠ �� ������� ����� �� 8 (��� ०��� 640�200) ���
;	       ����� �� 4 (��� ०��� 320�200),
;	  CL - ����⠭� ᤢ��� (��� �믮������ ������� �� 8 ��� �� 4).

 	mov	bx,2c0h
 	mov	cx,302h 	; ��⠭���� ��ࠬ��஢
 	cmp	crt_mode,6
 	jc	r5	 	;
 	mov	bx,180h
 	mov	cx,703h 	; ��� ��ࠬ���� ��� ���襣� ॣ����

;   ��।������ ��� ᬥ饭�� � ���� �� ��᪥
r5:
 	and	ch,dl	 	;

;   ��।������ ���� ᬥ饭�� � �������

 	shr	dx,cl	 	; ᤢ�� ��� ���४樨
 	add	si,dx	 	; ������� 㪠��⥫�
 	mov	dh,bh	; ������� 㪠��⥫� ��⮢ १���� � DH

;   ��������� BH (������⢮ ��� � ����) �� CH (��� ᬥ饭��)

 	sub	cl,cl
r6:
 	ror	al,1	; ����� �ࠩ��� ���祭�� � AL ��� �����
 	add	cl,ch	 	; �ਡ����� ���祭�� ��� ᬥ饭��
 	dec	bh	 	; ���稪 ����஫�
 	jnz	r6	; �� ��室� CL ᮤ�ন� ���稪 ᤢ��� ���
 	 	 	 	; ����⠭�������
 	mov	ah,bl	 	; ������� ���� � AH
 	shr	ah,cl	 	; ��।��� ���� � �祩��
 	pop	bx	 	; ����⠭����� ॣ����
 	ret	 	 	; ������ � ����⠭��������
r3	endp

;----------------------------------------
;
;
;    �ணࠬ�� ��६�頥� ���� ᨬ����� ����� � ०��� ��䨪�
;
;-----------------------------------------

graphics_up proc near
 	mov	bl,al	 	; ��࠭��� ������⢮ ᨬ�����
 	mov	ax,cx	 	; ������� ���孨� ���� 㣮� � AX


 	call	graph_posn
 	mov	di,ax	 	; ��࠭��� १����

;   ��।����� ࠧ���� �����

 	sub	dx,cx
 	add	dx,101h
 	sal	dh,1
 	sal	dh,1

 	cmp	crt_mode,6
 	jnc	r7

 	sal	dl,1
 	sal	di,1	 	;

;   ��।������ ���� ���筨�� � ����
r7:
 	push	es
 	pop	ds
 	sub	ch,ch	 	; ���㫨�� ���訩 ���� ���稪�
 	sal	bl,1	 	; 㬭������ �᫠ ��ப �� 4
 	sal	bl,1
 	jz	r11	 	; �᫨ 0, ������ �஡���
 	mov	al,bl	 	; ������� �᫮ ��ப � AL
 	mov	ah,80	 	; 80 ����/��ப
 	mul	ah	 	; ��।����� ᬥ饭�� ���筨��
 	mov	si,di	 	; ��⠭����� ���筨�
 	add	si,ax	 	; ᫮���� ���筨� � ���
 	mov	ah,dh	 	; ������⢮ ��ப
 	sub	ah,bl	 	; ��।����� �᫮ ��६�饭��

r8:
 	call	r17	 	; ��६�饭�� ����� ��ப�
 	sub	si,2000h-80	; ��६�饭�� � ᫥������ ��ப�
 	sub	di,2000h-80
 	dec	ah	 	; ������⢮ ��ப ��� ��६�饭��
 	jnz	r8	; �த������, ���� �� ��ப� �� ��६�������

;   ���������� �᢮��������� ��ப
r9:
 	mov	al,bh
r10:
 	call	r18	 	; ������ ��� ��ப�
 	sub	di,2000h-80	; 㪠���� �� ᫥������
 	dec	bl	 	; ������⢮ ��ப ��� ����������
 	jnz	r10	 	; 横� ���⪨
 	jmp	video_return	; � ��室� �� �ணࠬ��

r11:
 	mov	bl,dh	 	; ��⠭����� ������⢮ �஡����
 	jmp	short r9	; ������
graphics_up	endp

;---------------------------------
;
;   �ணࠬ�� ��६�頥� ���� ᨬ����� ���� � ०��� ��䨪�
;
;----------------------------------

graphics_down proc	near
 	std	 	 	; ��⠭����� ���ࠢ�����
 	mov	bl,al	 	; ��࠭��� ������⢮ ��ப
 	mov	ax,dx	 	; ������� ������ �ࠢ�� ������ � AX


 	call	graph_posn
 	mov	di,ax	 	; ��࠭��� १����

;   ��।������ ࠧ��� �����

 	sub	dx,cx
 	add	dx,101h
 	sal	dh,1
 	sal	dh,1


 	cmp	crt_mode,6
 	jnc	r12

 	sal	dl,1
 	sal	di,1
 	inc	di

;   ��।������ ���� ���筨�� � ����
r12:
 	push	es
 	pop	ds
 	sub	ch,ch	 	; ���㫨�� ���訩 ���� ���稪�
 	add	di,240	 	; 㪠���� ��᫥���� ��ப�
 	sal	bl,1	 	; 㬭����� ������⢮ ��ப �� 4
 	sal	bl,1
 	jz	r16	 	; �᫨ 0, ��������� �஡����
 	mov	al,bl	 	; ������� ������⢮ ��ப � AL
 	mov	ah,80	 	; 80 ����/��ப
 	mul	ah	 	; ��।����� ᬥ饭�� ���筨��
 	mov	si,di	 	; ��⠭����� ���筨�
 	sub	si,ax	 	; ������ ᬥ饭��
 	mov	ah,dh	 	; ������⢮ ��ப
 	sub	ah,bl	 	; ��।����� �᫮ ��� ��६�饭��

r13:
 	call	r17	 	; ��६����� ���� ��ப�
 	sub	si,2000h+80	; ��⠭����� ᫥������ ��ப�
 	sub	di,2000h+80
 	dec	ah	 	; ������⢮ ��ப ��� ��६�饭��
 	jnz	r13	 	; �த������, ���� �� �� ��६�������

;   ���������� �᢮��������� ��ப
r14:
 	mov	al,bh	 	; ��ਡ�� ����������
r15:
 	call	r18	 	; ������ ��ப�
 	sub	di,2000h+80	; 㪠���� ᫥������ ��ப�
 	dec	bl	 	; �᫮ ��ப ��� ����������
 	jnz	r15
 	cld	 	 	; ��� �ਧ���� ���ࠢ�����
 	jmp	video_return	; � ��室� �� �ணࠬ��

r16:
 	mov	bl,dh
 	jmp	short r14	; ������
graphics_down endp

;   �ணࠬ�� ��६�饭�� ����� ��ப�

r17	proc	near
 	mov	cl,dl	 	; �᫮ ���� � ��ப�
 	push	si
 	push	di	 	; �࠭��� 㪠��⥫�
 	rep	movsb	 	; ��६����� �⭮� ����
 	pop	di
 	pop	si
 	add	si,2000h
 	add	di,2000h	; 㪠���� ���⭮� ����
 	push	si
 	push	di	 	; ��࠭��� 㪠��⥫�
 	mov	cl,dl	 	; ������ ���稪�
 	rep	movsb	 	; ��।��� ���⭮� ����
 	pop	di
 	pop	si	 	; ������ 㪠��⥫��
 	ret	 	 	; ������ � �ணࠬ��
r17	endp

;   ���������� �஡����� ��ப�

r18	proc	near
 	mov	cl,dl	 	; �᫮ ���� � ����
 	push	di	 	; �࠭��� 㪠��⥫�
 	rep	stosb	 	; ��������� ����� ���祭��
 	pop	di	 	; ������ 㪠��⥫�
 	add	di,2000h	; 㪠���� ���⭮� ����
 	push	di
 	mov	cl,dl
 	rep	stosb	 	; ��������� ���⭮� ����
 	pop	di
 	ret	 	 	; ������ � �ணࠬ��
r18	endp

;--------------------------------------
;
;  graphics_write
;
;   �� �ணࠬ�� �����뢠�� ᨬ��� � ०��� ��䨪�
;
;   ����
;	   AL - ��� ᨬ����,
;	   BL - ��ਡ�� 梥�, ����� �ᯮ������ � ����⢥ 梥�
;	 	��।���� ����� (梥� ᨬ����). �᫨ ��� 7 BL=1, �
;	 	�믮������ ������ XOR ��� ���⮬ � ���� � ���⮬
;	 	� ������� ᨬ�����,
;	   CX - ���稪 ����७�� ᨬ����
;
;----------------------------------------

 	assume cs:code,ds:data,es:data
graphics_write proc near
 	mov	ah,0	 	; AH=0
 	push	ax	 	; ��࠭��� ���祭�� ���� ᨬ����

;   ��।������ ����樨 � ������ ���� ���뫪�� �㤠 ���� �祪

 	call	s26	 	; ���� �祩�� � ������ ����
 	mov	di,ax	 	; 㪠��⥫� ������ � DI

;   ��।������ ������ ��� ����祭�� ���� �窨

 	pop	ax	 	; ����⠭����� ��� �窨
 	cmp	al,80h	 	; �� ��ன �������� ?
 	jae	s1	 	; ��

;   ����ࠦ���� ���� � ��ࢮ� �������� �����

 	mov	si, offset crt_char_gen  ; ᬥ饭�� ����ࠦ����
 	push	cs	 	; �࠭��� ᥣ���� � �⥪�
 	jmp	short s2	; ��।����� ०��

;   ����ࠦ���� ���� �� ��ன ��� �����

s1:
 	sub	al,80h	 	; 0 �� ����� ��������
 	push	ds	 	; �࠭��� 㪠��⥫� ������
 	sub	si,si
 	mov	ds,si	 	; ��⠭����� ������
 	assume	ds:abs0
 	lds	si,ext_ptr	; ������� ᬥ饭��
 	mov	dx,ds	 	; ������� ᥣ����
 	assume	ds:data
 	pop	ds	 	; ����⠭����� ᥣ���� ������
 	push	dx	 	; �࠭��� ᥣ���� � �⥪�

;   ���������� ����᪮�� ०��� ����樨

s2:	 	 	 	; ��।������ ०���
 	sal	ax,1	 	; 㬭����� 㪠��⥫� ���� �� 8
 	sal	ax,1
 	sal	ax,1
 	add	si,ax	 	; SI ᮤ�ন� ᬥ饭��
 	cmp	crt_mode,6
 	pop	ds	 	; ����⠭����� 㪠��⥫� ⠡����
 	jc	s7	; �஢�ઠ ��� �।��� ࠧ���饩 ᯮᮡ����

;   ��᮪�� ࠧ����� ᯮᮡ�����
s3:
 	push	di	 	; ��࠭��� 㪠��⥫� ������
 	push	si	 	; ��࠭��� 㪠��⥫� ����
 	mov	dh,4	 	; ������⢮ 横���
s4:
 	lodsb	 	 	; �롮ઠ �⭮�� ����
 	test	bl,80h
 	jnz	s6
 	stosb
 	lodsb
s5:
 	mov es:[di+1fffh],al	; ��������� �� ��ன ���
 	add	di,79	 	; ��।��� ᫥������ ��ப�
 	dec	dh	 	; �믮����� 横�
 	jnz	s4
 	pop	si
 	pop	di	 	; ����⠭����� 㪠��⥫� ������
 	inc	di	; 㪠���� �� ᫥������ ������ ᨬ����
 	loop	s3	 	; ������� ��᫥���騥 ᨬ����
 	jmp	video_return

s6:
 	xor al,es:[di]
 	stosb	 	 	; ��������� ���
 	lodsb	 	 	; �롮ઠ ���⭮�� ᨬ����
 	xor  al,es:[di+1fffh]
 	jmp	s5	 	; �������

;   �।��� ࠧ����� ᯮᮡ����� �����
s7:
 	mov	dl,bl	 	; ��࠭��� ���訩 ��� 梥�
 	sal	di,1	; 㬭����� �� 2, �.�. ��� ����/ᨬ����
 	call	s19	 	; ���७�� BL �� ������� ᫮�� 梥�
s8:
 	push	di
 	push	si
 	mov	dh,4	 	; �᫮ 横���
s9:
 	lodsb	 	 	; ������� ��� �窨
 	call	s21	 	; �த㡫�஢���
 	and	ax,bx	 	; ���訢���� � ������� 梥�
 	test	dl,80h
 	jz	s10
 	xor	ah,es:[di]	; �믮����� �㭪�� XOR � "����"
 	xor	al,es:[di+1]	; � "����" 梥⠬�
s10:	mov  es:[di],ah 	; ��������� ���� ����
 	mov es:[di+1],al	; ��������� ��ன ����
 	lodsb	 	 	; ������� ��� �窨
 	call	s21
 	and	ax,bx	 	; ���訢���� ���⭮�� ����
 	test	dl,80h
 	jz  s11
 	xor	ah,es:[di+2000h]   ; �� ��ࢮ� ��������
 	xor	al,es:[di+2001h]   ; � �� ��ன ��������
s11:	mov	es:[di+2000h],ah
 	mov	es:[di+2001h],al   ; ��������� ����� ���� ����
 	add	di,80	 	; 㪠���� ᫥������ �祩��
 	dec	dh
 	jnz	s9	 	; �������
 	pop	si
 	pop	di
 	add	di,2	 	; ���室 � ᫥���饬� ᨬ����
 	loop	s8	 	; ०�� �����
 	jmp	video_return
graphics_write	endp
;-------------------------------------
;graphics_read
;
;   �ணࠬ�� ���뢠�� ᨬ��� � ०��� ��䨪�
;
;-------------------------------------
graphics_read	proc	near
 	call	s26
 	mov	si,ax	 	; ��࠭��� � SI
 	sub	sp,8	 	; ��१�ࢨ஢��� � �⥪� 8 ���� ���
 	 	 	 	; ����� ᨬ���� �� ���� ��ᯫ��
 	mov	bp,sp	 	; 㪠��⥫� ��� �࠭���� ������

;   ��।������ ०��� ��䨪�

 	cmp	crt_mode,6
 	push	es
 	pop	ds	 	; 㪠���� ᥣ����
 	jc	s13	 	; �।��� ࠧ����� ᯮᮡ�����

;  ��᮪�� ࠧ����� ᯮᮡ����� ��� ��⠢����

 	mov	dh,4
s12:
 	mov	al,byte ptr [si]   ; ������� ���� ����
 	mov byte ptr [bp],al	   ; ��������� � �����
 	inc	bp
 	mov al,byte ptr [si+2000h]   ; ������� ����訩 ����
 	mov byte ptr [bp],al
 	inc	bp
 	add	si,80	 	; ���室 �� ᫥������ ���� ��ப�
 	dec	dh
 	jnz	s12	 	; �������
 	jmp	short s15 	; ���室 � �࠭���� ����� �祪
	nop

;   �।��� ࠧ����� ᯮᮡ����� ��� ���뢠���
s13:
 	sal	si,1	  ; ᬥ饭�� 㬭����� �� 2, �.�. 2 ����/ᨬ����
 	mov	dh,4
s14:
 	call	s23
 	add	si,2000h
 	call	s23
 	sub	si,2000h-80
 	dec	dh
 	jnz	s14	 	; �������

;   ���࠭���
s15:
 	mov	di,offset crt_char_gen	 ; ᬥ饭��
 	push	cs
 	pop	es
 	sub	bp,8	 	; ����⠭����� ��砫�� ����
 	mov	si,bp
 	cld	 	 	; ��⠭����� ���ࠢ�����
 	mov	al,0
s16:
 	push	ss
 	pop	ds
 	mov	dx,128	 	; ������⢮ ᨬ�����
s17:
 	push	si
 	push	di
 	mov	cx,8	 	; ������⢮ ���� � ᨬ����
 	repe	cmpsb	 	; �ࠢ����
 	pop	di
 	pop	si
 	jz	s18	 	; �᫨ �ਧ��� = 0,ᨬ���� �ࠢ������
 	inc	al	 	; �� �ࠢ������
 	add	di,8	 	; ᫥���騩 ��� �窨
 	dec	dx	 	; - 1 �� ���稪�
 	jnz	s17	 	; �������


 	cmp	al,0
 	je	s18    ; ���室, �᫨ �� ᪠��஢���, �� ᨬ���
 	 	       ; �� ������
 	sub	ax,ax
 	mov	ds,ax	 	; ��⠭����� ������ �����
 	assume	ds:abs0
 	les	di,ext_ptr
 	mov	ax,es
 	or	ax,di
 	jz	s18
 	mov	al,128	 	; ��砫� ��ன ���
 	jmp	short s16	; �������� � �������
 	assume	ds:data

s18:
 	add	sp,8
 	jmp	video_return
graphics_read	endp

;---------------------------------
;
;   �� �ணࠬ�� �������� ॣ���� BX ���� ����訬� ��⠬�
; ॣ���� BL.
;
;   ����
;	   BL - �ᯮ��㥬� 梥� (����訥 ��� ���).
;
;   �����
;	   BX - �ᯮ��㥬� 梥� (��ᥬ� ����७�� ���� ��⮢ 梥�).
;
;---------------------------------
s19	proc	near
 	and	bl,3	 	; �뤥���� ���� 梥�
 	mov	al,bl	 	; ��९���� � AL
 	push	cx	 	; ��࠭��� ॣ����
 	mov	cx,3	 	; ������⢮ ����७��
s20:
 	sal	al,1
 	sal	al,1	 	; ᤢ�� ����� �� 2
 	or	bl,al	 	; � BL ������������� १����
 	loop	s20	 	; 横�
 	mov	bh,bl	 	; ���������
 	pop	cx
 	ret	 	 	; �� �믮�����
s19	endp
;--------------------------------------
;
;   �� �ணࠬ�� ���� ���� � AL � 㤢������ �� ����, �ॢ���
; 8 ��� � 16 ���. ������� ����頥��� � AX.
;--------------------------------------
s21	proc	near
 	push	dx	 	; ��࠭��� ॣ�����
 	push	cx
 	push	bx
 	mov	dx,0	 	; १���� 㤢�����
 	mov	cx,1	 	; ��᪠
s22:
 	mov	bx,ax
 	and	bx,cx	 	; �뤥����� ���
 	or	dx,bx	 	; ������������ १����
 	shl	ax,1
 	shl	cx,1	 	; ᤢ����� ���� � ���� �� 1
 	mov	bx,ax
 	and	bx,cx
 	or	dx,bx
 	shl	cx,1	; ᤨ� ��᪨, ��� �뤥����� ᫥���饣� ���
 	jnc	s22
 	mov	ax,dx
 	pop	bx	 	; ����⠭����� ॣ�����
 	pop	cx
 	pop	dx
 	ret	 	 	; � ��室� �� ���뢠���
s21	endp

;----------------------------------
;
;   �� �ணࠬ�� �८�ࠧ��뢠�� ����-��⮢�� �।�⠢����� �窨
; (C1,C0) � ������⮢��
; (C1,C0) � ������⮢���.
;
;----------------------------------
s23	proc	near
 	mov	ah,byte ptr [si]   ; ������� ���� ����
 	mov	al,byte ptr [si+1]   ; ������� ��ன ����
 	mov	cx,0c000h	; 2 ��� ��᪨
 	mov	dl,0	 	; ॣ���� १����
s24:
 	test	ax,cx	 	; �஢�ઠ 2 ������ ��� AX �� 0
 	clc	 	 	; ����� �ਧ��� ��७�� CF
 	jz	s25	 	; ���室 �᫨ 0
 	stc	 	 	; ��� - ��⠭����� CF
s25:	rcl	dl,1	 	; 横���᪨� ᤢ��
 	shr	cx,1
 	shr	cx,1
 	jnc	s24	 	; �������, �᫨ CF=1
 	mov byte ptr [bp],dl	; ��������� १����
 	inc	bp
 	ret	 	 	; � ��室� �� ���뢠���
s23	endp

;---------------------------------------
;
;   �� �ணࠬ�� ��।����� ��������� ����� �⭮�⥫쭮	 ��� �
; ��砫� ���� � ०��� ��䨪�	 	 	 	 /ᨬ���
;
;   �����
;	   AX  ᮤ�ন� ᬥ饭�� �����
;
;-----------------------------------------
s26	proc	near
 	mov	ax,cursor_posn	; ������� ⥪�饥 ��������� �����
graph_posn	label	near
 	push	bx	 	; ��࠭��� ॣ����
 	mov	bx,ax	 	; ��࠭��� ⥪�饥 ��������� �����
 	mov	al,ah	 	; ��ப�
 	mul	byte ptr crt_cols   ; 㬭����� �� ����/�������
 	shl	ax,1	 	; 㬭����� �� 4
 	shl	ax,1
 	sub	bh,bh	 	; �뤥���� ���祭�� �������
 	add	ax,bx	 	; ��।����� ᬥ饭��
 	pop	bx
 	ret	 	 	; � ��室� �� ���뢠���
s26	endp

;----------------------------------------
;
;   ������� ⥫�⠩� (INT 10H, AH=14)
;
;   �� �ணࠬ�� �뢮��� ᨬ��� � ���� ��� � �����६����� ���-
; ������ ����樨 ����� � ��।�������� ����� �� �࠭�.
;   ��᫥ ����� ᨬ���� � ��᫥���� ������ ��ப� �믮������ ��-
; ⮬���᪨� ���室 �� ����� ��ப�. �᫨ ��࠭�� �࠭� ��-
; ������� (������ ����� 24,79/39), �믮������ ��६�饭�� �࠭�
; �� ���� ��ப� �����. �᢮��������� ��ப� ���������� ���祭���
; ��ਡ�� ᨬ���� (��� ��䠢�⭮-��஢��� ०���). ��� ��䨪� 梥�=00
; ��᫥ ����� ��।���� ᨬ���� ����� ��⠭����� � ᫥������ ������.
;
;   ����
;	   AL - ��� �뢮������ ᨬ����,
;	   BL - 梥� ��।���� ����� ��� ��䨪�.
;
;----------------------------------------

 	assume	cs:code,ds:data
write_tty	proc	near
 	push	ax	 	; ��࠭��� ॣ�����
 	push	ax
 	mov	ah,3
 	int	10h	 	; ����� ��������� ⥪�饣� �����
 	pop	ax	 	; ����⠭����� ᨬ���

;   DX ᮤ�ন� ⥪���� ������ �����

 	cmp	al,8	 	; ���� ������ �� ���� ������ ?
 	je	u8	 	; ������ �� ���� ������
 	cmp	al,0dh	 	; ���� ������ ���⪨ ?
 	je	u9	 	; ������ ���⪨
 	cmp	al,0ah	 	; ���� �࠭�� ���� ?
 	je	u10	 	; �࠭�� ����
 	cmp	al,07h	 	; ��㪮��� ᨣ��� ?
 	je	u11	 	; ��㪮��� ᨣ���

;   ������ ᨬ���� �� �࠭

 	mov	bh,active_page
 	mov	ah,10	 	; ������ ᨬ���� ��� ��ਡ��
 	mov	cx,1
 	int	10h

;   ��������� ����� ��� ᫥���饣� ᨬ����

 	inc	dl
 	cmp	dl,byte ptr crt_cols
 	jnz	u7	 	; ���室 � ��⠭���� �����
 	mov	dl,0
 	cmp	dh,24	 	; �஢�ઠ �࠭�筮� ��ப�
 	jnz	u6	 	; ��⠭����� �����

;   ����� �࠭�
u1:

 	mov	ah,2
 	mov	bh,0
 	int	10h	 	; ��⠭����� �����


 	mov	al,crt_mode	; ������� ⥪�騩 ०��
 	cmp	al,4
 	jc	u2	 	; ���뢠��� �����
 	cmp	al,7
 	mov	bh,0	 	; 梥� ������� �����
 	jne	u3

u2:	 	 	 	; ���뢠��� �����
 	mov	ah,8
 	int	10h	   ; ����� ᨬ���/��ਡ�� ⥪�饣� �����
 	mov	bh,ah	 	; ��������� � BH

;   ��६�饭�� �࠭� �� ���� ��ப� �����

u3:
 	mov	ax,601h
 	mov	cx,0	 	; ���孨� ���� 㣮�
 	mov	dh,24	 	; ���न���� ������� �ࠢ���
 	mov	dl,byte ptr crt_cols	; 㣫�
 	dec	dl
u4:
 	int	10h

;   ��室 �� ���뢠���

u5:
 	pop	ax	 	; ����⠭����� ᨬ���
 	jmp	video_return	; ������ � �ணࠬ��

u6:	 	 	 	; ��⠭����� �����
 	inc	dh	 	; ᫥����� ��ப�
u7:	 	 	 	; ��⠭����� �����
 	mov	ah,2
 	jmp	short u4	; ��⠭����� ���� �����

;   ����� ����� �� ���� ������ �����

u8:
 	cmp	dl,0
 	je	u7	 	; ��⠭����� �����
 	dec	dl	 	; ��� - ᭮�� ��� ��।���
 	jmp	short u7

;   ��६�饭�� ����� � ��砫� ��ப�

u9:
 	mov	dl,0
 	jmp	short u7	; ��⠭����� �����

;   ��६�饭�� ����� �� ᫥������ ��ப�

u10:
 	cmp	dh,24	 	; ��᫥���� ��ப� �࠭�
 	jne	u6	 	; �� - ᤢ�� �࠭�
 	jmp	short u1	; ��� - ᭮�� ��⠭����� �����

;   ��㪮��� ᨣ���

u11:
 	mov	bl,2	 	; ��� ���⥫쭮��� ��㪮���� ᨣ����
 	call	beep	 	; ���
 	jmp	short u5	; ������
write_tty	endp

;
;----------------------------------------
;
;   �� �ணࠬ�� ���뢠�� ��������� ᢥ⮢��� ���.
; �஢������ ��४���⥫� � �ਣ��� ᢥ⮢��� ���. �᫨ ��� 1 �-
; ����� ���ﭨ� (���� 3DA)=1, � �ਣ��� ��⠭�����. �᫨ ��� 2 ����
; 3DA=0, � ��⠭����� ��४���⥫�.
;   ����� 3BD � 3DC �ᯮ������� ��� ��⠭���� � ��� �ਣ��� � ���-
; ����⥫� ᢥ⮢��� ���.
;   � ॣ����� R16 � R17 ����஫��� ᮤ�ন��� ���� ���न��� ���
; �⭮�⥫쭮 ��砫� ���� ��ᯫ��.
;   �᫨ �ਣ��� � ��४���⥫� ��⠭������, � �ணࠬ�� ��।����
; ��������� ᢥ⮢��� ���, � ��⨢��� ��砥, ������ ��� �뤠�
; ���ଠ樨.
;
;   � ����� ��1841 �㭪�� �� �����ন������
;-------------------------------------------------




 	assume	cs:code,ds:data

;   ������ ���ࠢ�� ��� ����祭�� 䠪��᪨� ���न��� ᢥ⮢��� ���

v1	label	byte
 	db	3,3,5,5,3,3,3,4

read_lpen	proc	near


 	mov	ah,0	 	; ��� ������, �᫨ ��� �� ����祭�
 	mov	dx,addr_6845	; ������� ������ ���� 6845
 	add	dx,6	 	; 㪠���� ॣ���� ���ﭨ�
 	in	al,dx	 	; ������� ॣ���� ���ﭨ�
 	test	al,4	 	; �஢���� ��४���⥫� ᢥ⮢��� ���
 	jnz	v6	 	; �� ��⠭������, ������

;   �஢�ઠ �ਣ��� ᢥ⮢��� ���

 	test	al,2	 	; �஢���� �ਣ��� ᢥ⮢��� ���
 	jz	v7	 	; ������ ��� ��� �ਣ���

;   �ਣ��� �� ��⠭�����, ����� ���祭�� � AH

 	mov	ah,16	 	; ��� ॣ����� ᢥ⮢��� ��� 6845

;   ���� ॣ���஢, 㪠������ AH � �८�ࠧ������ � ��ப� ������� � DX

 	mov	dx,addr_6845
 	mov	al,ah
 	out	dx,al	 	; �뢥�� � ����
 	inc	dx
 	in	al,dx	 	; ������� ���祭�� �� ����
 	mov	ch,al	 	; ��࠭��� ��� � CX
 	dec	dx	 	; ॣ���� ����
 	inc	ah
 	mov	al,ah	 	; ��ன ॣ���� ������
 	out	dx,al
 	inc	dx
 	in	al,dx	 	; ������� ��஥ ���祭�� ������
 	mov	ah,ch	 	; AX ᮤ�ন� ���न���� ᢥ⮢��� ���


 	mov	bl,crt_mode
 	sub	bh,bh	 	; �뤥���� ���祭�� ०��� � BX
 	mov	bl,cs:v1[bx]	; ���祭�� ���ࠢ��
 	sub	ax,bx
 	sub	ax,crt_start

 	jns	v2
 	mov	ax,0	 	; �������� 0

;   ��।����� ०��

v2:
 	mov	cl,3	 	; ��⠭����� ���稪
 	cmp	crt_mode,4	; ��।�����, ०�� ��䨪� ���
 	 	 	 	; ����
 	jb	v4	 	; ����-���
 	cmp	crt_mode,7
 	je	v4	 	; ����-���

;   ����᪨� ०��

 	mov	dl,40	 	; ����⥫� ��� ��䨪�
 	div	dl	; ��।������ ��ப� (AL) � ������� (AH)
 	 	 	 	; �।��� AL 0-99, AH 0-39

;   ��।������ ��������� ��ப� ��� ��䨪�

 	mov	ch,al	 	; ��࠭��� ���祭�� ��ப� � CH
 	add	ch,ch	 	; 㬭����� �� 2 �⭮/���⭮� ����
 	mov	bl,ah	 	; ���祭�� ������� � BX
 	sub	bh,bh	 	; 㬭����� �� 8 ��� �।���� १����
 	cmp	crt_mode,6	; ��।����� �।��� ��� ���������
 	 	 	 	; ࠧ������ ᯮᮡ�����
 	jne	v3	 	; �� �������� ࠧ����� ᯮᮡ�����
 	mov	cl,4	 ; ᤢ����� ���祭�� ������襩 ࠧ���饩
 	 	 	 ; ᯮᮡ����
 	sal	ah,1	; ᤢ�� �� 1 ࠧ�� ����� ���祭�� �������
v3:	 	 	 	; �� �������� ࠧ����� ᯮᮡ�����
 	shl	bx,cl	; 㬭����� �� 16 ��� ������襩 ࠧ���饩
 	 	 	; ᯮᮡ����

;   ��।������ ��������� ᨬ���� ��� ����

 	mov	dl,ah	 	; ���祭�� ������� ��� ������
 	mov	dh,al	 	; ���祭�� ��ப�
 	shr	dh,1	 	; ������ �� 4
 	shr	dh,1	 	; ��� ���祭�� � �।���� 0-24
 	jmp	short v5	; ������ ᢥ⮢��� ���

;   ����� ���� ᢥ⮢��� ���

v4:	 	 	 	; ���� ᢥ⮢��� ���
 	div	byte ptr crt_cols  ; ��ப�, �������
 	mov	dh,al	 	; ��ப� � DH
 	mov	dl,ah	 	; ������� � DL
 	sal	al,cl	 	; 㬭������ ��ப �� 8
 	mov	ch,al
 	mov	bl,ah
 	xor	bh,bh
 	sal	bx,cl
v5:
 	mov	ah,1	 	; 㪠����, �� �� ��⠭������
v6:
 	push	dx	 	; ��࠭��� ���祭�� ������
 	mov	dx,addr_6845	; ������� ������ ����
 	add	dx,7
 	out	dx,al	 	; �뢮�
 	pop	dx	 	; ����⠭����� ���祭��
v7:
 	pop	di	 	 ; ����⠭����� ॣ�����
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
;    �ணࠬ�� ��।������ ࠧ��� �����.
;
;    �� �ணࠬ�� ��।��� � ॣ���� AX ��'�� ����� � ������.
;
;-----------------------------------------

 	assume	cs:code,ds:data
memory_size_determine	proc	far
 	sti	 	 	; ��⠭����� ��� ࠧ�襭�� ���뢠���
 	push	ds	 	; ��࠭��� ᥣ����
 	mov	ax,dat	 	; ��⠭����� ������
 	mov	ds,ax
 	mov	ax,memory_size	; ������� ���祭�� ࠧ��� �����
 	pop	ds	 	; ����⠭����� ᥣ����
 	iret	 	 	; ������ �� ���뢠���
memory_size_determine	endp

;--- int 11-------------------------------
;
;    �ணࠬ�� ��।������ ��⠢� ����㤮�����.
;
;   �� �ணࠬ�� ��।��� � ॣ���� AX ���䨣���� ��⥬�.
;
;   ������ ॣ���� AX ����� ᫥���饥 ���祭��:
;   0	    - ����㧪� ��⥬� � ����;
;   5,4     - ⨯ ������祭���� ��� � ०�� ��� ࠡ���:
;	      00 - �� �ᯮ������;
;	      01 - 40�25, �୮-���� ०�� 梥⭮�� ����᪮��
;	 	   ���;
;	      10 - 80�25, �୮-���� ०�� 梥⭮�� ����᪮��
;	 	   ���;
;	      11 - 80�25, �୮-���� ०�� �����஬���� ���.
;   7,6     - ������⢮ ����;
;   11,10,9 - ������⢮ �����஢ ��몠 �2;
;   12	    - ������ ���;
;   15,14   - ������⢮ ������� ���ன��.
;   ������ 6 � 7 ��⠭���������� ⮫쪮 � ⮬ ��砥, �᫨
; ࠧ�� 0 ��⠭����� � "1".
;
;----------------------------------------------

 	assume	cs:code,ds:data
equipment	proc	far
 	sti	 	 	; ��⠭����� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds	 	; ��࠭��� ᥣ����
 	mov	ax,dat	 	; ��⠭����� ������
 	mov	ds,ax
 	mov	ax,equip_flag	; ������� ���䨣���� ��⥬�
 	pop	ds	 	; ����⠭����� ᥣ����
 	iret	 	 	; ������ �� ���뢠���
equipment	endp

;****************************************
;
;   ����㧪� ������������
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
		mov	dx, 3D8h
		in	al, dx
		mov	bl, al
		mov	al, 0
		out	dx, al
		xor	di, di
		mov	cx, 1024
		xor	ax, ax
		cld
		repe stosw
		mov	si, offset crt_char_gen
		mov	cx, 1024
		xor	di, di

bct4:
		mov	al, cs:[si]
		mov	es:[di], al
		inc	si
		inc	di
		loop	bct4
		mov	al, 0
		mov	dx, 3DFh
		out	dx, al
		mov	dx, 3D8h
		mov	al, bl
		out	dx, al
		ret
bct	endp

;
;   ������ ����� ���᪨� �����쪨� �㪢 (������)
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

;	�६���� ��ࠡ��稪 ���뢠��� ��몠 �2

rs232_io:
		mov	ax, 61F0h
		iret

ex_memory:
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
;   ������������ ����᪨� 320�200 � 640�200
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
;   �ணࠬ�� ��⠭����-���뢠��� �६��� ��⮪
;
;   �� �ணࠬ�� ���ᯥ稢��� �믮������ ���� �㭪権, ��� ������
; �������� � ॣ���� AH:
;   AH=0 - ����� ⥪�饥 ���ﭨ� �ᮢ. ��᫥ �믮������ �����-
; �� ॣ����� CX � DX ᮤ�ঠ� ������ � ������� ��� ���稪�.
;   �᫨ ॣ���� AL ᮤ�ন� "0", � ��� ���� � �祭�� �����
; ��⮪, �� �� ��㣮� ���祭�� ��� ���室�� �� ᫥���騥
; ��⪨;
;
;   AH=1 - ������� ⥪�饥 ���ﭨ� �ᮢ. �������� CX � DX
; ᮤ�ঠ� ������ � ������� ��� ���稪�.
;
;------------------------------------------
 	assume	cs:code,ds:data
time_of_day	proc	far
 	sti	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds	; ��࠭��� ᥣ����
 	push	ax	; ��࠭��� ��ࠬ����
 	mov	ax,dat
 	mov	ds,ax
 	pop	ax
 	or	ah,ah	; AH=0 ?
 	jz	t2  ; ��, ���室 � ���뢠��� ⥪�饣� ���ﭨ�
 	dec	ah	; AH=1 ?
 	jz	t3  ; ��, ���室 � ��⠭���� ⥪�饣� ���ﭨ�

t1:	; ������ �� �ணࠬ��

 	sti	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	pop	ds	; ������ ᥣ����
 	iret	 	; ������ � �ணࠬ��,�맢��襩 ��楤���

t2:	; ����� ⥪�饥 ���ﭨ� �ᮢ

 	cli	 	; ����� �ਧ��� ࠧ�襭�� ���뢠���
 	mov	al,timer_ofl  ; ����� � AL 䫠��� ���室� �� ᫥-
 	mov	timer_ofl,0   ; ���騥 ��⪨ � ����� ��� � �����
 	mov	cx,timer_high	 	; ��⠭����� ������ � �������
 	mov	dx,timer_low	 	; ��� ���稪�
 	jmp	short t1

t3:	; ��⠭����� ⥪�饥 ���ﭨ� �ᮢ

 	cli	 	; ��� �ਧ���� ࠧ�襭�� ���뢠���
 	mov	timer_low,dx	 	; ��⠭����� ������� � ������
 	mov	timer_high,cx	 	; ��� ���稪�
 	mov	timer_ofl,0	; ��� 䫠��� ���室� �१ ��⪨
 	jmp	short t1	; ������ �� �ணࠬ�� ����� �६���
time_of_day	endp

;-------int 08-------------------
;
;   �ணࠬ�� ��ࠡ�⪨ ���뢠��� ⠩��� ��580��53 (INT 8H) ��-
; ࠡ��뢠�� ���뢠���, �������୮ ��������騥 �� �㫥���� ������
; ⠩���, �� �室 ���ண� �������� ᨣ���� � ���⮩ 1,228 ���,
; ����騥�� �� 56263 ��� ���ᯥ祭�� 18,2 ���뢠��� � ᥪ㭤�.
;   �� ��ࠡ�⪥ ���뢠��� ���४������ �ணࠬ��� ���稪,
; �࠭�騩�� � ����� �� ����� 0046CH (������ ���� ���稪�) �
; ����� 0047EH (����� ���� ���稪�) � �ᯮ��㥬� ��� ���-
; ����� �६��� ��⮪.
;   � �㭪樨 �ணࠬ�� �室�� ���४�� ���稪�, �ࠢ���饣�
; �����⥫�� ����. ��᫥ ���㫥��� ���稪� �����⥫� �몫�砥���.
;   ����� 1CH ���� ����������� ���짮��⥫� �室��� � ��������
; �ணࠬ�� � ���⮩ ���뢠��� ⠩��� (18.2 ���뢠��� � ᥪ�-
; ��). ��� �⮣� � ⠡��� ����஢ ���뢠��� �� ����� 007CH
; ����室��� ������ ���� ���짮��⥫�᪮� �ணࠬ��.
;
;---------------------------------------------------

timer_int	proc	far
 	sti	 	; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds
 	push	ax
 	push	dx
 	mov	ax,dat
 	mov	ds,ax
 	inc	timer_low    ; +1 � ���襩 ��� ���稪�
 	jnz	t4
 	inc	timer_high   ; +1 � ���襩 ��� ���稪�

t4:	; ���� ���稪� = 24 �ᠬ

 	cmp	timer_high,018h
 	jnz	t5
 	cmp	timer_low,0b0h
 	jnz	t5

;   ������ ���௠� 24 ��

 	mov	timer_high,0   ; ��� ���襩 � ����襩 ��⥩
 	mov	timer_low,0    ; ���稪� � ��⠭���� 䫠��� ���-
 	mov	timer_ofl,1    ; 室� ��� �� ᫥���騥 ��⪨

;   �몫�祭�� ���� ����, �᫨ ���稪 �ࠢ����� ���஬
; ���௠�

t5:
 	dec	motor_count
 	jnz	t6	 	; ���室, �᫨ ���稪 �� ��⠭�����
 	and	motor_status,0f0h
 	mov	al,0ch
 	mov	dx,03f2h
 	out	dx,al	 	; �몫���� ����

t6:
 	int	1ch	; ��।�� �ࠢ����� �ணࠬ�� ���짮��⥫�
 	mov	al,eoi
 	out	020h,al        ; ����� ���뢠���
 	pop	dx
 	pop	ax
 	pop	ds
 	iret	 	 	; ������ �� ���뢠���
timer_int	endp
;---------------------------------
;
;   �� ����� ��।����� � ������� ���뢠��� 8086 �� �६�
; ����祭�� ��⠭��.
;
;---------------------------------
vector_table	label	word	; ⠡��� ����஢ ���뢠���

 	dw	offset timer_int	; ���뢠��� 8
 	dw	cod

 	dw	offset kb_int	 	; ���뢠��� 9
 	dw	cod

 	dw	offset dummy_return	; ���뢠��� �
 	dw	cod
 	dw	offset dummm_return	; ���뢠��� B
 	dw	cod
 	dw	offset dummm_return	; ���뢠��� C
 	dw	cod
 	dw	offset dummy_return	; ���뢠��� D
 	dw	cod
 	dw	offset disk_int 	; ���뢠��� E
 	dw	cod

 	dw	offset dummy_return	; ���뢠��� F
 	dw	cod
 	dw	offset video_io 	; ���뢠��� 10H
 	dw	cod

 	dw	offset equipment	; ���뢠��� 11H
 	dw	cod

 	dw	offset memory_size_determine	; ���뢠��� 12H
 	dw	cod

 	dw	offset diskette_io	; ���뢠��� 13H
 	dw	cod

 	dw	offset rs232_io 	; ���뢠���  14H
 	dw	cod

 	dw	offset ex_memory	; int 15h
 	dw	cod

 	dw	offset keyboard_io	; ���뢠��� 16H
 	dw	cod

 	dw	offset printer_io	; ���뢠��� 17H
 	dw	cod
	
		dw 0			; ���뢠��� 18H
		dw 0F600h		; ROM BASIC ???
		
 	dw	offset boot_strap	; ���뢠��� 19H
 	dw	cod

 	dw	time_of_day	; ���뢠��� 1�H - �६� ��⮪
 	dw	cod

 	dw	dummy_return	; ���뢠��� 1BH - ���뢠��� ����������
 	dw	cod

 	dw	dummy_return	; ���뢠��� 1C - ���뢠��� ⠩���
 	dw	cod

 	dw	video_parms	; ���뢠��� 1D - ��ࠬ���� �����
 	dw	cod

 	dw	offset	disk_base   ;���뢠��� 1EH - ��ࠬ���� ����
 	dw	cod

 	dw	0		; 1FH - ���� ⠡���� ���짮��-
 	dw	0		; ⥫�᪮�� �������⥫쭮�� ������������

dummy_return:
 	iret

;---int 5----------------------
;
;   �ணࠬ�� �뢮�� �� ����� ᮤ�ন���� ���� ��� ��뢠����
; �����६���� ����⨥� ������ ��� � ������ ��४��祭�� ॣ���-
; ஢. ������ ����� ��࠭���� �� �����襭�� ��楤��� ��ࠡ�⪨
; ���뢠���. ����୮� ����⨥ ��������� ������ �� �६� ��ࠡ�⪨
; ���뢠��� ����������.
;   �� �믮������ �ணࠬ�� � ����ﭭ� ��।������� ࠡ�祩
; ������ ����� �� ����� 0500H ��⠭���������� ᫥�����
; ���ଠ��:
;   0	 - ᮤ�ন��� ���� ��� �� �� �뢥���� �� �����, ����
; �뢮� 㦥 �����襭;
;   1	 - � ����� �뢮�� ᮤ�ন���� ���� ��� �� �����;
;   255  - �� ���� �����㦥�� �訡��.
;-----------------------------------------------------

 	assume	cs:code,ds:xxdata

print_screen	proc	far
 	sti	 	     ; ��� �ਧ��� ࠧ�襭�� ���뢠���
 	push	ds
 	push	ax
 	push	bx
 	push	cx   ; �㤥� �ᯮ�짮������ ��������� �㪢� ��� �����
 	push	dx   ; �㤥� ᮤ�ঠ�� ⥪�饥 ��������� �����
 	mov	ax,xxdat	; ���� 50
 	mov	ds,ax
 	cmp	status_byte,1	; ����� ��⮢� ?
 	jz	exit	 	; ���室, �᫨ ����� ��⮢�
 	mov	status_byte,1	;
 	mov	ah,15	 	; �ॡ���� ⥪�騩 ०�� �࠭�
 	int	10h	 	; AL - ०��, AH - �᫮ ��ப/�������
 	 	 	 	; BH - ��࠭��,�뢥������ �� �࠭


;*************************************8
;
;   � �⮬ ����:
;	 	    AX - �������, ��ப�,
;	 	    BH - ����� �⮡ࠦ����� ��࠭���.
;
;   �⥪ ᮤ�ন� DS, AX, BX, CX, DX.
;
;	 	    AL - ०��
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
;    ���뢠��� �����, ��室�饣��� � ⥪�饩 ����樨 �����
; � �뢮� �� �����
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

;   ������ ���⪨

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
;   ����祭�� ��⠭��
;
;--------------------------------------

;vector segment at 0ffffh

;   ���室 �� ����祭�� ��⠭��

POST: 		db	0eah		; db	0eah,5bh,0e0h,00h,0f0h	; jmp reset
		dw	offset reset, cod	; ###Gleb###

		db '04/24/81'

		db    0, 0	
		
		db    0	;  
;vector ends






code	ends
 	end	POST
