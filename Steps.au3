#include-once
#include <Common.au3>
#include <Array.au3>

Global $firstrun = []
_ArrayAdd($firstrun, "OpenApp")
_ArrayAdd($firstrun, "StartScreen")
_ArrayAdd($firstrun, "MoveWindow")
_ArrayAdd($firstrun, "OpenLoginUI")
_ArrayAdd($firstrun, "ClickBtnLianDongZiLiang")
_ArrayAdd($firstrun, "ChooseUserIDLogin")
_ArrayAdd($firstrun, "GetNextRecord")
_ArrayAdd($firstrun, "Wrapper_EnterUIDandPWD_LianDong")
_ArrayAdd($firstrun, "Wrapper_StartScreen_DoItLater")
_ArrayAdd($firstrun, "Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")
;_ArrayAdd($firstrun,"CloseBPInfo")
_ArrayAdd($firstrun, "GetGift")
_ArrayAdd($firstrun, "PerformTask1")
_ArrayAdd($firstrun, "CheckExit")


Global $steps = []
_ArrayAdd($steps, "ClickMenuOthers")
_ArrayAdd($steps, "ClickBtnGameLink")
_ArrayAdd($steps, "ClickBtnLianDongZiLiangV2")
_ArrayAdd($steps, "ChooseUserIDLoginV2")
_ArrayAdd($steps, "GetNextRecord")
_ArrayAdd($steps, "Wrapper_EnterUIDandPWD_LianDongV2")
_ArrayAdd($steps, "Wrapper_StartScreen_DoItLater")
_ArrayAdd($steps, "Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")
;_ArrayAdd($steps,"CloseBPInfo")
_ArrayAdd($steps, "GetGift")
_ArrayAdd($steps, "PerformTask1")
_ArrayAdd($steps, "CheckExit")



Func ExecStep($index)
	If $index = "" Then Return

	For $x = 0 To UBound($v_windows) - 1
		$activewindow = $v_windows[$x]
		If _ArraySearch($inactivewindows, $activewindow) <> -1 Then
			WriteLog("Skip execute " & $index & " for window " & $activewindow)
			ContinueLoop
		EndIf

		WinActivate($activewindow)
		WriteLog("Before execute " & $index)
		Call($index)
		WriteLog("After execute " & $index)
	Next
EndFunc   ;==>ExecStep

Func MoveWindow()
	Local $toolbarpos = GetHideToolBarPosition()
	Local $ctrlpos = GetCtrlPosition()
	ClickOn($toolbarpos)
	Sleep(500)
	If Not $winleftready Then
		WinMove($activewindow, "", 0, 0)
		$winleftready = True
		Sleep(500)
		Local $winleftheaderpos = [($ctrlpos[0] + $ctrlpos[2]) / 2, 10]
		WinActivate($activewindow)
		ClickOn($winleftheaderpos)
	ElseIf Not $winrightready Then
		WinMove($activewindow, "", $ctrlpos[0] + $ctrlpos[2] + 5, 0)
		$winrightready = True
		Sleep(500)
		Local $winrightheaderpos = [($ctrlpos[0] + $ctrlpos[2]) * 3 / 2, 10]
		WinActivate($activewindow)
		ClickOn($winrightheaderpos)
	EndIf
EndFunc   ;==>MoveWindow

Func OpenApp()
	ClickImage("app_icon_home.bmp")
EndFunc   ;==>OpenApp

Func OpenLoginUI()
	ClickOnRelative($btn_liandong)
EndFunc   ;==>OpenLoginUI

#Region ClickBtnLianDongZiLiang, ClickBtnLianDongZiLiangV2
Func ClickBtnLianDongZiLiang()
	ClickImage("btn_liandongziliao.bmp")
EndFunc   ;==>ClickBtnLianDongZiLiang

Func ClickBtnLianDongZiLiangV2()
	ClickImage("btn_liandongziliao_v2.bmp")
EndFunc   ;==>ClickBtnLianDongZiLiangV2
#EndRegion ClickBtnLianDongZiLiang, ClickBtnLianDongZiLiangV2

#Region ChooseUserIDLogin, ChooseUserIDLoginV2
Func ChooseUserIDLogin()
	If WaitImage("btn_close_login.bmp") = 1 Then
		ClickOnRelative($btn_uidpwd)
	Else
		WriteLog("Uanble to find btn_close_login.bmp", $v_exception)
		AddArrayElem($inactivewindows, $activewindow)
	EndIf
