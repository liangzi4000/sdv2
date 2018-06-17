#include-once
Global $activewindow = ""						; Store current active window
Global $inactivewindows = [] 					; Store inactive windows
Global $debug = True 							; Debug falg, turn on to write detail log
Global $exit = False 							; Terminate script flag
Global $winleftready = False 					; Align window left flag
Global $winrightready = False 					; Align window right flag
Global $timeoutcount = 0 						; Count number of timeout for function that invoking itself
Global Const $lastclickposition = "lastclicked" ; Name const of last clicked position
Global Const $lastimageposition = "lastimage"	; Name const of last image center position
Global Const $pixelinfo_shadow_variation = 5	; Default PixelSearch shadow variation
Global Const $pixelinfo_half_width = 2			; Default PixelSearch range half width
Global Const $pixelinfo_half_height = 2			; Default PixelSearch range half height
Global Const $pixel_empty = [0,0]				; Default result position of PixelSearch
Global $skipsecondwindowexecution = False		; Skip second window execution flag
Global $fightroomnumber = ""					; Fight room number

Global $v_winctrlclassname = "subWin1"
Global Const $v_imagepath = @ScriptDir & "\Assets\identifier\"

Global $btn_liandong[2] = [141,28] ; 资料连动
Global $btn_uidpwd[2] = [334,131] ; 输入用户名和密码
Global $txt_uid[2] = [334,180] ; 用户名输入文本框
Global $txt_pwd[2] = [334,236] ; 密码输入文本框
Global $btn_ignore[2] = [625,25] ; 忽略
Global $side_gift[2] = [635,84] ; 礼物
Global $side_task[2] = [635,199] ; 任务
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

;;;;;;;;----------------;;;;;;;;;
Global $opt_privatefight[3] = [555,222,0xE6E6E6] ; 私人对战
Global $meu_duizhan[2] = [254,377] ; 对战菜单
Global Const $v_room_screenshot = @ScriptDir & "\db\privateroom.jpg"
Global Const $v_room_file = @ScriptDir & "\db\privateroom"
Global Const $v_money_ocr = @ScriptDir & "\db\money\"
Global $v_room[4] = [295,102,374,123] ; room number rectangle
Global $v_money[4] = [493,19,532,37] ; money rectangle
Global Const $v_tesseractfile = "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe"
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
Global $cardevens[4] = [$evencard1,$evencard2,$evencard3,$evencard4]
Global $cardodds[5] = [$oddcard1,$oddcard2,$oddcard3,$oddcard4,$oddcard5]


Global $enemypos = [336,34]
Global $v_battle_card_x_offset = 24
Global $cardready = [525,371]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global $v_station_name = "jxpc"
; Game configuration
;Global $btn_liandong[2] = [304,75] ; 资料连动
Global $btn_doitlater[2] = [562,645] ; 晚点操作
Global $btn_jdacct[2] = [666,534] ; 决定
Global $sld_close_app[4] = [1167,447,1167,110] ; 关闭app
Global $screencenter[2] = [666,377] ; 屏幕中心点
Global $btn_install_next[2] = [304,654] ; 下一步，安装
Global $btn_confirm[2] = [666,533] ; 大弹窗确定按钮
Global $btn_reward_ok[2] = [666,445] ; 登录奖励 ok
Global $btn_liwu[6] = [1194,139,1202,147,0xE6E6D5,0] ; 礼物
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global $preparefight[6] = [110,883,114,87,0x356F25,10] ;back
Global Const $v_ctrl_fight = "fight"
Global Const $v_ctrl_wait = "wait"
Global $zoomcard = [1160,810]
;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;
Global $jinhuaover = [1374,416,1378,420,0xF9F7E6,5]
;;;;;;;;;;;;;;;;;;;;;;;
Global $stationdesktop = False ; PC station flag


#include <Configuration.au3>
