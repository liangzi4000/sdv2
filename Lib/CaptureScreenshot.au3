#include-once
#include "../GlobalVariables.au3"
#include "Logger.au3"
#include <ScreenCapture.au3>
#include <Date.au3>

Global Const $v_screenshotpath = @ScriptDir & "\Assets\screenshot\"


#comments-start
	$filename: screenshot file name, if it's empty, default file name will be used
	$logfile: the log file to record debug message, if it's empty, defualt file will be used
#comments-end
Func CaptureScreenshot($filename="",$logfile="")
	Local $screenshotpath = $v_screenshotpath
	Local $defaultfilename = StringReplace(StringReplace(StringReplace(_NowCalc(),"/",""),":","")," ","") &"_"& Random(1000,9999,1) & ".jpg"
	If $filename <> "" Then
		$defaultfilename = $filename
	EndIf
	_ScreenCapture_Capture($screenshotpath&$defaultfilename,0,0,-1,-1,False)
	WriteLog("Screenshot saved to " & $screenshotpath&$defaultfilename,$logfile)
EndFunc