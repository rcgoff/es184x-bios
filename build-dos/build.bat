@echo off
rem Build with MS-DOS toolchain (up to win7). Version 3. L.Yadrennikov 13.09.2021
rem Usage: BUILD asm-filename-without-extension
rem Assumed that .asm source file encoded in UTF-8.
rem
rem Uses system's DEBUG and requires MASM 3.0 files MASM.EXE and LINK.EXE
rem Also uses win-iconv (https://github.com/win-iconv/win-iconv)
del %1.bin
win_iconv -f utf-8 -t cp866 %1.asm >%1.866
ren %1.asm %1.utf
ren %1.866 %1.asm
masm %1,%1.obj,%1.lst,nul
link %1,%1.EXE,%1.map,,
echo n%1.exe>debug2bin
echo l>>debug2bin
echo rcx>>debug2bin
echo 4000>>debug2bin
echo n%1.bin>>debug2bin
rem The next line because a bug in Windows 7's DEBUG
rem (these 2 bytes already generated by MASM but lost by DEBUG)
echo ecs:fffe fe 20>>debug2bin
echo wcs:c000>>debug2bin
echo q>>debug2bin
debug<debug2bin
del %1.asm
ren %1.utf %1.asm
win_iconv -f cp866 -t utf-8 %1.lst > %1_utf.lst
del %1.lst
ren %1_utf.lst %1.lst



