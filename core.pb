Enumeration TaskType
  #TST_text
EndEnumeration
Enumeration StatusType
  #STT_empty
  #STT_progress
  #STT_complete
  #STT_postponded
EndEnumeration
Enumeration MenuCommand
  #MNC_Add
  #MNC_Edit
  #MNC_Del
  #MNC_postponded
  #MNC_complete
  #MNC_progress
EndEnumeration

Structure task_t
  id.i
  timestamp.i
  name.s
  status.i
  autor.s
  tags.s
  desc.s
  proj.s
EndStructure
Structure proj_t
  name.s
  status.i
  timestamp.i
  desc.s
EndStructure


Global do_exit = 0
Global NewList Tasks.Task_t()
Global NewList projs.proj_t()
Global NewList tags.s()
Global TasksCounter = 0

Global u_username.s = "user1"