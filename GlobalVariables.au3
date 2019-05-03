#include-once
Global Enum $exitaction_restart, $exitaction_terminatescript, $exitaction_shutdownpc
Global $activewindow = ""						; Store current active window
Global $inactivewindows = [] 					; Store inactive windows
Global $debug = True 							; Debug falg, turn on to write detail log
Global $exit = False 							; Terminate script flag
Global $shutdownpc = False						; Shut down pc after script completed
Global $exitaction = $exitaction_restart 		; Action to take upon exit, default is to restart program
Global $winleftready = False 					; Align window left flag
Global $winrightready = False 					; Align window right flag
Global $morethantwonox = False					; More than two NOX instance
Global $timeoutcount = 0 						; Count number of timeout for function that invoking itself
Global Const $lastclickposition = "lastclicked" ; Name const of last clicked position
Global Const $lastimageposition = "lastimage"	; Name const of last image center position
Global Const $pixelinfo_shadow_variation = 5	; Default PixelSearch shadow variation
Global Const $pixelinfo_half_width = 2			; Default PixelSearch range half width
Global Const $pixelinfo_half_height = 2			; Default PixelSearch range half height
Global Const $pixel_empty = [0,0]				; Default result position of PixelSearch
Global $skipsecondwindowexecution = False		; Skip second window execution flag
Global $fightroomnumber = ""					; Fight room number
Global $v_allowgetpyr = False					; Flag to config execution of function GetPFR
Global $v_onunexpectederrortoshutdownpc = True	; Flag to config shutdown pc when unexpected error happens
Global $v_checkaccountstatus = False
Global $v_blockinput = False
Global $v_ishost = False
Global $v_stagevalue = -1
Global Const $v_winctrlclassname = "subWin1"

Local Const $cfgfile = @ScriptDir & "\start.ini"
Global $v_noxpath 			= IniRead($cfgfile,"Install","NoxPath","")
Global $v_packagename 		= IniRead($cfgfile,"Install","PackageName",""); Package name
Local $cfg_namelist 		= IniRead($cfgfile,"Install","NameList","")
Local $cfg_shutdownpc 		= IniRead($cfgfile,"Install","ShutdownPC","")
Global $v_installfile1 		= IniRead($cfgfile,"Install","File1","")
Global $v_installfile2 		= IniRead($cfgfile,"Install","File2","")
Global $v_installfolder1 	= IniRead($cfgfile,"Install","Folder1","")
Global $v_installfolder2 	= IniRead($cfgfile,"Install","Folder2","")
Global $v_sqlcmdfile 		= IniRead($cfgfile,"Install","SQLCMD","")
Local $cfg_chkacctstatus 	= IniRead($cfgfile,"Install","Checkaccountstatus","")
Global $v_tesseractfile 	= IniRead($cfgfile,"Install","Tesseract","")
Global $v_graphicsmagickfile= IniRead($cfgfile,"Install","GraphicsMagick","")
Local $cfg_blockinput		= IniRead($cfgfile,"Install","BlockInput","")
Local $cfg_ishost			= IniRead($cfgfile,"Install","IsHost","")

Global $v_db_server 		= IniRead($cfgfile,"Database","Server","")
Global $v_db_userid 		= IniRead($cfgfile,"Database","UID","")
Global $v_db_password		= IniRead($cfgfile,"Database","Password","")
Global $v_db 				= IniRead($cfgfile,"Database","DBName","")