EndFunc   ;==>ChooseUserIDLogin

Func ChooseUserIDLoginV2()
	If WaitImage("btn_close_switch.bmp") = 1 Then
		ClickOnRelative($btn_uidpwd)
	Else
		WriteLog("Uanble to find btn_close_switch.bmp", $v_exception)
		AddArrayElem($inactivewindows, $activewindow)
	EndIf
EndFunc   ;==>ChooseUserIDLoginV2
#EndRegion ChooseUserIDLogin, ChooseUserIDLoginV2

Func GetNextRecord()
	Local $acctinfo = ExecDBQuery("[dbo].[SP_GetNextRecord] '" & $activewindow & "'")
	Assign("acctinfo" & $activewindow, $acctinfo, 2)
	If Not IsValidResult($acctinfo) Then
		WriteLog("GetNextRecord return invalid database record: " & $acctinfo, $v_exception)
		AddArrayElem($inactivewindows, $activewindow)
		CloseApp()
		Return False
	EndIf
	Return True
EndFunc   ;==>GetNextRecord

#Region Wrapper_EnterUIDandPWD_LianDong, Wrapper_EnterUIDandPWD_LianDongV2
Func Wrapper_EnterUIDandPWD_LianDong()
	EnterUIDandPWD()
	ClickJueDing()
	LianDong()
EndFunc   ;==>Wrapper_EnterUIDandPWD_LianDong

Func Wrapper_EnterUIDandPWD_LianDongV2()
	EnterUIDandPWD()
	ClickJueDingV2()
	LianDongV2()
EndFunc   ;==>Wrapper_EnterUIDandPWD_LianDongV2

