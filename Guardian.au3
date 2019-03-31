While 1
	If WinExists("AutoIt Error") Or WinExists("VirtualBox Headless Frontend") Or WinExists("Dialog") Then
		Shutdown(6)) ; Force a reboot
	EndIf
	Sleep(120000)
WEnd