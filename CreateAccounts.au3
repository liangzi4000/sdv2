#include-once
#include <Common.au3>
#include <Array.au3>

Global $createaccountsteps = []
_ArrayAdd($createaccountsteps,"Wrapper1")
_ArrayAdd($createaccountsteps,"Wrapper2")
_ArrayAdd($createaccountsteps,"CheckExit")

Func Wrapper1()
	Local $success = CreateNextRecord()
	If $success Then
		DeleteApp()
		InstallApp()
		SetupLanguageAndAgreement()
		SetupUserName()
	EndIf
EndFunc

Func Wrapper2()
	BeginnerTutorial()
	;Handle2ndAnniversary()
	SetupPassword()
EndFunc

Func CreateNextRecord()
	Local $acctinfo = ExecDBQuery("[dbo].[SP_CreateNextRecord] '"&$activewindow&"'")
	Assign("acctinfo"&$activewindow,$acctinfo,2)
	If Not IsValidResult($acctinfo) Then
		WriteLog("CreateNextRecord return invalid database record: " & $acctinfo, $v_exception)
		AddArrayElem($inactivewindows,$activewindow)
		Return False
	EndIf
	Return True
EndFunc

Func DeleteApp()
	Local $pos = [0, 0]
	Do
		Send("{HOME}")
		WriteLog("Press Home key")
		Sleep(1500)
	Until SearchImageActive("app_icon_home.bmp", $pos[0], $pos[1]) = 1

	DragImage("app_icon_home.bmp",$ico_bin)
	ClickImage("btn_delete_app_queding.bmp")
EndFunc

Func InstallApp()
	Local $pos = [0, 0]
	Do
		WinActivate($activewindow)
		Send("^3")
		Sleep(1500)
	Until SearchImageDesktop("openphoneapkfolder.bmp", $pos[0], $pos[1]) = 1
	ClickImageDesktop("openphoneapkfolder.bmp") ; Click on "Open Phone Folder" of APK files
	ClickImage("shadowverseapk.bmp") ; Click on "Shadowverse" apk file
	ClickImage("btn_next.bmp")
	ClickImage("btn_install.bmp")
	ClickImage("btn_open.bmp")
EndFunc

Func SetupLanguageAndAgreement()
	ClickImage("ui_startscreen.bmp", True, 60, "", $area_startscreen[0], $area_startscreen[1], $area_startscreen[2], $area_startscreen[3])
	WaitImage("btn_ok_language.bmp")
	Sleep(1500)
	ClickOnRelative($btn_change_lang)
	WaitImage("btn_ok_cht.bmp")
	Sleep(500)
	ClickOnRelative($opt_lang_cht)
	ClickImage("btn_ok_cht.bmp")
	Sleep(500)
	ClickImage("btn_ok_language.bmp")
	Sleep(500)
	ClickImage("btn_ok_language_confirm.bmp")
	Sleep(500)
	ClickImage("btn_agree.bmp")
	Sleep(800)
	ClickImage("btn_agree.bmp",True)
EndFunc