Global $v_email_SmtpServer	= IniRead($cfgfile,"Email","SMTP","")				; address for the smtp-server to use - REQUIRED
Global $v_email_FromName	= IniRead($cfgfile,"Email","FromName","")			; name from who the email was sent
Global $v_email_FromAddress = IniRead($cfgfile,"Email","FromAddress","")		; address from where the mail should come
Global $v_email_ToAddress 	= IniRead($cfgfile,"Email","ToAddress","")			; destination address of the email - REQUIRED
Global $v_email_Subject 	= IniRead($cfgfile,"Email","Subject","")			; subject from the email - can be anything you want it to be
Global $v_email_Body 		= IniRead($cfgfile,"Email","Body","")				; the messagebody from the mail - can be left blank but then you get a blank mail
Global $v_email_AttachFiles = IniRead($cfgfile,"Email","Attachment","")			; the file(s) you want to attach seperated with a ; (Semicolon) - leave blank if not needed
Global $v_email_CcAddress 	= IniRead($cfgfile,"Email","CcAddress","")      	; address for cc - leave blank if not needed
Global $v_email_BccAddress 	= IniRead($cfgfile,"Email","BccAddress","")    		; address for bcc - leave blank if not needed
Global $v_email_Importance 	= IniRead($cfgfile,"Email","Importance","")         ; Send message priority: "High", "Normal", "Low"
Global $v_email_Username 	= IniRead($cfgfile,"Email","Username","")			; username for the account used from where the mail gets sent - REQUIRED
Global $v_email_Password 	= IniRead($cfgfile,"Email","Password","")			; password for the account used
Global $v_email_IPPort 		= 465												; port used for sending the mail
Global $v_email_ssl 		= 1													; enables/disables secure socket layer sending - put to 1 if using httpS

Global $v_db_result = 			@ScriptDir & "\db\dbresult.txt"
Global $v_room_screenshot = 	@ScriptDir & "\db\privateroom.jpg"
Global $v_room_file = 			@ScriptDir & "\db\privateroom"
Global $v_money_ocr = 			@ScriptDir & "\db\money\"
Global $v_pyf = 				@ScriptDir & "\db\pyf\"
Global $v_imagepath = 			@ScriptDir & "\Assets\identifier\"

Global $v_windows = StringSplit($cfg_namelist,",",2)
If UBound($v_windows) > 2 Then $morethantwonox = True
If $cfg_shutdownpc = "True" Then $shutdownpc = True
If $cfg_chkacctstatus = "True" Then $v_checkaccountstatus = True
If $cfg_blockinput = "True" Then $v_blockinput = True
If $cfg_ishost = "True" Then $v_ishost = True

Global $btn_liandong[2] = [141,28] ; 资料连动
Global $btn_uidpwd[2] = [334,131] ; 输入用户名和密码
Global $txt_uid[2] = [334,180] ; 用户名输入文本框
Global $txt_pwd[2] = [334,236] ; 密码输入文本框
Global $btn_ignore[2] = [625,25] ; 忽略
Global $side_gift[2] = [635,84] ; 礼物
Global $side_task[3] = [635,186,0xE9E9D8] ; 任务
Global $side_task_chengjiu[2] = [253,83] ; 成就
Global $ico_bin[2] = [98,37] ; 回收站
Global $area_startscreen[4] = [0, 340, 60, 60] ; 开始屏幕图标
Global $btn_change_lang[2] = [500,113] ; change language
Global $opt_lang_cht[2] = [334,260] ; 繁体中文
Global $txt_username[2] = [334,202] ; 用户昵称
Global $btn_skipvideo[2] = [650,23] ; skip video
Global $sld_card1[4] = [334,313,334,5] ; 交换第一张卡
Global $sld_card2[4] = [496,313,496,5] ; 交换第二张卡
Global $btn_fight_confirm[2] = [611,204] ; 决定
Global $opt_zhuxian[2] = [129,119] ; 主线剧情
Global $btn_setpwd[2] = [334,244] ; 设定连动密码
Global $txt_setpwd[2] = [334,126] ; password
Global $txt_setpwd_confirm[2] = [334,205] ; confirm password
Global $chk_agreeprivacy[2] = [405,290] ; 同意隐私政策
Global $btn_createcombination = [129,103] ; 创建新牌组
Global $btn_zhuzhanzhe_confirm[2] = [621,277] ; 决定
Global $menu_other[2] = [619,378] ; 其他菜单
Global $menu_duizhan[2] = [254,377] ; 对战菜单
Global $menu_shop[2] = [526,377] ; 商店菜单
Global $menu_main[2] = [70,377] ; 主菜单
Global $menu_jjc[2] = [347,377] ; 竞技场

