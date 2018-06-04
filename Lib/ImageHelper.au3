#include-once
#include "../GlobalVariables.au3"
#include "ImageSearch.au3" ;this is a third party library
#include "PositionHelper.au3"
#include "Logger.au3"
#include "BasicActions.au3"

#comments-start
	Check if specified image can be found in active window, the $x and $y are absolute screen coordinates
#comments-end
Func SearchImage($image, ByRef $x, ByRef $y, $tolerance = 20, $area_x = 0, $area_y = 0, $area_width = 0, $area_height = 0)
	Local $area[4]
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	If $area_x = 0 And $area_y = 0 And $area_width = 0 And $area_height = 0 Then
		$area[0] = $winpos[0] + $ctrlpos[0]
		$area[1] = $winpos[1] + $ctrlpos[1]
		$area[2] = $area[0] + $ctrlpos[2]
		$area[3] = $area[1] + $ctrlpos[3]
	Else
		$area[0] = $winpos[0] + $ctrlpos[0] + $area_x
		$area[1] = $winpos[1] + $ctrlpos[1] + $area_y
		$area[2] = $area[0] + $area_width
		$area[3] = $area[1] + $area_height
	EndIf
	Local $result = _ImageSearchArea($v_imagepath & $image, 1, $area[0], $area[1], $area[2], $area[3], $x, $y, $tolerance)
	If $debug Then WriteLog("SearchImage search " & $image & ", result:" & $result)
	Return $result ; return 1 or 0
EndFunc   ;==>SearchImage

#comments-start
	Check if specified image can be found in desktop, the $x and $y are absolute screen coordinates
#comments-end
Func SearchImageDesktop($image, ByRef $x, ByRef $y, $tolerance = 20)
	Local $result = _ImageSearch($v_imagepath&$image, 1, $x, $y, $tolerance)
	If $debug Then WriteLog("SearchImageDesktop search " & $image & ", result:" & $result)
	Return $result ; return 1 or 0
EndFunc

#comments-start
	Return the center absolute x,y coordination of speicifed image in active window
#comments-end
Func GetImageCenterPos($image)
	Local $pos = [0, 0]
	SearchImage($image, $pos[0], $pos[1])
	Return $pos
EndFunc   ;==>GetImageCenterPos

#comments-start
	Wait and check if specified image(s) can be found in desktop
	$image: single image file or mutiple image files seperated by comma
	return value:
	0 				- not found
	1 				- found when $image is single file
	index number 	- found when $image is multiple files, it starts from 1
#comments-end
Func WaitImageDesktop($image, $timeout = 20, $timeoutcall = "", $click = False)
	Local $hTimer = TimerInit()
	Local $pos = [0, 0]
	Local $list = StringSplit($image, ",")
	Local $found = 0

	While 1
		For $i = 1 To $list[0]
			If SearchImageDesktop($list[$i], $pos[0], $pos[1]) = 1 Then
				$found = $i
				ExitLoop
			EndIf
		Next

		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("WaitImageDesktop time out after " & $timeout & " seconds waiting for image " & $image & ", $timeoutcall=" & $timeoutcall, $v_exception)
			Exit
			If $timeoutcall <> "" Then Call($timeoutcall)
			ExitLoop
		EndIf

		If $found <> 0 Then
			If $debug Then WriteLog("WaitImageDesktop found image " & $list[$found])
			ExitLoop
		EndIf

		Sleep(200)
	WEnd

	If $pos[0] <> 0 And $pos[1] <> 0 Then
		If $click Then ClickOn($pos)
	EndIf

	Return $found
EndFunc

#comments-start
	Wait and check if specified image(s) can be found in active window
	$image: single image file or mutiple image files seperated by comma
	return value:
	0 				- not found
	1 				- found when $image is single file
	index number 	- found when $image is multiple files, it starts from 1
#comments-end
Func WaitImage($image, $timeout = 20, $timeoutcall = "", $click = False, $area_x = 0, $area_y = 0, $area_width = 0, $area_height = 0)
	Local $hTimer = TimerInit()
	Local $pos = [0, 0]
	Local $list = StringSplit($image, ",")
	Local $found = 0

	While 1
		For $i = 1 To $list[0]
			If SearchImage($list[$i], $pos[0], $pos[1], 20, 0, 0, 0, 0) = 1 Then
				$found = $i
				ExitLoop
			EndIf
		Next

		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("WaitImage time out after " & $timeout & " seconds waiting for image " & $image & ", $timeoutcall=" & $timeoutcall, $v_exception)
			Exit
			If $timeoutcall <> "" Then Call($timeoutcall)
			ExitLoop
		EndIf

		If $found <> 0 Then
			If $debug Then WriteLog("WaitImage found image " & $list[$found])
			ExitLoop
		EndIf

		Sleep(200)
	WEnd

	If $pos[0] <> 0 And $pos[1] <> 0 Then
		If $click Then ClickOn($pos)
	EndIf

	Return $found
EndFunc   ;==>WaitImage


#comments-start
	Wait and click on specified image in desktop
	Return 1: clicked; 0: not click due to time out
