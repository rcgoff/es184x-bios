;_______________
;  Расположение прерываний 8086
;_________________________
abs0	segment at 0
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
stac	segment at 30h
 	dw	128 dup(?)



tos	label	word
stac	ends

;______________________
;  Область данных ПЗУ
;____________________
data segment at 40h
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
xxdata segment	at 50h
status_byte db	?
xxdata	ends

;_________________
;  Буфер ЭЛИ
;___________________
video_ram segment at 0b800h
regen	label	byte
regenw	label	word
 	db	16384 dup(?)



video_ram ends
