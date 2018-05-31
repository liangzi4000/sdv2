#include-once
#include <GlobalVariables.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <File.au3>
#include <Date.au3>
#include <Clipboard.au3>
#include <Array.au3>
#include "Lib\ImageSearch.au3" ;this is a third party library
#include <Logger.au3>
#include <Email.au3>
#include <Database.au3>
#include <CaptureScreenshot.au3>

Func WaitForImage($image, $triggerclick = False, $clicks = 1, $speed = 10, $timeoutcall = "")
	Sleep(200)
	Local $imagepath = $v_imagepath
	Local $y = 0, $x = 0
	Local $list = []
	Local $found = 0
	If VarGetType($image) = "String" Then
		_ArrayAdd($list, $image)
	EndIf
	If VarGetType($image) = "Array" Then
		For $i = 0 To UBound($image) - 1
			_ArrayAdd($list, $image[$i])
		Next
	EndIf
	WriteLog("Waiting for image " & $imagepath & _ArrayToString($list))
	Local $count = 50 ; 10 seconds = 50 * 200 million seconds
	While ($count > 0 Or $timeoutcall = "")
		For $i = 1 To UBound($list) - 1
			Local $search = _ImageSearch($imagepath & $list[$i], 1, $x, $y, 0)
			If $search = 1 Then
				WriteLog("Found image " & $imagepath & $list[$i])
				If $triggerclick = True Then
					MouseClick($MOUSE_CLICK_LEFT, $x, $y, $clicks)
					WriteLog("Click on image " & $imagepath & $list[$i])
				EndIf
				$found = $i
				ExitLoop
			EndIf
		Next
		If $found > 0 Then ExitLoop
		Sleep(200)
		$count = $count - 1
	WEnd
	If $count <= 0 And $timeoutcall <> "" Then
		WriteLog("Timeout - Waiting for image " & $imagepath & _ArrayToString($list))
		Call($timeoutcall)
		Call("WaitForImage", $image, $triggerclick, $clicks, $speed, $timeoutcall)
	EndIf
	Return $found - 1
EndFunc   ;==>WaitForImage

Func CheckImage($image, $file = "")
	WriteLog("Check image " & $image, $file)
	Local $imagepath = $v_imagepath
	Local $y = 0, $x = 0
	Return _ImageSearch($imagepath & $image, 1, $x, $y, 0) ; return 1 or 0
EndFunc   ;==>CheckImage

Func WaitForImageTimeout($image, $timeoutcall, $triggerclick = False)
	WaitForImage($image, $triggerclick, 1, 10, $timeoutcall)
EndFunc   ;==>WaitForImageTimeout

Func WaitForPixel($pixinfo, $triggerclick = True)
	WriteLog("Waiting for pixel " & _ArrayToString($pixinfo))
	While 1
		Local $aCoord = PixelSearch($pixinfo[0], $pixinfo[1], $pixinfo[2], $pixinfo[3], $pixinfo[4])
		If Not @error Then
			WriteLog("Found pixel " & _ArrayToString($pixinfo))
			If $triggerclick = True Then
				MouseClick($MOUSE_CLICK_LEFT, $aCoord[0], $aCoord[1])
				WriteLog("Click on pixel " & _ArrayToString($pixinfo))
			EndIf
			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>WaitForPixel

Func WaitForPixelVariant($pixinfo)
	WriteLog("Waiting for pixel " & _ArrayToString($pixinfo))
	While 1
		Local $aCoord = PixelSearch($pixinfo[0], $pixinfo[1], $pixinfo[2], $pixinfo[3], $pixinfo[4], $pixinfo[5])
		If Not @error Then
			WriteLog("Found pixel " & _ArrayToString($pixinfo))
			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>WaitForPixelVariant

Func ClickPosUntilScreenByPixel($checkpoint, $clickx, $clicky, $interval = 300)
	Local $imagepath = $v_imagepath
	Local $y = 0, $x = 0
	WriteLog("Waiting for pixel [" & $checkpoint[0] & "," & $checkpoint[1] & "]=" & $checkpoint[2])
	While 1
		Local $search = Hex(PixelGetColor($checkpoint[0], $checkpoint[1]), 6)
		If $search = $checkpoint[2] Then
			WriteLog("Found pixel [" & $checkpoint[0] & "," & $checkpoint[1] & "]=" & $checkpoint[2])
			ExitLoop
		Else
			MouseClick($MOUSE_CLICK_LEFT, $clickx, $clicky)
		EndIf
		Sleep($interval)
	WEnd
