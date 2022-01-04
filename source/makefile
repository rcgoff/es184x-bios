1840v5.bin: 1840v5-a.obj keybrd.obj 1840v5-b.obj
	link16.exe 1840v5-a.obj keybrd.obj 1840v5-b.obj, 1840v5.exe ;
	GetLastBytes 1840v5.exe 1840v5.bin 8192
	del 1840v5.exe

1840v5-a.obj: 1840v5-a.asm dseg40.inc postequ0.inc
	tasm32.exe /m0 /l /um400 /w-LCO 1840v5-a

keybrd.obj: keybrd.asm dseg40.inc postequ0.inc
	tasm32.exe /m0 /l /um400 /w-LCO keybrd

1840v5-b.obj: 1840v5-b.asm dseg40.inc postequ0.inc
	tasm32.exe /m0 /l /um400 /w-LCO 1840v5-b