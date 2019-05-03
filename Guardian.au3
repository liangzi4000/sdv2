#AutoIt3Wrapper_UseX64 = Y
#include-once
#include <Common.au3>
#include <Array.au3>
#include <Date.au3>

While 1
	; Check if error happened by check error window
	If WinExists("AutoIt Error") Or WinExists("VirtualBox Headless Frontend") Or WinExists("Dialog") Then
		Shutdown(6) ; Force a reboot
	EndIf

	; Check if log file is modified within specified time period
	Local $logfile = GetLog()
	If FileExists($logfile) And (StringInStr($logfile, $v_windows[0]) > 0 Or StringInStr($logfile, $v_windows[1]) > 0) Then
		Local $lastmodifiedtime = FileGetTime($logfile)
		Local $diff = _DateDiff("n",$lastmodifiedtime[0]&"/"&$lastmodifiedtime[1]&"/"&$lastmodifiedtime[2]&" "&$lastmodifiedtime[3]&":"&$lastmodifiedtime[4]&":"&$lastmodifiedtime[5],_NowCalc())
		If $diff > 10 Then
			Shutdown(6) ; Force a reboot
		EndIf
	EndIf

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

	Sleep(180000) ; every three minutes
WEnd