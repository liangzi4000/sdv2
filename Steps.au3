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
_ArrayAdd($firstrun, "CheckAccountStatus")
;_ArrayAdd($firstrun, "GetPFR")
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
_ArrayAdd($steps, "ClickBtnLianDongZiLiang")
_ArrayAdd($steps, "ChooseUserIDLogin")
_ArrayAdd($steps, "GetNextRecord")
_ArrayAdd($steps, "Wrapper_EnterUIDandPWD_LianDong")
_ArrayAdd($steps, "Wrapper_StartScreen_DoItLater")
_ArrayAdd($steps, "Wrapper_ClickUntilNotification_CloseNotification_CompleteLogin")
;_ArrayAdd($steps,"CloseBPInfo")
_ArrayAdd($steps, "CheckAccountStatus")
;_ArrayAdd($steps, "GetPFR")
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

Func ClickBtnLianDongZiLiang()
	ClickImage("btn_liandongziliao.bmp,btn_liandongziliao_v2.bmp,btn_liandongziliao_v3.bmp")
EndFunc   ;==>ClickBtnLianDongZiLiang

Func ChooseUserIDLogin()
	WaitImage("btn_close_login.bmp,btn_close_login_v2.bmp,btn_close_switch.bmp")
	ClickOnRelative($btn_uidpwd)
EndFunc   ;==>ChooseUserIDLogin

Func GetNextRecord()
	Local $acctinfo = ""
	Local $result = False
	Local $siblingloginid = 0
	If Not IsFightHost() Then
		SwitchWindow(True)
		$siblingloginid = Number(GetAccountInfo("uid"))
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

#Region Wrapper_EnterUIDandPWD_LianDong
Func Wrapper_EnterUIDandPWD_LianDong()
	EnterUIDandPWD()
	ClickJueDing()
	LianDong()
EndFunc   ;==>Wrapper_EnterUIDandPWD_LianDong

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
	ClickImage("btn_login_jueding.bmp,btn_login_jueding_v2.bmp")
EndFunc   ;==>ClickJueDing

Func LianDong()
	ClickImage("btn_liandong.bmp,btn_liandong_v2.bmp", False, 2)
	Sleep(500)
	ClickImage("btn_liandong.bmp,btn_liandong_v2.bmp", False, 2)
	ClickBtnOK()
EndFunc   ;==>LianDong

Func ClickBtnOK()
	ClickImage("btn_ok.bmp,btn_ok_v2.bmp", True, 2)
EndFunc   ;==>ClickBtnOK
#EndRegion Wrapper_EnterUIDandPWD_LianDong

#Region Wrapper_StartScreen_DoItLater
Func Wrapper_StartScreen_DoItLater()
	StartScreen()
	ClickOnStartScreen()
	DoItLater()
EndFunc   ;==>Wrapper_StartScreen_DoItLater

Func StartScreen()
	; Extra check to ensure Ok button is clicked
	Local $pos = [0,0]
	If SearchImageActive("btn_ok.bmp",$pos[0],$pos[1]) = 1 Then ClickImage("btn_ok.bmp")
	If SearchImageActive("btn_ok_v2.bmp",$pos[0],$pos[1]) = 1 Then ClickImage("btn_ok_v2.bmp")

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
	ClickPosUntilScreen($menu_other,"btn_youxiziliaoliandong.bmp")
EndFunc   ;==>ClickMenuOthers

Func ClickBtnGameLink()
	ClickImageUntilScreen("btn_youxiziliaoliandong.bmp", "btn_liandongziliao_v2.bmp")
EndFunc   ;==>ClickBtnGameLink

Func CloseApp()
	Local $pos = [0, 0]
	Local $mycount = 5
	Do
		Send("{PGUP}")
		Sleep(3000)
		If SearchImageActive("app_icon_tasklist_vertical.bmp", $pos[0], $pos[1]) = 1 Then
			ClickImage("app_icon_tasklist_vertical.bmp")
			Sleep(1000)
		EndIf
		$mycount = $mycount - 1
	Until (SearchImageActive("app_icon_tasklist.bmp", $pos[0], $pos[1]) = 1 Or $mycount = 0)
	Slide($pos[0], $pos[1]+120, $pos[0], 0)
	Sleep(2000)
	Local $count = 0, $maxretry = 5
	While SearchImageActive("app_icon_home.bmp", $pos[0], $pos[1]) <> 1 And $count < $maxretry
		Send("{HOME}")
		$count += 1
		Sleep(3000)
	WEnd
	If $count >= $maxretry Then
		If $v_onunexpectederrortoshutdownpc Then
			Local $errorscreen = $v_screenshotpath & CaptureFullScreen()
			$v_email_Subject = "Shutdown pc triggered"
			$v_email_AttachFiles = $errorscreen
			_INetSmtpMailCom($v_email_SmtpServer,$v_email_FromName,$v_email_FromAddress,$v_email_ToAddress,$v_email_Subject,$v_email_Body,$v_email_AttachFiles,$v_email_CcAddress,$v_email_BccAddress,$v_email_Importance,$v_email_Username,$v_email_Password,$v_email_IPPort,$v_email_ssl)
			Shutdown(BitOR($SD_SHUTDOWN,$SD_FORCE)) ; shutdown PC
		Else
			Exit
		EndIf
	EndIf
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

