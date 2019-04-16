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
	$pixelinfo[3]: shadow-variation, optional, default is 5
	$pixelinfo[4]: pixel point to top or bottom, optional, default is 2
	$pixelinfo[5]: pixel point to left or right, optional, default is 2
#comments-end
Func SearchPixel($pixelinfo_var)
	Local $pixelinfo = FormatPixelInfo($pixelinfo_var)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $area[4]
	$area[0] = $winpos[0] + $ctrlpos[0] + $pixelinfo[0] - $pixelinfo[5]
	$area[1] = $winpos[1] + $ctrlpos[1] + $pixelinfo[1] - $pixelinfo[4]
	$area[2] = $winpos[0] + $ctrlpos[0] + $pixelinfo[0] + $pixelinfo[5]
	$area[3] = $winpos[1] + $ctrlpos[1] + $pixelinfo[1] + $pixelinfo[4]
	Local $aCoord = PixelSearch($area[0], $area[1], $area[2], $area[3], $pixelinfo[2], $pixelinfo[3])
	If Not @error Then
		If _ArrayToString($aCoord) = -1 Then
			If $debug Then WriteLog("SearchPixel unable to find " & _ArrayToString($pixelinfo))
			Return $pixel_empty
		EndIf
		If $debug Then WriteLog("SearchPixel found " & _ArrayToString($pixelinfo))
		Return $aCoord
	Else
		If $debug Then WriteLog("SearchPixel unable to find " & _ArrayToString($pixelinfo))
		Return $pixel_empty
	EndIf
EndFunc   ;==>SearchPixel

Func FormatPixelInfo($pixelinfo)
	Switch UBound($pixelinfo)
		Case 3
			_ArrayAdd($pixelinfo, $pixelinfo_shadow_variation)
			_ArrayAdd($pixelinfo, $pixelinfo_half_height)
			_ArrayAdd($pixelinfo, $pixelinfo_half_width)
		Case 4
			_ArrayAdd($pixelinfo, $pixelinfo_half_height)
			_ArrayAdd($pixelinfo, $pixelinfo_half_width)
		Case 5
			_ArrayAdd($pixelinfo, $pixelinfo_half_width)
		Case Else
			; nothing
	EndSwitch
	Return $pixelinfo
EndFunc   ;==>FormatPixelInfo

