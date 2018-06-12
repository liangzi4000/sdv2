#include-once
#include "../GlobalVariables.au3"
#include "PositionHelper.au3"
#include "Logger.au3"
#include "BasicActions.au3"


#comments-start
	$pixelinfo is an array with following format:
	$pixelinfo[0]: relative position x
	$pixelinfo[1]: relative position y
	$pixelinfo[2]: color
	$pixelinfo[3]: shadow-variation, optional, default is 0
	$pixelinfo[4]: pixel point to top or bottom, optional, default is 5
	$pixelinfo[5]: pixel point to left or right, optional, default is 5
#comments-end
Func SearchPixel($pixelinfo)
	FormatPixelInfo($pixelinfo)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $area[4]
	$area[0] = $winpos[0] + $ctrlpos[0] + $pixelinfo[0] - $pixelinfo[5]
	$area[1] = $winpos[1] + $ctrlpos[1] + $pixelinfo[1] - $pixelinfo[4]
	$area[2] = $winpos[0] + $ctrlpos[0] + $pixelinfo[0] + $pixelinfo[5]
	$area[3] = $winpos[1] + $ctrlpos[1] + $pixelinfo[1] + $pixelinfo[4]
	Local $aCoord = PixelSearch($area[0], $area[1], $area[2], $area[3], $pixelinfo[2], $pixelinfo[3])
	If Not @error Then
		If $debug Then WriteLog("SearchPixel found " & _ArrayToString($pixelinfo))
		Return $aCoord
	Else
		If $debug Then WriteLog("SearchPixel unable to find " & _ArrayToString($pixelinfo))
		Return $pixel_empty
	EndIf
EndFunc

Func FormatPixelInfo($pixelinfo)
	Switch UBound($pixelinfo)
		Case 3
			_ArrayAdd($pixelinfo,$pixelinfo_shadow_variation)
			_ArrayAdd($pixelinfo,$pixelinfo_half_height)
			_ArrayAdd($pixelinfo,$pixelinfo_half_width)
		Case 4
			_ArrayAdd($pixelinfo,$pixelinfo_half_height)
			_ArrayAdd($pixelinfo,$pixelinfo_half_width)
		Case 5
			_ArrayAdd($pixelinfo,$pixelinfo_half_width)
		Case Else
			; nothing
	EndSwitch
EndFunc

Func WaitPixel($pixelinfo, $timeout = 60, $timeoutcall = "", $click = False)
	Local $hTimer = TimerInit()

	While 1
		Local $pixelresult = SearchPixel($pixelinfo)
		If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
			If $debug Then WriteLog("WaitPixel found " & _ArrayToString($pixelinfo))
			If $click Then ClickOn($pixelresult)
			ExitLoop
		EndIf

		If TimerDiff($hTimer) > $timeout * 1000 Then
			If $timeoutcall <> "" Then
				WriteLog("WaitPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($pixelinfo) & ", $timeoutcall=" & $timeoutcall, $v_exception)
				Call($timeoutcall)
			ElseIf $timeoutcount < 1 Then
				WriteLog("WaitPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($pixelinfo) & ", $timeoutcount=" & $timeoutcount, $v_exception)
				$timeoutcount = $timeoutcount + 1
				ClickOnLastPosition()
				Call("WaitPixel",$pixelinfo,$timeout,$timeoutcall,$click)
			Else
				WriteLog("WaitPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($pixelinfo) & ", exit after click on last position and failed", $v_exception)
				;;;;;;;;;;;;;;;;;;;; TIMEOUT EXIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				Exit
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			EndIf
			ExitLoop
		EndIf

		Sleep(100)
	WEnd
EndFunc

Func ClickPixel($pixelinfo, $timeout = 60, $timeoutcall = "")
	WaitPixel($pixelinfo, $timeout, $timeoutcall, True)
	If $debug Then WriteLog("ClickPixel clicked on pixel " & _ArrayToString($pixelinfo))
EndFunc

Func ClickPosUntilScreenByPixel($pos, $untilpixel, $interval = 700, $timeout = 60, $timeoutcall = "", $convertposition = True)
	Local $mypos = $convertposition = True ? ConvertRelativePosToAbsolutePos($pos) : $pos
	Local $x = 0, $y = 0
	Local $hTimer = TimerInit()
	Do
		If TimerDiff($hTimer) > $timeout * 1000 Then
			If $timeoutcall <> "" Then
				WriteLog("ClickPosUntilScreenByPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($untilpixel) & ", $timeoutcall=" & $timeoutcall, $v_exception)
				Call($timeoutcall)
			Else
				WriteLog("ClickPosUntilScreenByPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($untilpixel) & ", exit", $v_exception)
				;;;;;;;;;;;;;;;;;;;; TIMEOUT EXIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				Exit
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			EndIf
			ExitLoop
		EndIf

		ClickOn($pos)
		Sleep($interval)
		Local $pixelresult = SearchPixel($untilpixel)
	Until $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1]
	If $debug Then WriteLog("ClickPosUntilScreenByPixel found pixel " & _ArrayToString($untilpixel))
EndFunc

#comments-start
	Wait and click on specified image in active window until targe image appear in active window
#comments-end
Func ClickPixelUntilScreenByPixel($waitpixel, $untilpixel, $interval = 700, $timeout = 60, $timeoutcall = "")
	WaitPixel($waitpixel)
	Local $pos = [$waitpixel[0],$waitpixel[1]]
	ClickPosUntilScreenByPixel($pos, $untilpixel, $interval, $timeout, $timeoutcall)
	If $debug Then WriteLog("ClickPixelUntilScreenByPixel found pixel " & _ArrayToString($untilpixel))
EndFunc   ;==>ClickImageUntilScreen

#comments-start
	Determine which pixel exist given an array of pixels
	return the found pixel index or -1 if not found, default time out is 1 second
#comments-end
Func DeterminePixel($pixellist, $timeout = 1)
	Local $sleepinterval = 500
	Local $count = 0
	While 1
		Local $found = -1
		For $i = 0 To UBound($pixellist) - 1
			Local $currentitem = $pixellist[$i]
			Local $pixelresult = SearchPixel($currentitem)
			If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
				$found = $i
				ExitLoop
			EndIf
		Next
		If $found > -1 Then
			If $debug Then WriteLog("DeterminePixel found " & _ArrayToString($pixellist[$found]))
			Return $found ; return found pixel index
		EndIf
		Sleep($sleepinterval)
		$count = $count + 1
		If ($count >= $timeout * 1000 / $sleepinterval) Then
			If $debug Then WriteLog("DeterminePixel time out and unable to find " & _ArrayToString($pixellist))
			Return -1 ; return -1 if timeout
		EndIf
	WEnd
EndFunc   ;==>DeterminePixel
