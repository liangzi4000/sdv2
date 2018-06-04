#include-once
#include "../GlobalVariables.au3"
#include <File.au3>
#include <Date.au3>

Global Const $v_logpath = @ScriptDir & "\Log\"
Global Const $v_exception = "_Exception"

;possible $file value: "","_errorhandler", or "_reset"
Func WriteLog($msg,$file="")
	Local $hFile = FileOpen(GetLog($file), 9)
	_FileWriteLog($hFile, $msg)
	FileClose($hFile)
EndFunc

Func GetLog($file="")
	If IsDeclared("activewindow") <> 1 Then
		Local $activewindow = "Default"
	EndIf

	Return $v_logpath & StringReplace(_NowCalcDate(),"/","")&$activewindow&$file&".log"
EndFunc
