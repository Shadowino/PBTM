XIncludeFile "utils.pb"

Procedure CWinRes()
  ResizeGadget(0, 0, 20, WindowWidth(0), WindowHeight(0)-20)
EndProcedure

Procedure CwinEveMenu()
  Select EventMenu()
      ;{ control add del edit and other
    Case #MNC_Add
      *task.task_t = AddTask(InputRequester("Add Task", "input Task text:", ""))
      AddGadgetTask(*task)
    Case #MNC_Del
;       For i = CountGadgetItems(0) To 0 Step -1
;         If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
;           id = Val(GetGadgetItemText(0, i))
;           DeleteTask(id)
;           RemoveGadgetItem(0, i)
;         EndIf
;       Next
      applyTaskDelete()
    Case #MNC_Edit
      ids.s = ""
      cids = 0
      For i = CountGadgetItems(0) To 0 Step -1
        If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
          ids + i + " " ; items ID
          cids + 1
        EndIf
      Next
      If cids > 1
        editorGroup(ids)
      Else
        editor(ids)
      EndIf
    Case #MNC_complete
      applyTaskUpdate(@EditTaskStatus(), #STT_complete)
    Case #MNC_progress
      applyTaskUpdate(@EditTaskStatus(), #STT_progress)
    Case #MNC_postponded
      applyTaskUpdate(@EditTaskStatus(), #STT_postponded)
      ;}
    Case 10
      file$ = OpenFileRequester("IMPORT", "", "Text and .md | *.txt;*.md | all Files | *.* ", 0)
      If FileSize(file$) <= 0 : MessageRequester("ERROR", "ERFS") : EndIf
      importMD(file$)
    Case 11
      file$ = SaveFileRequester("EXPORT", "base.md", "Text and .md | *.* ", 0)
      exportMD(file$)
    Case 12 ; find
      find()
    Case 13 ; reDrawTaskView()
      reDrawTaskView()
    Case 14 ; save DB
      SaveTasksAll()
  EndSelect
  ; reDrawTaskView()
EndProcedure

Procedure CwinEveGadget()
  Select EventGadget() 
    Case 0
      Select EventType()
        Case #PB_EventType_RightClick
          DisplayPopupMenu(1, WindowID(0))
        Case #PB_EventType_Change
          str.s = ""
          For i = 0 To CountGadgetItems(0)
            If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
              str + " " + Str(i)
            EndIf
          Next
        Case #PB_EventType_LeftClick
          str.s = ""
          str + Str(GetGadgetState(0))
      EndSelect
    Case 1, 2, 3, 4, 5
      findTaskKeyword(GetGadgetText(1)+" ", 
                      GetGadgetState(5) | GetGadgetState(2) << 1 | GetGadgetState(4) << 2 | GetGadgetState(3) << 3)  
    Case 14 ; editor - save
      *editableTask\name = GetGadgetText(10)
      *editableTask\timestamp = GetGadgetState(11)
      *editableTask\autor = GetGadgetText(12)
      *editableTask\status = GetGadgetState(13)
      *editableTask\tags = GetGadgetText(16)
      updGadgetTask(giID, *editableTask)
      CloseWindow(1)
    Case 15 ; editor - cancel
      CloseWindow(1)
    Case 100 ; editor - cancel
      MessageRequester("about?", "V" + #Version + ~"\n")
  EndSelect
EndProcedure


Procedure CWinEve()
  ;   CWinRes()
  Select WindowEvent()
    Case #PB_Event_CloseWindow
      Select EventWindow()
        Case 0 
          do_exit = 1
          SaveTasksAll()
        Case 1
          CloseWindow(1)
        Case 2
          CloseWindow(2)
      EndSelect
    Case #PB_Event_SizeWindow
      CWinRes()
    Case #PB_Event_Menu
      CwinEveMenu()
    Case #PB_Event_Gadget
      CwinEveGadget()
  EndSelect
EndProcedure