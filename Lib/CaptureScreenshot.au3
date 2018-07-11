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
Func CaptureFullScreen($filename="", $myscreenshotpath="")
	Local $area[4] = [0,0,-1,-1]
	Return _CaptureScreen($filename, $myscreenshotpath, $area)
EndFunc

Func CaptureActiveWindow($filename="", $myscreenshotpath="")
	Local $area[4]
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	$area[0] = $winpos[0] + $ctrlpos[0]
	$area[1] = $winpos[1] + $ctrlpos[1]
	$area[2] = $area[0] + $ctrlpos[2]
	$area[3] = $area[1] + $ctrlpos[3]
	Return _CaptureScreen($filename, $myscreenshotpath, $area)
EndFunc

Func _CaptureScreen($filename, $myscreenshotpath, $area)
	Local $screenshotpath = $v_screenshotpath
	If $myscreenshotpath <> "" Then $screenshotpath = $myscreenshotpath

	Local $defaultfilename = StringReplace(StringReplace(StringReplace(_NowCalc(),"/",""),":","")," ","") &"_"& Random(1000,9999,1) & ".jpg"
	If $filename <> "" Then $defaultfilename = $filename

	_ScreenCapture_Capture($screenshotpath&$defaultfilename,$area[0],$area[1],$area[2],$area[3],False)
	Return $defaultfilename
EndFunc

