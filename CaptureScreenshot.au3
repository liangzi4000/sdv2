#include-once
#include <GlobalVariables.au3>
#include <ScreenCapture.au3>
#include <Date.au3>
#include <Logger.au3>

Global Const $v_screenshotpath = @ScriptDir & "\Assets\screenshot\"

Func CaptureScreenshot($filename="",$logfile="")
	Local $screenshotpath = $v_screenshotpath
	Local $defaultfilename = StringReplace(StringReplace(StringReplace(_NowCalc(),"/",""),":","")," ","") &"_"& Random(1000,9999,1) & ".jpg"
	If $filename <> "" Then
		$defaultfilename = $filename
	EndIf
	_ScreenCapture_Capture($screenshotpath&$defaultfilename,0,0,-1,-1,False)
	WriteLog("Screenshot saved to " & $screenshotpath&$defaultfilename,$logfile)
EndFunc