EndFunc   ;==>ClickPosUntilScreenByPixel

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Region Position Helper
Func GetWinPosition()
	Return WinGetPos($activewindow)
EndFunc   ;==>GetWinPosition

Func GetCtrlPosition()
	Return ControlGetPos($activewindow, "", $v_winctrlclassname)
EndFunc   ;==>GetCtrlPosition

Func GetCtrlCenter()
	Local $ctrl = GetCtrlPosition()
	Local $result[2] = [$ctrl[2] / 2, $ctrl[3] / 2]
	Return $result
EndFunc   ;==>GetCtrlCenter

Func GetTaskListPosition()
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlpos[2] + 16
	$result[1] = $winpos[1] + $ctrlpos[1] + 368
	Return $result
EndFunc   ;==>GetTaskListPosition

Func ConvertControlCoordsToWindowPosition($ctrlcoords)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlcoords[0]
	$result[1] = $winpos[1] + $ctrlpos[1] + $ctrlcoords[1]
	Return $result
EndFunc   ;==>ConvertControlCoordsToWindowPosition
#EndRegion Position Helper

#Region Fundamental Operation (e.g ClickOn, SearchImage, SendPasteKeys, Slide, Drag)
Func ClickOn($pos)
	MouseClick($MOUSE_CLICK_LEFT, $pos[0], $pos[1], 1, 0)
	If $debug Then WriteLog("ClickOn [" & $pos[0] & "," & $pos[1] & "]")
EndFunc   ;==>ClickOn

Func ClickOnConvert($pos)
	Local $targetpos = ConvertControlCoordsToWindowPosition($pos)
	ClickOn($targetpos)
	If $debug Then WriteLog("ClickOnConvert [" & $pos[0] & "," & $pos[1] & "]")
EndFunc   ;==>ClickOnConvert

#comments-start
	The $x and $y are absolute screen coordinates, no need to convert
	Todo: set PixelCoordMode to return relative coords to defined window
#comments-end
Func SearchImage($image, ByRef $x, ByRef $y, $tolerance=20, $HBMP=0)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $area[4]
	$area[0] = $winpos[0] + $ctrlpos[0]
	$area[1] = $winpos[1] + $ctrlpos[1]
	$area[2] = $area[0] + $ctrlpos[2]
	$area[3] = $area[1] + $ctrlpos[3]
	Local $result = _ImageSearchArea($v_imagepath & $image, 1, $area[0], $area[1], $area[2], $area[3], $x, $y, $tolerance, $HBMP)
	If $debug Then WriteLog("SearchImage search " & $image & ", result:" & $result)
	Return $result ; return 1 or 0
EndFunc   ;==>SearchImage

Func SendPasteKeys()
	Send("^v")
	If $debug Then WriteLog("Press Ctrl+V to paste")
EndFunc   ;==>SendPasteKeys

Func Slide($x1, $y1, $x2, $y2)
	MouseClickDrag($MOUSE_CLICK_LEFT, $x1, $y1, $x2, $y2)
	If $debug Then WriteLog("Slide from " & $x1 & "," & $y1 & " to " & $x2 & "," & $y2)
EndFunc   ;==>Slide

Func Drag($x1, $y1, $x2, $y2, $delay = 500)
	Opt("MouseClickDragDelay",$delay)
	MouseClickDrag($MOUSE_CLICK_LEFT, $x1, $y1, $x2, $y2)
	Opt("MouseClickDragDelay",250) ; restore to default 250 milliseconds
	If $debug Then WriteLog("Drag from " & $x1 & "," & $y1 & " to " & $x2 & "," & $y2)
EndFunc   ;==>Drag
#EndRegion Fundamental Operation (e.g ClickOn, SearchImage, SendPasteKeys, Slide)

#Region Advanced Image Operation
;Return 1: clicked; 0: not click due to time out
Func ClickImage($image, $sureclick = False, $timeout = 20, $timeoutcall = "")
	If Not $sureclick Then
		If WaitImage($image, $timeout, $timeoutcall, True) = 1 Then
			If $debug Then WriteLog("ClickImage clicked on image " & $image)
			Return 1
		Else
			WriteLog("ClickImage unable to find image " & $image, $v_exception)
			Return 0
		EndIf
	EndIf

	If WaitImage($image) = 1 Then
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

