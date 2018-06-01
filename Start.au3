#AutoIt3Wrapper_UseX64 = Y
#include <Common.au3>
#include <Steps.au3>

If MutexExists("MydeswswScriptName") Then
	; We know the script is already running. Let the user know.
    MsgBox(0, "Script Name", "This script is already running. Using multiple copies of this script at the same breaks the [(BruceAutomation)] License!")
    Exit
EndIf
OnAutoItExitRegister("OnAutoitExit")

HotKeySet("^m", "Main")
HotKeySet("^q", "Terminate") ; quit immediately
HotKeySet("^f", "Finish") ; quit after complete current record

While 1
	Sleep(200)
WEnd

Func Finish()
	WriteLog("Ctrl+F pressed.")
	$exit = True
EndFunc

Func Terminate()
	WriteLog("Ctrl+Q pressed.")
	Exit
EndFunc

Func Main()
	Local $firstrunflag = True
	While UBound($inactivewindows) <> UBound($v_windows)
		If $firstrunflag Then
			$firstrunflag = False
			For $x=0 To UBound($firstrun)-1
				ExecStep($firstrun[$x])
			Next
		EndIf

		For $x=0 To UBound($steps)-1
			ExecStep($steps[$x])
		Next
	WEnd
	Exit
EndFunc

Func OnAutoitExit()
	WriteLog("OnAutoitExit Called.")
EndFunc
