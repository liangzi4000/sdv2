#include-once
#include "AutoItConstants.au3"
#include "../GlobalVariables.au3"
#include "PositionHelper.au3"
#include "Logger.au3"

#comments-start
	Start a given name program which exists in the same folder as host program
#comments-end
Func StartProcess($processname)
	Local $fullpath = @ScriptDir & "\" & $processname
	If FileExists($fullpath) Then
		Run($fullpath)
	EndIf
EndFunc

#comments-start
	Close all processes with given name, e.g. notepad.exe
#comments-end
Func CloseProcess($processname)
	Local $exitloop = False
	While Not $exitloop
		Local $pid = ProcessExists($processname)
		If $pid <> 0 Then
			ProcessClose($pid)
		Else
			$exitloop =True
		EndIf
	WEnd
EndFunc