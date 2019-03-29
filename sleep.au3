#include "AutoItConstants.au3"

HotKeySet("^x","_Standby")

While 1
	Sleep(100)
WEnd

Func _Standby()
		Shutdown($SD_STANDBY)
EndFunc

