#AutoIt3Wrapper_UseX64 = Y
#RequireAdmin
#include <Common.au3>
#include <Steps.au3>
#include <CreateAccounts.au3>

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
	$exit = True
	Exit
EndFunc

Func Main()
	BlockInput($BI_DISABLE)
	ExecDBQuery("[dbo].[SP_ResetDailyTaskStatus] '"&$v_windows[0]&"'")
	Local $firstrunflag = True
	While UBound($inactivewindows)-1 <> UBound($v_windows)
		If $firstrunflag Then
			$firstrunflag = False
			For $x=0 To UBound($firstrun)-1
				ExecStep($firstrun[$x])
			Next
		Else
			For $x=0 To UBound($steps)-1
				ExecStep($steps[$x])
			Next
		EndIf
	WEnd
	WriteLog("Accounts sign in completed.")

	; Reset inactive window array to default
	While UBound($inactivewindows) > 1
		_ArrayPop($inactivewindows)
	WEnd

	While UBound($inactivewindows)-1 <> UBound($v_windows)
		For $x=0 To UBound($createaccountsteps)-1
			ExecStep($createaccountsteps[$x])
		Next
	WEnd
	WriteLog("Accounts creation completed.")
	$exit = True
	Exit


;~ 	$v_email_Subject = "All tasks completed"
;~ 	$v_email_AttachFiles = GetLog()
;~ 	_INetSmtpMailCom($v_email_SmtpServer,$v_email_FromName,$v_email_FromAddress,$v_email_ToAddress,$v_email_Subject,$v_email_Body,$v_email_AttachFiles,$v_email_CcAddress,$v_email_BccAddress,$v_email_Importance,$v_email_Username,$v_email_Password,$v_email_IPPort,$v_email_ssl)

;~ 	Shutdown($SD_SHUTDOWN) ; shutdown PC
EndFunc

Func OnAutoitExit()
	WriteLog("OnAutoitExit Called.")
	CaptureScreenshot()
	ExecStep("CloseApp")
	If Not $exit Then
		RunScript()
	EndIf
EndFunc
