#Version = "B" + #PB_Editor_BuildCount
XIncludeFile "utils.pb"



;{ task Text converter
Global dat.s = "WEB панель угол проверки SCAN3 SCAN2 SCAN7 SCAN8"
Global dat2.s = "выяснить доработать переписать удалить добавить"
Procedure.s generateTaskText()
  res.s = StringField(dat2, Random(3)+1, " ")
  res.s + " " + StringField(dat, Random(CountString(dat, " "))+1, " ")
  ProcedureReturn res
EndProcedure

;{ import from txt format (.md format)
Procedure.i CheckIsTaskText(txt.s)
  txt = Trim(txt)
;   Debug txt
  If Not (Mid(txt, 1, 1) <> "-" Or Mid(txt, 1, 1) <> "+")
;     Debug "not becouse:" + Mid(txt, 1, 1)
    ProcedureReturn #False
  EndIf
  If Not (Mid(txt, 3, 1) = "[" And Mid(txt, 5, 1) = "]")
;     Debug "not becouse:" + Mid(txt, 3, 1) + "\" + Mid(txt, 5, 1)
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
EndProcedure
Procedure.s AddTaskText(txt.s)
  txt = Trim(txt)
  If Not CheckIsTaskText(txt) : ProcedureReturn "" : EndIf
  Debug "add Task:" + Mid(txt, 6)
  name$ = Trim(Mid(txt, 6))
  stat.i = -1
;   # ус. обознчения
; - [ ] не сделано
; - [*] в процессе
; - [~] сделано, не тестировано
; - [+] сделано, протестировано
; - [x] утвержденно
  Select Mid(txt, 4, 1) 
    Case " ", "~" 
      stat = #STT_progress
    Case "+", "*", "*", "x", "v"
      stat = #STT_complete 
    Case "-", "0"
      stat = #STT_postponded
    Default
      stat = #STT_empty
  EndSelect
  
  AddTask(name$, stat)
  ProcedureReturn Trim(Mid(txt, 6))
EndProcedure
;}

; export to .md format
Procedure exportMD(file$)
  If Not CreateFile(0, file$)
    MessageRequester("", "ERCF")
    ProcedureReturn
  EndIf
  ResetList(Tasks())
  ForEach Tasks()
    task$ = "- ["
    Select Tasks()\status 
      Case #STT_complete
        task$ + "+"
      Case #STT_progress
        task$ + " "
      Case #STT_postponded
        task$ + "-"
      Case #STT_empty
        task$ + " "
    EndSelect
    task$ + "] " + tasks()\name
        
    WriteStringN(0, task$)
  Next
  CloseFile(0)
EndProcedure

; Import .md
Procedure importMD(file$)
  OpenFile(0, file$)
  While 1
    stask.s = ReadString(0)
    AddTaskText(stask)
    If Eof(0) : Break : EndIf
  Wend
  CloseFile(0)
EndProcedure

;}

