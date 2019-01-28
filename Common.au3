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

#comments-start
	Copy const array $arr2 to array $arr1
#comments-end
Func CopyArrayData(ByRef $arr1, Const ByRef $arr2)
	If UBound($arr1,0) = 2 Then
		For $row = 0 To UBound($arr1,1) - 1
			For $col = 0 To UBound($arr1,2) - 1
				$arr1[$row][$col] = $arr2[$row][$col]
			Next
		Next
	Else
		For $i = 0 To UBound($arr1) - 1
			$arr1[$i] = $arr2[$i]
		Next
	EndIf
EndFunc   ;==>CopyArrayData

Func AddArrayElem(ByRef $arr1, $elem)
	If _ArraySearch($arr1, $elem) = -1 Then
		_ArrayAdd($arr1, $elem)
	EndIf
EndFunc   ;==>AddArrayElem
#EndRegion Misc Helper
