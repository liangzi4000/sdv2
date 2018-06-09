#AutoIt3Wrapper_UseX64 = Y
#include <Common.au3>

Run(@ScriptDir&"\StartSQLServer.bat")
WaitImageDesktop("nox_multi_drive.bmp")
Local $pos = [0,0]
SearchImageDesktop("nox_multi_drive.bmp",$pos[0], $pos[1])
MouseClick($MOUSE_CLICK_LEFT, $pos[0], $pos[1], 2, 0)
WaitImageDesktop("NoxPlayer04.bmp")
SearchImageDesktop("NoxPlayer04.bmp",$pos[0], $pos[1])
MouseClick($MOUSE_CLICK_LEFT, $pos[0]+446, $pos[1], 1, 0)
SearchImageDesktop("NoxPlayer05.bmp",$pos[0], $pos[1])
MouseClick($MOUSE_CLICK_LEFT, $pos[0]+446, $pos[1], 1, 0)
WaitImageDesktop("app_icon_home.bmp")
Run(@ScriptDir&"\Start.exe")
Sleep(10000)
Send("^m")
Exit