;{ edit Tasks
; add
; edit
; del
; set stat
; set other
Global *editableTask.task_t
Global giID
Procedure editor(ids.s)
;   isGroup = 0
;   If CountString(ids, " ") > 1 : isGroup = 1 : EndIf
  giID = Val(StringField(ids, 1, " "))
  id = Val(GetGadgetItemText(0, Val(StringField(ids, 1, " "))))
  ForEach tasks()
    If Tasks()\id = id : *editableTask = Tasks() : Break : EndIf
  Next
  If IsWindow(1) : CloseWindow(1) : EndIf
  OpenWindow(1, 0, 0, 400, 110, "Editor (standart)", 
             #PB_Window_ScreenCentered | #PB_Window_SystemMenu,
             WindowID(0))
  StringGadget(10, 5, 5, 390, 20, *editableTask\name)
  GadgetToolTip(10, "Name")
  DateGadget(11, 315, 30, 80, 20, "%dd.%mm.%yy", *editableTask\timestamp)
  GadgetToolTip(11, "date")
  StringGadget(12, 5, 30, 305, 20, *editableTask\autor)
  GadgetToolTip(11, "autor")
  ComboBoxGadget(13, 5, 55, 100, 20)
  AddGadgetItem(13, #STT_empty, "unknown")
  AddGadgetItem(13, #STT_progress, "progress")
  AddGadgetItem(13, #STT_complete, "complete")
  AddGadgetItem(13, #STT_postponded, "postponded")
  GadgetToolTip(13, "status")
  SetGadgetState(13, *editableTask\status)
  StringGadget(16, 5, 80, 390, 20, *editableTask\tags)
  ButtonGadget(14, 230, 55, 80, 20, "save")
  ButtonGadget(15, 315, 55, 80, 20, "cancel")
EndProcedure
Procedure editorGroup(ids.s)
  
EndProcedure
;}


;{ advanced edit
Procedure.i findTaskKeyword(Patt.s, showOnly = %1111)
  While FindString(Patt, "  ") > 0
  Patt = ReplaceString(Patt, "  ", " ")
  Wend
  If Patt = "" : ProcedureReturn : EndIf
  NewList words.s()
  For i = 1 To CountString(Patt, " ")
    AddElement(words())
    words() = StringField(Patt, i, " ")
  Next
  ResetList(Tasks())
  ClearGadgetItems(0)
  ForEach Tasks()
    ForEach words()
      Debug Bin(showOnly) + " &" + Bin(%1 << Tasks()\status)
      If (FindString(LCase(Tasks()\name), LCase(words())) > 0 Or FindString(LCase(Tasks()\tags), LCase(words())) > 0 Or Patt = " ") And 
         (showOnly & (%1 << Tasks()\status))
        AddGadgetTask(@Tasks())
        Break
      EndIf
    Next
  Next
  FreeList(words())
EndProcedure

Procedure find()
  If IsWindow(2) : CloseWindow(2) : EndIf
  OpenWindow(2, 0, 0, 300, 150, "PBTM (Find)", #PB_Window_ScreenCentered | #PB_Window_SystemMenu, WindowID(0))
  StringGadget(1, 10, 10, 280, 20, "")
  CheckBoxGadget(2, 10, 40, 280, 20, "show progress?")
  SetGadgetState(2, 1)
  CheckBoxGadget(3, 10, 70, 280, 20, "show postponded?")
  SetGadgetState(3, 1)
  CheckBoxGadget(4, 10, 100, 280, 20, "show complete?")
  SetGadgetState(4, 1)
  CheckBoxGadget(5, 10, 130, 280, 20, "show unknown?")
  SetGadgetState(5, 1)
EndProcedure

;}


XIncludeFile "cont.pb"
Procedure Cwin()
  ExamineDesktops()
  OpenWindow(0, 0, 0, DesktopWidth(0)/2, DesktopHeight(0)/2, "PB|TaskLists|Editor|V" + #Version + "",
             #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget)
  CreateMenu(0, WindowID(0))
  MenuTitle("File")
  MenuItem(10, "import")
  MenuItem(11, "export")
  CloseSubMenu()
  OpenSubMenu("control")
  MenuItem(12, "find")
  MenuItem(13, "reDraw View")
  MenuItem(14, "DB Save")
  CloseSubMenu()
  MenuItem(#MNC_Add, "ADD")
  MenuItem(#MNC_Del, "DEL")
  MenuItem(#MNC_Edit, "EDIT")
  MenuItem(#MNC_complete, "SET is completed")
  MenuItem(#MNC_progress, "SET is progress")
  MenuItem(#MNC_postponded, "SET is postponded")
  MenuItem(100, "about")

  CreatePopupMenu(1)
  MenuItem(#MNC_Add, "ADD")
  MenuItem(#MNC_Edit, "EDIT")
  MenuItem(#MNC_complete, "SET is completed")
  MenuItem(#MNC_progress, "SET is progress")
  MenuItem(#MNC_postponded, "SET is postponded")
  MenuItem(#MNC_Del, "DEL")
  WW = WindowWidth(0)
  ListIconGadget(0, 0, 20, 800, 580, "ID", WW*0.05, 
                 #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_MultiSelect | #PB_ListIcon_GridLines)
  
  AddGadgetColumn(0, 1, "Status", WW*0.1)
  AddGadgetColumn(0, 2, "Text", WW*0.45)
  AddGadgetColumn(0, 3, "Tags", WW*0.1)
  AddGadgetColumn(0, 4, "dateTime", WW*0.1)
  AddGadgetColumn(0, 5, "autor", WW*0.1)
  AddGadgetColumn(0, 6, "timestamp", WW*0.1)
  reDrawTaskView()
  Global SProjG = ComboBoxGadget(#PB_Any, 0, 0, 80, 20)
EndProcedure


Procedure main()
  Cwin()
  
  Repeat
    CWinEve()
    Delay(1)
  Until do_exit
  
EndProcedure

main()


