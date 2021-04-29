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
;
;
;Л.Ядренников (RCgoff),17.04.20, 13.08.20 (29.04.21 - изм. для UTF-8)

	db	01eh,036h,066h,066h,07eh,066h,066h,000h
	db	07ch,060h,060h,07ch,066h,066h,07ch,000h
	db	07ch,066h,066h,07ch,066h,066h,07ch,000h
	db	07eh,060h,060h,060h,060h,060h,060h,000h
	db	038h,06ch,06ch,06ch,06ch,06ch,0feh,0c6h
	db	07eh,060h,060h,07ch,060h,060h,07eh,000h
	db	0dbh,0dbh,07eh,03ch,07eh,0dbh,0dbh,000h
	db	03ch,066h,006h,01ch,006h,066h,03ch,000h
	db	066h,066h,06eh,07eh,076h,066h,066h,000h
	db	03ch,066h,06eh,07eh,076h,066h,066h,000h
	db	066h,06ch,078h,070h,078h,06ch,066h,000h
	db	01eh,036h,066h,066h,066h,066h,066h,000h
	db	0c6h,0eeh,0feh,0feh,0d6h,0c6h,0c6h,000h
	db	066h,066h,066h,07eh,066h,066h,066h,000h
	db	03ch,066h,066h,066h,066h,066h,03ch,000h
	db	07eh,066h,066h,066h,066h,066h,066h,000h
	db	07ch,066h,066h,066h,07ch,060h,060h,000h
	db	03ch,066h,060h,060h,060h,066h,03ch,000h
	db	07eh,018h,018h,018h,018h,018h,018h,000h
	db	066h,066h,066h,03eh,006h,066h,03ch,000h
	db	07eh,0dbh,0dbh,0dbh,07eh,018h,018h,000h
	db	066h,066h,03ch,018h,03ch,066h,066h,000h
	db	066h,066h,066h,066h,066h,066h,07fh,003h
	db	066h,066h,066h,03eh,006h,006h,006h,000h
	db	0dbh,0dbh,0dbh,0dbh,0dbh,0dbh,0ffh,000h
	db	0dbh,0dbh,0dbh,0dbh,0dbh,0dbh,0ffh,003h
	db	0e0h,060h,060h,07ch,066h,066h,07ch,000h
	db	0c6h,0c6h,0c6h,0f6h,0deh,0deh,0f6h,000h
	db	060h,060h,060h,07ch,066h,066h,07ch,000h
	db	078h,00ch,006h,03eh,006h,00ch,078h,000h
	db	0ceh,0dbh,0dbh,0fbh,0dbh,0dbh,0ceh,000h
	db	03eh,066h,066h,066h,03eh,036h,066h,000h
	db	000h,000h,078h,00ch,07ch,0cch,076h,000h
	db	000h,03ch,060h,03ch,066h,066h,03ch,000h
	db	000h,03ch,066h,07ch,066h,066h,07ch,000h
	db	000h,000h,07eh,060h,060h,060h,060h,000h
	db	000h,000h,03ch,06ch,06ch,06ch,0feh,0c6h
	db	000h,000h,03ch,066h,07eh,060h,03ch,000h
	db	000h,000h,0dbh,07eh,03ch,07eh,0dbh,000h
	db	000h,000h,03ch,066h,00ch,066h,03ch,000h
	db	000h,000h,066h,06eh,07eh,076h,066h,000h
	db	000h,018h,066h,06eh,07eh,076h,066h,000h
	db	000h,000h,066h,06ch,078h,06ch,066h,000h
	db	000h,000h,01eh,036h,066h,066h,066h,000h
	db	000h,000h,0c6h,0feh,0feh,0d6h,0c6h,000h
	db	000h,000h,066h,066h,07eh,066h,066h,000h
	db	000h,000h,03ch,066h,066h,066h,03ch,000h
	db	000h,000h,07eh,066h,066h,066h,066h,000h
	db	092h,000h,092h,000h,092h,000h,092h,000h
	db	092h,049h,092h,049h,092h,049h,092h,000h
	db	0aah,055h,0aah,055h,0aah,055h,0aah,000h
	db	018h,018h,018h,018h,018h,018h,018h,018h
	db	018h,018h,018h,0f8h,018h,018h,018h,018h
	db	018h,018h,0f8h,018h,0f8h,018h,018h,018h
	db	06ch,06ch,06ch,0ech,06ch,06ch,06ch,06ch
	db	000h,000h,000h,0fch,06ch,06ch,06ch,06ch
	db	000h,000h,0f8h,018h,0f8h,018h,018h,018h
	db	06ch,06ch,0ech,00ch,0ech,06ch,06ch,06ch
	db	06ch,06ch,06ch,06ch,06ch,06ch,06ch,06ch
	db	000h,000h,0fch,00ch,0ech,06ch,06ch,06ch
	db	06ch,06ch,0ech,00ch,0fch,000h,000h,000h
	db	06ch,06ch,06ch,0fch,000h,000h,000h,000h
	db	018h,018h,0f8h,018h,0f8h,000h,000h,000h
	db	000h,000h,000h,0f8h,018h,018h,018h,018h
	db	018h,018h,018h,01fh,000h,000h,000h,000h
	db	018h,018h,018h,0ffh,000h,000h,000h,000h
	db	000h,000h,000h,0ffh,018h,018h,018h,018h
	db	018h,018h,018h,01fh,018h,018h,018h,018h
	db	000h,000h,000h,0ffh,000h,000h,000h,000h
	db	018h,018h,018h,0ffh,018h,018h,018h,018h
	db	018h,018h,01fh,018h,01fh,018h,018h,018h
	db	06ch,06ch,06ch,06fh,06ch,06ch,06ch,06ch
	db	06ch,06ch,06fh,060h,07fh,000h,000h,000h
	db	000h,000h,07fh,060h,06fh,06ch,06ch,06ch
	db	06ch,06ch,0efh,000h,0ffh,000h,000h,000h
	db	000h,000h,0ffh,000h,0efh,06ch,06ch,06ch
	db	06ch,06ch,06fh,060h,06fh,06ch,06ch,06ch
	db	000h,000h,0ffh,000h,0ffh,000h,000h,000h
	db	06ch,06ch,0efh,000h,0efh,06ch,06ch,06ch
	db	018h,018h,0ffh,000h,0ffh,000h,000h,000h
	db	06ch,06ch,06ch,0ffh,000h,000h,000h,000h
	db	000h,000h,0ffh,000h,0ffh,018h,018h,018h
	db	000h,000h,000h,0ffh,06ch,06ch,06ch,06ch
	db	06ch,06ch,06ch,07fh,000h,000h,000h,000h
	db	018h,018h,01fh,018h,01fh,000h,000h,000h
	db	000h,000h,01fh,018h,01fh,018h,018h,018h
	db	000h,000h,000h,07fh,06ch,06ch,06ch,06ch
	db	06ch,06ch,06ch,0efh,06ch,06ch,06ch,06ch
	db	018h,018h,0ffh,000h,0ffh,018h,018h,018h
	db	018h,018h,018h,0f8h,000h,000h,000h,000h
	db	000h,000h,000h,01fh,018h,018h,018h,018h
	db	0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	db	000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh
	db	0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
	db	00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh
	db	0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h

