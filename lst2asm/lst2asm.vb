'ДАННЫЙ ФАЙЛ СОСТАВЛЕН ДЛЯ VBA, ВСТРОЕННОГО В MS EXCEL
Option Explicit
'преобразование файла листинга MASM 3.0 в файл .asm
'написано в рамках переделки BIOS ЕС1841
'Л.Ядренников 21,25.04.2020
'05.04.2021 - изменения для обработки листинга без нумерации строк (необходимо переключить переменную isLineNumbersInFile);
'             также сделана обработка обрезаемых строк, оказавшихся на границе страниц
'26.09.2021 - удаление лишней пустой строки, добавляемой ассемблером MASM3 в листинг в конце dup-последовательностей;
'             проверка на затирание выходных файлов, если они уже есть
'07.10.2021 - обработка нескольких разных форматов (необходимо изменить строковую переменную LstFormat);
'             добавлен формат TASM 5.0 (по файлам Глеба Ларионова из Праги);
'             исправлена ошибка, если в конце файла перевод страницы и нужного числа пустых строк не набирается;
'             добавлено исправление CR-LF
'             доработано удаление пустых строк после dup(?) - и для db, и для dw
'ЕЩЕ НЕ РЕАЛИЗОВАНО: рассовывание включенных по include файлов в разные asm-файлы
'ЕЩЕ НЕ РЕАЛИЗОВАНО: ListBox выбора формата и вообще интерфейс
'ЕЩЕ НЕ РЕАЛИЗОВАНО: сохранение файлов с LF вместо CR-LF под другим именем (а не перезапись)

Sub InPath()  'процедура основная, выбор файлов
Dim flname As Variant           'это потому что по-другому не обрабатываются collection

With Application.FileDialog(msoFileDialogFilePicker)
.AllowMultiSelect = True
.Show
.Filters.Add "LST-файлы", "*.lst", 1
.Filters.Add "TXT-файлы", "*.txt", 1
For Each flname In .SelectedItems
    lst2asm (flname)
    Next
End With
MsgBox "Done!"
End Sub
Private Sub lst2asm(flname)
Dim lstline As String
Dim prevline As String
Dim i As Integer
Dim FirstCharCode As String
Dim lstcnt As Long

Dim stoplisting As Integer

Dim LongLineArray() As Integer  'номера переполнившихся (переход на новую строку) строк листинга
Dim NewpageArray() As Integer   'номера строк - начал новых страниц
Dim longlineCnt As Integer
Dim newpageCnt As Integer
Dim asmString As String
Dim codeSection As String
Dim PrevLineEndDup As Boolean       'предыдущая строка - последняя в DUP (закр. квадр. скобка)
Dim FileExsistAnswer As Integer     'ответ пользователя, если файл существует
Dim CRLFrewriteAnswer As Integer    'ответ пользователя - перезаписывать ли файл с неверным CR-LF

'константы формата листинга
Dim LstFormat As String             'имя формата листинга
Dim isLineNumbersInFile As Boolean  'начинается ли строка листинга с номера строки или нет
Dim AsmFileDataBegin As Integer     'позиция начала данных, переносимых из asm-файла
Dim LstAddrBegin As Integer         'позиция начала адреса
Dim LstMachCodeBegin As Integer     'позиция начала машкода
Dim LstMachCodeEnd As Integer       'позиция конца машкода
Dim NextPageSkippedLines As Integer 'сколько строк пропускать при встрече новой страницы (считая ту, которая с ASCII 12)
Dim EndingPhrase As String          'фраза, после которой в листинге идет таблица символов (ее не включаем в asm)
Dim EndingFirstSym As String        'первый символ этой фразы (заполняется автоматически)
Dim EndingPhraseLen As Integer      'длина этой фразы (заполняется автоматически)


'здесь нужно раскомментировать нужный формат (только один!)
'=====================================================================
LstFormat = "MASM3 with line numbers"
'LstFormat = "MASM3 without line numbers"
'LstFormat = "TASM5 with line numbers"
'=====================================================================

Select Case LstFormat

Case "MASM3 with line numbers"
        'это параметры листинга ЕС-1841, распространенного в интернете на различных площадках
    isLineNumbersInFile = True
    AsmFileDataBegin = 41
    LstAddrBegin = 10
    LstMachCodeBegin = 16
    LstMachCodeEnd = 32
    NextPageSkippedLines = 4
    EndingPhrase = "Segments and Groups:"

Case "MASM3 without line numbers"
        'если листинг без номеров страниц, позиции становятся на 8 (одну позицию tab) меньше. Это листинг, генерируемый на моем компе
    isLineNumbersInFile = False
    AsmFileDataBegin = 33
    LstAddrBegin = 2
    LstMachCodeBegin = 8
    LstMachCodeEnd = 26    'это не на 8 меньше, а посмотрел по реальному файлу до link-овки, только после ассемблера
    NextPageSkippedLines = 4
    EndingPhrase = "Segments and Groups:"

