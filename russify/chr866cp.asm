;Верхние 128 символов шрифта 8x8 в кодировке DOS (cp866)
;Расположение символов полностью соответствует кодовой странице 866.
;
;Таблица получена из таблицы crt_char_rus из листинга
;BIOS ЕС1841 путем перетасовки 8-байтовых последовательностей,
;соответствующих символам, за исключением: 
;	-Символы с кодами 0xE0..0xF1 оставлены неизменными
;	-Символы с кодами 0xF2..0xFB, 0xFD...0xFF взяты из файла ega.cpi
;	 (8x8, кодовая страница 866) Windows 7
;	-Символ номера с кодом 0xFC взят из шрифта в книге Фроловых
;	 "Программирование видеоадаптеров CGA/EGA/VGA", т.к. красивый
;	-Символы с кодами 0xB0..0xB2 взяты из таблицы crt_char_ibm,
;	 т.к. там они существенно лучше, чем были в crt_char_rus
;
;
;Л.Ядренников (RCgoff),17.04.20, 13.08.20,29.09.20 (03.05.21 - UTF-8)

 	db	01eh,036h,066h,066h,07eh,066h,066h,000h    ;80
 	db	07ch,060h,060h,07ch,066h,066h,07ch,000h    ;81
 	db	07ch,066h,066h,07ch,066h,066h,07ch,000h    ;82
 	db	07eh,060h,060h,060h,060h,060h,060h,000h    ;83
 	db	038h,06ch,06ch,06ch,06ch,06ch,0feh,0c6h    ;84
 	db	07eh,060h,060h,07ch,060h,060h,07eh,000h    ;85
 	db	0dbh,0dbh,07eh,03ch,07eh,0dbh,0dbh,000h    ;86
 	db	03ch,066h,006h,01ch,006h,066h,03ch,000h    ;87
 	db	066h,066h,06eh,07eh,076h,066h,066h,000h    ;88
 	db	03ch,066h,06eh,07eh,076h,066h,066h,000h    ;89
 	db	066h,06ch,078h,070h,078h,06ch,066h,000h    ;8a
 	db	01eh,036h,066h,066h,066h,066h,066h,000h    ;8b
 	db	0c6h,0eeh,0feh,0feh,0d6h,0c6h,0c6h,000h    ;8c
 	db	066h,066h,066h,07eh,066h,066h,066h,000h    ;8d
 	db	03ch,066h,066h,066h,066h,066h,03ch,000h    ;8e
 	db	07eh,066h,066h,066h,066h,066h,066h,000h    ;8f
 	db	07ch,066h,066h,066h,07ch,060h,060h,000h    ;90
 	db	03ch,066h,060h,060h,060h,066h,03ch,000h    ;91
 	db	07eh,018h,018h,018h,018h,018h,018h,000h    ;92
 	db	066h,066h,066h,03eh,006h,066h,03ch,000h    ;93
 	db	07eh,0dbh,0dbh,0dbh,07eh,018h,018h,000h    ;94
 	db	066h,066h,03ch,018h,03ch,066h,066h,000h    ;95
 	db	066h,066h,066h,066h,066h,066h,07fh,003h    ;96
 	db	066h,066h,066h,03eh,006h,006h,006h,000h    ;97
 	db	0dbh,0dbh,0dbh,0dbh,0dbh,0dbh,0ffh,000h    ;98
 	db	0dbh,0dbh,0dbh,0dbh,0dbh,0dbh,0ffh,003h    ;99
 	db	0e0h,060h,060h,07ch,066h,066h,07ch,000h    ;9a
 	db	0c6h,0c6h,0c6h,0f6h,0deh,0deh,0f6h,000h    ;9b
 	db	060h,060h,060h,07ch,066h,066h,07ch,000h    ;9c
 	db	078h,00ch,006h,03eh,006h,00ch,078h,000h    ;9d
 	db	0ceh,0dbh,0dbh,0fbh,0dbh,0dbh,0ceh,000h    ;9e
 	db	03eh,066h,066h,066h,03eh,036h,066h,000h    ;9f
 	db	000h,000h,078h,00ch,07ch,0cch,076h,000h    ;a0
 	db	000h,03ch,060h,03ch,066h,066h,03ch,000h    ;a1
 	db	000h,03ch,066h,07ch,066h,066h,07ch,000h    ;a2
 	db	000h,000h,07eh,060h,060h,060h,060h,000h    ;a3
 	db	000h,000h,03ch,06ch,06ch,06ch,0feh,0c6h    ;a4
 	db	000h,000h,03ch,066h,07eh,060h,03ch,000h    ;a5
 	db	000h,000h,0dbh,07eh,03ch,07eh,0dbh,000h    ;a6
 	db	000h,000h,03ch,066h,00ch,066h,03ch,000h    ;a7
 	db	000h,000h,066h,06eh,07eh,076h,066h,000h    ;a8
 	db	000h,018h,066h,06eh,07eh,076h,066h,000h    ;a9
 	db	000h,000h,066h,06ch,078h,06ch,066h,000h    ;aa
 	db	000h,000h,01eh,036h,066h,066h,066h,000h    ;ab
 	db	000h,000h,0c6h,0feh,0feh,0d6h,0c6h,000h    ;ac
 	db	000h,000h,066h,066h,07eh,066h,066h,000h    ;ad
 	db	000h,000h,03ch,066h,066h,066h,03ch,000h    ;ae
 	db	000h,000h,07eh,066h,066h,066h,066h,000h    ;af
