XIncludeFile "core.pb"
UseSQLiteDatabase()
; UseMySQLDatabase()
Procedure CheckDatabaseUpdate(Database, Query$)
  Debug Query$
  Result = DatabaseUpdate(Database, Query$)
   If Result = 0
     Debug Query$ + " | " + DatabaseError()
   EndIf
   Debug AffectedDatabaseRows(Database)
   ProcedureReturn AffectedDatabaseRows(Database)
EndProcedure
Procedure CheckDatabaseQuery(Db, Query$)
  If Not DatabaseQuery(Db, Query$) ; Get all the records in the 'employee' table
    Debug Query$ + " | " + DatabaseError()
    ProcedureReturn
  EndIf
EndProcedure
Procedure loadTasks()
  If Not DatabaseQuery(Db, "Select * FROM tasks") ; Get all the records in the 'employee' table
    Debug Query$ + " | " + DatabaseError()
    ProcedureReturn
  EndIf
  NbRows = 0
  While NextDatabaseRow(Db)
    ; (ID INT PRIMARY KEY,name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))
    AddElement(Tasks())
    Tasks()\id = GetDatabaseLong(Db, 0)  
    Tasks()\name = GetDatabaseString(Db, 1)  
    Tasks()\status = GetDatabaseLong(Db, 2)  
    Tasks()\timestamp = GetDatabaseLong(Db, 3)  
    Tasks()\autor = GetDatabaseString(Db, 4)  
    Tasks()\desc = GetDatabaseString(Db, 5)  
    Tasks()\tags = GetDatabaseString(Db, 6)  
    NbRows + 1
  Wend
  Debug "DB load " + NbRows + " task"
  FinishDatabaseQuery(Db)
EndProcedure
Procedure loadProjs()
  If Not DatabaseQuery(Db, "Select * FROM projs") ; Get all the records in the 'employee' table
    Debug Query$ + " | " + DatabaseError()
    ProcedureReturn
  EndIf
  NbRows = 0
  While NextDatabaseRow(Db)
    ;  projs (name CHAR(64) PRIMARY KEY, status INT, timestamp INT, desc CHAR(255))
    AddElement(projs())
    projs()\name = GetDatabaseString(Db, 0)  
    projs()\status = GetDatabaseLong(Db, 1)  
    projs()\timestamp = GetDatabaseLong(Db, 1)  
    projs()\desc = GetDatabaseString(Db, 3)  
    NbRows + 1
  Wend
  Debug "DB load " + NbRows + " projects"
  FinishDatabaseQuery(Db)
EndProcedure
  
Procedure.s fillSQLreq(SQLr$, *task.task_t)
  SQLr$ = ReplaceString(SQLr$, "%ID", Str(*task\id))
  SQLr$ = ReplaceString(SQLr$, "%name", *task\name)
  SQLr$ = ReplaceString(SQLr$, "%status", Str(*task\status))
  SQLr$ = ReplaceString(SQLr$, "%timestamp", Str(*task\timestamp))
  SQLr$ = ReplaceString(SQLr$, "%autor", *task\autor)
  SQLr$ = ReplaceString(SQLr$, "%desc", *task\desc)
  SQLr$ = ReplaceString(SQLr$, "%tags", *task\tags)
  SQLr$ = ReplaceString(SQLr$, "%proj", *task\proj)
  ProcedureReturn SQLr$
EndProcedure

;{
Procedure addTaskDB(*task.task_t, replace.i = 0)
  ;(ID INT PRIMARY KEY,name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))
  If replace
    SQLr$ = "INSERT or REPLACE INTO tasks VALUES ('%ID', '%name', '%status', '%timestamp', '%autor', '%desc', '%tags', '%proj')"
  Else
    SQLr$ = "INSERT INTO tasks VALUES ('%ID', '%name', '%status', '%timestamp', '%autor', '%desc', '%tags', 'proj')"
  EndIf
  SQLr$ = fillSQLreq(SQLr$, @Tasks())
  CheckDatabaseUpdate(0, SQLr$)
EndProcedure
Procedure updTaskDB(*task.task_t)
  ;(ID INT PRIMARY KEY,name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))
  SQLr$ = "UPDATE tasks SET name = '%name', status = '%status', desc = '%desc', tags = '%tags' WHERE id = %ID"
  SQLr$ = fillSQLreq(SQLr$, @Tasks())
  CheckDatabaseUpdate(0, SQLr$)
EndProcedure
Procedure delTaskDB(*task.task_t)
  ;(ID INT PRIMARY KEY,name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))
  SQLr$ = "DELETE FROM tasks WHERE id = %ID"
  SQLr$ = ReplaceString(SQLr$, "%ID", Str(*task\id))
  CheckDatabaseUpdate(0, SQLr$)
EndProcedure
Procedure delTaskDBid(ID)
  ;(ID INT PRIMARY KEY,name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))
  SQLr$ = "DELETE FROM tasks WHERE id = %ID"
  SQLr$ = ReplaceString(SQLr$, "%ID", Str(ID))
  CheckDatabaseUpdate(0, SQLr$)
EndProcedure
;}
Procedure SaveTasksAll()
  ForEach Tasks()
    addTaskDB(@Tasks(), 1)
  Next
EndProcedure


If FileSize("tasks.sqlite") <= 0
  CreateFile(0, "tasks.sqlite")
  CloseFile(0)
EndIf

If Not OpenDatabase(0, "tasks.sqlite", "", "")
  MessageRequester("Error", "EDBF")
  End
EndIf
CheckDatabaseUpdate(0, "ALTER TABLE tasks ADD COLUMN proj char(32)")
CheckDatabaseUpdate(0, "ALTER TABLE tasks ADD COLUMN tags char(64)")
CheckDatabaseUpdate(0, "CREATE TABLE IF not EXISTS tasks (ID INT PRIMARY KEY, name CHAR(64), status INT, timestamp INT, autor CHAR(64), desc CHAR(255))")
CheckDatabaseUpdate(0, "CREATE TABLE IF not EXISTS projs (name CHAR(64) PRIMARY KEY, status INT, timestamp INT, desc CHAR(255))")
loadTasks()
loadProjs()

; For i = 0 To 12
;  CheckDatabaseUpdate(0, "INSERT INTO tasks VALUES ('"+i+"', 'random-name"+Str(i)+"', '"+Str(Random(32)-16)+"', '"+
;                          Str(Date()+3600*24*(Random(16)-8))+"', '" + "user"+Str(Random(3)) + "', '')")
; Next
; CheckDatabaseQuery(0, "Select * FROM tasks")

; End
