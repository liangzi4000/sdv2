While 1
	If WinExists("AutoIt Error") Then
		Shutdown(6)) ; Force a reboot
	EndIf
	Sleep(120000)
WEnd