Case "TASM5 with line numbers"
        'параметры листинга Turbo Assembler 5.0, по которому компилируются файлы Gleb'а из Чехии
    isLineNumbersInFile = True
    AsmFileDataBegin = 38
    LstAddrBegin = 9
    LstMachCodeBegin = 15
    LstMachCodeEnd = 34    'там дальше в 35-й позиции "+", но он нам не нужен
    NextPageSkippedLines = 5
    EndingPhrase = "Symbol Name"
End Select
    

'инициализация динамических массивов
ReDim LongLineArray(1 To 1): LongLineArray(1) = 0
ReDim NewpageArray(1 To 1): NewpageArray(1) = 0
lstcnt = 0
longlineCnt = 1
newpageCnt = 1
stoplisting = 0
PrevLineEndDup = False
FileExsistAnswer = 0
EndingFirstSym = Left(EndingPhrase, 1)
EndingPhraseLen = Len(EndingPhrase)

'первый проход - заполнение массивов
FirstPass:
Open flname For Input As #1
Do While Not EOF(1)
    Line Input #1, lstline
    If lstcnt = 0 Then
        If LenB(lstline) > LOF(1) / 2 Then
        'так бывает, если вместо CR-LF стоят LF, и при чтении первой же строки считывается весь файл
        'почему-то точного равенства не получается, получается немного меньше
        'LenB - для корректной обработки UTF-8 файлов, т.к. просто Len выдаст длину примерно вдвое меньше, чем LOF
            CRLFrewriteAnswer = MsgBox(flname & _
             ": LST file probably contains wrong (non-Windows) line endings, correct and rewrite the file? ", _
             vbQuestion + vbYesNo + vbDefaultButton2, "CRLF error")
            If CRLFrewriteAnswer = vbYes Then
                Close #1
                Call CRLF(CStr(flname))
                GoTo FirstPass
            Else: GoTo EndProgram
            End If
        End If
    End If
    lstcnt = lstcnt + 1
    If Len(lstline) > 0 Then
        FirstCharCode = Asc(Left(lstline, 1))
        If FirstCharCode = 12 Then
            NewpageArray(newpageCnt) = lstcnt
            newpageCnt = newpageCnt + 1
            ReDim Preserve NewpageArray(1 To newpageCnt)
        End If
        If FirstCharCode = 9 And newpageCnt > 1 Then
        'не считаем пустые строки, оставшиеся после перевода страницы
            If lstcnt - NewpageArray(newpageCnt - 1) > (NextPageSkippedLines - 1) Then
                'если строка, следующая сразу за автоматически вставленными с началом страницы, является перенесенной
                If lstcnt - NewpageArray(newpageCnt - 1) = NextPageSkippedLines Then
                        'то маркируем начало строки, оставшееся на предыдущей странице
                        LongLineArray(longlineCnt) = lstcnt - (NextPageSkippedLines + 1)
                    Else
                        LongLineArray(longlineCnt) = lstcnt - 1 'иначе маркируем просто предыдущую строку
                    End If
                longlineCnt = longlineCnt + 1
                ReDim Preserve LongLineArray(1 To longlineCnt)
            End If
        End If
        If Chr(FirstCharCode) = EndingFirstSym Then
            If Left(lstline, EndingPhraseLen) = EndingPhrase Then
                stoplisting = lstcnt 'конец зоны, где нужно укорачивать строки
            End If
        End If
    End If
Loop
Close #1
If stoplisting = 0 Then stoplisting = lstcnt + 1


'второй проход - запись поправленного по строкам файла
lstcnt = 0
longlineCnt = 1
newpageCnt = 1
prevline = ""

Open flname For Input As #1

'файл с укороченными строками для ассемблера
If Dir(Left(flname, Len(flname) - 3) + "asm") <> "" Then
    FileExsistAnswer = MsgBox(Left(flname, Len(flname) - 3) + "asm" & _
        ": ASM file already exist and will be erased, proceed anyway?", _
        vbQuestion + vbYesNo + vbDefaultButton2, "ASM file exists")
    If FileExsistAnswer = vbNo Then GoTo EndProgram
    FileExsistAnswer = 0
End If
Open Left(flname, Len(flname) - 3) + "asm" For Output As #2
    