;;;;;;;;----------------;;;;;;;;;
Global $opt_privatefight[3] = [555,222,0xE6E6E6] ; 私人对战
Global $v_room[4] = [295,102,374,123] ; room number rectangle
Global $v_money[4] = [485,19,532,37] ; money rectangle
Global $btn_number[10][2] = [[336,305],[218,161],[336,161],[454,161],[218,209],[336,209],[454,209],[218,257],[336,257],[454,257]]
Global $btn_readytofight[3] = [337,275,0x00698A] ;准备完成
Global $btn_changecard[3] = [613,203,0x016C8D] ;交换 决定
Global $btn_waitforfight[3] = [613,202,0x3E191D] ;等待
Global $btn_confirmfight[3] = [613,202,0x227A8B] ;回合完成

Global $readycard1 = [151,392,0xFFFDEB,10]
Global $readycard2 = [200,384,0xFFFDEB,10]
Global $readycard3 = [248,377,0xFFFDEB,10]
Global $readycard4 = [297,373,0xFFFDEB,10]
Global $readycard5 = [344,370,0xFFFDEB,10]
Global $readycard6 = [393,375,0xFFFDEB,10]
Global $readycards = [$readycard1,$readycard2,$readycard3,$readycard4,$readycard5,$readycard6]

Global $evencard1 = [219,231]
Global $evencard2 = [296,231]
Global $evencard3 = [376,231]
Global $evencard4 = [457,231]
Global $oddcard1 = [179,231]
Global $oddcard2 = [257,231]
Global $oddcard3 = [339,231]
Global $oddcard4 = [418,231]
Global $oddcard5 = [495,231]
Global $cardevens = [$evencard1,$evencard2,$evencard3,$evencard4]
Global $cardodds = [$oddcard1,$oddcard2,$oddcard3,$oddcard4,$oddcard5]

Global $enemypos = [336,34]
Global $v_battle_card_x_offset = 24
Global $cardready = [525,371]

Global $as_nextcard[2] = [56,279] ;点击切换卡包类别
Global $opt_buycards[3] = [346,266,0xC6D1C3] ; 购买卡包
Global $opt_twopick[2][6] = [[336,190,0xBC3F2F,35,5,5],[215,204,0xA3321E,35,5,5]] ; 2 Pick
Global $v_card_legend[4] = [499,296,519,310] ; card legend rectangle
Global $v_card_normal[4] = [498,165,519,180] ; card normal rectangle
Global $v_jjc[4] = [376,243,400,257] ; jjc rectangle


;;;;;;;;;;;;;;;;;;;;;Privat fight activity;;;;;;;;;;;;
Global $pfa_reward_start[2] = [130,224]
Global $pfa_length = 105
Global $pfa_height = 88
Global $pfa_double_reward = [609,263,0x154CEE,10,8,8]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;; Daily award stage ;;;;;;;;;;;;;;;;;;
Local Const $day1 = [0,0,0xFFFFFF]
Local Const $day2 = [0,0,0xFFFFFF]
Local Const $day3 = [0,0,0xFFFFFF]
Local Const $day4 = [0,0,0xFFFFFF]
Local Const $day5 = [0,0,0xFFFFFF]
Local Const $day6 = [0,0,0xFFFFFF]
Local Const $day7 = [0,0,0xFFFFFF]
Local Const $day8 = [0,0,0xFFFFFF]
Local Const $day9 = [0,0,0xFFFFFF]
Local Const $day10 = [0,0,0xFFFFFF]
Local Const $day11 = [0,0,0xFFFFFF]
Local Const $day12 = [0,0,0xFFFFFF]
Local Const $day13 = [0,0,0xFFFFFF]
Local Const $day14 = [0,0,0xFFFFFF]
Local Const $day15 = [0,0,0xFFFFFF]
Global $v_awardstage = [$day1,$day2,$day3,$day4,$day5,$day6,$day7,$day8,$day9,$day10,$day11,$day12,$day13,$day14,$day15]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global $oDictionary = ObjCreate("Scripting.Dictionary")
If $v_ishost Then
	$oDictionary.Add ("NoxPlayer03","62001")
	$oDictionary.Add ("NoxPlayer04","62025")