Func GetTaskReward()
	ClickPosUntilScreen($side_task, "btn_back.bmp")
	ClickOnRelative($side_task_chengjiu)
	Local $img = WaitImage("btn_getall_gifts.bmp,btn_getall_gifts_greyout.bmp")
	If $img = 1 Then
		ClickImage("btn_getall_gifts.bmp", True)
		ClickImage("btn_ok_lingqu.bmp", True)
		Return 1
	Else
		ClickOnRelative($menu_main)
		Return 0
	EndIf
EndFunc

Func PerformTask1()
	If GetAccountInfo("task1") = 0 Then
		ClickImage("menu_card.bmp",True) ; 点击卡片菜单
		Sleep(500)
		ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
		Sleep(500)
		Local $mypos = [0,0]
		If SearchImageActive("ui_zhidingxilie.bmp",$mypos[0],$mypos[1]) = 0 Then
			ClickPosUntilScreen($opt_zhuxian,"ui_zhidingxilie.bmp") ;点击直到出现 指定系列
		EndIf
		ClickImage("ui_zhidingxilie.bmp",True)
		WaitImage("btn_back.bmp")
		ClickOnRelative($btn_createcombination) ; 点击 创建新牌组
		ClickImage("btn_zidongbianji.bmp"); 点击 自动编辑
		Sleep(300)
		ClickPosUntilScreen($btn_zhuzhanzhe_confirm,"btn_save.bmp") ; 点击决定
		ClickImage("btn_save.bmp")
		ClickImage("btn_jueding_bianjicard.bmp",True)
		ClickImage("btn_ok_card_saved.bmp",True)
		ClickImage("btn_ok_fight_effect.bmp",True)
		ClickImage("menu_single_mode.bmp",True)
		Sleep(2000)
		ClickOnRelative($opt_zhuxian) ; 点击 主线剧情
		WaitImage("btn_back.bmp",5)
		ClickOnRelative($btn_zhuzhanzhe_confirm) ; 点击决定
		ClickImage("ui_1st_chapter_task1.bmp",10)
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
	ClickPosUntilScreenByPixel($menu_duizhan,$opt_privatefight) ;点击 对战
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
					Sleep(800)
					ClickOnLastPosition()
				EndIf
				WaitImage("btn_back.bmp")
				ClickImage("menu_single_mode.bmp")
				ClickImage("btn_jiesan.bmp",False,5)
				UpdateFightResult()
				ExitLoop
			EndIf
		Else
			ClickOnRelative($btn_confirmfight)
		EndIf

		$isfirstwindow = Not $isfirstwindow
	WEnd
EndFunc

Func SecondWindowExitFight()
	ClickImage("btn_ok_beginner.bmp",True) ; 点击 ok
EndFunc

Func UpdateFightResult()
	Local $hostloginid = GetAccountInfo("uid")
	SwitchWindow(False)
	Local $rivalloginid = GetAccountInfo("uid")
	SwitchWindow(True)
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

Func CheckAccountStatus()
	CheckMoneyBefore()