'файл листинга без разбивки на страницы и переполненных строк
If Dir(Left(flname, Len(flname) - 4) + "_clean" + Right(flname, 4)) <> "" Then
    FileExsistAnswer = MsgBox(Left(flname, Len(flname) - 4) + "_clean" + Right(flname, 4) & _
        ": Cleaned LST file already exist and will be erased, proceed anyway?", _
        vbQuestion + vbYesNo + vbDefaultButton2, "_clean.LST file exists")
    If FileExsistAnswer = vbNo Then GoTo EndProgram
    FileExsistAnswer = 0
End If
Open Left(flname, Len(flname) - 4) + "_clean" + Right(flname, 4) For Output As #3
    
    
Do While Not EOF(1)
    Line Input #1, lstline
    lstcnt = lstcnt + 1
    If lstcnt = NewpageArray(newpageCnt) Then
    'при встрече новой страницы вхолостую прочесть NextPageSkippedLines строк (уже считанную+NextPageSkippedLines-1)
    'и еще одну строку - уже новую, непустую - занести в lstline
        For i = 1 To NextPageSkippedLines
            If Not EOF(1) Then
                Line Input #1, lstline
                lstcnt = lstcnt + 1
            Else: Exit For          'на тот случай, если в конце файла перевод страницы и нужного числа пустых строк не набирается
            End If
        Next i
        newpageCnt = newpageCnt + 1
    End If
    
    'выполним слитие с перенесенной строкой, если она была ранее считана
    If Len(prevline) <> 0 Then
           'по FAR-редактору, перенесенная строка в начале содержит 7 символов
            '0x09 0x20 0x09 0x20 0x09 0x20 0x09
            lstline = Right(lstline, Len(lstline) - 7) 'обрезанная строка
            lstline = prevline + lstline
            longlineCnt = longlineCnt + 1
            prevline = ""
    End If
    
    If lstcnt = LongLineArray(longlineCnt) Then
    'если в листинге случился перенос на новую строку,
    'она будет начинаться с пробела (а не с номера).
    'Перенос нужно ликвидировать. Для этого необходимо
    'запомнить строку (в данном проходе) и слить ее со следующей,
    'имея в виду возможную прокрутку на границе страниц
        If lstcnt < stoplisting Then    'только для классического листинга
        
            'запоминаем подстроку - первую часть переносимой строки
            prevline = lstline
        End If
    End If
    
    'теперь в lstline строка из листинга, либо часть строки (тогда prevline непусто и вывода не будет)
    'формат листинга см. выше в заголовке
    
    'Простая обрезка по колонке номер AsmFileDataBegin листинга оставит в asm-файле лишние пустые строки.
    'они возникают, когда одна asm-строка генерирует много машкода, не умещающегося в поз.LstMachCodeBegin...LstMachCodeEnd.
    'происходит перенос на новую строку. Пример - при использовании DUP  в DB,DW.
    'Такие строки определяются по условию: asm-секция(начиная с AsmFileDataBegin и дальше) пуста,
    'а секция кода - нет. И такие строки не включаются в asm-файл
    '
    If Len(prevline) = 0 Then 'блокировка вывода в файлы части переносимой строки
        If lstcnt < stoplisting Then
    
            codeSection = ViewPosMid(lstline, LstMachCodeBegin, LstMachCodeEnd)
            asmString = ViewPosMid(lstline, AsmFileDataBegin)
            If isStringEmpty(asmString) Then
                If isStringEmpty(codeSection) Then
                    If Not (PrevLineEndDup) Then Print #2, asmString
                End If
            Else
                Print #2, asmString
            End If
            
            'отловим ложную пустую строку, возникающую в конце dup-последовательностей,
            'если после dup в строке кода ничего не было
            If StringExceptSpacesTabs(codeSection) = "]" Then        'была ли текущая строка третьей в DUP-последовательности?
                                                                     '(работать с ней будем на следующем проходе)
                PrevLineEndDup = True
            Else
                PrevLineEndDup = False
            End If
        End If
        Print #3, lstline
    End If
Loop
EndProgram:
Close #1
Close #2
Close #3
End Sub

Private Function ViewPosMid(lststring As String, _
    startViewPos As Integer, _
    Optional endViewPos As Integer = 32767) _
    As String
