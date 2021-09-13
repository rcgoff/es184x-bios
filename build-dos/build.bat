rem Build with MS-DOS toolchain (up to win7). L.Yadrennikov 21.04.2020
del %1.bin
masm %1,%1.obj,%1.lst,nul
link %1,BIOS-ISO.EXE,%1.map,,
debug<debug2bin
ren bios.bin %1.bin


