#include-once
#include "../GlobalVariables.au3"

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

; Below function has been replaced with keyboard shortcut
;~ Func GetTaskListPosition()
;~ 	Local $winpos = GetWinPosition()
;~ 	Local $ctrlpos = GetCtrlPosition()
;~ 	Local $result[2] ;
;~ 	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlpos[2] + 16
;~ 	$result[1] = $winpos[1] + $ctrlpos[1] + 368
;~ 	Return $result
;~ EndFunc   ;==>GetTaskListPosition

Func GetHideToolBarPosition()
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlpos[2] + 16
	$result[1] = $winpos[1] + $ctrlpos[1] + 10
	Return $result
EndFunc   ;==>GetHideToolBarPosition

Func ConvertRelativePosToAbsolutePos($ctrlcoords)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlcoords[0]
	$result[1] = $winpos[1] + $ctrlpos[1] + $ctrlcoords[1]
	Return $result
EndFunc   ;==>ConvertRelativePosToAbsolutePos