Func EnterUIDandPWD()
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")

	_ClipBoard_SetData($acctinfoarr[1]) ; 读取UID到粘贴板
	ClickPosUntilScreen($txt_uid, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(800)

	_ClipBoard_SetData($acctinfoarr[2]) ; 读取password到粘贴板
	ClickPosUntilScreen($txt_pwd, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(700)
EndFunc   ;==>EnterUIDandPWD

Func ClickJueDing()
	ClickImage("btn_login_jueding.bmp", True)
EndFunc   ;==>ClickJueDing

Func JueDingTimeout()
	EnterUIDandPWD()
	ClickJueDing()
EndFunc   ;==>JueDingTimeout

Func ClickJueDingV2()
	ClickImage("btn_login_jueding_v2.bmp", True)
EndFunc   ;==>ClickJueDingV2

Func JueDingTimeoutV2()
	EnterUIDandPWD()
	ClickJueDingV2()
EndFunc   ;==>JueDingTimeoutV2

Func LianDong()
	ClickImageUntilScreen("btn_liandong.bmp", "btn_ok.bmp", 900)
	ClickBtnOK()
EndFunc   ;==>LianDong

Func LianDongV2()
	ClickImageUntilScreen("btn_liandong_v2.bmp", "btn_ok_v2.bmp", 900)
	ClickBtnOKV2()
EndFunc   ;==>LianDongV2

Func ClickBtnOK()
	ClickImage("btn_ok.bmp", True)
EndFunc   ;==>ClickBtnOK

Func ClickBtnOKV2()
	ClickImage("btn_ok_v2.bmp", True)
EndFunc   ;==>ClickBtnOKV2
#EndRegion Wrapper_EnterUIDandPWD_LianDong, Wrapper_EnterUIDandPWD_LianDongV2

#Region Wrapper_StartScreen_DoItLater
Func Wrapper_StartScreen_DoItLater()
	StartScreen()
	ClickOnStartScreen()
	DoItLater()
EndFunc   ;==>Wrapper_StartScreen_DoItLater

Func StartScreen()
	WaitImage("ui_startscreen.bmp", 600, "", False, $area_startscreen[0], $area_startscreen[1], $area_startscreen[2], $area_startscreen[3])
EndFunc   ;==>StartScreen

Func ClickOnStartScreen()
	ClickImage("ui_startscreen.bmp", True, 600, "", $area_startscreen[0], $area_startscreen[1], $area_startscreen[2], $area_startscreen[3])
EndFunc   ;==>ClickOnStartScreen

Func DoItLater()
	ClickImage("btn_doitlater.bmp", True)
EndFunc   ;==>DoItLater
#EndRegion Wrapper_StartScreen_DoItLater

#Region Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin
Func Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin()
	ClickUntilNotification()
	CloseNotification()
	CompleteLogin()
EndFunc   ;==>Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin

Func ClickUntilNotification()
	ClickPosUntilScreen($btn_ignore, "btn_close.bmp")
EndFunc   ;==>ClickUntilNotification

Func CloseNotification()
	ClickImage("btn_close.bmp", True)
EndFunc   ;==>CloseNotification

Func CloseBPInfo()
	ClickImage("btn_ok_bp.bmp", True)
EndFunc   ;==>CloseBPInfo

Func CompleteLogin()
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	If $debug Then WriteLog($acctinfo)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	Local $uid = $acctinfoarr[1]
	If $debug Then WriteLog($uid)
	ExecDBQuery("[dbo].[SP_CompleteDailyTask] '" & $uid & "'")
EndFunc   ;==>CompleteLogin
#EndRegion Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin

Func ClickMenuOthers()
	ClickImageUntilScreen("menu_others.bmp", "btn_youxiziliaoliandong.bmp")
EndFunc   ;==>ClickMenuOthers

Func ClickBtnGameLink()
	ClickImageUntilScreen("btn_youxiziliaoliandong.bmp", "btn_liandongziliao_v2.bmp")
EndFunc   ;==>ClickBtnGameLink

Func CloseApp()
	Local $pos = [0, 0]
	Do
		Send("{PGUP}")
		Sleep(1500)
	Until SearchImage("app_icon_tasklist.bmp", $pos[0], $pos[1]) = 1
	Slide($pos[0], $pos[1]+120, $pos[0], 0)
EndFunc   ;==>CloseApp

Func GetGift()
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	If $acctinfoarr[5] = 1 Then
		ClickPosUntilScreen($side_gift, "btn_back.bmp")
		Local $img = WaitImage("btn_getall_gifts.bmp,btn_getall_gifts_greyout.bmp")
		If $img = 1 Then
			ClickImage("btn_getall_gifts.bmp", True)
			ClickImage("btn_lingqu.bmp", True)
			ClickImage("btn_ok_lingqu.bmp", True)
		EndIf
	EndIf
EndFunc   ;==>GetGift

Func PerformTask1()
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	If $acctinfoarr[3] = 0 Then
		ClickImage("menu_card.bmp",True) ; 点击卡片菜单
		Sleep(500)
		ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
		ClickImage("ui_zhidingxilie.bmp") ; 选择 指定系列
;~ 		Sleep(300)
;~ 		ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
;~ 		ClickImage("ui_zhidingxilie.bmp") ; 选择 指定系列
		Sleep(800)
		WaitImage("btn_back.bmp")
		ClickOnRelative($btn_createcombination) ; 点击 创建新牌组
		ClickImage("btn_zidongbianji.bmp"); 点击 自动编辑
		Sleep(300)
		ClickPosUntilScreen($btn_zhuzhanzhe_confirm,"btn_save.bmp") ; 点击决定
		ClickImage("btn_save.bmp")
		ClickImage("btn_jueding_bianjicard.bmp")
		Sleep(500)
		ClickImage("btn_ok_card_saved.bmp")
		Sleep(500)
		ClickImage("btn_ok_fight_effect.bmp")

		ClickImage("menu_single_mode.bmp")
		Sleep(3000)
		ClickOnRelative($opt_zhuxian) ; 点击 主线剧情
		WaitImage("btn_back.bmp")
		ClickOnRelative($btn_zhuzhanzhe_confirm) ; 点击决定
		ClickImage("ui_1st_chapter_task1.bmp")
		ClickImage("btn_qianwangjuqing.bmp")
		ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp") ;忽略
		ClickImage("btn_ignore.bmp")
		ClickImage("btn_ok_fight_effect.bmp")
		ClickImage("btn_fight_option.bmp")
		ClickImage("btn_giveup.bmp")
		ClickImage("btn_giveup_confirm.bmp")
		Sleep(500)
	 	ClickImage("btn_ok_fight_effect.bmp")
	 	ExecDBQuery("[dbo].[SP_CompleteTask1] "&$acctinfoarr[4])
		ClickImage("btn_choosechapter.bmp")
		ClickImage("btn_back.bmp")
	EndIf
EndFunc   ;==>PerformTask1

Func CheckExit()
	If $exit Then Exit
EndFunc   ;==>CheckExit
