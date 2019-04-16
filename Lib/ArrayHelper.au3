#include-once
#include <Array.au3>

#comments-start
	Copy const array $arr2 to array $arr1
	$arr1 and $arr2 must have same dimension, either 1d or 2d.
#comments-end
Func CopyArrayData(ByRef $arr1, Const ByRef $arr2)
	If UBound($arr1, 0) = 2 Then
		For $row = 0 To UBound($arr1, 1) - 1
			For $col = 0 To UBound($arr1, 2) - 1
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

Func ConvertArrayInArrayToString($arr)
	Local $result = ""
	For $x = 0 To UBound($arr) - 1
		$result &= _ArrayToString($arr[$x], ",") & "|"
	Next
	Return $result
EndFunc   ;==>ConvertArrayInArrayToString

Func GetRowFromArray(ByRef $arrr, $index)
	Local $elem = []
	For $col = 0 To UBound($arrr, 2) - 1
		_ArrayAdd($elem, $arrr[$index][$col])
	Next
	_ArrayDelete($elem, 0)
	Return $elem
EndFunc   ;==>GetRowFromArray