Func SetupUserName()
	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	_ClipBoard_SetData($acctinfoarr[1]) ; 读取用户名到粘贴板
	ClickPosUntilScreen($txt_username, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(500)
	ClickImage("btn_jueding_name.bmp")
	Sleep(500)
	ClickImageUntilScreen("btn_ok_complete_registration.bmp","initial_downloading.bmp")
EndFunc

Func BeginnerTutorial()
	ClickImage("ui_download_completed.bmp", True, 1200)
	ClickImage("ui_1st_chapter.bmp", False, 2)
	ClickImage("btn_qianwangjuqing.bmp")
	ClickPosUntilScreen($btn_skipvideo,"btn_ok_fight_effect.bmp")
	ClickImage("btn_ok_fight_effect.bmp")
	Sleep(500)
	ClickImage("btn_ok_fight_effect.bmp", False, 40)
	ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp")
	ClickImage("btn_ignore.bmp")
	ClickImage("ui_2nd_chapter.bmp") ;第二章
	ClickImage("btn_qianwangjuqing.bmp")
	ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp")
	ClickImage("btn_ignore.bmp")
	ClickImage("btn_ok_fight_effect.bmp", False, 40)
	ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp")
	ClickImage("btn_ignore.bmp")
	ClickImage("ui_3rd_chapter.bmp") ;第三章
	ClickImage("btn_qianwangjuqing.bmp")
	ClickImage("btn_ok_fight_effect.bmp", False, 40)
	ClickImage("btn_ok_beginner.bmp") ;关闭弹窗 “新手教学”
	Sleep(800)
	SlideRelative($sld_card1[0],$sld_card1[1],$sld_card1[2],$sld_card1[3]) ; 交换中间卡牌
	SlideRelative($sld_card2[0],$sld_card2[1],$sld_card2[2],$sld_card2[3]) ; 交换右边卡牌
	ClickImage("btn_ok_beginner.bmp") ;关闭弹窗 “新手教学”
	Sleep(300)
	ClickOnRelative($btn_fight_confirm)
	ClickImage("btn_ok_fight_effect.bmp") ;关闭弹窗 “后攻的第一回合”
	Sleep(300)
	ClickImage("btn_ok_fight_effect.bmp") ;关闭弹窗 “宝战”
	ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp")
	ClickImage("btn_ignore.bmp")
	ClickImage("btn_ok_fight_effect.bmp") ;关闭弹窗 “新手教学完成”
	ClickPosUntilScreen($btn_ignore,"btn_ignore.bmp")
	ClickImage("btn_ignore.bmp")
	ClickImage("btn_ok_downlod.bmp")
	ClickImage("btn_ok_fight_effect.bmp", False, 1200) ;关闭弹窗 “登入奖励”
EndFunc

Func Handle2ndAnniversary()
	Sleep(1000)
	Local $wincenter = GetCtrlCenter()
	ClickPosUntilScreen($wincenter,"btn_ok_fight_effect.bmp") ; 2-years anniversary
	ClickImage("btn_ok_fight_effect.bmp") ; 2-years anniversary
EndFunc

Func SetupPassword()
	Local $wincenter = GetCtrlCenter()
	ClickPosUntilScreen($wincenter,"btn_ok_beginner.bmp")
	ClickImage("btn_ok_beginner.bmp") ;选择单人游戏-确定
	ClickImage("menu_single_mode.bmp") ;单人游戏
	Sleep(800)
	ClickOnRelative($opt_zhuxian) ; 主线剧情
	ClickImage("menu_others_v2.bmp")
	ClickImage("btn_youxiziliaoliandong.bmp")
	ClickImage("btn_liandongziliao_v2.bmp")
	Sleep(300)
	ClickOnRelative($btn_setpwd)
	ClickImage("btn_sheding.bmp")

	Local $acctinfo = Eval("acctinfo" & $activewindow)
	Local $acctinfoarr = StringSplit($acctinfo, "|")
	_ClipBoard_SetData($acctinfoarr[2]) ; 读取密码到粘贴板
	ClickPosUntilScreen($txt_setpwd, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(500)
	ClickPosUntilScreen($txt_setpwd_confirm, "btn_queding.bmp", 800)
	SendPasteKeys() ; 黏贴
	ClickImage("btn_queding.bmp") ;点击确定
	Sleep(800)
	ClickOnRelative($chk_agreeprivacy)
	ClickImage("btn_sheding_confirm.bmp",True,5) ; 设置密码
	ClickImage("btn_copy_uid.bmp",True)
	ClickImage("btn_ok_beginner.bmp")
	ExecDBQuery("[dbo].[SP_CompleteAccountCreation] '"&_ClipBoard_GetData()&"','"&$acctinfoarr[2]&"'")
	ClickImage("btn_ok_fight_effect.bmp")
EndFunc