Func WaitPixel($pixelinfo, $timeout = Default, $timeoutcall = Default, $click = Default)
	If $timeout = Default Then $timeout = 60
	If $click = Default Then $click = False

	Local $hTimer = TimerInit()
	While 1
		Local $pixelresult = SearchPixel($pixelinfo)
		If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
			If $debug Then WriteLog("WaitPixel found " & _ArrayToString($pixelinfo))
			If $click Then ClickOn($pixelresult)
			ExitLoop
		EndIf

		If TimerDiff($hTimer) > $timeout * 1000 Then
			If $timeoutcall <> Default Then
				WriteLog("WaitPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($pixelinfo) & ", $timeoutcall=" & $timeoutcall, $v_exception)
				Call($timeoutcall)
			ElseIf $timeoutcount < 1 Then
				WriteLog("WaitPixel time out after " & $timeout & " seconds waiting for pixel " & _ArrayToString($pixelinfo) & ", $timeoutcount=" & $timeoutcount, $v_exception)
				$timeoutcount = $timeoutcount + 1
				ClickOnLastPosition()
				Call("WaitPixel", $pixelinfo, $timeout, $timeoutcall, $click)
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
EndFunc   ;==>WaitPixel

Func ClickPixel($pixelinfo, $timeout = Default, $timeoutcall = Default)
	WaitPixel($pixelinfo, $timeout, $timeoutcall, True)
	If $debug Then WriteLog("ClickPixel clicked on pixel " & _ArrayToString($pixelinfo))
EndFunc   ;==>ClickPixel

Func ClickImageUntilScreenByPixel($waitimage, $untilpixel, $interval = Default, $timeout = Default, $timeoutcall = Default, $convertposition = Default)
	Local $pos = GetImageCenterPosActive($waitimage)
	ClickPosUntilScreenByPixel($pos, $untilpixel, Default, $interval, $timeout, $timeoutcall, $convertposition)
EndFunc   ;==>ClickImageUntilScreenByPixel

Func ClickPosUntilScreenByPixel($pos, $untilpixel, $ext = Default, $interval = Default, $timeout = Default, $timeoutcall = Default, $convertposition = Default)
	Local $untilpixellist = [$untilpixel]
	ClickPosUntilScreenByMultiPixel($pos,$untilpixellist,$ext,$interval,$timeout,$timeoutcall,$convertposition)
	If $debug Then WriteLog("ClickPosUntilScreenByPixel found pixel " & _ArrayToString($untilpixel))
EndFunc   ;==>ClickPosUntilScreenByPixel

Func ClickPosUntilScreenByMultiPixel($pos, $untilpixellist, $ext = Default, $interval = Default, $timeout = Default, $timeoutcall = Default, $convertposition = Default)
	If $interval = Default Then $interval = 700
	If $timeout = Default Then $timeout = 60
	If $convertposition = Default Then $convertposition = True

	Local $mypos = $convertposition = True ? ConvertRelativePosToAbsolutePos($pos) : $pos
	Local $x = 0, $y = 0
	Local $hTimer = TimerInit()
	Local $foundcount = 0
	Do
		$foundcount = 0
		If TimerDiff($hTimer) > $timeout * 1000 Then
			If $timeoutcall <> Default Then
				WriteLog("ClickPosUntilScreenByMultiPixel time out after " & $timeout & " seconds waiting for pixel list " & ConvertArrayInArrayToString($untilpixellist) & ", $timeoutcall=" & $timeoutcall, $v_exception)
				Call($timeoutcall)
			Else
				WriteLog("ClickPosUntilScreenByMultiPixel time out after " & $timeout & " seconds waiting for pixel list " & ConvertArrayInArrayToString($untilpixellist) & ", exit", $v_exception)
				;;;;;;;;;;;;;;;;;;;; TIMEOUT EXIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				Exit
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			EndIf
			ExitLoop
		EndIf

		ClickOn($mypos)
		Sleep($interval)
		If $ext <> Default Then Call($ext)
		For $count = 0 To UBound($untilpixellist) - 1
			Local $pixelresult = SearchPixel($untilpixellist[$count])
			If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
				$foundcount += 1
			EndIf

		Next
	Until $foundcount = UBound($untilpixellist)
	If $debug Then WriteLog("ClickPosUntilScreenByMultiPixel found pixel list " & ConvertArrayInArrayToString($untilpixellist))
EndFunc   ;==>ClickPosUntilScreenByMultiPixel

#comments-start
	Wait and click on specified pixel in active window until targe pixel appear in active window
#comments-end
Func ClickPixelUntilScreenByPixel($waitpixel, $untilpixel, $interval = Default, $timeout = Default, $timeoutcall = Default)
	WaitPixel($waitpixel)
	Local $pos = [$waitpixel[0], $waitpixel[1]]
	ClickPosUntilScreenByPixel($pos, $untilpixel, Default, $interval, $timeout, $timeoutcall)
	If $debug Then WriteLog("ClickPixelUntilScreenByPixel found pixel " & _ArrayToString($untilpixel))
EndFunc   ;==>ClickPixelUntilScreenByPixel

#comments-start
	Check if all the pixels in the list exist
	return true if all pixels are found, otherwise false
#comments-end
Func FindPixelList($pixellist)
	Local $result = True
	For $i = 0 To UBound($pixellist) - 1
		Local $currentitem = $pixellist[$i]
		Local $pixelresult = SearchPixel($currentitem)
		If $pixelresult[0] = $pixel_empty[0] And $pixelresult[1] = $pixel_empty[1] Then
			$result = False
			ExitLoop
		EndIf
	Next
	Return $result
EndFunc   ;==>CheckPixelList

Func WaitPixelList($pixellist, $timeoutcall = Default, $timeout = Default)
	If $timeout = Default Then $timeout = 60
	Local $hTimer = TimerInit()
	Do
		Sleep(500)
		If TimerDiff($hTimer) > $timeout * 1000 Then
			$hTimer = TimerInit()
			Call($timeoutcall)
		EndIf
	Until FindPixelList($pixellist) = True
EndFunc   ;==>WaitPixelList

#comments-start
	Determine which pixel exist given an array of pixels
	return the found pixel index or exit program if not found, default time out is 60 seconds
#comments-end
Func DeterminePixel($pixellist, $timeout = Default)
	If $timeout = Default Then $timeout = 60

	Local $sleepinterval = 500
	Local $hTimer = TimerInit()
	While 1
		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("DeterminePixel time out after " & $timeout & " seconds waiting for pixel list " & _ArrayToString($pixellist) & ", exit", $v_exception)
			;;;;;;;;;;;;;;;;;;;; TIMEOUT EXIT ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			Exit
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		EndIf

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
	WEnd
EndFunc   ;==>DeterminePixel

Func GetPixelColor($pos)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $iColor = PixelGetColor($winpos[0] + $ctrlpos[0] + $pos[0], $winpos[1] + $ctrlpos[1] + $pos[1])
	Return Hex($iColor, 6)
EndFunc   ;==>GetPixelColor