;Return 1: found; 0: not found due to time out
Func WaitImage($image, $timeout = 20, $timeoutcall = "", $click = False)
	Local $hTimer = TimerInit()
	Local $pos = [0, 0]
	While SearchImage($image, $pos[0], $pos[1]) = 0
		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("WaitImage time out after " & $timeout & " seconds waiting for image " & $image & ", $timeoutcall=" & $timeoutcall, $v_exception)
			If $timeoutcall <> "" Then Call($timeoutcall)
			Return 0
		EndIf
		Sleep(200)
	WEnd
	If $debug Then WriteLog("WaitImage found image " & $image)
	If $pos[0] <> 0 And $pos[1] <> 0 Then
		If $click Then ClickOn($pos)
		Return 1
	EndIf
	Return 0
EndFunc   ;==>WaitImage

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

Func ClickPosUntilScreen($pos, $untilimage, $interval = 700, $timeout = 20, $timeoutcall = "", $convertposition = True)
	Local $mypos = $convertposition = True ? ConvertControlCoordsToWindowPosition($pos) : $pos
	Local $x = 0, $y = 0
	Local $hTimer = TimerInit()
	While SearchImage($untilimage, $x, $y) = 0
		If TimerDiff($hTimer) > $timeout * 1000 Then
			WriteLog("ClickPosUntilScreen time out after " & $timeout & " seconds waiting for image " & $untilimage & ", $timeoutcall=" & $timeoutcall, $v_exception)
			If $timeoutcall <> "" Then Call($timeoutcall)
			Return 0
		EndIf
		ClickOn($mypos)
		Sleep($interval)
	WEnd
	If $debug Then WriteLog("ClickPosUntilScreen found image " & $untilimage)
	Return 1
EndFunc   ;==>ClickPosUntilScreen

Func DragImage($image, $to_x, $to_y)
	If WaitImage($image) = 1 Then
		Local $pos = [0, 0]
		SearchImage($image, $pos[0], $pos[1])
		Drag($pos[0], $pos[1], $to_x, $to_y)
;~ 		MouseMove($pos[0], $pos[1], 0)
;~ 		MouseDown($MOUSE_CLICK_LEFT)
;~ 		Sleep(500)
;~ 		MouseMove($to_x, $to_y)
;~ 		MouseUp($MOUSE_CLICK_LEFT)
		If $debug Then WriteLog("Drag image " & $image & " to [" & $to_x & "," & $to_y & "]")
	Else
		WriteLog("Drag unable to find image " & $image, $v_exception)
	EndIf
EndFunc   ;==>Drag
#EndRegion Advanced Image Operation

#Region Advanced Pixel Operation
#comments-start
	Check if specified pixel exist
	return True or False
	$pixelinfo sample:
	[120,120,210,210,0xefefef,10]
#comments-end
Func CheckPixel($pixelinfo)
	Local $aCoord = PixelSearch($pixelinfo[0], $pixelinfo[1], $pixelinfo[2], $pixelinfo[3], $pixelinfo[4], $pixelinfo[5], 1, WinGetHandle($activewindow))
	If Not @error Then
		If $debug Then WriteLog("CheckPixel found " & _ArrayToString($pixelinfo))
		Return True
	Else
		If $debug Then WriteLog("CheckPixel unable to find " & _ArrayToString($pixelinfo))
		Return False
	EndIf
EndFunc   ;==>CheckPixel

#comments-start
	Determine which pixel exist given an array of pixels
	return the found pixel index or -1 if not found, default time out is 1 second
	$pixellist sample:
	[[120,120,210,210,0xefefef,10],[128,128,232,232,0x989898,10]]
#comments-end
Func DeterminePixel($pixellist, $timeout = 1)
	Local $sleepinterval = 500
	Local $count = 0
	While 1
		Local $found = -1
		For $i = 0 To UBound($pixellist) - 1
			Local $currentitem = $pixellist[$i]
			If CheckPixel($currentitem) Then
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
#EndRegion Advanced Pixel Operation

#Region Misc Helper
Func MutexExists($sOccurenceName)
	Local $ERROR_ALREADY_EXISTS = 183, $handle, $lastError
	$sOccurenceName = StringReplace($sOccurenceName, "\", "") ; to avoid error
	$handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", $sOccurenceName)
	$lastError = DllCall("kernel32.dll", "int", "GetLastError")
	Return $lastError[0] = $ERROR_ALREADY_EXISTS
EndFunc   ;==>MutexExists

#comments-start
	Copy const array $arr2 to array $arr1
#comments-end
Func CopyArrayData(ByRef $arr1, Const ByRef $arr2)
	For $i = 0 To UBound($arr1) - 1
		$arr1[$i] = $arr2[$i]
	Next
EndFunc   ;==>CopyArrayData
#EndRegion Misc Helper
