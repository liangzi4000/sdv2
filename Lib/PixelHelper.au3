#include-once
#include "../GlobalVariables.au3"
#include "PositionHelper.au3"
#include "Logger.au3"
#include "BasicActions.au3"

;~ Func WaitForPixel($pixinfo, $triggerclick = True)
;~ 	WriteLog("Waiting for pixel " & _ArrayToString($pixinfo))
;~ 	While 1
;~ 		Local $aCoord = PixelSearch($pixinfo[0], $pixinfo[1], $pixinfo[2], $pixinfo[3], $pixinfo[4])
;~ 		If Not @error Then
;~ 			WriteLog("Found pixel " & _ArrayToString($pixinfo))
;~ 			If $triggerclick = True Then
;~ 				MouseClick($MOUSE_CLICK_LEFT, $aCoord[0], $aCoord[1])
;~ 				WriteLog("Click on pixel " & _ArrayToString($pixinfo))
;~ 			EndIf
;~ 			ExitLoop
;~ 		EndIf
;~ 	WEnd
;~ EndFunc   ;==>WaitForPixel

;~ Func WaitForPixelVariant($pixinfo)
;~ 	WriteLog("Waiting for pixel " & _ArrayToString($pixinfo))
;~ 	While 1
;~ 		Local $aCoord = PixelSearch($pixinfo[0], $pixinfo[1], $pixinfo[2], $pixinfo[3], $pixinfo[4], $pixinfo[5])
;~ 		If Not @error Then
;~ 			WriteLog("Found pixel " & _ArrayToString($pixinfo))
;~ 			ExitLoop
;~ 		EndIf
;~ 	WEnd
;~ EndFunc   ;==>WaitForPixelVariant

;~ Func ClickPosUntilScreenByPixel($checkpoint, $clickx, $clicky, $interval = 300)
;~ 	Local $imagepath = $v_imagepath
;~ 	Local $y = 0, $x = 0
;~ 	WriteLog("Waiting for pixel [" & $checkpoint[0] & "," & $checkpoint[1] & "]=" & $checkpoint[2])
;~ 	While 1
;~ 		Local $search = Hex(PixelGetColor($checkpoint[0], $checkpoint[1]), 6)
;~ 		If $search = $checkpoint[2] Then
;~ 			WriteLog("Found pixel [" & $checkpoint[0] & "," & $checkpoint[1] & "]=" & $checkpoint[2])
;~ 			ExitLoop
;~ 		Else
;~ 			MouseClick($MOUSE_CLICK_LEFT, $clickx, $clicky)
;~ 		EndIf
;~ 		Sleep($interval)
;~ 	WEnd
;~ EndFunc   ;==>ClickPosUntilScreenByPixel

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

;~ Func WaitPixel($pixelinfo, $timeout = 20, $timeoutcall = "", $click = False)

;~ 	While 1
;~ 		If CheckPixel($pixelinfo) Then
;~ 			If $debug Then WriteLog("WaitPixel found " & _ArrayToString($pixelinfo))

;~ 			If $click Then

;~ 			EndIf

;~ 			ExitLoop
;~ 		EndIf
;~ 		Sleep(200)
;~ 	WEnd


;~ 	WriteLog("Waiting for pixel " & _ArrayToString($pixelinfo))
;~ 	While 1
;~ 		Local $aCoord = PixelSearch($pixelinfo[0], $pixelinfo[1], $pixelinfo[2], $pixelinfo[3], $pixelinfo[4])
;~ 		If Not @error Then
;~ 			WriteLog("Found pixel " & _ArrayToString($pixelinfo))
;~ 			If $triggerclick = True Then
;~ 				MouseClick($MOUSE_CLICK_LEFT, $aCoord[0], $aCoord[1])
;~ 				WriteLog("Click on pixel " & _ArrayToString($pixelinfo))
;~ 			EndIf
;~ 			ExitLoop
;~ 		EndIf
;~ 	WEnd
;~ EndFunc

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
