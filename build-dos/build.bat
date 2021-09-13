@echo off
rem Build with MS-DOS toolchain (up to win7). Version 2. L.Yadrennikov 29.09.2020
del %1.bin
masm %1,%1.obj,%1.lst,nul
link %1,%1.EXE,%1.map,,
echo n%1.exe>debug2bin
echo l>>debug2bin
echo rcx>>debug2bin
echo 4000>>debug2bin
echo n%1.bin>>debug2bin
echo ecs:fffe fe 20>>debug2bin
echo wcs:c000>>debug2bin
echo q>>debug2bin
debug<debug2bin



