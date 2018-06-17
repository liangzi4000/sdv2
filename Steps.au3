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
_ArrayAdd($firstrun, "CheckMoneyBefore")
_ArrayAdd($firstrun, "GetGift")
_ArrayAdd($firstrun, "PerformTask1")
_ArrayAdd($firstrun, "CreateOrEnterFightRoom")
_ArrayAdd($firstrun, "WaitForFightStart")
_ArrayAdd($firstrun, "HandleChangeCards")
_ArrayAdd($firstrun, "ProcessFight")
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
_ArrayAdd($steps, "CheckMoneyBefore")
_ArrayAdd($steps, "GetGift")
_ArrayAdd($steps, "PerformTask1")
_ArrayAdd($steps, "CreateOrEnterFightRoom")
_ArrayAdd($steps, "WaitForFightStart")
_ArrayAdd($steps, "HandleChangeCards")
_ArrayAdd($steps, "ProcessFight")
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
		Local $winpos = GetWinPosition()
		WinMove($activewindow, "", @DesktopWidth-$winpos[2], 0)
		$winrightready = True
		Sleep(500)
		Local $winrightheaderpos = [@DesktopWidth-$winpos[2]/2, 10]
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
	WaitImage("btn_close_login.bmp")
	ClickOnRelative($btn_uidpwd)
EndFunc   ;==>ChooseUserIDLogin

Func ChooseUserIDLoginV2()
	WaitImage("btn_close_switch.bmp")
	ClickOnRelative($btn_uidpwd)
EndFunc   ;==>ChooseUserIDLoginV2
#EndRegion ChooseUserIDLogin, ChooseUserIDLoginV2

