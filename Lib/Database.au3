#include-once
#include "../GlobalVariables.au3"
#include "Logger.au3"
#include <StringConstants.au3>

Func ExecDBQuery($query)
	ShellExecuteWait($v_sqlcmdfile,"-S """ & $v_db_server & """ -U "&$v_db_userid&" -P "&$v_db_password&" -d "&$v_db&" -Q """&$query&""" -o """&$v_db_result&"""")
	Return StringStripWS(FileReadLine($v_db_result,3),8)
EndFunc

Func IsValidResult($dbmessage)
	If ($dbmessage <> "" And StringInStr($dbmessage,"|") > 0) Then
		Return True
	Else
		WriteLog("Invalid database message: "&$dbmessage)
		Return False
	EndIf
EndFunc