#AutoIt3Wrapper_UseX64 = Y
#RequireAdmin ;start sql service require administrator right
#include-once
#include <FileConstants.au3>
#include <Common.au3>

; If host, Start SQL Service
Local $IsHost = IniRead($cfgfile,"Install","IsHost","")
If $IsHost="True" Then WaitForSQLService()

; Auto update program
Local $UpdateFolder = @ScriptDir & "\Assets\Update\"
Local $file_start_exe = $UpdateFolder & "start.exe"
Local $file_start_ini = $UpdateFolder & "start.ini"
Local $file_guardian_exe = $UpdateFolder & "guardian.exe"
If FileExists($file_start_exe) Then FileMove($file_start_exe,@ScriptDir,$FC_OVERWRITE)
If FileExists($file_start_ini) Then FileMove($file_start_ini,@ScriptDir,$FC_OVERWRITE)
If FileExists($file_guardian_exe) Then FileMove($file_guardian_exe,@ScriptDir,$FC_OVERWRITE)

; Launch program
Sleep(20000)
Run(@ScriptDir&"\Start.exe")
Sleep(10000)
Send("^m")
Exit

Func WaitForSQLService()
	While ExecDBQuery("SELECT 1 AS Result") <> "1"
		WriteLog("Waiting for SQL service ...")
		Sleep(15000)
	WEnd
EndFunc