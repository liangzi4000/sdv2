#AutoIt3Wrapper_UseX64 = Y
#include-once
#include <Common.au3>
#include <Array.au3>
#include <Date.au3>

While 1
	Sleep(1800000) ; every 30 mins

	; Check if error happened by check error window
	If WinExists("AutoIt Error") Or WinExists("VirtualBox Headless Frontend") Or WinExists("Dialog") Then
		Shutdown(6) ; Force a reboot
		ExitLoop
	EndIf

	; Check database last login date
	Local $dblastlogindate = ExecDBQuery("[dbo].[SP_GetLastLoginDate] '" & $v_windows[0] & "'", 7)
	If $dblastlogindate <> '' Then
		Local $diff = _DateDiff("n",$dblastlogindate,_NowCalc())
		If $diff > 15 Then ; More than 15 minutes
			Shutdown(6) ; Force a reboot
			ExitLoop
		EndIf
	EndIf

;~	Below way of checking log file not working. There is a scenario where program keep writting log of found ui_startup without further action
;~  ; Check if log file is modified within specified time period
;~ 	Local $triggerrestart = True
;~ 	Local $filelist = _FileListToArray($v_logpath,"*.log",1,True)
;~ 	If @error = 0 Then
;~ 		For $index = 1 To $filelist[0]
;~ 			Local $lastmodifiedtime = FileGetTime($filelist[$index])
;~ 			;ConsoleWrite(FileGetTime($filelist[$index],Default,1) & @CRLF)
;~ 			Local $diff = _DateDiff("n",$lastmodifiedtime[0]&"/"&$lastmodifiedtime[1]&"/"&$lastmodifiedtime[2]&" "&$lastmodifiedtime[3]&":"&$lastmodifiedtime[4]&":"&$lastmodifiedtime[5],_NowCalc())
;~ 			If $diff > 7200 Then ; More than 5 days
;~ 				FileDelete($filelist[$index])
;~ 			ElseIf $diff < 10 Then ; Less than 10 minutes
;~ 				$triggerrestart = False
;~ 			EndIf
;~ 		Next
;~ 		If $triggerrestart Then
;~ 			Shutdown(6) ; Force a reboot
;~ 			ExitLoop
;~ 		EndIf
;~ 	EndIf

	; Check and execute remote command
	Local $commandurl = IniRead($cfgfile,"RPC","CommandUrl","")
	If $commandurl <> "" Then
		Local $pclist = StringSplit(_HTTP_Get($commandurl),@CRLF,2)
		For $i = 0 To UBound($pclist)-1
			If StringInStr($pclist[$i],$v_windows[0]) > 0 Then
				Local $commandinfo = StringSplit($pclist[$i]," ",2)
				If IniRead($cfgfile,"RPC",$commandinfo[1],"") = "" Then
					IniWrite($cfgfile, "RPC", $commandinfo[1], $commandinfo[2])
					Switch $commandinfo[2]
						Case 1
							Shutdown(6) 		; Force a reboot
						Case 2
							Shutdown(5) 		; Force a shutdown
						Case 3
							Shutdown(32) 		; Sleep
					EndSwitch
				EndIf
				ExitLoop
			EndIf
		Next
	EndIf

WEnd