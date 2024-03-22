If Not OpenLibrary(0, "Comctl32.dll")
  MessageRequester("", "")
EndIf


ExamineLibraryFunctions(0)
Debug CountLibraryFunctions(0)
For i = 0  To CountLibraryFunctions(0)
  Lname.s = LibraryFunctionName()
  If FindString(LCase(Lname), "enable")
    Debug Lname
  EndIf
  
  NextLibraryFunction()
Next
; GadgetID(0)
; ListView()

; COMctl32.dll InitCommonControls