;	db	092h,000h,092h,000h,092h,000h,092h,000h    ;b0_es_old
 	db	022H,088H,022H,088H,022H,088H,022H,088H    ;b0_ibm
;	db	092h,049h,092h,049h,092h,049h,092h,000h    ;b1_es_old
 	db      055H,0AAH,055H,0AAH,055H,0AAH,055H,0AAH    ;b1_ibm
;	db	0aah,055h,0aah,055h,0aah,055h,0aah,000h    ;b2_es_old
 	db	0DBH,077H,0DBH,0EEH,0DBH,077H,0DBH,0EEH    ;b2_ibm	
 	db	018h,018h,018h,018h,018h,018h,018h,018h    ;b3
 	db	018h,018h,018h,0f8h,018h,018h,018h,018h    ;b4
 	db	018h,018h,0f8h,018h,0f8h,018h,018h,018h    ;b5
 	db	06ch,06ch,06ch,0ech,06ch,06ch,06ch,06ch    ;b6
 	db	000h,000h,000h,0fch,06ch,06ch,06ch,06ch    ;b7
 	db	000h,000h,0f8h,018h,0f8h,018h,018h,018h    ;b8
 	db	06ch,06ch,0ech,00ch,0ech,06ch,06ch,06ch    ;b9
 	db	06ch,06ch,06ch,06ch,06ch,06ch,06ch,06ch    ;ba
 	db	000h,000h,0fch,00ch,0ech,06ch,06ch,06ch    ;bb
 	db	06ch,06ch,0ech,00ch,0fch,000h,000h,000h    ;bc
 	db	06ch,06ch,06ch,0fch,000h,000h,000h,000h    ;bd
 	db	018h,018h,0f8h,018h,0f8h,000h,000h,000h    ;be
 	db	000h,000h,000h,0f8h,018h,018h,018h,018h    ;bf
 	db	018h,018h,018h,01fh,000h,000h,000h,000h    ;c0
 	db	018h,018h,018h,0ffh,000h,000h,000h,000h    ;c1
 	db	000h,000h,000h,0ffh,018h,018h,018h,018h    ;c2
 	db	018h,018h,018h,01fh,018h,018h,018h,018h    ;c3
 	db	000h,000h,000h,0ffh,000h,000h,000h,000h    ;c4
 	db	018h,018h,018h,0ffh,018h,018h,018h,018h    ;c5
 	db	018h,018h,01fh,018h,01fh,018h,018h,018h    ;c6
 	db	06ch,06ch,06ch,06fh,06ch,06ch,06ch,06ch    ;c7
 	db	06ch,06ch,06fh,060h,07fh,000h,000h,000h    ;c8
 	db	000h,000h,07fh,060h,06fh,06ch,06ch,06ch    ;c9
 	db	06ch,06ch,0efh,000h,0ffh,000h,000h,000h    ;ca
 	db	000h,000h,0ffh,000h,0efh,06ch,06ch,06ch    ;cb
 	db	06ch,06ch,06fh,060h,06fh,06ch,06ch,06ch    ;cc
 	db	000h,000h,0ffh,000h,0ffh,000h,000h,000h    ;cd
 	db	06ch,06ch,0efh,000h,0efh,06ch,06ch,06ch    ;ce
 	db	018h,018h,0ffh,000h,0ffh,000h,000h,000h    ;cf
 	db	06ch,06ch,06ch,0ffh,000h,000h,000h,000h    ;d0
 	db	000h,000h,0ffh,000h,0ffh,018h,018h,018h    ;d1
 	db	000h,000h,000h,0ffh,06ch,06ch,06ch,06ch    ;d2
 	db	06ch,06ch,06ch,07fh,000h,000h,000h,000h    ;d3
 	db	018h,018h,01fh,018h,01fh,000h,000h,000h    ;d4
 	db	000h,000h,01fh,018h,01fh,018h,018h,018h    ;d5
 	db	000h,000h,000h,07fh,06ch,06ch,06ch,06ch    ;d6
 	db	06ch,06ch,06ch,0efh,06ch,06ch,06ch,06ch    ;d7
 	db	018h,018h,0ffh,000h,0ffh,018h,018h,018h    ;d8
 	db	018h,018h,018h,0f8h,000h,000h,000h,000h    ;d9
 	db	000h,000h,000h,01fh,018h,018h,018h,018h    ;da
 	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh    ;db
 	db	000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh    ;dc
 	db	0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h    ;dd
 	db	00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh    ;de
 	db	0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h    ;df

