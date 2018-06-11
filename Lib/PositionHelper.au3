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

Func GetOpenToolBarPosition()
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlpos[2] + 10
	$result[1] = $winpos[1] + $ctrlpos[1] + $ctrlpos[3]/2
	Return $result
EndFunc   ;==>GetOpenToolBarPosition

Func ConvertRelativePosToAbsolutePos($ctrlcoords)
	Local $winpos = GetWinPosition()
	Local $ctrlpos = GetCtrlPosition()
	Local $result[2] ;
	$result[0] = $winpos[0] + $ctrlpos[0] + $ctrlcoords[0]
	$result[1] = $winpos[1] + $ctrlpos[1] + $ctrlcoords[1]
	Return $result
EndFunc   ;==>ConvertRelativePosToAbsolutePos

Func GetLastClickPosition()
	Local $result[2] = [0,0]
	If IsDeclared($activewindow&$lastclickposition) Then
		Local $postr = Eval($activewindow&$lastclickposition)
		Local $pos = StringSplit($postr,",")
		If $pos[0] = 2 Then
			$result[0] = $pos[1]
			$result[1] = $pos[2]
		EndIf
	EndIf
	Return $result
EndFunc

Func GetLastImagePosition()
	Local $result[2] = [0,0]
	If IsDeclared($activewindow&$lastimageposition) Then
		Local $postr = Eval($activewindow&$lastimageposition)
		Local $pos = StringSplit($postr,",")
		If $pos[0] = 2 Then
			$result[0] = $pos[1]
			$result[1] = $pos[2]
		EndIf
	EndIf
	Return $result
EndFunc