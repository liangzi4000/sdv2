#include-once
#include <Common.au3>
#include <Array.au3>

Global $firstrun = []
_ArrayAdd($firstrun,"OpenApp")
_ArrayAdd($firstrun,"StartScreen")
_ArrayAdd($firstrun,"MoveWindow")
_ArrayAdd($firstrun,"OpenLoginUI")
_ArrayAdd($firstrun,"ClickBtnLianDongZiLiang")
_ArrayAdd($firstrun,"ChooseUserIDLogin")
_ArrayAdd($firstrun,"GetNextRecord")
_ArrayAdd($firstrun,"Wrapper_EnterUIDandPWD_LianDong")
_ArrayAdd($firstrun,"Wrapper_StartScreen_DoItLater")
_ArrayAdd($firstrun,"Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")
;_ArrayAdd($firstrun,"CloseBPInfo")
_ArrayAdd($firstrun,"GetGift")
_ArrayAdd($firstrun,"PerformTask1")
_ArrayAdd($firstrun,"CheckExit")


Global $steps = []
_ArrayAdd($steps,"ClickMenuOthers")
_ArrayAdd($steps,"ClickBtnGameLink")
_ArrayAdd($steps,"ClickBtnLianDongZiLiangV2")
_ArrayAdd($steps,"ChooseUserIDLoginV2")
_ArrayAdd($steps,"GetNextRecord")
_ArrayAdd($steps,"Wrapper_EnterUIDandPWD_LianDongV2")
_ArrayAdd($steps,"Wrapper_StartScreen_DoItLater")
_ArrayAdd($steps,"Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")
;_ArrayAdd($steps,"CloseBPInfo")
_ArrayAdd($steps,"GetGift")
_ArrayAdd($steps,"PerformTask1")
_ArrayAdd($steps,"CheckExit")

Func ExecStep($index)
	For $x = 0 To UBound($v_windows)-1
		$activewindow = $v_windows[$x]
		If _ArraySearch($inactivewindows, $activewindow) <> -1 Then
			WriteLog("Skip execute "&$index&" for window "&$activewindow)
			ContinueLoop
		EndIf

		WinActivate($activewindow)
		WriteLog("Before execute "&$index)
		Call($index)
		WriteLog("After execute "&$index)
	Next
EndFunc

Func MoveWindow()
	Local $toolbarpos = GetHideToolBarPosition()
	Local $ctrlpos = GetCtrlPosition()
	ClickOn($toolbarpos)
	Sleep(500)
	If Not $winleftready Then
		WinMove($activewindow,"",0,0)
		$winleftready = True
		Sleep(500)
		Local $winleftheaderpos = [($ctrlpos[0]+$ctrlpos[2])/2,10]
		WinActivate($activewindow)
		ClickOn($winleftheaderpos)
	ElseIf Not $winrightready Then
		WinMove($activewindow,"",$ctrlpos[0]+$ctrlpos[2]+5,0)
		$winrightready = True
		Sleep(500)
		Local $winrightheaderpos = [($ctrlpos[0]+$ctrlpos[2])*3/2,10]
		WinActivate($activewindow)
		ClickOn($winrightheaderpos)
	EndIf
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
		AddArrayElem($inactivewindows,$activewindow)
	EndIf
EndFunc

Func ChooseUserIDLoginV2()
	If WaitImage("btn_close_switch.bmp") = 1 Then
		ClickOnRelative($btn_uidpwd)
	Else
		WriteLog("Uanble to find btn_close_switch.bmp",$v_exception)
		AddArrayElem($inactivewindows,$activewindow)
	EndIf
EndFunc
#EndRegion

Func GetNextRecord()
	Local $acctinfo = ExecDBQuery("[dbo].[SP_GetNextRecord] '"&$activewindow&"'")
	Assign("acctinfo"&$activewindow,$acctinfo,2)
	If Not IsValidResult($acctinfo) Then
		WriteLog("Invalid database record: " & $acctinfo, $v_exception)
		AddArrayElem($inactivewindows,$activewindow)
		CloseApp()
		Return False
	EndIf
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
	ClickPosUntilScreen($txt_uid,"btn_queding.bmp",800)
	SendPasteKeys(); 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(800)

	_ClipBoard_SetData($acctinfoarr[2]) ; 读取password到粘贴板
	ClickPosUntilScreen($txt_pwd,"btn_queding.bmp",800)
	SendPasteKeys(); 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(700)
EndFunc

Func ClickJueDing()
	ClickImage("btn_login_jueding.bmp",True)
EndFunc

Func JueDingTimeout()
	EnterUIDandPWD()
	ClickJueDing()
EndFunc

Func ClickJueDingV2()
	ClickImage("btn_login_jueding_v2.bmp",True)
EndFunc

Func JueDingTimeoutV2()
	EnterUIDandPWD()
	ClickJueDingV2()
EndFunc

Func LianDong()
	ClickImageUntilScreen("btn_liandong.bmp","btn_ok.bmp",900)
	ClickBtnOK()
EndFunc

Func LianDongV2()
	ClickImageUntilScreen("btn_liandong_v2.bmp","btn_ok_v2.bmp",900)
	ClickBtnOKV2()
EndFunc

Func ClickBtnOK()
	ClickImage("btn_ok.bmp",True)
EndFunc

Func ClickBtnOKV2()
	ClickImage("btn_ok_v2.bmp",True)
EndFunc
#EndRegion

#Region Wrapper_StartScreen_DoItLater
Func Wrapper_StartScreen_DoItLater()
	StartScreen()
	ClickOnStartScreen()
	DoItLater()
EndFunc

Func StartScreen()
	WaitImage("ui_startscreen.bmp",60)
EndFunc

Func ClickOnStartScreen()
	ClickImage("ui_startscreen.bmp",True)
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
	ClickImage("btn_close.bmp",True)
EndFunc

Func CloseBPInfo()
	ClickImage("btn_ok_bp.bmp",True)
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
	Local $pos = [0,0]
	Do
		Send("{PGUP}")
		Sleep(3000)
	Until SearchImage("app_icon_tasklist.bmp",$pos[0],$pos[1]) = 1
	Slide($pos[0],$pos[1],$pos[0],0)
EndFunc

Func GetGift()
	Local $acctinfo = Eval("acctinfo"&$activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	If $acctinfoarr[5] = 1 Then
		ClickPosUntilScreen($side_gift,"btn_back.bmp")
		Local $img = WaitImage("btn_getall_gifts.bmp,btn_getall_gifts_greyout.bmp")
		If $img = 1 Then
			ClickImage("btn_getall_gifts.bmp",True)
			ClickImage("btn_lingqu.bmp",True)
			ClickImage("btn_ok_lingqu.bmp",True)
		EndIf
	EndIf
EndFunc

Func PerformTask1()
	Local $acctinfo = Eval("acctinfo"&$activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	If $acctinfoarr[3] = 0 Then

	EndIf
EndFunc

Func CheckExit()
	If $exit Then Exit
EndFunc