'получение подстроки с использованием видимых в текстовом редакторе позиций (номеров колонок).
'Отличие от Mid - в возможном использовании символа табуляции.
'Он перемещает курсор на следующую кратную 8 плюс одну позицию:1,9,17,25... позиции.
'endViewPos указывает на позицию последнего еще включаемого символа.
'Если endViewPos не указано - вернет подстроку от startViewPos до конца строки.
'-----
'функции VB Left,Right,Mid трактуют символ табуляции как один символ и не перемещают "курсор".
'Используя их, нельзя оказаться на определенной колонке, если в строке были табуляции.
'поэтому сканируем строку и перемещаем "курсор" (viewPos) всед за tab-ами.
'truePos - это позиции для Left,Right,Mid, соответствующие данной позиции курсора.
'-----
'НЕЗАВЕРШЕНО: если startViewPos не совпадает с tab-позицией,
'а в строке стоит табуляция и такой, как надо,
'колонки в строке просто нет, будет возвращена подстрока со следующей tab-позиции.
'например, startViewPos указано 39, а в строке только tab-позиции 33 и 41.
'функция вернет подстроку с позиции 41.
'НЕЗАВЕРШЕНО: если такая же ситуация с endViewPos, будет возвращена подстрока до символа,
'стоящего в ближайшей tab-позиции, следующей за данным символом.
'
'Т.е. как будто startViewPos и endViewPos округляются вверх до ближайшей tab-позиции,
'если им не соответствовало определенных символов в строке и они оказались между tab-позициями

Dim viewPos As Integer  'видимая в редакторе глазом позиция
Dim truePos As Integer  'считываемая позиция
Dim currchr As String   'текущий символ в строке
Dim startTruePos As Integer 'считываемая позиция, идентичная заданной видимой стартовой
Dim isStartPosReached As Boolean
Dim PrevPosReached As Boolean

viewPos = 1
truePos = 1
startTruePos = 0
PrevPosReached = False
isStartPosReached = False
ViewPosMid = ""

If Len(lststring) = 0 Or endViewPos < startViewPos Then Exit Function

Do While Not ((viewPos > endViewPos - 1) _
            Or truePos > Len(lststring)) 'not(условие остановки сканирования строки)
    
currchr = Mid(lststring, truePos, 1)
If Asc(currchr) = 9 Then
    viewPos = ((viewPos - 1) \ 8 + 1) * 8 + 1
        'куда перемещает символ табуляции из текущей позиции. См. на листе excel
    Else
    viewPos = viewPos + 1
End If
truePos = truePos + 1

'вычислить стартовый truePos для стартового viewPos
isStartPosReached = Not (PrevPosReached) And viewPos >= startViewPos
PrevPosReached = viewPos >= startViewPos 'перевалили ли в предыдущем проходе
    'такое сочетание сделает isStartposreached=1 только в том проходе, когда перевалили за
    'startviewpos, неважно, стало ли в проходе впервые равно или больше (последнее из-за tab)
If isStartPosReached Then startTruePos = truePos
Loop

'теперь truePos указывает либо на последний символ, либо на endViewPos
If startTruePos > 0 Then    '=0 если указали startViewPos больше длины строки
    ViewPosMid = Mid(lststring, startTruePos, truePos - startTruePos + 1)
End If
End Function

Function isStringEmpty(srcStr As String) As Boolean
'returns TRUE if string contains only spaces or tabs or has zero length
'otherwise returns FALSE
Dim currpos As Integer
Dim currchr As String
currpos = 1

If Len(srcStr) = 0 Then
    isStringEmpty = True
    Exit Function
End If


isStringEmpty = True
Do
currchr = Mid(srcStr, currpos, 1)
isStringEmpty = Asc(currchr) = 9 Or currchr = " "   'tab or space doesn't change "empty"
                                                    'but any other does
currpos = currpos + 1
Loop Until currpos > Len(srcStr) Or isStringEmpty = False

End Function
Sub testIsStringEmpty()
MsgBox (isStringEmpty("      "))
MsgBox (isStringEmpty(""))
MsgBox (isStringEmpty("  v v"))
End Sub


'объявление собственного типа для создания функции, которая возвращает два значения
'больше не используется
'функции должны быть типа private
'обращение типа Dim xxx as LstStringParms
'xxx.finalTruePos = 34
'Private Type LstStringParms
'    finalTruePos As Integer
'    finalViewPos As Integer
'End Type


 Sub CRLF(MyFile As String)
 'расстановка CR-LF для корректной работы текстовых процедур
 '(c)rcgoff 2009
  
 Dim tempstr As String
Dim tempstr2 As String
 Open MyFile For Input As #1
 Line Input #1, tempstr
 'If LOF(1) <> Len(tempstr) Then Close #1: Exit Sub      'если длины не равны, значит корректно считалась одна строка и файл нормальный
 tempstr2 = Replace(tempstr, Chr(10), Chr(13) + Chr(10))
 Close #1
 Kill MyFile
 Open MyFile For Output As #1
 Print #1, tempstr2
 Close #1
 End Sub

Function StringExceptSpacesTabs(currStr As String) As String
'возвращает строку без пробелов и табуляций

    currStr = Replace(currStr, " ", "")
    currStr = Replace(currStr, vbTab, "")
 
StringExceptSpacesTabs = currStr
End Function