#comments-end
Func ClickImageDesktop($image, $sureclick = False, $timeout = 20, $timeoutcall = "")
	If Not $sureclick Then
		If WaitImageDesktop($image, $timeout, $timeoutcall, True) = 1 Then
			If $debug Then WriteLog("ClickImageDesktop clicked on image " & $image)
			Return 1
		Else
			WriteLog("ClickImageDesktop unable to find image " & $image, $v_exception)
			Return 0
		EndIf
	EndIf

	If WaitImageDesktop($image, $timeout, $timeoutcall, True) = 1 Then
		Local $pos = [0, 0]
		While SearchImageDesktop($image, $pos[0], $pos[1]) = 1
			ClickOn($pos)
			Sleep(1000)
		WEnd
		If $debug Then WriteLog("ClickImageDesktop [sureclick] clicked on image " & $image)
	Else
		WriteLog("ClickImageDesktop [sureclick] unable to find image " & $image, $v_exception)
	EndIf
EndFunc

#comments-start
	Wait and click on specified image in active window
	Return 1: clicked; 0: not click due to time out
#comments-end
Func ClickImage($image, $sureclick = False, $timeout = 20, $timeoutcall = "", $area_x = 0, $area_y = 0, $area_width = 0, $area_height = 0)
	If Not $sureclick Then
		If WaitImage($image, $timeout, $timeoutcall, True, 0, 0, 0, 0) = 1 Then
			If $debug Then WriteLog("ClickImage clicked on image " & $image)
			Return 1
		Else
			WriteLog("ClickImage unable to find image " & $image, $v_exception)
			Return 0
		EndIf
	EndIf

	If WaitImage($image, $timeout, $timeoutcall, False, 0, 0, 0, 0) = 1 Then
		Local $pos = [0, 0]
		While SearchImage($image, $pos[0], $pos[1]) = 1
			ClickOn($pos)
			Sleep(1000)
		WEnd
		If $debug Then WriteLog("ClickImage [sureclick] clicked on image " & $image)
	Else
		WriteLog("ClickImage [sureclick] unable to find image " & $image, $v_exception)
	EndIf
EndFunc   ;==>ClickImage

#comments-start
	Wait and click on specified image in active window until targe image appear in active window
#comments-end
Func ClickImageUntilScreen($waitimage, $untilimage, $interval = 700, $timeout = 20, $timeoutcall = "")
	If WaitImage($waitimage, $timeout, $timeoutcall) = 1 Then
		Local $pos = [0, 0]
		If SearchImage($waitimage, $pos[0], $pos[1]) = 1 Then
			Local $result = ClickPosUntilScreen($pos, $untilimage, $interval, $timeout, $timeoutcall, False)
			If $result = 1 Then
				If $debug Then WriteLog("ClickImageUntilScreen found image " & $untilimage)
				Return 1
			Else
				If $debug Then WriteLog("ClickImageUntilScreen unable to find image " & $untilimage)
				Return 0
			EndIf
		Else
			WriteLog("ClickImageUntilScreen unexpected error")
			Return 0
		EndIf
	Else
		WriteLog("ClickImageUntilScreen unable to find image " & $waitimage, $v_exception)
		Return 0
	EndIf
EndFunc   ;==>ClickImageUntilScreen

#comments-start
	Wait and click on specified position in active window until targe image appear in active window.
	The $pos by default is relative position
#comments-end
Func ClickPosUntilScreen($pos, $untilimage, $interval = 700, $timeout = 20, $timeoutcall = "", $convertposition = True)
	Local $mypos = $convertposition = True ? ConvertRelativePosToAbsolutePos($pos) : $pos
	Local $x = 0, $y = 0
	Local $hTimer = TimerInit()
	While SearchImage($untilimage, $x, $y) = 0
		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("ClickPosUntilScreen time out after " & $timeout & " seconds waiting for image " & $untilimage & ", $timeoutcall=" & $timeoutcall, $v_exception)
			Exit
			If $timeoutcall <> "" Then Call($timeoutcall)
			Return 0
		EndIf
		ClickOn($mypos)
		Sleep($interval)
	WEnd
	If $debug Then WriteLog("ClickPosUntilScreen found image " & $untilimage)
	Return 1
EndFunc   ;==>ClickPosUntilScreen

Func DragImage($image, $to_pos, $relaive = True)
	If WaitImage($image) = 1 Then
		Local $pos = [0, 0]
		SearchImage($image, $pos[0], $pos[1])
		If $relaive Then
			Local $abspos = ConvertRelativePosToAbsolutePos($to_pos)
			Drag($pos[0], $pos[1], $abspos[0], $abspos[1])
		Else
			Drag($pos[0], $pos[1], $to_pos[0], $to_pos[1])
		EndIf

		If $debug Then WriteLog("Drag image " & $image & " to [" & $to_pos[0] & "," & $to_pos[1] & "]")
	Else
		WriteLog("Drag unable to find image " & $image, $v_exception)
	EndIf
EndFunc   ;==>DragImage