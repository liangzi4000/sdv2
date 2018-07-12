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

HotKeySet("^m", "Main")				; execute main process
HotKeySet("^q", "Terminate") 		; quit immediately
HotKeySet("^f", "Finish") 			; quit after complete current record
HotKeySet("^g", "ShutdownAfterFinish") 	; shut down PC when all tasks completed

While 1
	Sleep(200)
WEnd

Func Finish()
	WriteLog("Ctrl+F pressed.")
	$exit = True
	$exitaction = $exitaction_terminatescript
EndFunc

Func Terminate()
	WriteLog("Ctrl+Q pressed.")
	$exitaction = $exitaction_terminatescript
	Exit
EndFunc

Func ShutdownAfterFinish()
	BlockInput($BI_DISABLE)
	WriteLog("Ctrl+G pressed.")
	$shutdownpc = True
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

	; Default to terminate program without shutdown PC
	If $exitaction = $exitaction_restart Then
		$exitaction = $exitaction_terminatescript
	EndIf

	If $shutdownpc Then
		$exitaction = $exitaction_shutdownpc
	EndIf
	Exit
EndFunc

Func OnAutoitExit()
	WriteLog("OnAutoitExit Called.")
	Switch $exitaction
		Case $exitaction_restart
			Local $errorscreen = $v_screenshotpath & CaptureFullScreen()
			$v_email_Subject = "Program auto restart triggered"
			$v_email_AttachFiles = $errorscreen
			_INetSmtpMailCom($v_email_SmtpServer,$v_email_FromName,$v_email_FromAddress,$v_email_ToAddress,$v_email_Subject,$v_email_Body,$v_email_AttachFiles,$v_email_CcAddress,$v_email_BccAddress,$v_email_Importance,$v_email_Username,$v_email_Password,$v_email_IPPort,$v_email_ssl)
			ExecStep("CloseApp")
			RunScript()
		Case $exitaction_shutdownpc
			Shutdown(BitOR($SD_SHUTDOWN,$SD_FORCE)) ; shutdown PC
		Case $exitaction_terminatescript
			; do nothing
	EndSwitch
EndFunc