;Далее неизменные столбцы E,F из ЕС-листинга
 	db 000h,000h,07ch,066h,066h,07ch,060h,000h         ;e0
 	db 000h,000h,03ch,066h,060h,066h,03ch,000h         ;e1
 	db 000h,000h,07eh,018h,018h,018h,018h,000h         ;e2
 	db 000h,000h,066h,066h,03eh,006h,03ch,000h         ;e3
 	db 000h,000h,07eh,0dbh,0dbh,07eh,018h,000h         ;e4
 	db 000h,000h,066h,03ch,018h,03ch,066h,000h         ;e5
 	db 000h,000h,066h,066h,066h,066h,07fh,003h         ;e6
 	db 000h,000h,066h,066h,03eh,006h,006h,000h         ;e7
 	db 000h,000h,0dbh,0dbh,0dbh,0dbh,0ffh,000h         ;e8
 	db 000h,000h,0dbh,0dbh,0dbh,0dbh,0ffh,003h         ;e9
 	db 000h,000h,0e0h,060h,07ch,066h,07ch,000h         ;ea
 	db 000h,000h,0c6h,0c6h,0f6h,0deh,0f6h,000h         ;eb
 	db 000h,000h,060h,060h,07ch,066h,07ch,000h         ;ec
 	db 000h,000h,07ch,006h,03eh,006h,07ch,000h         ;ed
 	db 000h,000h,0ceh,0dbh,0fbh,0dbh,0ceh,000h         ;ee
 	db 000h,000h,03eh,066h,03eh,036h,066h,000h         ;ef
 	db 066h,07eh,060h,07ch,060h,060h,07eh,000h         ;f0
 	db 000h,066h,03ch,066h,07eh,060h,03ch,000h         ;f1

;Из шрифта 8x8 кодовой страницы 866 файла ega.cpi Windows 7

 	cp866_code_0f2h	db	03Ch, 066h, 0C0h, 0F8h, 0C0h, 066h, 03Ch, 000h	 	;укр Э ОБРАТНОЕ
        cp866_code_0f3h	db	000h, 000h, 03Eh, 063h, 078h, 063h, 03Eh, 000h          ;укр э обратное
        cp866_code_0f4h	db	048h, 078h, 030h, 030h, 030h, 030h, 078h, 000h          ;укр И С ДВУМЯ ТОЧКАМИ
        cp866_code_0f5h	db	0CCh, 000h, 030h, 030h, 030h, 030h, 078h, 000h          ;укр и с двумя точками
 	cp866_code_0f6h	db	038h, 0C6h, 0C6h, 07Eh, 006h, 0C6h, 07Ch, 000h          ;бел У С ДВУМЯ ТОЧКАМИ
 	cp866_code_0f7h	db	06Ch, 038h, 0C6h, 0C6h, 0C6h, 07Eh, 006h, 07Ch          ;бел у с двумя точками
 	cp866_code_0f8h	db	038h, 06Ch, 06Ch, 038h, 000h, 000h, 000h, 000h          ;градус
 	cp866_code_0f9h	db	000h, 000h, 000h, 018h, 018h, 000h, 000h, 000h	 	;большой прямоугольник	
 	cp866_code_0fah	db      000h, 000h, 000h, 000h, 018h, 000h, 000h, 000h          ;маленький прямоугольник
        cp866_code_0fbh	db	00Eh, 00Ch, 00Ch, 00Ch, 06Ch, 03Ch, 01Ch, 000h          ;корень

;из книги братьев Фроловых

 	frol_252_fc   DB   006h,008h,0CBh,06Bh,068h,05Bh,058h,08Ch      ;номер (красивый!=cp866)

;Из шрифта 8x8 кодовой страницы 866 файла ega.cpi Windows 7

 	cp866_code_0fdh	db	000h, 0C6h, 07Ch, 0C6h, 0C6h, 07Ch, 0C6h, 000h          ;отбивка
 	cp866_code_0feh	db	000h, 000h, 03Ch, 03Ch, 03Ch, 03Ch, 000h, 000h          ;совсем большой прямоугольник
 	cp866_code_0ffh	db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