;~ 	Local $gettaskrewardresult = GetTaskReward()
;~ 	If $gettaskrewardresult = 1 Then
;~ 		CheckMoneyAfter()
;~ 	EndIf
	GotoCardPage()
	CheckCardLegend()
	CheckCardBrigade()
	CheckCardDawnbreak()
	CheckCardChronogenesis()
	CheckCardStarforged()
	CheckCardWonderland()
	ClickImage("btn_switch_classic_cards.bmp",True)
	CheckCardTempest()
	CheckCardBahamut()
	CheckCardDarkness()
	CheckCardClassic()
	; Go to JJC
	;CheckCardJJC()
	;ExecDBQuery("[dbo].[SP_InsertAccountStatus] "&GetAccountInfo("uid")&","&$as_Money&",'"&$as_Money_url&"',"&$as_MoneyAfter&",'"&$as_MoneyAfter_url&"',"&$as_legendcard&",'"&$as_legendcard_url&"',"&$as_dawnbreakcard&",'"&$as_dawnbreakcard_url&"',"&$as_chronogenesiscard&",'"&$as_chronogenesiscard_url&"',"&$as_starforgedcard&",'"&$as_starforgedcard_url&"',"&$as_wonderlandcard&",'"&$as_wonderlandcard_url&"',"&$as_tempestcard&",'"&$as_tempestcard_url&"',"&$as_bahamutcard&",'"&$as_bahamutcard_url&"',"&$as_darknesscard&",'"&$as_darknesscard_url&"',"&$as_classiccard&",'"&$as_classiccard_url&"',"&$as_JJC&",'"&$as_JJC_url&"'")
EndFunc

Func GotoCardPage()
	ClickPosUntilScreenByPixel($menu_shop,$opt_buycards) ;点击 商店
	ClickOnRelative($opt_buycards) ;点击 购买卡包
	ClickImage("opt_buycard.bmp",True)
EndFunc

#Region OCR functions
Func CheckMoneyBefore()
	$as_Money = 0
	$as_Money_url = ""
	Local $val = ExecTesseract("_before",$v_money)
	$as_Money = $val[0]
	$as_Money_url = $val[1]
EndFunc

Func CheckMoneyAfter()
	$as_MoneyAfter = 0
	$as_MoneyAfter_url = ""
	Local $val = ExecTesseract("_after",$v_money)
	$as_MoneyAfter = $val[0]
	$as_MoneyAfter_url = $val[1]
EndFunc

Func CheckCardLegend()
	Local $pos[2] = [$as_nextcard[0],$as_nextcard[1]-60]
	ClickPosUntilScreen($pos, "card_legend.bmp", 800)
	$as_legendcard = 0
	$as_legendcard_url = ""
	Local $val = ExecTesseract("_legend",$v_card_legend)
	$as_legendcard = $val[0]
	$as_legendcard_url = $val[1]
EndFunc

Func CheckCardBrigade()
	ClickPosUntilScreen($as_nextcard, "card_brigade.bmp", 800)
	$as_brigadecard = 0
	$as_brigadecard_url = ""
	Local $val = ExecTesseract("_brigade",$v_card_normal)
	$as_brigadecard = $val[0]
	$as_brigadecard_url = $val[1]
EndFunc

Func CheckCardDawnbreak()
	ClickPosUntilScreen($as_nextcard, "card_dawnbreak.bmp", 800)
	$as_dawnbreakcard = 0
	$as_dawnbreakcard_url = ""
	Local $val = ExecTesseract("_dawnbreak",$v_card_normal)
	$as_dawnbreakcard = $val[0]
	$as_dawnbreakcard_url = $val[1]
EndFunc

Func CheckCardChronogenesis()
	ClickPosUntilScreen($as_nextcard, "card_chronogenesis.bmp", 800)
	$as_chronogenesiscard = 0
	$as_chronogenesiscard_url = ""
	Local $val = ExecTesseract("_chronogenesis",$v_card_normal)
	$as_chronogenesiscard = $val[0]
	$as_chronogenesiscard_url = $val[1]
EndFunc

Func CheckCardStarforged()
	ClickPosUntilScreen($as_nextcard, "card_starforged.bmp", 800)
	$as_starforgedcard = 0
	$as_starforgedcard_url = ""
	Local $val = ExecTesseract("_starforged",$v_card_normal)
	$as_starforgedcard = $val[0]
	$as_starforgedcard_url = $val[1]
EndFunc

Func CheckCardWonderland()
	ClickPosUntilScreen($as_nextcard, "card_wonderland.bmp", 800)
	$as_wonderlandcard = 0
	$as_wonderlandcard_url = ""
	Local $val = ExecTesseract("_wonderland",$v_card_normal)
	$as_wonderlandcard = $val[0]
	$as_wonderlandcard_url = $val[1]
EndFunc

Func CheckCardTempest()
	ClickPosUntilScreen($as_nextcard, "card_tempest.bmp", 800)
	$as_tempestcard = 0
	$as_tempestcard_url = ""
	Local $val = ExecTesseract("_tempest",$v_card_normal)
	$as_tempestcard = $val[0]
	$as_tempestcard_url = $val[1]
EndFunc

