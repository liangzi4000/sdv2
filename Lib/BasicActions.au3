#include-once
#include "../GlobalVariables.au3"
#include "Logger.au3"
#include "PositionHelper.au3"

Func ClickOn($pos)
	MouseClick($MOUSE_CLICK_LEFT, $pos[0], $pos[1], 1, 0)
	Assign($activewindow&$lastclickposition, $pos[0]&","&$pos[1], 2)
	If $debug Then WriteLog("ClickOn [" & $pos[0] & "," & $pos[1] & "]")
EndFunc   ;==>ClickOn

Func ClickOnRelative($pos)
	Local $targetpos = ConvertRelativePosToAbsolutePos($pos)
	ClickOn($targetpos)
	If $debug Then WriteLog("ClickOnRelative [" & $pos[0] & "," & $pos[1] & "]")
EndFunc   ;==>ClickOnRelative

Func ClickOnLastPosition()
	Local $pos = GetLastClickPosition()
	If $pos[0] = 0 And $pos[1] = 0 Then Return 0
	ClickOn($pos)
	If $debug Then WriteLog("ClickOnLastPosition [" & $pos[0] & "," & $pos[1] & "]")
	Return 1
EndFunc

Func SendPasteKeys()
	Sleep(100)
	Send("^v")
	If $debug Then WriteLog("Press Ctrl+V to paste")
EndFunc   ;==>SendPasteKeys

Func Slide($x1, $y1, $x2, $y2)
	MouseClickDrag($MOUSE_CLICK_LEFT, $x1, $y1, $x2, $y2)
	If $debug Then WriteLog("Slide from " & $x1 & "," & $y1 & " to " & $x2 & "," & $y2)
EndFunc   ;==>Slide

Func SlideRelative($x1, $y1, $x2, $y2)
	Local $start[2] = [$x1, $y1]
	Local $end[2] = [$x2, $y2]
	Local $start_conv = ConvertRelativePosToAbsolutePos($start)
	Local $end_conv = ConvertRelativePosToAbsolutePos($end)
	Slide($start_conv[0],$start_conv[1],$end_conv[0],$end_conv[1])
EndFunc

Func Drag($x1, $y1, $x2, $y2, $delay = 500)
	Local $defaultdelay = 250 ; autoit default delay is 250 milliseconds
	Opt("MouseClickDragDelay", $delay)
	MouseClickDrag($MOUSE_CLICK_LEFT, $x1, $y1, $x2, $y2)
	Opt("MouseClickDragDelay", $defaultdelay) ; restore to default
	If $debug Then WriteLog("Drag from " & $x1 & "," & $y1 & " to " & $x2 & "," & $y2)
EndFunc   ;==>Drag