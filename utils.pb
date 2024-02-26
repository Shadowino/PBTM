XIncludeFile "core.pb"
XIncludeFile "dbex.pb"

;{ simple edit task

Procedure.i findTask(id)
  ResetList(Tasks())
  ForEach Tasks()
    If Tasks()\id = id : ProcedureReturn @Tasks() : EndIf
  Next
EndProcedure

Procedure.i AddTask(name.s, status.i = -1)
  If name = "" : ProcedureReturn : EndIf
  max.i = 0
  ForEach Tasks()
    If Tasks()\id > max : max = Tasks()\id : EndIf
  Next
  AddElement(Tasks())
  tasks()\id = max+1
  tasks()\name = name
  tasks()\autor = u_username
  tasks()\timestamp = Date()
  tasks()\status = status
  ProcedureReturn @tasks()
EndProcedure

Declare deleteItemTaskID(id)
; Procedure DeleteTask(id)
;   ForEach Tasks()
;     If Tasks()\id = id : DeleteElement(Tasks()) : EndIf
;   Next
;   delTaskDBid(id)
;   deleteItemTaskID(id)
; EndProcedure

Procedure DeleteTask(*task.task_t, mode.i)
  delTaskDB(*task)
  ChangeCurrentElement(Tasks(), *task)
;   Debug "Tid:"
  If Tasks()\id = *task\id : DeleteElement(Tasks()) : EndIf
EndProcedure

Procedure.i EditTaskStatus(*task.task_t, status.i)
  *task\status = status
  ProcedureReturn *task
EndProcedure

Procedure editTaskName(*task.task_t, name.s)
  *task\name = name
  ProcedureReturn *task
EndProcedure

Procedure editTaskDate(*task.task_t, timestamp.i)
  *task\timestamp = timestamp
  ProcedureReturn *task
EndProcedure

Procedure editTaskAutor(*task.task_t, timestamp.i)
  *task\timestamp = timestamp
  ProcedureReturn *task
EndProcedure

Procedure editTaskTag(*task.task_t, tags.s)
  *task\tags = tags
  ProcedureReturn *task
EndProcedure

;}

;{ items control
Declare updGadgetTask(inb, *task.task_t)
Procedure.i CountSelectedItem()
  counter = 0
  For i = CountGadgetItems(0) To 0 Step -1
    If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
      counter+1 
    EndIf
  Next
  ProcedureReturn counter
EndProcedure

Prototype.i TaskUpdater_t(*task.task_t, value)
Procedure applyTaskUpdate(TU.TaskUpdater_t, value)
  For i = CountGadgetItems(0) To 0 Step -1
    If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
      id =  Val(GetGadgetItemText(0, i))
      *t.task_t = TU(findTask(id), value)
      updGadgetTask(i, *t)
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

Prototype.i TaskUpdaterText_t(*task.task_t, value.s)
Procedure applyTaskUpdateText(TU.TaskUpdaterText_t, value.s)
  For i = CountGadgetItems(0) To 0 Step -1
    If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
      id =  Val(GetGadgetItemText(0, i))
      *t.task_t = TU(findTask(id), value)
      updGadgetTask(i, *t)
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

Procedure applyTaskDelete()
  For i = CountGadgetItems(0) To 0 Step -1
    If GetGadgetItemState(0, i) = #PB_ListIcon_Selected
      id =  Val(GetGadgetItemText(0, i))
      DeleteTask(findTask(id), 0)
      RemoveGadgetItem(0, i)
    EndIf
  Next
  ProcedureReturn 0
EndProcedure

;}

Procedure tagsCounter()
  ForEach Tasks()
    For i = 1 To CountString(Tasks()\tags, " ")
      tag.s = StringField(Tasks()\tags, i, " ")
      isFind = 0
      ForEach tags()
        If tag = tags() : isFind = 1 : Break : EndIf
      Next
      If Not isFind : AddElement(tags()) : EndIf
      tags() = tag
    Next
  Next
EndProcedure

;{
Procedure updGadgetTask(inb, *task.task_t)
  status.s
  color = RGB(250, 250, 250)
  Select *Task\status 
    Case #STT_progress
      status = "progress"
      color = RGB($AA, $CC, $FF)
    Case #STT_complete
      status = "complete"
      color = RGB($DE, $FF, $00)
    Case #STT_postponded
      status = "postponded"
      color = RGB($77, $77, $77)
    Default
      status = "unknown"
  EndSelect
  Hdate.s = ""
  If *Task\timestamp = 0
    Hdate = "not specified"
  Else
    Hdate = FormatDate("%dd.%mm.%yy", *Task\timestamp)
  EndIf
  SetGadgetItemText(0, inb, "" + *Task\ID  + ~"\n" +
                      status + ~"\n" +
                      *Task\name + ~"\n" + 
                      *Task\tags + ~"\n" + 
                      Hdate + ~"\n" +
                      *Task\autor + ~"\n" + Str(*task\timestamp))
  SetGadgetItemColor(0, inb, #PB_Gadget_BackColor, color)
EndProcedure
Procedure AddGadgetTask(*Task.task_t)
  status.s
  color = RGB(250, 250, 250)
  Select *Task\status 
    Case #STT_progress
      status = "progress"
      color = RGB($AA, $CC, $FF)
    Case #STT_complete
      status = "complete"
      color = RGB($DE, $FF, $00)
    Case #STT_postponded
      status = "postponded"
      color = RGB($77, $77, $77)
    Default
      status = "unknown"
  EndSelect
  Hdate.s = ""
  If *Task\timestamp = 0
    Hdate = "not specified"
  Else
    Hdate = FormatDate("%dd.%mm.%yy", *Task\timestamp)
  EndIf
  AddGadgetItem(0, 0, "" + *Task\ID  + ~"\n" +
                      status + ~"\n" +
                      *Task\name + ~"\n" + 
                      *Task\tags + ~"\n" + 
                      Hdate + ~"\n" +
                      *Task\autor + ~"\n" + Str(*task\timestamp))
  SetGadgetItemColor(0, 0, #PB_Gadget_BackColor, color)
EndProcedure
Procedure reDrawTaskView()
  ClearGadgetItems(0)  
  ForEach Tasks()
    AddGadgetTask(@Tasks())
  Next
EndProcedure
Procedure deleteItemTaskID(id)
  For i = CountGadgetItems(0) - 1 To 0
    If Str(id) = GetGadgetItemText(0, i) : RemoveGadgetItem(0, i) : EndIf
  Next
EndProcedure
;}