;Далее неизменные столбцы E,F из ЕС-листинга
	db 000h,000h,07ch,066h,066h,07ch,060h,000h
 	db 000h,000h,03ch,066h,060h,066h,03ch,000h
 	db 000h,000h,07eh,018h,018h,018h,018h,000h
 	db 000h,000h,066h,066h,03eh,006h,03ch,000h
 	db 000h,000h,07eh,0dbh,0dbh,07eh,018h,000h
 	db 000h,000h,066h,03ch,018h,03ch,066h,000h
 	db 000h,000h,066h,066h,066h,066h,07fh,003h
 	db 000h,000h,066h,066h,03eh,006h,006h,000h
 	db 000h,000h,0dbh,0dbh,0dbh,0dbh,0ffh,000h
 	db 000h,000h,0dbh,0dbh,0dbh,0dbh,0ffh,003h
 	db 000h,000h,0e0h,060h,07ch,066h,07ch,000h
 	db 000h,000h,0c6h,0c6h,0f6h,0deh,0f6h,000h
 	db 000h,000h,060h,060h,07ch,066h,07ch,000h
 	db 000h,000h,07ch,006h,03eh,006h,07ch,000h
 	db 000h,000h,0ceh,0dbh,0fbh,0dbh,0ceh,000h
 	db 000h,000h,03eh,066h,03eh,036h,066h,000h
 	db 066h,07eh,060h,07ch,060h,060h,07eh,000h
 	db 000h,066h,03ch,066h,07eh,060h,03ch,000h

;Из шрифта 8x8 кодовой страницы 866 файла ega.cpi Windows 7

	cp866_code_0f2h	db	03Ch, 066h, 0C0h, 0F8h, 0C0h, 066h, 03Ch, 000h		;укр Э ОБРАТНОЕ
        cp866_code_0f3h	db	000h, 000h, 03Eh, 063h, 078h, 063h, 03Eh, 000h          ;укр э обратное
        cp866_code_0f4h	db	048h, 078h, 030h, 030h, 030h, 030h, 078h, 000h          ;укр И С ДВУМЯ ТОЧКАМИ
        cp866_code_0f5h	db	0CCh, 000h, 030h, 030h, 030h, 030h, 078h, 000h          ;укр и с двумя точками
	cp866_code_0f6h	db	038h, 0C6h, 0C6h, 07Eh, 006h, 0C6h, 07Ch, 000h          ;бел У С ДВУМЯ ТОЧКАМИ
	cp866_code_0f7h	db	06Ch, 038h, 0C6h, 0C6h, 0C6h, 07Eh, 006h, 07Ch          ;бел у с двумя точками
	cp866_code_0f8h	db	038h, 06Ch, 06Ch, 038h, 000h, 000h, 000h, 000h          ;градус
	cp866_code_0f9h	db	000h, 000h, 000h, 018h, 018h, 000h, 000h, 000h		;большой прямоугольник	
	cp866_code_0fah	db      000h, 000h, 000h, 000h, 018h, 000h, 000h, 000h          ;маленький прямоугольник
        cp866_code_0fbh	db	00Eh, 00Ch, 00Ch, 00Ch, 06Ch, 03Ch, 01Ch, 000h          ;корень

;из книги братьев Фроловых

	frol_252_fc   DB   006h,008h,0CBh,06Bh,068h,05Bh,058h,08Ch      ;номер (красивый!=cp866)

;Из шрифта 8x8 кодовой страницы 866 файла ega.cpi Windows 7

	cp866_code_0fdh	db	000h, 0C6h, 07Ch, 0C6h, 0C6h, 07Ch, 0C6h, 000h          ;отбивка
	cp866_code_0feh	db	000h, 000h, 03Ch, 03Ch, 03Ch, 03Ch, 000h, 000h          ;совсем большой прямоугольник
	cp866_code_0ffh	db	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h

