#include-once
Global $activewindow = ""
Global $inactivewindows = [] ; To store the inactive windows
Global $debug = True
Global $exit = False ; Terminate script flag
Global $winleftready = False
Global $winrightready = False
Global $timeoutcount = 0
Global Const $lastclickposition = "lastclicked"
Global Const $lastimageposition = "lastimage"
Global Const $pixelinfo_shadow_variation = 0
Global Const $pixelinfo_half_width = 5
Global Const $pixelinfo_half_height = 5
Global Const $pixel_empty = [0,0]

Global $v_winctrlclassname = "subWin1"
Global Const $v_imagepath = @ScriptDir & "\Assets\identifier\"

Global $btn_liandong[2] = [141,28] ; 资料连动
Global $btn_uidpwd[2] = [334,131] ; 输入用户名和密码
Global $txt_uid[2] = [334,180] ; 用户名输入文本框
Global $txt_pwd[2] = [334,236] ; 密码输入文本框
Global $btn_ignore[2] = [625,25] ; 忽略
Global $side_gift[2] = [635,84] ; 礼物
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Global Const $v_room_screenshot = @ScriptDir & "\db\privateroom.jpg"
Global Const $v_room_file = @ScriptDir & "\db\privateroom"
Global $v_room[4] = [700,218,863,270] ; room number rectangle
Global Const $v_tesseractfile = "C:\Program Files (x86)\Tesseract-OCR\tesseract.exe"

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




Global $opt_privatefight[3] = [1069,411,"E7E7E7"] ; 私人对战
Global $meu_duizhan[2] = [504,678] ; 对战菜单
Global $btn_liwu[6] = [1194,139,1202,147,0xE6E6D5,0] ; 礼物

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Global $btn_readytofight[6] = [660,509,668,517,0x016B8C,5] ;准备完成

Global $btn_changecard[6] = [1166,378,1174,386,0x006A8B,5] ;交换 决定
Global $btn_waitforfight[6] = [1134,350,1142,358,0x240807,5] ;等待
Global $btn_confirmfight[6] = [1167,372,1175,380,0x257586,5] ;回合完成

Global $preparefight[6] = [110,883,114,87,0x356F25,10] ;back

Global $btn_number[10][2] = [[667,563],[447,306],[667,306],[887,306],[447,393],[667,393],[887,393],[447,480],[667,480],[887,480]]

Global Const $v_ctrl_fight = "fight"
Global Const $v_ctrl_wait = "wait"

Global $zoomcard = [1160,810]

;;;;;;;;;;;;;;;;;;;;;;;;

Global $evencard1 = [575,543,585,553,0x5A0A0A,10]
Global $evencard2 = [737,543,747,553,0x5A0A0A,10]
Global $evencard3 = [900,543,910,553,0x5A0A0A,10]
Global $evencard4 = [1063,543,1073,553,0x5A0A0A,10]
Global $oddcard1 = [495,543,505,553,0x5A0A0A,10]
Global $oddcard2 = [657,543,667,553,0x5A0A0A,10]
Global $oddcard3 = [819,543,829,553,0x5A0A0A,10]
Global $oddcard4 = [981,543,991,553,0x5A0A0A,10]
Global $oddcard5 = [1143,543,1153,553,0x5A0A0A,10]

Global $v_card_battle_relative = [43,53]
Global $enemypos = [779,106]

Global $cardevens[4] = [$evencard1,$evencard2,$evencard3,$evencard4]
Global $cardodds[5] = [$oddcard1,$oddcard2,$oddcard3,$oddcard4,$oddcard5]

;;;;;;;;;;;;;;;;;;;;;

Global $readycard1 = [390,825,410,845,0xFFFDEB,10]
Global $readycard2 = [490,801,510,821,0xFFFDEB,10]
Global $readycard3 = [590,792,610,812,0xFFFDEB,10]
Global $readycard4 = [690,778,710,798,0xFFFDEB,10]
Global $readycard5 = [790,778,810,798,0xFFFDEB,10]
Global $readycard6 = [890,793,910,813,0xFFFDEB,10]
Global $readycard7 = [990,802,1010,822,0xFFFDEB,10]
Global $readycard8 = [1090,804,1110,824,0xFFFDEB,10]
Global $readycard9 = [1190,805,1210,825,0xFFFDEB,10]
Global $readycards = [$readycard1,$readycard2,$readycard3,$readycard4,$readycard5,$readycard6,$readycard7,$readycard8,$readycard9]

Global $jinhuaover = [1374,416,1378,420,0xF9F7E6,5]
;;;;;;;;;;;;;;;;;;;;;;;


Global $stationdesktop = False ; PC station flag


#include <Configuration.au3>
