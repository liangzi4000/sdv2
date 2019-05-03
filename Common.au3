#include-once
#include "GlobalVariables.au3"
#include "Lib/Logger.au3"
#include "Lib/Email.au3"
#include "Lib/Database.au3"
#include "Lib/CaptureScreenshot.au3"
#include "Lib/PositionHelper.au3"
#include "Lib/ImageHelper.au3"
#include "Lib/PixelHelper.au3"
#include "Lib/BasicActions.au3"
#include "Lib/ProcessHelper.au3"
#include "Lib/ArrayHelper.au3"
#include "Lib/Http.au3"
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <AutoItConstants.au3>
#include <File.au3>
#include <Date.au3>
#include <Clipboard.au3>
#include <Array.au3>

#Region Misc Helper
Func MutexExists($sOccurenceName)
	Local $ERROR_ALREADY_EXISTS = 183, $handle, $lastError
	$sOccurenceName = StringReplace($sOccurenceName, "\", "") ; to avoid error
	$handle = DllCall("kernel32.dll", "int", "CreateMutex", "int", 0, "long", 1, "str", $sOccurenceName)
	$lastError = DllCall("kernel32.dll", "int", "GetLastError")
	Return $lastError[0] = $ERROR_ALREADY_EXISTS
EndFunc   ;==>MutexExists
#EndRegion Misc Helper
