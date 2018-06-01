#include-once
#include <Common.au3>
#include <Array.au3>

Global $firstrun = []
_ArrayAdd($firstrun,"OpenApp")
_ArrayAdd($firstrun,"StartScreen")
_ArrayAdd($firstrun,"OpenLoginUI")
_ArrayAdd($firstrun,"ClickBtnLianDongZiLiang")
_ArrayAdd($firstrun,"ChooseUserIDLogin")
_ArrayAdd($firstrun,"GetNextRecord")
_ArrayAdd($firstrun,"Wrapper_EnterUIDandPWD_LianDong")
_ArrayAdd($firstrun,"Wrapper_StartScreen_ClickOnCenter_DoItLater")
_ArrayAdd($firstrun,"Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")

Global $steps = []
_ArrayAdd($steps,"ClickMenuOthers")
_ArrayAdd($steps,"ClickBtnGameLink")
_ArrayAdd($steps,"ClickBtnLianDongZiLiangV2")
_ArrayAdd($steps,"ChooseUserIDLoginV2")
_ArrayAdd($steps,"GetNextRecord")
_ArrayAdd($steps,"Wrapper_EnterUIDandPWD_LianDongV2")
_ArrayAdd($steps,"Wrapper_StartScreen_ClickOnCenter_DoItLater")
_ArrayAdd($steps,"Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")

Func ExecStep($index)
	For $x = 0 To UBound($v_windows)-1
		$activewindow = $v_windows[$x]
		If _ArraySearch($inactivewindows, $activewindow) <> -1 Then ContinueLoop

		WinActivate($activewindow)
		WriteLog("Before execute "&$index)
		Call($index)
		WriteLog("After execute "&$index)
	Next
EndFunc

Func OpenApp()
	ClickImage("app_icon_home.bmp")
EndFunc

Func OpenLoginUI()
	ClickOnRelative($btn_liandong)
EndFunc

#Region ClickBtnLianDongZiLiang, ClickBtnLianDongZiLiangV2
Func ClickBtnLianDongZiLiang()
	ClickImage("btn_liandongziliao.bmp")
EndFunc

Func ClickBtnLianDongZiLiangV2()
	ClickImage("btn_liandongziliao_v2.bmp")
EndFunc
#EndRegion

#Region ChooseUserIDLogin, ChooseUserIDLoginV2
Func ChooseUserIDLogin()
	If WaitImage("btn_close_login.bmp") = 1 Then
		ClickOnRelative($btn_uidpwd)
	Else
		WriteLog("Uanble to find btn_close_login.bmp",$v_exception)
		_ArrayAdd($inactivewindows,$activewindow)
	EndIf
EndFunc

Func ChooseUserIDLoginV2()
	If WaitImage("btn_close_switch.bmp") = 1 Then
		ClickOnRelative($btn_uidpwd)
	Else
		WriteLog("Uanble to find btn_close_switch.bmp",$v_exception)
		_ArrayAdd($inactivewindows,$activewindow)
	EndIf
EndFunc
#EndRegion

Func GetNextRecord()
	Local $acctinfo = ExecDBQuery("[dbo].[SP_GetNextRecord] '"&$activewindow&"'")
	If Not IsValidResult($acctinfo) Then
		WriteLog("Invalid database record: " & $acctinfo, $v_exception)
		_ArrayAdd($inactivewindows,$activewindow)
		CloseApp()
		Return False
	EndIf
	Assign("acctinfo"&$activewindow,$acctinfo,2)
	Return True
EndFunc

#Region Wrapper_EnterUIDandPWD_LianDong, Wrapper_EnterUIDandPWD_LianDongV2
Func Wrapper_EnterUIDandPWD_LianDong()
	EnterUIDandPWD()
	ClickJueDing()
	LianDong()
EndFunc

Func Wrapper_EnterUIDandPWD_LianDongV2()
	EnterUIDandPWD()
	ClickJueDingV2()
	LianDongV2()
EndFunc

Func EnterUIDandPWD()
	Local $acctinfo = Eval("acctinfo"&$activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")

	_ClipBoard_SetData($acctinfoarr[1]) ; 读取UID到粘贴板
	ClickPosUntilScreen($txt_uid,"btn_queding.bmp")
	Local $textboxpos = GetImageCenterPos("btn_queding.bmp")
	$textboxpos[0] = $textboxpos[0] - 200
	ClickOn($textboxpos) ; Ensure curosr on textbox
	SendPasteKeys(); 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(500)

	_ClipBoard_SetData($acctinfoarr[2]) ; 读取password到粘贴板
	ClickPosUntilScreen($txt_pwd,"btn_queding.bmp")
	ClickOn($textboxpos) ; Ensure curosr on textbox
	SendPasteKeys(); 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(300)
EndFunc

Func ClickJueDing()
	ClickImage("btn_login_jueding.bmp",True)
EndFunc

Func ClickJueDingV2()
	ClickImage("btn_login_jueding_v2.bmp",True)
EndFunc

Func LianDong()
	ClickImageUntilScreen("btn_liandong.bmp","btn_ok.bmp")
	ClickBtnOK()
EndFunc

Func LianDongV2()
	ClickImageUntilScreen("btn_liandong_v2.bmp","btn_ok_v2.bmp")
	ClickBtnOKV2()
EndFunc

Func ClickBtnOK()
	ClickImage("btn_ok.bmp",True)
EndFunc

Func ClickBtnOKV2()
	ClickImage("btn_ok_v2.bmp",True)
EndFunc
#EndRegion

#Region Wrapper_StartScreen_ClickOnCenter_DoItLater
Func Wrapper_StartScreen_ClickOnCenter_DoItLater()
	StartScreen()
	ClickOnCenter()
	DoItLater()
EndFunc

Func StartScreen()
	If WaitImage("ui_startscreen.bmp") = 1 Then
	Else
		WriteLog("Uanble to find ui_startscreen.bmp",$v_exception)
		; To do on error handler
	EndIf
EndFunc

Func ClickOnCenter()
	Local $ctrlcenter = GetCtrlCenter()
	ClickOnRelative($ctrlcenter)
EndFunc

Func DoItLater()
	ClickImage("btn_doitlater.bmp",True)
EndFunc
#EndRegion

#Region Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin
Func Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin()
	ClickUntilNotification()
	CloseNotification()
	CompleteLogin()
EndFunc

Func ClickUntilNotification()
	ClickPosUntilScreen($btn_ignore,"btn_close.bmp")
EndFunc

Func CloseNotification()
	ClickImage("btn_close.bmp")
EndFunc

Func CompleteLogin()
	Local $acctinfo = Eval("acctinfo"&$activewindow)
	If $debug Then WriteLog($acctinfo)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	Local $uid = $acctinfoarr[1]
	If $debug Then WriteLog($uid)
	ExecDBQuery("[dbo].[SP_CompleteDailyTask] '"&$uid&"'")
EndFunc
#EndRegion

Func ClickMenuOthers()
	ClickImageUntilScreen("menu_others.bmp","btn_youxiziliaoliandong.bmp")
EndFunc

Func ClickBtnGameLink()
	ClickImageUntilScreen("btn_youxiziliaoliandong.bmp","btn_liandongziliao_v2.bmp")
EndFunc

Func CloseApp()
	Local $tasklistpos = GetTaskListPosition()
	ClickOn($tasklistpos)
	WaitImage("app_icon_tasklist.bmp")
	Local $pos = [0,0]
	SearchImage("app_icon_tasklist.bmp",$pos[0],$pos[1])
	Slide($pos[0],$pos[1],$pos[0],0)
EndFunc
