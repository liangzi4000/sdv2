#include-once
#Include <file.au3>

Global $oMyEmailRet[2]
Global $oMyEmailError = ObjEvent("AutoIt.Error", "MyEmailErrFunc")

Func _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "", $s_CcAddress = "", $s_BccAddress = "", $s_Importance="Normal", $s_Username = "", $s_Password = "", $IPPort = 25, $ssl = 0)
    Local $objEmail = ObjCreate("CDO.Message")
    $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
    $objEmail.To = $s_ToAddress
    Local $i_Error = 0
    Local $i_Error_desciption = ""
    If $s_CcAddress <> "" Then $objEmail.Cc = $s_CcAddress
    If $s_BccAddress <> "" Then $objEmail.Bcc = $s_BccAddress
    $objEmail.Subject = $s_Subject
    If StringInStr($as_Body, "<") And StringInStr($as_Body, ">") Then
        $objEmail.HTMLBody = $as_Body
    Else
        $objEmail.Textbody = $as_Body & @CRLF
    EndIf
    If $s_AttachFiles <> "" Then
        Local $S_Files2Attach = StringSplit($s_AttachFiles, ";")
        For $x = 1 To $S_Files2Attach[0]
            $S_Files2Attach[$x] = _PathFull($S_Files2Attach[$x])
            If FileExists($S_Files2Attach[$x]) Then
                WriteLog("File attachment added: " & $S_Files2Attach[$x])
                $objEmail.AddAttachment($S_Files2Attach[$x])
            Else
                WriteLog("File not found to attach: " & $S_Files2Attach[$x])
            EndIf
        Next
    EndIf
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $s_SmtpServer
    If Number($IPPort) = 0 then $IPPort = 25
    $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $IPPort
    ;Authenticated SMTP
    If $s_Username <> "" Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendusername") = $s_Username
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $s_Password
    EndIf
    If $ssl Then
        $objEmail.Configuration.Fields.Item ("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
    EndIf
    ;Update settings
    $objEmail.Configuration.Fields.Update
    ; Set Email Importance
    Switch $s_Importance
        Case "High"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "High"
        Case "Normal"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Normal"
        Case "Low"
            $objEmail.Fields.Item ("urn:schemas:mailheader:Importance") = "Low"
    EndSwitch
    $objEmail.Fields.Update
    ; Sent the Message
    $objEmail.Send
    If @error Then
        SetError(2)
        Return $oMyEmailRet[1]
    EndIf
    $objEmail=""
EndFunc   ;==>_INetSmtpMailCom
;
;
; Com Error Handler
Func MyEmailErrFunc()
    Local $HexNumber = Hex($oMyEmailError.number, 8)
    $oMyEmailRet[0] = $HexNumber
    $oMyEmailRet[1] = StringStripWS($oMyEmailError.description, 3)
    WriteLog("COM Error !  Number: " & $HexNumber & @CRLF & "	ScriptLine: " & $oMyEmailError.scriptline & @CRLF & "	Description:" & $oMyEmailRet[1])
    SetError(1); something to check for when this function returns
    Return
EndFunc   ;==>MyEmailErrFunc