Else
	Local Const $opt_twopick_ls[2][6] = [[215,204,0xA3321E,35,5,5],[336,190,0xBC3F2F,35,5,5]]
	Local Const $btn_liandong_ls[2] = [169,31] ; 资料连动
	Local Const $btn_uidpwd_ls[2] = [395,155] ; 输入用户名和密码
	Local Const $txt_uid_ls[2] = [395,213] ; 用户名输入文本框
	Local Const $txt_pwd_ls[2] = [395,282] ; 密码输入文本框
	Local Const $btn_ignore_ls[2] = [743,30] ; 忽略
	Local Const $side_gift_ls[2] = [753,97] ; 礼物
	Local Const $side_task_ls[3] = [753,223,0xEFEBDE] ; 任务
	Local Const $side_task_chengjiu_ls[2] = [300,97] ; 成就

	Local Const $area_startscreen_ls[4] = [0, 414, 100, 100] ; 开始屏幕图标
	Local Const $opt_lang_cht_ls[2] = [395,260] ; 繁体中文
	Local Const $txt_username_ls[2] = [395,202] ; 用户昵称
	Local Const $sld_card1_ls[4] = [395,313,395,5] ; 交换第一张卡
	Local Const $btn_setpwd_ls[2] = [395,244] ; 设定连动密码
	Local Const $txt_setpwd_ls[2] = [395,126] ; password
	Local Const $txt_setpwd_confirm_ls[2] = [395,205] ; confirm password

	Local Const $menu_other_ls[2] = [742,440] ; 其他菜单
	Local Const $menu_duizhan_ls[2] = [304,440] ; 对战菜单
	Local Const $menu_shop_ls[2] = [625,440] ; 商店菜单
	Local Const $menu_main_ls[2] = [84,440] ; 主菜单
	Local Const $menu_jjc_ls[2] = [414,440] ; 竞技场

	CopyArrayData($opt_twopick,$opt_twopick_ls)

	CopyArrayData($btn_liandong,$btn_liandong_ls)
	CopyArrayData($btn_uidpwd,$btn_uidpwd_ls)
	CopyArrayData($txt_uid,$txt_uid_ls)
	CopyArrayData($txt_pwd,$txt_pwd_ls)
	CopyArrayData($btn_ignore,$btn_ignore_ls)
	CopyArrayData($side_gift,$side_gift_ls)
	CopyArrayData($side_task,$side_task_ls)
	CopyArrayData($side_task_chengjiu,$side_task_chengjiu_ls)

	CopyArrayData($area_startscreen,$area_startscreen_ls)
	CopyArrayData($opt_lang_cht,$opt_lang_cht_ls)
	CopyArrayData($txt_username,$txt_username_ls)
	CopyArrayData($sld_card1,$sld_card1_ls)
	CopyArrayData($btn_setpwd,$btn_setpwd_ls)
	CopyArrayData($txt_setpwd,$txt_setpwd_ls)
	CopyArrayData($txt_setpwd_confirm,$txt_setpwd_confirm_ls)

	CopyArrayData($menu_other,$menu_other_ls)
	CopyArrayData($menu_duizhan,$menu_duizhan_ls)
	CopyArrayData($menu_shop,$menu_shop_ls)
	CopyArrayData($menu_main,$menu_main_ls)
	CopyArrayData($menu_jjc,$menu_jjc_ls)
EndIf