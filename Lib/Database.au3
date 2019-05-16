#include-once
#include "../GlobalVariables.au3"
#include "Logger.au3"
#include <StringConstants.au3>

Func ExecDBQuery($query, $stripWS = 8)
	ShellExecuteWait($v_sqlcmdfile,"-S """ & $v_db_server & """ -U "&$v_db_userid&" -P "&$v_db_password&" -d "&$v_db&" -Q """&$query&""" -o """&$v_db_result&"""")
	Return StringStripWS(FileReadLine($v_db_result,3),$stripWS)
EndFunc

Func IsValidResult($dbmessage)
	If ($dbmessage <> "" And StringInStr($dbmessage,"|") > 0) Then
		Return True
	Else
		Return False
	EndIf
EndFunc