Func GetNextRecord()
	Local $acctinfo = ""
	Local $result = False
	Local $siblingloginid = 0
	If Not IsFightHost() Then
		SwitchWindow(True)
		$siblingloginid = GetAccountInfo("uid")
		If Not IsNumber($siblingloginid) Then $siblingloginid = 0
		SwitchWindow(False)
	EndIf

	For $x = 1 To 5
		$acctinfo = ExecDBQuery("[dbo].[SP_GetNextRecord] '" & $activewindow & "',"&$siblingloginid)
		If $acctinfo = "End" Then
			WriteLog("Reach end of database, close window.")
			AddArrayElem($inactivewindows, $activewindow)
			CloseApp()
			$result = True
			ExitLoop
		ElseIf IsValidResult($acctinfo) Then
			WriteLog("$acctinfo = "&$acctinfo)
			$result = True
			ExitLoop
		Else
			WriteLog("GetNextRecord return invalid database record: " & $acctinfo, $v_exception)
			Sleep(10000)
		EndIf
	Next
	Assign("acctinfo" & $activewindow, $acctinfo, 2)

	If Not $result Then
		WriteLog("Failed to connnect to database after 5 times retry, close window.", $v_exception)
		AddArrayElem($inactivewindows, $activewindow)
		CloseApp()
	EndIf

	Return $result
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
	_ClipBoard_SetData(GetAccountInfo("uid")) ; 读取UID到粘贴板
	ClickPosUntilScreen($txt_uid, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(800)

	_ClipBoard_SetData(GetAccountInfo("pwd")) ; 读取password到粘贴板
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
	Local $index = WaitImage("btn_doitlater.bmp,btn_nox_forever.bmp")
	If $index = 2 Then
		ClickImage("btn_nox_forever.bmp")
		ClickImage("btn_nox_reject.bmp")
	EndIf
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
	Local $uid = GetAccountInfo("uid")
	If $debug Then WriteLog($uid & "completed login")
	ExecDBQuery("[dbo].[SP_CompleteDailyTask] '" & $uid & "'")
EndFunc   ;==>CompleteLogin
#EndRegion Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin

Func ClickMenuOthers()
	;ClickImageUntilScreen("menu_others_v2.bmp", "btn_youxiziliaoliandong.bmp")
	ClickPosUntilScreen($menu_other,"btn_youxiziliaoliandong.bmp")
EndFunc   ;==>ClickMenuOthers

Func ClickBtnGameLink()
	ClickImageUntilScreen("btn_youxiziliaoliandong.bmp", "btn_liandongziliao_v2.bmp")
EndFunc   ;==>ClickBtnGameLink

Func CloseApp()
	Local $pos = [0, 0]
	Do
		Send("{PGUP}")
		Sleep(3000)
	Until SearchImage("app_icon_tasklist.bmp", $pos[0], $pos[1]) = 1
	Slide($pos[0], $pos[1]+120, $pos[0], 0)
	Sleep(2000)
	Local $toolbarpos = GetOpenToolBarPosition()
	ClickOn($toolbarpos)
EndFunc   ;==>CloseApp

Func GetGift()
	If GetAccountInfo("gift") = 1 Then
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
	If GetAccountInfo("task1") = 0 Then
		ClickImage("menu_card.bmp",True) ; 点击卡片菜单
		Sleep(500)
		ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
		Sleep(500)
		Local $mypos = [0,0]
		If SearchImage("ui_zhidingxilie.bmp",$mypos[0],$mypos[1]) = 0 Then
			ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
		EndIf
		ClickImage("ui_zhidingxilie.bmp")
		Sleep(800)
		WaitImage("btn_back.bmp")
		ClickOnRelative($btn_createcombination) ; 点击 创建新牌组
		ClickImage("btn_zidongbianji.bmp"); 点击 自动编辑
		Sleep(300)
		ClickPosUntilScreen($btn_zhuzhanzhe_confirm,"btn_save.bmp") ; 点击决定
		ClickImage("btn_save.bmp")
		ClickImage("btn_jueding_bianjicard.bmp")
		Sleep(1000)
		ClickImage("btn_ok_card_saved.bmp")
		Sleep(1000)
		ClickImage("btn_ok_fight_effect.bmp")
		Sleep(1000)
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
		Sleep(1000)
		ClickImage("btn_giveup_confirm.bmp")
		Sleep(1000)
	 	ClickImage("btn_ok_fight_effect.bmp")
	 	ExecDBQuery("[dbo].[SP_CompleteTask1] "&GetAccountInfo("acct"))
		ClickImage("btn_choosechapter.bmp")
		ClickImage("btn_back.bmp")
	EndIf
EndFunc   ;==>PerformTask1

Func CheckExit()
	If $exit Then Exit
EndFunc   ;==>CheckExit

Func RunScript()
	Run(@ScriptDir&"\Surrogate.exe")
EndFunc

#Region Fight Functions
#comments-start
; PC name end with odd number is host
; PC name end with even number is guest
#comments-end
Func CreateOrEnterFightRoom()
	If Not IsFightAllow() Then Return
	ClickPosUntilScreenByPixel($meu_duizhan,$opt_privatefight) ;点击 对战
	ClickOnRelative($opt_privatefight) ;点击 私人对战
	If IsFightHost() Then
		ClickImage("sdv_fight_duizhan.bmp") ; 建立对战室
		ClickImage("sdv_fight_normalfight.bmp") ; 一般对战
		ClickImage("sdv_button_jianliduizhanshi.bmp") ; 点击 建立对战室 按钮
	Else
		ClickImage("sdv_fight_jinruduizhan.bmp") ; 进入对战室
		Sleep(500)
		Local $roomnumber = StringSplit($fightroomnumber,"")
		For $i = 1 To UBound($roomnumber)-1
			Local $number = Number($roomnumber[$i])
			Local $numpos[2] = [$btn_number[$number][0],$btn_number[$number][1]]
			ClickOnRelative($numpos)
			Sleep(100)
		Next
		ClickImage("sdv_button_jueding_room.bmp") ; 决定
	EndIf
	ClickImage("sdv_button_xuanzepaizu.bmp") ; 点击 选择牌组 按钮
	ClickImage("sdv_card_jingling.bmp",True) ; 选择精灵
	ClickImage("sdv_button_card_ok.bmp") ; OK
	Sleep(500)
	If IsFightHost() Then
		Local $room_abs = GetAbsoluteRoomCoord($v_room)
		_ScreenCapture_Capture($v_room_screenshot,$room_abs[0],$room_abs[1],$room_abs[2],$room_abs[3])
		ShellExecuteWait($v_tesseractfile,$v_room_screenshot&" "&$v_room_file&" -psm 7")
		$fightroomnumber = StringStripWS(FileReadLine($v_room_file&".txt",1),8)
	EndIf
EndFunc

Func WaitForFightStart()
	If Not IsFightAllow() Then Return
	ClickPixel($btn_readytofight) ; 等待准备完毕
EndFunc

Func HandleChangeCards()
	If Not IsFightAllow() Then Return
	ClickPixel($btn_changecard) ; 决定
EndFunc

Func ProcessFight()
	If Not IsFightAllow() Then Return
	; Execute this function for first window only, skip for second window
	If $skipsecondwindowexecution Then
		SecondWindowExitFight()
		ConsoleWrite("Fight completed"&@CRLF)
		$skipsecondwindowexecution = False
		Return
	EndIf
	$skipsecondwindowexecution = True

	Local $fightctrlbtns = [$btn_waitforfight,$btn_confirmfight] 			; List of fight buttons
	Local $attackfirst = DeterminePixel($fightctrlbtns) = 1 ? True : False	; 是否先攻
	Local $clickcount = 0 													; No of times click on 结束回合
	Local $isfirstwindow = $attackfirst ? True : False						; Is first window active
	Local $cardsinbattlecount = 0											; No of cards in battle area
	Local $iscardsready = False
	Local $jinhuastatus[3] = [False,False,False]							; Store if card jinhua

	While 1
		SwitchWindow($isfirstwindow)
		WaitPixel($btn_confirmfight)

		If $isfirstwindow And $clickcount >= 5 Then
			ConsoleWrite("$clickcount:"&$clickcount&@CRLF)
			If Not $iscardsready Then
				$iscardsready = True
				ClickOnRelative($cardready)
				Sleep(1000)
			EndIf

			If $cardsinbattlecount < 5 Then
				; Find one card in ready area and move it to battle area
				Local $foundcard = False
				For $x = 0 To UBound($readycards)-1
					Local $currentcard = $readycards[$x]
					Local $pixelresult = SearchPixel($currentcard)
					If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
						ConsoleWrite("found card: "&$x&@CRLF)
						SlideRelative($currentcard[0]+10,$currentcard[1]-25,$currentcard[0]+10,$currentcard[1]-200)
						$cardsinbattlecount = $cardsinbattlecount + 1
						$foundcard = True
						ExitLoop
					Else
						ConsoleWrite("cannot find card: "&$x&@CRLF)
					EndIf
				Next
				If Not $foundcard Then $iscardsready = False
				Sleep(1500)
			EndIf

			If $cardsinbattlecount > 0 Then
				Local $cardsinbattle[$cardsinbattlecount]
				Switch $cardsinbattlecount
					Case 1
						$cardsinbattle[0] = $cardodds[2]
						If Not $jinhuastatus[0] Then
							$jinhuastatus[0] = True
							Local $currentcard = $cardsinbattle[0]
							JinHua($currentcard)
						EndIf
					Case 2
						$cardsinbattle[0] = $cardevens[1]
						$cardsinbattle[1] = $cardevens[2]
						If Not $jinhuastatus[1] Then
							$jinhuastatus[1] = True
							Local $currentcard = $cardsinbattle[1]
							JinHua($currentcard)
						EndIf
					Case 3
						$cardsinbattle[0] = $cardodds[1]
						$cardsinbattle[1] = $cardodds[2]
						$cardsinbattle[2] = $cardodds[3]
						If Not $jinhuastatus[2] And Not $attackfirst Then
							$jinhuastatus[2] = True
							Local $currentcard = $cardsinbattle[2]
							JinHua($currentcard)
						EndIf
					Case 4
						$cardsinbattle[0] = $cardevens[0]
						$cardsinbattle[1] = $cardevens[1]
						$cardsinbattle[2] = $cardevens[2]
						$cardsinbattle[3] = $cardevens[3]
					Case 5
						$cardsinbattle[0] = $cardodds[0]
						$cardsinbattle[1] = $cardodds[1]
						$cardsinbattle[2] = $cardodds[2]
						$cardsinbattle[3] = $cardodds[3]
						$cardsinbattle[4] = $cardodds[4]
				EndSwitch

				For $x = 0 To UBound($cardsinbattle)-1
					If $x = UBound($cardsinbattle)-1 And $cardsinbattlecount < 5 Then ContinueLoop
					Local $card = $cardsinbattle[$x]
					SlideRelative($card[0]-$v_battle_card_x_offset,$card[1],$enemypos[0],$enemypos[1])
					Sleep(300)
				Next
			EndIf
		EndIf

		If $isfirstwindow Then
			Local $index = WaitImage("btn_ok_fight_effect.bmp,btn_back.bmp,btn_confirmfight.bmp")
			If $index = 3 Then
				ConsoleWrite("Found confirm fight"&@CRLF)
				;ClickOnRelative($btn_confirmfight)
				ClickImage("btn_confirmfight.bmp",True)
				$clickcount = $clickcount + 1
			Else
				ConsoleWrite("Waiting for btn_back.bmp"&@CRLF)
				If $index = 1 Then
					; Close the popup window if exists
					ClickImage("btn_ok_fight_effect.bmp")
					Sleep(300)
				EndIf
				WaitImage("btn_back.bmp")
				ClickImage("menu_single_mode.bmp")
				ClickImage("btn_jiesan.bmp")
				ExitLoop
			EndIf
		Else
			ClickOnRelative($btn_confirmfight)
		EndIf

		$isfirstwindow = Not $isfirstwindow
	WEnd
EndFunc

Func SecondWindowExitFight()
	ClickImage("btn_ok_beginner.bmp") ; 点击 ok
	Local $rivalloginid = GetAccountInfo("uid")
	SwitchWindow(True)
	Local $hostloginid = GetAccountInfo("uid")
	SwitchWindow(False)
	ExecDBQuery("[dbo].[SP_CompletePYFight] "&$hostloginid&","&$rivalloginid&","&$fightroomnumber)
EndFunc

Func JinHua($card)
	Sleep(2000)
	ConsoleWrite("Click on card to jinhua"&@CRLF)
	ClickOnRelative($card)
	Sleep(1000)
	ClickImage("btn_jinhua.bmp,btn_jinhua_v2.bmp,btn_jinhua_v3.bmp",True)
	WaitPixel($btn_confirmfight)
EndFunc

Func SwitchWindow($isfirstwindow)
	If $isfirstwindow Then
		$activewindow = $v_windows[0]
	Else
		$activewindow = $v_windows[1]
	EndIf
	WinActivate($activewindow)
EndFunc

Func GetAbsoluteRoomCoord($v_room)
	Local $leftpoint[2] = [$v_room[0],$v_room[1]]
	Local $rightpoint[2] = [$v_room[2],$v_room[3]]
	Local $leftpoint_abs = ConvertRelativePosToAbsolutePos($leftpoint)
	Local $rightpoint_abs = ConvertRelativePosToAbsolutePos($rightpoint)
	Local $result[4] = [$leftpoint_abs[0],$leftpoint_abs[1],$rightpoint_abs[0],$rightpoint_abs[1]]
	Return $result
EndFunc

#comments-start
Check if fight is allowed
#comments-end
Func IsFightAllow()
	If GetAccountInfo("fight") = 1 And UBound($v_windows) = 2 Then Return True
	Return False
EndFunc

Func IsFightHost()
	Local $number = StringRight($activewindow,2)
	If $number = "" Then Return False
	If Mod($number,2) = 1 Then
		Return True
	Else
		Return False
	EndIf
EndFunc
#EndRegion

#Region Account Info Helper
Func GetAccountInfo($type)
	Local $result = ""
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")

	Switch $type
		Case "uid"
			$result = $acctinfoarr[1]
		Case "pwd"
			$result = $acctinfoarr[2]
		Case "task1"
			$result = $acctinfoarr[3]
		Case "acct"
			$result = $acctinfoarr[4]
		Case "gift"
			$result = $acctinfoarr[5]
		Case "fight"
			$result = $acctinfoarr[6]
	EndSwitch

	Return $result
EndFunc
#EndRegion

Func CheckMoneyBefore()
	CheckMoney("_before")
EndFunc

Func CheckMoneyAfter()
	CheckMoney("_after")
EndFunc

Func CheckMoney($suffix)
	Local $money_abs = GetAbsoluteRoomCoord($v_money)
	Local $screenshotfile = $v_money_ocr&StringReplace(_NowCalcDate(),"/","")&"_"&GetAccountInfo("uid")&$suffix&".jpg"
	Local $ocrfile = $v_money_ocr&StringReplace(_NowCalcDate(),"/","")&"_"&GetAccountInfo("uid")&$suffix
	_ScreenCapture_Capture($screenshotfile,$money_abs[0],$money_abs[1],$money_abs[2],$money_abs[3])
	ShellExecuteWait($v_tesseractfile,$screenshotfile&" "&$ocrfile&" -psm 7")
	Local $moneyamount = StringStripWS(FileReadLine($ocrfile&".txt",1),8)
	ConsoleWrite($moneyamount&@CRLF)
	Return $moneyamount
EndFunc

#Region Check number of py fight
Func GetAchievement()

EndFunc
#EndRegion