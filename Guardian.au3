#AutoIt3Wrapper_UseX64 = Y
#include-once
#include <Common.au3>
#include <Array.au3>
#include <Date.au3>

While 1
	If WinExists("AutoIt Error") Or WinExists("VirtualBox Headless Frontend") Or WinExists("Dialog") Then
		Shutdown(6) ; Force a reboot
	EndIf

	Local $logfile = GetLog()
	If FileExists($logfile) Then
		Local $lastmodifiedtime = FileGetTime($logfile)
		Local $diff = _DateDiff("n",$lastmodifiedtime[0]&"/"&$lastmodifiedtime[1]&"/"&$lastmodifiedtime[2]&" "&$lastmodifiedtime[3]&":"&$lastmodifiedtime[4]&":"&$lastmodifiedtime[5],_NowCalc())
		If $diff > 10 Then
			Shutdown(6) ; Force a reboot
		EndIf
	EndIf

	Sleep(120000) ; every two minutes
WEnd