Func CheckCardBahamut()
	ClickPosUntilScreen($as_nextcard, "card_bahamut.bmp", 800)
	$as_bahamutcard = 0
	$as_bahamutcard_url = ""
	Local $val = ExecTesseract("_bahamut",$v_card_normal)
	$as_bahamutcard = $val[0]
	$as_bahamutcard_url = $val[1]
EndFunc

Func CheckCardDarkness()
	ClickPosUntilScreen($as_nextcard, "card_darkness.bmp", 800)
	$as_darknesscard = 0
	$as_darknesscard_url = ""
	Local $val = ExecTesseract("_darkness",$v_card_normal)
	$as_darknesscard = $val[0]
	$as_darknesscard_url = $val[1]
EndFunc

Func CheckCardClassic()
	ClickPosUntilScreen($as_nextcard, "card_classic.bmp", 800)
	$as_classiccard = 0
	$as_classiccard_url = ""
	Local $val = ExecTesseract("_classic",$v_card_normal)
	$as_classiccard = $val[0]
	$as_classiccard_url = $val[1]
EndFunc

Func CheckCardJJC()
	$as_JJC = 0
	$as_JJC_url = ""
	Local $val = ExecTesseract("_jjc",$v_jjc)
	$as_JJC = $val[0]
	$as_JJC_url = $val[1]
EndFunc

Func ExecTesseract($suffix,$area)
	Local $money_abs = GetAbsoluteRoomCoord($area)
	Local $screenshotfilename = StringReplace(_NowCalcDate(),"/","")&"_"&GetAccountInfo("uid")&$suffix&".jpg"
	Local $screenshotfile = $v_money_ocr&$screenshotfilename
	Local $ocrfile = $v_money_ocr&StringReplace(_NowCalcDate(),"/","")&"_"&GetAccountInfo("uid")&$suffix
	_ScreenCapture_Capture($screenshotfile,$money_abs[0],$money_abs[1],$money_abs[2],$money_abs[3])
	ShellExecuteWait($v_tesseractfile,$screenshotfile&" "&$ocrfile&" -psm 7 digits")
	Local $moneyamount = StringStripWS(FileReadLine($ocrfile&".txt",1),8)
	Local $result[2] = [$moneyamount,$screenshotfilename]
	Return $result
EndFunc
#EndRegion

#Region Private Fight Reward
Func GetPFR()
	If Not $v_allowgetpyr Then Return
	ClickImage("activity_privatefight.bmp")
	WaitImage("btn_back.bmp",5)
	CaptureActiveWindow(GetAccountInfo("uid")&".bmp",$v_pyf)
	Local $sqlparams = GetAccountInfo("uid")
	Local $i = 0, $j = 0, $pos = [0,0]
	For $i = 0 To 1
		For $j = 0 To 3
			Local $startpoint_x = $pfa_reward_start[0] + $j * $pfa_length
			Local $startpoint_y = $pfa_reward_start[1] + $i * $pfa_height
			Local $tmpixel = [$pfa_reward_start[0]+$j*$pfa_length,$pfa_reward_start[1]+$i*$pfa_height,0x2B74F5,10,8,8]
			Local $pixelresult = SearchPixel($tmpixel)
			If $pixelresult[0] <> $pixel_empty[0] Or $pixelresult[1] <> $pixel_empty[1] Then
				$sqlparams = $sqlparams & ",1"
				Local $clickonpos = [$tmpixel[0],$tmpixel[1]]
				ClickOnRelative($clickonpos)
				WaitImage("btn_ok_fight_effect.bmp")
				CaptureActiveWindow(GetAccountInfo("uid")&"_"&($i*4+$j+1)&".bmp",$v_pyf)
				ClickImage("btn_ok_fight_effect.bmp",True)
			Else
				$sqlparams = $sqlparams & ",0"
			EndIf
		Next
	Next

	Local $pixelresult2 = SearchPixel($pfa_double_reward)
	If $pixelresult2[0] <> $pixel_empty[0] Or $pixelresult2[1] <> $pixel_empty[1] Then
		$sqlparams = $sqlparams & ",1"
		Local $clickonpos2 = [$pfa_double_reward[0],$pfa_double_reward[1]]
		ClickOnRelative($clickonpos2)
		WaitImage("btn_ok_fight_effect.bmp")
		CaptureActiveWindow(GetAccountInfo("uid")&"_dblreward.bmp",$v_pyf)
		ClickImage("btn_ok_fight_effect.bmp",True)
	Else
		$sqlparams = $sqlparams & ",0"
	EndIf
	ExecDBQuery("[dbo].[SP_InsertPYFStatus] "&$sqlparams)
	ClickOnRelative($menu_main)
EndFunc
#EndRegion